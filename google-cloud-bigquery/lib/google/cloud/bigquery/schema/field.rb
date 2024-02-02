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


module Google
  module Cloud
    module Bigquery
      class Schema
        ##
        # # Schema Field
        #
        # The fields of a table schema.
        #
        # @see https://cloud.google.com/bigquery/docs/loading-data#loading_denormalized_nested_and_repeated_data
        #   Loading denormalized, nested, and repeated data
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.table "my_table"
        #
        #   field = table.schema.field "name"
        #   field.required? #=> true
        #
        class Field
          # @private
          MODES = ["NULLABLE", "REQUIRED", "REPEATED"].freeze

          # @private
          TYPES = [
            "BIGNUMERIC",
            "BOOL",
            "BOOLEAN",
            "BYTES",
            "DATE",
            "DATETIME",
            "FLOAT",
            "FLOAT64",
            "GEOGRAPHY",
            "INTEGER",
            "INT64",
            "JSON",
            "NUMERIC",
            "RECORD",
            "STRING",
            "STRUCT",
            "TIME",
            "TIMESTAMP"
          ].freeze

          ##
          # The name of the field.
          #
          # @return [String] The field name. The name must contain only
          #   letters (`[A-Za-z]`), numbers (`[0-9]`), or underscores (`_`), and must
          #   start with a letter or underscore. The maximum length is 128
          #   characters.
          #
          def name
            @gapi.name
          end

          ##
          # Updates the name of the field.
          #
          # @param [String] new_name The field name. The name must contain only
          #   letters (`[A-Za-z]`), numbers (`[0-9]`), or underscores (`_`), and must
          #   start with a letter or underscore. The maximum length is 128
          #   characters.
          #
          def name= new_name
            @gapi.update! name: String(new_name)
          end

          ##
          # The data type of the field.
          #
          # @return [String] The field data type. Possible values include:
          #
          #   * `BIGNUMERIC`
          #   * `BOOL`
          #   * `BOOLEAN` (same as `BOOL`)
          #   * `BYTES`
          #   * `DATE`
          #   * `DATETIME`
          #   * `FLOAT`
          #   * `FLOAT64` (same as `FLOAT`)
          #   * `GEOGRAPHY`
          #   * `JSON`
          #   * `INTEGER`
          #   * `INT64` (same as `INTEGER`)
          #   * `NUMERIC`
          #   * `RECORD` (where `RECORD` indicates that the field contains a nested schema)
          #   * `STRING`
          #   * `STRUCT` (same as `RECORD`)
          #   * `TIME`
          #   * `TIMESTAMP`
          #
          def type
            @gapi.type
          end

          ##
          # Updates the data type of the field.
          #
          # @param [String] new_type The data type. Possible values include:
          #
          #   * `BIGNUMERIC`
          #   * `BOOL`
          #   * `BOOLEAN` (same as `BOOL`)
          #   * `BYTES`
          #   * `DATE`
          #   * `DATETIME`
          #   * `FLOAT`
          #   * `FLOAT64` (same as `FLOAT`)
          #   * `GEOGRAPHY`
          #   * `JSON`
          #   * `INTEGER`
          #   * `INT64` (same as `INTEGER`)
          #   * `NUMERIC`
          #   * `RECORD` (where `RECORD` indicates that the field contains a nested schema)
          #   * `STRING`
          #   * `STRUCT` (same as `RECORD`)
          #   * `TIME`
          #   * `TIMESTAMP`
          #
          def type= new_type
            @gapi.update! type: verify_type(new_type)
          end

          ##
          # Checks if the type of the field is `NULLABLE`.
          #
          # @return [Boolean] `true` when `NULLABLE`, `false` otherwise.
          #
          def nullable?
            mode == "NULLABLE"
          end

          ##
          # Checks if the type of the field is `REQUIRED`.
          #
          # @return [Boolean] `true` when `REQUIRED`, `false` otherwise.
          #
          def required?
            mode == "REQUIRED"
          end

          ##
          # Checks if the type of the field is `REPEATED`.
          #
          # @return [Boolean] `true` when `REPEATED`, `false` otherwise.
          #
          def repeated?
            mode == "REPEATED"
          end

          ##
          # The description of the field.
          #
          # @return [String] The field description. The maximum length is 1,024
          #   characters.
          #
          def description
            @gapi.description
          end

          ##
          # Updates the description of the field.
          #
          # @param [String] new_description The field description. The maximum
          #   length is 1,024 characters.
          #
          def description= new_description
            @gapi.update! description: new_description
          end

          ##
          # The mode of the field.
          #
          # @return [String] The field mode. Possible values include `NULLABLE`,
          #   `REQUIRED` and `REPEATED`. The default value is `NULLABLE`.
          #
          def mode
            @gapi.mode
          end

          ##
          # Updates the mode of the field.
          #
          # @param [String] new_mode The field mode. Possible values include
          #   `NULLABLE`, `REQUIRED` and `REPEATED`. The default value is
          #   `NULLABLE`.
          #
          def mode= new_mode
            @gapi.update! mode: verify_mode(new_mode)
          end

          ##
          # The policy tag list for the field. Policy tag identifiers are of the form
          # `projects/*/locations/*/taxonomies/*/policyTags/*`. At most 1 policy tag
          # is currently allowed.
          #
          # @see https://cloud.google.com/bigquery/docs/column-level-security-intro
          #   Introduction to BigQuery column-level security
          #
          # @return [Array<String>, nil] The policy tag list for the field, or `nil`.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   table = dataset.table "my_table"
          #
          #   table.schema.field("age").policy_tags
          #
          def policy_tags
            names = @gapi.policy_tags&.names
            names.to_a if names && !names.empty?
          end

          ##
          # Updates the policy tag list for the field.
          #
          # @see https://cloud.google.com/bigquery/docs/column-level-security-intro
          #   Introduction to BigQuery column-level security
          #
          # @param [Array<String>, String, nil] new_policy_tags The policy tag list or
          #   single policy tag for the field, or `nil` to remove the existing policy tags.
          #   Policy tag identifiers are of the form `projects/*/locations/*/taxonomies/*/policyTags/*`.
          #   At most 1 policy tag is currently allowed.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   table = dataset.table "my_table"
          #
          #   policy_tag = "projects/my-project/locations/us/taxonomies/my-taxonomy/policyTags/my-policy-tag"
          #   table.schema do |schema|
          #     schema.field("age").policy_tags = policy_tag
          #   end
          #
          #   table.schema.field("age").policy_tags
          #
          def policy_tags= new_policy_tags
            # If new_policy_tags is nil, send an empty array.
            # Sending a nil value for policy_tags results in no change.
            new_policy_tags = Array(new_policy_tags)
            policy_tag_list = Google::Apis::BigqueryV2::TableFieldSchema::PolicyTags.new names: new_policy_tags
            @gapi.update! policy_tags: policy_tag_list
          end

          ##
          # The default value of a field using a SQL expression. It can only
          # be set for top level fields (columns). Default value for the entire struct or
          # array is set using a struct or array expression. The valid SQL expressions are:
          #     - Literals for all data types, including STRUCT and ARRAY.
          #     - The following functions:
          #         `CURRENT_TIMESTAMP`
          #         `CURRENT_TIME`
          #         `CURRENT_DATE`
          #         `CURRENT_DATETIME`
          #         `GENERATE_UUID`
          #         `RAND`
          #         `SESSION_USER`
          #         `ST_GEOPOINT`
          #     - Struct or array composed with the above allowed functions, for example:
          #         "[CURRENT_DATE(), DATE '2020-01-01'"]
          #
          # @return [String] The default value expression of the field.
          #
          def default_value_expression
            @gapi.default_value_expression
          end

          ##
          # Updates the default value expression of the field.
          #
          # @param default_value_expression [String] The default value of a field
          #   using a SQL expression. It can only be set for top level fields (columns).
          #   Use a struct or array expression to specify default value for the entire struct or
          #   array. The valid SQL expressions are:
          #     - Literals for all data types, including STRUCT and ARRAY.
          #     - The following functions:
          #         `CURRENT_TIMESTAMP`
          #         `CURRENT_TIME`
          #         `CURRENT_DATE`
          #         `CURRENT_DATETIME`
          #         `GENERATE_UUID`
          #         `RAND`
          #         `SESSION_USER`
          #         `ST_GEOPOINT`
          #     - Struct or array composed with the above allowed functions, for example:
          #         "[CURRENT_DATE(), DATE '2020-01-01'"]
          #
          def default_value_expression= default_value_expression
            @gapi.update! default_value_expression: default_value_expression
          end

          ##
          # The maximum length of values of this field for {#string?} or {bytes?} fields. If `max_length` is not
          # specified, no maximum length constraint is imposed on this field. If type = `STRING`, then `max_length`
          # represents the maximum UTF-8 length of strings in this field. If type = `BYTES`, then `max_length`
          # represents the maximum number of bytes in this field.
          #
          # @return [Integer, nil] The maximum length of values of this field, or `nil`.
          #
          def max_length
            @gapi.max_length
          end

          ##
          # The precision (maximum number of total digits) for `NUMERIC` or `BIGNUMERIC` types. For {#numeric?} fields,
          # acceptable values for precision must be `1 ≤ (precision - scale) ≤ 29` and values for scale must be `0 ≤
          # scale ≤ 9`. For {#bignumeric?} fields, acceptable values for precision must be `1 ≤ (precision - scale) ≤
          # 38` and values for scale must be `0 ≤ scale ≤ 38`. If the scale value is set, the precision value must be
          # set as well.
          #
          # @return [Integer, nil] The precision for the field, or `nil`.
          #
          def precision
            @gapi.precision
          end

          ##
          # The scale (maximum number of digits in the fractional part) for `NUMERIC` or `BIGNUMERIC` types. For
          # {#numeric?} fields, acceptable values for precision must be `1 ≤ (precision - scale) ≤ 29` and values for
          # scale must be `0 ≤ scale ≤ 9`. For {#bignumeric?} fields, acceptable values for precision must be `1 ≤
          # (precision - scale) ≤ 38` and values for scale must be `0 ≤ scale ≤ 38`. If the scale value is set, the
          # precision value must be set as well.
          #
          # @return [Integer, nil] The scale for the field, or `nil`.
          #
          def scale
            @gapi.scale
          end

          ##
          # Checks if the type of the field is `STRING`.
          #
          # @return [Boolean] `true` when `STRING`, `false` otherwise.
          #
          def string?
            type == "STRING"
          end

          ##
          # Checks if the type of the field is `INTEGER`.
          #
          # @return [Boolean] `true` when `INTEGER`, `false` otherwise.
          #
          def integer?
            type == "INTEGER" || type == "INT64"
          end

          ##
          # Checks if the type of the field is `FLOAT`.
          #
          # @return [Boolean] `true` when `FLOAT`, `false` otherwise.
          #
          def float?
            type == "FLOAT" || type == "FLOAT64"
          end

          ##
          # Checks if the type of the field is `NUMERIC`.
          #
          # @return [Boolean] `true` when `NUMERIC`, `false` otherwise.
          #
          def numeric?
            type == "NUMERIC"
          end

          ##
          # Checks if the type of the field is `BIGNUMERIC`.
          #
          # @return [Boolean] `true` when `BIGNUMERIC`, `false` otherwise.
          #
          def bignumeric?
            type == "BIGNUMERIC"
          end

          ##
          # Checks if the type of the field is `BOOLEAN`.
          #
          # @return [Boolean] `true` when `BOOLEAN`, `false` otherwise.
          #
          def boolean?
            type == "BOOLEAN" || type == "BOOL"
          end

          ##
          # Checks if the type of the field is `BYTES`.
          #
          # @return [Boolean] `true` when `BYTES`, `false` otherwise.
          #
          def bytes?
            type == "BYTES"
          end

          ##
          # Checks if the type of the field is `TIMESTAMP`.
          #
          # @return [Boolean] `true` when `TIMESTAMP`, `false` otherwise.
          #
          def timestamp?
            type == "TIMESTAMP"
          end

          ##
          # Checks if the type of the field is `TIME`.
          #
          # @return [Boolean] `true` when `TIME`, `false` otherwise.
          #
          def time?
            type == "TIME"
          end

          ##
          # Checks if the type of the field is `DATETIME`.
          #
          # @return [Boolean] `true` when `DATETIME`, `false` otherwise.
          #
          def datetime?
            type == "DATETIME"
          end

          ##
          # Checks if the type of the field is `DATE`.
          #
          # @return [Boolean] `true` when `DATE`, `false` otherwise.
          #
          def date?
            type == "DATE"
          end

          ##
          # Checks if the type of the field is `GEOGRAPHY`.
          #
          # @return [Boolean] `true` when `GEOGRAPHY`, `false` otherwise.
          #
          def geography?
            type == "GEOGRAPHY"
          end

          ##
          # Checks if the type of the field is `JSON`.
          #
          # @return [Boolean] `true` when `JSON`, `false` otherwise.
          #
          def json?
            type == "JSON"
          end

          ##
          # Checks if the type of the field is `RECORD`.
          #
          # @return [Boolean] `true` when `RECORD`, `false` otherwise.
          #
          def record?
            type == "RECORD" || type == "STRUCT"
          end
          alias struct? record?

          ##
          # The nested fields if the type property is set to `RECORD`. Will be
          # empty otherwise.
          #
          # @return [Array<Field>, nil] The nested schema fields if the type
          #   is set to `RECORD`.
          #
          def fields
            if frozen?
              Array(@gapi.fields).map { |f| Field.from_gapi(f).freeze }.freeze
            else
              Array(@gapi.fields).map { |f| Field.from_gapi f }
            end
          end

          ##
          # The names of the nested fields as symbols if the type property is
          # set to `RECORD`. Will be empty otherwise.
          #
          # @return [Array<Symbol>, nil] The names of the nested schema fields
          #   if the type is set to `RECORD`.
          #
          def headers
            fields.map(&:name).map(&:to_sym)
          end

          ##
          # The types of the field, using the same format as the optional query
          # parameter types.
          #
          # The parameter types are one of the following BigQuery type codes:
          #
          # * `:BOOL`
          # * `:INT64`
          # * `:FLOAT64`
          # * `:NUMERIC`
          # * `:BIGNUMERIC`
          # * `:STRING`
          # * `:DATETIME`
          # * `:DATE`
          # * `:TIMESTAMP`
          # * `:TIME`
          # * `:BYTES`
          # * `Array` - Lists are specified by providing the type code in an array. For example, an array of integers
          #   are specified as `[:INT64]`.
          # * `Hash` - Types for STRUCT values (`Hash` objects) are specified using a `Hash` object, where the keys
          #   are the nested field names, and the values are the the nested field types.
          #
          # @return [Symbol, Array, Hash] The type.
          #
          def param_type
            param_type = type.to_sym
            param_type = fields.to_h { |field| [field.name.to_sym, field.param_type] } if record?
            param_type = [param_type] if repeated?
            param_type
          end

          ##
          # Retrieve a nested field by name, if the type property is
          # set to `RECORD`. Will return `nil` otherwise.
          #
          # @return [Field, nil] The nested schema field object, or `nil`.
          #
          def field name
            f = fields.find { |fld| fld.name == name.to_s }
            return nil if f.nil?
            yield f if block_given?
            f
          end

          ##
          # Adds a string field to the nested schema of a record field.
          #
          # This can only be called on fields that are of type `RECORD`.
          #
          # @param [String] name The field name. The name must contain only
          #   letters (`[A-Za-z]`), numbers (`[0-9]`), or underscores (`_`), and must
          #   start with a letter or underscore. The maximum length is 128
          #   characters.
          # @param [String] description A description of the field.
          # @param [Symbol] mode The field's mode. The possible values are
          #   `:nullable`, `:required`, and `:repeated`. The default value is
          #   `:nullable`.
          # @param [Array<String>, String] policy_tags The policy tag list or
          #   single policy tag for the field. Policy tag identifiers are of
          #   the form `projects/*/locations/*/taxonomies/*/policyTags/*`.
          #   At most 1 policy tag is currently allowed.
          # @param [Integer] max_length The maximum UTF-8 length of strings
          #   allowed in the field.
          #
          def string name, description: nil, mode: :nullable, policy_tags: nil, max_length: nil
            record_check!

            add_field name,
                      :string,
                      description: description,
                      mode: mode,
                      policy_tags: policy_tags,
                      max_length: max_length
          end

          ##
          # Adds an integer field to the nested schema of a record field.
          #
          # This can only be called on fields that are of type `RECORD`.
          #
          # @param [String] name The field name. The name must contain only
          #   letters (`[A-Za-z]`), numbers (`[0-9]`), or underscores (`_`), and must
          #   start with a letter or underscore. The maximum length is 128
          #   characters.
          # @param [String] description A description of the field.
          # @param [Symbol] mode The field's mode. The possible values are
          #   `:nullable`, `:required`, and `:repeated`. The default value is
          #   `:nullable`.
          # @param [Array<String>, String] policy_tags The policy tag list or
          #   single policy tag for the field. Policy tag identifiers are of
          #   the form `projects/*/locations/*/taxonomies/*/policyTags/*`.
          #   At most 1 policy tag is currently allowed.
          #
          def integer name, description: nil, mode: :nullable, policy_tags: nil
            record_check!

            add_field name, :integer, description: description, mode: mode, policy_tags: policy_tags
          end

          ##
          # Adds a floating-point number field to the nested schema of a record
          # field.
          #
          # This can only be called on fields that are of type `RECORD`.
          #
          # @param [String] name The field name. The name must contain only
          #   letters (`[A-Za-z]`), numbers (`[0-9]`), or underscores (`_`), and must
          #   start with a letter or underscore. The maximum length is 128
          #   characters.
          # @param [String] description A description of the field.
          # @param [Symbol] mode The field's mode. The possible values are
          #   `:nullable`, `:required`, and `:repeated`. The default value is
          #   `:nullable`.
          # @param [Array<String>, String] policy_tags The policy tag list or
          #   single policy tag for the field. Policy tag identifiers are of
          #   the form `projects/*/locations/*/taxonomies/*/policyTags/*`.
          #   At most 1 policy tag is currently allowed.
          #
          def float name, description: nil, mode: :nullable, policy_tags: nil
            record_check!

            add_field name, :float, description: description, mode: mode, policy_tags: policy_tags
          end

          ##
          # Adds a numeric number field to the schema. `NUMERIC` is a decimal
          # type with fixed precision and scale. Precision is the number of
          # digits that the number contains. Scale is how many of these
          # digits appear after the decimal point. It supports:
          #
          # Precision: 38
          # Scale: 9
          # Min: -9.9999999999999999999999999999999999999E+28
          # Max: 9.9999999999999999999999999999999999999E+28
          #
          # This type can represent decimal fractions exactly, and is suitable
          # for financial calculations.
          #
          # This can only be called on fields that are of type `RECORD`.
          #
          # @param [String] name The field name. The name must contain only
          #   letters (`[A-Za-z]`), numbers (`[0-9]`), or underscores (`_`), and must
          #   start with a letter or underscore. The maximum length is 128
          #   characters.
          # @param [String] description A description of the field.
          # @param [Symbol] mode The field's mode. The possible values are
          #   `:nullable`, `:required`, and `:repeated`. The default value is
          #   `:nullable`.
          # @param [Array<String>, String] policy_tags The policy tag list or
          #   single policy tag for the field. Policy tag identifiers are of
          #   the form `projects/*/locations/*/taxonomies/*/policyTags/*`.
          #   At most 1 policy tag is currently allowed.
          # @param [Integer] precision The precision (maximum number of total
          #   digits) for the field. Acceptable values for precision must be:
          #   `1 ≤ (precision - scale) ≤ 29`. Values for scale must be:
          #   `0 ≤ scale ≤ 9`. If the scale value is set, the precision value
          #   must be set as well.
          # @param [Integer] scale The scale (maximum number of digits in the
          #   fractional part) for the field. Acceptable values for precision
          #   must be: `1 ≤ (precision - scale) ≤ 29`. Values for scale must
          #   be: `0 ≤ scale ≤ 9`. If the scale value is set, the precision
          #   value must be set as well.
          #
          def numeric name, description: nil, mode: :nullable, policy_tags: nil, precision: nil, scale: nil
            record_check!

            add_field name,
                      :numeric,
                      description: description,
                      mode: mode,
                      policy_tags: policy_tags,
                      precision: precision,
                      scale: scale
          end

          ##
          # Adds a bignumeric number field to the schema. `BIGNUMERIC` is a
          # decimal type with fixed precision and scale. Precision is the
          # number of digits that the number contains. Scale is how many of
          # these digits appear after the decimal point. It supports:
          #
          # Precision: 76.76 (the 77th digit is partial)
          # Scale: 38
          # Min: -5.7896044618658097711785492504343953926634992332820282019728792003956564819968E+38
          # Max: 5.7896044618658097711785492504343953926634992332820282019728792003956564819967E+38
          #
          # This type can represent decimal fractions exactly, and is suitable
          # for financial calculations.
          #
          # This can only be called on fields that are of type `RECORD`.
          #
          # @param [String] name The field name. The name must contain only
          #   letters (`[A-Za-z]`), numbers (`[0-9]`), or underscores (`_`), and must
          #   start with a letter or underscore. The maximum length is 128
          #   characters.
          # @param [String] description A description of the field.
          # @param [Symbol] mode The field's mode. The possible values are
          #   `:nullable`, `:required`, and `:repeated`. The default value is
          #   `:nullable`.
          # @param [Array<String>, String] policy_tags The policy tag list or
          #   single policy tag for the field. Policy tag identifiers are of
          #   the form `projects/*/locations/*/taxonomies/*/policyTags/*`.
          #   At most 1 policy tag is currently allowed.
          # @param [Integer] precision The precision (maximum number of total
          #   digits) for the field. Acceptable values for precision must be:
          #   `1 ≤ (precision - scale) ≤ 38`. Values for scale must be:
          #   `0 ≤ scale ≤ 38`. If the scale value is set, the precision value
          #   must be set as well.
          # @param [Integer] scale The scale (maximum number of digits in the
          #   fractional part) for the field. Acceptable values for precision
          #   must be: `1 ≤ (precision - scale) ≤ 38`. Values for scale must
          #   be: `0 ≤ scale ≤ 38`. If the scale value is set, the precision
          #   value must be set as well.
          #
          def bignumeric name, description: nil, mode: :nullable, policy_tags: nil, precision: nil, scale: nil
            record_check!

            add_field name,
                      :bignumeric,
                      description: description,
                      mode: mode,
                      policy_tags: policy_tags,
                      precision: precision,
                      scale: scale
          end

          ##
          # Adds a boolean field to the nested schema of a record field.
          #
          # This can only be called on fields that are of type `RECORD`.
          #
          # @param [String] name The field name. The name must contain only
          #   letters (`[A-Za-z]`), numbers (`[0-9]`), or underscores (`_`), and must
          #   start with a letter or underscore. The maximum length is 128
          #   characters.
          # @param [String] description A description of the field.
          # @param [Symbol] mode The field's mode. The possible values are
          #   `:nullable`, `:required`, and `:repeated`. The default value is
          #   `:nullable`.
          # @param [Array<String>, String] policy_tags The policy tag list or
          #   single policy tag for the field. Policy tag identifiers are of
          #   the form `projects/*/locations/*/taxonomies/*/policyTags/*`.
          #   At most 1 policy tag is currently allowed.
          #
          def boolean name, description: nil, mode: :nullable, policy_tags: nil
            record_check!

            add_field name, :boolean, description: description, mode: mode, policy_tags: policy_tags
          end

          ##
          # Adds a bytes field to the nested schema of a record field.
          #
          # This can only be called on fields that are of type `RECORD`.
          #
          # @param [String] name The field name. The name must contain only
          #   letters (`[A-Za-z]`), numbers (`[0-9]`), or underscores (`_`), and must
          #   start with a letter or underscore. The maximum length is 128
          #   characters.
          # @param [String] description A description of the field.
          # @param [Symbol] mode The field's mode. The possible values are
          #   `:nullable`, `:required`, and `:repeated`. The default value is
          #   `:nullable`.
          # @param [Array<String>, String] policy_tags The policy tag list or
          #   single policy tag for the field. Policy tag identifiers are of
          #   the form `projects/*/locations/*/taxonomies/*/policyTags/*`.
          #   At most 1 policy tag is currently allowed.
          # @param [Integer] max_length The maximum the maximum number of
          #   bytes in the field.
          #
          def bytes name, description: nil, mode: :nullable, policy_tags: nil, max_length: nil
            record_check!

            add_field name,
                      :bytes,
                      description: description,
                      mode: mode,
                      policy_tags: policy_tags,
                      max_length: max_length
          end

          ##
          # Adds a timestamp field to the nested schema of a record field.
          #
          # This can only be called on fields that are of type `RECORD`.
          #
          # @param [String] name The field name. The name must contain only
          #   letters (`[A-Za-z]`), numbers (`[0-9]`), or underscores (`_`), and must
          #   start with a letter or underscore. The maximum length is 128
          #   characters.
          # @param [String] description A description of the field.
          # @param [Symbol] mode The field's mode. The possible values are
          #   `:nullable`, `:required`, and `:repeated`. The default value is
          #   `:nullable`.
          # @param [Array<String>, String] policy_tags The policy tag list or
          #   single policy tag for the field. Policy tag identifiers are of
          #   the form `projects/*/locations/*/taxonomies/*/policyTags/*`.
          #   At most 1 policy tag is currently allowed.
          #
          def timestamp name, description: nil, mode: :nullable, policy_tags: nil
            record_check!

            add_field name, :timestamp, description: description, mode: mode, policy_tags: policy_tags
          end

          ##
          # Adds a time field to the nested schema of a record field.
          #
          # This can only be called on fields that are of type `RECORD`.
          #
          # @param [String] name The field name. The name must contain only
          #   letters (`[A-Za-z]`), numbers (`[0-9]`), or underscores (`_`), and must
          #   start with a letter or underscore. The maximum length is 128
          #   characters.
          # @param [String] description A description of the field.
          # @param [Symbol] mode The field's mode. The possible values are
          #   `:nullable`, `:required`, and `:repeated`. The default value is
          #   `:nullable`.
          # @param [Array<String>, String] policy_tags The policy tag list or
          #   single policy tag for the field. Policy tag identifiers are of
          #   the form `projects/*/locations/*/taxonomies/*/policyTags/*`.
          #   At most 1 policy tag is currently allowed.
          #
          def time name, description: nil, mode: :nullable, policy_tags: nil
            record_check!

            add_field name, :time, description: description, mode: mode, policy_tags: policy_tags
          end

          ##
          # Adds a datetime field to the nested schema of a record field.
          #
          # This can only be called on fields that are of type `RECORD`.
          #
          # @param [String] name The field name. The name must contain only
          #   letters (`[A-Za-z]`), numbers (`[0-9]`), or underscores (`_`), and must
          #   start with a letter or underscore. The maximum length is 128
          #   characters.
          # @param [String] description A description of the field.
          # @param [Symbol] mode The field's mode. The possible values are
          #   `:nullable`, `:required`, and `:repeated`. The default value is
          #   `:nullable`.
          # @param [Array<String>, String] policy_tags The policy tag list or
          #   single policy tag for the field. Policy tag identifiers are of
          #   the form `projects/*/locations/*/taxonomies/*/policyTags/*`.
          #   At most 1 policy tag is currently allowed.
          #
          def datetime name, description: nil, mode: :nullable, policy_tags: nil
            record_check!

            add_field name, :datetime, description: description, mode: mode, policy_tags: policy_tags
          end

          ##
          # Adds a date field to the nested schema of a record field.
          #
          # This can only be called on fields that are of type `RECORD`.
          #
          # @param [String] name The field name. The name must contain only
          #   letters (`[A-Za-z]`), numbers (`[0-9]`), or underscores (`_`), and must
          #   start with a letter or underscore. The maximum length is 128
          #   characters.
          # @param [String] description A description of the field.
          # @param [Symbol] mode The field's mode. The possible values are
          #   `:nullable`, `:required`, and `:repeated`. The default value is
          #   `:nullable`.
          # @param [Array<String>, String] policy_tags The policy tag list or
          #   single policy tag for the field. Policy tag identifiers are of
          #   the form `projects/*/locations/*/taxonomies/*/policyTags/*`.
          #   At most 1 policy tag is currently allowed.
          #
          def date name, description: nil, mode: :nullable, policy_tags: nil
            record_check!

            add_field name, :date, description: description, mode: mode, policy_tags: policy_tags
          end

          ##
          # Adds a geography field to the nested schema of a record field.
          #
          # @see https://cloud.google.com/bigquery/docs/gis-data Working with BigQuery GIS data
          #
          # @param [String] name The field name. The name must contain only
          #   letters (`[A-Za-z]`), numbers (`[0-9]`), or underscores (`_`), and must
          #   start with a letter or underscore. The maximum length is 128
          #   characters.
          # @param [String] description A description of the field.
          # @param [Symbol] mode The field's mode. The possible values are
          #   `:nullable`, `:required`, and `:repeated`. The default value is
          #   `:nullable`.
          # @param [Array<String>, String] policy_tags The policy tag list or
          #   single policy tag for the field. Policy tag identifiers are of
          #   the form `projects/*/locations/*/taxonomies/*/policyTags/*`.
          #   At most 1 policy tag is currently allowed.
          #
          def geography name, description: nil, mode: :nullable, policy_tags: nil
            record_check!

            add_field name, :geography, description: description, mode: mode, policy_tags: policy_tags
          end

          ##
          # Adds a json field to the nested schema of a record field.
          #
          # https://cloud.google.com/bigquery/docs/reference/standard-sql/data-types#json_type
          #
          # @param [String] name The field name. The name must contain only
          #   letters (a-z, A-Z), numbers (0-9), or underscores (_), and must
          #   start with a letter or underscore. The maximum length is 128
          #   characters.
          # @param [String] description A description of the field.
          # @param [Symbol] mode The field's mode. The possible values are
          #   `:nullable`, `:required`, and `:repeated`. The default value is
          #   `:nullable`.
          # @param [Array<String>, String] policy_tags The policy tag list or
          #   single policy tag for the field. Policy tag identifiers are of
          #   the form `projects/*/locations/*/taxonomies/*/policyTags/*`.
          #   At most 1 policy tag is currently allowed.
          #
          def json name, description: nil, mode: :nullable, policy_tags: nil
            record_check!

            add_field name, :json, description: description, mode: mode, policy_tags: policy_tags
          end

          ##
          # Adds a record field to the nested schema of a record field. A block
          # must be passed describing the nested fields of the record. For more
          # information about nested and repeated records, see [Preparing Data
          # for BigQuery](https://cloud.google.com/bigquery/docs/loading-data#loading_denormalized_nested_and_repeated_data).
          #
          # This can only be called on fields that are of type `RECORD`.
          #
          # @param [String] name The field name. The name must contain only
          #   letters (`[A-Za-z]`), numbers (`[0-9]`), or underscores (`_`), and must
          #   start with a letter or underscore. The maximum length is 128
          #   characters.
          # @param [String] description A description of the field.
          # @param [Symbol] mode The field's mode. The possible values are
          #   `:nullable`, `:required`, and `:repeated`. The default value is
          #   `:nullable`.
          # @yield [nested_schema] a block for setting the nested schema
          # @yieldparam [Schema] nested_schema the object accepting the
          #   nested schema
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   table = dataset.create_table "my_table"
          #
          #   table.schema do |schema|
          #     schema.string "first_name", mode: :required
          #     schema.record "cities_lived", mode: :repeated do |cities_lived|
          #       cities_lived.record "city", mode: :required do |city|
          #         city.string "name", mode: :required
          #         city.string "country", mode: :required
          #       end
          #       cities_lived.integer "number_of_years", mode: :required
          #     end
          #   end
          #
          def record name, description: nil, mode: nil
            record_check!

            # TODO: do we need to raise if no block was given?
            raise ArgumentError, "a block is required" unless block_given?

            nested_field = add_field name, :record, description: description, mode: mode
            yield nested_field
            nested_field
          end

          # @private
          def self.from_gapi gapi
            new.tap do |f|
              f.instance_variable_set :@gapi, gapi
              f.instance_variable_set :@original_json, gapi.to_json
            end
          end

          # @private
          def to_gapi
            @gapi
          end

          # @private
          def == other
            return false unless other.is_a? Field
            to_gapi.to_h == other.to_gapi.to_h
          end

          # @private
          def to_hash
            h = {
              name: name,
              type: type,
              mode: mode
            }
            h[:description] = description if description
            h[:fields] = fields.map(&:to_hash) if record?
            h
          end

          protected

          def frozen_check!
            return unless frozen?
            raise ArgumentError, "Cannot modify a frozen field"
          end

          def record_check!
            return unless type != "RECORD"
            raise ArgumentError,
                  "Cannot add fields to a non-RECORD field (#{type})"
          end

          def add_field name,
                        type,
                        description: nil,
                        mode: :nullable,
                        policy_tags: nil,
                        max_length: nil,
                        precision: nil,
                        scale: nil
            frozen_check!

            new_gapi = Google::Apis::BigqueryV2::TableFieldSchema.new(
              name:        String(name),
              type:        verify_type(type),
              description: description,
              mode:        verify_mode(mode),
              fields:      []
            )
            if policy_tags
              policy_tags = Array(policy_tags)
              new_gapi.policy_tags = Google::Apis::BigqueryV2::TableFieldSchema::PolicyTags.new names: policy_tags
            end
            new_gapi.max_length = max_length if max_length
            new_gapi.precision = precision if precision
            new_gapi.scale = scale if scale
            # Remove any existing field of this name
            @gapi.fields ||= []
            @gapi.fields.reject! { |f| f.name == new_gapi.name }
            # Add to the nested fields
            @gapi.fields << new_gapi

            # return the public API object
            Field.from_gapi new_gapi
          end

          def verify_type type
            type = type.to_s.upcase
            raise ArgumentError, "Type '#{type}' not found" unless TYPES.include? type
            type
          end

          def verify_mode mode
            mode = :nullable if mode.nil?
            mode = mode.to_s.upcase
            raise ArgumentError "Unable to determine mode for '#{mode}'" unless MODES.include? mode
            mode
          end
        end
      end
    end
  end
end
