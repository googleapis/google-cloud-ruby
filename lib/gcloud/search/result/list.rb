#--
# Copyright 2015 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module Gcloud
  module Search
    class Result
      ##
      # Result::List is a special case Array with additional values.
      class List < DelegateClass(::Array)
        ##
        # If not empty, indicates that there are more records that match
        # the request and this value should be passed to continue.
        attr_reader :token

        ##
        # The number of documents that match the query. It is greater than or
        # equal to the number of documents actually returned. This is an
        # approximation and not an exact count unless it is less than or equal
        # to the {Index#search} +matched_count_accuracy+ option.
        attr_reader :matched_count

        ##
        # Create a new Result::List with an array of {Result} instances.
        def initialize arr = []
          super arr
        end

        ##
        # Whether there a next page of results.
        def next?
          !token.nil?
        end

        ##
        # Retrieve the next page of results.
        def next
          return nil unless next?
          ensure_index!
          @index.search @query, @search_options.merge(token: token)
        end

        ##
        # Retrieves all results by repeatedly loading pages until {#next?}
        # returns false. Returns the list instance for method chaining.
        def all
          while next?
            next_results = self.next
            push(*next_results)
            self.token = next_results.token
          end
          self
        end

        ##
        # @private New Result::List from a response object.
        def self.from_response resp, index, query, search_options
          data = JSON.parse resp.body
          results = new(Array(data["results"]).map do |raw|
            Result.from_hash raw
          end)
          results.instance_eval do
            @token = data["results"].last["nextPageToken"]
            @matched_count = data["matchedCount"]
            @index = index
            @query = query
            @search_options = search_options
          end
          results
        rescue JSON::ParserError
          ApiError.from_response_status resp
        end

        protected

        ##
        # Raise an error unless an active connection is available.
        def ensure_index!
          fail "Must have active connection" unless @index
        end
      end
    end
  end
end
