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

require "google/cloud/bigquery/encryption_configuration"

module Google
  module Cloud
    module Bigquery
      ##
      # # CopyJob
      #
      # A {Job} subclass representing a copy operation that may be performed on
      # a {Table}. A CopyJob instance is created when you call {Table#copy_job}.
      #
      # @see https://cloud.google.com/bigquery/docs/tables#copy-table Copying
      #   an Existing Table
      # @see https://cloud.google.com/bigquery/docs/reference/v2/jobs Jobs API
      #   reference
      #
      # @example
      #   require "google/cloud/bigquery"
      #
      #   bigquery = Google::Cloud::Bigquery.new
      #   dataset = bigquery.dataset "my_dataset"
      #   table = dataset.table "my_table"
      #   destination_table = dataset.table "my_destination_table"
      #
      #   copy_job = table.copy_job destination_table
      #
      #   copy_job.wait_until_done!
      #   copy_job.done? #=> true
      #
      class CopyJob < Job
        ##
        # The table from which data is copied. This is the table on
        # which {Table#copy_job} was called.
        #
        # @return [Table] A table instance.
        #
        def source
          table = @gapi.configuration.copy.source_table
          return nil unless table
          retrieve_table table.project_id,
                         table.dataset_id,
                         table.table_id
        end

        ##
        # The table to which data is copied.
        #
        # @return [Table] A table instance.
        #
        def destination
          table = @gapi.configuration.copy.destination_table
          return nil unless table
          retrieve_table table.project_id,
                         table.dataset_id,
                         table.table_id
        end

        ##
        # Checks if the create disposition for the job is `CREATE_IF_NEEDED`,
        # which provides the following behavior: If the table does not exist,
        # the copy operation creates the table. This is the default create
        # disposition for copy jobs.
        #
        # @return [Boolean] `true` when `CREATE_IF_NEEDED`, `false` otherwise.
        #
        def create_if_needed?
          disp = @gapi.configuration.copy.create_disposition
          disp == "CREATE_IF_NEEDED"
        end

        ##
        # Checks if the create disposition for the job is `CREATE_NEVER`, which
        # provides the following behavior: The table must already exist; if it
        # does not, an error is returned in the job result.
        #
        # @return [Boolean] `true` when `CREATE_NEVER`, `false` otherwise.
        #
        def create_never?
          disp = @gapi.configuration.copy.create_disposition
          disp == "CREATE_NEVER"
        end

        ##
        # Checks if the write disposition for the job is `WRITE_TRUNCATE`, which
        # provides the following behavior: If the table already exists, the copy
        # operation overwrites the table data.
        #
        # @return [Boolean] `true` when `WRITE_TRUNCATE`, `false` otherwise.
        #
        def write_truncate?
          disp = @gapi.configuration.copy.write_disposition
          disp == "WRITE_TRUNCATE"
        end

        ##
        # Checks if the write disposition for the job is `WRITE_APPEND`, which
        # provides the following behavior: If the table already exists, the copy
        # operation appends the data to the table.
        #
        # @return [Boolean] `true` when `WRITE_APPEND`, `false` otherwise.
        #
        def write_append?
          disp = @gapi.configuration.copy.write_disposition
          disp == "WRITE_APPEND"
        end

        ##
        # Checks if the write disposition for the job is `WRITE_EMPTY`, which
        # provides the following behavior: If the table already exists and
        # contains data, the job will have an error. This is the default write
        # disposition for copy jobs.
        #
        # @return [Boolean] `true` when `WRITE_EMPTY`, `false` otherwise.
        #
        def write_empty?
          disp = @gapi.configuration.copy.write_disposition
          disp == "WRITE_EMPTY"
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
            @gapi.configuration.copy.destination_encryption_configuration
          )
        end

        ##
        # Yielded to a block to accumulate changes for an API request.
        class Updater < CopyJob
          ##
          # @private Create an Updater object.
          def initialize gapi
            @gapi = gapi
          end

          ##
          # @private Create an Updater from an options hash.
          #
          # @return [Google::Cloud::Bigquery::CopyJob::Updater] A job
          #   configuration object for setting copy options.
          def self.from_options source, target, options = {}
            req = Google::Apis::BigqueryV2::Job.new(
              configuration: Google::Apis::BigqueryV2::JobConfiguration.new(
                copy: Google::Apis::BigqueryV2::JobConfigurationTableCopy.new(
                  source_table: source,
                  destination_table: target
                ),
                dry_run: options[:dryrun]
              )
            )

            updater = CopyJob::Updater.new req
            updater.create = options[:create]
            updater.write = options[:write]
            updater.labels = options[:labels] if options[:labels]
            updater
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
          def create= new_create
            @gapi.configuration.copy.update! create_disposition:
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
          def write= new_write
            @gapi.configuration.copy.update! write_disposition:
              Convert.write_disposition(new_write)
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
          #   table = dataset.table "my_table"
          #
          #   key_name = "projects/a/locations/b/keyRings/c/cryptoKeys/d"
          #   encrypt_config = bigquery.encryption kms_key: key_name
          #   job = table.copy_job "my_dataset.new_table" do |job|
          #     job.encryption = encrypt_config
          #   end
          #
          # @!group Attributes
          def encryption= val
            @gapi.configuration.copy.update!(
              destination_encryption_configuration: val.to_gapi
            )
          end

          ##
          # Sets the labels to use for the job.
          #
          # @param [Hash] value A hash of user-provided labels associated with
          #   the job. You can use these to organize and group your jobs. Label
          #   keys and values can be no longer than 63 characters, can only
          #   contain lowercase letters, numeric characters, underscores and
          #   dashes. International characters are allowed. Label values are
          #   optional. Label keys must start with a letter and each label in
          #   the list must have a different key.
          #
          # @!group Attributes
          def labels= value
            @gapi.configuration.update! labels: value
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
      end
    end
  end
end
