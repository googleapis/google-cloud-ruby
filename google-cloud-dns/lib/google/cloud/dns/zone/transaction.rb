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


module Google
  module Cloud
    module Dns
      class Zone
        ##
        # # DNS Zone Transaction
        #
        # This object is used by {Zone#update} when passed a block. These
        # methods are used to update the records that are sent to the Google
        # Cloud DNS API.
        #
        # @example
        #   require "google/cloud/dns"
        #
        #   dns = Google::Cloud::Dns.new
        #   zone = dns.zone "example-com"
        #   zone.update do |tx|
        #     tx.add     "example.com.", "A",  86400, "1.2.3.4"
        #     tx.remove  "example.com.", "TXT"
        #     tx.replace "example.com.", "MX", 86400, ["10 mail1.example.com.",
        #                                              "20 mail2.example.com."]
        #     tx.modify "www.example.com.", "CNAME" do |cname|
        #       cname.ttl = 86400 # only change the TTL
        #     end
        #   end
        #
        class Transaction
          # @private
          attr_reader :additions, :deletions

          ##
          # @private Creates a new transaction.
          def initialize zone
            @zone = zone
            @additions = []
            @deletions = []
          end

          ##
          # Adds a record to the Zone.
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
          #   (section
          #   3.6.1)](http://tools.ietf.org/html/rfc1034#section-3.6.1). For
          #   example: `192.0.2.1` or `example.com.`.
          #
          # @example
          #   require "google/cloud/dns"
          #
          #   dns = Google::Cloud::Dns.new
          #   zone = dns.zone "example-com"
          #   zone.update do |tx|
          #     tx.add     "example.com.", "A",  86400, "1.2.3.4"
          #   end
          #
          def add name, type, ttl, data
            @additions += Array(@zone.record(name, type, ttl, data))
          end

          ##
          # Removes records from the Zone. The records are looked up before they
          # are removed.
          #
          # @param [String] name The owner of the record. For example:
          #   `example.com.`.
          # @param [String] type The identifier of a [supported record
          #   type](https://cloud.google.com/dns/what-is-cloud-dns).
          #   For example: `A`, `AAAA`, `CNAME`, `MX`, or `TXT`.
          #
          # @example
          #   require "google/cloud/dns"
          #
          #   dns = Google::Cloud::Dns.new
          #   zone = dns.zone "example-com"
          #   zone.update do |tx|
          #     tx.remove  "example.com.", "TXT"
          #   end
          #
          def remove name, type
            @deletions += @zone.records(name, type).all.to_a
          end

          ##
          # Replaces existing records on the Zone. Records matching the `name`
          # and `type` are replaced.
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
          #   (section
          #   3.6.1)](http://tools.ietf.org/html/rfc1034#section-3.6.1). For
          #   example: `192.0.2.1` or `example.com.`.
          #
          # @example
          #   require "google/cloud/dns"
          #
          #   dns = Google::Cloud::Dns.new
          #   zone = dns.zone "example-com"
          #   zone.update do |tx|
          #     tx.replace "example.com.",
          #                "MX", 86400,
          #                ["10 mail1.example.com.",
          #                 "20 mail2.example.com."]
          #   end
          #
          def replace name, type, ttl, data
            remove name, type
            add name, type, ttl, data
          end

          ##
          # Modifies records on the Zone. Records matching the `name` and `type`
          # are yielded to the block where they can be modified.
          #
          # @param [String] name The owner of the record. For example:
          #   `example.com.`.
          # @param [String] type The identifier of a [supported record
          #   type](https://cloud.google.com/dns/what-is-cloud-dns).
          #   For example: `A`, `AAAA`, `CNAME`, `MX`, or `TXT`.
          # @yield [record] a block yielding each matching record
          # @yieldparam [Record] record the record to be modified
          #
          # @example
          #   require "google/cloud/dns"
          #
          #   dns = Google::Cloud::Dns.new
          #   zone = dns.zone "example-com"
          #   zone.update do |tx|
          #     tx.modify "www.example.com.", "CNAME" do |cname|
          #       cname.ttl = 86400 # only change the TTL
          #     end
          #   end
          #
          def modify name, type
            existing = @zone.records(name, type).all.to_a
            updated = existing.map(&:dup)
            updated.each { |r| yield r }
            @additions += updated
            @deletions += existing
          end
        end
      end
    end
  end
end
