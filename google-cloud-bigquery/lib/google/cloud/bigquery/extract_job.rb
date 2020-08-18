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


module Google
  module Cloud
    module Bigquery
      ##
      # # ExtractJob
      #
      # A {Job} subclass representing an export operation that may be performed
      # on a {Table} or {Model}. A ExtractJob instance is returned when you call
      # {Project#extract_job}, {Table#extract_job} or {Model#extract_job}.
      #
      # @see https://cloud.google.com/bigquery/docs/exporting-data
      #   Exporting table data
      # @see https://cloud.google.com/bigquery-ml/docs/exporting-models
      #   Exporting models
      # @see https://cloud.google.com/bigquery/docs/reference/v2/jobs Jobs API
      #   reference
      #
      # @example Export table data
      #   require "google/cloud/bigquery"
      #
      #   bigquery = Google::Cloud::Bigquery.new
      #   dataset = bigquery.dataset "my_dataset"
      #   table = dataset.table "my_table"
      #
      #   extract_job = table.extract_job "gs://my-bucket/file-name.json",
      #                                   format: "json"
      #   extract_job.wait_until_done!
      #   extract_job.done? #=> true
      #
      # @example Export a model
      #   require "google/cloud/bigquery"
      #
      #   bigquery = Google::Cloud::Bigquery.new
      #   dataset = bigquery.dataset "my_dataset"
      #   model = dataset.model "my_model"
      #
      #   extract_job = model.extract_job "gs://my-bucket/#{model.model_id}"
      #
      #   extract_job.wait_until_done!
      #   extract_job.done? #=> true
      #
      class ExtractJob < Job
        ##
        # The URI or URIs representing the Google Cloud Storage files to which
        # the data is exported.
        def destinations
          Array @gapi.configuration.extract.destination_uris
        end

        ##
        # The table or model which is exported.
        #
        # @return [Table, Model, nil] A table or model instance, or `nil`.
        #
        def source
          if (table = @gapi.configuration.extract.source_table)
            retrieve_table table.project_id, table.dataset_id, table.table_id
          elsif (model = @gapi.configuration.extract.source_model)
            retrieve_model model.project_id, model.dataset_id, model.model_id
          end
        end

        ##
        # Whether the source of the export job is a table. See {#source}.
        #
        # @return [Boolean] `true` when the source is a table, `false`
        #   otherwise.
        #
        def table?
          !@gapi.configuration.extract.source_table.nil?
        end

        ##
        # Whether the source of the export job is a model. See {#source}.
        #
        # @return [Boolean] `true` when the source is a model, `false`
        #   otherwise.
        #
        def model?
          !@gapi.configuration.extract.source_model.nil?
        end

        ##
        # Checks if the export operation compresses the data using gzip. The
        # default is `false`. Not applicable when extracting models.
        #
        # @return [Boolean] `true` when `GZIP`, `false` if not `GZIP` or not a
        #   table extraction.
        def compression?
          return false unless table?
          val = @gapi.configuration.extract.compression
          val == "GZIP"
        end

        ##
        # Checks if the destination format for the table data is [newline-delimited
        # JSON](http://jsonlines.org/). The default is `false`. Not applicable when
        # extracting models.
        #
        # @return [Boolean] `true` when `NEWLINE_DELIMITED_JSON`, `false` if not
        #   `NEWLINE_DELIMITED_JSON` or not a table extraction.
        #
        def json?
          return false unless table?
          val = @gapi.configuration.extract.destination_format
          val == "NEWLINE_DELIMITED_JSON"
        end

        ##
        # Checks if the destination format for the table data is CSV. Tables with
        # nested or repeated fields cannot be exported as CSV. The default is
        # `true` for tables. Not applicable when extracting models.
        #
        # @return [Boolean] `true` when `CSV`, or `false` if not `CSV` or not a
        #   table extraction.
        #
        def csv?
          return false unless table?
          val = @gapi.configuration.extract.destination_format
          return true if val.nil?
          val == "CSV"
        end

        ##
        # Checks if the destination format for the table data is
        # [Avro](http://avro.apache.org/). The default is `false`. Not applicable
        # when extracting models.
        #
        # @return [Boolean] `true` when `AVRO`, `false` if not `AVRO` or not a
        #   table extraction.
        #
        def avro?
          return false unless table?
          val = @gapi.configuration.extract.destination_format
          val == "AVRO"
        end

        ##
        # Checks if the destination format for the model is TensorFlow SavedModel.
        # The default is `true` for models. Not applicable when extracting tables.
        #
        # @return [Boolean] `true` when `ML_TF_SAVED_MODEL`, `false` if not
        #   `ML_TF_SAVED_MODEL` or not a model extraction.
        #
        def ml_tf_saved_model?
          return false unless model?
          val = @gapi.configuration.extract.destination_format
          return true if val.nil?
          val == "ML_TF_SAVED_MODEL"
        end

        ##
        # Checks if the destination format for the model is XGBoost. The default
        # is `false`. Not applicable when extracting tables.
        #
        # @return [Boolean] `true` when `ML_XGBOOST_BOOSTER`, `false` if not
        #   `ML_XGBOOST_BOOSTER` or not a model extraction.
        #
        def ml_xgboost_booster?
          return false unless model?
          val = @gapi.configuration.extract.destination_format
          val == "ML_XGBOOST_BOOSTER"
        end

        ##
        # The character or symbol the operation uses to delimit fields in the
        # exported data. The default is a comma (,) for tables. Not applicable
        # when extracting models.
        #
        # @return [String, nil] A string containing the character, such as `","`,
        #   `nil` if not a table extraction.
        #
        def delimiter
          return unless table?
          val = @gapi.configuration.extract.field_delimiter
          val = "," if val.nil?
          val
        end

        ##
        # Checks if the exported data contains a header row. The default is
        # `true` for tables. Not applicable when extracting models.
        #
        # @return [Boolean] `true` when the print header configuration is
        #   present or `nil`, `false` if disabled or not a table extraction.
        #
        def print_header?
          return false unless table?
          val = @gapi.configuration.extract.print_header
          val = true if val.nil?
          val
        end

        ##
        # The number of files per destination URI or URI pattern specified in
        # {#destinations}.
        #
        # @return [Array<Integer>] An array of values in the same order as the
        #   URI patterns.
        #
        def destinations_file_counts
          Array @gapi.statistics.extract.destination_uri_file_counts
        end

        ##
        # A hash containing the URI or URI pattern specified in
        # {#destinations} mapped to the counts of files per destination.
        #
        # @return [Hash<String, Integer>] A Hash with the URI patterns as keys
        #   and the counts as values.
        #
        def destinations_counts
          Hash[destinations.zip destinations_file_counts]
        end

        ##
        # If `#avro?` (`#format` is set to `"AVRO"`), this flag indicates
        # whether to enable extracting applicable column types (such as
        # `TIMESTAMP`) to their corresponding AVRO logical types
        # (`timestamp-micros`), instead of only using their raw types
        # (`avro-long`). Not applicable when extracting models.
        #
        # @return [Boolean] `true` when applicable column types will use their
        #   corresponding AVRO logical types, `false` if not enabled or not a
        #   table extraction.
        #
        def use_avro_logical_types?
          return false unless table?
          @gapi.configuration.extract.use_avro_logical_types
        end

        ##
        # Yielded to a block to accumulate changes for an API request.
        class Updater < ExtractJob
          ##
          # @private Create an Updater object.
          def initialize gapi
            @gapi = gapi
          end

          ##
          # @private Create an Updater from an options hash.
          #
          # @return [Google::Cloud::Bigquery::ExtractJob::Updater] A job
          #   configuration object for setting query options.
          def self.from_options service, source, storage_files, options
            job_ref = service.job_ref_from options[:job_id], options[:prefix]
            storage_urls = Array(storage_files).map do |url|
              url.respond_to?(:to_gs_url) ? url.to_gs_url : url
            end
            options[:format] ||= Convert.derive_source_format storage_urls.first
            extract_config = Google::Apis::BigqueryV2::JobConfigurationExtract.new(
              destination_uris: Array(storage_urls)
            )
            if source.is_a? Google::Apis::BigqueryV2::TableReference
              extract_config.source_table = source
            elsif source.is_a? Google::Apis::BigqueryV2::ModelReference
              extract_config.source_model = source
            end
            job = Google::Apis::BigqueryV2::Job.new(
              job_reference: job_ref,
              configuration: Google::Apis::BigqueryV2::JobConfiguration.new(
                extract: extract_config,
                dry_run: options[:dryrun]
              )
            )

            from_job_and_options job, options
          end

          ##
          # @private Create an Updater from a Job and options hash.
          #
          # @return [Google::Cloud::Bigquery::ExtractJob::Updater] A job
          #   configuration object for setting query options.
          def self.from_job_and_options request, options
            updater = ExtractJob::Updater.new request
            updater.compression = options[:compression]
            updater.delimiter = options[:delimiter]
            updater.format = options[:format]
            updater.header = options[:header]
            updater.labels = options[:labels] if options[:labels]
            unless options[:use_avro_logical_types].nil?
              updater.use_avro_logical_types = options[:use_avro_logical_types]
            end
            updater
          end

          ##
          # Sets the geographic location where the job should run. Required
          # except for US and EU.
          #
          # @param [String] value A geographic location, such as "US", "EU" or
          #   "asia-northeast1". Required except for US and EU.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   table = dataset.table "my_table"
          #
          #   destination = "gs://my-bucket/file-name.csv"
          #   extract_job = table.extract_job destination do |j|
          #     j.location = "EU"
          #   end
          #
          #   extract_job.wait_until_done!
          #   extract_job.done? #=> true
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
          # Sets the compression type. Not applicable when extracting models.
          #
          # @param [String] value The compression type to use for exported
          #   files. Possible values include `GZIP` and `NONE`. The default
          #   value is `NONE`.
          #
          # @!group Attributes
          def compression= value
            @gapi.configuration.extract.compression = value
          end

          ##
          # Sets the field delimiter. Not applicable when extracting models.
          #
          # @param [String] value Delimiter to use between fields in the
          #   exported data. Default is <code>,</code>.
          #
          # @!group Attributes
          def delimiter= value
            @gapi.configuration.extract.field_delimiter = value
          end

          ##
          # Sets the destination file format. The default value for
          # tables is `csv`. Tables with nested or repeated fields cannot be
          # exported as CSV. The default value for models is `ml_tf_saved_model`.
          #
          # Supported values for tables:
          #
          # * `csv` - CSV
          # * `json` - [Newline-delimited JSON](http://jsonlines.org/)
          # * `avro` - [Avro](http://avro.apache.org/)
          #
          # Supported values for models:
          #
          # * `ml_tf_saved_model` - TensorFlow SavedModel
          # * `ml_xgboost_booster` - XGBoost Booster
          #
          # @param [String] new_format The new source format.
          #
          # @!group Attributes
          #
          def format= new_format
            @gapi.configuration.extract.update! destination_format: Convert.source_format(new_format)
          end

          ##
          # Print a header row in the exported file. Not applicable when
          # extracting models.
          #
          # @param [Boolean] value Whether to print out a header row in the
          #   results. Default is `true`.
          #
          # @!group Attributes
          def header= value
            @gapi.configuration.extract.print_header = value
          end

          ##
          # Sets the labels to use for the job.
          #
          # @param [Hash] value A hash of user-provided labels associated with
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
          def labels= value
            @gapi.configuration.update! labels: value
          end

          ##
          # Indicate whether to enable extracting applicable column types (such
          # as `TIMESTAMP`) to their corresponding AVRO logical types
          # (`timestamp-micros`), instead of only using their raw types
          # (`avro-long`).
          #
          # Only used when `#format` is set to `"AVRO"` (`#avro?`).
          #
          # @param [Boolean] value Whether applicable column types will use
          #   their corresponding AVRO logical types.
          #
          # @!group Attributes
          def use_avro_logical_types= value
            @gapi.configuration.extract.use_avro_logical_types = value
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
            @gapi
          end
        end

        protected

        def retrieve_model project_id, dataset_id, model_id
          ensure_service!
          gapi = service.get_project_model project_id, dataset_id, model_id
          Model.from_gapi_json gapi, service
        rescue Google::Cloud::NotFoundError
          nil
        end
      end
    end
  end
end
