# Copyright 2015 Google LLC
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


require "google/cloud/dns/change/list"
require "time"

module Google
  module Cloud
    module Dns
      ##
      # # DNS Change
      #
      # Represents a request containing additions or deletions or records.
      # Additions and deletions can be done in bulk, in a single atomic
      # transaction, and take effect at the same time in each authoritative DNS
      # server.
      #
      # @example
      #   require "google/cloud/dns"
      #
      #   dns = Google::Cloud::Dns.new
      #   zone = dns.zone "example-com"
      #   zone.changes.each do |change|
      #     puts "Change includes #{change.additions.count} additions " \
      #          "and #{change.additions.count} deletions."
      #   end
      #
      class Change
        ##
        # @private The Zone object this Change belongs to.
        attr_accessor :zone

        ##
        # @private The Google API Client object.
        attr_accessor :gapi

        ##
        # @private Create an empty Change object.
        def initialize
          @zone = nil
          @gapi = {}
        end

        ##
        # Unique identifier for the resource; defined by the server.
        #
        def id
          @gapi.id
        end

        ##
        # The records added in this change request.
        #
        def additions
          Array(@gapi.additions).map { |gapi| Record.from_gapi gapi }
        end

        ##
        # The records removed in this change request.
        #
        def deletions
          Array(@gapi.deletions).map { |gapi| Record.from_gapi gapi }
        end

        ##
        # Status of the operation. Values are `"done"` and `"pending"`.
        #
        def status
          @gapi.status
        end

        ##
        # Checks if the status is `"done"`.
        def done?
          return false if status.nil?
          "done".casecmp(status).zero?
        end

        ##
        # Checks if the status is `"pending"`.
        def pending?
          return false if status.nil?
          "pending".casecmp(status).zero?
        end

        ##
        # The time that this operation was started by the server.
        #
        def started_at
          Time.parse @gapi.start_time
        rescue StandardError
          nil
        end

        ##
        # Reloads the change with updated status from the DNS service.
        def reload!
          ensure_service!
          @gapi = zone.service.get_change @zone.id, id
        end
        alias refresh! reload!

        ##
        # Refreshes the change until the status is `done`.
        # The delay between refreshes will incrementally increase.
        #
        # @example
        #   require "google/cloud/dns"
        #
        #   dns = Google::Cloud::Dns.new
        #   zone = dns.zone "example-com"
        #   change = zone.change 1234567890
        #   change.done? #=> false
        #   change.wait_until_done!
        #   change.done? #=> true
        #
        def wait_until_done!
          backoff = ->(retries) { sleep 2 * retries + 5 }
          retries = 0
          until done?
            backoff.call retries
            retries += 1
            reload!
          end
        end

        ##
        # @private New Change from a Google API Client object.
        def self.from_gapi gapi, zone
          new.tap do |f|
            f.gapi = gapi
            f.zone = zone
          end
        end

        protected

        ##
        # Raise an error unless an active service is available.
        def ensure_service!
          raise "Must have active connection" unless zone && zone.service
        end
      end
    end
  end
end
