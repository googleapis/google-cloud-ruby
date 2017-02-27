# Copyright 2017 Google Inc. All rights reserved.
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


require "google/apis/bigquery_v2"
require "stringio"
require "base64"
require "time"
require "date"

module Google
  module Cloud
    module Bigquery
      # rubocop:disable all

      ##
      # @private
      #
      # Internal conversion of raw data values to/from Bigquery values
      #
      # | BigQuery    | Ruby           | Notes  |
      # |-------------|----------------|---|
      # | `BOOL`      | `true`/`false` | |
      # | `INT64`     | `Integer`      | |
      # | `FLOAT64`   | `Float`        | |
      # | `STRING`    | `STRING`       | |
      # | `DATETIME`  | `DateTime`  | `DATETIME` does not support time zone. |
      # | `DATE`      | `Date`         | |
      # | `TIMESTAMP` | `Time`         | |
      # | `TIME`      | `Google::Cloud::BigQuery::Time` | |
      # | `BYTES`     | `File`, `IO`, `StringIO`, or similar | |
      # | `ARRAY` | `Array` | Nested arrays, `nil` values are not supported. |
      # | `STRUCT`    | `Hash`        | Hash keys may be strings or symbols. |

      module Convert
        ##
        # @private
        def self.format_rows rows, fields
          headers = Array(fields).map { |f| f.name }
          field_types = Array(fields).map { |f| f.type }

          Array(rows).map do |row|
            values = row.f.map { |f| f.v }
            formatted_values = format_values field_types, values
            Hash[headers.zip formatted_values]
          end
        end

        ##
        # @private
        def self.format_values field_types, values
          field_types.zip(values).map do |type, value|
            begin
              if value.nil?
                nil
              elsif type == "INTEGER"
                Integer value
              elsif type == "FLOAT"
                Float value
              elsif type == "BOOLEAN"
                (value == "true" ? true : (value == "false" ? false : nil))
              elsif type == "BYTES"
                StringIO.new Base64.decode64 value
              elsif type == "TIMESTAMP"
                ::Time.at Float(value)
              elsif type == "TIME"
                Bigquery::Time.new value
              elsif type == "DATETIME"
                ::Time.parse("#{value} UTC").to_datetime
              elsif type == "DATE"
                Date.parse value
              else
                value
              end
            rescue => e
              value
            end
          end
        end

        ##
        # @private
        def self.to_query_param value
          if TrueClass === value
            return Google::Apis::BigqueryV2::QueryParameter.new(
              parameter_type:  Google::Apis::BigqueryV2::QueryParameterType.new(
                type: "BOOL"),
              parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
                value: true)
            )
          elsif FalseClass === value
            return Google::Apis::BigqueryV2::QueryParameter.new(
              parameter_type:  Google::Apis::BigqueryV2::QueryParameterType.new(
                type: "BOOL"),
              parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
                value: false)
            )
          elsif Integer === value
            return Google::Apis::BigqueryV2::QueryParameter.new(
              parameter_type:  Google::Apis::BigqueryV2::QueryParameterType.new(
                type: "INT64"),
              parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
                value: value)
            )
          elsif Float === value
            return Google::Apis::BigqueryV2::QueryParameter.new(
              parameter_type:  Google::Apis::BigqueryV2::QueryParameterType.new(
                type: "FLOAT64"),
              parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
                value: value)
            )
          elsif String === value
            return Google::Apis::BigqueryV2::QueryParameter.new(
              parameter_type:  Google::Apis::BigqueryV2::QueryParameterType.new(
                type: "STRING"),
              parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
                value: value)
            )
          elsif DateTime === value
            return Google::Apis::BigqueryV2::QueryParameter.new(
              parameter_type:  Google::Apis::BigqueryV2::QueryParameterType.new(
                type: "DATETIME"),
              parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
                value: value.strftime("%Y-%m-%d %H:%M:%S.%6N"))
            )
          elsif Date === value
            return Google::Apis::BigqueryV2::QueryParameter.new(
              parameter_type:  Google::Apis::BigqueryV2::QueryParameterType.new(
                type: "DATE"),
              parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
                value: value.to_s)
            )
          elsif ::Time === value
            return Google::Apis::BigqueryV2::QueryParameter.new(
              parameter_type:  Google::Apis::BigqueryV2::QueryParameterType.new(
                type: "TIMESTAMP"),
              parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
                value: value.strftime("%Y-%m-%d %H:%M:%S.%6N%:z"))
            )
          elsif Bigquery::Time === value
            return Google::Apis::BigqueryV2::QueryParameter.new(
              parameter_type:  Google::Apis::BigqueryV2::QueryParameterType.new(
              type: "TIME"),
              parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
                value: value.value)
            )
          elsif value.respond_to?(:read) && value.respond_to?(:rewind)
            value.rewind
            return Google::Apis::BigqueryV2::QueryParameter.new(
              parameter_type:  Google::Apis::BigqueryV2::QueryParameterType.new(
                type: "BYTES"),
              parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
                value: Base64.strict_encode64(
                  value.read.force_encoding("ASCII-8BIT")))
            )
          elsif Array === value
            array_params = value.map { |param| Convert.to_query_param param }
            return Google::Apis::BigqueryV2::QueryParameter.new(
              parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
                type: "ARRAY",
                array_type: array_params.first.parameter_type
              ),
              parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
                array_values: array_params.map(&:parameter_value)
              )
            )
          elsif Hash === value
            struct_pairs = value.map do |name, param|
              struct_param = Convert.to_query_param param
              [Google::Apis::BigqueryV2::QueryParameterType::StructType.new(
                name: String(name),
                type: struct_param.parameter_type
              ), struct_param.parameter_value]
            end

            return Google::Apis::BigqueryV2::QueryParameter.new(
              parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
                type: "STRUCT",
                struct_types: struct_pairs.map(&:first)
              ),
              parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
                struct_values: struct_pairs.map(&:last)
              )
            )
          else
            fail "A query parameter of type #{value.class} is not supported."
          end
        end

        # rubocop:enable all
      end
    end
  end
end
