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


require "google/cloud/dns/change"
require "google/cloud/dns/zone/transaction"
require "google/cloud/dns/zone/list"
require "google/cloud/dns/record"
require "google/cloud/dns/importer"
require "time"

module Google
  module Cloud
    module Dns
      ##
      # # DNS Zone
      #
      # The managed zone is the container for DNS records for the same DNS name
      # suffix and has a set of name servers that accept and responds to
      # queries. A project can have multiple managed zones, but they must each
      # have a unique name.
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
      # @see https://cloud.google.com/dns/zones/ Managing Zones
      #
      class Zone
        ##
        # @private The Service object.
        attr_accessor :service

        ##
        # @private The Google API Client object.
        attr_accessor :gapi

        ##
        # @private Create an empty Zone object.
        def initialize
          @service = nil
          @gapi = {}
        end

        ##
        # Unique identifier for the resource; defined by the server.
        #
        def id
          @gapi.id
        end

        ##
        # User assigned name for this resource. Must be unique within the
        # project. The name must be 1-32 characters long, must begin with a
        # letter, end with a letter or digit, and only contain lowercase
        # letters, digits or dashes.
        #
        def name
          @gapi.name
        end

        ##
        # The DNS name of this managed zone, for instance "example.com.".
        #
        def dns
          @gapi.dns_name
        end

        ##
        # A string of at most 1024 characters associated with this resource for
        # the user's convenience. Has no effect on the managed zone's function.
        #
        def description
          @gapi.description
        end

        ##
        # Delegate your managed_zone to these virtual name servers; defined by
        # the server.
        #
        def name_servers
          Array(@gapi.name_servers)
        end

        ##
        # Optionally specifies the NameServerSet for this ManagedZone. A
        # NameServerSet is a set of DNS name servers that all host the same
        # ManagedZones. Most users will leave this field unset.
        #
        def name_server_set
          @gapi.name_server_set
        end

        ##
        # The time that this resource was created on the server.
        #
        def created_at
          Time.parse @gapi.creation_time
        rescue
          nil
        end

        ##
        # Permanently deletes the zone.
        #
        # @param [Boolean] force If `true`, ensures the deletion of the zone by
        #   first deleting all records. If `false` and the zone contains
        #   non-essential records, the request will fail. Default is `false`.
        #
        # @return [Boolean] Returns `true` if the zone was deleted.
        #
        # @example
        #   require "google/cloud/dns"
        #
        #   dns = Google::Cloud::Dns.new
        #   zone = dns.zone "example-com"
        #   zone.delete
        #
        # @example The zone can be forcefully deleted with the `force` option:
        #   require "google/cloud/dns"
        #
        #   dns = Google::Cloud::Dns.new
        #   zone = dns.zone "example-com"
        #   zone.delete force: true
        #
        def delete force: false
          clear! if force

          ensure_service!
          service.delete_zone id
          true
        end

        ##
        # Removes non-essential records from the zone. Only NS and SOA records
        # will be kept.
        #
        # @example
        #   require "google/cloud/dns"
        #
        #   dns = Google::Cloud::Dns.new
        #   zone = dns.zone "example-com"
        #   zone.clear!
        #
        def clear!
          non_essential = records.all.reject { |r| %w(SOA NS).include?(r.type) }
          change = update [], non_essential
          change.wait_until_done! unless change.nil?
        end

        ##
        # Retrieves an existing change by id.
        #
        # @param [String] change_id The id of a change.
        #
        # @return [Google::Cloud::Dns::Change, nil] Returns `nil` if the change
        #   does not exist.
        #
        # @example
        #   require "google/cloud/dns"
        #
        #   dns = Google::Cloud::Dns.new
        #   zone = dns.zone "example-com"
        #   change = zone.change "2"
        #   if change
        #     puts "#{change.id} - #{change.started_at} - #{change.status}"
        #   end
        #
        def change change_id
          ensure_service!
          gapi = service.get_change id, change_id
          Change.from_gapi gapi, self
        rescue Google::Cloud::NotFoundError
          nil
        end
        alias_method :find_change, :change
        alias_method :get_change, :change

        ##
        # Retrieves the list of changes belonging to the zone.
        #
        # @param [String] token A previously-returned page token representing
        #   part of the larger set of results to view.
        # @param [Integer] max Maximum number of changes to return.
        # @param [Symbol, String] order Sort the changes by change sequence.
        #
        #   Acceptable values are:
        #
        #   * `asc` - Sort by ascending change sequence
        #   * `desc` - Sort by descending change sequence
        #
        # @return [Array<Google::Cloud::Dns::Change>] (See
        #   {Google::Cloud::Dns::Change::List})
        #
        # @example
        #   require "google/cloud/dns"
        #
        #   dns = Google::Cloud::Dns.new
        #   zone = dns.zone "example-com"
        #   changes = zone.changes
        #   changes.each do |change|
        #     puts "#{change.id} - #{change.started_at} - #{change.status}"
        #   end
        #
        # @example The changes can be sorted by change sequence:
        #   require "google/cloud/dns"
        #
        #   dns = Google::Cloud::Dns.new
        #   zone = dns.zone "example-com"
        #   changes = zone.changes order: :desc
        #
        # @example Retrieve all changes: (See {Change::List#all})
        #   require "google/cloud/dns"
        #
        #   dns = Google::Cloud::Dns.new
        #   zone = dns.zone "example-com"
        #   changes = zone.changes
        #   changes.all do |change|
        #     puts "#{change.id} - #{change.status}"
        #   end
        #
        def changes token: nil, max: nil, order: nil
          ensure_service!
          # Fix the sort options
          order = adjust_change_sort_order order
          sort  = "changeSequence" if order
          # Continue with the API call
          gapi = service.list_changes id, token: token, max: max,
                                          order: order, sort: sort
          Change::List.from_gapi gapi, self, max, order
        end
        alias_method :find_changes, :changes

        ##
        # Retrieves the list of records belonging to the zone. Records can be
        # filtered by name and type. The name argument can be a subdomain (e.g.,
        # `www`) fragment for convenience, but notice that the retrieved
        # record's domain name is always fully-qualified.
        #
        # @param [String] name Return only records with this domain or subdomain
        #   name.
        # @param [String] type Return only records with this [record
        #   type](https://cloud.google.com/dns/what-is-cloud-dns). If present,
        #   the `name` parameter must also be present.
        # @param [String] token A previously-returned page token representing
        #   part of the larger set of results to view.
        # @param [Integer] max Maximum number of records to return.
        #
        # @return [Array<Google::Cloud::Dns::Record>] (See
        #   {Google::Cloud::Dns::Record::List})
        #
        # @example
        #   require "google/cloud/dns"
        #
        #   dns = Google::Cloud::Dns.new
        #   zone = dns.zone "example-com"
        #   records = zone.records
        #   records.each do |record|
        #     puts record.name
        #   end
        #
        # @example Records can be filtered by name and type:
        #   require "google/cloud/dns"
        #
        #   dns = Google::Cloud::Dns.new
        #   zone = dns.zone "example-com"
        #   records = zone.records "www", "A"
        #   records.first.name #=> "www.example.com."
        #
        # @example Retrieve all records:
        #   require "google/cloud/dns"
        #
        #   dns = Google::Cloud::Dns.new
        #   zone = dns.zone "example-com"
        #   records = zone.records "example.com."
        #
        #   records.all do |record|
        #     puts record.name
        #   end
        #
        def records name = nil, type = nil, token: nil, max: nil
          ensure_service!

          name = fqdn(name) if name

          gapi = service.list_records id, name, type, token: token, max: max
          Record::List.from_gapi gapi, self, name, type, max
        end
        alias_method :find_records, :records

        ##
        # Creates a new, unsaved Record that can be added to a Zone. See
        # {#update}.
        #
        # @return [Google::Cloud::Dns::Record]
        #
        # @example
        #   require "google/cloud/dns"
        #
        #   dns = Google::Cloud::Dns.new
        #   zone = dns.zone "example-com"
        #   record = zone.record "example.com.", "A", 86400, ["1.2.3.4"]
        #   zone.update record
        #
        def record name, type, ttl, data
          Google::Cloud::Dns::Record.new fqdn(name), type, ttl, data
        end
        alias_method :new_record, :record

        ##
        # Exports the zone to a local [DNS zone
        # file](https://en.wikipedia.org/wiki/Zone_file).
        #
        # @param [String] path The path on the local file system to write the
        #   data to. The path provided must be writable.
        #
        # @return [File] An object on the local file system.
        #
        # @example
        #   require "google/cloud/dns"
        #
        #   dns = Google::Cloud::Dns.new
        #   zone = dns.zone "example-com"
        #
        #   zone.export "path/to/db.example.com"
        #
        def export path
          File.open path, "w" do |f|
            f.write to_zonefile
          end
        end

        ##
        # Imports resource records from a [DNS zone
        # file](https://en.wikipedia.org/wiki/Zone_file), adding the new records
        # to the zone, without removing any existing records from the zone.
        #
        # Because the Google Cloud DNS API only accepts a single resource record
        # for each `name` and `type` combination (with multiple `data`
        # elements), the zone file's records are merged as necessary. During
        # this merge, the lowest `ttl` of the merged records is used. If none of
        # the merged records have a `ttl` value, the zone file's global TTL is
        # used for the record.
        #
        # The zone file's SOA and NS records are not imported, because the zone
        # was given SOA and NS records when it was created. These generated
        # records point to Cloud DNS name servers.
        #
        # This operation automatically updates the SOA record serial number
        # unless prevented with the `skip_soa` option. See {#update} for
        # details.
        #
        # The Google Cloud DNS service requires that record names and data use
        # fully-qualified addresses. The @ symbol is not accepted, nor are
        # unqualified subdomain addresses like www. If your zone file contains
        # such values, you may need to pre-process it in order for the import
        # operation to succeed.
        #
        # @param [String, IO] path_or_io The path to a zone file on the
        #   filesystem, or an IO instance from which zone file data can be read.
        # @param [String, Array<String>] only Include only records of this type
        #   or types.
        # @param [String, Array<String>] except Exclude records of this type or
        #   types.
        # @param [Boolean] skip_soa Do not automatically update the SOA record
        #   serial number. See {#update} for details.
        # @param [Integer, lambda, Proc] soa_serial A value (or a lambda or Proc
        #   returning a value) for the new SOA record serial number. See
        #   {#update} for details.
        #
        # @return [Google::Cloud::Dns::Change] A new change adding the imported
        #   Record instances.
        #
        # @example
        #   require "google/cloud/dns"
        #
        #   dns = Google::Cloud::Dns.new
        #   zone = dns.zone "example-com"
        #   change = zone.import "path/to/db.example.com"
        #
        def import path_or_io, only: nil, except: nil,
                   skip_soa: nil, soa_serial: nil
          except = (Array(except).map(&:to_s).map(&:upcase) + %w(SOA NS)).uniq
          importer = Google::Cloud::Dns::Importer.new self, path_or_io
          additions = importer.records only: only, except: except
          update additions, [], skip_soa: skip_soa, soa_serial: soa_serial
        end

        # rubocop:disable all
        # Disabled rubocop because this complexity cannot easily be avoided.

        ##
        # Adds and removes Records from the zone. All changes are made in a
        # single API request.
        #
        # The best way to add, remove, and update multiple records in a single
        # [transaction](https://cloud.google.com/dns/records) is with a block.
        # See {Zone::Transaction}.
        #
        # If the SOA record for the zone is not present in `additions` or
        # `deletions` (and if present in one, it should be present in the
        # other), it will be added to both, and its serial number will be
        # incremented by adding `1`. This update to the SOA record can be
        # prevented with the `skip_soa` option. To provide your own value or
        # behavior for the new serial number, use the `soa_serial` option.
        #
        # @param [Record, Array<Record>] additions The Record or array of
        #   records to add.
        # @param [Record, Array<Record>] deletions The Record or array of
        #   records to remove.
        # @param [Boolean] skip_soa Do not automatically update the SOA record
        #   serial number.
        # @param [Integer, lambda, Proc] soa_serial A value (or a lambda or Proc
        #   returning a value) for the new SOA record serial number.
        # @yield [tx] a block yielding a new transaction
        # @yieldparam [Zone::Transaction] tx the transaction object
        #
        # @return [Google::Cloud::Dns::Change]
        #
        # @example Using a block:
        #   require "google/cloud/dns"
        #
        #   dns = Google::Cloud::Dns.new
        #   zone = dns.zone "example-com"
        #   change = zone.update do |tx|
        #     tx.add     "example.com.", "A",  86400, "1.2.3.4"
        #     tx.remove  "example.com.", "TXT"
        #     tx.replace "example.com.", "MX", 86400, ["10 mail1.example.com.",
        #                                              "20 mail2.example.com."]
        #     tx.modify "www.example.com.", "CNAME" do |cname|
        #       cname.ttl = 86400 # only change the TTL
        #     end
        #   end
        #
        # @example Or you can provide the record objects to add and remove:
        #   require "google/cloud/dns"
        #
        #   dns = Google::Cloud::Dns.new
        #   zone = dns.zone "example-com"
        #   new_record = zone.record "example.com.", "A", 86400, ["1.2.3.4"]
        #   old_record = zone.record "example.com.", "A", 18600, ["1.2.3.4"]
        #   change = zone.update [new_record], [old_record]
        #
        # @example Using a lambda or Proc to update current SOA serial number:
        #   require "google/cloud/dns"
        #
        #   dns = Google::Cloud::Dns.new
        #   zone = dns.zone "example-com"
        #   new_record = zone.record "example.com.", "A", 86400, ["1.2.3.4"]
        #   change = zone.update new_record, soa_serial: lambda { |sn| sn + 10 }
        #
        def update additions = [], deletions = [], skip_soa: nil, soa_serial: nil
          # Handle only sending in options
          if additions.is_a?(::Hash) && deletions.empty? && options.empty?
            options = additions
            additions = []
          elsif deletions.is_a?(::Hash) && options.empty?
            options = deletions
            deletions = []
          end

          additions = Array additions
          deletions = Array deletions

          if block_given?
            updater = Zone::Transaction.new self
            yield updater
            additions += updater.additions
            deletions += updater.deletions
          end

          to_add    = additions - deletions
          to_remove = deletions - additions
          return nil if to_add.empty? && to_remove.empty?
          unless skip_soa || detect_soa(to_add) || detect_soa(to_remove)
            increment_soa to_add, to_remove, soa_serial
          end
          create_change to_add, to_remove
        end

        # rubocop:enable all

        ##
        # Adds a record to the Zone. In order to update existing records, or add
        # and delete records in the same transaction, use #update.
        #
        # This operation automatically updates the SOA record serial number
        # unless prevented with the `skip_soa` option. See {#update} for
        # details.
        #
        # @param [String] name The owner of the record. For example:
        #   `example.com.`.
        # @param [String] type The identifier of a [supported record
        #   type](https://cloud.google.com/dns/what-is-cloud-dns).
        #   For example: `A`, `AAAA`, `CNAME`, `MX`, or `TXT`.
        # @param [Integer] ttl The number of seconds that the record can be
        #   cached by resolvers.
        # @param [String, Array<String>] data The resource record data, as
        #   determined by `type` and defined in [RFC
        #   1035 (section 5)](http://tools.ietf.org/html/rfc1035#section-5) and
        #   [RFC 1034
        #   (section 3.6.1)](http://tools.ietf.org/html/rfc1034#section-3.6.1).
        #   For example: `192.0.2.1` or `example.com.`.
        # @param [Boolean] skip_soa Do not automatically update the SOA record
        #   serial number. See {#update} for details.
        # @param [Integer+, lambda, Proc] soa_serial A value (or a lambda or
        #   Proc returning a value) for the new SOA record serial number. See
        #   {#update} for details.
        #
        # @return [Google::Cloud::Dns::Change]
        #
        # @example
        #   require "google/cloud/dns"
        #
        #   dns = Google::Cloud::Dns.new
        #   zone = dns.zone "example-com"
        #   change = zone.add "example.com.", "A", 86400, ["1.2.3.4"]
        #
        def add name, type, ttl, data, skip_soa: nil, soa_serial: nil
          update [record(name, type, ttl, data)], [],
                 skip_soa: skip_soa, soa_serial: soa_serial
        end

        ##
        # Removes records from the Zone. The records are looked up before they
        # are removed. In order to update existing records, or add and remove
        # records in the same transaction, use #update.
        #
        # This operation automatically updates the SOA record serial number
        # unless prevented with the `skip_soa` option. See {#update} for
        # details.
        #
        # @param [String] name The owner of the record. For example:
        #   `example.com.`.
        # @param [String] type The identifier of a [supported record
        #   type](https://cloud.google.com/dns/what-is-cloud-dns).
        #   For example: `A`, `AAAA`, `CNAME`, `MX`, or `TXT`.
        # @param [Boolean] skip_soa Do not automatically update the SOA record
        #   serial number. See {#update} for details.
        # @param [Integer+, lambda, Proc] soa_serial A value (or a lambda or
        #   Proc returning a value) for the new SOA record serial number. See
        #   {#update} for details.
        #
        # @return [Google::Cloud::Dns::Change]
        #
        # @example
        #   require "google/cloud/dns"
        #
        #   dns = Google::Cloud::Dns.new
        #   zone = dns.zone "example-com"
        #   change = zone.remove "example.com.", "A"
        #
        def remove name, type, skip_soa: nil, soa_serial: nil
          update [], records(name, type).all.to_a,
                 skip_soa: skip_soa, soa_serial: soa_serial
        end

        ##
        # Replaces existing records on the Zone. Records matching the `name` and
        # `type` are replaced. In order to update existing records, or add and
        # delete records in the same transaction, use #update.
        #
        # This operation automatically updates the SOA record serial number
        # unless prevented with the `skip_soa` option. See {#update} for
        # details.
        #
        # @param [String] name The owner of the record. For example:
        #   `example.com.`.
        # @param [String] type The identifier of a [supported record
        #   type](https://cloud.google.com/dns/what-is-cloud-dns).
        #   For example: `A`, `AAAA`, `CNAME`, `MX`, or `TXT`.
        # @param [Integer] ttl The number of seconds that the record can be
        #   cached by resolvers.
        # @param [String, Array<String>] data The resource record data, as
        #   determined by `type` and defined in [RFC 1035 (section
        #   5)](http://tools.ietf.org/html/rfc1035#section-5) and [RFC 1034
        #   (section 3.6.1)](http://tools.ietf.org/html/rfc1034#section-3.6.1).
        #   For example: `192.0.2.1` or `example.com.`.
        # @param [Boolean] skip_soa Do not automatically update the SOA record
        #   serial number. See {#update} for details.
        # @param [Integer+, lambda, Proc] soa_serial A value (or a lambda or
        #   Proc returning a value) for the new SOA record serial number. See
        #   {#update} for details.
        #
        # @return [Google::Cloud::Dns::Change]
        #
        # @example
        #   require "google/cloud/dns"
        #
        #   dns = Google::Cloud::Dns.new
        #   zone = dns.zone "example-com"
        #   change = zone.replace "example.com.", "A", 86400, ["5.6.7.8"]
        #
        def replace name, type, ttl, data, skip_soa: nil, soa_serial: nil
          update [record(name, type, ttl, data)],
                 records(name, type).all.to_a,
                 skip_soa: skip_soa, soa_serial: soa_serial
        end

        # @private
        def to_zonefile
          records.all.map(&:to_zonefile_records).flatten.join("\n")
        end

        ##
        # Modifies records on the Zone. Records matching the `name` and `type`
        # are yielded to the block where they can be modified.
        #
        # This operation automatically updates the SOA record serial number
        # unless prevented with the `skip_soa` option. See {#update} for
        # details.
        #
        # @param [String] name The owner of the record. For example:
        #   `example.com.`.
        # @param [String] type The identifier of a [supported record
        #   type](https://cloud.google.com/dns/what-is-cloud-dns).
        #   For example: `A`, `AAAA`, `CNAME`, `MX`, or `TXT`.
        # @param [Boolean] skip_soa Do not automatically update the SOA record
        #   serial number. See {#update} for details.
        # @param [Integer+, lambda, Proc] soa_serial A value (or a lambda or
        #   Proc returning a value) for the new SOA record serial number. See
        #   {#update} for details.
        # @yield [record] a block yielding each matching record
        # @yieldparam [Record] record the record to be modified
        #
        # @return [Google::Cloud::Dns::Change]
        #
        # @example
        #   require "google/cloud/dns"
        #
        #   dns = Google::Cloud::Dns.new
        #   zone = dns.zone "example-com"
        #   change = zone.modify "example.com.", "MX" do |mx|
        #     mx.ttl = 3600 # change only the TTL
        #   end
        #
        def modify name, type, skip_soa: nil, soa_serial: nil
          existing = records(name, type).all.to_a
          updated = existing.map(&:dup)
          updated.each { |r| yield r }
          update updated, existing, skip_soa: skip_soa, soa_serial: soa_serial
        end

        ##
        # This helper converts the given domain name or subdomain (e.g., `www`)
        # fragment to a [fully qualified domain name
        # (FQDN)](https://en.wikipedia.org/wiki/Fully_qualified_domain_name) for
        # the zone's #dns. If the argument is already a FQDN, it is returned
        # unchanged.
        #
        # @param [String] domain_name The name to convert to a fully qualified
        #   domain name.
        #
        # @return [String] A fully qualified domain name.
        #
        # @example
        #   require "google/cloud/dns"
        #
        #   dns = Google::Cloud::Dns.new
        #   zone = dns.zone "example-com"
        #   zone.fqdn "www" #=> "www.example.com."
        #   zone.fqdn "@" #=> "example.com."
        #   zone.fqdn "mail.example.com." #=> "mail.example.com."
        #
        def fqdn domain_name
          Service.fqdn domain_name, dns
        end

        ##
        # @private New Zone from a Google API Client object.
        def self.from_gapi gapi, conn
          new.tap do |f|
            f.gapi = gapi
            f.service = conn
          end
        end

        protected

        ##
        # Raise an error unless an active connection is available.
        def ensure_service!
          fail "Must have active connection" unless service
        end

        def create_change additions, deletions
          ensure_service!
          gapi = service.create_change id, additions.map(&:to_gapi),
                                       deletions.map(&:to_gapi)
          Change.from_gapi gapi, self
        end

        def increment_soa to_add, to_remove, soa_serial
          current_soa = detect_soa records(dns, "SOA").all
          return false if current_soa.nil?
          updated_soa = current_soa.dup
          updated_soa.data[0] = replace_soa_serial updated_soa.data[0],
                                                   soa_serial
          to_add << updated_soa
          to_remove << current_soa
        end

        def detect_soa records
          records.detect { |r| r.type == "SOA" }
        end

        def replace_soa_serial soa_data, soa_serial
          soa_data = soa_data.split " "
          current_serial = soa_data[2].to_i
          soa_data[2] = if soa_serial && soa_serial.respond_to?(:call)
                          soa_serial.call current_serial
                        elsif soa_serial
                          soa_serial.to_i
                        else
                          current_serial + 1
                        end
          soa_data.join " "
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
end
