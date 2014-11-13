# Copyright 2014 Google Inc. All rights reserved.
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

require "gcloud/proto/datastore_v1.pb"

module Gcloud
  module Datastore
    # rubocop:disable all

    ##
    # Proto is the module that contains all Protocol Buffer objects.
    #
    # This module is an implementation detail and as such
    # should not be relied on. It is not part of the public
    # API that gcloud intends to expose. The implementation,
    # and the module's existance, may change without warning.
    module Proto #:nodoc:
      # rubocop:disable all

      def self.from_proto_value proto_value
        if !proto_value.timestamp_microseconds_value.nil?
          microseconds = proto_value.timestamp_microseconds_value
          self.time_from_microseconds microseconds
        elsif !proto_value.key_value.nil?
          Gcloud::Datastore::Key.from_proto(proto_value.key_value)
        elsif !proto_value.boolean_value.nil?
          proto_value.boolean_value
        elsif !proto_value.double_value.nil?
          proto_value.double_value
        elsif !proto_value.integer_value.nil?
          proto_value.integer_value
        elsif !proto_value.string_value.nil?
          return proto_value.string_value
        else
          nil
        end # TODO: blob? Entity?
      end

      def self.to_proto_value value
        v = Gcloud::Datastore::Proto::Value.new
        if Time === value
          v.timestamp_microseconds_value = self.microseconds_from_time value
        elsif Gcloud::Datastore::Key === value
          v.key_value = value.to_proto
        elsif TrueClass === value
          v.boolean_value = true
        elsif FalseClass === value
          v.boolean_value = false
        elsif Float === value
          v.double_value = value
        elsif defined?(BigDecimal) && BigDecimal === value
          v.double_value = value
        elsif Integer === value
          v.integer_value = value
        elsif String === value
          v.string_value = value
        end # TODO: entity, blob_value, blob_key_value, list_value
        v
      end

      def self.microseconds_from_time time
        (time.utc.to_f * 1000000).to_i
      end

      def self.time_from_microseconds microseconds
        Time.at(microseconds / 1000000, microseconds % 1000000).utc
      end

      #:nodoc:
      PROP_FILTER_OPS = {
        "<"   => PropertyFilter::Operator::LESS_THAN,
        "lt"  => PropertyFilter::Operator::LESS_THAN,
        "<="  => PropertyFilter::Operator::LESS_THAN_OR_EQUAL,
        "lte" => PropertyFilter::Operator::LESS_THAN_OR_EQUAL,
        ">"   => PropertyFilter::Operator::GREATER_THAN,
        "gt"  => PropertyFilter::Operator::GREATER_THAN,
        ">="  => PropertyFilter::Operator::GREATER_THAN_OR_EQUAL,
        "gte" => PropertyFilter::Operator::GREATER_THAN_OR_EQUAL,
        "="   => PropertyFilter::Operator::EQUAL,
        "eq"  => PropertyFilter::Operator::EQUAL,
        "eql" => PropertyFilter::Operator::EQUAL,
        "~"            => PropertyFilter::Operator::HAS_ANCESTOR,
        "~>"           => PropertyFilter::Operator::HAS_ANCESTOR,
        "ancestor"     => PropertyFilter::Operator::HAS_ANCESTOR,
        "has_ancestor" => PropertyFilter::Operator::HAS_ANCESTOR,
        "has ancestor" => PropertyFilter::Operator::HAS_ANCESTOR }

      def self.to_prop_filter_op str
        PROP_FILTER_OPS[str.to_s.downcase] ||
        PropertyFilter::Operator::EQUAL
      end

      def self.to_prop_order_direction direction
        if direction.to_s.downcase.start_with? "d"
          PropertyOrder::Direction::DESCENDING
        else
          PropertyOrder::Direction::ASCENDING
        end
      end

      def self.encode_cursor cursor
        Array(cursor.to_s).pack("m").chomp
      end

      def self.decode_cursor cursor
        dc = cursor.to_s.unpack("m").first.force_encoding Encoding::ASCII_8BIT
        dc = nil if dc.empty?
        dc
      end
    end
    # rubocop:enable all
  end
end
