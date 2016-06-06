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


require "delegate"

module Gcloud
  module Storage
    class Bucket
      ##
      # Bucket::List is a special case Array with additional values.
      class List < DelegateClass(::Array)
        ##
        # If not empty, indicates that there are more buckets
        # that match the request and this value should be passed to
        # the next {Gcloud::Storage::Project#buckets} to continue.
        attr_accessor :token

        ##
        # @private Create a new Bucket::List with an array of values.
        def initialize arr = []
          super arr
        end

        ##
        # Whether there a next page of buckets.
        def next?
          !token.nil?
        end

        ##
        # Retrieve the next page of buckets.
        def next
          return nil unless next?
          ensure_connection!
          options = { prefix: @prefix, token: @token, max: @max }
          resp = @connection.list_buckets options
          fail ApiError.from_response(resp) unless resp.success?
          Bucket::List.from_response resp, @connection, @prefix, @max
        end

        ##
        # @private New Bucket::List from a response object.
        def self.from_response resp, conn, prefix = nil, max = nil
          buckets = new(Array(resp.data["items"]).map do |gapi_object|
            Bucket.from_gapi gapi_object, conn
          end)
          buckets.instance_variable_set "@token", resp.data["nextPageToken"]
          buckets.instance_variable_set "@connection", conn
          buckets.instance_variable_set "@prefix", prefix
          buckets.instance_variable_set "@max", max
          buckets
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
