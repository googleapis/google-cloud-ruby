# Copyright 2017, Google Inc. All rights reserved.
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


require "google/cloud/firestore/v1beta1"
require "google/cloud/firestore/convert"
require "google/cloud/firestore/collection"

module Google
  module Cloud
    module Firestore
      ##
      # # Query
      #
      class Query
        StructuredQuery = Google::Firestore::V1beta1::StructuredQuery
        ##
        # @private The parent path for the query.
        attr_accessor :parent_path

        ##
        # @private The Google::Firestore::V1beta1::Query object.
        attr_accessor :grpc

        ##
        # @private The connection context object.
        attr_accessor :context

        def select *fields
          fields = fields.flatten.map(&:to_s).reject(&:nil?).reject(&:empty?)
          grpc.select ||= StructuredQuery::Projection.new
          fields.each do |field|
            field = StructuredQuery::FieldReference.new field_path: field.to_s
            grpc.select.fields << field
          end

          self
        end

        def from collection_id
          if grpc.from.any? &&
             grpc.from.last.collection_id == collection_id.to_s
            return self
          end

          # The protobuf structure allows more than one, but the service fails
          # with the following message:
          # StructuredQuery.from cannot have more than one collection selector.
          grpc.from << StructuredQuery::CollectionSelector.new(
            collection_id: collection_id.to_s
          )

          self
        end

        def all_descendants
          if grpc.from.empty?
            fail "must set collection_id using from to specify descendants."
          end

          grpc.from.last.all_descendants = true

          self
        end

        def direct_descendants
          if grpc.from.empty?
            fail "must set collection_id using from to specify descendants."
          end

          grpc.from.last.all_descendants = false

          self
        end

        def where name, operator, value
          grpc.where ||= default_filter
          grpc.where.composite_filter.filters << filter(name, operator, value)

          self
        end

        def order name, direction = :asc
          grpc.order_by << StructuredQuery::Order.new(
            field: StructuredQuery::FieldReference.new(field_path: name.to_s),
            direction: order_direction(direction))

          self
        end

        def offset num
          grpc.offset = num

          self
        end

        def limit num
          grpc.limit = Google::Protobuf::Int32Value.new(value: num)

          self
        end

        def start_at *values
          values = values.flatten.map { |value| Convert.raw_to_value value }
          grpc.start_at = Google::Firestore::V1beta1::Cursor.new(
            values: values, before: true)

          self
        end

        def start_after *values
          values = values.flatten.map { |value| Convert.raw_to_value value }
          grpc.start_at = Google::Firestore::V1beta1::Cursor.new(
            values: values, before: false)

          self
        end

        def end_before *values
          values = values.flatten.map { |value| Convert.raw_to_value value }
          grpc.end_at = Google::Firestore::V1beta1::Cursor.new(
            values: values, before: true)

          self
        end

        def end_at *values
          values = values.flatten.map { |value| Convert.raw_to_value value }
          grpc.end_at = Google::Firestore::V1beta1::Cursor.new(
            values: values, before: false)

          self
        end

        def run &block
          ensure_context!
          context.run(self, &block)
        end
        alias_method :get, :run

        ##
        # @private Start a new Query.
        def self.start parent_path, context
          new.tap do |q|
            q.grpc = Google::Firestore::V1beta1::StructuredQuery.new
            q.parent_path = parent_path
            q.context = context
          end
        end

        protected

        FILTER_OPS = {
          "<"            => :LESS_THAN,
          "lt"           => :LESS_THAN,
          "<="           => :LESS_THAN_OR_EQUAL,
          "lte"          => :LESS_THAN_OR_EQUAL,
          ">"            => :GREATER_THAN,
          "gt"           => :GREATER_THAN,
          ">="           => :GREATER_THAN_OR_EQUAL,
          "gte"          => :GREATER_THAN_OR_EQUAL,
          "="            => :EQUAL,
          "=="           => :EQUAL,
          "eq"           => :EQUAL,
          "eql"          => :EQUAL }
        UNARY_NIL_VALUES = [nil, :null, :nil]
        UNARY_NAN_VALUES = [:nan, Float::NAN]
        UNARY_VALUES = UNARY_NIL_VALUES + UNARY_NAN_VALUES

        def filter name, op, value
          field = StructuredQuery::FieldReference.new field_path: name.to_s
          op = FILTER_OPS[op.to_s.downcase] || :EQUAL

          is_value_nan = value.respond_to?(:nan?) && value.nan?
          if UNARY_VALUES.include?(value) || is_value_nan
            if op != :EQUAL
              fail ArgumentError, "can only check equality for #{value} values."
            end

            op = :IS_NULL
            op = :IS_NAN if UNARY_NAN_VALUES.include?(value) || is_value_nan

            return StructuredQuery::Filter.new(unary_filter:
              StructuredQuery::UnaryFilter.new(field: field, op: op))
          end

          value = Convert.raw_to_value value
          StructuredQuery::Filter.new(field_filter:
              StructuredQuery::FieldFilter.new(field: field, op: op,
                                               value: value))
        end

        def default_filter
          StructuredQuery::Filter.new(composite_filter:
              StructuredQuery::CompositeFilter.new(op: :AND))
        end

        def order_direction direction
          if direction.to_s.downcase.start_with? "a"
            :ASCENDING
          elsif direction.to_s.downcase.start_with? "d"
            :DESCENDING
          else
            :DIRECTION_UNSPECIFIED
          end
        end

        ##
        # @private Raise an error unless context is available.
        def ensure_context!
          fail "Must have active connection to service" unless context
          return unless context.respond_to? :closed?
          self.context = context.database if context.closed?
        end
      end
    end
  end
end
