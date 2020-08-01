# Copyright 2020 Google LLC
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
      ##
      # @private
      #
      # An Array delegate for pagination. Private class exposing only an Enumerator to clients.
      #
      class CollectionReferenceList < DelegateClass(::Array)
        ##
        # If not empty, indicates that there are more records that match the request and this value should be passed
        # to continue.
        attr_accessor :token

        ##
        # @private Create a new CollectionReference::List with an array of CollectionReference instances.
        def initialize arr = []
          super arr
        end

        ##
        # Whether there is a next page of collection references.
        #
        # @return [Boolean]
        #
        def next?
          !token.nil?
        end

        ##
        # Retrieve the next page of collection references.
        #
        # @return [CollectionReference::List] The list of collection references.
        #
        def next
          return nil unless next?
          ensure_service!
          grpc = @client.service.list_collections @parent, token: token, max: @max
          self.class.from_grpc grpc, @client, @parent, max: @max
        end

        ##
        # Retrieves remaining results by repeatedly invoking {#next} until {#next?} returns `false`. Calls the given
        # block once for each result, which is passed as the argument to the block.
        #
        # An Enumerator is returned if no block is given.
        #
        # This method will make repeated API calls until all remaining results are retrieved. (Unlike `#each`, for
        # example, which merely iterates over the results returned by a single API call.) Use with caution.
        #
        # @param [Integer] request_limit The upper limit of API requests to make to load all collection references.
        #   Default is no limit.
        # @yield [collection_reference] The block for accessing each collection_reference.
        # @yieldparam [CollectionReference] collection_reference The collection reference object.
        #
        # @return [Enumerator]
        #
        # @example Iterating each collection reference by passing a block:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   firestore.cols do |collection_reference|
        #     puts collection_reference.collection_id
        #   end
        #
        # @example Using the enumerator by not passing a block:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   all_collection_ids = firestore.cols.map do |collection_reference|
        #     collection_reference.collection_id
        #   end
        #
        def all request_limit: nil
          request_limit = request_limit.to_i if request_limit
          unless block_given?
            return enum_for :all, request_limit: request_limit
          end
          results = self
          loop do
            results.each { |r| yield r }
            if request_limit
              request_limit -= 1
              break if request_limit < 0
            end
            break unless results.next?
            results = results.next
          end
        end

        ##
        # @private New CollectionReference::List from a `Google::Cloud::Firestore::V1::ListCollectionIdsResponse`
        # object.
        def self.from_grpc grpc, client, parent, max: nil
          raise ArgumentError, "parent is required" unless parent
          cols = CollectionReferenceList.new(Array(grpc.collection_ids).map do |collection_id|
            CollectionReference.from_path "#{parent}/#{collection_id}", client
          end)
          token = grpc.next_page_token
          token = nil if token == "".freeze
          cols.instance_variable_set :@token, token
          cols.instance_variable_set :@client, client
          cols.instance_variable_set :@parent, parent
          cols.instance_variable_set :@max, max
          cols
        end

        protected

        ##
        # Raise an error unless an active service is available.
        def ensure_service!
          raise "Must have active connection" unless @client.service
        end
      end
    end
  end
end
