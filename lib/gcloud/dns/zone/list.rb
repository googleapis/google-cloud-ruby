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
  module Dns
    class Zone
      ##
      # Zone::List is a special case Array with additional values.
      class List < DelegateClass(::Array)
        ##
        # If not empty, indicates that there are more records that match
        # the request and this value should be passed to continue.
        attr_accessor :token

        ##
        # Create a new Zone::List with an array of Zone instances.
        def initialize arr = []
          super arr
        end

        ##
        # Whether there a next page of zones.
        def next?
          !token.nil?
        end

        ##
        # Retrieve the next page of zones.
        def next
          return nil unless next?
          ensure_connection!
          resp = @connection.list_zones token: token, max: @max
          if resp.success?
            Zone::List.from_response resp, @connection, @max
          else
            fail ApiError.from_response(resp)
          end
        end

        ##
        # @private New Zones::List from a response object.
        def self.from_response resp, conn, max = nil
          zones = new(Array(resp.data["managedZones"]).map do |gapi_object|
            Zone.from_gapi gapi_object, conn
          end)
          zones.instance_variable_set "@token",      resp.data["nextPageToken"]
          zones.instance_variable_set "@connection", conn
          zones.instance_variable_set "@max",        max
          zones
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
