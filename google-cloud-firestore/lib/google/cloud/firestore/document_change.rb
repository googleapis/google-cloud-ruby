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


module Google
  module Cloud
    module Firestore
      ##
      # # DocumentChange
      #
      # A DocumentChange object represents a change to the document matching a
      # query. It contains the document affected and the type of change that
      # occurred (added, modifed, or removed).
      #
      # See {Query#listen} and {QuerySnapshot#changes}.
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
      class DocumentChange
        ##
        # The document snapshot object for the data.
        #
        # @return [DocumentSnapshot] document snapshot.
        #
        def doc
          @doc
        end
        alias document doc

        ##
        # The type of change (':added', ':modified', or ':removed').
        #
        # @return [Symbol] The type of change.
        #
        def type
          return :removed if @new_index.nil?
          return :added if @old_index.nil?
          :modified
        end

        ##
        # Determines whether the document was added.
        #
        # @return [Boolean] Whether the document was added.
        #
        def added?
          type == :added
        end

        ##
        # Determines whether the document was modified.
        #
        # @return [Boolean] Whether the document was modified.
        #
        def modified?
          type == :modified
        end

        ##
        # Determines whether the document was removed.
        #
        # @return [Boolean] Whether the document was removed.
        #
        def removed?
          type == :removed
        end

        ##
        # The index in the documents array prior to the change.
        #
        # @return [Integer, nil] The old index
        #
        def old_index
          @old_index
        end

        ##
        # The index in the documents array after the change.
        #
        # @return [Integer, nil] The new index
        #
        def new_index
          @new_index
        end

        ##
        # @private New DocumentChange from a
        # Google::Cloud::Firestore::DocumentSnapshot object.
        def self.from_doc doc, old_index, new_index
          new.tap do |s|
            s.instance_variable_set :@doc, doc
            s.instance_variable_set :@old_index, old_index
            s.instance_variable_set :@new_index, new_index
          end
        end
      end
    end
  end
end
