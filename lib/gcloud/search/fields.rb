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
      def initialize hash = {}
        super extract_fields(hash["fields"])
      end

      protected

      def extract_fields raw_fields
        hsh = {}
        raw_fields.each_pair do |k, v|
          hsh[k] = extract_values(v).first
        end
        hsh
      end

      def extract_values raw_field
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
        values.freeze
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
