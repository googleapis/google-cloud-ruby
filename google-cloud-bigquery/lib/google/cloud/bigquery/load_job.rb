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


require "google/cloud/bigquery/service"
require "google/cloud/bigquery/encryption_configuration"

module Google
  module Cloud
    module Bigquery
      ##
      # # LoadJob
      #
      # A {Job} subclass representing a load operation that may be performed
      # on a {Table}. A LoadJob instance is created when you call
      # {Table#load_job}.
      #
      # @see https://cloud.google.com/bigquery/loading-data
      #   Loading Data Into BigQuery
      # @see https://cloud.google.com/bigquery/docs/reference/v2/jobs Jobs API
      #   reference
      #
      # @example
      #   require "google/cloud/bigquery"
      #
      #   bigquery = Google::Cloud::Bigquery.new
      #   dataset = bigquery.dataset "my_dataset"
      #
      #   gs_url = "gs://my-bucket/file-name.csv"
      #   load_job = dataset.load_job "my_new_table", gs_url do |schema|
      #     schema.string "first_name", mode: :required
      #     schema.record "cities_lived", mode: :repeated do |nested_schema|
      #       nested_schema.string "place", mode: :required
      #       nested_schema.integer "number_of_years", mode: :required
      #     end
      #   end
      #
      #   load_job.wait_until_done!
      #   load_job.done? #=> true
      #
      #
      class LoadJob < Job
        ##
        # The URI or URIs representing the Google Cloud Storage files from which
        # the operation loads data.
        def sources
          Array @gapi.configuration.load.source_uris
        end

        ##
        # The table into which the operation loads data. This is the table on
        # which {Table#load_job} was invoked.
        #
        # @return [Table] A table instance.
        #
        def destination
          table = @gapi.configuration.load.destination_table
          return nil unless table
          retrieve_table table.project_id,
                         table.dataset_id,
                         table.table_id
        end

        ##
        # The delimiter used between fields in the source data. The default is a
        # comma (,).
        #
        # @return [String] A string containing the character, such as `","`.
        #
        def delimiter
          @gapi.configuration.load.field_delimiter || ","
        end

        ##
        # The number of rows at the top of a CSV file that BigQuery will skip
        # when loading the data. The default value is 0. This property is useful
        # if you have header rows in the file that should be skipped.
        #
        # @return [Integer] The number of header rows at the top of a CSV file
        #   to skip.
        #
        def skip_leading_rows
          @gapi.configuration.load.skip_leading_rows || 0
        end

        ##
        # Checks if the character encoding of the data is UTF-8. This is the
        # default.
        #
        # @return [Boolean] `true` when the character encoding is UTF-8,
        #   `false` otherwise.
        #
        def utf8?
          val = @gapi.configuration.load.encoding
          return true if val.nil?
          val == "UTF-8"
        end

        ##
        # Checks if the character encoding of the data is ISO-8859-1.
        #
        # @return [Boolean] `true` when the character encoding is ISO-8859-1,
        #   `false` otherwise.
        #
        def iso8859_1?
          val = @gapi.configuration.load.encoding
          val == "ISO-8859-1"
        end

        ##
        # The value that is used to quote data sections in a CSV file. The
        # default value is a double-quote (`"`). If your data does not contain
        # quoted sections, the value should be an empty string. If your data
        # contains quoted newline characters, {#quoted_newlines?} should return
        # `true`.
        #
        # @return [String] A string containing the character, such as `"\""`.
        #
        def quote
          val = @gapi.configuration.load.quote
          val = "\"" if val.nil?
          val
        end

        ##
        # The maximum number of bad records that the load operation can ignore.
        # If the number of bad records exceeds this value, an error is returned.
        # The default value is `0`, which requires that all records be valid.
        #
        # @return [Integer] The maximum number of bad records.
        #
        def max_bad_records
          val = @gapi.configuration.load.max_bad_records
          val = 0 if val.nil?
          val
        end

        ##
        # Specifies a string that represents a null value in a CSV file. For
        # example, if you specify `\N`, BigQuery interprets `\N` as a null value
        # when loading a CSV file. The default value is the empty string. If you
        # set this property to a custom value, BigQuery throws an error if an
        # empty string is present for all data types except for STRING and BYTE.
        # For STRING and BYTE columns, BigQuery interprets the empty string as
        # an empty value.
        #
        # @return [String] A string representing null value in a CSV file.
        #
        def null_marker
          val = @gapi.configuration.load.null_marker
          val = "" if val.nil?
          val
        end

        ##
        # Checks if quoted data sections may contain newline characters in a CSV
        # file. The default is `false`.
        #
        # @return [Boolean] `true` when quoted newlines are allowed, `false`
        #   otherwise.
        #
        def quoted_newlines?
          val = @gapi.configuration.load.allow_quoted_newlines
          val = false if val.nil?
          val
        end

        ##
        # Checks if BigQuery should automatically infer the options and schema
        # for CSV and JSON sources. The default is `false`.
        #
        # @return [Boolean] `true` when autodetect is enabled, `false`
        #   otherwise.
        #
        def autodetect?
          val = @gapi.configuration.load.autodetect
          val = false if val.nil?
          val
        end

        ##
        # Checks if the format of the source data is [newline-delimited
        # JSON](http://jsonlines.org/). The default is `false`.
        #
        # @return [Boolean] `true` when the source format is
        #   `NEWLINE_DELIMITED_JSON`, `false` otherwise.
        #
        def json?
          val = @gapi.configuration.load.source_format
          val == "NEWLINE_DELIMITED_JSON"
        end

        ##
        # Checks if the format of the source data is CSV. The default is `true`.
        #
        # @return [Boolean] `true` when the source format is `CSV`, `false`
        #   otherwise.
        #
        def csv?
          val = @gapi.configuration.load.source_format
          return true if val.nil?
          val == "CSV"
        end

        ##
        # Checks if the source data is a Google Cloud Datastore backup.
        #
        # @return [Boolean] `true` when the source format is `DATASTORE_BACKUP`,
        #   `false` otherwise.
        #
        def backup?
          val = @gapi.configuration.load.source_format
          val == "DATASTORE_BACKUP"
        end

        ##
        # Checks if the load operation accepts rows that are missing trailing
        # optional columns. The missing values are treated as nulls. If `false`,
        # records with missing trailing columns are treated as bad records, and
        # if there are too many bad records, an error is returned. The default
        # value is `false`. Only applicable to CSV, ignored for other formats.
        #
        # @return [Boolean] `true` when jagged rows are allowed, `false`
        #   otherwise.
        #
        def allow_jagged_rows?
          val = @gapi.configuration.load.allow_jagged_rows
          val = false if val.nil?
          val
        end

        ##
        # Checks if the load operation allows extra values that are not
        # represented in the table schema. If `true`, the extra values are
        # ignored. If `false`, records with extra columns are treated as bad
        # records, and if there are too many bad records, an invalid error is
        # returned. The default is `false`.
        #
        # @return [Boolean] `true` when unknown values are ignored, `false`
        #   otherwise.
        #
        def ignore_unknown_values?
          val = @gapi.configuration.load.ignore_unknown_values
          val = false if val.nil?
          val
        end

        ##
        # The schema for the destination table. The schema can be omitted if the
        # destination table already exists, or if you're loading data from
        # Google Cloud Datastore.
        #
        # The returned object is frozen and changes are not allowed. Use
        # {Table#schema} to update the schema.
        #
        # @return [Schema, nil] A schema object, or `nil`.
        #
        def schema
          Schema.from_gapi(@gapi.configuration.load.schema).freeze
        end

        ##
        # Allows the schema of the destination table to be updated as a side
        # effect of the load job if a schema is autodetected or supplied in the
        # job configuration. Schema update options are supported in two cases:
        # when write disposition is `WRITE_APPEND`; when write disposition is
        # `WRITE_TRUNCATE` and the destination table is a partition of a table,
        # specified by partition decorators. For normal tables, `WRITE_TRUNCATE`
        # will always overwrite the schema. One or more of the following values
        # are specified:
        #
        # * `ALLOW_FIELD_ADDITION`: allow adding a nullable field to the schema.
        # * `ALLOW_FIELD_RELAXATION`: allow relaxing a required field in the
        #   original schema to nullable.
        #
        # @return [Array<String>] An array of strings.
        #
        def schema_update_options
          Array @gapi.configuration.load.schema_update_options
        end

        ##
        # The number of source data files in the load job.
        #
        # @return [Integer] The number of source files.
        #
        def input_files
          Integer @gapi.statistics.load.input_files
        rescue StandardError
          nil
        end

        ##
        # The number of bytes of source data in the load job.
        #
        # @return [Integer] The number of bytes.
        #
        def input_file_bytes
          Integer @gapi.statistics.load.input_file_bytes
        rescue StandardError
          nil
        end

        ##
        # The number of rows that have been loaded into the table. While an
        # import job is in the running state, this value may change.
        #
        # @return [Integer] The number of rows that have been loaded.
        #
        def output_rows
          Integer @gapi.statistics.load.output_rows
        rescue StandardError
          nil
        end

        ##
        # The encryption configuration of the destination table.
        #
        # @return [Google::Cloud::BigQuery::EncryptionConfiguration] Custom
        #   encryption configuration (e.g., Cloud KMS keys).
        #
        # @!group Attributes
        def encryption
          EncryptionConfiguration.from_gapi(
            @gapi.configuration.load.destination_encryption_configuration
          )
        end

        ##
        # The number of bytes that have been loaded into the table. While an
        # import job is in the running state, this value may change.
        #
        # @return [Integer] The number of bytes that have been loaded.
        #
        def output_bytes
          Integer @gapi.statistics.load.output_bytes
        rescue StandardError
          nil
        end

        ##
        # Yielded to a block to accumulate changes for a patch request.
        class Updater < LoadJob
          ##
          # A list of attributes that were updated.
          attr_reader :updates

          ##
          # @private Create an Updater object.
          def initialize gapi
            @updates = []
            @gapi = gapi
            @schema = nil
          end

          ##
          # Returns the table's schema. This method can also be used to set,
          # replace, or add to the schema by passing a block. See {Schema} for
          # available methods.
          #
          # @param [Boolean] replace Whether to replace the existing schema with
          #   the new schema. If `true`, the fields will replace the existing
          #   schema. If `false`, the fields will be added to the existing
          #   schema. When a table already contains data, schema changes must be
          #   additive. Thus, the default value is `false`.
          # @yield [schema] a block for setting the schema
          # @yieldparam [Schema] schema the object accepting the schema
          #
          # @return [Google::Cloud::Bigquery::Schema]
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |j|
          #     j.schema do |s|
          #       s.string "first_name", mode: :required
          #       s.record "cities_lived", mode: :repeated do |r|
          #         r.string "place", mode: :required
          #         r.integer "number_of_years", mode: :required
          #       end
          #     end
          #   end
          #
          # @!group Schema
          #
          def schema replace: false
            # Same as Table#schema, but not frozen
            # TODO: make sure to call ensure_full_data! on Dataset#update
            @schema ||= Schema.from_gapi @gapi.configuration.load.schema
            if block_given?
              @schema = Schema.from_gapi if replace
              yield @schema
              check_for_mutated_schema!
            end
            # Do not freeze on updater, allow modifications
            @schema
          end

          ##
          # Sets the schema of the destination table.
          #
          # @param [Google::Cloud::Bigquery::Schema] new_schema The schema for
          #   the destination table. Optional. The schema can be omitted if the
          #   destination table already exists, or if you're loading data from a
          #   source that includes a schema, such as Avro or a Google Cloud
          #   Datastore backup.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   schema = bigquery.schema do |s|
          #     s.string "first_name", mode: :required
          #     s.record "cities_lived", mode: :repeated do |nested_schema|
          #       nested_schema.string "place", mode: :required
          #       nested_schema.integer "number_of_years", mode: :required
          #     end
          #   end
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |j|
          #     j.schema = schema
          #   end
          #
          # @!group Schema
          #
          def schema= new_schema
            @schema = new_schema
          end

          ##
          # Adds a string field to the schema.
          #
          # See {Schema#string}.
          #
          # @param [String] name The field name. The name must contain only
          #   letters (a-z, A-Z), numbers (0-9), or underscores (_), and must
          #   start with a letter or underscore. The maximum length is 128
          #   characters.
          # @param [String] description A description of the field.
          # @param [Symbol] mode The field's mode. The possible values are
          #   `:nullable`, `:required`, and `:repeated`. The default value is
          #   `:nullable`.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |schema|
          #     schema.string "first_name", mode: :required
          #   end
          #
          # @!group Schema
          def string name, description: nil, mode: :nullable
            schema.string name, description: description, mode: mode
          end

          ##
          # Adds an integer field to the schema.
          #
          # See {Schema#integer}.
          #
          # @param [String] name The field name. The name must contain only
          #   letters (a-z, A-Z), numbers (0-9), or underscores (_), and must
          #   start with a letter or underscore. The maximum length is 128
          #   characters.
          # @param [String] description A description of the field.
          # @param [Symbol] mode The field's mode. The possible values are
          #   `:nullable`, `:required`, and `:repeated`. The default value is
          #   `:nullable`.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |schema|
          #     schema.integer "age", mode: :required
          #   end
          #
          # @!group Schema
          def integer name, description: nil, mode: :nullable
            schema.integer name, description: description, mode: mode
          end

          ##
          # Adds a floating-point number field to the schema.
          #
          # See {Schema#float}.
          #
          # @param [String] name The field name. The name must contain only
          #   letters (a-z, A-Z), numbers (0-9), or underscores (_), and must
          #   start with a letter or underscore. The maximum length is 128
          #   characters.
          # @param [String] description A description of the field.
          # @param [Symbol] mode The field's mode. The possible values are
          #   `:nullable`, `:required`, and `:repeated`. The default value is
          #   `:nullable`.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |schema|
          #     schema.float "price", mode: :required
          #   end
          #
          # @!group Schema
          def float name, description: nil, mode: :nullable
            schema.float name, description: description, mode: mode
          end

          ##
          # Adds a boolean field to the schema.
          #
          # See {Schema#boolean}.
          #
          # @param [String] name The field name. The name must contain only
          #   letters (a-z, A-Z), numbers (0-9), or underscores (_), and must
          #   start with a letter or underscore. The maximum length is 128
          #   characters.
          # @param [String] description A description of the field.
          # @param [Symbol] mode The field's mode. The possible values are
          #   `:nullable`, `:required`, and `:repeated`. The default value is
          #   `:nullable`.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |schema|
          #     schema.boolean "active", mode: :required
          #   end
          #
          # @!group Schema
          def boolean name, description: nil, mode: :nullable
            schema.boolean name, description: description, mode: mode
          end

          ##
          # Adds a bytes field to the schema.
          #
          # See {Schema#bytes}.
          #
          # @param [String] name The field name. The name must contain only
          #   letters (a-z, A-Z), numbers (0-9), or underscores (_), and must
          #   start with a letter or underscore. The maximum length is 128
          #   characters.
          # @param [String] description A description of the field.
          # @param [Symbol] mode The field's mode. The possible values are
          #   `:nullable`, `:required`, and `:repeated`. The default value is
          #   `:nullable`.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |schema|
          #     schema.bytes "avatar", mode: :required
          #   end
          #
          # @!group Schema
          def bytes name, description: nil, mode: :nullable
            schema.bytes name, description: description, mode: mode
          end

          ##
          # Adds a timestamp field to the schema.
          #
          # See {Schema#timestamp}.
          #
          # @param [String] name The field name. The name must contain only
          #   letters (a-z, A-Z), numbers (0-9), or underscores (_), and must
          #   start with a letter or underscore. The maximum length is 128
          #   characters.
          # @param [String] description A description of the field.
          # @param [Symbol] mode The field's mode. The possible values are
          #   `:nullable`, `:required`, and `:repeated`. The default value is
          #   `:nullable`.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |schema|
          #     schema.timestamp "creation_date", mode: :required
          #   end
          #
          # @!group Schema
          def timestamp name, description: nil, mode: :nullable
            schema.timestamp name, description: description, mode: mode
          end

          ##
          # Adds a time field to the schema.
          #
          # See {Schema#time}.
          #
          # @param [String] name The field name. The name must contain only
          #   letters (a-z, A-Z), numbers (0-9), or underscores (_), and must
          #   start with a letter or underscore. The maximum length is 128
          #   characters.
          # @param [String] description A description of the field.
          # @param [Symbol] mode The field's mode. The possible values are
          #   `:nullable`, `:required`, and `:repeated`. The default value is
          #   `:nullable`.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |schema|
          #     schema.time "duration", mode: :required
          #   end
          #
          # @!group Schema
          def time name, description: nil, mode: :nullable
            schema.time name, description: description, mode: mode
          end

          ##
          # Adds a datetime field to the schema.
          #
          # See {Schema#datetime}.
          #
          # @param [String] name The field name. The name must contain only
          #   letters (a-z, A-Z), numbers (0-9), or underscores (_), and must
          #   start with a letter or underscore. The maximum length is 128
          #   characters.
          # @param [String] description A description of the field.
          # @param [Symbol] mode The field's mode. The possible values are
          #   `:nullable`, `:required`, and `:repeated`. The default value is
          #   `:nullable`.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |schema|
          #     schema.datetime "target_end", mode: :required
          #   end
          #
          # @!group Schema
          def datetime name, description: nil, mode: :nullable
            schema.datetime name, description: description, mode: mode
          end

          ##
          # Adds a date field to the schema.
          #
          # See {Schema#date}.
          #
          # @param [String] name The field name. The name must contain only
          #   letters (a-z, A-Z), numbers (0-9), or underscores (_), and must
          #   start with a letter or underscore. The maximum length is 128
          #   characters.
          # @param [String] description A description of the field.
          # @param [Symbol] mode The field's mode. The possible values are
          #   `:nullable`, `:required`, and `:repeated`. The default value is
          #   `:nullable`.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |schema|
          #     schema.date "birthday", mode: :required
          #   end
          #
          # @!group Schema
          def date name, description: nil, mode: :nullable
            schema.date name, description: description, mode: mode
          end

          ##
          # Adds a record field to the schema. A block must be passed describing
          # the nested fields of the record. For more information about nested
          # and repeated records, see [Preparing Data for BigQuery
          # ](https://cloud.google.com/bigquery/preparing-data-for-bigquery).
          #
          # See {Schema#record}.
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
          #   job = dataset.load_job "my_table", "gs://abc/file" do |schema|
          #     schema.record "cities_lived", mode: :repeated do |cities_lived|
          #       cities_lived.string "place", mode: :required
          #       cities_lived.integer "number_of_years", mode: :required
          #     end
          #   end
          #
          # @!group Schema
          #
          def record name, description: nil, mode: nil, &block
            schema.record name, description: description, mode: mode, &block
          end

          ##
          # Make sure any access changes are saved
          def check_for_mutated_schema!
            return if @schema.nil?
            return unless @schema.changed?
            @gapi.configuration.load.schema = @schema.to_gapi
            patch_gapi! :schema
          end

          ##
          # Sets the geographic location where the job should run. Required
          # except for US and EU.
          #
          # @param [String] value  A geographic location, such as "US", "EU" or
          #   "asia-northeast1". Required except for US and EU.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |j|
          #     j.schema do |s|
          #       s.string "first_name", mode: :required
          #       s.record "cities_lived", mode: :repeated do |r|
          #         r.string "place", mode: :required
          #         r.integer "number_of_years", mode: :required
          #       end
          #     end
          #     j.location = "EU"
          #   end
          #
          # @!group Attributes
          def location= value
            @gapi.job_reference.location = value
            return unless value.nil?

            # Treat assigning value of nil the same as unsetting the value.
            unset = @gapi.job_reference.instance_variables.include? :@location
            @gapi.job_reference.remove_instance_variable :@location if unset
          end

          ##
          # Sets the source file format. The default value is `csv`.
          #
          # The following values are supported:
          #
          # * `csv` - CSV
          # * `json` - [Newline-delimited JSON](http://jsonlines.org/)
          # * `avro` - [Avro](http://avro.apache.org/)
          # * `parquet` - [Parquet](https://parquet.apache.org/)
          # * `datastore_backup` - Cloud Datastore backup
          #
          # @param [String] new_format The new source format.
          #
          # @!group Attributes
          #
          def format= new_format
            @gapi.configuration.load.update! source_format:
              Convert.source_format(new_format)
          end

          ##
          # Sets the create disposition.
          #
          # This specifies whether the job is allowed to create new tables. The
          # default value is `needed`.
          #
          # The following values are supported:
          #
          # * `needed` - Create the table if it does not exist.
          # * `never` - The table must already exist. A 'notFound' error is
          #             raised if the table does not exist.
          #
          # @param [String] new_create The new create disposition.
          #
          # @!group Attributes
          #
          def create= new_create
            @gapi.configuration.load.update! create_disposition:
              Convert.create_disposition(new_create)
          end

          ##
          # Sets the write disposition.
          #
          # This specifies how to handle data already present in the table. The
          # default value is `append`.
          #
          # The following values are supported:
          #
          # * `truncate` - BigQuery overwrites the table data.
          # * `append` - BigQuery appends the data to the table.
          # * `empty` - An error will be returned if the table already contains
          #   data.
          #
          # @param [String] new_write The new write disposition.
          #
          # @!group Attributes
          #
          def write= new_write
            @gapi.configuration.load.update! write_disposition:
              Convert.write_disposition(new_write)
          end

          ##
          # Sets the projection fields.
          #
          # If the `format` option is set to `datastore_backup`, indicates
          # which entity properties to load from a Cloud Datastore backup.
          # Property names are case sensitive and must be top-level properties.
          # If not set, BigQuery loads all properties. If any named property
          # isn't found in the Cloud Datastore backup, an invalid error is
          # returned.
          #
          # @param [Array<String>] new_fields The new projection fields.
          #
          # @!group Attributes
          #
          def projection_fields= new_fields
            if new_fields.nil?
              @gapi.configuration.load.update! projection_fields: nil
            else
              @gapi.configuration.load.update! projection_fields:
                Array(new_fields)
            end
          end

          ##
          # Sets the source URIs to load.
          #
          # The fully-qualified URIs that point to your data in Google Cloud.
          #
          # * For Google Cloud Storage URIs: Each URI can contain one '*'
          #   wildcard character and it must come after the 'bucket' name. Size
          #   limits related to load jobs apply to external data sources. For
          # * Google Cloud Bigtable URIs: Exactly one URI can be specified and
          #   it has be a fully specified and valid HTTPS URL for a Google Cloud
          #   Bigtable table.
          # * For Google Cloud Datastore backups: Exactly one URI can be
          #   specified. Also, the '*' wildcard character is not allowed.
          #
          # @param [Array<String>] new_uris The new source URIs to load.
          #
          # @!group Attributes
          #
          def source_uris= new_uris
            if new_uris.nil?
              @gapi.configuration.load.update! source_uris: nil
            else
              @gapi.configuration.load.update! source_uris: Array(new_uris)
            end
          end

          ##
          # Sets flag for allowing jagged rows.
          #
          # Accept rows that are missing trailing optional columns. The missing
          # values are treated as nulls. If `false`, records with missing
          # trailing columns are treated as bad records, and if there are too
          # many bad records, an invalid error is returned in the job result.
          # The default value is `false`. Only applicable to CSV, ignored for
          # other formats.
          #
          # @param [Boolean] val Accept rows that are missing trailing optional
          #   columns.
          #
          # @!group Attributes
          #
          def jagged_rows= val
            @gapi.configuration.load.update! allow_jagged_rows: val
          end

          ##
          # Allows quoted data sections to contain newline characters in CSV.
          #
          # @param [Boolean] val Indicates if BigQuery should allow quoted data
          #   sections that contain newline characters in a CSV file. The
          #   default value is `false`.
          #
          # @!group Attributes
          #
          def quoted_newlines= val
            @gapi.configuration.load.update! allow_quoted_newlines: val
          end

          ##
          # Allows BigQuery to autodetect the schema.
          #
          # @param [Boolean] val Indicates if BigQuery should automatically
          #   infer the options and schema for CSV and JSON sources. The default
          #   value is `false`.
          #
          # @!group Attributes
          #
          def autodetect= val
            @gapi.configuration.load.update! autodetect: val
          end

          ##
          # Sets the character encoding of the data.
          #
          # @param [String] val The character encoding of the data. The
          #   supported values are `UTF-8` or `ISO-8859-1`. The default value
          #   is `UTF-8`.
          #
          # @!group Attributes
          #
          def encoding= val
            @gapi.configuration.load.update! encoding: val
          end

          ##
          # Sets the separator for fields in a CSV file.
          #
          # @param [String] val Specifices the separator for fields in a CSV
          #   file. BigQuery converts the string to `ISO-8859-1` encoding, and
          #   then uses the first byte of the encoded string to split the data
          #   in its raw, binary state. Default is <code>,</code>.
          #
          # @!group Attributes
          #
          def delimiter= val
            @gapi.configuration.load.update! field_delimiter: val
          end

          ##
          # Allows unknown columns to be ignored.
          #
          # @param [Boolean] val Indicates if BigQuery should allow extra
          #   values that are not represented in the table schema. If true, the
          #   extra values are ignored. If false, records with extra columns are
          #   treated as bad records, and if there are too many bad records, an
          #   invalid error is returned in the job result. The default value is
          #   `false`.
          #
          #   The `format` property determines what BigQuery treats as an extra
          #   value:
          #
          #   * `CSV`: Trailing columns
          #   * `JSON`: Named values that don't match any column names
          #
          # @!group Attributes
          #
          def ignore_unknown= val
            @gapi.configuration.load.update! ignore_unknown_values: val
          end

          ##
          # Sets the maximum number of bad records that can be ignored.
          #
          # @param [Integer] val The maximum number of bad records that
          #   BigQuery can ignore when running the job. If the number of bad
          #   records exceeds this value, an invalid error is returned in the
          #   job result. The default value is `0`, which requires that all
          #   records are valid.
          #
          # @!group Attributes
          #
          def max_bad_records= val
            @gapi.configuration.load.update! max_bad_records: val
          end

          ##
          # Sets the string that represents a null value in a CSV file.
          #
          # @param [String] val Specifies a string that represents a null value
          #   in a CSV file. For example, if you specify `\N`, BigQuery
          #   interprets `\N` as a null value when loading a CSV file. The
          #   default value is the empty string. If you set this property to a
          #   custom value, BigQuery throws an error if an empty string is
          #   present for all data types except for STRING and BYTE. For STRING
          #   and BYTE columns, BigQuery interprets the empty string as an empty
          #   value.
          #
          # @!group Attributes
          #
          def null_marker= val
            @gapi.configuration.load.update! null_marker: val
          end

          ##
          # Sets the character to use to quote string values in CSVs.
          #
          # @param [String] val The value that is used to quote data sections
          #   in a CSV file. BigQuery converts the string to ISO-8859-1
          #   encoding, and then uses the first byte of the encoded string to
          #   split the data in its raw, binary state. The default value is a
          #   double-quote <code>"</code>. If your data does not contain quoted
          #   sections, set the property value to an empty string. If your data
          #   contains quoted newline characters, you must also set the
          #   allowQuotedNewlines property to true.
          #
          # @!group Attributes
          #
          def quote= val
            @gapi.configuration.load.update! quote: val
          end

          ##
          # Sets the schema update options, which allow the schema of the
          # destination table to be updated as a side effect of the load job if
          # a schema is autodetected or supplied in the job configuration.
          # Schema update options are supported in two cases: when write
          # disposition is `WRITE_APPEND`; when write disposition is
          # `WRITE_TRUNCATE` and the destination table is a partition of a
          # table, specified by partition decorators. For normal tables,
          # `WRITE_TRUNCATE` will always overwrite the schema. One or more of
          # the following values are specified:
          #
          # * `ALLOW_FIELD_ADDITION`: allow adding a nullable field to the
          #   schema.
          # * `ALLOW_FIELD_RELAXATION`: allow relaxing a required field in the
          #   original schema to nullable.
          #
          # @param [Array<String>] new_options The new schema update options.
          #
          # @!group Attributes
          #
          def schema_update_options= new_options
            if new_options.nil?
              @gapi.configuration.load.update! schema_update_options: nil
            else
              @gapi.configuration.load.update! \
                schema_update_options: Array(new_options)
            end
          end

          ##
          # Sets the number of leading rows to skip in the file.
          #
          # @param [Integer] val The number of rows at the top of a CSV file
          #   that BigQuery will skip when loading the data. The default
          #   value is `0`. This property is useful if you have header rows in
          #   the file that should be skipped.
          #
          # @!group Attributes
          #
          def skip_leading= val
            @gapi.configuration.load.update! skip_leading_rows: val
          end

          ##
          # Sets the encryption configuration of the destination table.
          #
          # @param [Google::Cloud::BigQuery::EncryptionConfiguration] val
          #   Custom encryption configuration (e.g., Cloud KMS keys).
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   key_name = "projects/a/locations/b/keyRings/c/cryptoKeys/d"
          #   encrypt_config = bigquery.encryption kms_key: key_name
          #   job = dataset.load_job "my_table", "gs://abc/file" do |job|
          #     job.encryption = encrypt_config
          #   end
          #
          # @!group Attributes
          def encryption= val
            @gapi.configuration.load.update!(
              destination_encryption_configuration: val.to_gapi
            )
          end

          ##
          # Sets the labels to use for the load job.
          #
          # @param [Hash] val A hash of user-provided labels associated with
          #   the job. You can use these to organize and group your jobs. Label
          #   keys and values can be no longer than 63 characters, can only
          #   contain lowercase letters, numeric characters, underscores and
          #   dashes. International characters are allowed. Label values are
          #   optional. Label keys must start with a letter and each label in
          #   the list must have a different key.
          #
          # @!group Attributes
          #
          def labels= val
            @gapi.configuration.update! labels: val
          end

          ##
          # @private Returns the Google API client library version of this job.
          #
          # @return [<Google::Apis::BigqueryV2::Job>] (See
          #   {Google::Apis::BigqueryV2::Job})
          def to_gapi
            check_for_mutated_schema!
            @gapi
          end

          protected

          ##
          # Change to a NOOP
          def ensure_full_data!
            # Do nothing because we trust the gapi is full before we get here.
          end

          ##
          # Queue up all the updates instead of making them.
          def patch_gapi! attribute
            @updates << attribute
            @updates.uniq!
          end
        end
      end
    end
  end
end
