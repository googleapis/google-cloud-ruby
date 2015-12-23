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

require "gcloud/gce"
require "gcloud/dns/connection"
require "gcloud/dns/credentials"
require "gcloud/dns/zone"
require "gcloud/dns/errors"

module Gcloud
  module Dns
    ##
    # # Project
    #
    # The project is a top level container for resources including Cloud DNS
    # ManagedZones. Projects can be created only in the {Google Developers
    # Console}[https://console.developers.google.com].
    #
    # @example
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   dns = gcloud.dns
    #   zone = dns.zone "example-com"
    #   zone.records.each do |record|
    #     puts record.name
    #   end
    #
    # See {Gcloud#dns}
    class Project
      ##
      # @private The Connection object.
      attr_accessor :connection

      ##
      # @private The Google API Client object.
      attr_accessor :gapi

      ##
      # @private Creates a new Connection instance.
      #
      # See {Gcloud.dns}
      def initialize project, credentials
        project = project.to_s # Always cast to a string
        fail ArgumentError, "project is missing" if project.empty?
        @connection = Connection.new project, credentials
        @gapi = nil
      end

      ##
      # The unique ID string for the current project.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new "my-todo-project", "/path/to/keyfile.json"
      #   dns = gcloud.dns
      #
      #   dns.project #=> "my-todo-project"
      #
      def project
        connection.project
      end
      alias_method :id, :project

      ##
      # The project number.
      def number
        reload! if @gapi.nil?
        @gapi["number"]
      end

      ##
      # Maximum allowed number of zones in the project.
      def zones_quota
        reload! if @gapi.nil?
        @gapi["quota"]["managedZones"] if @gapi["quota"]
      end

      ##
      # Maximum allowed number of data entries per record.
      def data_per_record
        reload! if @gapi.nil?
        @gapi["quota"]["resourceRecordsPerRrset"] if @gapi["quota"]
      end

      ##
      # Maximum allowed number of records to add per change.
      def additions_per_change
        reload! if @gapi.nil?
        @gapi["quota"]["rrsetAdditionsPerChange"] if @gapi["quota"]
      end

      ##
      # Maximum allowed number of records to delete per change.
      def deletions_per_change
        reload! if @gapi.nil?
        @gapi["quota"]["rrsetDeletionsPerChange"] if @gapi["quota"]
      end

      ##
      # Maximum allowed number of records per zone in the project.
      def records_per_zone
        reload! if @gapi.nil?
        @gapi["quota"]["rrsetsPerManagedZone"] if @gapi["quota"]
      end

      ##
      # Maximum allowed total bytes size for all the data in one change.
      def total_data_per_change
        reload! if @gapi.nil?
        @gapi["quota"]["totalRrdataSizePerChange"] if @gapi["quota"]
      end

      ##
      # @private Default project.
      def self.default_project
        ENV["DNS_PROJECT"] ||
          ENV["GCLOUD_PROJECT"] ||
          ENV["GOOGLE_CLOUD_PROJECT"] ||
          Gcloud::GCE.project_id
      end

      ##
      # Retrieves an existing zone by name or id.
      #
      # @param [String, Integer] zone_id The name or id of a zone.
      #
      # @return [Gcloud::Dns::Zone, nil] Returns +nil+ if the zone does not
      #   exist.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dns = gcloud.dns
      #   zone = dns.zone "example-com"
      #   puts zone.name
      #
      def zone zone_id
        ensure_connection!
        resp = connection.get_zone zone_id
        if resp.success?
          Zone.from_gapi resp.data, connection
        else
          nil
        end
      end
      alias_method :find_zone, :zone
      alias_method :get_zone, :zone

      ##
      # Retrieves the list of zones belonging to the project.
      #
      # @param [String] token A previously-returned page token representing part
      #   of the larger set of results to view.
      # @param [Integer] max Maximum number of zones to return.
      #
      # @return [Array<Gcloud::Dns::Zone>] (See {Gcloud::Dns::Zone::List})
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dns = gcloud.dns
      #   zones = dns.zones
      #   zones.each do |zone|
      #     puts zone.name
      #   end
      #
      # @example With pagination: (See {Gcloud::Dns::Zone::List})
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dns = gcloud.dns
      #   zones = dns.zones
      #   loop do
      #     zones.each do |zone|
      #       puts zone.name
      #     end
      #     break unless zones.next?
      #     zones = zones.next
      #   end
      #
      def zones token: nil, max: nil
        ensure_connection!
        resp = connection.list_zones token: token, max: max
        if resp.success?
          Zone::List.from_response resp, connection
        else
          fail ApiError.from_response(resp)
        end
      end
      alias_method :find_zones, :zones

      ##
      # Creates a new zone.
      #
      # @param [String] zone_name User assigned name for this resource. Must be
      #   unique within the project. The name must be 1-32 characters long, must
      #   begin with a letter, end with a letter or digit, and only contain
      #   lowercase letters, digits or dashes.
      # @param [String] zone_dns The DNS name of this managed zone, for instance
      #   "example.com.".
      # @param [String] description A string of at most 1024 characters
      #   associated with this resource for the user's convenience. Has no
      #   effect on the managed zone's function.
      # @param [String] name_server_set A NameServerSet is a set of DNS name
      #   servers that all host the same ManagedZones. Most users will leave
      #   this field unset.
      #
      # @return [Gcloud::Dns::Zone]
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dns = gcloud.dns
      #   zone = dns.create_zone "example-com", "example.com."
      #
      def create_zone zone_name, zone_dns, description: nil,
                      name_server_set: nil
        ensure_connection!
        resp = connection.create_zone zone_name, zone_dns,
                                      description: description,
                                      name_server_set: name_server_set
        if resp.success?
          Zone.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Reloads the change with updated status from the DNS service.
      def reload!
        ensure_connection!
        resp = connection.get_project
        if resp.success?
          @gapi = resp.data
        else
          fail ApiError.from_response(resp)
        end
      end
      alias_method :refresh!, :reload!

      protected

      ##
      # Raise an error unless an active connection is available.
      def ensure_connection!
        fail "Must have active connection" unless connection
      end
    end
  end
end
