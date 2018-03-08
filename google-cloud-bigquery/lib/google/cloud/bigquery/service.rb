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


require "google/cloud/bigquery/version"
require "google/cloud/bigquery/convert"
require "google/cloud/errors"
require "google/apis/bigquery_v2"
require "pathname"
require "securerandom"
require "mime/types"
require "date"

module Google
  module Cloud
    module Bigquery
      ##
      # @private Represents the Bigquery service and API calls.
      class Service
        ##
        # Alias to the Google Client API module
        API = Google::Apis::BigqueryV2

        # @private
        attr_accessor :project

        # @private
        attr_accessor :credentials

        # @private
        attr_reader :retries, :timeout

        ##
        # Creates a new Service instance.
        def initialize project, credentials, retries: nil, timeout: nil
          @project = project
          @credentials = credentials
          @retries = retries
          @timeout = timeout
        end

        def service
          return mocked_service if mocked_service
          @service ||= begin
            service = API::BigqueryService.new
            service.client_options.application_name    = "gcloud-ruby"
            service.client_options.application_version = \
              Google::Cloud::Bigquery::VERSION
            service.client_options.open_timeout_sec = timeout
            service.client_options.read_timeout_sec = timeout
            service.client_options.send_timeout_sec = timeout
            service.request_options.retries = 0 # handle retries in #execute
            service.request_options.header ||= {}
            service.request_options.header["x-goog-api-client"] = \
              "gl-ruby/#{RUBY_VERSION} gccl/#{Google::Cloud::Bigquery::VERSION}"
            service.authorization = @credentials.client
            service
          end
        end
        attr_accessor :mocked_service

        ##
        # Lists all datasets in the specified project to which you have
        # been granted the READER dataset role.
        def list_datasets options = {}
          # The list operation is considered idempotent
          execute backoff: true do
            service.list_datasets \
              @project, all: options[:all], filter: options[:filter],
                        max_results: options[:max], page_token: options[:token]
          end
        end

        ##
        # Returns the dataset specified by datasetID.
        def get_dataset dataset_id
          # The get operation is considered idempotent
          execute(backoff: true) { service.get_dataset @project, dataset_id }
        end

        ##
        # Creates a new empty dataset.
        def insert_dataset new_dataset_gapi
          execute { service.insert_dataset @project, new_dataset_gapi }
        end

        ##
        # Updates information in an existing dataset, only replacing
        # fields that are provided in the submitted dataset resource.
        def patch_dataset dataset_id, patched_dataset_gapi
          patch_with_backoff = false
          options = {}
          if patched_dataset_gapi.etag
            options[:header] = { "If-Match" => patched_dataset_gapi.etag }
            # The patch with etag operation is considered idempotent
            patch_with_backoff = true
          end
          execute backoff: patch_with_backoff do
            service.patch_dataset @project, dataset_id, patched_dataset_gapi,
                                  options: options
          end
        end

        ##
        # Deletes the dataset specified by the datasetId value.
        # Before you can delete a dataset, you must delete all its tables,
        # either manually or by specifying force: true in options.
        # Immediately after deletion, you can create another dataset with
        # the same name.
        def delete_dataset dataset_id, force = nil
          execute do
            service.delete_dataset @project, dataset_id, delete_contents: force
          end
        end

        ##
        # Lists all tables in the specified dataset.
        # Requires the READER dataset role.
        def list_tables dataset_id, options = {}
          # The list operation is considered idempotent
          execute backoff: true do
            service.list_tables @project, dataset_id,
                                max_results: options[:max],
                                page_token: options[:token]
          end
        end

        def get_project_table project_id, dataset_id, table_id
          # The get operation is considered idempotent
          execute backoff: true do
            service.get_table project_id, dataset_id, table_id
          end
        end

        ##
        # Gets the specified table resource by table ID.
        # This method does not return the data in the table,
        # it only returns the table resource,
        # which describes the structure of this table.
        def get_table dataset_id, table_id
          # The get operation is considered idempotent
          execute backoff: true do
            get_project_table @project, dataset_id, table_id
          end
        end

        ##
        # Creates a new, empty table in the dataset.
        def insert_table dataset_id, new_table_gapi
          execute { service.insert_table @project, dataset_id, new_table_gapi }
        end

        ##
        # Updates information in an existing table, replacing fields that
        # are provided in the submitted table resource.
        def patch_table dataset_id, table_id, patched_table_gapi
          patch_with_backoff = false
          options = {}
          if patched_table_gapi.etag
            options[:header] = { "If-Match" => patched_table_gapi.etag }
            # The patch with etag operation is considered idempotent
            patch_with_backoff = true
          end
          execute backoff: patch_with_backoff do
            service.patch_table @project, dataset_id, table_id,
                                patched_table_gapi, options: options
          end
        end

        ##
        # Deletes the table specified by tableId from the dataset.
        # If the table contains data, all the data will be deleted.
        def delete_table dataset_id, table_id
          execute { service.delete_table @project, dataset_id, table_id }
        end

        ##
        # Retrieves data from the table.
        def list_tabledata dataset_id, table_id, options = {}
          # The list operation is considered idempotent
          execute backoff: true do
            json_txt = service.list_table_data \
              @project, dataset_id, table_id,
              max_results: options.delete(:max),
              page_token: options.delete(:token),
              start_index: options.delete(:start),
              options: { skip_deserialization: true }
            JSON.parse json_txt, symbolize_names: true
          end
        end

        def insert_tabledata dataset_id, table_id, rows, options = {}
          json_rows = Array(rows).map { |row| Convert.to_json_row row }

          insert_tabledata_json_rows dataset_id, table_id, json_rows, options
        end

        def insert_tabledata_json_rows dataset_id, table_id, json_rows,
                                       options = {}
          insert_rows = Array(json_rows).map do |json_row|
            {
              insertId: SecureRandom.uuid,
              json: json_row
            }
          end

          insert_req = {
            rows: insert_rows,
            ignoreUnknownValues: options[:ignore_unknown],
            skipInvalidRows: options[:skip_invalid]
          }.to_json

          # The insertAll with insertId operation is considered idempotent
          execute backoff: true do
            service.insert_all_table_data(
              @project, dataset_id, table_id, insert_req,
              options: { skip_serialization: true }
            )
          end
        end

        ##
        # Lists all jobs in the specified project to which you have
        # been granted the READER job role.
        def list_jobs options = {}
          # The list operation is considered idempotent
          execute backoff: true do
            service.list_jobs \
              @project, all_users: options[:all], max_results: options[:max],
                        page_token: options[:token], projection: "full",
                        state_filter: options[:filter]
          end
        end

        ##
        # Cancel the job specified by jobId.
        def cancel_job job_id
          # The BigQuery team has told us cancelling is considered idempotent
          execute(backoff: true) { service.cancel_job @project, job_id }
        end

        ##
        # Returns the job specified by jobID.
        def get_job job_id
          # The get operation is considered idempotent
          execute(backoff: true) { service.get_job @project, job_id }
        end

        def insert_job config
          job_object = API::Job.new(
            job_reference: job_ref_from(nil, nil),
            configuration: config
          )
          # Jobs have generated id, so this operation is considered idempotent
          execute(backoff: true) { service.insert_job @project, job_object }
        end

        def query_job job_id, prefix, query_job_gapi
          # Jobs have generated id, so this operation is considered idempotent
          query_job_gapi.job_reference = job_ref_from(job_id, prefix)
          execute backoff: true do
            service.insert_job @project, query_job_gapi
          end
        end

        ##
        # Returns the query data for the job
        def job_query_results job_id, options = {}
          # The get operation is considered idempotent
          execute backoff: true do
            service.get_job_query_results @project,
                                          job_id,
                                          max_results: options.delete(:max),
                                          page_token: options.delete(:token),
                                          start_index: options.delete(:start),
                                          timeout_ms: options.delete(:timeout)
          end
        end

        def copy_table source, target, options = {}
          # Jobs have generated id, so this operation is considered idempotent
          execute backoff: true do
            service.insert_job @project, copy_table_config(
              source, target, options
            )
          end
        end

        def extract_table table, storage_files, options = {}
          # Jobs have generated id, so this operation is considered idempotent
          execute backoff: true do
            service.insert_job \
              @project, extract_table_config(table, storage_files, options)
          end
        end

        def load_table_gs_url job_id, prefix, load_job_gapi
          # Jobs have generated id, so this operation is considered idempotent
          load_job_gapi.job_reference = job_ref_from(job_id, prefix)
          execute backoff: true do
            service.insert_job @project, load_job_gapi
          end
        end

        def load_table_file job_id, prefix, file, load_job_gapi
          # Jobs have generated id, so this operation is considered idempotent
          load_job_gapi.job_reference = job_ref_from(job_id, prefix)
          execute backoff: true do
            service.insert_job \
              @project,
              load_job_gapi,
              upload_source: file, content_type: mime_type_for(file)
          end
        end

        ##
        # Extracts at least `tbl` group, and possibly `dts` and `prj` groups,
        # from strings in the formats: "my_table", "my_dataset.my_table", or
        # "my-project:my_dataset.my_table". Then merges project_id and
        # dataset_id from the default table if they are missing.
        def self.table_ref_from_s str, default_table_ref
          str = str.to_s
          m = /\A(((?<prj>\S*):)?(?<dts>\S*)\.)?(?<tbl>\S*)\z/.match str
          unless m
            raise ArgumentError, "unable to identify table from #{str.inspect}"
          end
          str_table_ref_hash = {
            project_id: m["prj"],
            dataset_id: m["dts"],
            table_id:   m["tbl"]
          }.delete_if { |_, v| v.nil? }
          new_table_ref_hash = default_table_ref.to_h.merge str_table_ref_hash
          Google::Apis::BigqueryV2::TableReference.new new_table_ref_hash
        end

        ##
        # Lists all projects to which you have been granted any project role.
        def list_projects options = {}
          execute backoff: true do
            service.list_projects max_results: options[:max],
                                  page_token: options[:token]
          end
        end

        def inspect
          "#{self.class}(#{@project})"
        end

        protected

        # Generate a random string similar to the BigQuery service job IDs.
        def generate_id
          SecureRandom.urlsafe_base64(21)
        end

        # If no job_id or prefix is given, always generate a client-side job ID
        # anyway, for idempotent retry in the google-api-client layer.
        # See https://cloud.google.com/bigquery/docs/managing-jobs#generate-jobid
        def job_ref_from job_id, prefix
          prefix ||= "job_"
          job_id ||= "#{prefix}#{generate_id}"
          API::JobReference.new(
            project_id: @project,
            job_id: job_id
          )
        end

        ##
        # Job description for copy job
        def copy_table_config source, target, options = {}
          req = API::Job.new(
            job_reference: job_ref_from(options[:job_id], options[:prefix]),
            configuration: API::JobConfiguration.new(
              copy: API::JobConfigurationTableCopy.new(
                source_table: source,
                destination_table: target,
                create_disposition: Convert.create_disposition(options[:create]),
                write_disposition: Convert.write_disposition(options[:write])
              ),
              dry_run: options[:dryrun]
            )
          )
          req.configuration.labels = options[:labels] if options[:labels]
          req
        end

        def extract_table_config table, storage_files, options = {}
          storage_urls = Array(storage_files).map do |url|
            url.respond_to?(:to_gs_url) ? url.to_gs_url : url
          end
          dest_format = source_format storage_urls.first, options[:format]
          req = API::Job.new(
            job_reference: job_ref_from(options[:job_id], options[:prefix]),
            configuration: API::JobConfiguration.new(
              extract: API::JobConfigurationExtract.new(
                destination_uris: Array(storage_urls),
                source_table: table,
                destination_format: dest_format,
                compression: options[:compression],
                field_delimiter: options[:delimiter],
                print_header: options[:header]
              ),
              dry_run: options[:dryrun]
            )
          )
          req.configuration.labels = options[:labels] if options[:labels]
          req
        end

        def source_format path, format
          val = {
            "csv" => "CSV",
            "json" => "NEWLINE_DELIMITED_JSON",
            "newline_delimited_json" => "NEWLINE_DELIMITED_JSON",
            "avro" => "AVRO",
            "datastore" => "DATASTORE_BACKUP",
            "backup" => "DATASTORE_BACKUP",
            "datastore_backup" => "DATASTORE_BACKUP"
          }[format.to_s.downcase]
          return val unless val.nil?
          return nil if path.nil?
          return "CSV" if path.end_with? ".csv"
          return "NEWLINE_DELIMITED_JSON" if path.end_with? ".json"
          return "AVRO" if path.end_with? ".avro"
          return "DATASTORE_BACKUP" if path.end_with? ".backup_info"
          nil
        end

        def mime_type_for file
          mime_type = MIME::Types.of(Pathname(file).to_path).first.to_s
          return nil if mime_type.empty?
          mime_type
        rescue StandardError
          nil
        end

        def execute backoff: nil
          if backoff
            Backoff.new(retries: retries).execute { yield }
          else
            yield
          end
        rescue Google::Apis::Error => e
          raise Google::Cloud::Error.from_error(e)
        end

        class Backoff
          class << self
            attr_accessor :retries
            attr_accessor :reasons
            attr_accessor :backoff
          end
          self.retries = 5
          self.reasons = %w[rateLimitExceeded backendError]
          self.backoff = lambda do |retries|
            # Max delay is 32 seconds
            # See "Back-off Requirements" here:
            # https://cloud.google.com/bigquery/sla
            retries = 5 if retries > 5
            delay = 2**retries
            sleep delay
          end

          def initialize options = {}
            @retries = (options[:retries] || Backoff.retries).to_i
            @reasons = (options[:reasons] || Backoff.reasons).to_a
            @backoff =  options[:backoff] || Backoff.backoff
          end

          def execute
            current_retries = 0
            loop do
              begin
                return yield
              rescue Google::Apis::Error => e
                raise e unless retry? e.body, current_retries

                @backoff.call current_retries
                current_retries += 1
              end
            end
          end

          protected

          def retry? result, current_retries #:nodoc:
            if current_retries < @retries
              return true if retry_error_reason? result
            end
            false
          end

          def retry_error_reason? err_body
            err_hash = JSON.parse err_body
            json_errors = Array err_hash["error"]["errors"]
            return false if json_errors.empty?
            json_errors.each do |json_error|
              return false unless @reasons.include? json_error["reason"]
            end
            true
          rescue StandardError
            false
          end
        end
      end
    end
  end
end
