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
    #   zone = dns.zone "example-com"
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
      # The identifier of a {supported record type
      # }[https://cloud.google.com/dns/what-is-cloud-dns#supported_record_types]
      # . For example: +A+, +AAAA+, +CNAME+, +MX+, or +TXT+. (+String+)
      attr_accessor :type

      ##
      # The number of seconds that the record can be cached by resolvers.
      # (+Integer+)
      attr_accessor :ttl

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
        fail ArgumentError, "type is required" unless type
        fail ArgumentError, "ttl is required" unless ttl
        fail ArgumentError, "data is required" unless data
        @name = name.to_s
        @type = type.to_s.upcase
        @ttl = Integer(ttl)
        @data = Array(data)
      end

      ##
      # Returns an array of strings in the zone file format, one
      # for each element in the record's data array.
      def to_zonefile_records #:nodoc:
        data.map do |rrdata|
          "#{name} #{ttl} IN #{type} #{rrdata}"
        end
      end

      ##
      # Returns a deep copy of the record. Useful for changing records, since
      # the original record must be passed for deletion when using Zone#update.
      def dup
        other = super
        other.data = data.map(&:dup)
        other
      end

      ##
      # New Record from a Google API Client object.
      def self.from_gapi gapi #:nodoc:
        new gapi["name"], gapi["type"], gapi["ttl"], gapi["rrdatas"]
      end

      ##
      # Convert the record object to a Google API hash.
      def to_gapi #:nodoc:
        { "name" => name, "type" => type, "ttl" => ttl, "rrdatas" => data }
      end

      def hash #:nodoc:
        [name, type, ttl, data].hash
      end

      def eql? other #:nodoc:
        return false unless other.is_a? self.class
        name == other.name && type == other.type &&
          ttl == other.ttl && data == other.data
      end

      def == other #:nodoc:
        self.eql? other
      end

      def <=> other #:nodoc:
        return nil unless other.is_a? self.class
        [name, type, ttl, data] <=>
          [other.name, other.type, other.ttl, other.data]
      end
    end
  end
end
