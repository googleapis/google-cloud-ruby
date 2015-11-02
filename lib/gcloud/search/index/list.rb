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
    class Index
      ##
      # Index::List is a special case Array with additional values.
      class List < DelegateClass(::Array)
        ##
        # If not empty, indicates that there are more records that match
        # the request and this value should be passed to continue.
        attr_accessor :token

        ##
        # Create a new Index::List with an array of Index instances.
        def initialize arr = []
          super arr
        end

        ##
        # Whether there a next page of indexes.
        def next?
          !token.nil?
        end

        ##
        # Retrieve the next page of indexes.
        def next
          return nil unless next?
          ensure_connection!
          resp = @connection.list_indexes token: token
          if resp.success?
            Index::List.from_response resp, @connection
          else
            fail ApiError.from_response(resp)
          end
        end

        ##
        # New Indexs::List from a response object.
        def self.from_response resp, conn #:nodoc:
          data = JSON.parse resp.body
          indexes = new(Array(data["indexes"]).map do |raw_index|
            Index.from_raw raw_index, conn
          end)
          indexes.instance_eval do
            @token = data["nextPageToken"]
            @connection = conn
          end
          indexes
        rescue JSON::ParserError
          ApiError.from_response_status resp
        end

        protected

        ##
        # Raise an error unless an active connection is available.
        def ensure_connection!
          fail "Must have active connection" unless @connection
        end
      end
    end
  end
end
