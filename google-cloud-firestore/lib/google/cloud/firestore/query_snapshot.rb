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
require "google/cloud/firestore/document_reference"
require "google/cloud/firestore/collection_reference"
require "google/cloud/firestore/convert"

module Google
  module Cloud
    module Firestore
      ##
      # # QuerySnapshot
      #
      # A query snapshot object is an immutable representation of query results,
      # including chnages from the previous snapshot.
      #
      # See {Query#listen}.
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
      class QuerySnapshot
        ##
        # The query producing this snapshot.
        #
        # @return [Query] query.
        #
        def query
          @query
        end

        ##
        # The documents in the snapshot.
        #
        # @return [Array<DocumentSnapshot>] document snapshots.
        #
        def docs
          @docs
        end
        alias documents docs

        ##
        # The document change objects for the query snapshot.
        #
        # @return [Array<DocumentChange>] document changes.
        #
        def changes
          @changes
        end
        alias doc_changes changes
        alias document_changes changes

        ##
        # Returns the number of documents in this query snapshot.
        #
        # @return [Integer] The number of documents.
        #
        def size
          docs.size
        end
        alias count size

        ##
        # Determines whether query results exists.
        #
        # @return [Boolean] Whether query results exists.
        #
        def empty?
          docs.empty?
        end

        ##
        # The time at which the snapshot was read.
        #
        # @return [Time] The time at which the documents were read.
        #
        def read_at
          @read_at
        end
        alias read_time read_at

        ##
        # @private New QuerySnapshot
        def self.from_docs query, docs, changes, read_at
          new.tap do |s|
            s.instance_variable_set :@query,   query
            s.instance_variable_set :@docs,    docs
            s.instance_variable_set :@changes, changes
            s.instance_variable_set :@read_at, read_at
          end
        end
      end
    end
  end
end
