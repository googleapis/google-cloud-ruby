
# Copyright 2017 Google LLC
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

  def initialize filter
    @filter = filter
  end

  def and filters
    filter.unshift @filter
    filter = insert_in_composite_filter composite_filter_and, filters
    new filter
  end

  def or filters
    filter = insert_in_composite_filter composite_filter_or, filters
    new filter
  end

  def self.filter field, operator, value
    new create_filter(field, operator, value)
  end

  def self.and filters
    filter = insert_in_composite_filter composite_filter_and, filters
    new filter
  end

  def self.or filters
    filter = insert_in_composite_filter composite_filter_or, filters
    new filter
  end

  protected

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

  def insert_in_composite_filter composite_filter, filters
    filters.each do |filter|
      if filter.is_a? Filter
        composite_filter.composite_filter.filters << filter.filter
      end
    end
    composite_filter
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
