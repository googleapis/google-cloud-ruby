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


require "google/cloud/firestore/v1"
require "google/cloud/firestore/convert"
require "google/cloud/firestore/document_reference"
require "google/cloud/firestore/document_snapshot"
require "google/cloud/firestore/document_change"
require "google/cloud/firestore/query_snapshot"
require "google/cloud/firestore/watch/order"
require "rbtree"

module Google
  module Cloud
    module Firestore
      ##
      # @private
      module Watch
        # @private Collects changes and produces a QuerySnapshot.
        # Uses RBTree to hold a sorted list of DocumentSnapshot objects and to
        # make inserting and removing objects much more efficent.
        class Inventory
          attr_accessor :current
          attr_reader :resume_token
          attr_reader :read_time

          def initialize client, query
            @client = client
            @query = query
            @pending = {
              add:    [],
              delete: []
            }
            @current = nil
            @resume_token = nil
            @read_time = nil
            @tree = RBTree.new
            @tree.readjust(&method(:query_comparison_proc))
            @old_order = nil

            # TODO: Remove this when done benchmarking
            @comp_proc_counter = 0
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
          alias count size

          def size_with_pending
            count_with_pending_tree = @tree.dup
            apply_pending_changes_to_tree @pending, count_with_pending_tree
            count_with_pending_tree.size
          end
          alias count_with_pending size_with_pending

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

          # TODO: Remove this when done benchmarking
          def reset_comp_proc_counter!
            old_count = @comp_proc_counter
            @comp_proc_counter = 0
            old_count
          end

          def persist resume_token, read_time
            @resume_token = resume_token
            @read_time = read_time

            apply_pending_changes_to_tree @pending, @tree
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
            # Reverse the results for Query#limit_to_last queries since that method reversed the order_by directions.
            return @tree.keys.reverse if @query&.limit_type == :last
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

          def query_comparison_proc left, right
            # TODO: Remove this when done benchmarking
            @comp_proc_counter += 1

            return Order.compare_field_values left.ref, right.ref if @query.nil?

            @directions ||= @query.query.order_by.map(&:direction)

            left_comps = left.query_comparisons_for @query.query
            right_comps = right.query_comparisons_for @query.query
            @directions.zip(left_comps, right_comps).each do |dir, left_comp, right_comp|
              comp = left_comp <=> right_comp
              comp = 0 - comp if dir == :DESCENDING
              return comp unless comp.zero?
            end

            # Compare paths when everything else is equal
            ref_comp = Order.compare_field_values left.ref, right.ref
            ref_comp = 0 - ref_comp if @directions.last == :DESCENDING
            ref_comp
          end

          def apply_pending_changes_to_tree pending, tree
            # Remove the deleted documents
            pending[:delete].each do |doc_path|
              remove_doc_from_tree doc_path, tree
            end

            # Add/update the changed documents
            pending[:add].each do |doc_grpc|
              removed_doc = remove_doc_from_tree doc_grpc.name, tree
              added_doc = DocumentSnapshot.from_document(
                doc_grpc, @client, read_at: read_time
              )

              if removed_doc && removed_doc.updated_at >= added_doc.updated_at
                # Restore the removed doc if the added doc isn't newer
                added_doc = removed_doc
              end

              add_doc_to_tree added_doc, tree
            end
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
            new_paths = new_order.keys
            old_paths = old_order.keys
            added_paths, deleted_paths, changed_paths = \
              change_paths new_order, old_order

            changes = deleted_paths.map do |doc_path|
              build_deleted_doc_change doc_path, old_paths
            end
            changes += added_paths.map do |doc_path|
              build_added_doc_change doc_path, new_paths
            end
            changes += changed_paths.map do |doc_path|
              build_modified_doc_change doc_path, new_paths, old_paths
            end
            changes
          end

          def build_deleted_doc_change doc_path, old_paths
            doc_ref = DocumentReference.from_path doc_path, @client
            doc_snp = DocumentSnapshot.missing doc_ref
            old_index = get_index_from_order_array doc_path, old_paths
            DocumentChange.from_doc doc_snp, old_index, nil
          end

          def build_added_doc_change doc_path, new_paths
            doc_snp = get_doc_from_tree doc_path, @tree
            new_index = get_index_from_order_array doc_path, new_paths
            DocumentChange.from_doc doc_snp, nil, new_index
          end

          def build_modified_doc_change doc_path, new_paths, old_paths
            doc_snp = get_doc_from_tree doc_path, @tree
            old_index = get_index_from_order_array doc_path, old_paths
            new_index = get_index_from_order_array doc_path, new_paths
            DocumentChange.from_doc doc_snp, old_index, new_index
          end

          def get_index_from_order_array doc_path, order_array
            order_array.index doc_path
          end

          def get_doc_from_tree doc_path, tree
            tree.key doc_path
          end

          def add_doc_to_tree doc_snp, tree
            tree[doc_snp] = doc_snp.path
          end

          def remove_doc_from_tree doc_path, tree
            # Remove old snapshot
            old_snp = tree.key doc_path
            tree.delete old_snp unless old_snp.nil?
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
