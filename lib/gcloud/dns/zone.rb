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
require "gcloud/dns/zone/transaction"
require "gcloud/dns/zone/list"
require "gcloud/dns/record"
require "gcloud/dns/importer"
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
      # Gcloud::Dns::Change or +nil+ if the change does not exist
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
          Change.from_gapi resp.data, self
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
      # <code>options[:order]</code>::
      #   Sort the changes by change sequence. (+Symbol+ or +String+)
      #
      #   Acceptable values are:
      #   * +asc+ - Sort by ascending change sequence
      #   * +desc+ - Sort by descending change sequence
      #
      # === Returns
      #
      # Array of Gcloud::Dns::Change (Gcloud::Dns::Change::List)
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
      # The changes can be sorted by change sequence:
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dns = gcloud.dns
      #   zone = dns.zone "example-zone"
      #   changes = zone.changes order: :desc
      #
      # If you have a significant number of changes, you may need to paginate
      # through them: (See Gcloud::Dns::Change::List)
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
        # Fix the sort options
        options[:order] = adjust_change_sort_order options[:order]
        options[:sort]  = "changeSequence" if options[:order]
        # Continue with the API call
        resp = connection.list_changes id, options
        if resp.success?
          Change::List.from_response resp, self
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Retrieves the list of records belonging to the zone.
      #
      # === Parameters
      #
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:token]</code>::
      #   A previously-returned page token representing part of the larger set
      #   of results to view. (+String+)
      # <code>options[:max]</code>::
      #   Maximum number of records to return. (+Integer+)
      # <code>options[:name]</code>::
      #   Return only records with this fully-qualified domain name. (+String+)
      # <code>options[:type]</code>::
      #   Return only records with this {record
      #   type}[https://cloud.google.com/dns/what-is-cloud-dns].
      #   If present, the +name+ parameter must also be present. (+String+)
      #
      # === Returns
      #
      # Array of Gcloud::Dns::Record (Gcloud::Dns::Record::List)
      #
      # === Examples
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dns = gcloud.dns
      #   zone = dns.zone "example-zone"
      #   records = zone.records
      #   records.each do |record|
      #     puts record.name
      #   end
      #
      # Records can be filtered by name and type.
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dns = gcloud.dns
      #   zone = dns.zone "example-zone"
      #   records = zone.records name: "example.com.", type: "A"
      #
      # If you have a significant number of records, you may need to paginate
      # through them: (See Gcloud::Dns::Record::List)
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dns = gcloud.dns
      #   zone = dns.zone "example-zone"
      #   records = zone.records
      #   loop do
      #     records.each do |record|
      #       puts record.name
      #     end
      #     break unless records.next?
      #     records = records.next
      #   end
      #
      def records options = {}
        ensure_connection!
        resp = connection.list_records id, options
        if resp.success?
          Record::List.from_response resp, self
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Creates a new, unsaved Record that can be added to a Zone.
      #
      # === Returns
      #
      # Gcloud::Dns::Record
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dns = gcloud.dns
      #   zone = dns.zone "example-zone"
      #   record = zone.record "example.com.", "A", 86400, ["1.2.3.4"]
      #   zone.add record
      #
      def record name, type, ttl, data
        Gcloud::Dns::Record.new name, type, ttl, data
      end

      ##
      # Exports the zone to a local {DNS zone
      # file}[https://en.wikipedia.org/wiki/Zone_file].
      #
      # === Parameters
      #
      # +path+::
      #   The path on the local file system to write the data to.
      #   The path provided must be writable. (+String+)
      #
      # === Returns
      #
      # +::File+ object on the local file system
      #
      # === Examples
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dns = gcloud.dns
      #   zone = dns.zone "example-zone"
      #
      #   zone.export "path/to/db.example.com"
      #
      def export path
        File.open path, "w" do |f|
          f.write to_zonefile
        end
      end

      ##
      # Imports resource records from a {DNS zone
      # file}[https://en.wikipedia.org/wiki/Zone_file], adding the new records
      # to the zone, without removing any existing records from the zone.
      #
      # Because the Google Cloud DNS API only accepts a single resource record
      # for each +name+ and +type+ combination (with multiple +data+ elements),
      # the zone file's records are merged as necessary. During this merge, the
      # lowest +ttl+ of the merged records is used. If none of the merged
      # records have a +ttl+ value, the zone file's global TTL is used for the
      # record.
      #
      # The zone file's SOA and NS records are not imported by default, because
      # the zone was already given SOA and NS records when it was created. These
      # generated records point to Cloud DNS name servers and are probably the
      # ones that you want. You can override this behavior with the
      # +nameservers+ option, however.
      #
      # The Google Cloud DNS service requires that record names and data use
      # fully-qualified addresses. The @ symbol is not accepted, nor are
      # unqualified subdomain addresses like www. If your zone file contains
      # such values, you may need to pre-process it in order for the import
      # operation to succeed.
      #
      # === Parameters
      #
      # +path_or_io+::
      #   The path to a zone file on the filesystem, or an IO instance from
      #   which zone file data can be read. (+String+ or +IO+)
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:only]</code>::
      #   Include only records of this type or types. (+String+ or +Array+)
      # <code>options[:except]</code>::
      #   Exclude records of this type or types. (+String+ or +Array+)
      # <code>options[:nameservers]</code>::
      #   Add the SOA and NS records from the zone file to the zone. This may
      #   result in an ApiError if the zone already contains records of this
      #   type for its origin. (When a Zone is created, the Cloud DNS service
      #   automatically adds SOA and NS records to it.) The default value is
      #   +false+. (+Boolean+)
      #
      # === Returns
      #
      # A new Change adding the imported Record instances.
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dns = gcloud.dns
      #   zone = dns.zone "example-zone"
      #   change = zone.import "path/to/db.example.com"
      #
      def import path_or_io, options = {}
        unless options[:nameservers]
          options[:except] ||= []
          options[:except] = (Array(options[:except]) + %w(SOA NS)).uniq
        end
        update Gcloud::Dns::Importer.new(path_or_io).records(options), []
      end

      ##
      # Adds and removes Records from the Zone. All changes are made in a single
      # API request.
      #
      # === Returns
      #
      # Gcloud::Dns::Change
      #
      # === Examples
      #
      # The recommended way to make changes is call +update+ with a block. See
      # Zone::Transaction.
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dns = gcloud.dns
      #   zone = dns.zone "example-zone"
      #   zone.update do |tx|
      #     tx.add     "example.com.", "A",  86400, "1.2.3.4"
      #     tx.remove  "example.com.", "TXT"
      #     tx.replace "example.com.", "MX", 86400, ["10 mail1.example.com.",
      #                                              "20 mail2.example.com."]
      #   end
      #
      # Or you can provide the record objects to add and remove.
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dns = gcloud.dns
      #   zone = dns.zone "example-zone"
      #   new_record = zone.record "example.com.", "A", 86400, ["1.2.3.4"]
      #   old_record = zone.record "example.com.", "A", 18600, ["1.2.3.4"]
      #   zone.update [new_record], [old_record]
      #
      def update additions = [], deletions = []
        additions = Array additions
        deletions = Array deletions

        if block_given?
          updater = Zone::Transaction.new self
          yield updater
          additions += updater.additions
          deletions += updater.deletions
        end

        create_change additions, deletions
      end

      ##
      # Adds a record to the Zone. In order to update existing records, or add
      # and delete records in the same transaction, use #update.
      #
      # === Parameters
      #
      # +name+::
      #   The owner of the record. For example: +example.com.+. (+String+)
      # +type+::
      #   The identifier of a {supported record
      #   type}[https://cloud.google.com/dns/what-is-cloud-dns].
      #   For example: +A+, +AAAA+, +CNAME+, +MX+, or +TXT+. (+String+)
      # +ttl+::
      #   The number of seconds that the record can be cached by resolvers.
      #   (+Integer+)
      # +data+::
      #   The resource record data, as determined by +type+ and defined in RFC
      #   1035 (section 5) and RFC 1034 (section 3.6.1). For example:
      #   +192.0.2.1+ or +example.com.+. (+String+ or +Array+ of +String+)
      #
      # === Returns
      #
      # Gcloud::Dns::Change
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dns = gcloud.dns
      #   zone = dns.zone "example-zone"
      #   change = zone.add "example.com.", "A", 86400, ["1.2.3.4"]
      #
      def add name, type, ttl, data
        update [record(name, type, ttl, data)], []
      end

      ##
      # Removes records from the Zone. The records are looked up before they are
      # removed. In order to update existing records, or add and remove records
      # in the same transaction, use #update.
      #
      # === Parameters
      #
      # +name+::
      #   The owner of the record. For example: +example.com.+. (+String+)
      # +type+::
      #   The identifier of a {supported record
      #   type}[https://cloud.google.com/dns/what-is-cloud-dns].
      #   For example: +A+, +AAAA+, +CNAME+, +MX+, or +TXT+. (+String+)
      #
      # === Returns
      #
      # Gcloud::Dns::Change
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dns = gcloud.dns
      #   zone = dns.zone "example-zone"
      #   change = zone.remove "example.com.", "A"
      #
      def remove name, type
        update [], records(name: name, type: type).all.to_a
      end

      ##
      # Replaces existing records on the Zone. Records matching the +name+ and
      # +type+ are replaced. In order to update existing records, or add and
      # delete records in the same transaction, use #update.
      #
      # === Parameters
      #
      # +name+::
      #   The owner of the record. For example: +example.com.+. (+String+)
      # +type+::
      #   The identifier of a {supported record
      #   type}[https://cloud.google.com/dns/what-is-cloud-dns].
      #   For example: +A+, +AAAA+, +CNAME+, +MX+, or +TXT+. (+String+)
      # +ttl+::
      #   The number of seconds that the record can be cached by resolvers.
      #   (+Integer+)
      # +data+::
      #   The resource record data, as determined by +type+ and defined in RFC
      #   1035 (section 5) and RFC 1034 (section 3.6.1). For example:
      #   +192.0.2.1+ or +example.com.+. (+String+ or +Array+ of +String+)
      #
      # === Returns
      #
      # Gcloud::Dns::Change
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dns = gcloud.dns
      #   zone = dns.zone "example-zone"
      #   change = zone.replace "example.com.", "A", 86400, ["5.6.7.8"]
      #
      def replace name, type, ttl, data
        update [record(name, type, ttl, data)],
               records(name: name, type: type).all.to_a
      end

      def to_zonefile #:nodoc:
        records.all.map(&:to_zonefile_records).flatten.join("\n")
      end

      ##
      # Modifies records on the Zone. Records matching the +name+ and +type+ are
      # yielded to the block where they can be modified.
      #
      # === Parameters
      #
      # +name+::
      #   The owner of the record. For example: +example.com.+. (+String+)
      # +type+::
      #   The identifier of a {supported record
      #   type}[https://cloud.google.com/dns/what-is-cloud-dns].
      #   For example: +A+, +AAAA+, +CNAME+, +MX+, or +TXT+. (+String+)
      #
      # === Returns
      #
      # Gcloud::Dns::Change
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dns = gcloud.dns
      #   change = zone.modify "example.com.", "MX" do |mx|
      #     mx.ttl = 3600 # change only the TTL
      #   end
      #
      def modify name, type
        existing = records(name: name, type: type).all.to_a
        updated = existing.map &:dup
        updated.each { |r| yield r }
        update updated, existing
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

      def create_change additions, deletions
        ensure_connection!
        resp = connection.create_change id,
                                        additions.map(&:to_gapi),
                                        deletions.map(&:to_gapi)
        if resp.success?
          Change.from_gapi resp.data, self
        else
          fail ApiError.from_response(resp)
        end
      end

      def adjust_change_sort_order order
        return nil if order.nil?
        if order.to_s.downcase.start_with? "d"
          "descending"
        else
          "ascending"
        end
      end
    end
  end
end
