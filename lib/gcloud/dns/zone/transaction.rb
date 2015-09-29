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
    class Zone
      ##
      # = DNS Zone Transaction
      #
      # This object is used by Zone#update when passed a block. These methods
      # are used to update the records that are sent to the Google Cloud DNS
      # API.
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   dns = gcloud.dns
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
        attr_reader :additions, :deletions #:nodoc:

        ##
        # Creates a new transaction.
        def initialize zone #:nodoc:
          @zone = zone
          @additions = []
          @deletions = []
        end

        ##
        # Adds a record to the Zone.
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
        #   The resource record data, as determined by +type+ and defined in
        #   {RFC 1035 (section 5)}[http://tools.ietf.org/html/rfc1035#section-5]
        #   and {RFC 1034 (section
        #   3.6.1)}[http://tools.ietf.org/html/rfc1034#section-3.6.1]. For
        #   example: +192.0.2.1+ or +example.com.+. (+String+ or +Array+ of
        #   +String+)
        #
        # === Example
        #
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   dns = gcloud.dns
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
        # === Parameters
        #
        # +name+::
        #   The owner of the record. For example: +example.com.+. (+String+)
        # +type+::
        #   The identifier of a {supported record
        #   type}[https://cloud.google.com/dns/what-is-cloud-dns].
        #   For example: +A+, +AAAA+, +CNAME+, +MX+, or +TXT+. (+String+)
        #
        # === Example
        #
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   dns = gcloud.dns
        #   zone = dns.zone "example-com"
        #   zone.update do |tx|
        #     tx.remove  "example.com.", "TXT"
        #   end
        #
        def remove name, type
          @deletions += @zone.records(name: name, type: type).all
        end

        ##
        # Replaces existing records on the Zone. Records matching the +name+ and
        # +type+ are replaced.
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
        #   The resource record data, as determined by +type+ and defined in
        #   {RFC 1035 (section 5)}[http://tools.ietf.org/html/rfc1035#section-5]
        #   and {RFC 1034 (section
        #   3.6.1)}[http://tools.ietf.org/html/rfc1034#section-3.6.1]. For
        #   example: +192.0.2.1+ or +example.com.+. (+String+ or +Array+ of
        #   +String+)
        #
        # === Example
        #
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   dns = gcloud.dns
        #   zone = dns.zone "example-com"
        #   zone.update do |tx|
        #     tx.replace "example.com.", "MX", 86400, ["10 mail1.example.com.",
        #                                              "20 mail2.example.com."]
        #   end
        #
        def replace name, type, ttl, data
          remove name, type
          add name, type, ttl, data
        end

        ##
        # Modifies records on the Zone. Records matching the +name+ and +type+
        # are yielded to the block where they can be modified.
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
        # === Example
        #
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   dns = gcloud.dns
        #   zone.update do |tx|
        #     tx.modify "www.example.com.", "CNAME" do |cname|
        #       cname.ttl = 86400 # only change the TTL
        #     end
        #   end
        #
        def modify name, type
          existing = @zone.records(name: name, type: type).all.to_a
          updated = existing.map(&:dup)
          updated.each { |r| yield r }
          @additions += updated
          @deletions += existing
        end
      end
    end
  end
end
