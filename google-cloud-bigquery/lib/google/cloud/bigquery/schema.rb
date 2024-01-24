# Copyright 2015 Google LLC
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


require "google/cloud/bigquery/schema/field"
require "json"

module Google
  module Cloud
    module Bigquery
      ##
      # # Table Schema
      #
      # A builder for BigQuery table schemas, passed to block arguments to
      # {Dataset#create_table} and {Table#schema}. Supports nested and
      # repeated fields via a nested block.
      #
      # @see https://cloud.google.com/bigquery/docs/loading-data#loading_denormalized_nested_and_repeated_data
      #   Loading denormalized, nested, and repeated data
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
      #       cities_lived.string "place", mode: :required
      #       cities_lived.integer "number_of_years", mode: :required
      #     end
      #   end
      #
      class Schema
        class << self
          ##
          # Load a schema from a JSON file.
          #
          # The JSON schema file is the same as for the [`bq`
          # CLI](https://cloud.google.com/bigquery/docs/schemas#specifying_a_json_schema_file)
          # consisting of an array of JSON objects containing the following:
          # - `name`: The column [name](https://cloud.google.com/bigquery/docs/schemas#column_names)
          # - `type`: The column's [data
          #   type](https://cloud.google.com/bigquery/docs/schemas#standard_sql_data_types)
          # - `description`: (Optional) The column's [description](https://cloud.google.com/bigquery/docs/schemas#column_descriptions)
          # - `mode`: (Optional) The column's [mode](https://cloud.google.com/bigquery/docs/schemas#modes)
          #   (if unspecified, mode defaults to `NULLABLE`)
          # - `fields`: If `type` is `RECORD`, an array of objects defining
          #   child fields with these properties
          #
          # @param [IO, String, Array<Hash>] source An `IO` containing the JSON
          #   schema, a `String` containing the JSON schema, or an `Array` of
          #   `Hash`es containing the schema details.
          #
          # @return [Schema] A schema.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   schema = Google::Cloud::Bigquery::Schema.load(
          #     File.read("schema.json")
          #   )
          #
          def load source
            new.load source
          end

          ##
          # Write a schema as JSON to a file.
          #
          # The JSON schema file is the same as for the [`bq`
          # CLI](https://cloud.google.com/bigquery/docs/schemas#specifying_a_json_schema_file).
          #
          # @param [Schema] schema A `Google::Cloud::Bigquery::Schema`.
          #
          # @param [IO, String] destination An `IO` to which to write the
          #   schema, or a `String` containing the filename to write to.
          #
          # @return [Schema] The schema so that commands are chainable.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   table = dataset.table "my_table"
          #   schema = Google::Cloud::Bigquery::Schema.dump(
          #     table.schema,
          #     "schema.json"
          #   )
          #
          def dump schema, destination
            schema.dump destination
          end
        end
        ##
        # The fields of the table schema.
        #
        # @return [Array<Field>] An array of field objects.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.table "my_table"
        #
        #   schema = table.schema
        #
        #   schema.fields.each do |field|
        #     puts field.name
        #   end
        #
        def fields
          if frozen?
            Array(@gapi.fields).map { |f| Field.from_gapi(f).freeze }.freeze
          else
            Array(@gapi.fields).map { |f| Field.from_gapi f }
          end
        end

        ##
        # The names of the fields as symbols.
        #
        # @return [Array<Symbol>] An array of column names.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.create_table "my_table"
        #
        #   schema = table.schema
        #
        #   schema.headers.each do |header|
        #     puts header
        #   end
        #
        def headers
          fields.map(&:name).map(&:to_sym)
        end

        ##
        # The types of the fields, using the same format as the optional query
        # parameter types.
        #
        # @return [Hash] A hash with column names as keys, and types as values.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.create_table "my_table"
        #
        #   schema = table.schema
        #
        #   schema.param_types
        #
        def param_types
          fields.to_h { |field| [field.name.to_sym, field.param_type] }
        end

        ##
        # Retrieve a field by name.
        #
        # @return [Field] A field object.
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
        def field name
          f = fields.find { |fld| fld.name == name.to_s }
          return nil if f.nil?
          yield f if block_given?
          f
        end

        ##
        # Whether the schema has no fields defined.
        #
        # @return [Boolean] `true` when there are no fields, `false` otherwise.
        #
        def empty?
          fields.empty?
        end

        ##
        # Load the schema from a JSON file.
        #
        # The JSON schema file is the same as for the [`bq`
        # CLI](https://cloud.google.com/bigquery/docs/schemas#specifying_a_json_schema_file)
        # consisting of an array of JSON objects containing the following:
        # - `name`: The column [name](https://cloud.google.com/bigquery/docs/schemas#column_names)
        # - `type`: The column's [data
        #   type](https://cloud.google.com/bigquery/docs/schemas#standard_sql_data_types)
        # - `description`: (Optional) The column's [description](https://cloud.google.com/bigquery/docs/schemas#column_descriptions)
        # - `mode`: (Optional) The column's [mode](https://cloud.google.com/bigquery/docs/schemas#modes)
        #   (if unspecified, mode defaults to `NULLABLE`)
        # - `fields`: If `type` is `RECORD`, an array of objects defining child
        #   fields with these properties
        #
        # @param [IO, String, Array<Hash>] source An `IO` containing the JSON
        #   schema, a `String` containing the JSON schema, or an `Array` of
        #   `Hash`es containing the schema details.
        #
        # @return [Schema] The schema so that commands are chainable.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.table "my_table" do |t|
        #     t.schema.load File.read("path/to/schema.json")
        #   end
        #
        def load source
          if source.respond_to?(:rewind) && source.respond_to?(:read)
            source.rewind
            schema_json = String source.read
          elsif source.is_a? Array
            schema_json = JSON.dump source
          else
            schema_json = String source
          end

          schema_json = %({"fields":#{schema_json}})

          @gapi = Google::Apis::BigqueryV2::TableSchema.from_json schema_json

          self
        end

        ##
        # Write the schema as JSON to a file.
        #
        # The JSON schema file is the same as for the [`bq`
        # CLI](https://cloud.google.com/bigquery/docs/schemas#specifying_a_json_schema_file).
        #
        # @param [IO, String] destination An `IO` to which to write the schema,
        #   or a `String` containing the filename to write to.
        #
        # @return [Schema] The schema so that commands are chainable.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.table "my_table"
        #   table.schema.dump "schema.json"
        #
        def dump destination
          if destination.respond_to?(:rewind) && destination.respond_to?(:write)
            destination.rewind
            destination.write JSON.dump(fields.map(&:to_hash))
          else
            File.write String(destination), JSON.dump(fields.map(&:to_hash))
          end

          self
        end

        ##
        # Adds a string field to the schema.
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
        def string name, description: nil, mode: :nullable, policy_tags: nil,
                   max_length: nil, default_value_expression: nil
          add_field name, :string,
                    description: description,
                    mode: mode,
                    policy_tags: policy_tags,
                    max_length: max_length,
                    default_value_expression: default_value_expression
        end

        ##
        # Adds an integer field to the schema.
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
        def integer name, description: nil, mode: :nullable,
                    policy_tags: nil, default_value_expression: nil
          add_field name, :integer,
                    description: description,
                    mode: mode,
                    policy_tags: policy_tags,
                    default_value_expression: default_value_expression
        end

        ##
        # Adds a floating-point number field to the schema.
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
        def float name, description: nil, mode: :nullable,
                  policy_tags: nil, default_value_expression: nil
          add_field name, :float,
                    description: description,
                    mode: mode,
                    policy_tags: policy_tags,
                    default_value_expression: default_value_expression
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
        def numeric name, description: nil, mode: :nullable, policy_tags: nil,
                    precision: nil, scale: nil, default_value_expression: nil
          add_field name, :numeric,
                    description: description,
                    mode: mode,
                    policy_tags: policy_tags,
                    precision: precision,
                    scale: scale,
                    default_value_expression: default_value_expression
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
        def bignumeric name, description: nil, mode: :nullable, policy_tags: nil,
                       precision: nil, scale: nil, default_value_expression: nil
          add_field name, :bignumeric,
                    description: description,
                    mode: mode,
                    policy_tags: policy_tags,
                    precision: precision,
                    scale: scale,
                    default_value_expression: default_value_expression
        end

        ##
        # Adds a boolean field to the schema.
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
        def boolean name, description: nil, mode: :nullable, policy_tags: nil,
                    default_value_expression: nil
          add_field name, :boolean,
                    description: description,
                    mode: mode,
                    policy_tags: policy_tags,
                    default_value_expression: default_value_expression
        end

        ##
        # Adds a bytes field to the schema.
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
        def bytes name, description: nil, mode: :nullable,
                  policy_tags: nil, max_length: nil, default_value_expression: nil
          add_field name, :bytes,
                    description: description,
                    mode: mode,
                    policy_tags: policy_tags,
                    max_length: max_length,
                    default_value_expression: default_value_expression
        end

        ##
        # Adds a timestamp field to the schema.
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
        def timestamp name, description: nil, mode: :nullable,
                      policy_tags: nil, default_value_expression: nil
          add_field name, :timestamp,
                    description: description,
                    mode: mode,
                    policy_tags: policy_tags,
                    default_value_expression: default_value_expression
        end

        ##
        # Adds a time field to the schema.
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
        def time name, description: nil, mode: :nullable,
                 policy_tags: nil, default_value_expression: nil
          add_field name, :time,
                    description: description,
                    mode: mode,
                    policy_tags: policy_tags,
                    default_value_expression: default_value_expression
        end

        ##
        # Adds a datetime field to the schema.
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
        def datetime name, description: nil, mode: :nullable,
                     policy_tags: nil, default_value_expression: nil
          add_field name, :datetime,
                    description: description,
                    mode: mode,
                    policy_tags: policy_tags,
                    default_value_expression: default_value_expression
        end

        ##
        # Adds a date field to the schema.
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
        def date name, description: nil, mode: :nullable,
                 policy_tags: nil, default_value_expression: nil
          add_field name, :date,
                    description: description,
                    mode: mode,
                    policy_tags: policy_tags,
                    default_value_expression: default_value_expression
        end

        ##
        # Adds a geography field to the schema.
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
        def geography name, description: nil, mode: :nullable,
                      policy_tags: nil, default_value_expression: nil
          add_field name, :geography,
                    description: description,
                    mode: mode,
                    policy_tags: policy_tags,
                    default_value_expression: default_value_expression
        end

        ##
        # Adds a JSON field to the schema.
        #
        # @see https://cloud.google.com/bigquery/docs/reference/standard-sql/data-types#json_type
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
        def json name, description: nil, mode: :nullable,
                 policy_tags: nil, default_value_expression: nil
          add_field name, :json,
                    description: description,
                    mode: mode,
                    policy_tags: policy_tags,
                    default_value_expression: default_value_expression
        end

        ##
        # Adds a record field to the schema. A block must be passed describing
        # the nested fields of the record. For more information about nested
        # and repeated records, see [Loading denormalized, nested, and repeated
        # data
        # ](https://cloud.google.com/bigquery/docs/loading-data#loading_denormalized_nested_and_repeated_data).
        #
        # @param [String] name The field name. The name must contain only
        #   letters (`[A-Za-z]`), numbers (`[0-9]`), or underscores (`_`), and must
        #   start with a letter or underscore. The maximum length is 128
        #   characters.
        # @param [String] description A description of the field.
        # @param [Symbol] mode The field's mode. The possible values are
        #   `:nullable`, `:required`, and `:repeated`. The default value is
        #   `:nullable`.
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
        # @yield [field] a block for setting the nested record's schema
        # @yieldparam [Field] field the object accepting the
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
        #       cities_lived.string "place", mode: :required
        #       cities_lived.integer "number_of_years", mode: :required
        #     end
        #   end
        #
        def record name, description: nil, mode: nil,
                   default_value_expression: nil
          # TODO: do we need to raise if no block was given?
          raise ArgumentError, "a block is required" unless block_given?

          nested_field = add_field name, :record,
                                   description: description,
                                   mode: mode,
                                   default_value_expression: default_value_expression
          yield nested_field
          nested_field
        end

        # @private
        def changed?
          return false if frozen?
          @original_json != @gapi.to_json
        end

        # @private
        # @param [Google::Apis::BigqueryV2::TableSchema, nil] gapi Returns an
        #   empty schema if nil or no arg is provided. The default is nil.
        #
        def self.from_gapi gapi = nil
          gapi ||= Google::Apis::BigqueryV2::TableSchema.new fields: []
          gapi.fields ||= []
          new.tap do |s|
            s.instance_variable_set :@gapi, gapi
            s.instance_variable_set :@original_json, gapi.to_json
          end
        end

        # @private
        def to_gapi
          @gapi
        end

        # @private
        def == other
          return false unless other.is_a? Schema
          to_gapi.to_json == other.to_gapi.to_json
        end

        protected

        def frozen_check!
          return unless frozen?
          raise ArgumentError, "Cannot modify a frozen schema"
        end

        def add_field name,
                      type,
                      description: nil,
                      mode: :nullable,
                      policy_tags: nil,
                      max_length: nil,
                      precision: nil,
                      scale: nil,
                      default_value_expression: nil
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
          new_gapi.default_value_expression = default_value_expression if default_value_expression
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
          raise ArgumentError, "Type '#{type}' not found" unless Field::TYPES.include? type
          type
        end

        def verify_mode mode
          mode = :nullable if mode.nil?
          mode = mode.to_s.upcase
          raise ArgumentError "Unable to determine mode for '#{mode}'" unless Field::MODES.include? mode
          mode
        end
      end
    end
  end
end
