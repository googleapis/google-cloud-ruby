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


require "time"
require "stringio"

module Google
  module Cloud
    module Firestore
      ##
      # @private Helper module for converting Protobuf values.
      module Convert
        module ClassMethods
          # rubocop:disable all

          def time_to_timestamp time
            return nil if time.nil?

            # Force the object to be a Time object.
            time = time.to_time

            Google::Protobuf::Timestamp.new \
              seconds: time.to_i,
              nanos: time.nsec
          end

          def timestamp_to_time timestamp
            return nil if timestamp.nil?

            Time.at timestamp.seconds, Rational(timestamp.nanos, 1000)
          end

          def fields_to_hash fields, context
            Hash[fields.map do |key, value|
              [key.to_sym, value_to_raw(value, context)]
            end]
          end

          def hash_to_fields hash
            Hash[hash.map do |key, value|
              [String(key), raw_to_value(value)]
            end]
          end

          def value_to_raw value, context
            case value.value_type
            when :null_value
              nil
            when :boolean_value
              value.boolean_value
            when :integer_value
              Integer value.integer_value
            when :double_value
              value.double_value
            when :timestamp_value
              timestamp_to_time value.timestamp_value
            when :string_value
              value.string_value
            when :bytes_value
              StringIO.new Base64.decode64 value.bytes_value
            when :reference_value
              Google::Cloud::Firestore::Document.from_path \
                value.reference_value, context
            when :geo_point_value
              value.geo_point_value.to_hash
            when :array_value
              value.array_value.values.map { |v| value_to_raw v, context }
            when :map_value
              fields_to_hash value.map_value.fields, context
            end
          end

          def raw_to_value obj
            if NilClass === obj
              Google::Firestore::V1beta1::Value.new null_value: :NULL_VALUE
            elsif TrueClass === obj || FalseClass === obj
              Google::Firestore::V1beta1::Value.new boolean_value: obj
            elsif Integer === obj
              Google::Firestore::V1beta1::Value.new integer_value: obj
            elsif Numeric === obj # Any number not an integer is a double
              Google::Firestore::V1beta1::Value.new double_value: obj.to_f
            elsif Time === obj || DateTime === obj || Date === obj
              Google::Firestore::V1beta1::Value.new \
                timestamp_value: time_to_timestamp(obj.to_time)
            elsif String === obj || Symbol === obj
              Google::Firestore::V1beta1::Value.new string_value: obj.to_s
            elsif Google::Cloud::Firestore::Document::Reference === obj
              Google::Firestore::V1beta1::Value.new reference_value: obj.path
            elsif Array === obj
              values = obj.map { |o| raw_to_value(o) }
              Google::Firestore::V1beta1::Value.new(array_value:
                Google::Firestore::V1beta1::ArrayValue.new(values: values))
            elsif Hash === obj
              if obj.keys.sort == [:latitude, :longitude]
                Google::Firestore::V1beta1::Value.new(geo_point_value:
                  Google::Type::LatLng.new(obj))
              else
                fields = hash_to_fields obj
                Google::Firestore::V1beta1::Value.new(map_value:
                  Google::Firestore::V1beta1::MapValue.new(fields: fields))
              end
            elsif obj.respond_to?(:read) && obj.respond_to?(:rewind)
              obj.rewind
              content = obj.read.force_encoding "ASCII-8BIT"
              encoded_content = Base64.strict_encode64 content
              Google::Firestore::V1beta1::Value.new bytes_value: encoded_content
            else
              fail ArgumentError,
                   "A value of type #{obj.class} is not supported."
            end
          end

          def is_nested obj, target
            return true if obj == target

            if obj.is_a? Array
              obj.each { |o| val = is_nested o, target; return true if val }
            elsif obj.is_a? Hash
              obj.each { |_k, v| val = is_nested v, target; return true if val }
            end
            false
          end

          def remove_from obj, target
            return [nil, []] unless obj.is_a? Hash

            paths = []
            new_pairs = obj.map do |key, value|
              if value == target
                paths << key
                nil # will be removed by calling compact
              elsif value.is_a? Hash
                nested_hash, nested_paths = remove_from value, target
                if nested_paths.any?
                  nested_paths.each do |nested_path|
                    paths << "#{escape_field_path(key)}.#{nested_path}"
                  end
                end
                if nested_hash.empty?
                  nil # will be removed by calling compact
                else
                  [String(key), nested_hash]
                end
              else
                if value.is_a? Array
                  if is_nested value, target
                    raise ArgumentError, "cannot nest #{target} under arrays"
                  end
                end

                [String(key), value]
              end
            end

            # return a new hash and paths
            [Hash[new_pairs.compact], paths]
          end

          def extract_leaf_nodes hash
            paths = []

            hash.map do |key, value|
              if value.is_a? Hash
                nested_paths = extract_leaf_nodes value
                nested_paths.each do |nested_path|
                  paths << "#{escape_field_path(key)}.#{nested_path}"
                end
              else
                paths << escape_field_path(key)
              end
            end

            paths
          end

          def select_by_field_paths hash, field_paths
            new_hash = {}
            field_paths.map do |field_path|
              selected_hash = select_field_path hash, field_path
              # new_hash = deep_merge_hashes new_hash, selected_hash
              deep_merge_hashes new_hash, selected_hash
            end
            new_hash
          end

          def select_field_path hash, field_path
            ret_hash = {}
            tmp_hash = ret_hash
            prev_hash = ret_hash
            dup_hash = hash.dup
            nodes = unescape_field_path field_path
            last_node = nil
            nodes.each do |node|
              prev_hash[last_node] = tmp_hash unless last_node.nil?
              last_node = node
              tmp_hash[node] = {}
              prev_hash = tmp_hash
              tmp_hash = tmp_hash[node]
              dup_hash = dup_hash[node]
            end
            prev_hash[last_node] = dup_hash
            ret_hash
          end

          def deep_merge_hashes left_hash, right_hash
            right_hash.each_pair do |key, right_value|
              left_value = left_hash[key]

              if left_value.is_a?(Hash) && right_value.is_a?(Hash)
                left_hash[key] = deep_merge_hashes left_value, right_value
              else
                left_hash[key] = right_value
              end
            end

            left_hash
          end

          def extract_field_paths hash
            invalid_field_path_chars = /[\~\*\/\[\]]/

            dup_hash = {}
            hash.each do |keys, value|
              tmp_dup = dup_hash
              last_key = nil
              keys.to_s.split(".").each do |key|
                raise ArgumentError, "empty paths not allowed" if key.empty?
                if invalid_field_path_chars.match key
                  raise ArgumentError, "invalid character"
                end
                tmp_dup = tmp_dup[last_key] unless last_key.nil?
                last_key = key
                if !tmp_dup[key].nil?
                  raise ArgumentError, "one field cannot be a prefix of another"
                end
                tmp_dup[key] = {}
              end
              tmp_dup[last_key] = hash[keys]
            end
            dup_hash
          end

          def escape_field_path str
            str = String(str)
            return str if str =~ /\A[a-zA-Z_]/

            "`#{str}`"
          end

          # returns an array of nodes
          def unescape_field_path str
            String(str).split(".").map do |node|
              unescape_field_node node
            end
          end

          def unescape_field_node str
            escaped_field_path_regexp = /\A\`(.*)\`\z/
            match = escaped_field_path_regexp.match str
            return match[1] if match
            str
          end

          # rubocop:enable all
        end

        extend ClassMethods
      end
    end
  end
end
