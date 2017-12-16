# Copyright 2015 Google LLC
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


require "google/cloud/errors"
require "google/cloud/env"
require "google/cloud/dns/service"
require "google/cloud/dns/credentials"
require "google/cloud/dns/zone"

module Google
  module Cloud
    module Dns
      ##
      # # Project
      #
      # The project is a top level container for resources including Cloud DNS
      # ManagedZones. Projects can be created only in the [Google Developers
      # Console](https://console.developers.google.com).
      #
      # @example
      #   require "google/cloud/dns"
      #
      #   dns = Google::Cloud::Dns.new
      #   zone = dns.zone "example-com"
      #   zone.records.each do |record|
      #     puts record.name
      #   end
      #
      # See {Google::Cloud#dns}
      class Project
        ##
        # @private The Service object.
        attr_accessor :service

        ##
        # @private The Google API Client object.
        attr_accessor :gapi

        ##
        # @private Creates a new Service instance.
        #
        # See {Google::Cloud.dns}
        def initialize service
          @service = service
          @gapi = nil
        end

        ##
        # The unique ID string for the current project.
        #
        # @example
        #   require "google/cloud/dns"
        #
        #   dns = Google::Cloud::Dns.new(
        #     project_id: "my-project",
        #     credentials: "/path/to/keyfile.json"
        #   )
        #
        #   dns.project_id #=> "my-project"
        #
        def project_id
          service.project
        end
        alias_method :project, :project_id
        alias_method :id, :project_id

        ##
        # The project number.
        def number
          reload! if @gapi.nil?
          @gapi.number
        end

        ##
        # Maximum allowed number of zones in the project.
        def zones_quota
          reload! if @gapi.nil?
          @gapi.quota.managed_zones if @gapi.quota
        end

        ##
        # Maximum allowed number of data entries per record.
        def data_per_record
          reload! if @gapi.nil?
          @gapi.quota.resource_records_per_rrset if @gapi.quota
        end

        ##
        # Maximum allowed number of records to add per change.
        def additions_per_change
          reload! if @gapi.nil?
          @gapi.quota.rrset_additions_per_change if @gapi.quota
        end

        ##
        # Maximum allowed number of records to delete per change.
        def deletions_per_change
          reload! if @gapi.nil?
          @gapi.quota.rrset_deletions_per_change if @gapi.quota
        end

        ##
        # Maximum allowed number of records per zone in the project.
        def records_per_zone
          reload! if @gapi.nil?
          @gapi.quota.rrsets_per_managed_zone if @gapi.quota
        end

        ##
        # Maximum allowed total bytes size for all the data in one change.
        def total_data_per_change
          reload! if @gapi.nil?
          @gapi.quota.total_rrdata_size_per_change if @gapi.quota
        end

        ##
        # @private Default project.
        def self.default_project_id
          ENV["DNS_PROJECT"] ||
            ENV["GOOGLE_CLOUD_PROJECT"] ||
            ENV["GCLOUD_PROJECT"] ||
            Google::Cloud.env.project_id
        end

        ##
        # Retrieves an existing zone by name or id.
        #
        # @param [String, Integer] zone_id The name or id of a zone.
        #
        # @return [Google::Cloud::Dns::Zone, nil] Returns `nil` if the zone does
        #   not exist.
        #
        # @example
        #   require "google/cloud/dns"
        #
        #   dns = Google::Cloud::Dns.new
        #   zone = dns.zone "example-com"
        #   puts zone.name
        #
        def zone zone_id
          ensure_service!
          gapi = service.get_zone zone_id
          Zone.from_gapi gapi, service
        rescue Google::Cloud::NotFoundError
          nil
        end
        alias_method :find_zone, :zone
        alias_method :get_zone, :zone

        ##
        # Retrieves the list of zones belonging to the project.
        #
        # @param [String] token A previously-returned page token representing
        #   part of the larger set of results to view.
        # @param [Integer] max Maximum number of zones to return.
        #
        # @return [Array<Google::Cloud::Dns::Zone>] (See
        # {Google::Cloud::Dns::Zone::List})
        #
        # @example
        #   require "google/cloud/dns"
        #
        #   dns = Google::Cloud::Dns.new
        #   zones = dns.zones
        #   zones.each do |zone|
        #     puts zone.name
        #   end
        #
        # @example Retrieve all zones: (See {Zone::List#all})
        #   require "google/cloud/dns"
        #
        #   dns = Google::Cloud::Dns.new
        #   zones = dns.zones
        #   zones.all do |zone|
        #     puts zone.name
        #   end
        #
        def zones token: nil, max: nil
          ensure_service!
          gapi = service.list_zones token: token, max: max
          Zone::List.from_gapi gapi, service, max
        end
        alias_method :find_zones, :zones

        ##
        # Creates a new zone.
        #
        # @param [String] zone_name User assigned name for this resource. Must
        #   be unique within the project. The name must be 1-32 characters long,
        #   must begin with a letter, end with a letter or digit, and only
        #   contain lowercase letters, digits or dashes.
        # @param [String] zone_dns The DNS name of this managed zone, for
        #   instance "example.com.".
        # @param [String] description A string of at most 1024 characters
        #   associated with this resource for the user's convenience. Has no
        #   effect on the managed zone's function.
        # @param [String] name_server_set A NameServerSet is a set of DNS name
        #   servers that all host the same ManagedZones. Most users will leave
        #   this field unset.
        #
        # @return [Google::Cloud::Dns::Zone]
        #
        # @example
        #   require "google/cloud/dns"
        #
        #   dns = Google::Cloud::Dns.new
        #   zone = dns.create_zone "example-com", "example.com."
        #
        def create_zone zone_name, zone_dns, description: nil,
                        name_server_set: nil
          ensure_service!
          gapi = service.create_zone zone_name, zone_dns,
                                     description: description,
                                     name_server_set: name_server_set
          Zone.from_gapi gapi, service
        end

        ##
        # Reloads the change with updated status from the DNS service.
        def reload!
          ensure_service!
          @gapi = service.get_project
        end
        alias_method :refresh!, :reload!

        protected

        ##
        # Raise an error unless an active connection is available.
        def ensure_service!
          fail "Must have active connection" unless service
        end
      end
    end
  end
end
