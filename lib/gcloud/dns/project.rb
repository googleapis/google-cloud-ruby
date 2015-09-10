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
    # = Project
    #
    # The project is a top level container for resources including Cloud DNS
    # ManagedZones. Projects can be created only in the APIs console.
    #
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   dns = gcloud.dns
    #   zone = dns.zone "example.com."
    #   zone.records.each do |record|
    #     puts record.name
    #   end
    #
    # See Gcloud#dns
    class Project
      ##
      # The Connection object.
      attr_accessor :connection #:nodoc:

      ##
      # Creates a new Connection instance.
      #
      # See Gcloud.dns
      def initialize project, credentials
        project = project.to_s # Always cast to a string
        fail ArgumentError, "project is missing" if project.empty?
        @connection = Connection.new project, credentials
      end

      ##
      # The DNS project connected to.
      #
      # === Example
      #
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

      ##
      # Default project.
      def self.default_project #:nodoc:
        ENV["DNS_PROJECT"] ||
          ENV["GCLOUD_PROJECT"] ||
          ENV["GOOGLE_CLOUD_PROJECT"] ||
          Gcloud::GCE.project_id
      end

      ##
      # Retrieves an existing zone by name or id.
      #
      # === Parameters
      #
      # +zone_id+::
      #   The name or id of a zone. (+String+ or +Integer+)
      #
      # === Returns
      #
      # Gcloud::Bigquery::Zone or +nil+ if the zone does not exist
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dns = gcloud.dns
      #   zone = dns.zone "example.com."
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

      ##
      # Retrieves the list of zones belonging to the project.
      #
      # === Parameters
      #
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:token]</code>::
      #   A previously-returned page token representing part of the larger set
      #   of results to view. (+String+)
      # <code>options[:max]</code>::
      #   Maximum number of zones to return. (+Integer+)
      #
      # === Returns
      #
      # Array of Gcloud::Bigquery::Zone (Gcloud::Bigquery::Zone::List)
      #
      # === Examples
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dns = gcloud.dns
      #   zones = dns.zones
      #   zones.each do |zone|
      #     puts zone.name
      #   end
      #
      # If you have a significant number of zones, you may need to paginate
      # through them: (See Gcloud::Bigquery::Zone::List)
      #
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
      def zones options = {}
        ensure_connection!
        resp = connection.list_zones options
        if resp.success?
          Zone::List.from_response resp, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Creates a new zone.
      #
      # === Parameters
      #
      # +zone_name+::
      #   User assigned name for this resource. Must be unique within the
      #   project. The name must be 1-32 characters long, must begin with a
      #   letter, end with a letter or digit, and only contain lowercase
      #   letters, digits or dashes. (+String+)
      # +zone_dns+::
      #   The DNS name of this managed zone, for instance "example.com.".
      #   (+String+)
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:description]</code>::
      #   A string of at most 1024 characters associated with this resource for
      #   the user's convenience. Has no effect on the managed zone's function.
      #   (+String+)
      # <code>options[:name_server_set]</code>::
      #   A NameServerSet is a set of DNS name servers that all host the same
      #   ManagedZones. Most users will leave this field unset. (+String+)
      #
      # === Returns
      #
      # Gcloud::Dns::Zone
      #
      # === Examples
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dns = gcloud.dns
      #   zone = dns.create_zones "Example Zone", "example.com."
      #
      # You can also pass +description+ and +name_server_set+ options.
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dns = gcloud.dns
      #   zone = dns.create_zones "example-zone", "example.com.",
      #                           description: "A description of my zone.",
      #                           name_server_set: "example"
      #
      def create_zone zone_name, zone_dns, options = {}
        ensure_connection!
        resp = connection.create_zone zone_name, zone_dns, options
        if resp.success?
          Zone.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
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
