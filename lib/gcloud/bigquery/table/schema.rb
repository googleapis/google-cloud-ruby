#--
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
      # Table::Schema is a builder for a BigQuery table schema. It enables a
      # "dirty check" comparison of the newly built schema with a provided
      # existing schema.
      #
      # Every table is defined by a schema
      # that may contain nested and repeated fields. (For more information
      # about nested and repeated fields, see {Preparing Data for BigQuery
      # }[https://cloud.google.com/bigquery/preparing-data-for-bigquery].)
      #
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
      #   table.schema #=> {
      #     "fields" => [
      #       {
      #         "name" => "first_name",
      #         "type" => "STRING",
      #         "mode" => "REQUIRED"
      #       },
      #       {
      #         "name" => "cities_lived",
      #         "type" => "RECORD",
      #         "mode" => "REPEATED",
      #         "fields" => [
      #           {
      #             "name" => "place",
      #             "type" => "STRING",
      #             "mode" => "REQUIRED"
      #           },
      #           {
      #             "name" => "number_of_years",
      #             "type" => "INTEGER",
      #             "mode" => "REQUIRED"
      #           }
      #         ]
      #       }
      #     ]
      #   }
      #
      class Schema
        MODES = %w( NULLABLE REQUIRED REPEATED )
        TYPES = %w( STRING INTEGER FLOAT BOOLEAN TIMESTAMP RECORD )

        attr_reader :fields #:nodoc:

        ##
        # Initializes a new schema object with an existing schema.
        def initialize schema = nil, nested = false
          fields = (schema && schema["fields"]) || []
          @original_fields = fields.dup
          @fields = fields.dup
          @nested = nested
        end

        def changed? #:nodoc:
          @original_fields != @fields
        end

        def schema
          {
            "fields" => @fields
          }
        end

        def string name, options = {}
          add_field name, :string, nil, options
        end

        def integer name, options = {}
          add_field name, :integer, nil, options
        end

        def float name, options = {}
          add_field name, :float, nil, options
        end

        def boolean name, options = {}
          add_field name, :boolean, nil, options
        end

        def timestamp name, options = {}
          add_field name, :timestamp, nil, options
        end

        def record name, options = {}
          fail ArgumentError, "nested RECORD type is not permitted" if @nested
          fields = if block_given?
                     nested_schema = self.class.new nil, true
                     yield nested_schema
                     nested_schema.changed? ? nested_schema.fields : nil
                   end
          add_field name, :record, fields, options
        end

        protected

        def upcase_type type #:nodoc:
          upcase_type = type.to_s.upcase
          unless TYPES.include? upcase_type
            fail ArgumentError,
                 "Type '#{upcase_type}' not found in #{TYPES.inspect}"
          end
          upcase_type
        end

        def upcase_mode mode #:nodoc:
          upcase_mode = mode.to_s.upcase
          unless MODES.include? upcase_mode
            fail ArgumentError "Unable to determine mode for '#{mode}'"
          end
          upcase_mode
        end

        def add_field name, type, nested_fields, options
          # Remove any existing field of this name
          @fields.reject! { |h| h["name"] == name }
          field = {
            "name" => name,
            "type" => upcase_type(type)
          }
          field["mode"] = upcase_mode(options[:mode]) if options[:mode]
          field["description"] =options[:description] if options[:description]
          field["fields"] = nested_fields if nested_fields
          @fields << field
        end
      end
    end
  end
end
