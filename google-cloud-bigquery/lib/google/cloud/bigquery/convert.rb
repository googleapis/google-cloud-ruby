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


require "google/apis/bigquery_v2"
require "stringio"
require "base64"
require "bigdecimal"
require "time"
require "date"

module Google
  module Cloud
    module Bigquery
      # rubocop:disable Metrics/ModuleLength

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
      # | `NUMERIC`   | `BigDecimal`   | Will be rounded to 9 decimal places |
      # | `STRING`    | `String`       | |
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
          Array(rows).map do |row|
            # convert TableRow to hash to handle nested TableCell values
            format_row row.to_h, fields
          end
        end

        ##
        # @private
        def self.format_row row, fields
          row_pairs = fields.zip(row[:f]).map do |f, v|
            [f.name.to_sym, format_value(v, f)]
          end
          Hash[row_pairs]
        end

        # rubocop:disable all

        def self.format_value value, field
          if value.nil?
            nil
          elsif value.empty?
            nil
          elsif value[:v].nil?
            nil
          elsif Array === value[:v]
            value[:v].map { |v| format_value v, field }
          elsif Hash === value[:v]
            format_row value[:v], field.fields
          elsif field.type == "STRING"
            String value[:v]
          elsif field.type == "INTEGER"
            Integer value[:v]
          elsif field.type == "FLOAT"
            if value[:v] == "Infinity"
              Float::INFINITY
            elsif value[:v] == "-Infinity"
              -Float::INFINITY
            elsif value[:v] == "NaN"
              Float::NAN
            else
              Float value[:v]
            end
          elsif field.type == "NUMERIC"
            BigDecimal value[:v]
          elsif field.type == "BOOLEAN"
            (value[:v] == "true" ? true : (value[:v] == "false" ? false : nil))
          elsif field.type == "BYTES"
            StringIO.new Base64.decode64 value[:v]
          elsif field.type == "TIMESTAMP"
            ::Time.at Float(value[:v])
          elsif field.type == "TIME"
            Bigquery::Time.new value[:v]
          elsif field.type == "DATETIME"
            ::Time.parse("#{value[:v]} UTC").to_datetime
          elsif field.type == "DATE"
            Date.parse value[:v]
          else
            value[:v]
          end
        end

        ##
        # @private
        def self.to_query_param param, type = nil
          type ||= default_query_param_type_for param

          Google::Apis::BigqueryV2::QueryParameter.new(
            parameter_type:  to_query_param_type(type),
            parameter_value: to_query_param_value(param)
          )
        end

        ##
        # @private
        def self.to_query_param_value value
          return Google::Apis::BigqueryV2::QueryParameterValue.new value: nil if value.nil?

          json_value = to_json_value value

          if Array === json_value
            array_values = json_value.map { |v| to_query_param_value v }
            Google::Apis::BigqueryV2::QueryParameterValue.new array_values: array_values
          elsif Hash === json_value
            struct_pairs = json_value.map do |key, value|
              [String(key), to_query_param_value(value)]
            end
            struct_values = Hash[struct_pairs]
            Google::Apis::BigqueryV2::QueryParameterValue.new struct_values: struct_values
          else
            # Everything else is converted to a string, per the API expectations.
            Google::Apis::BigqueryV2::QueryParameterValue.new value: json_value.to_s
          end
        end

        def self.to_query_param_type type
          if Array === type
            Google::Apis::BigqueryV2::QueryParameterType.new(
              type: "ARRAY".freeze,
              array_type: to_query_param_type(type.first)
            )
          elsif Hash === type
            Google::Apis::BigqueryV2::QueryParameterType.new(
              type: "STRUCT".freeze,
              struct_types: type.map do |key, val|
                Google::Apis::BigqueryV2::QueryParameterType::StructType.new(
                  name: String(key),
                  type: to_query_param_type(val)
                )
              end
            )
          else
            Google::Apis::BigqueryV2::QueryParameterType.new(type: type.to_s.freeze)
          end
        end

        def self.default_query_param_type_for param
          raise ArgumentError, "nil params are not supported, must assign optional type" if param.nil?

          case param
          when String
            :STRING
          when Symbol
            :STRING
          when TrueClass
            :BOOL
          when FalseClass
            :BOOL
          when Integer
            :INT64
          when BigDecimal
            :NUMERIC
          when Numeric
            :FLOAT64
          when ::Time
            :TIMESTAMP
          when Bigquery::Time
            :TIME
          when DateTime
            :DATETIME
          when Date
            :DATE
          when Array
            if param.empty?
              raise ArgumentError, "Cannot determine type for empty array values"
            end
            non_nil_values = param.compact.map { |p| default_query_param_type_for p }.compact
            if non_nil_values.empty?
              raise ArgumentError, "Cannot determine type for array of nil values"
            end
            if non_nil_values.uniq.count > 1
              raise ArgumentError, "Cannot determine type for array of different types of values"
            end
            [non_nil_values.first]
          when Hash
            Hash[param.map do |key, value|
              [key, default_query_param_type_for(value)]
            end]
          else
            if param.respond_to?(:read) && param.respond_to?(:rewind)
              :BYTES
            else
              raise "A query parameter of type #{param.class} is not supported"
            end
          end
        end

        ##
        # @private
        def self.to_json_value value
          if DateTime === value
            value.strftime "%Y-%m-%d %H:%M:%S.%6N"
          elsif Date === value
            value.to_s
          elsif ::Time === value
            value.strftime "%Y-%m-%d %H:%M:%S.%6N%:z"
          elsif Bigquery::Time === value
            value.value
          elsif BigDecimal === value
            # Round to precision of 9
            value.finite? ? value.round(9).to_s("F") : value.to_s
          elsif value.respond_to?(:read) && value.respond_to?(:rewind)
            value.rewind
            Base64.strict_encode64(value.read.force_encoding("ASCII-8BIT"))
          elsif Array === value
            value.map { |v| to_json_value v }
          elsif Hash === value
            Hash[value.map { |k, v| [k.to_s, to_json_value(v)] }]
          else
            value
          end
        end

        # rubocop:enable all

        ##
        # @private
        def self.to_json_rows rows
          rows.map { |row| to_json_row row }
        end

        ##
        # @private
        def self.to_json_row row
          Hash[row.map { |k, v| [k.to_s, to_json_value(v)] }]
        end

        def self.resolve_legacy_sql standard_sql, legacy_sql
          return !standard_sql unless standard_sql.nil?
          return legacy_sql unless legacy_sql.nil?
          false
        end

        ##
        # @private
        #
        # Converts create disposition strings to API values.
        #
        # @return [String] API representation of create disposition.
        def self.create_disposition str
          val = {
            "create_if_needed" => "CREATE_IF_NEEDED",
            "createifneeded"   => "CREATE_IF_NEEDED",
            "if_needed"        => "CREATE_IF_NEEDED",
            "needed"           => "CREATE_IF_NEEDED",
            "create_never"     => "CREATE_NEVER",
            "createnever"      => "CREATE_NEVER",
            "never"            => "CREATE_NEVER"
          }[str.to_s.downcase]
          return val unless val.nil?
          str
        end

        ##
        # @private
        #
        # Converts write disposition strings to API values.
        #
        # @return [String] API representation of write disposition.
        def self.write_disposition str
          val = {
            "write_truncate" => "WRITE_TRUNCATE",
            "writetruncate"  => "WRITE_TRUNCATE",
            "truncate"       => "WRITE_TRUNCATE",
            "write_append"   => "WRITE_APPEND",
            "writeappend"    => "WRITE_APPEND",
            "append"         => "WRITE_APPEND",
            "write_empty"    => "WRITE_EMPTY",
            "writeempty"     => "WRITE_EMPTY",
            "empty"          => "WRITE_EMPTY"
          }[str.to_s.downcase]
          return val unless val.nil?
          str
        end

        ##
        # @private
        #
        # Converts source format strings to API values.
        #
        # @return [String] API representation of source format.
        def self.source_format format
          val = {
            "csv"                    => "CSV",
            "json"                   => "NEWLINE_DELIMITED_JSON",
            "newline_delimited_json" => "NEWLINE_DELIMITED_JSON",
            "avro"                   => "AVRO",
            "orc"                    => "ORC",
            "parquet"                => "PARQUET",
            "datastore"              => "DATASTORE_BACKUP",
            "backup"                 => "DATASTORE_BACKUP",
            "datastore_backup"       => "DATASTORE_BACKUP",
            "ml_tf_saved_model"      => "ML_TF_SAVED_MODEL",
            "ml_xgboost_booster"     => "ML_XGBOOST_BOOSTER"
          }[format.to_s.downcase]
          return val unless val.nil?
          format
        end

        ##
        # @private
        #
        # Converts file paths into source format by extension.
        #
        # @return [String] API representation of source format.
        def self.derive_source_format_from_list paths
          paths.map do |path|
            derive_source_format path
          end.compact.uniq.first
        end

        ##
        # @private
        #
        # Converts file path into source format by extension.
        #
        # @return [String] API representation of source format.
        def self.derive_source_format path
          return "CSV"                    if path.end_with? ".csv"
          return "NEWLINE_DELIMITED_JSON" if path.end_with? ".json"
          return "AVRO"                   if path.end_with? ".avro"
          return "ORC"                    if path.end_with? ".orc"
          return "PARQUET"                if path.end_with? ".parquet"
          return "DATASTORE_BACKUP"       if path.end_with? ".backup_info"
          nil
        end

        ##
        # @private
        #
        # Converts a primitive time value in milliseconds to a Ruby Time object.
        #
        # @return [Time, nil] The Ruby Time object, or nil if the given argument
        #   is nil.
        def self.millis_to_time time_millis
          return nil unless time_millis
          ::Time.at Rational(time_millis, 1000)
        end

        ##
        # @private
        #
        # Converts a Ruby Time object to a primitive time value in milliseconds.
        #
        # @return [Integer, nil] The primitive time value in milliseconds, or
        #   nil if the given argument is nil.
        def self.time_to_millis time_obj
          return nil unless time_obj
          (time_obj.to_i * 1000) + (time_obj.nsec / 1_000_000)
        end
      end

      # rubocop:enable Metrics/ModuleLength
    end
  end
end
