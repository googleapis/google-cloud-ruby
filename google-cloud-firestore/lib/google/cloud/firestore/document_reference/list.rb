# Copyright 2019 Google LLC
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


require "delegate"

module Google
  module Cloud
    module Firestore
      class DocumentReference
        ##
        # DocumentReference::List is a special case Array with additional
        # values.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   col = firestore.col "cities"
        #
        #   doc_refs = col.list_documents
        #
        #   doc_refs.each do |doc_ref|
        #     puts doc_ref.document_id
        #   end
        #
        class List < DelegateClass(::Array)
          ##
          # If not empty, indicates that there are more records that match
          # the request and this value should be passed to continue.
          attr_accessor :token

          ##
          # @private Create a new DocumentReference::List with an array of
          # DocumentReference instances.
          def initialize arr = []
            super arr
          end

          ##
          # Whether there is a next page of document references.
          #
          # @return [Boolean]
          #
          # @example
          #   require "google/cloud/firestore"
          #
          #   firestore = Google::Cloud::Firestore.new
          #   col = firestore.col "cities"
          #
          #   doc_refs = col.list_documents
          #   if doc_refs.next?
          #     next_documents = doc_refs.next
          #   end
          def next?
            !token.nil?
          end

          ##
          # Retrieve the next page of document references.
          #
          # @return [DocumentReference::List]
          #
          # @example
          #   require "google/cloud/firestore"
          #
          #   firestore = Google::Cloud::Firestore.new
          #   col = firestore.col "cities"
          #
          #   doc_refs = col.list_documents
          #   if doc_refs.next?
          #     next_documents = doc_refs.next
          #   end
          def next
            return nil unless next?
            ensure_client!
            grpc = @client.service.list_documents @parent, @collection_id, token: token, max: @max, \
              read_time: @read_time
            self.class.from_grpc grpc, @client, @parent, @collection_id, @max, read_time: @read_time
          end

          ##
          # Retrieves remaining results by repeatedly invoking {#next} until
          # {#next?} returns `false`. Calls the given block once for each
          # result, which is passed as the argument to the block.
          #
          # An Enumerator is returned if no block is given.
          #
          # This method will make repeated API calls until all remaining results
          # are retrieved. (Unlike `#each`, for example, which merely iterates
          # over the results returned by a single API call.) Use with caution.
          #
          # @param [Integer] request_limit The upper limit of API requests to
          #   make to load all document references. Default is no limit.
          # @yield [document] The block for accessing each document.
          # @yieldparam [DocumentReference] document The document reference
          #   object.
          #
          # @return [Enumerator]
          #
          # @example Iterating each document reference by passing a block or proc:
          #   require "google/cloud/firestore"
          #
          #   firestore = Google::Cloud::Firestore.new
          #   col = firestore.col "cities"
          #
          #   doc_refs = col.list_documents
          #   doc_refs.all do |doc_ref|
          #     puts doc_ref.document_id
          #   end
          #
          # @example Using the enumerator by not passing a block:
          #   require "google/cloud/firestore"
          #
          #   firestore = Google::Cloud::Firestore.new
          #   col = firestore.col "cities"
          #
          #   doc_refs = col.list_documents
          #   all_document_ids = doc_refs.all.map do |doc_ref|
          #     doc_ref.document_id
          #   end
          #
          # @example Limit the number of API calls made:
          #   require "google/cloud/firestore"
          #
          #   firestore = Google::Cloud::Firestore.new
          #   col = firestore.col "cities"
          #
          #   doc_refs = col.list_documents
          #   doc_refs.all(request_limit: 10) do |doc_ref|
          #     puts doc_ref.document_id
          #   end
          #
          def all request_limit: nil, &block
            request_limit = request_limit.to_i if request_limit
            unless block_given?
              return enum_for :all, request_limit: request_limit
            end
            results = self
            loop do
              results.each(&block)
              if request_limit
                request_limit -= 1
                break if request_limit.negative?
              end
              break unless results.next?
              results = results.next
            end
          end

          ##
          # @private New DocumentReference::List from a
          # Google::Cloud::Firestore::V1::ListDocumentsResponse object.
          def self.from_grpc grpc, client, parent, collection_id, max = nil, read_time: nil
            documents = List.new(Array(grpc.documents).map do |document|
              DocumentReference.from_path document.name, client
            end)
            documents.instance_variable_set :@parent, parent
            documents.instance_variable_set :@collection_id, collection_id
            token = grpc.next_page_token
            token = nil if token == ""
            documents.instance_variable_set :@token, token
            documents.instance_variable_set :@client, client
            documents.instance_variable_set :@max, max
            documents.instance_variable_set :@read_time, read_time
            documents
          end


          protected

          ##
          # Raise an error unless an active client is available.
          def ensure_client!
            raise "Must have active connection" unless @client
          end
        end
      end
    end
  end
end
