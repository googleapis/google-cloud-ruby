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

          @inventory    = nil
          @resume_token = nil
          @read_time    = nil

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

        # rubocop:disable all

        def background_run enum
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

                  synchronize do
                    @resume_token = response.target_change.resume_token
                    @read_time    = Convert.timestamp_to_time \
                      response.target_change.read_time

                    if @inventory.pending?
                      send_callback @inventory.to_query_snapshot(@read_time)
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

                  synchronize do
                    @resume_token = response.target_change.resume_token
                    @read_time    = Convert.timestamp_to_time \
                      response.target_change.read_time

                    send_callback @inventory.to_query_snapshot(@read_time)
                  end
                when :RESET
                  # The targets have been reset, and a new initial state for the
                  # targets will be returned in subsequent changes.
                  #
                  # After the initial state is complete, +CURRENT+ will be
                  # returned even if the target was previously indicated to be
                  # +CURRENT+.

                  raise "restart stream" # Raise to restart the stream
                end
              when :document_change
                # A {Google::Firestore::V1beta1::Document Document} has changed.

                synchronize do
                  @inventory.add response.document_change.document
                end
              when :document_delete
                # A {Google::Firestore::V1beta1::Document Document} has been
                # deleted.

                synchronize do
                  @inventory.delete response.document_delete.document
                end
              when :document_remove
                # A {Google::Firestore::V1beta1::Document Document} has been
                # removed from a target (because it is no longer relevant to
                # that target).

                synchronize do
                  @inventory.delete response.document_remove.document
                end
              end
            rescue StopIteration
              break
            end
          end
          # Has the loop broken but we aren't stopped?
          # Could be GRPC has thrown an internal error, so restart.
          synchronize { raise "restart thread" unless @stopped }
        rescue GRPC::DeadlineExceeded, GRPC::Unavailable, GRPC::Cancelled,
               GRPC::ResourceExhausted, GRPC::Internal,
               GRPC::Core::CallError => e
          # The GAPIC layer will raise DeadlineExceeded when stream is opened
          # longer than the timeout value it is configured for. When this
          # happends, restart the stream stealthly.
          # Also stealthly restart the stream on Unavailable, Cancelled,
          # ResourceExhausted, and Internal.
          # Also, also stealthly restart the stream when GRPC raises the
          # internal CallError.
          synchronize { start_listening! }
        rescue StandardError => e
          synchronize do
            raise Google::Cloud::Error.from_error(e) if @stopped

            start_listening!
          end
        end

        # rubocop:enable all

        def start_listening!
          # Don't allow a stream to restart if already stopped
          return if @stopped

          # Reuse inventory if one already exists
          @inventory ||= Inventory.new @query
          @inventory.clear

          # Send stop if already running
          @request_queue.push self if @request_queue

          # Customize the provided initial listen request
          init_listen_req = Google::Firestore::V1beta1::ListenRequest.new(
            database: @query.client.path,
            add_target: Google::Firestore::V1beta1::Target.new(
              query: Google::Firestore::V1beta1::Target::QueryTarget.new(
                parent: @query.parent_path,
                structured_query: @query.query
              ),
              resume_token: String(@resume_token),
              read_time: Convert.time_to_timestamp(@read_time),
              target_id: 0x42
            )
          )

          # Always create a new enum queue
          @request_queue = EnumeratorQueue.new self
          @request_queue.push init_listen_req

          output_enum = @query.client.service.listen @request_queue.each

          # create new background thread to handle new enumerator
          @background_thread = Thread.new(output_enum) do |enum|
            background_run enum
          end
        end

        # @private Collects changes and produces a QuerySnapshot.
        # Uses RBTree to hold a sorted list of DocumentSnapshot objects and to
        # make inserting and removing objects much more efficent.
        class Inventory
          def initialize query
            @query = query
            @to_add = []
            @to_delete = []
            @tree = RBTree.new
            @tree.readjust(&method(:init_aware_query_comparison_proc))
            @old_order = {}

            @initial_load = true
          end

          def add doc_snp
            @to_add << doc_snp
          end

          def delete doc_path
            @to_delete << doc_path
          end

          def pending?
            @to_add.any? || @to_delete.any?
          end

          def clear
            @to_add.clear
            @to_delete.clear
          end

          def to_query_snapshot read_time
            # Remove the deleted documents
            @to_delete.each do |doc_path|
              remove_doc_path doc_path
            end

            # Add/update the changed documents
            @to_add.each do |doc_grpc|
              remove_doc_path doc_grpc.name
              add_doc_snp DocumentSnapshot.from_document(
                doc_grpc, @query.client, read_at: read_time
              )
            end

            # Get the new set of documents, changes, order
            docs = @tree.keys
            new_order = Hash[docs.map(&:path).each_with_index.to_a] # O(n)
            changes = calc_changes \
              @to_add, @to_delete, @old_order, new_order, read_time

            @old_order = new_order

            clear
            @initial_load = false

            QuerySnapshot.from_docs @query, docs, changes, read_time
          end

          protected

          def init_aware_query_comparison_proc a, b
            # When loading for the first time we want to always append.
            # This is because the API returns sorted query results.
            # This also provides a massive performance improvement because
            # sorting an already sorted red-black tree is a worst case scenario.
            return 1 if @initial_load

            query_comparison_proc a, b
          end

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
            nodes = value.split("/")
            [nodes.count, nodes]
          end

          def field_type value
            return 0 if value.nil?
            return 1 if value == false
            return 1 if value == true
            return 2 if value.is_a? Numeric
            return 3 if value.is_a? String
            return 4 if value.is_a? StringIO
            return 5 if value.is_a? Array
            return 6 if value.is_a? Hash

            raise "Can't determine field type for #{value.class}"
          end

          def field_value value
            return 0 if value.nil?
            return 0 if value == false
            return 1 if value == true
            return value if value.is_a? Numeric
            return value if value.is_a? String
            return value.string if value.is_a? StringIO
            return value.map { |v| field_comparison(v) } if value.is_a? Array
            if value.is_a? Hash
              return value.sort.map { |k, v| [k, field_comparison(v)] }
            end

            raise "Can't determine field value for #{value}"
          end

          def calc_changes add_docs, del_docs, old_order, new_order, read_time
            additions = add_docs.map do |doc_grpc|
              old_index = old_order[doc_grpc.name]
              new_index = new_order[doc_grpc.name]
              type = type_from_indexes old_index, new_index
              doc_snp = DocumentSnapshot.from_document(
                doc_grpc, @query.client, read_at: read_time
              )
              DocumentChange.from_doc doc_snp, type, old_index, new_index
            end
            removals = del_docs.map do |doc_path|
              old_index = old_order[doc_path]
              doc_ref = DocumentReference.from_path doc_path, @query.client
              doc_snp = DocumentSnapshot.missing doc_ref, read_at: read_time
              DocumentChange.from_doc doc_snp, :removed, old_index, nil
            end
            additions + removals
          end

          def add_doc_snp doc_snp
            @tree[doc_snp] = doc_snp.path
          end

          def remove_doc_path doc_path
            # # lookup using Hash#[] is faster than RBTree#key, O(1) vs O(???)
            # return if @old_order[doc_path].nil?

            # Remove old snapshot
            old_snp = @tree.key doc_path
            @tree.delete old_snp unless old_snp.nil?
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
