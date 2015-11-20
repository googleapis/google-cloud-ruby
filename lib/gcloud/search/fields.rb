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

require "gcloud/search/field_values"
require "gcloud/search/field_value"

module Gcloud
  module Search
    # rubocop:disable Metrics/LineLength
    # Disabled because there are links in the docs that are long.

    ##
    # = Fields
    #
    # A field can have multiple values with same or different types; however, it
    # cannot have multiple Timestamp or number values.
    #
    # For more information see {Documents and
    # fields}[https://cloud.google.com/search/documents_indexes#documents_and_fields].
    #
    class Fields
      include Enumerable

      def initialize #:nodoc:
        @hash = {}
      end

      def [] name
        @hash[name] ||= FieldValues.new name
      end

      def add name, value, options = {}
        @hash[name] ||= FieldValues.new name
        @hash[name].add value, options
      end

      def delete key, &block
        @hash.delete key, &block
      end

      def each &block
        # Only yield keys that have values.
        fields_with_values.each(&block)
      end

      def each_pair &block
        # Only yield pairs that have values.
        fields_with_values.each_pair(&block)
      end

      def keys
        # Only return keys that have values.
        fields_with_values.keys
      end

      def self.from_raw raw #:nodoc:
        hsh = {}
        raw.each_pair do |k, v|
          hsh[k] = FieldValues.from_raw k, v["values"]
        end
        fields = new
        fields.instance_variable_set "@hash", hsh
        fields
      end

      def to_raw #:nodoc:
        hsh = {}
        @hash.each_pair do |k, v|
          hsh[k] = v.to_raw unless v.empty?
        end
        hsh
      end

      protected

      def fields_with_values
        @hash.select { |_name, values| values.any? }
      end
    end
  end
end
