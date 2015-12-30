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
    class Change
      ##
      # Change::List is a special case Array with additional values.
      class List < DelegateClass(::Array)
        ##
        # If not empty, indicates that there are more records that match
        # the request and this value should be passed to continue.
        attr_accessor :token

        ##
        # Create a new Change::List with an array of Change instances.
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
          ensure_zone!
          @zone.changes token: token
        end

        ##
        # @private New Changes::List from a response object.
        def self.from_response resp, zone
          changes = new(Array(resp.data["changes"]).map do |gapi_object|
            Change.from_gapi gapi_object, zone
          end)
          changes.instance_eval do
            @token = resp.data["nextPageToken"]
            @zone = zone
          end
          changes
        end

        protected

        ##
        # Raise an error unless an active connection is available.
        def ensure_zone!
          fail "Must have active connection" unless @zone
        end
      end
    end
  end
end
