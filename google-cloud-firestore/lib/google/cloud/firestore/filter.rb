# Copyright 2023 Google LLC
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


require "google/cloud/firestore/v1"
require "google/cloud/firestore/document_snapshot"
require "google/cloud/firestore/query_listener"
require "google/cloud/firestore/convert"
require "google/cloud/firestore/aggregate_query"
require "json"

module Google
  module Cloud
    module Firestore
      class Filter
        ##
        # @private Object of type
        # Google::Cloud::Firestore::V1::StructuredQuery::Filter
        attr_accessor :filter

        ##
        # @private Creates a new Filter.
        def initialize filter
          @filter = filter
        end

        ##
        # Filters the query on a field.
        #
        # @param [Object] args
        #
        #   If a {FieldPath} object is not provided then the field will be
        #   treated as a dotted string, meaning the string represents individual
        #   fields joined by ".". Fields containing `~`, `*`, `/`, `[`, `]`, and
        #   `.` cannot be in a dotted string, and should provided using a
        #   {FieldPath} object instead.
        # @param [String, Symbol] operator The operation to compare the field
        #   to. Acceptable values include:
        #
        #   * less than: `<`, `lt`
        #   * less than or equal: `<=`, `lte`
        #   * greater than: `>`, `gt`
        #   * greater than or equal: `>=`, `gte`
        #   * equal: `=`, `==`, `eq`, `eql`, `is`
        #   * not equal: `!=`
        #   * in: `in`
        #   * not in: `not-in`, `not_in`
        #   * array contains: `array-contains`, `array_contains`
        # @param [Object] value A value the field is compared to.
        #
        # @return [Google::Cloud::Firestore::Filter] New filter for the given condition
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Create a Filter
        #   Google::Cloud::Firestore::Filter.create(:population, :>=, 1000000)
        #
        def and *args
          if args.length == 1
            Filter.and_all self, *args
          else
            Filter.and_all self, args
          end
        end

        def or *args
          if args.length == 1
            Filter.or_all self, *args
          else
            Filter.or_all self, args
          end
        end

        ##
        # Create a Filter object.
        #
        # @param [FieldPath, String, Symbol] field A field path to filter
        #   results with.
        #
        #   If a {FieldPath} object is not provided then the field will be
        #   treated as a dotted string, meaning the string represents individual
        #   fields joined by ".". Fields containing `~`, `*`, `/`, `[`, `]`, and
        #   `.` cannot be in a dotted string, and should provided using a
        #   {FieldPath} object instead.
        # @param [String, Symbol] operator The operation to compare the field
        #   to. Acceptable values include:
        #
        #   * less than: `<`, `lt`
        #   * less than or equal: `<=`, `lte`
        #   * greater than: `>`, `gt`
        #   * greater than or equal: `>=`, `gte`
        #   * equal: `=`, `==`, `eq`, `eql`, `is`
        #   * not equal: `!=`
        #   * in: `in`
        #   * not in: `not-in`, `not_in`
        #   * array contains: `array-contains`, `array_contains`
        # @param [Object] value A value the field is compared to.
        #
        # @return [Google::Cloud::Firestore::Filter] New filter for the given condition
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Create a Filter
        #   Google::Cloud::Firestore::Filter.create(:population, :>=, 1000000)
        #
        def self.create field, operator, value
          new create_filter(field, operator, value)
        end

        def self.and_all *args
          new insert_in_composite_filter(composite_filter_and, args)
        end

        def self.or_all *args
          new insert_in_composite_filter(composite_filter_or, args)
        end

        ##
        # @private
        StructuredQuery = Google::Cloud::Firestore::V1::StructuredQuery

        ##
        # @private
        FILTER_OPS = {
          "<"                  => :LESS_THAN,
          "lt"                 => :LESS_THAN,
          "<="                 => :LESS_THAN_OR_EQUAL,
          "lte"                => :LESS_THAN_OR_EQUAL,
          ">"                  => :GREATER_THAN,
          "gt"                 => :GREATER_THAN,
          ">="                 => :GREATER_THAN_OR_EQUAL,
          "gte"                => :GREATER_THAN_OR_EQUAL,
          "="                  => :EQUAL,
          "=="                 => :EQUAL,
          "eq"                 => :EQUAL,
          "eql"                => :EQUAL,
          "is"                 => :EQUAL,
          "!="                 => :NOT_EQUAL,
          "array_contains"     => :ARRAY_CONTAINS,
          "array-contains"     => :ARRAY_CONTAINS,
          "include"            => :ARRAY_CONTAINS,
          "include?"           => :ARRAY_CONTAINS,
          "has"                => :ARRAY_CONTAINS,
          "in"                 => :IN,
          "not_in"             => :NOT_IN,
          "not-in"             => :NOT_IN,
          "array_contains_any" => :ARRAY_CONTAINS_ANY,
          "array-contains-any" => :ARRAY_CONTAINS_ANY
        }.freeze
        ##
        # @private
        INEQUALITY_FILTERS = [
          :LESS_THAN,
          :LESS_THAN_OR_EQUAL,
          :GREATER_THAN,
          :GREATER_THAN_OR_EQUAL
        ].freeze

        def self.composite_filter_and
          StructuredQuery::Filter.new(
            composite_filter: StructuredQuery::CompositeFilter.new(op: :AND)
          )
        end

        def self.composite_filter_or
          StructuredQuery::Filter.new(
            composite_filter: StructuredQuery::CompositeFilter.new(op: :OR)
          )
        end

        def self.insert_in_composite_filter composite_filter, args
          args.each do |filter|
            case filter
            when Google::Cloud::Firestore::Filter
              composite_filter.composite_filter.filters << filter.filter
            when Array
              composite_filter.composite_filter.filters << create_filter(*filter)
            else
              # Raise a error for incorrect input
              puts "Error should be raised in this case"
            end
          end
          composite_filter
        end

        def self.value_nil? value
          [nil, :null, :nil].include? value
        end

        def self.value_nan? value
          # Comparing NaN values raises, so check for #nan? first.
          return true if value.respond_to?(:nan?) && value.nan?
          [:nan].include? value
        end

        def self.value_unary? value
          value_nil?(value) || value_nan?(value)
        end

        def self.create_filter field, op_key, value
          field = FieldPath.parse field unless field.is_a? FieldPath
          field = StructuredQuery::FieldReference.new field_path: field.formatted_string.to_s
          operator = FILTER_OPS[op_key.to_s.downcase]
          raise ArgumentError, "unknown operator #{op_key}" if operator.nil?

          if value_unary? value
            operator = case operator
                       when :EQUAL
                         value_nan?(value) ? :IS_NAN : :IS_NULL
                       when :NOT_EQUAL
                         value_nan?(value) ? :IS_NOT_NAN : :IS_NOT_NULL
                       else
                         raise ArgumentError, "can only perform '==' and '!=' comparisons on #{value} values"
                       end

            return StructuredQuery::Filter.new(
              unary_filter: StructuredQuery::UnaryFilter.new(
                field: field, op: operator
              )
            )
          end

          value = Convert.raw_to_value value
          StructuredQuery::Filter.new(
            field_filter: StructuredQuery::FieldFilter.new(
              field: field, op: operator, value: value
            )
          )
        end
      end
    end
  end
end
