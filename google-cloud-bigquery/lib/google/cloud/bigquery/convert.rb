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
      ##
      # @private
      #
      # Internal conversion of raw data values to/from BigQuery values
      #
      #   | BigQuery     | Ruby                                 | Notes                                              |
      #   |--------------|--------------------------------------|----------------------------------------------------|
      #   | `BOOL`       | `true`/`false`                       |                                                    |
      #   | `INT64`      | `Integer`                            |                                                    |
      #   | `FLOAT64`    | `Float`                              |                                                    |
      #   | `NUMERIC`    | `BigDecimal`                         | `BigDecimal` values will be rounded to scale 9.    |
      #   | `BIGNUMERIC` | converted to `BigDecimal`            | Pass data as `String`; map query params in `types`.|
      #   | `STRING`     | `String`                             |                                                    |
      #   | `DATETIME`   | `DateTime`                           | `DATETIME` does not support time zone.             |
      #   | `DATE`       | `Date`                               |                                                    |
      #   | `GEOGRAPHY`  | `String`                             |                                                    |
      #   | `JSON`       | `String`                             | String, as JSON does not have a schema to verify.  |
      #   | `TIMESTAMP`  | `Time`                               |                                                    |
      #   | `TIME`       | `Google::Cloud::BigQuery::Time`      |                                                    |
      #   | `BYTES`      | `File`, `IO`, `StringIO`, or similar |                                                    |
      #   | `ARRAY`      | `Array`                              | Nested arrays, `nil` values are not supported.     |
      #   | `STRUCT`     | `Hash`                               | Hash keys may be strings or symbols.               |
      #
      module Convert
        def self.format_rows rows, fields
          Array(rows).map do |row|
            # convert TableRow to hash to handle nested TableCell values
            format_row row.to_h, fields
          end
        end

        def self.format_row row, fields
          fields.zip(row[:f]).to_h do |f, v|
            [f.name.to_sym, format_value(v, f)]
          end
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
          elsif field.type == "STRING" || field.type == "JSON" || field.type == "GEOGRAPHY"
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
          elsif field.type == "BIGNUMERIC"
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

        # rubocop:enable all

        def self.to_query_param_value value, type = nil
          return Google::Apis::BigqueryV2::QueryParameterValue.new value: nil if value.nil?

          json_value = to_json_value value, type

          case json_value
          when Array
            type = extract_array_type type
            array_values = json_value.map { |v| to_query_param_value v, type }
            Google::Apis::BigqueryV2::QueryParameterValue.new array_values: array_values
          when Hash
            struct_values = json_value.to_h do |k, v|
              [String(k), to_query_param_value(v, type)]
            end
            Google::Apis::BigqueryV2::QueryParameterValue.new struct_values: struct_values
          else
            # Everything else is converted to a string, per the API expectations.
            Google::Apis::BigqueryV2::QueryParameterValue.new value: json_value.to_s
          end
        end

        def self.to_query_param_type type
          case type
          when Array
            Google::Apis::BigqueryV2::QueryParameterType.new(
              type: "ARRAY".freeze,
              array_type: to_query_param_type(type.first)
            )
          when Hash
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
            Google::Apis::BigqueryV2::QueryParameterType.new type: type.to_s.freeze
          end
        end

        # rubocop:disable Lint/DuplicateBranch
        # rubocop:disable Metrics/CyclomaticComplexity
        # rubocop:disable Style/GuardClause

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
            param.transform_values do |value|
              default_query_param_type_for value
            end
          else
            if param.respond_to?(:read) && param.respond_to?(:rewind)
              :BYTES
            else
              raise "A query parameter of type #{param.class} is not supported"
            end
          end
        end

        # rubocop:enable Lint/DuplicateBranch
        # rubocop:enable Metrics/CyclomaticComplexity
        # rubocop:enable Style/GuardClause

        def self.to_json_value value, type = nil
          if DateTime === value
            value.strftime "%Y-%m-%d %H:%M:%S.%6N"
          elsif Date === value
            value.to_s
          elsif ::Time === value
            value.strftime "%Y-%m-%d %H:%M:%S.%6N%:z"
          elsif Bigquery::Time === value
            value.value
          elsif BigDecimal === value
            if value.finite?
              # Round to precision of 9 unless explicit `BIGNUMERIC`
              bigdecimal = type == :BIGNUMERIC ? value : value.round(9)
              bigdecimal.to_s "F"
            else
              value.to_s
            end
          elsif value.respond_to?(:read) && value.respond_to?(:rewind)
            value.rewind
            Base64.strict_encode64 value.read.force_encoding("ASCII-8BIT")
          elsif Array === value
            type = extract_array_type type
            value.map { |x| to_json_value x, type }
          elsif Hash === value
            value.to_h { |k, v| [k.to_s, to_json_value(v, type)] }
          else
            value
          end
        end

        def self.to_query_param param, type = nil
          type ||= default_query_param_type_for param

          Google::Apis::BigqueryV2::QueryParameter.new(
            parameter_type:  to_query_param_type(type),
            parameter_value: to_query_param_value(param, type)
          )
        end

        ##
        # Lists are specified by providing the type code in an array. For example, an array of integers are specified as
        # `[:INT64]`. Extracts the symbol/hash.
        def self.extract_array_type type
          return nil if type.nil?
          unless type.is_a?(Array) && type.count == 1 && (type.first.is_a?(Symbol) || type.first.is_a?(Hash))
            raise ArgumentError, "types Array #{type.inspect} should include only a single symbol or hash element."
          end
          type.first
        end

        def self.to_json_row row
          row.to_h { |k, v| [k.to_s, to_json_value(v)] }
        end

        def self.resolve_legacy_sql standard_sql, legacy_sql
          return !standard_sql unless standard_sql.nil?
          return legacy_sql unless legacy_sql.nil?
          false
        end

        ##
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
        # Converts file paths into source format by extension.
        #
        # @return [String] API representation of source format.
        def self.derive_source_format_from_list paths
          paths.map do |path|
            derive_source_format path
          end.compact.uniq.first
        end

        ##
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
        # Converts a primitive time value in milliseconds to a Ruby Time object.
        #
        # @return [Time, nil] The Ruby Time object, or nil if the given argument
        #   is nil.
        def self.millis_to_time time_millis
          return nil unless time_millis
          ::Time.at Rational(time_millis, 1000)
        end

        ##
        # Converts a Ruby Time object to a primitive time value in milliseconds.
        #
        # @return [Integer, nil] The primitive time value in milliseconds, or
        #   nil if the given argument is nil.
        def self.time_to_millis time_obj
          return nil unless time_obj
          (time_obj.to_i * 1000) + (time_obj.nsec / 1_000_000)
        end
      end
    end
  end
end
