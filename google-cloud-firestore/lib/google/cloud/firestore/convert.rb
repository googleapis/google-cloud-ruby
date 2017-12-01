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
        # rubocop:disable all
        module ClassMethods
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

          def create_writes doc_path, data
            writes = []

            if is_nested data, :DELETE
              fail ArgumentError, "DELETE not allowed on create"
            end
            fail ArgumentError, "data must be a Hash" unless data.is_a? Hash

            data, server_time_paths = remove_from data, :SERVER_TIME

            if data.any? || server_time_paths.empty?
              write = Google::Firestore::V1beta1::Write.new(
                update: Google::Firestore::V1beta1::Document.new(
                  name: doc_path,
                  fields: hash_to_fields(data)),
                current_document: Google::Firestore::V1beta1::Precondition.new(
                  exists: false)
              )
              writes << write
            end

            if server_time_paths.any?
              transform_write = transform_write doc_path, server_time_paths

              if data.empty?
                transform_write.current_document = \
                  Google::Firestore::V1beta1::Precondition.new(exists: false)
              end

              writes << transform_write
            end

            writes
          end

          def set_writes doc_path, data, merge: nil
            writes = []

            fail ArgumentError, "data must be a Hash" unless data.is_a? Hash

            data, delete_paths = remove_from data, :DELETE
            fail ArgumentError, "DELETE not allowed on set" if delete_paths.any?

            data, server_time_paths = remove_from data, :SERVER_TIME

            write = Google::Firestore::V1beta1::Write.new(
              update: Google::Firestore::V1beta1::Document.new(
                name: doc_path,
                fields: hash_to_fields(data))
            )

            if merge
              if merge == true
                # extract the leaf node field paths from data
                field_paths = identify_leaf_nodes data
              else
                field_paths = format_merge_field_paths merge
              end

              # Ensure provided field paths are valid.
              all_valid = identify_leaf_nodes data
              verify_paths = field_paths - server_time_paths
              all_valid_check = verify_paths.map do |verify_path|
                all_valid.include?(verify_path) ||
                all_valid.select { |fp| fp.start_with? "#{verify_path}." }.any?
              end
              all_valid_check = all_valid_check.include? false
              fail ArgumentError, "all fields must be in data" if all_valid_check

              # Choose only the data there are field paths for
              data = select_by_field_paths data, verify_paths

              if data.empty?
                if merge == true && server_time_paths.empty?
                  fail ArgumentError, "data required for merge: true"
                end
                write = nil
              else
                write = Google::Firestore::V1beta1::Write.new(
                  update: Google::Firestore::V1beta1::Document.new(
                    name: doc_path,
                    fields: hash_to_fields(data)),
                  update_mask: Google::Firestore::V1beta1::DocumentMask.new(
                    field_paths: field_paths)
                )
              end
            end

            writes << write if write

            if server_time_paths.any?
              transform_write = transform_write doc_path, server_time_paths
              writes << transform_write
            end

            writes
          end

          def update_writes doc_path, data, update_time: nil
            writes = []

            fail ArgumentError, "data must be a Hash" unless data.is_a? Hash

            data, delete_paths = remove_from data, :DELETE, recurse: false
            data, nested_deletes = remove_from data, :DELETE
            fail ArgumentError, "DELETE cannot be nested" if nested_deletes.any?

            data, root_server_time_paths = remove_from data, :SERVER_TIME, recurse: false
            data, nested_server_time_paths = remove_from data, :SERVER_TIME
            server_time_paths = root_server_time_paths + nested_server_time_paths

            field_paths = data.keys.map(&:to_s).map do |path|
              path.split(".").map { |p| escape_field_path p }.join(".")
            end

            # extract data after building field paths
            data, field_paths = extract_field_paths data
            field_paths += delete_paths

            if data.empty? && delete_paths.empty? && server_time_paths.empty?
              fail ArgumentError, "data is required"
            end

            if data.any? || delete_paths.any?
              write = Google::Firestore::V1beta1::Write.new(
                update: Google::Firestore::V1beta1::Document.new(
                  name: doc_path,
                  fields: hash_to_fields(data)),
                update_mask: Google::Firestore::V1beta1::DocumentMask.new(
                  field_paths: field_paths),
                current_document: Google::Firestore::V1beta1::Precondition.new(
                  exists: true)
              )
              if update_time
                write.current_document = \
                  Google::Firestore::V1beta1::Precondition.new(
                    update_time: time_to_timestamp(update_time))
              end
              writes << write
            end

            if server_time_paths.any?
              transform_write = transform_write doc_path, server_time_paths
              if data.empty?
                transform_write.current_document = \
                  Google::Firestore::V1beta1::Precondition.new(exists: true)
              end
              writes << transform_write
            end

            writes
          end

          def delete_write doc_path, exists: nil, update_time: nil
            if !exists.nil? && !update_time.nil?
              fail ArgumentError, "cannot specify both exists and update_time"
            end

            write = Google::Firestore::V1beta1::Write.new(
              delete: doc_path
            )

            unless exists.nil? && update_time.nil?
              write.current_document = \
                Google::Firestore::V1beta1::Precondition.new({
                  exists: exists, update_time: time_to_timestamp(update_time)
                }.delete_if { |_, v| v.nil? })
            end

            write
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

          def remove_from obj, target, recurse: true
            return [nil, []] unless obj.is_a? Hash

            paths = []
            new_pairs = obj.map do |key, value|
              if value == target
                if recurse
                  # escape when recursing
                  paths << escape_field_path(key)
                else
                  # don't escape when recursing
                  paths << String(key)
                end
                nil # will be removed by calling compact
              elsif recurse
                if value.is_a? Hash
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
                      fail ArgumentError, "cannot nest #{target} under arrays"
                    end
                  end

                  [String(key), value]
                end
              else # no recurse
                [String(key), value]
              end
            end

            # return a new hash and paths
            [Hash[new_pairs.compact], paths]
          end

          def identify_leaf_nodes hash
            paths = []

            hash.map do |key, value|
              if value.is_a? Hash
                nested_paths = identify_leaf_nodes value
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

          START_FIELD_PATH_CHARS = /\A[a-zA-Z_]/
          INVALID_FIELD_PATH_CHARS = /[\~\*\.\/\[\]]/
          ESCAPED_FIELD_PATH = /\A\`(.*)\`\z/

          def extract_field_paths hash
            field_paths = hash.keys.map do |path|
              path.split(".").map { |p| escape_field_path p }.join(".")
            end

            dup_hash = {}
            hash.each do |keys, value|
              tmp_dup = dup_hash
              last_key = nil
              keys.to_s.split(".").each do |key|
                fail ArgumentError, "empty paths not allowed" if key.empty?
                if INVALID_FIELD_PATH_CHARS.match key
                  fail ArgumentError, "invalid character"
                end
                tmp_dup = tmp_dup[last_key] unless last_key.nil?
                last_key = key
                if !tmp_dup[key].nil?
                  fail ArgumentError, "one field cannot be a prefix of another"
                end
                tmp_dup[key] = {}
              end
              tmp_dup[last_key] = hash[keys]
            end
            [dup_hash, field_paths]
          end

          def escape_field_path str
            str = String str

            return "`#{str}`" if INVALID_FIELD_PATH_CHARS.match str
            return str if START_FIELD_PATH_CHARS.match str

            "`#{str}`"
          end

          # returns an array of nodes
          def unescape_field_path str
            String(str).split(".").map do |node|
              unescape_field_node node
            end
          end

          def unescape_field_node str
            match = ESCAPED_FIELD_PATH.match str
            return match[1] if match
            str
          end

          def format_merge_field_paths merge
            Array(merge).map do |inner_field_path|
              if inner_field_path.is_a? Array
                paths = inner_field_path.map do |field_path|
                  escape_field_path field_path
                end
                paths.join "."
              else
                String inner_field_path
              end
            end
          end

          def transform_write doc_path, paths, server_value: :REQUEST_TIME
            field_transforms = paths.map do |path|
              Google::Firestore::V1beta1::DocumentTransform::FieldTransform.new(
                field_path: path,
                set_to_server_value: server_value
              )
            end

            Google::Firestore::V1beta1::Write.new(
              transform: Google::Firestore::V1beta1::DocumentTransform.new(
                document: doc_path,
                field_transforms: field_transforms
              )
            )
          end
        end
        # rubocop:enable all

        extend ClassMethods
      end
    end
  end
end
