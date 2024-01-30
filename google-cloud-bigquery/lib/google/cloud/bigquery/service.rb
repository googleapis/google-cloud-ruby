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
require "mini_mime"
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
        attr_reader :retries, :timeout, :host

        # @private
        def universe_domain
          service.universe_domain
        end

        ##
        # Creates a new Service instance.
        def initialize project, credentials,
                       retries: nil,
                       timeout: nil,
                       host: nil,
                       quota_project: nil,
                       universe_domain: nil
          @project = project
          @credentials = credentials
          @retries = retries
          @timeout = timeout
          @host = host
          @quota_project = quota_project
          @universe_domain = universe_domain
        end

        def service
          return mocked_service if mocked_service
          @service ||= begin
            service = API::BigqueryService.new
            service.client_options.application_name    = "gcloud-ruby"
            service.client_options.application_version = Google::Cloud::Bigquery::VERSION
            service.client_options.open_timeout_sec = timeout
            service.client_options.read_timeout_sec = timeout
            service.client_options.send_timeout_sec = timeout
            service.request_options.retries = 0 # handle retries in #execute
            service.request_options.header ||= {}
            service.request_options.header["x-goog-api-client"] = \
              "gl-ruby/#{RUBY_VERSION} gccl/#{Google::Cloud::Bigquery::VERSION}"
            service.request_options.query ||= {}
            service.request_options.query["prettyPrint"] = false
            service.request_options.quota_project = @quota_project if @quota_project
            service.authorization = @credentials.client
            service.universe_domain = @universe_domain
            service.root_url = host if host
            begin
              service.verify_universe_domain!
            rescue Google::Apis::UniverseDomainError => e
              # TODO: Create a Google::Cloud::Error subclass for this.
              raise Google::Cloud::Error, e.message
            end
            service
          end
        end
        attr_accessor :mocked_service

        def project_service_account
          service.get_project_service_account project
        end

        ##
        # Lists all datasets in the specified project to which you have
        # been granted the READER dataset role.
        def list_datasets all: nil, filter: nil, max: nil, token: nil
          # The list operation is considered idempotent
          execute backoff: true do
            service.list_datasets @project, all: all, filter: filter, max_results: max, page_token: token
          end
        end

        ##
        # Returns the dataset specified by datasetID.
        def get_dataset dataset_id
          # The get operation is considered idempotent
          execute backoff: true do
            service.get_dataset @project, dataset_id
          end
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
            service.patch_dataset @project, dataset_id, patched_dataset_gapi, options: options
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
        def list_tables dataset_id, max: nil, token: nil
          # The list operation is considered idempotent
          execute backoff: true do
            service.list_tables @project, dataset_id, max_results: max, page_token: token
          end
        end

        ##
        # Gets the specified table resource by full table reference.
        def get_project_table project_id, dataset_id, table_id, metadata_view: nil
          metadata_view = table_metadata_view_type_for metadata_view
          # The get operation is considered idempotent
          execute backoff: true do
            service.get_table project_id, dataset_id, table_id, view: metadata_view
          end
        end

        ##
        # Gets the specified table resource by table ID.
        # This method does not return the data in the table,
        # it only returns the table resource,
        # which describes the structure of this table.
        def get_table dataset_id, table_id, metadata_view: nil
          get_project_table @project, dataset_id, table_id, metadata_view: metadata_view
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
            service.patch_table @project, dataset_id, table_id, patched_table_gapi, options: options
          end
        end

        ##
        # Returns Google::Apis::BigqueryV2::Policy
        def get_table_policy dataset_id, table_id
          policy_options = API::GetPolicyOptions.new requested_policy_version: 1
          execute do
            service.get_table_iam_policy table_path(dataset_id, table_id),
                                         API::GetIamPolicyRequest.new(options: policy_options)
          end
        end

        ##
        # @param [Google::Apis::BigqueryV2::Policy] new_policy
        def set_table_policy dataset_id, table_id, new_policy
          execute do
            service.set_table_iam_policy table_path(dataset_id, table_id),
                                         API::SetIamPolicyRequest.new(policy: new_policy)
          end
        end

        ##
        # Returns Google::Apis::BigqueryV2::TestIamPermissionsResponse
        def test_table_permissions dataset_id, table_id, permissions
          execute do
            service.test_table_iam_permissions table_path(dataset_id, table_id),
                                               API::TestIamPermissionsRequest.new(permissions: permissions)
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
        def list_tabledata dataset_id, table_id, max: nil, token: nil, start: nil
          # The list operation is considered idempotent
          execute backoff: true do
            json_txt = service.list_table_data \
              @project, dataset_id, table_id,
              max_results: max,
              page_token:  token,
              start_index: start,
              options:     { skip_deserialization: true }
            JSON.parse json_txt, symbolize_names: true
          end
        end

        def insert_tabledata dataset_id, table_id, rows, insert_ids: nil, ignore_unknown: nil, skip_invalid: nil
          json_rows = Array(rows).map { |row| Convert.to_json_row row }
          insert_tabledata_json_rows dataset_id, table_id, json_rows, insert_ids:     insert_ids,
                                                                      ignore_unknown: ignore_unknown,
                                                                      skip_invalid:   skip_invalid
        end

        def insert_tabledata_json_rows dataset_id, table_id, json_rows, insert_ids: nil, ignore_unknown: nil,
                                       skip_invalid: nil
          rows_and_ids = Array(json_rows).zip Array(insert_ids)
          insert_rows = rows_and_ids.map do |json_row, insert_id|
            if insert_id == :skip
              { json: json_row }
            else
              insert_id ||= SecureRandom.uuid
              {
                insertId: insert_id,
                json:     json_row
              }
            end
          end

          insert_req = {
            rows:                insert_rows,
            ignoreUnknownValues: ignore_unknown,
            skipInvalidRows:     skip_invalid
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
        # Lists all models in the specified dataset.
        # Requires the READER dataset role.
        def list_models dataset_id, max: nil, token: nil
          options = { skip_deserialization: true }
          # The list operation is considered idempotent
          execute backoff: true do
            json_txt = service.list_models @project, dataset_id, max_results: max, page_token: token, options: options
            JSON.parse json_txt, symbolize_names: true
          end
        end

        # Gets the specified model resource by full model reference.
        def get_project_model project_id, dataset_id, model_id
          # The get operation is considered idempotent
          execute backoff: true do
            json_txt = service.get_model project_id, dataset_id, model_id, options: { skip_deserialization: true }
            JSON.parse json_txt, symbolize_names: true
          end
        end

        # Gets the specified model resource by model ID. This method does not return the data in the model, it only
        # returns the model resource, which describes the structure of this model.
        def get_model dataset_id, model_id
          get_project_model @project, dataset_id, model_id
        end

        ##
        # Updates information in an existing model, replacing fields that
        # are provided in the submitted model resource.
        def patch_model dataset_id, model_id, patched_model_gapi, etag = nil
          patch_with_backoff = false
          options = { skip_deserialization: true }
          if etag
            options[:header] = { "If-Match" => etag }
            # The patch with etag operation is considered idempotent
            patch_with_backoff = true
          end
          execute backoff: patch_with_backoff do
            json_txt = service.patch_model @project, dataset_id, model_id, patched_model_gapi, options: options
            JSON.parse json_txt, symbolize_names: true
          end
        end

        ##
        # Deletes the model specified by modelId from the dataset.
        # If the model contains data, all the data will be deleted.
        def delete_model dataset_id, model_id
          execute { service.delete_model @project, dataset_id, model_id }
        end

        ##
        # Creates a new routine in the dataset.
        def insert_routine dataset_id, new_routine_gapi
          execute { service.insert_routine @project, dataset_id, new_routine_gapi }
        end

        ##
        # Lists all routines in the specified dataset.
        # Requires the READER dataset role.
        # Unless readMask is set in the request, only the following fields are populated:
        #   etag, projectId, datasetId, routineId, routineType, creationTime, lastModifiedTime, and language.
        def list_routines dataset_id, max: nil, token: nil, filter: nil
          # The list operation is considered idempotent
          execute backoff: true do
            service.list_routines @project, dataset_id, max_results: max,
                                                        page_token:  token,
                                                        filter:      filter
          end
        end

        ##
        # Gets the specified routine resource by routine ID.
        def get_routine dataset_id, routine_id
          # The get operation is considered idempotent
          execute backoff: true do
            service.get_routine @project, dataset_id, routine_id
          end
        end

        ##
        # Updates information in an existing routine, replacing the entire routine resource.
        def update_routine dataset_id, routine_id, new_routine_gapi
          update_with_backoff = false
          options = {}
          if new_routine_gapi.etag
            options[:header] = { "If-Match" => new_routine_gapi.etag }
            # The update with etag operation is considered idempotent
            update_with_backoff = true
          end
          execute backoff: update_with_backoff do
            service.update_routine @project, dataset_id, routine_id, new_routine_gapi, options: options
          end
        end

        ##
        # Deletes the routine specified by routine_id from the dataset.
        def delete_routine dataset_id, routine_id
          execute { service.delete_routine @project, dataset_id, routine_id }
        end

        ##
        # Lists all jobs in the specified project to which you have
        # been granted the READER job role.
        def list_jobs all: nil, token: nil, max: nil, filter: nil, min_created_at: nil, max_created_at: nil,
                      parent_job_id: nil
          # The list operation is considered idempotent
          min_creation_time = Convert.time_to_millis min_created_at
          max_creation_time = Convert.time_to_millis max_created_at
          execute backoff: true do
            service.list_jobs @project, all_users: all, max_results: max,
                                        page_token: token, projection: "full", state_filter: filter,
                                        min_creation_time: min_creation_time, max_creation_time: max_creation_time,
                                        parent_job_id: parent_job_id
          end
        end

        ##
        # Cancel the job specified by jobId.
        def cancel_job job_id, location: nil
          # The BigQuery team has told us cancelling is considered idempotent
          execute backoff: true do
            service.cancel_job @project, job_id, location: location
          end
        end

        ##
        # Returns the job specified by jobID.
        def get_job job_id, location: nil
          # The get operation is considered idempotent
          execute backoff: true do
            service.get_job @project, job_id, location: location
          end
        end

        def insert_job config, location: nil
          job_object = API::Job.new job_reference: job_ref_from(nil, nil, location: location), configuration: config
          # Jobs have generated id, so this operation is considered idempotent
          execute backoff: true do
            service.insert_job @project, job_object
          end
        end

        def query_job query_job_gapi
          execute backoff: true do
            service.insert_job @project, query_job_gapi
          end
        end

        ##
        # Deletes the job specified by jobId and location (required).
        def delete_job job_id, location: nil
          execute do
            service.delete_job @project, job_id, location: location
          end
        end

        ##
        # Returns the query data for the job
        def job_query_results job_id, location: nil, max: nil, token: nil, start: nil, timeout: nil
          # The get operation is considered idempotent
          execute backoff: true do
            service.get_job_query_results @project, job_id,
                                          location:    location,
                                          max_results: max,
                                          page_token:  token,
                                          start_index: start,
                                          timeout_ms:  timeout
          end
        end

        def copy_table copy_job_gapi
          execute backoff: true do
            service.insert_job @project, copy_job_gapi
          end
        end

        def extract_table extract_job_gapi
          execute backoff: true do
            service.insert_job @project, extract_job_gapi
          end
        end

        def load_table_gs_url load_job_gapi
          execute backoff: true do
            service.insert_job @project, load_job_gapi
          end
        end

        def load_table_file file, load_job_gapi
          execute backoff: true do
            service.insert_job @project, load_job_gapi, upload_source: file, content_type: mime_type_for(file)
          end
        end

        def self.get_table_ref table, default_ref: nil
          if table.respond_to? :table_ref
            table.table_ref
          else
            table_ref_from_s table, default_ref: default_ref
          end
        end

        ##
        # Extracts at least `tbl` group, and possibly `dts` and `prj` groups,
        # from strings in the formats: "my_table", "my_dataset.my_table", or
        # "my-project:my_dataset.my_table". Then merges project_id and
        # dataset_id from the default table ref if they are missing.
        #
        # The regex matches both Standard SQL
        # ("bigquery-public-data.samples.shakespeare") and Legacy SQL
        # ("bigquery-public-data:samples.shakespeare").
        def self.table_ref_from_s str, default_ref: {}
          str = str.to_s
          m = /\A(((?<prj>\S*)(:|\.))?(?<dts>\S*)\.)?(?<tbl>\S*)\z/.match str
          raise ArgumentError, "unable to identify table from #{str.inspect}" unless m
          str_table_ref_hash = {
            project_id: m["prj"],
            dataset_id: m["dts"],
            table_id:   m["tbl"]
          }.compact
          str_table_ref_hash = default_ref.to_h.merge str_table_ref_hash
          ref = Google::Apis::BigqueryV2::TableReference.new(**str_table_ref_hash)
          validate_table_ref ref
          ref
        end

        ##
        # Converts a hash to a Google::Apis::BigqueryV2::DatasetAccessEntry oject.
        #
        # @param [Hash<String,String>] dataset_hash Hash for a DatasetAccessEntry.
        #
        def self.dataset_access_entry_from_hash dataset_hash
          params = {
            dataset: Google::Apis::BigqueryV2::DatasetReference.new(**dataset_hash),
            target_types: dataset_hash[:target_types]
          }.compact
          Google::Apis::BigqueryV2::DatasetAccessEntry.new(**params)
        end

        def self.validate_table_ref table_ref
          [:project_id, :dataset_id, :table_id].each do |f|
            raise ArgumentError, "TableReference is missing #{f}" if table_ref.send(f).nil?
          end
        end

        ##
        # Lists all projects to which you have been granted any project role.
        def list_projects max: nil, token: nil
          execute backoff: true do
            service.list_projects max_results: max, page_token: token
          end
        end

        # If no job_id or prefix is given, always generate a client-side job ID
        # anyway, for idempotent retry in the google-api-client layer.
        # See https://cloud.google.com/bigquery/docs/managing-jobs#generate-jobid
        def job_ref_from job_id, prefix, location: nil
          prefix ||= "job_"
          job_id ||= "#{prefix}#{generate_id}"
          job_ref = API::JobReference.new project_id: @project, job_id: job_id
          # BigQuery does not allow nil location, but missing is ok.
          job_ref.location = location if location
          job_ref
        end

        # API object for dataset.
        def dataset_ref_from dts, pjt = nil
          return nil if dts.nil?
          if dts.respond_to? :dataset_id
            Google::Apis::BigqueryV2::DatasetReference.new(
              project_id: (pjt || dts.project_id || @project),
              dataset_id: dts.dataset_id
            )
          else
            Google::Apis::BigqueryV2::DatasetReference.new(
              project_id: (pjt || @project),
              dataset_id: dts
            )
          end
        end

        def inspect
          "#{self.class}(#{@project})"
        end

        protected

        # Creates a formatted table path.
        def table_path dataset_id, table_id
          "projects/#{@project}/datasets/#{dataset_id}/tables/#{table_id}"
        end

        # Generate a random string similar to the BigQuery service job IDs.
        def generate_id
          SecureRandom.urlsafe_base64 21
        end

        def mime_type_for file
          mime_type = MiniMime.lookup_by_filename Pathname(file).to_path
          return nil if mime_type.nil?
          mime_type.content_type
        rescue StandardError
          nil
        end

        def execute backoff: nil, &block
          if backoff
            Backoff.new(retries: retries).execute(&block)
          else
            yield
          end
        rescue Google::Apis::Error => e
          raise Google::Cloud::Error.from_error e
        end

        def table_metadata_view_type_for str
          return nil if str.nil?
          { "unspecified" => "TABLE_METADATA_VIEW_UNSPECIFIED",
            "basic" => "BASIC",
            "storage" => "STORAGE_STATS",
            "full" => "FULL" }[str.to_s.downcase]
        end

        class Backoff
          class << self
            attr_accessor :retries
            attr_accessor :reasons
            attr_accessor :backoff
          end
          self.retries = 5
          self.reasons = ["rateLimitExceeded", "backendError"]
          self.backoff = lambda do |retries|
            # Max delay is 32 seconds
            # See "Back-off Requirements" here:
            # https://cloud.google.com/bigquery/sla
            retries = 5 if retries > 5
            delay = 2**retries
            sleep delay
          end

          def initialize retries: nil, reasons: nil, backoff: nil
            @retries = (retries || Backoff.retries).to_i
            @reasons = (reasons || Backoff.reasons).to_a
            @backoff = backoff || Backoff.backoff
          end

          def execute
            current_retries = 0
            loop do
              return yield
            rescue Google::Apis::Error => e
              raise e unless retry? e.body, current_retries

              @backoff.call current_retries
              current_retries += 1
            end
          end

          protected

          def retry? result, current_retries
            if current_retries < @retries && retry_error_reason?(result)
              return true
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
