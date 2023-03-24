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

module Google
  module Cloud
    module Firestore
      ##
      # Represents the filter for structured query.
      #
      class Filter
        ##
        # @private Object of type
        # Google::Cloud::Firestore::V1::StructuredQuery::Filter
        attr_accessor :filter

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
        def initialize field, operator, value
          @filter = create_filter field, operator, value
        end

        ##
        # Joins filter using AND operator.
        #
        # @overload and(filter)
        #
        #   @param [::Google::Cloud::Firestore::Filter] filter
        #
        # @overload and(field, operator, value)
        #
        #    @param [FieldPath, String, Symbol] filter_or_field A field path to filter
        #     results with.
        #
        #     If a {FieldPath} object is not provided then the field will be
        #     treated as a dotted string, meaning the string represents individual
        #     fields joined by ".". Fields containing `~`, `*`, `/`, `[`, `]`, and
        #     `.` cannot be in a dotted string, and should provided using a
        #     {FieldPath} object instead.
        #    @param [String, Symbol] operator The operation to compare the field
        #     to. Acceptable values include:
        #
        #     * less than: `<`, `lt`
        #     * less than or equal: `<=`, `lte`
        #     * greater than: `>`, `gt`
        #     * greater than or equal: `>=`, `gte`
        #     * equal: `=`, `==`, `eq`, `eql`, `is`
        #     * not equal: `!=`
        #     * in: `in`
        #     * not in: `not-in`, `not_in`
        #     * array contains: `array-contains`, `array_contains`
        #    @param [Object] value A value the field is compared to.
        #
        # @return [Filter] New Filter object.
        #
        # @example Pass a Filter type object in argument
        #   require "google/cloud/firestore"
        #
        #   filter_1 = Google::Cloud::Firestore.Firestore.new(:population, :>=, 1000000)
        #   filter_2 = Google::Cloud::Firestore.Firestore.new("done", "=", "false")
        #
        #   filter = filter_1.and(filter_2)
        #
        # @example Pass filter conditions in the argument
        #   require "google/cloud/firestore"
        #
        #   filter_1 = Google::Cloud::Firestore.Firestore.new(:population, :>=, 1000000)
        #
        #   filter = filter_1.and("done", "=", "false")
        #
        def and *args
          join_filters composite_filter_and, args
        end

        ##
        # Joins filter using OR operator.
        #
        # @overload and(filter)
        #
        #   @param [::Google::Cloud::Firestore::Filter] filter
        #
        # @overload and(field, operator, value)
        #
        #    @param [FieldPath, String, Symbol] filter_or_field A field path to filter
        #     results with.
        #
        #     If a {FieldPath} object is not provided then the field will be
        #     treated as a dotted string, meaning the string represents individual
        #     fields joined by ".". Fields containing `~`, `*`, `/`, `[`, `]`, and
        #     `.` cannot be in a dotted string, and should provided using a
        #     {FieldPath} object instead.
        #    @param [String, Symbol] operator The operation to compare the field
        #     to. Acceptable values include:
        #
        #     * less than: `<`, `lt`
        #     * less than or equal: `<=`, `lte`
        #     * greater than: `>`, `gt`
        #     * greater than or equal: `>=`, `gte`
        #     * equal: `=`, `==`, `eq`, `eql`, `is`
        #     * not equal: `!=`
        #     * in: `in`
        #     * not in: `not-in`, `not_in`
        #     * array contains: `array-contains`, `array_contains`
        #    @param [Object] value A value the field is compared to.
        #
        # @return [Filter] New Filter object.
        #
        # @example Pass a Filter type object in argument
        #   require "google/cloud/firestore"
        #
        #   filter_1 = Google::Cloud::Firestore.Firestore.new(:population, :>=, 1000000)
        #   filter_2 = Google::Cloud::Firestore.Firestore.new("done", "=", "false")
        #
        #   filter = filter_1.or(filter_2)
        #
        # @example Pass filter conditions in the argument
        #   require "google/cloud/firestore"
        #
        #   filter_1 = Google::Cloud::Firestore.Firestore.new(:population, :>=, 1000000)
        #
        #   filter = filter_1.or("done", "=", "false")
        #
        def or *args
          join_filters composite_filter_or, args
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

        def composite_filter_and
          StructuredQuery::Filter.new(
            composite_filter: StructuredQuery::CompositeFilter.new(op: :AND)
          )
        end

        def composite_filter_or
          StructuredQuery::Filter.new(
            composite_filter: StructuredQuery::CompositeFilter.new(op: :OR)
          )
        end

        def join_filters composite_filter, sec_filter
          composite_filter.composite_filter.filters << @filter
          if (sec_filter.length == 1) && sec_filter[0].is_a?(Google::Cloud::Firestore::Filter)
            composite_filter.composite_filter.filters << sec_filter[0].filter
          else
            composite_filter.composite_filter.filters << create_filter(*sec_filter)
          end
          Filter.new(nil, nil, nil).tap do |f|
            f.filter = composite_filter
          end
        end

        def value_nil? value
          [nil, :null, :nil].include? value
        end

        def value_nan? value
          # Comparing NaN values raises, so check for #nan? first.
          return true if value.respond_to?(:nan?) && value.nan?
          [:nan].include? value
        end

        def value_unary? value
          value_nil?(value) || value_nan?(value)
        end

        def create_filter field, op_key, value
          return if field.nil? && op_key.nil? && value.nil?
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
