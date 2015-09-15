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

require "gcloud/dns/record/list"

module Gcloud
  module Dns
    ##
    # = DNS Record
    #
    # A value object representing a DNS resource record (RR). A newly created
    # record is transient until it is added to a Zone's resource record set.
    #
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   dns = gcloud.dns
    #   zone = dns.zone "example-zone"
    #
    #   record_1 = zone.record "example.com.", "A", 86400, "1.2.3.4"
    #   mx_data = ["10 mail.example.com.","20 mail2.example.com."]
    #   record_2 = zone.record "example.com.", "A", 86400, mx_data
    #   zone.change [record_1, record_2], []
    #
    class Record
      ##
      # The owner of the record. For example: +example.com.+. (+String+)
      attr_accessor :name

      ##
      # The number of seconds that the record can be cached by resolvers.
      # (+Integer+)
      attr_accessor :ttl

      ##
      # The identifier of a {supported record type
      # }[https://cloud.google.com/dns/what-is-cloud-dns#supported_record_types]
      # . For example: +A+, +AAAA+, +CNAME+, +MX+, or +TXT+. (+String+)
      attr_accessor :type

      ##
      # The resource record data, as determined by +type+ and defined in RFC
      # 1035 (section 5) and RFC 1034 (section 3.6.1). For example: +192.0.2.1+
      # or +example.com.+. (+Array+ of +String+)
      attr_accessor :data

      ##
      # Creates a Record value object.
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
      def initialize name, type, ttl, data
        fail ArgumentError, "name is required" unless name
        fail ArgumentError, "ttl is required" unless ttl
        fail ArgumentError, "type is required" unless type
        fail ArgumentError, "data is required" unless data
        @name = name.to_s
        @ttl = Integer(ttl)
        @type = type.to_s.upcase
        @data = Array(data)
      end

      ##
      # New Record from a Google API Client object.
      def self.from_gapi gapi #:nodoc:
        new gapi["name"], gapi["type"], gapi["ttl"], gapi["rrdatas"]
      end

      def to_gapi
        { "name" => name, "type" => type, "ttl" => ttl, "rrdatas" => data }
      end

      # rubocop:disable all
      # Rubocop's line-length and branch condition restrictions would prevent
      # the most straightforward approach to converting zonefile's records
      # to our own. So disable rubocop for these operations.

      ##
      # The zonefile library returns a two-element array in which the first
      # element is a symbol type (:a, :mx, and so on), and the second element
      # is an array containing the records of that type. We need to convert to a
      # single array of records; and at the same time, aggregate records of the
      # same name, ttl, and type into a single record with an array of rrdatas.
      def self.from_zonefile zf # :nodoc:
        final = {}
        zf.records.map do |r|
          type = r.first
          type = :aaaa if type == :a4
          r.last.each do |record|
            ttl = ttl_to_i(record[:ttl] || zf.ttl)
            key = [(record[:name] || zf.name), ttl, type]
            final[key] ||= []
            final[key] << data_from_zonefile_record(type, record)
          end
        end
        final.map do |key, value|
          Record.new key[0], key[1], key[2], value
        end
      end

      def self.data_from_zonefile_record type, zf_record # :nodoc:
        case type.to_s.upcase
        when "A"
          "#{zf_record[:host]}"
        when "AAAA"
          "#{zf_record[:host]}"
        when "CNAME"
          "#{zf_record[:host]}"
        when "MX"
          "#{zf_record[:pri]} #{zf_record[:host]}"
        when "NAPTR"
          "#{zf_record[:order]} #{zf_record[:preference]} #{zf_record[:flags]} #{zf_record[:service]} #{zf_record[:regexp]} #{zf_record[:replacement]}"
        when "NS"
          "#{zf_record[:host]}"
        when "PTR"
          "#{zf_record[:host]}"
        when "SOA"
          "#{zf_record[:mname]} #{zf_record[:rname]} #{zf_record[:serial]} #{zf_record[:retry]} #{zf_record[:refresh]} #{zf_record[:expire]} #{zf_record[:minimum]}"
        when "SPF"
          "#{zf_record[:data]}"
        when "SRV"
          "#{zf_record[:pri]} #{zf_record[:weight]} #{zf_record[:port]} #{zf_record[:host]}"
        when "TXT"
          "#{zf_record[:text]}"
        else
          fail ArgumentError, "record type '#{type}' is not supported"
        end
      end

      # rubocop:enable all

      MULTIPLIER = { "s" => (1),
                     "m" => (60),
                     "h" => (60 * 60),
                     "d" => (60 * 60 * 24),
                     "w" => (60 * 60 * 24 * 7) } # :nodoc:

      def self.ttl_to_i ttl # :nodoc:
        if ttl.respond_to?(:to_int) || ttl.to_s =~ /\A\d+\z/
          return ttl.to_i
        elsif (m = /\A(\d+)(w|d|h|m|s)\z/.match ttl)
          return m[1].to_i * MULTIPLIER[m[2]].to_i
        end
        fail ArgumentError, "ttl '#{ttl}' is not convertible to seconds"
      end
    end
  end
end
