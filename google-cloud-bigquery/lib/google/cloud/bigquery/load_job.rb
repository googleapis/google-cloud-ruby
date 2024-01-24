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
      #   gcs_uri = "gs://my-bucket/file-name.csv"
      #   load_job = dataset.load_job "my_new_table", gcs_uri do |schema|
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
        # @param [String] view Specifies the view that determines which table information is returned.
        #   By default, basic table information and storage statistics (STORAGE_STATS) are returned.
        #   Accepted values include `:unspecified`, `:basic`, `:storage`, and
        #   `:full`. For more information, see [BigQuery Classes](@todo: Update the link).
        #   The default value is the `:unspecified` view type.
        #
        # @return [Table] A table instance.
        #
        def destination view: nil
          table = @gapi.configuration.load.destination_table
          return nil unless table
          retrieve_table table.project_id, table.dataset_id, table.table_id, metadata_view: view
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
          @gapi.configuration.load.encoding == "ISO-8859-1"
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
        # JSON](https://jsonlines.org/). The default is `false`.
        #
        # @return [Boolean] `true` when the source format is
        #   `NEWLINE_DELIMITED_JSON`, `false` otherwise.
        #
        def json?
          @gapi.configuration.load.source_format == "NEWLINE_DELIMITED_JSON"
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
          @gapi.configuration.load.source_format == "DATASTORE_BACKUP"
        end

        ##
        # Checks if the source format is ORC.
        #
        # @return [Boolean] `true` when the source format is `ORC`,
        #   `false` otherwise.
        #
        def orc?
          @gapi.configuration.load.source_format == "ORC"
        end

        ##
        # Checks if the source format is Parquet.
        #
        # @return [Boolean] `true` when the source format is `PARQUET`,
        #   `false` otherwise.
        #
        def parquet?
          @gapi.configuration.load.source_format == "PARQUET"
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

        ###
        # Checks if hive partitioning options are set.
        #
        # @see https://cloud.google.com/bigquery/docs/hive-partitioned-loads-gcs Loading externally partitioned data
        #
        # @return [Boolean] `true` when hive partitioning options are set, or `false` otherwise.
        #
        # @!group Attributes
        #
        def hive_partitioning?
          !@gapi.configuration.load.hive_partitioning_options.nil?
        end

        ###
        # The mode of hive partitioning to use when reading data. The following modes are supported:
        #
        #   1. `AUTO`: automatically infer partition key name(s) and type(s).
        #   2. `STRINGS`: automatically infer partition key name(s). All types are interpreted as strings.
        #   3. `CUSTOM`: partition key schema is encoded in the source URI prefix.
        #
        # @see https://cloud.google.com/bigquery/docs/hive-partitioned-loads-gcs Loading externally partitioned data
        #
        # @return [String, nil] The mode of hive partitioning, or `nil` if not set.
        #
        # @!group Attributes
        #
        def hive_partitioning_mode
          @gapi.configuration.load.hive_partitioning_options.mode if hive_partitioning?
        end

        ###
        # The common prefix for all source uris when hive partition detection is requested. The prefix must end
        # immediately before the partition key encoding begins. For example, consider files following this data layout:
        #
        # ```
        # gs://bucket/path_to_table/dt=2019-01-01/country=BR/id=7/file.avro
        # gs://bucket/path_to_table/dt=2018-12-31/country=CA/id=3/file.avro
        # ```
        #
        # When hive partitioning is requested with either `AUTO` or `STRINGS` mode, the common prefix can be either of
        # `gs://bucket/path_to_table` or `gs://bucket/path_to_table/` (trailing slash does not matter).
        #
        # @see https://cloud.google.com/bigquery/docs/hive-partitioned-loads-gcs Loading externally partitioned data
        #
        # @return [String, nil] The common prefix for all source uris, or `nil` if not set.
        #
        # @!group Attributes
        #
        def hive_partitioning_source_uri_prefix
          @gapi.configuration.load.hive_partitioning_options.source_uri_prefix if hive_partitioning?
        end

        ###
        # Checks if Parquet options are set.
        #
        # @see https://cloud.google.com/bigquery/docs/loading-data-cloud-storage-parquet Loading Parquet data from Cloud
        #   Storage
        #
        # @return [Boolean] `true` when Parquet options are set, or `false` otherwise.
        #
        # @!group Attributes
        #
        def parquet_options?
          !@gapi.configuration.load.parquet_options.nil?
        end

        ###
        # Indicates whether to use schema inference specifically for Parquet `LIST` logical type.
        #
        # @see https://cloud.google.com/bigquery/docs/loading-data-cloud-storage-parquet Loading Parquet data from Cloud
        #   Storage
        #
        # @return [Boolean, nil] The `enable_list_inference` value in Parquet options, or `nil` if Parquet options are
        #   not set.
        #
        # @!group Attributes
        #
        def parquet_enable_list_inference?
          @gapi.configuration.load.parquet_options.enable_list_inference if parquet_options?
        end

        ###
        # Indicates whether to infer Parquet `ENUM` logical type as `STRING` instead of `BYTES` by default.
        #
        # @see https://cloud.google.com/bigquery/docs/loading-data-cloud-storage-parquet Loading Parquet data from Cloud
        #   Storage
        #
        # @return [Boolean, nil] The `enum_as_string` value in Parquet options, or `nil` if Parquet options are not set.
        #
        # @!group Attributes
        #
        def parquet_enum_as_string?
          @gapi.configuration.load.parquet_options.enum_as_string if parquet_options?
        end

        ###
        # Checks if the destination table will be range partitioned. See [Creating and using integer range partitioned
        # tables](https://cloud.google.com/bigquery/docs/creating-integer-range-partitions).
        #
        # @return [Boolean] `true` when the table is range partitioned, or `false` otherwise.
        #
        # @!group Attributes
        #
        def range_partitioning?
          !@gapi.configuration.load.range_partitioning.nil?
        end

        ###
        # The field on which the destination table will be range partitioned, if any. The field must be a
        # top-level `NULLABLE/REQUIRED` field. The only supported type is `INTEGER/INT64`. See
        # [Creating and using integer range partitioned
        # tables](https://cloud.google.com/bigquery/docs/creating-integer-range-partitions).
        #
        # @return [String, nil] The partition field, if a field was configured, or `nil` if not range partitioned.
        #
        # @!group Attributes
        #
        def range_partitioning_field
          @gapi.configuration.load.range_partitioning.field if range_partitioning?
        end

        ###
        # The start of range partitioning, inclusive. See [Creating and using integer range partitioned
        # tables](https://cloud.google.com/bigquery/docs/creating-integer-range-partitions).
        #
        # @return [Integer, nil] The start of range partitioning, inclusive, or `nil` if not range partitioned.
        #
        # @!group Attributes
        #
        def range_partitioning_start
          @gapi.configuration.load.range_partitioning.range.start if range_partitioning?
        end

        ###
        # The width of each interval. See [Creating and using integer range partitioned
        # tables](https://cloud.google.com/bigquery/docs/creating-integer-range-partitions).
        #
        # @return [Integer, nil] The width of each interval, for data in range partitions, or `nil` if not range
        #   partitioned.
        #
        # @!group Attributes
        #
        def range_partitioning_interval
          return nil unless range_partitioning?
          @gapi.configuration.load.range_partitioning.range.interval
        end

        ###
        # The end of range partitioning, exclusive. See [Creating and using integer range partitioned
        # tables](https://cloud.google.com/bigquery/docs/creating-integer-range-partitions).
        #
        # @return [Integer, nil] The end of range partitioning, exclusive, or `nil` if not range partitioned.
        #
        # @!group Attributes
        #
        def range_partitioning_end
          @gapi.configuration.load.range_partitioning.range.end if range_partitioning?
        end

        ###
        # Checks if the destination table will be time partitioned. See
        # [Partitioned Tables](https://cloud.google.com/bigquery/docs/partitioned-tables).
        #
        # @return [Boolean] `true` when the table will be time-partitioned,
        #   or `false` otherwise.
        #
        # @!group Attributes
        #
        def time_partitioning?
          !@gapi.configuration.load.time_partitioning.nil?
        end

        ###
        # The period for which the destination table will be time partitioned, if
        # any. See [Partitioned Tables](https://cloud.google.com/bigquery/docs/partitioned-tables).
        #
        # @return [String, nil] The time partition type. The supported types are `DAY`,
        #   `HOUR`, `MONTH`, and `YEAR`, which will generate one partition per day,
        #   hour, month, and year, respectively; or `nil` if not present.
        #
        # @!group Attributes
        #
        def time_partitioning_type
          @gapi.configuration.load.time_partitioning.type if time_partitioning?
        end

        ###
        # The field on which the destination table will be time partitioned, if any.
        # If not set, the destination table will be time partitioned by pseudo column
        # `_PARTITIONTIME`; if set, the table will be time partitioned by this field.
        # See [Partitioned Tables](https://cloud.google.com/bigquery/docs/partitioned-tables).
        #
        # @return [String, nil] The time partition field, if a field was configured.
        #   `nil` if not time partitioned or not set (partitioned by pseudo column
        #   '_PARTITIONTIME').
        #
        # @!group Attributes
        #
        def time_partitioning_field
          @gapi.configuration.load.time_partitioning.field if time_partitioning?
        end

        ###
        # The expiration for the destination table time partitions, if any, in
        # seconds. See [Partitioned
        # Tables](https://cloud.google.com/bigquery/docs/partitioned-tables).
        #
        # @return [Integer, nil] The expiration time, in seconds, for data in
        #   time partitions, or `nil` if not present.
        #
        # @!group Attributes
        #
        def time_partitioning_expiration
          return nil unless time_partitioning?
          return nil if @gapi.configuration.load.time_partitioning.expiration_ms.nil?

          @gapi.configuration.load.time_partitioning.expiration_ms / 1_000
        end

        ###
        # If set to true, queries over the destination table will require a
        # time partition filter that can be used for partition elimination to be
        # specified. See [Partitioned
        # Tables](https://cloud.google.com/bigquery/docs/partitioned-tables).
        #
        # @return [Boolean] `true` when a time partition filter will be required,
        #   or `false` otherwise.
        #
        # @!group Attributes
        #
        def time_partitioning_require_filter?
          tp = @gapi.configuration.load.time_partitioning
          return false if tp.nil? || tp.require_partition_filter.nil?
          tp.require_partition_filter
        end

        ###
        # Checks if the destination table will be clustered.
        #
        # See {LoadJob::Updater#clustering_fields=}, {Table#clustering_fields} and
        # {Table#clustering_fields=}.
        #
        # @see https://cloud.google.com/bigquery/docs/clustered-tables
        #   Introduction to clustered tables
        # @see https://cloud.google.com/bigquery/docs/creating-clustered-tables
        #   Creating and using clustered tables
        #
        # @return [Boolean] `true` when the table will be clustered,
        #   or `false` otherwise.
        #
        # @!group Attributes
        #
        def clustering?
          !@gapi.configuration.load.clustering.nil?
        end

        ###
        # One or more fields on which the destination table should be clustered.
        # Must be specified with time-based partitioning, data in the table will
        # be first partitioned and subsequently clustered. The order of the
        # returned fields determines the sort order of the data.
        #
        # BigQuery supports clustering for both partitioned and non-partitioned
        # tables.
        #
        # See {LoadJob::Updater#clustering_fields=}, {Table#clustering_fields} and
        # {Table#clustering_fields=}.
        #
        # @see https://cloud.google.com/bigquery/docs/clustered-tables
        #   Introduction to clustered tables
        # @see https://cloud.google.com/bigquery/docs/creating-clustered-tables
        #   Creating and using clustered tables
        #
        # @return [Array<String>, nil] The clustering fields, or `nil` if the
        #   destination table will not be clustered.
        #
        # @!group Attributes
        #
        def clustering_fields
          @gapi.configuration.load.clustering.fields if clustering?
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
            super()
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
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |schema|
          #     schema.string "first_name", mode: :required
          #   end
          #
          # @example Add field with default value.
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |schema|
          #     schema.string "first_name", default_value_expression: "'name'"
          #   end
          #
          # @!group Schema
          def string name, description: nil, mode: :nullable, policy_tags: nil, max_length: nil,
                     default_value_expression: nil
            schema.string name, description: description, mode: mode, policy_tags: policy_tags, max_length: max_length,
                          default_value_expression: default_value_expression
          end

          ##
          # Adds an integer field to the schema.
          #
          # See {Schema#integer}.
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
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |schema|
          #     schema.integer "age", mode: :required
          #   end
          #
          # @example Add field with default value.
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |schema|
          #     schema.integer "age", default_value_expression: "1"
          #   end
          #
          # @!group Schema
          def integer name, description: nil, mode: :nullable, policy_tags: nil,
                      default_value_expression: nil
            schema.integer name, description: description, mode: mode, policy_tags: policy_tags,
                           default_value_expression: default_value_expression
          end

          ##
          # Adds a floating-point number field to the schema.
          #
          # See {Schema#float}.
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
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |schema|
          #     schema.float "price", mode: :required
          #   end
          #
          # @example Add field with default value.
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |schema|
          #     schema.float "price", default_value_expression: "1.0"
          #   end
          #
          # @!group Schema
          def float name, description: nil, mode: :nullable, policy_tags: nil,
                    default_value_expression: nil
            schema.float name, description: description, mode: mode, policy_tags: policy_tags,
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
          # See {Schema#numeric}
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
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |schema|
          #     schema.numeric "total_cost", mode: :required
          #   end
          #
          # @example Add field with default value.
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |schema|
          #     schema.numeric "total_cost", default_value_expression: "1.0e10"
          #   end
          #
          # @!group Schema
          def numeric name, description: nil, mode: :nullable, policy_tags: nil, precision: nil, scale: nil,
                      default_value_expression: nil
            schema.numeric name,
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
          # See {Schema#bignumeric}
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
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |schema|
          #     schema.bignumeric "total_cost", mode: :required
          #   end
          #
          # @example Add field with default value.
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |schema|
          #     schema.bignumeric "total_cost", default_value_expression: "1.0e10"
          #   end
          #
          # @!group Schema
          def bignumeric name, description: nil, mode: :nullable, policy_tags: nil, precision: nil, scale: nil,
                         default_value_expression: nil
            schema.bignumeric name,
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
          # See {Schema#boolean}.
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
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |schema|
          #     schema.boolean "active", mode: :required
          #   end
          #
          # @example Add field with default value.
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |schema|
          #     schema.boolean "active", default_value_expression: "true"
          #   end
          #
          # @!group Schema
          def boolean name, description: nil, mode: :nullable, policy_tags: nil,
                      default_value_expression: nil
            schema.boolean name,
                           description: description,
                           mode: mode,
                           policy_tags: policy_tags,
                           default_value_expression: default_value_expression
          end

          ##
          # Adds a bytes field to the schema.
          #
          # See {Schema#bytes}.
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
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |schema|
          #     schema.bytes "avatar", mode: :required
          #   end
          #
          # @example Add field with default value.
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |schema|
          #     schema.bytes "avatar", default_value_expression: "b'101'"
          #   end
          #
          # @!group Schema
          def bytes name, description: nil, mode: :nullable, policy_tags: nil, max_length: nil,
                    default_value_expression: nil
            schema.bytes name,
                         description: description,
                         mode: mode,
                         policy_tags: policy_tags,
                         max_length: max_length,
                         default_value_expression: default_value_expression
          end

          ##
          # Adds a timestamp field to the schema.
          #
          # See {Schema#timestamp}.
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
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |schema|
          #     schema.timestamp "creation_date", mode: :required
          #   end
          #
          # @example Add field with default value.
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |schema|
          #     schema.timestamp "creation_date", default_value_expression: "CURRENT_TIMESTAMP"
          #   end
          #
          # @!group Schema
          def timestamp name, description: nil, mode: :nullable, policy_tags: nil,
                        default_value_expression: nil
            schema.timestamp name, description: description, mode: mode, policy_tags: policy_tags,
                             default_value_expression: default_value_expression
          end

          ##
          # Adds a time field to the schema.
          #
          # See {Schema#time}.
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
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |schema|
          #     schema.time "duration", mode: :required
          #   end
          #
          # @example Add field with default value.
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |schema|
          #     schema.time "duration", default_value_expression: "CURRENT_TIME"
          #   end
          #
          # @!group Schema
          def time name, description: nil, mode: :nullable, policy_tags: nil,
                   default_value_expression: nil
            schema.time name,
                        description: description,
                        mode: mode,
                        policy_tags: policy_tags,
                        default_value_expression: default_value_expression
          end

          ##
          # Adds a datetime field to the schema.
          #
          # See {Schema#datetime}.
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
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |schema|
          #     schema.datetime "target_end", mode: :required
          #   end
          #
          # @example Add field with default value.
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |schema|
          #     schema.datetime "target_end", default_value_expression: "CURRENT_DATETIME"
          #   end
          #
          # @!group Schema
          def datetime name, description: nil, mode: :nullable, policy_tags: nil,
                       default_value_expression: nil
            schema.datetime name,
                            description: description,
                            mode: mode,
                            policy_tags: policy_tags,
                            default_value_expression: default_value_expression
          end

          ##
          # Adds a date field to the schema.
          #
          # See {Schema#date}.
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
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |schema|
          #     schema.date "birthday", mode: :required
          #   end
          #
          # @example Add field with default value.
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |schema|
          #     schema.date "birthday", default_value_expression: "CURRENT_DATE"
          #   end
          #
          # @!group Schema
          def date name, description: nil, mode: :nullable, policy_tags: nil,
                   default_value_expression: nil
            schema.date name,
                        description: description,
                        mode: mode,
                        policy_tags: policy_tags,
                        default_value_expression: default_value_expression
          end

          ##
          # Adds a geography field to the schema.
          #
          # See {Schema#geography}.
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
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |schema|
          #     schema.record "cities_lived", mode: :repeated do |cities_lived|
          #       cities_lived.geography "location", mode: :required
          #       cities_lived.integer "number_of_years", mode: :required
          #     end
          #   end
          #
          # @example Add field with default value.
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |schema|
          #     schema.geography "location", default_value_expression: "ST_GEOGPOINT(-122.084801, 37.422131)"
          #   end
          #
          def geography name, description: nil, mode: :nullable, policy_tags: nil,
                        default_value_expression: nil
            schema.geography name,
                             description: description,
                             mode: mode,
                             policy_tags: policy_tags,
                             default_value_expression: default_value_expression
          end

          ##
          # Adds an json field to the schema.
          #
          # See {Schema#json}. 
          # https://cloud.google.com/bigquery/docs/reference/standard-sql/data-types#json_type
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
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |schema|
          #     schema.record "cities_lived", mode: :repeated do |cities_lived|
          #       cities_lived.geography "location", mode: :required
          #       cities_lived.integer "number_of_years", mode: :required
          #       cities_lived.json "address", mode: :required
          #     end
          #   end
          #
          # @example Add field with default value.
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |schema|
          #     schema.json "person", default_value_expression: "JSON '{"name": "Alice", "age": 30}'"
          #   end
          #
          # @!group Schema
          #
          def json name, description: nil, mode: :nullable, policy_tags: nil,
                   default_value_expression: nil
            schema.json name, description: description, mode: mode, policy_tags: policy_tags,
                        default_value_expression: default_value_expression
          end

          ##
          # Adds a record field to the schema. A block must be passed describing
          # the nested fields of the record. For more information about nested
          # and repeated records, see [Loading denormalized, nested, and
          # repeated data
          # ](https://cloud.google.com/bigquery/docs/loading-data#loading_denormalized_nested_and_repeated_data).
          #
          # See {Schema#record}.
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
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   job = dataset.load_job "my_table", "gs://abc/file" do |schema|
          #     schema.record "cities_lived", default_value_expression: "STRUCT('place',10)" do |cities_lived|
          #       cities_lived.string "place", mode: :required
          #       cities_lived.integer "number_of_years", mode: :required
          #     end
          #   end
          #
          # @!group Schema
          #
          def record name, description: nil, mode: nil, default_value_expression: nil, &block
            schema.record name, description: description, mode: mode,
                          default_value_expression: default_value_expression, &block
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
          # * `json` - [Newline-delimited JSON](https://jsonlines.org/)
          # * `avro` - [Avro](http://avro.apache.org/)
          # * `orc` - [ORC](https://cloud.google.com/bigquery/docs/loading-data-cloud-storage-orc)
          # * `parquet` - [Parquet](https://parquet.apache.org/)
          # * `datastore_backup` - Cloud Datastore backup
          #
          # @param [String] new_format The new source format.
          #
          # @!group Attributes
          #
          def format= new_format
            @gapi.configuration.load.update! source_format: Convert.source_format(new_format)
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
            @gapi.configuration.load.update! create_disposition: Convert.create_disposition(new_create)
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
            @gapi.configuration.load.update! write_disposition: Convert.write_disposition(new_write)
          end

          ##
          # Sets the create_session property. If true, creates a new session,
          # where session id will be a server generated random id. If false,
          # runs query with an existing {#session_id=}, otherwise runs query in
          # non-session mode. The default value is `false`.
          #
          # @param [Boolean] value The create_session property. The default
          # value is `false`.
          #
          # @!group Attributes
          def create_session= value
            @gapi.configuration.load.create_session = value
          end

          ##
          # Sets the session ID for a query run in session mode. See {#create_session=}.
          #
          # @param [String] value The session ID. The default value is `nil`.
          #
          # @!group Attributes
          def session_id= value
            @gapi.configuration.load.connection_properties ||= []
            prop = @gapi.configuration.load.connection_properties.find { |cp| cp.key == "session_id" }
            if prop
              prop.value = value
            else
              prop = Google::Apis::BigqueryV2::ConnectionProperty.new key: "session_id", value: value
              @gapi.configuration.load.connection_properties << prop
            end
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
              @gapi.configuration.load.update! projection_fields: Array(new_fields)
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
              @gapi.configuration.load.update! schema_update_options: Array(new_options)
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
            @gapi.configuration.load.update! destination_encryption_configuration: val.to_gapi
          end

          ##
          # Sets the labels to use for the load job.
          #
          # @param [Hash] val A hash of user-provided labels associated with
          #   the job. You can use these to organize and group your jobs.
          #
          #   The labels applied to a resource must meet the following requirements:
          #
          #   * Each resource can have multiple labels, up to a maximum of 64.
          #   * Each label must be a key-value pair.
          #   * Keys have a minimum length of 1 character and a maximum length of
          #     63 characters, and cannot be empty. Values can be empty, and have
          #     a maximum length of 63 characters.
          #   * Keys and values can contain only lowercase letters, numeric characters,
          #     underscores, and dashes. All characters must use UTF-8 encoding, and
          #     international characters are allowed.
          #   * The key portion of a label must be unique. However, you can use the
          #     same key with multiple resources.
          #   * Keys must start with a lowercase letter or international character.
          #
          # @!group Attributes
          #
          def labels= val
            @gapi.configuration.update! labels: val
          end

          ##
          # Sets the mode of hive partitioning to use when reading data. The following modes are supported:
          #
          #   1. `auto`: automatically infer partition key name(s) and type(s).
          #   2. `strings`: automatically infer partition key name(s). All types are interpreted as strings.
          #   3. `custom`: partition key schema is encoded in the source URI prefix.
          #
          # Not all storage formats support hive partitioning. Requesting hive partitioning on an unsupported format
          # will lead to an error. Currently supported types include: `avro`, `csv`, `json`, `orc` and `parquet`.
          #
          # See {#format=} and {#hive_partitioning_source_uri_prefix=}.
          #
          # @see https://cloud.google.com/bigquery/docs/hive-partitioned-loads-gcs Loading externally partitioned data
          #
          # @param [String, Symbol] mode The mode of hive partitioning to use when reading data.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   gcs_uri = "gs://cloud-samples-data/bigquery/hive-partitioning-samples/autolayout/*"
          #   source_uri_prefix = "gs://cloud-samples-data/bigquery/hive-partitioning-samples/autolayout/"
          #   load_job = dataset.load_job "my_new_table", gcs_uri do |job|
          #     job.format = :parquet
          #     job.hive_partitioning_mode = :auto
          #     job.hive_partitioning_source_uri_prefix = source_uri_prefix
          #   end
          #
          #   load_job.wait_until_done!
          #   load_job.done? #=> true
          #
          # @!group Attributes
          #
          def hive_partitioning_mode= mode
            @gapi.configuration.load.hive_partitioning_options ||= Google::Apis::BigqueryV2::HivePartitioningOptions.new
            @gapi.configuration.load.hive_partitioning_options.mode = mode.to_s.upcase
          end

          ##
          # Sets the common prefix for all source uris when hive partition detection is requested. The prefix must end
          # immediately before the partition key encoding begins. For example, consider files following this data
          # layout:
          #
          # ```
          # gs://bucket/path_to_table/dt=2019-01-01/country=BR/id=7/file.avro
          # gs://bucket/path_to_table/dt=2018-12-31/country=CA/id=3/file.avro
          # ```
          #
          # When hive partitioning is requested with either `AUTO` or `STRINGS` mode, the common prefix can be either of
          # `gs://bucket/path_to_table` or `gs://bucket/path_to_table/` (trailing slash does not matter).
          #
          # See {#hive_partitioning_mode=}.
          #
          # @see https://cloud.google.com/bigquery/docs/hive-partitioned-loads-gcs Loading externally partitioned data
          #
          # @param [String] source_uri_prefix The common prefix for all source uris.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   gcs_uri = "gs://cloud-samples-data/bigquery/hive-partitioning-samples/autolayout/*"
          #   source_uri_prefix = "gs://cloud-samples-data/bigquery/hive-partitioning-samples/autolayout/"
          #   load_job = dataset.load_job "my_new_table", gcs_uri do |job|
          #     job.format = :parquet
          #     job.hive_partitioning_mode = :auto
          #     job.hive_partitioning_source_uri_prefix = source_uri_prefix
          #   end
          #
          #   load_job.wait_until_done!
          #   load_job.done? #=> true
          #
          # @!group Attributes
          #
          def hive_partitioning_source_uri_prefix= source_uri_prefix
            @gapi.configuration.load.hive_partitioning_options ||= Google::Apis::BigqueryV2::HivePartitioningOptions.new
            @gapi.configuration.load.hive_partitioning_options.source_uri_prefix = source_uri_prefix
          end

          ##
          # Sets whether to use schema inference specifically for Parquet `LIST` logical type.
          #
          # @see https://cloud.google.com/bigquery/docs/loading-data-cloud-storage-parquet Loading Parquet data from
          #   Cloud Storage
          #
          # @param [Boolean] enable_list_inference The `enable_list_inference` value to use in Parquet options.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   gcs_uris = ["gs://mybucket/00/*.parquet", "gs://mybucket/01/*.parquet"]
          #   load_job = dataset.load_job "my_new_table", gcs_uris do |job|
          #     job.format = :parquet
          #     job.parquet_enable_list_inference = true
          #   end
          #
          #   load_job.wait_until_done!
          #   load_job.done? #=> true
          #
          # @!group Attributes
          #
          def parquet_enable_list_inference= enable_list_inference
            @gapi.configuration.load.parquet_options ||= Google::Apis::BigqueryV2::ParquetOptions.new
            @gapi.configuration.load.parquet_options.enable_list_inference = enable_list_inference
          end

          ##
          # Sets whether to infer Parquet `ENUM` logical type as `STRING` instead of `BYTES` by default.
          #
          # @see https://cloud.google.com/bigquery/docs/loading-data-cloud-storage-parquet Loading Parquet data from
          #   Cloud Storage
          #
          # @param [Boolean] enum_as_string The `enum_as_string` value to use in Parquet options.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   gcs_uris = ["gs://mybucket/00/*.parquet", "gs://mybucket/01/*.parquet"]
          #   load_job = dataset.load_job "my_new_table", gcs_uris do |job|
          #     job.format = :parquet
          #     job.parquet_enum_as_string = true
          #   end
          #
          #   load_job.wait_until_done!
          #   load_job.done? #=> true
          #
          # @!group Attributes
          #
          def parquet_enum_as_string= enum_as_string
            @gapi.configuration.load.parquet_options ||= Google::Apis::BigqueryV2::ParquetOptions.new
            @gapi.configuration.load.parquet_options.enum_as_string = enum_as_string
          end

          ##
          # Sets the field on which to range partition the table. See [Creating and using integer range partitioned
          # tables](https://cloud.google.com/bigquery/docs/creating-integer-range-partitions).
          #
          # See {#range_partitioning_start=}, {#range_partitioning_interval=} and {#range_partitioning_end=}.
          #
          # You can only set range partitioning when creating a table. BigQuery does not allow you to change
          # partitioning on an existing table.
          #
          # @param [String] field The range partition field. the destination table is partitioned by this
          #   field. The field must be a top-level `NULLABLE/REQUIRED` field. The only supported
          #   type is `INTEGER/INT64`.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   gcs_uri = "gs://my-bucket/file-name.csv"
          #   load_job = dataset.load_job "my_new_table", gcs_uri do |job|
          #     job.schema do |schema|
          #       schema.integer "my_table_id", mode: :required
          #       schema.string "my_table_data", mode: :required
          #     end
          #     job.range_partitioning_field = "my_table_id"
          #     job.range_partitioning_start = 0
          #     job.range_partitioning_interval = 10
          #     job.range_partitioning_end = 100
          #   end
          #
          #   load_job.wait_until_done!
          #   load_job.done? #=> true
          #
          # @!group Attributes
          #
          def range_partitioning_field= field
            @gapi.configuration.load.range_partitioning ||= Google::Apis::BigqueryV2::RangePartitioning.new(
              range: Google::Apis::BigqueryV2::RangePartitioning::Range.new
            )
            @gapi.configuration.load.range_partitioning.field = field
          end

          ##
          # Sets the start of range partitioning, inclusive, for the destination table. See [Creating and using integer
          # range partitioned tables](https://cloud.google.com/bigquery/docs/creating-integer-range-partitions).
          #
          # You can only set range partitioning when creating a table. BigQuery does not allow you to change
          # partitioning on an existing table.
          #
          # See {#range_partitioning_field=}, {#range_partitioning_interval=} and {#range_partitioning_end=}.
          #
          # @param [Integer] range_start The start of range partitioning, inclusive.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   gcs_uri = "gs://my-bucket/file-name.csv"
          #   load_job = dataset.load_job "my_new_table", gcs_uri do |job|
          #     job.schema do |schema|
          #       schema.integer "my_table_id", mode: :required
          #       schema.string "my_table_data", mode: :required
          #     end
          #     job.range_partitioning_field = "my_table_id"
          #     job.range_partitioning_start = 0
          #     job.range_partitioning_interval = 10
          #     job.range_partitioning_end = 100
          #   end
          #
          #   load_job.wait_until_done!
          #   load_job.done? #=> true
          #
          # @!group Attributes
          #
          def range_partitioning_start= range_start
            @gapi.configuration.load.range_partitioning ||= Google::Apis::BigqueryV2::RangePartitioning.new(
              range: Google::Apis::BigqueryV2::RangePartitioning::Range.new
            )
            @gapi.configuration.load.range_partitioning.range.start = range_start
          end

          ##
          # Sets width of each interval for data in range partitions. See [Creating and using integer range partitioned
          # tables](https://cloud.google.com/bigquery/docs/creating-integer-range-partitions).
          #
          # You can only set range partitioning when creating a table. BigQuery does not allow you to change
          # partitioning on an existing table.
          #
          # See {#range_partitioning_field=}, {#range_partitioning_start=} and {#range_partitioning_end=}.
          #
          # @param [Integer] range_interval The width of each interval, for data in partitions.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   gcs_uri = "gs://my-bucket/file-name.csv"
          #   load_job = dataset.load_job "my_new_table", gcs_uri do |job|
          #     job.schema do |schema|
          #       schema.integer "my_table_id", mode: :required
          #       schema.string "my_table_data", mode: :required
          #     end
          #     job.range_partitioning_field = "my_table_id"
          #     job.range_partitioning_start = 0
          #     job.range_partitioning_interval = 10
          #     job.range_partitioning_end = 100
          #   end
          #
          #   load_job.wait_until_done!
          #   load_job.done? #=> true
          #
          # @!group Attributes
          #
          def range_partitioning_interval= range_interval
            @gapi.configuration.load.range_partitioning ||= Google::Apis::BigqueryV2::RangePartitioning.new(
              range: Google::Apis::BigqueryV2::RangePartitioning::Range.new
            )
            @gapi.configuration.load.range_partitioning.range.interval = range_interval
          end

          ##
          # Sets the end of range partitioning, exclusive, for the destination table. See [Creating and using integer
          # range partitioned tables](https://cloud.google.com/bigquery/docs/creating-integer-range-partitions).
          #
          # You can only set range partitioning when creating a table. BigQuery does not allow you to change
          # partitioning on an existing table.
          #
          # See {#range_partitioning_start=}, {#range_partitioning_interval=} and {#range_partitioning_field=}.
          #
          # @param [Integer] range_end The end of range partitioning, exclusive.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   gcs_uri = "gs://my-bucket/file-name.csv"
          #   load_job = dataset.load_job "my_new_table", gcs_uri do |job|
          #     job.schema do |schema|
          #       schema.integer "my_table_id", mode: :required
          #       schema.string "my_table_data", mode: :required
          #     end
          #     job.range_partitioning_field = "my_table_id"
          #     job.range_partitioning_start = 0
          #     job.range_partitioning_interval = 10
          #     job.range_partitioning_end = 100
          #   end
          #
          #   load_job.wait_until_done!
          #   load_job.done? #=> true
          #
          # @!group Attributes
          #
          def range_partitioning_end= range_end
            @gapi.configuration.load.range_partitioning ||= Google::Apis::BigqueryV2::RangePartitioning.new(
              range: Google::Apis::BigqueryV2::RangePartitioning::Range.new
            )
            @gapi.configuration.load.range_partitioning.range.end = range_end
          end

          ##
          # Sets the time partitioning for the destination table. See [Partitioned
          # Tables](https://cloud.google.com/bigquery/docs/partitioned-tables).
          #
          # You can only set the time partitioning field while creating a table.
          # BigQuery does not allow you to change partitioning on an existing
          # table.
          #
          # @param [String] type The time partition type. The supported types are `DAY`,
          #   `HOUR`, `MONTH`, and `YEAR`, which will generate one partition per day,
          #   hour, month, and year, respectively.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   gcs_uri = "gs://my-bucket/file-name.csv"
          #   load_job = dataset.load_job "my_new_table", gcs_uri do |job|
          #     job.time_partitioning_type = "DAY"
          #   end
          #
          #   load_job.wait_until_done!
          #   load_job.done? #=> true
          #
          # @!group Attributes
          #
          def time_partitioning_type= type
            @gapi.configuration.load.time_partitioning ||= Google::Apis::BigqueryV2::TimePartitioning.new
            @gapi.configuration.load.time_partitioning.update! type: type
          end

          ##
          # Sets the field on which to time partition the destination table. If not
          # set, the destination table is time partitioned by pseudo column
          # `_PARTITIONTIME`; if set, the table is time partitioned by this field.
          # See [Partitioned
          # Tables](https://cloud.google.com/bigquery/docs/partitioned-tables).
          #
          # The destination table must also be time partitioned. See
          # {#time_partitioning_type=}.
          #
          # You can only set the time partitioning field while creating a table.
          # BigQuery does not allow you to change partitioning on an existing
          # table.
          #
          # @param [String] field The time partition field. The field must be a
          #   top-level TIMESTAMP or DATE field. Its mode must be NULLABLE or
          #   REQUIRED.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   gcs_uri = "gs://my-bucket/file-name.csv"
          #   load_job = dataset.load_job "my_new_table", gcs_uri do |job|
          #     job.time_partitioning_type  = "DAY"
          #     job.time_partitioning_field = "dob"
          #     job.schema do |schema|
          #       schema.timestamp "dob", mode: :required
          #     end
          #   end
          #
          #   load_job.wait_until_done!
          #   load_job.done? #=> true
          #
          # @!group Attributes
          #
          def time_partitioning_field= field
            @gapi.configuration.load.time_partitioning ||= Google::Apis::BigqueryV2::TimePartitioning.new
            @gapi.configuration.load.time_partitioning.update! field: field
          end

          ##
          # Sets the time partition expiration for the destination table. See
          # [Partitioned
          # Tables](https://cloud.google.com/bigquery/docs/partitioned-tables).
          #
          # The destination table must also be time partitioned. See
          # {#time_partitioning_type=}.
          #
          # @param [Integer] expiration An expiration time, in seconds,
          #   for data in time partitions.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   gcs_uri = "gs://my-bucket/file-name.csv"
          #   load_job = dataset.load_job "my_new_table", gcs_uri do |job|
          #     job.time_partitioning_type = "DAY"
          #     job.time_partitioning_expiration = 86_400
          #   end
          #
          #   load_job.wait_until_done!
          #   load_job.done? #=> true
          #
          # @!group Attributes
          #
          def time_partitioning_expiration= expiration
            @gapi.configuration.load.time_partitioning ||= Google::Apis::BigqueryV2::TimePartitioning.new
            @gapi.configuration.load.time_partitioning.update! expiration_ms: expiration * 1000
          end

          ##
          # If set to true, queries over the destination table will require a
          # time partition filter that can be used for time partition elimination to be
          # specified. See [Partitioned
          # Tables](https://cloud.google.com/bigquery/docs/partitioned-tables).
          #
          # @param [Boolean] val Indicates if queries over the destination table
          #   will require a time partition filter. The default value is `false`.
          #
          # @!group Attributes
          #
          def time_partitioning_require_filter= val
            @gapi.configuration.load.time_partitioning ||= Google::Apis::BigqueryV2::TimePartitioning.new
            @gapi.configuration.load.time_partitioning.update! require_partition_filter: val
          end

          ##
          # Sets the list of fields on which data should be clustered.
          #
          # Only top-level, non-repeated, simple-type fields are supported. When
          # you cluster a table using multiple columns, the order of columns you
          # specify is important. The order of the specified columns determines
          # the sort order of the data.
          #
          # BigQuery supports clustering for both partitioned and non-partitioned
          # tables.
          #
          # See {LoadJob#clustering_fields}, {Table#clustering_fields} and
          # {Table#clustering_fields=}.
          #
          # @see https://cloud.google.com/bigquery/docs/clustered-tables
          #   Introduction to clustered tables
          # @see https://cloud.google.com/bigquery/docs/creating-clustered-tables
          #   Creating and using clustered tables
          #
          # @param [Array<String>] fields The clustering fields. Only top-level,
          #   non-repeated, simple-type fields are supported.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   gcs_uri = "gs://my-bucket/file-name.csv"
          #   load_job = dataset.load_job "my_new_table", gcs_uri do |job|
          #     job.time_partitioning_type  = "DAY"
          #     job.time_partitioning_field = "dob"
          #     job.schema do |schema|
          #       schema.timestamp "dob", mode: :required
          #       schema.string "first_name", mode: :required
          #       schema.string "last_name", mode: :required
          #     end
          #     job.clustering_fields = ["last_name", "first_name"]
          #   end
          #
          #   load_job.wait_until_done!
          #   load_job.done? #=> true
          #
          # @!group Attributes
          #
          def clustering_fields= fields
            @gapi.configuration.load.clustering ||= Google::Apis::BigqueryV2::Clustering.new
            @gapi.configuration.load.clustering.fields = fields
          end

          def cancel
            raise "not implemented in #{self.class}"
          end

          def rerun!
            raise "not implemented in #{self.class}"
          end

          def reload!
            raise "not implemented in #{self.class}"
          end
          alias refresh! reload!

          def wait_until_done!
            raise "not implemented in #{self.class}"
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
