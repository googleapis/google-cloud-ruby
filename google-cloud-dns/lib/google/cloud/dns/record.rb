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


require "google/cloud/dns/record/list"

module Google
  module Cloud
    module Dns
      ##
      # # DNS Record
      #
      # Represents a set of DNS resource records (RRs) for a given
      # {Google::Cloud::Dns::Record#name} and {Google::Cloud::Dns::Record#type}
      # in a {Google::Cloud::Dns::Zone}. Since it is a value object, a newly
      # created Record instance is transient until it is added to a Zone with
      # {Google::Cloud::Dns::Zone#update}. Note that
      # {Google::Cloud::Dns::Zone#add} and the {Google::Cloud::Dns::Zone#update}
      # block parameter can be used instead of {Google::Cloud::Dns::Zone#record}
      # or `Record.new` to create new records.
      #
      # @example
      #   require "google/cloud/dns"
      #
      #   dns = Google::Cloud::Dns.new
      #   zone = dns.zone "example-com"
      #
      #   zone.records.count #=> 2
      #   record = zone.record "example.com.", "A", 86400, "1.2.3.4"
      #   zone.records.count #=> 2
      #   change = zone.update record
      #   zone.records.count #=> 3
      #
      class Record
        ##
        # The owner of the record. For example: `example.com.`.
        #
        # @return [String]
        #
        attr_accessor :name

        ##
        # The identifier of a [supported record type
        # ](https://cloud.google.com/dns/what-is-cloud-dns#supported_record_types).
        # For example: `A`, `AAAA`, `CNAME`, `MX`, or `TXT`.
        #
        # @return [String]
        #
        attr_accessor :type

        ##
        # The number of seconds that the record can be cached by resolvers.
        #
        # @return [Integer]
        #
        attr_accessor :ttl

        ##
        # The array of resource record data, as determined by `type` and defined
        # in [RFC 1035 (section
        # 5)](http://tools.ietf.org/html/rfc1035#section-5) and [RFC 1034
        # (section 3.6.1)](http://tools.ietf.org/html/rfc1034#section-3.6.1).
        # For example: ["10 mail.example.com.", "20 mail2.example.com."].
        #
        # @return [Array<String>]
        #
        attr_accessor :data

        ##
        # Creates a Record value object.
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
        #   For example: ["10 mail.example.com.", "20 mail2.example.com."].
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
        # @private Returns an array of strings in the zone file format, one
        # for each element in the record's data array.
        def to_zonefile_records
          data.map do |rrdata|
            "#{name} #{ttl} IN #{type} #{rrdata}"
          end
        end

        ##
        # Returns a deep copy of the record. Useful for updating records, since
        # the original, unmodified record must be passed for deletion when using
        # {Google::Cloud::Dns::Zone#update}.
        #
        def dup
          other = super
          other.data = data.map(&:dup)
          other
        end

        ##
        # @private New Record from a Google API Client object.
        def self.from_gapi gapi
          new gapi.name, gapi.type, gapi.ttl, gapi.rrdatas
        end

        ##
        # @private Convert the record object to a Google API hash.
        def to_gapi
          Google::Apis::DnsV1::ResourceRecordSet.new(
            kind: "dns#resourceRecordSet",
            name: name,
            rrdatas: data,
            ttl: ttl,
            type: type
          )
        end

        # @private
        def hash
          [name, type, ttl, data].hash
        end

        # @private
        def eql? other
          return false unless other.is_a? self.class
          name == other.name && type == other.type &&
            ttl == other.ttl && data == other.data
        end

        # @private
        def == other
          self.eql? other
        end

        # @private
        def <=> other
          return nil unless other.is_a? self.class
          [name, type, ttl, data] <=>
            [other.name, other.type, other.ttl, other.data]
        end
      end
    end
  end
end
