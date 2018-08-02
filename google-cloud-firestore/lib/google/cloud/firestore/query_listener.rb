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
require "google/cloud/firestore/document_reference"
require "google/cloud/firestore/document_snapshot"
require "google/cloud/firestore/document_change"
require "google/cloud/firestore/query_snapshot"
require "google/cloud/firestore/enumerator_queue"
require "monitor"
require "rbtree"
require "thread"

module Google
  module Cloud
    module Firestore
      ##
      # # QueryListener
      #
      # An ongoing listen operation on a query. This is returned by calling
      # {Query#listen}.
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
      #   # When ready, stop the listen operation and close the stream.
      #   listener.stop
      #
      class QueryListener
        include MonitorMixin

        ##
        # @private
        # Creates the watch stream and listener object.
        def initialize query, &callback
          @query = query
          raise ArgumentError if @query.nil?

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
        #   # Create a query
        #   query = firestore.col(:cities).order(:population, :desc)
        #
        #   listener = query.listen do |snapshot|
        #     puts "The query snapshot has #{snapshot.docs.count} documents "
        #     puts "and has #{snapshot.changes.count} changes."
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
          @inventory ||= Inventory.new(synchronize { @query })
          @inventory.restart

          # Send stop if already running
          synchronize do
            @request_queue.push self if @request_queue
          end

          # Customize the provided initial listen request
          init_listen_req = Google::Firestore::V1beta1::ListenRequest.new(
            database: synchronize { @query.client.path },
            add_target: Google::Firestore::V1beta1::Target.new(
              query: Google::Firestore::V1beta1::Target::QueryTarget.new(
                parent: synchronize { @query.parent_path },
                structured_query: synchronize { @query.query }
              ),
              resume_token: String(@inventory.resume_token),
              read_time: Convert.time_to_timestamp(@inventory.read_time),
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
            @query.client.service.listen @request_queue.each
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
        rescue StandardError
          raise Google::Cloud::Error.from_error(e)
        end

        # rubocop:enable all

        # @private Collects changes and produces a QuerySnapshot.
        # Uses RBTree to hold a sorted list of DocumentSnapshot objects and to
        # make inserting and removing objects much more efficent.
        class Inventory
          attr_accessor :current
          attr_reader :resume_token, :read_time

          def initialize query
            @query = query
            @pending = {
              add: [],
              delete: []
            }
            @current = nil
            @resume_token = nil
            @read_time = nil
            @tree = RBTree.new
            @tree.readjust(&method(:query_comparison_proc))
            @old_order = nil
          end

          def current?
            @current
          end

          def add doc_grpc
            @pending[:add] << doc_grpc
          end

          def delete doc_path
            @pending[:delete] << doc_path
          end

          def pending?
            @pending[:add].any? || @pending[:delete].any?
          end

          def clear_pending
            @pending[:add].clear
            @pending[:delete].clear
          end

          def size
            @tree.size
          end

          def restart
            # clears all but query, resume token, read time, and old order
            clear_pending

            @current = nil

            @tree.clear
          end

          def reset
            restart

            # clears the resume token and read time, but not query and old order
            @resume_token = nil
            @read_time = nil
          end

          def persist resume_token, read_time
            # Remove the deleted documents
            @pending[:delete].each do |doc_path|
              remove_doc_from_tree doc_path
            end

            # Add/update the changed documents
            @pending[:add].each do |doc_grpc|
              removed_doc = remove_doc_from_tree doc_grpc.name
              added_doc = DocumentSnapshot.from_document(
                doc_grpc, @query.client, read_at: read_time
              )

              if removed_doc && removed_doc.updated_at >= added_doc.updated_at
                # Restore the removed doc if the added doc isn't newer
                added_doc = removed_doc
              end

              add_doc_to_tree added_doc
            end

            @resume_token = resume_token
            @read_time = read_time
            clear_pending
          end

          def changes?
            # Act like there are changes if we have never run before
            return true if @old_order.nil?
            added_paths, deleted_paths, changed_paths = \
              change_paths current_order, @old_order
            added_paths.any? || deleted_paths.any? || changed_paths.any?
          end

          def current_docs
            @tree.keys
          end

          def order_for docs
            Hash[docs.map { |doc| [doc.path, doc.updated_at] }]
          end

          def current_order
            order_for current_docs
          end

          def build_query_snapshot
            # If this is the first time building, set to empty hash
            @old_order ||= {}

            # Get the new set of documents, changes, order
            docs = current_docs
            new_order = order_for docs
            changes = build_changes new_order, @old_order
            @old_order = new_order

            QuerySnapshot.from_docs @query, docs, changes, @read_time
          end

          protected

          def query_comparison_proc a, b
            last_direction = nil

            @query.query.order_by.each do |order|
              field_path = order.field.field_path # "__name__"
              last_direction = order.direction

              comp = compare_fields field_path, a[field_path], b[field_path]
              comp = apply_direction comp, last_direction
              return comp unless comp.zero?
            end

            apply_direction compare_paths(a.path, b.path), last_direction
          end

          def apply_direction comparision, direction
            return 0 - comparision if direction == :DESCENDING

            comparision
          end

          def compare_fields field_path, a_value, b_value
            if field_path == "__name__".freeze
              return compare_paths a_value, b_value
            end

            compare_values a_value, b_value
          end

          def compare_values a_value, b_value
            field_comparison(a_value) <=> field_comparison(b_value)
          end

          def compare_paths a_path, b_path
            path_comparison(a_path) <=> path_comparison(b_path)
          end

          def field_comparison value
            [field_type(value), field_value(value)]
          end

          def path_comparison value
            value.split("/")
          end

          def field_type value
            return 0 if value.nil?
            return 1 if value == false
            return 1 if value == true
            # The backend ordering semantics treats NaN and Numbers as the same
            # type, and then internally orders NaNs before Numbers. Ruby's
            # Float::NAN cannot be compared, similar to nil, so we need to use a
            # stand in value instead. Therefore the desired sorting is achieved
            # by separating NaN and Number types. This is an intentional
            # divergence from type order that is used in the backend and in the
            # other SDKs. (And because Ruby has to be special.)
            return 2 if value.respond_to?(:nan?) && value.nan?
            return 3 if value.is_a? Numeric
            return 4 if value.is_a? Time
            return 5 if value.is_a? String
            return 6 if value.is_a? StringIO
            return 7 if value.is_a? DocumentReference
            return 9 if value.is_a? Array
            if value.is_a? Hash
              return 8 if Convert.hash_is_geo_point? value
              return 10
            end

            raise "Can't determine field type for #{value.class}"
          end

          def field_value value
            # nil can't be compared, so use 0 as a stand in.
            return 0 if value.nil?
            return 0 if value == false
            return 1 if value == true
            # NaN can't be compared, so use 0 as a stand in.
            return 0 if value.respond_to?(:nan?) && value.nan?
            return value if value.is_a? Numeric
            return value if value.is_a? Time
            return value if value.is_a? String
            return value.string if value.is_a? StringIO
            return path_comparison(value.path) if value.is_a? DocumentReference
            return value.map { |v| field_comparison(v) } if value.is_a? Array
            if value.is_a? Hash
              geo_pairs = Convert.hash_is_geo_point? value
              return geo_pairs.map(&:last) if geo_pairs
              return value.sort.map { |k, v| [k, field_comparison(v)] }
            end

            raise "Can't determine field value for #{value}"
          end

          def change_paths new_order, old_order
            added_paths = new_order.keys - old_order.keys
            deleted_paths = old_order.keys - new_order.keys
            new_hash = new_order.dup.delete_if do |path, _updated_at|
              added_paths.include? path
            end
            old_hash = old_order.dup.delete_if do |path, _updated_at|
              deleted_paths.include? path
            end
            changed_paths = (new_hash.to_a - old_hash.to_a).map(&:first)

            [added_paths, deleted_paths, changed_paths]
          end

          def build_changes new_order, old_order
            added_paths, deleted_paths, changed_paths = \
              change_paths new_order, old_order

            changes = deleted_paths.map do |doc_path|
              doc_ref = DocumentReference.from_path doc_path, @query.client
              doc_snp = DocumentSnapshot.missing doc_ref
              DocumentChange.from_doc \
                doc_snp, old_order.keys.index(doc_path), nil
            end
            changes += added_paths.map do |doc_path|
              DocumentChange.from_doc \
                @tree.key(doc_path), nil, new_order.keys.index(doc_path)
            end
            changes += changed_paths.map do |doc_path|
              DocumentChange.from_doc \
                @tree.key(doc_path),
                old_order.keys.index(doc_path),
                new_order.keys.index(doc_path)
            end
            changes
          end

          def add_doc_to_tree doc_snp
            @tree[doc_snp] = doc_snp.path
          end

          def remove_doc_from_tree doc_path
            # Remove old snapshot
            old_snp = @tree.key doc_path
            @tree.delete old_snp unless old_snp.nil?
            old_snp
          end

          def type_from_indexes old_index, new_index
            return :removed if new_index.nil?
            return :added if old_index.nil?
            :modified
          end
        end
      end
    end
  end
end
