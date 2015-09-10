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

require "gcloud/dns/change"
require "gcloud/dns/zone/list"
require "time"

module Gcloud
  module Dns
    ##
    # = DNS Zone
    #
    # The managed zone is the container for DNS records for the same DNS name
    # suffix and has a set of name servers that accept and responds to queries.
    # A project can have multiple managed zones, but they must each have a
    # unique name.
    #
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   dns = gcloud.dns
    #   zone = dns.zone "example-zone"
    #   zone.records.each do |record|
    #     puts record.name
    #   end
    #
    class Zone
      ##
      # The Connection object.
      attr_accessor :connection #:nodoc:

      ##
      # The Google API Client object.
      attr_accessor :gapi #:nodoc:

      ##
      # Create an empty Zone object.
      def initialize #:nodoc:
        @connection = nil
        @gapi = {}
      end

      ##
      # Unique identifier for the resource; defined by the server.
      #
      def id
        @gapi["id"]
      end

      ##
      # User assigned name for this resource. Must be unique within the project.
      # The name must be 1-32 characters long, must begin with a letter, end
      # with a letter or digit, and only contain lowercase letters, digits or
      # dashes.
      #
      def name
        @gapi["name"]
      end

      ##
      # The DNS name of this managed zone, for instance "example.com.".
      #
      def dns
        @gapi["dnsName"]
      end

      ##
      # A string of at most 1024 characters associated with this resource for
      # the user's convenience. Has no effect on the managed zone's function.
      #
      def description
        @gapi["description"]
      end

      ##
      # Delegate your managed_zone to these virtual name servers; defined by the
      # server.
      #
      def name_servers
        Array(@gapi["nameServers"])
      end

      ##
      # Optionally specifies the NameServerSet for this ManagedZone. A
      # NameServerSet is a set of DNS name servers that all host the same
      # ManagedZones. Most users will leave this field unset.
      #
      def name_server_set
        @gapi["nameServerSet"]
      end

      ##
      # The time that this resource was created on the server.
      #
      def created_at
        Time.parse @gapi["creationTime"]
      rescue
        nil
      end

      ##
      # Permanently deletes the zone.
      #
      # === Returns
      #
      # +true+ if the zone was deleted.
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dns = gcloud.dns
      #   zone = dns.zone "example-zone"
      #   zone.delete
      #
      def delete
        ensure_connection!
        resp = connection.delete_zone id
        if resp.success?
          true
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Retrieves an existing change by id.
      #
      # === Parameters
      #
      # +change_id+::
      #   The id of a change. (+String+)
      #
      # === Returns
      #
      # Gcloud::Bigquery::Change or +nil+ if the change does not exist
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dns = gcloud.dns
      #   zone = dns.zone "example.com."
      #   change = zone.change "dns-change-1234567890"
      #   if change
      #     puts "Change includes #{change.additions.count} additions " \
      #          "and #{change.additions.count} deletions."
      #   end
      #
      def change change_id
        ensure_connection!
        resp = connection.get_change id, change_id
        if resp.success?
          Change.from_gapi resp.data, connection
        else
          nil
        end
      end

      ##
      # Retrieves the list of changes belonging to the zone.
      #
      # === Parameters
      #
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:token]</code>::
      #   A previously-returned page token representing part of the larger set
      #   of results to view. (+String+)
      # <code>options[:max]</code>::
      #   Maximum number of changes to return. (+Integer+)
      #
      # === Returns
      #
      # Array of Gcloud::Bigquery::Change (Gcloud::Bigquery::Change::List)
      #
      # === Examples
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dns = gcloud.dns
      #   zone = dns.zone "example-zone"
      #   changes = zone.changes
      #   changes.each do |change|
      #     puts change.name
      #   end
      #
      # If you have a significant number of changes, you may need to paginate
      # through them: (See Gcloud::Bigquery::Change::List)
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dns = gcloud.dns
      #   zone = dns.zone "example-zone"
      #   changes = zone.changes
      #   loop do
      #     changes.each do |change|
      #       puts change.name
      #     end
      #     break unless changes.next?
      #     changes = changes.next
      #   end
      #
      def changes options = {}
        ensure_connection!
        resp = connection.list_changes id, options
        if resp.success?
          Change::List.from_response resp, self
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # New Zone from a Google API Client object.
      def self.from_gapi gapi, conn #:nodoc:
        new.tap do |f|
          f.gapi = gapi
          f.connection = conn
        end
      end

      protected

      ##
      # Raise an error unless an active connection is available.
      def ensure_connection!
        fail "Must have active connection" unless connection
      end
    end
  end
end
