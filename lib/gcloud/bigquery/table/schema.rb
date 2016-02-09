# Copyright 2015 Google Inc. All rights reserved.
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


module Gcloud
  module Bigquery
    class Table
      ##
      # # Table Schema
      #
      # A builder for BigQuery table schemas, passed to block arguments to
      # {Dataset#create_table} and {Table#schema}. Supports nested and
      # repeated fields via a nested block.
      #
      # @see https://cloud.google.com/bigquery/preparing-data-for-bigquery
      #   Preparing Data for BigQuery
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
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
        # @private
        MODES = %w( NULLABLE REQUIRED REPEATED )

        # @private
        TYPES = %w( STRING INTEGER FLOAT BOOLEAN TIMESTAMP RECORD )

        # @private
        attr_reader :fields

        ##
        # @private  Initializes a new schema object with an existing schema.
        def initialize schema = nil, nested = false
          fields = (schema && schema["fields"]) || []
          @original_fields = fields.dup
          @fields = fields.dup
          @nested = nested
        end

        # @private
        def changed?
          @original_fields != @fields
        end

        ##
        # @private
        # Returns the schema as hash containing the keys and values specified by
        # the Google Cloud BigQuery [Rest API
        # ](https://cloud.google.com/bigquery/docs/reference/v2/tables#resource)
        # .
        def schema
          {
            "fields" => @fields
          }
        end

        ##
        # Adds a string field to the schema.
        #
        # @param [String] name The field name. The name must contain only
        #   letters (a-z, A-Z), numbers (0-9), or underscores (_), and must
        #   start with a letter or underscore. The maximum length is 128
        #   characters.
        # @param [String] description A description of the field.
        # @param [Symbol] mode The field's mode. The possible values are
        #   `:nullable`, `:required`, and `:repeated`. The default value is
        #   `:nullable`.
        def string name, description: nil, mode: nil
          add_field name, :string, nil, description: description, mode: mode
        end

        ##
        # Adds an integer field to the schema.
        #
        # @param [String] name The field name. The name must contain only
        #   letters (a-z, A-Z), numbers (0-9), or underscores (_), and must
        #   start with a letter or underscore. The maximum length is 128
        #   characters.
        # @param [String] description A description of the field.
        # @param [Symbol] mode The field's mode. The possible values are
        #   `:nullable`, `:required`, and `:repeated`. The default value is
        #   `:nullable`.
        def integer name, description: nil, mode: nil
          add_field name, :integer, nil, description: description, mode: mode
        end

        ##
        # Adds a floating-point number field to the schema.
        #
        # @param [String] name The field name. The name must contain only
        #   letters (a-z, A-Z), numbers (0-9), or underscores (_), and must
        #   start with a letter or underscore. The maximum length is 128
        #   characters.
        # @param [String] description A description of the field.
        # @param [Symbol] mode The field's mode. The possible values are
        #   `:nullable`, `:required`, and `:repeated`. The default value is
        #   `:nullable`.
        def float name, description: nil, mode: nil
          add_field name, :float, nil, description: description, mode: mode
        end

        ##
        # Adds a boolean field to the schema.
        #
        # @param [String] name The field name. The name must contain only
        #   letters (a-z, A-Z), numbers (0-9), or underscores (_), and must
        #   start with a letter or underscore. The maximum length is 128
        #   characters.
        # @param [String] description A description of the field.
        # @param [Symbol] mode The field's mode. The possible values are
        #   `:nullable`, `:required`, and `:repeated`. The default value is
        #   `:nullable`.
        def boolean name, description: nil, mode: nil
          add_field name, :boolean, nil, description: description, mode: mode
        end

        ##
        # Adds a timestamp field to the schema.
        #
        # @param [String] name The field name. The name must contain only
        #   letters (a-z, A-Z), numbers (0-9), or underscores (_), and must
        #   start with a letter or underscore. The maximum length is 128
        #   characters.
        # @param [String] description A description of the field.
        # @param [Symbol] mode The field's mode. The possible values are
        #   `:nullable`, `:required`, and `:repeated`. The default value is
        #   `:nullable`.
        def timestamp name, description: nil, mode: nil
          add_field name, :timestamp, nil, description: description, mode: mode
        end

        ##
        # Adds a record field to the schema. A block must be passed describing
        # the nested fields of the record. For more information about nested
        # and repeated records, see [Preparing Data for BigQuery
        # ](https://cloud.google.com/bigquery/preparing-data-for-bigquery).
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
        # @yieldparam [Table::Schema] nested_schema the object accepting the
        #   nested schema
        #
        # @example
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   bigquery = gcloud.bigquery
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
          fail ArgumentError, "nested RECORD type is not permitted" if @nested
          fail ArgumentError, "a block is required" unless block_given?
          nested_schema = self.class.new nil, true
          yield nested_schema
          add_field name, :record, nested_schema.fields,
                    description: description, mode: mode
        end

        protected

        def upcase_type type
          upcase_type = type.to_s.upcase
          unless TYPES.include? upcase_type
            fail ArgumentError,
                 "Type '#{upcase_type}' not found in #{TYPES.inspect}"
          end
          upcase_type
        end

        def upcase_mode mode
          upcase_mode = mode.to_s.upcase
          unless MODES.include? upcase_mode
            fail ArgumentError "Unable to determine mode for '#{mode}'"
          end
          upcase_mode
        end

        def add_field name, type, nested_fields, description: nil,
                      mode: :nullable
          # Remove any existing field of this name
          @fields.reject! { |h| h["name"] == name }
          field = {
            "name" => name,
            "type" => upcase_type(type)
          }
          field["fields"]      = nested_fields     if nested_fields
          field["description"] = description       if description
          field["mode"]        = upcase_mode(mode) if mode
          @fields << field
        end
      end
    end
  end
end
