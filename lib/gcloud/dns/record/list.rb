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
  module Dns
    class Record
      ##
      # Record::List is a special case Array with additional values.
      class List < DelegateClass(::Array)
        ##
        # If not empty, indicates that there are more records that match
        # the request and this value should be passed to continue.
        attr_accessor :token

        ##
        # Create a new Record::List with an array of Record instances.
        def initialize arr = []
          super arr
        end

        ##
        # Whether there a next page of records.
        def next?
          !token.nil?
        end

        ##
        # Retrieve the next page of records.
        def next
          return nil unless next?
          ensure_zone!
          @zone.records token: token
        end

        ##
        # Retrieves all records by repeatedly loading pages until #next? returns
        # false. Returns the list instance for method chaining.
        #
        # === Example
        #
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   dns = gcloud.dns
        #   zone = dns.zone "example-com"
        #   records = zone.records.all # Load all pages of records
        #
        def all
          while next?
            next_records = self.next
            push(*next_records)
            self.token = next_records.token
          end
          self
        end

        ##
        # New Records::List from a response object.
        def self.from_response resp, zone #:nodoc:
          records = new(Array(resp.data["rrsets"]).map do |gapi_object|
            Record.from_gapi gapi_object
          end)
          records.instance_eval do
            @token = resp.data["nextPageToken"]
            @zone = zone
          end
          records
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
