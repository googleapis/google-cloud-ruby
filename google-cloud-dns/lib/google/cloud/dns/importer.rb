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


require "zonefile"
require "google/cloud/dns/record"

module Google
  module Cloud
    module Dns
      ##
      # @private
      # # DNS Importer
      #
      # Reads a [DNS zone file](https://en.wikipedia.org/wiki/Zone_file) and
      # parses it, creating a collection of Record instances. The returned
      # records are unsaved, as they are not yet associated with a Zone. Use
      # {Zone#import} to add zone file records to a Zone.
      #
      # Because the Google Cloud DNS API only accepts a single resource record
      # for each `name` and `type` combination (with multiple `data` elements),
      # the zone file's records are merged as necessary. During this merge, the
      # lowest `ttl` of the merged records is used. If none of the merged
      # records have a `ttl` value, the zone file's global TTL is used for the
      # record.
      #
      # The following record types are supported: A, AAAA, CNAME, MX, NAPTR, NS,
      # PTR, SOA, SPF, SRV, and TXT.
      class Importer
        ##
        # Creates a new Importer that immediately parses the provided zone file
        # data and creates Record instances.
        #
        # @param [String, IO] path_or_io The path to a zone file on the
        #   filesystem, or an IO instance from which zone file data can be read.
        #
        def initialize zone, path_or_io
          @zone = zone
          @merged_zf_records = {}
          @records = []
          @zonefile = create_zonefile path_or_io
          merge_zonefile_records
          from_zonefile_records
          @records.unshift soa_record
        end

        ##
        # Returns the Record instances created from the zone file.
        #
        # @param [String, Array<String>] only Include only records of this type
        #   or types.
        # @param [String, Array<String>] except Exclude records of this type or
        #   types.
        #
        # @return [Array<Record>] An array of unsaved {Record} instances
        #
        def records only: nil, except: nil
          ret = @records
          ret = ret.select { |r| Array(only).include? r.type } if only
          ret = ret.reject { |r| Array(except).include? r.type } if except
          ret
        end

        protected

        ##
        # The zonefile library returns a two-element array in which the first
        # element is a symbol type (:a, :mx, and so on), and the second element
        # is an array containing the records of that type. Group the records by
        # name and type instead.
        def merge_zonefile_records
          @zonefile.records.map do |r|
            type = r.first
            type = :aaaa if type == :a4
            r.last.each do |zf_record|
              name = Service.fqdn(zf_record[:name], @zonefile.origin)
              key = [name, type]
              (@merged_zf_records[key] ||= []) << zf_record
            end
          end
        end

        ##
        # Convert the grouped records to single array of records, merging
        # records of the same name and type into a single record with an array
        # of rrdatas.
        def from_zonefile_records
          @records = @merged_zf_records.map do |key, zf_records|
            ttl = ttl_from_zonefile_records zf_records
            data = zf_records.map do |zf_record|
              data_from_zonefile_record(key[1], zf_record)
            end
            @zone.record key[0], key[1], ttl, data
          end
        end

        def soa_record
          zf_soa = @zonefile.soa
          ttl = ttl_to_i(zf_soa[:ttl]) || ttl_to_i(@zonefile.ttl)
          data = data_from_zonefile_record :soa, zf_soa
          @zone.record zf_soa[:origin], "SOA", ttl, data
        end

        ##
        # From a collection of records, take the lowest ttl
        def ttl_from_zonefile_records zf_records
          ttls = zf_records.map do |zf_record|
            ttl_to_i(zf_record[:ttl])
          end
          min_ttl = ttls.compact.sort.first
          min_ttl || ttl_to_i(@zonefile.ttl)
        end

        # rubocop:disable all

        ##
        # Rubocop's line-length and branch condition restrictions prevent
        # the most straightforward approach to converting zonefile's records
        # to our own. So disable rubocop for this operation.
        def data_from_zonefile_record type, zf_record
          case type.to_s.upcase
          when "A"
            String zf_record[:host]
          when "AAAA"
            String zf_record[:host]
          when "CNAME"
            String zf_record[:host]
          when "MX"
            "#{zf_record[:pri]} #{zf_record[:host]}"
          when "NAPTR"
            "#{zf_record[:order]} #{zf_record[:preference]} " \
              "#{zf_record[:flags]} #{zf_record[:service]} " \
              "#{zf_record[:regexp]} #{zf_record[:replacement]}"
          when "NS"
            String zf_record[:host]
          when "PTR"
            String zf_record[:host]
          when "SOA"
            "#{zf_record[:primary]} #{zf_record[:email]} " \
              "#{zf_record[:serial]} #{zf_record[:refresh]} " \
              "#{zf_record[:retry]} #{zf_record[:expire]} " \
              "#{zf_record[:minimumTTL]}"
          when "SPF"
            String zf_record[:data]
          when "SRV"
            "#{zf_record[:pri]} #{zf_record[:weight]} " \
              "#{zf_record[:port]} #{zf_record[:host]}"
          when "TXT"
            String zf_record[:text]
          else
            raise ArgumentError, "record type '#{type}' is not supported"
          end
        end

        # rubocop:enable all

        ##
        # @private
        MULTIPLIER = { "s" => 1,
                       "m" => 60,
                       "h" => (60 * 60),
                       "d" => (60 * 60 * 24),
                       "w" => (60 * 60 * 24 * 7) }.freeze # :nodoc:

        def ttl_to_i ttl
          if ttl.respond_to?(:to_int) || ttl.to_s =~ /\A\d+\z/
            ttl.to_i
          elsif (m = /\A(\d+)(w|d|h|m|s)\z/.match ttl)
            m[1].to_i * MULTIPLIER[m[2]].to_i
          end
        end

        def create_zonefile path_or_io # :nodoc:
          if path_or_io.respond_to? :read
            Zonefile.new path_or_io.read
          else
            Zonefile.from_file path_or_io
          end
        end
      end
    end
  end
end
