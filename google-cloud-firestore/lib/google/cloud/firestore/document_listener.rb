# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require "google/cloud/firestore/v1beta1"
require "google/cloud/firestore/convert"
require "google/cloud/firestore/document_snapshot"
require "google/cloud/firestore/enumerator_queue"
require "thread"
require "monitor"

module Google
  module Cloud
    module Firestore
      ##
      # An ongoing listen operation on a document reference. This is returned by
      # calling {DocumentReference#listen}.
      #
      # @example
      #   require "google/cloud/firestore"
      #
      #   firestore = Google::Cloud::Firestore.new
      #
      #   # Get a document reference
      #   nyc_ref = firestore.doc "cities/NYC"
      #
      #   listener = nyc_ref.listen do |snapshot|
      #     puts "The population of #{snapshot[:name]} "
      #     puts "is #{snapshot[:population]}."
      #   end
      #
      #   # When ready, stop the listen operation and close the stream.
      #   listener.stop
      #
      class DocumentListener
        include MonitorMixin

        ##
        # @private
        # Creates the watch stream and listener object.
        def initialize doc_ref, &callback
          @doc_ref = doc_ref
          raise ArgumentError if @doc_ref.nil?

          @callback = callback
          raise ArgumentError if @callback.nil?

          super() # to init MonitorMixin
        end

        ##
        # @private
        # Starts the client listening for changes. This is called when the
        # listener object is created, which is why this method is not part of
        # the public API.
        def start
          synchronize { start_listening! }
          self
        end

        ##
        # Stops the client listening for changes.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   listener = nyc_ref.listen do |snapshot|
        #     puts "The population of #{snapshot[:name]} "
        #     puts "is #{snapshot[:population]}."
        #   end
        #
        #   # When ready, stop the listen operation and close the stream.
        #   listener.stop
        #
        def stop
          synchronize do
            @stopped = true
            @request_queue.push self if @request_queue
          end
        end

        ##
        # Whether the client has stopped listening for changes.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a document reference
        #   nyc_ref = firestore.doc "cities/NYC"
        #
        #   listener = nyc_ref.listen do |snapshot|
        #     puts "The population of #{snapshot[:name]} "
        #     puts "is #{snapshot[:population]}."
        #   end
        #
        #   # Checks if the listener is stopped.
        #   listener.stopped? #=> false
        #
        #   # When ready, stop the listen operation and close the stream.
        #   listener.stop
        #
        #   # Checks if the listener is stopped.
        #   listener.stopped? #=> true
        #
        def stopped?
          synchronize { @stopped }
        end

        private

        def send_callback doc_snp
          @callback.call doc_snp
        end

        def start_listening!
          # create new background thread to handle the stream's enumerator
          @background_thread = Thread.new { background_run }
        end

        # @private
        class RestartStream < StandardError; end

        # rubocop:disable all

        def background_run
          # Don't allow a stream to restart if already stopped
          return if synchronize { @stopped }

          @backoff ||= { current: 0, delay: 1.0, max: 5, mod: 1.3 }

          # Create empty inventory every time
          # Even though this uses an @var, no need to synchronize
          @inventory = []

          # Send stop if already running
          synchronize do
            @request_queue.push self if @request_queue
          end

          # Customize the provided initial listen request
          init_listen_req = Google::Firestore::V1beta1::ListenRequest.new(
            database: synchronize { @doc_ref.client.path },
            add_target: Google::Firestore::V1beta1::Target.new(
              documents: \
                Google::Firestore::V1beta1::Target::DocumentsTarget.new(
                  documents: synchronize { [@doc_ref.path] }
                ),
              resume_token: String(@resume_token),
              read_time: Convert.time_to_timestamp(@read_time),
              target_id: 0x42
            )
          )

          # Always create a new enum queue
          synchronize do
            @request_queue = EnumeratorQueue.new self
            @request_queue.push init_listen_req

          end

          # Not an @var, we get a new enum each time
          enum = synchronize do
            @doc_ref.client.service.listen @request_queue.each
          end

          loop do

            # Break loop, close thread if stopped
            break if synchronize { @stopped }

            begin
              # Cannot syncronize the enumerator, causes deadlock
              response = enum.next

              case response.response_type
              when :target_change
                case response.target_change.target_change_type
                when :NO_CHANGE
                  # No change has occurred. Used only to send an updated
                  # +resume_token+.

                  @resume_token = response.target_change.resume_token
                  @read_time    = Convert.timestamp_to_time \
                    response.target_change.read_time

                  unless @inventory.empty?
                    synchronize do
                      send_callback get_latest_doc_snp(@read_time)
                    end
                  end
                when :CURRENT
                  # The targets reflect all changes committed before the targets
                  # were added to the stream.
                  #
                  # This will be sent after or with a +read_time+ that is
                  # greater than or equal to the time at which the targets were
                  # added.
                  #
                  # Listeners can wait for this change if read-after-write
                  # semantics are desired.

                  @resume_token = response.target_change.resume_token
                  @read_time    = Convert.timestamp_to_time \
                    response.target_change.read_time
                when :RESET
                  # The targets have been reset, and a new initial state for the
                  # targets will be returned in subsequent changes.
                  #
                  # After the initial state is complete, +CURRENT+ will be
                  # returned even if the target was previously indicated to be
                  # +CURRENT+.

                  raise RestartStream # Raise to restart the stream
                end
              when :document_change
                # A {Google::Firestore::V1beta1::Document Document} has changed.

                @inventory << response.document_change.document
              when :document_delete
                # A {Google::Firestore::V1beta1::Document Document} has been
                # deleted.

                @inventory << nil
              when :document_remove
                # A {Google::Firestore::V1beta1::Document Document} has been
                # removed from a target (because it is no longer relevant to
                # that target).

                @inventory << nil
              end

            rescue StopIteration
              break
            end

            # Reset backoff values when completed without an error
            @backoff[:current] = 0
            @backoff[:delay] = 1.0
          end

          # Has the loop broken but we aren't stopped?
          # Could be GRPC has thrown an internal error, so restart.
          raise RestartStream
        rescue GRPC::Cancelled, GRPC::DeadlineExceeded, GRPC::Internal,
               GRPC::ResourceExhausted, GRPC::Unauthenticated,
               GRPC::Unavailable, GRPC::Core::CallError
          # Restart the stream with an incremental back for a retriable error.
          # Also when GRPC raises the internal CallError.

          # Re-raise if retried more than the max
          raise err if @backoff[:current] > @backoff[:max]

          # Sleep with incremental backoff before restarting
          sleep @backoff[:delay]

          # Update increment backoff delay and retry counter
          @backoff[:delay] *= @backoff[:mod]
          @backoff[:current] += 1

          retry
        rescue RestartStream
          retry
        rescue StandardError => e
          raise Google::Cloud::Error.from_error(e)
        end

        def get_latest_doc_snp read_time = nil
          grpc_doc = @inventory.last
          @inventory.clear

          if grpc_doc
            return DocumentSnapshot.from_document(
              grpc_doc, @doc_ref.client, read_at: read_time
            )
          end

          DocumentSnapshot.missing @doc_ref, read_at: read_time
        end
      end
    end
  end
end
