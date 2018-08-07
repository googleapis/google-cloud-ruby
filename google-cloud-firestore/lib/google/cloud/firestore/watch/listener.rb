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
require "google/cloud/firestore/watch/enumerator_queue"
require "google/cloud/firestore/watch/inventory"
require "monitor"
require "thread"

module Google
  module Cloud
    module Firestore
      ##
      # @private
      module Watch
        ##
        # @private
        class Listener
          include MonitorMixin

          def self.for_doc_ref doc_ref, &callback
            raise ArgumentError if doc_ref.nil?
            raise ArgumentError if callback.nil?

            init_listen_req = Google::Firestore::V1beta1::ListenRequest.new(
              database: doc_ref.client.path,
              add_target: Google::Firestore::V1beta1::Target.new(
                documents: \
                  Google::Firestore::V1beta1::Target::DocumentsTarget.new(
                    documents: [doc_ref.path]
                  )
              )
            )

            new nil, doc_ref, doc_ref.client, init_listen_req, &callback
          end

          def self.for_query query, &callback
            raise ArgumentError if query.nil?
            raise ArgumentError if callback.nil?

            init_listen_req = Google::Firestore::V1beta1::ListenRequest.new(
              database: query.client.path,
              add_target: Google::Firestore::V1beta1::Target.new(
                query: Google::Firestore::V1beta1::Target::QueryTarget.new(
                  parent: query.parent_path,
                  structured_query: query.query
                )
              )
            )

            new query, nil, query.client, init_listen_req, &callback
          end

          def initialize query, doc_ref, client, init_listen_req, &callback
            @query = query
            @doc_ref = doc_ref
            @client = client
            @init_listen_req = init_listen_req
            @callback = callback

            super() # to init MonitorMixin
          end

          def start
            synchronize { start_listening! }
            self
          end

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
          #   # Create a query
          #   query = firestore.col(:cities).order(:population, :desc)
          #
          #   listener = query.listen do |snapshot|
          #     puts "The query snapshot has #{snapshot.docs.count} documents "
          #     puts "and has #{snapshot.changes.count} changes."
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

          def send_callback query_snp
            @callback.call query_snp
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

            # Reuse inventory if one already exists
            # Even though this uses an @var, no need to synchronize
            @inventory ||= Inventory.new(@client, @query)
            @inventory.restart

            # Send stop if already running
            synchronize do
              @request_queue.push self if @request_queue
            end

            # Customize the provided initial listen request
            init_listen_req = @init_listen_req.dup.tap do |req|
              req.add_target.resume_token = String(@inventory.resume_token)
              req.add_target.target_id = 0x42
            end

            # Always create a new enum queue
            synchronize do
              @request_queue = EnumeratorQueue.new self
              @request_queue.push init_listen_req
            end

            # Not an @var, we get a new enum each time
            enum = synchronize do
              @client.service.listen @request_queue.each
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

                    @inventory.persist(
                      response.target_change.resume_token,
                      Convert.timestamp_to_time(
                        response.target_change.read_time
                      )
                    )

                    if @inventory.current? && @inventory.changes?
                      synchronize do
                        send_callback @inventory.build_query_snapshot
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

                    @inventory.persist(
                      response.target_change.resume_token,
                      Convert.timestamp_to_time(
                        response.target_change.read_time
                      )
                    )

                    @inventory.current = true
                  when :RESET
                    # The targets have been reset, and a new initial state for the
                    # targets will be returned in subsequent changes.
                    #
                    # After the initial state is complete, +CURRENT+ will be
                    # returned even if the target was previously indicated to be
                    # +CURRENT+.

                    @inventory.reset
                    raise RestartStream # Raise to restart the stream
                  end
                when :document_change
                  # A {Google::Firestore::V1beta1::Document Document} has changed.

                  if response.document_change.removed_target_ids.any?
                    @inventory.delete response.document_change.document.name
                  else
                    @inventory.add response.document_change.document
                  end
                when :document_delete
                  # A {Google::Firestore::V1beta1::Document Document} has been
                  # deleted.

                  @inventory.delete response.document_delete.document
                when :document_remove
                  # A {Google::Firestore::V1beta1::Document Document} has been
                  # removed from a target (because it is no longer relevant to
                  # that target).

                  @inventory.delete response.document_remove.document
                when :filter
                  # A filter to apply to the set of documents previously returned
                  # for the given target.
                  #
                  # Returned when documents may have been removed from the given
                  # target, but the exact documents are unknown.

                  if response.filter.count != @inventory.size
                    @inventory.reset
                    raise RestartStream # Raise to restart the stream
                  end
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
        end
      end
    end
  end
end
