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
require "gcloud/search/connection"
require "gcloud/search/credentials"
require "gcloud/search/index"
require "gcloud/search/errors"

module Gcloud
  module Search
    # rubocop:disable all
    # Disabled because there are links in the docs that are long, and a long
    # if/else chain.

    ##
    # = Fields
    #
    # A field can have multiple values with same or different types; however, it
    # cannot have multiple Timestamp or number values.
    #
    # For more information see {Documents and
    # fields}[https://cloud.google.com/search/documents_indexes#documents_and_fields].
    #
    class Fields < DelegateClass(::Hash)
      def initialize raw = {}
        super from_raw(raw)
      end

      def to_raw
        hsh = {}
        each_pair do |k, v|
          hsh[k] = to_raw_values(v)
        end
        hsh
      end

      protected

      def from_raw raw
        hsh = {}
        raw.each_pair do |k, v|
          hsh[k] = from_raw_values(v).first
        end
        hsh
      end

      def from_raw_values raw_field
        values = []
        raw_field["values"].each do |v|
          values << if v["stringValue"]
                      type = v["stringFormat"].downcase.to_sym
                      StringValue.new values, v["stringValue"], type, v["lang"]
                    elsif v["timestampValue"]
                      datetime = DateTime.rfc3339 v["timestampValue"]
                      TimestampValue.new values, datetime
                    elsif v["geoValue"]
                      GeoValue.new values, v["geoValue"]
                    elsif v["numberValue"]
                      NumberValue.new values, v["numberValue"]
                    end
        end
        values
      end

      def to_raw_values field
        raw_values = field.values.map do |v|
          case v.type
          when :atom, :default, :html, :text
            to_raw_string v
          when :geo
            to_raw_geo v
          when :number
            to_raw_number v
          when :timestamp
            to_raw_timestamp v
          end
        end
        {
          "values" => raw_values
        }
      end

      def to_raw_string v
        {
          "stringFormat" => v.type.to_s.upcase,
          "lang" => v.lang,
          "stringValue" => v
        }
      end

      def to_raw_geo v
        {
          "geoValue" => "#{v.latitude}, #{v.longitude}"
        }
      end

      def to_raw_number v
        numeric = v.is_a?(Integer) ? v.to_i : v.to_f
        {
          "numberValue" => numeric
        }
      end

      def to_raw_timestamp v
        {
          "timestampValue" => v.rfc3339
        }
      end
    end
    # rubocop:enable all

    ##
    # Extends DateTime with :values, :type readers
    class GeoValue
      attr_reader :latitude, :longitude, :values, :type

      def initialize values, v
        latlon = v.split(",").map(&:strip)
        fail "Invalid geo string" unless latlon.size == 2
        @latitude = latlon[0].to_f
        @longitude = latlon[1].to_f
        @values = values
        @type = :geo
      end

      def inspect
        "GeoValue(#{latitude},#{longitude})"
      end
    end

    ##
    # Extends Numeric with :values, :type readers
    class NumberValue < DelegateClass(::Numeric)
      attr_reader :values, :type, :lang

      def initialize values, v
        super v
        @values = values
        @type = :number
      end
    end

    ##
    # Extends String with :values, :type, :lang readers
    class StringValue < DelegateClass(::String)
      attr_reader :values, :type, :lang

      def initialize values, v, type, lang
        super v
        @values = values
        @type = type
        @lang = lang
      end
    end

    ##
    # Extends DateTime with :values, :type readers
    #
    # Timestamp is a JSON string following RFC 3339, where generated output will
    # always be Z-normalized and uses 3, 6, or 9 fractional digits depending on
    # required precision.
    class TimestampValue < DelegateClass(::DateTime)
      attr_reader :values, :type

      def initialize values, v
        super v
        @values = values
        @type = :timestamp
      end
    end
  end
end
