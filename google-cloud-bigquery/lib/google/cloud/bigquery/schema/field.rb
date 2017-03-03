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


module Google
  module Cloud
    module Bigquery
      class Schema
        ##
        # # Schema Field
        #
        # The fields of a table schema.
        #
        # @see https://cloud.google.com/bigquery/preparing-data-for-bigquery
        #   Preparing Data for BigQuery
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.table "my_table"
        #
        #   name_field = table.schema.field "name"
        #   name_field.required? #=> true
        class Field
          # @private
          MODES = %w( NULLABLE REQUIRED REPEATED )

          # @private
          TYPES = %w( STRING INTEGER FLOAT BOOLEAN BYTES TIMESTAMP TIME DATETIME
                      DATE RECORD )

          ##
          # The name of the field.
          #
          def name
            @gapi.name
          end

          ##
          # Updates the name of the field.
          #
          def name= new_name
            @gapi.update! name: String(new_name)
          end

          ##
          # The type of the field.
          #
          def type
            @gapi.type
          end

          ##
          # Updates the type of the field.
          #
          def type= new_type
            @gapi.update! type: verify_type(new_type)
          end

          ##
          # Checks if the type of the field is `NULLABLE`.
          def nullable?
            mode == "NULLABLE"
          end

          ##
          # Checks if the type of the field is `REQUIRED`.
          def required?
            mode == "REQUIRED"
          end

          ##
          # Checks if the type of the field is `REPEATED`.
          def repeated?
            mode == "REPEATED"
          end

          ##
          # The description of the field.
          #
          def description
            @gapi.description
          end

          ##
          # Updates the description of the field.
          #
          def description= new_description
            @gapi.update! description: new_description
          end

          ##
          # The mode of the field.
          #
          def mode
            @gapi.mode
          end

          ##
          # Updates the mode of the field.
          #
          def mode= new_mode
            @gapi.update! mode: verify_mode(new_mode)
          end

          ##
          # Checks if the mode of the field is `STRING`.
          def string?
            mode == "STRING"
          end

          ##
          # Checks if the mode of the field is `INTEGER`.
          def integer?
            mode == "INTEGER"
          end

          ##
          # Checks if the mode of the field is `FLOAT`.
          def float?
            mode == "FLOAT"
          end

          ##
          # Checks if the mode of the field is `BOOLEAN`.
          def boolean?
            mode == "BOOLEAN"
          end

          ##
          # Checks if the mode of the field is `BYTES`.
          def bytes?
            mode == "BYTES"
          end

          ##
          # Checks if the mode of the field is `TIMESTAMP`.
          def timestamp?
            mode == "TIMESTAMP"
          end

          ##
          # Checks if the mode of the field is `TIME`.
          def time?
            mode == "TIME"
          end

          ##
          # Checks if the mode of the field is `DATETIME`.
          def datetime?
            mode == "DATETIME"
          end

          ##
          # Checks if the mode of the field is `DATE`.
          def date?
            mode == "DATE"
          end

          ##
          # Checks if the mode of the field is `RECORD`.
          def record?
            mode == "RECORD"
          end

          ##
          # The nested fields if the type property is set to `RECORD`. Will be
          # empty otherwise.
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
          def headers
            fields.map(&:name).map(&:to_sym)
          end

          ##
          # Retreive a nested fields by name, if the type property is
          # set to `RECORD`. Will return `nil` otherwise.
          def field name
            f = fields.find { |fld| fld.name == name.to_s }
            return nil if f.nil?
            yield f if block_given?
            f
          end

          ##
          # Adds a string field to the schema.
          #
          # This can only be called on fields that are of type `RECORD`.
          #
          # @param [String] name The field name. The name must contain only
          #   letters (a-z, A-Z), numbers (0-9), or underscores (_), and must
          #   start with a letter or underscore. The maximum length is 128
          #   characters.
          # @param [String] description A description of the field.
          # @param [Symbol] mode The field's mode. The possible values are
          #   `:nullable`, `:required`, and `:repeated`. The default value is
          #   `:nullable`.
          def string name, description: nil, mode: :nullable
            record_check!

            add_field name, :string, description: description, mode: mode
          end

          ##
          # Adds an integer field to the schema.
          #
          # This can only be called on fields that are of type `RECORD`.
          #
          # @param [String] name The field name. The name must contain only
          #   letters (a-z, A-Z), numbers (0-9), or underscores (_), and must
          #   start with a letter or underscore. The maximum length is 128
          #   characters.
          # @param [String] description A description of the field.
          # @param [Symbol] mode The field's mode. The possible values are
          #   `:nullable`, `:required`, and `:repeated`. The default value is
          #   `:nullable`.
          def integer name, description: nil, mode: :nullable
            record_check!

            add_field name, :integer, description: description, mode: mode
          end

          ##
          # Adds a floating-point number field to the schema.
          #
          # This can only be called on fields that are of type `RECORD`.
          #
          # @param [String] name The field name. The name must contain only
          #   letters (a-z, A-Z), numbers (0-9), or underscores (_), and must
          #   start with a letter or underscore. The maximum length is 128
          #   characters.
          # @param [String] description A description of the field.
          # @param [Symbol] mode The field's mode. The possible values are
          #   `:nullable`, `:required`, and `:repeated`. The default value is
          #   `:nullable`.
          def float name, description: nil, mode: :nullable
            record_check!

            add_field name, :float, description: description, mode: mode
          end

          ##
          # Adds a boolean field to the schema.
          #
          # This can only be called on fields that are of type `RECORD`.
          #
          # @param [String] name The field name. The name must contain only
          #   letters (a-z, A-Z), numbers (0-9), or underscores (_), and must
          #   start with a letter or underscore. The maximum length is 128
          #   characters.
          # @param [String] description A description of the field.
          # @param [Symbol] mode The field's mode. The possible values are
          #   `:nullable`, `:required`, and `:repeated`. The default value is
          #   `:nullable`.
          def boolean name, description: nil, mode: :nullable
            record_check!

            add_field name, :boolean, description: description, mode: mode
          end

          ##
          # Adds a bytes field to the schema.
          #
          # This can only be called on fields that are of type `RECORD`.
          #
          # @param [String] name The field name. The name must contain only
          #   letters (a-z, A-Z), numbers (0-9), or underscores (_), and must
          #   start with a letter or underscore. The maximum length is 128
          #   characters.
          # @param [String] description A description of the field.
          # @param [Symbol] mode The field's mode. The possible values are
          #   `:nullable`, `:required`, and `:repeated`. The default value is
          #   `:nullable`.
          def bytes name, description: nil, mode: :nullable
            record_check!

            add_field name, :bytes, description: description, mode: mode
          end

          ##
          # Adds a timestamp field to the schema.
          #
          # This can only be called on fields that are of type `RECORD`.
          #
          # @param [String] name The field name. The name must contain only
          #   letters (a-z, A-Z), numbers (0-9), or underscores (_), and must
          #   start with a letter or underscore. The maximum length is 128
          #   characters.
          # @param [String] description A description of the field.
          # @param [Symbol] mode The field's mode. The possible values are
          #   `:nullable`, `:required`, and `:repeated`. The default value is
          #   `:nullable`.
          def timestamp name, description: nil, mode: :nullable
            record_check!

            add_field name, :timestamp, description: description, mode: mode
          end

          ##
          # Adds a time field to the schema.
          #
          # This can only be called on fields that are of type `RECORD`.
          #
          # @param [String] name The field name. The name must contain only
          #   letters (a-z, A-Z), numbers (0-9), or underscores (_), and must
          #   start with a letter or underscore. The maximum length is 128
          #   characters.
          # @param [String] description A description of the field.
          # @param [Symbol] mode The field's mode. The possible values are
          #   `:nullable`, `:required`, and `:repeated`. The default value is
          #   `:nullable`.
          def time name, description: nil, mode: :nullable
            record_check!

            add_field name, :time, description: description, mode: mode
          end

          ##
          # Adds a datetime field to the schema.
          #
          # This can only be called on fields that are of type `RECORD`.
          #
          # @param [String] name The field name. The name must contain only
          #   letters (a-z, A-Z), numbers (0-9), or underscores (_), and must
          #   start with a letter or underscore. The maximum length is 128
          #   characters.
          # @param [String] description A description of the field.
          # @param [Symbol] mode The field's mode. The possible values are
          #   `:nullable`, `:required`, and `:repeated`. The default value is
          #   `:nullable`.
          def datetime name, description: nil, mode: :nullable
            record_check!

            add_field name, :datetime, description: description, mode: mode
          end

          ##
          # Adds a date field to the schema.
          #
          # This can only be called on fields that are of type `RECORD`.
          #
          # @param [String] name The field name. The name must contain only
          #   letters (a-z, A-Z), numbers (0-9), or underscores (_), and must
          #   start with a letter or underscore. The maximum length is 128
          #   characters.
          # @param [String] description A description of the field.
          # @param [Symbol] mode The field's mode. The possible values are
          #   `:nullable`, `:required`, and `:repeated`. The default value is
          #   `:nullable`.
          def date name, description: nil, mode: :nullable
            record_check!

            add_field name, :date, description: description, mode: mode
          end

          ##
          # Adds a record field to the schema. A block must be passed describing
          # the nested fields of the record. For more information about nested
          # and repeated records, see [Preparing Data for BigQuery
          # ](https://cloud.google.com/bigquery/preparing-data-for-bigquery).
          #
          # This can only be called on fields that are of type `RECORD`.
          #
          # @param [String] name The field name. The name must contain only
          #   letters (a-z, A-Z), numbers (0-9), or underscores (_), and must
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
          #       cities_lived.string "place", mode: :required
          #       cities_lived.integer "number_of_years", mode: :required
          #     end
          #   end
          #
          def record name, description: nil, mode: nil
            record_check!

            # TODO: do we need to fail if no block was given?
            fail ArgumentError, "a block is required" unless block_given?

            nested_field = add_field name, :record, description: description,
                                                    mode: mode
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

          protected

          def frozen_check!
            return unless frozen?
            fail ArgumentError, "Cannot modify a frozen field"
          end

          def record_check!
            return unless type != "RECORD"
            fail ArgumentError,
                 "Cannot add fields to a non-RECORD field (#{type})"
          end

          def add_field name, type, description: nil, mode: :nullable
            frozen_check!

            new_gapi = Google::Apis::BigqueryV2::TableFieldSchema.new(
              name: String(name),
              type: verify_type(type),
              description: description,
              mode: verify_mode(mode),
              fields: [])

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
            unless TYPES.include? type
              fail ArgumentError,
                   "Type '#{type}' not found in #{TYPES.inspect}"
            end
            type
          end

          def verify_mode mode
            mode = :nullable if mode.nil?
            mode = mode.to_s.upcase
            unless MODES.include? mode
              fail ArgumentError "Unable to determine mode for '#{mode}'"
            end
            mode
          end
        end
      end
    end
  end
end
