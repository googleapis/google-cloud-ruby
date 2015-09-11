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

require "gcloud/dns/change/list"
require "time"

module Gcloud
  module Dns
    ##
    # = DNS Change
    #
    # Represents a request containing additions or deletions or records.
    # Additions and deletions can be done in bulk, in a single atomic
    # transaction, and take effect at the same time in each authoritative DNS
    # server.
    #
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   dns = gcloud.dns
    #   zone = dns.zone "example-zone"
    #   zone.changes.each do |change|
    #     puts "Change includes #{change.additions.count} additions " \
    #          "and #{change.additions.count} deletions."
    #   end
    #
    class Change
      ##
      # The Zone object this Change belongs to.
      attr_accessor :zone #:nodoc:

      ##
      # The Google API Client object.
      attr_accessor :gapi #:nodoc:

      ##
      # Create an empty Change object.
      def initialize #:nodoc:
        @zone = nil
        @gapi = {}
      end

      ##
      # Unique identifier for the resource; defined by the server.
      #
      def id
        @gapi["id"]
      end

      ##
      # The records added in this change request.
      #
      def additions
        Array @gapi["additions"]
      end

      ##
      # The records removed in this change request.
      #
      def deletions
        Array @gapi["deletions"]
      end

      ##
      # Status of the operation. Values are +"done"+ and +"pending"+.
      #
      def status
        @gapi["status"]
      end

      ##
      # Checks if the status is +"done"+.
      def done?
        return false if status.nil?
        "done".casecmp(status).zero?
      end

      ##
      # Checks if the status is +"pending"+.
      def pending?
        return false if status.nil?
        "pending".casecmp(status).zero?
      end

      ##
      # The time that this operation was started by the server.
      #
      def started_at
        Time.parse @gapi["startTime"]
      rescue
        nil
      end

      ##
      # Reloads the change with updated status from the DNS service.
      def reload!
        ensure_connection!
        resp = zone.connection.get_change @zone.id, id
        if resp.success?
          @gapi = resp.data
        else
          fail ApiError.from_response(resp)
        end
      end
      alias_method :refresh!, :reload!

      ##
      # New Change from a Google API Client object.
      def self.from_gapi gapi, zone #:nodoc:
        new.tap do |f|
          f.gapi = gapi
          f.zone = zone
        end
      end

      protected

      ##
      # Raise an error unless an active connection is available.
      def ensure_connection!
        fail "Must have active connection" unless zone && zone.connection
      end
    end
  end
end
