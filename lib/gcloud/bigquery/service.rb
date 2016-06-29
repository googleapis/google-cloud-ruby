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


require "gcloud/version"
require "gcloud/errors"
require "google/apis/bigquery_v2"
require "pathname"
require "digest/md5"
require "mime/types"

module Gcloud
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

      ##
      # Creates a new Service instance.
      def initialize project, credentials
        @project = project
        @credentials = credentials
        @credentials = credentials
        @service = API::BigqueryService.new
        @service.client_options.application_name    = "gcloud-ruby"
        @service.client_options.application_version = Gcloud::VERSION
        @service.authorization = @credentials.client
      end

      def service
        return mocked_service if mocked_service
        @service
      end
      attr_accessor :mocked_service

      ##
      # Lists all datasets in the specified project to which you have
      # been granted the READER dataset role.
      def list_datasets options = {}
        service.list_datasets \
        @project, all: options[:all], max_results: options[:max],
                  page_token: options[:token]
      end

      ##
      # Returns the dataset specified by datasetID.
      def get_dataset dataset_id
        service.get_dataset @project, dataset_id
      end

      ##
      # Creates a new empty dataset.
      def insert_dataset dataset_id, new_dataset_gapi
        service.insert_dataset @project, new_dataset_gapi
      end

      ##
      # Updates information in an existing dataset, only replacing
      # fields that are provided in the submitted dataset resource.
      def patch_dataset dataset_id, patched_dataset_gapi
        service.patch_dataset @project, dataset_id, patched_dataset_gapi
      end

      ##
      # Deletes the dataset specified by the datasetId value.
      # Before you can delete a dataset, you must delete all its tables,
      # either manually or by specifying force: true in options.
      # Immediately after deletion, you can create another dataset with
      # the same name.
      def delete_dataset dataset_id, force = nil
        service.delete_dataset @project, dataset_id, delete_contents: force
      end

      ##
      # Lists all tables in the specified dataset.
      # Requires the READER dataset role.
      def list_tables dataset_id, options = {}
        service.list_tables @project, dataset_id, max_results: options[:max], page_token: options[:token]
      end

      def get_project_table project_id, dataset_id, table_id
        service.get_table project_id, dataset_id, table_id
      end

      ##
      # Gets the specified table resource by table ID.
      # This method does not return the data in the table,
      # it only returns the table resource,
      # which describes the structure of this table.
      def get_table dataset_id, table_id
        get_project_table @project, dataset_id, table_id
      end

      ##
      # Creates a new, empty table in the dataset.
      def insert_table dataset_id, new_table_gapi
        service.insert_table @project, dataset_id, new_table_gapi
      end

      ##
      # Updates information in an existing table, replacing fields that
      # are provided in the submitted table resource.
      def patch_table dataset_id, table_id, patched_table_gapi
        service.patch_table @project, dataset_id, table_id, patched_table_gapi
      end

      ##
      # Deletes the table specified by tableId from the dataset.
      # If the table contains data, all the data will be deleted.
      def delete_table dataset_id, table_id
        service.delete_table @project, dataset_id, table_id
      end

      ##
      # Retrieves data from the table.
      def list_tabledata dataset_id, table_id, options = {}
        service.list_table_data @project, dataset_id, table_id,
                                max_results: options.delete(:max),
                                page_token: options.delete(:token),
                                start_index: options.delete(:start)
      end

      def insert_tabledata dataset_id, table_id, rows, options = {}
        insert_rows = Array(rows).map do |row|
          Google::Apis::BigqueryV2::InsertAllTableDataRequest::Row.new(
            insert_id: Digest::MD5.base64digest(row.inspect),
            json: row # Hash[my_hash.map{|(k,v)| [k.to_s,v]}] for Hash<String,Object>
          )
        end
        insert_req = Google::Apis::BigqueryV2::InsertAllTableDataRequest.new(
          rows: insert_rows,
          ignore_unknown_values: options[:ignore_unknown],
          skip_invalid_rows: options[:skip_invalid],
        )

        service.insert_all_table_data @project, dataset_id, table_id, insert_req
      end

      ##
      # Lists all jobs in the specified project to which you have
      # been granted the READER job role.
      def list_jobs options = {}
        service.list_jobs \
          @project, all_users: options[:all], max_results: options[:max],
                    page_token: options[:token], projection: "full",
                    state_filter: options[:filter]
      end

      ##
      # Returns the job specified by jobID.
      def get_job job_id
        service.get_job @project, job_id
      end

      def insert_job config
        job_object = API::Job.new(
          configuration: config
        )
        service.insert_job @project, job_object
      end

      def query_job query, options = {}
        config = query_table_config(query, options)
        service.insert_job @project, config
      end

      def query query, options = {}
        service.query_job @project, query_config(query, options)
      end

      ##
      # Returns the query data for the job
      def job_query_results job_id, options = {}
        service.get_job_query_results @project,
                                      job_id,
                                      max_results: options.delete(:max),
                                      page_token: options.delete(:token),
                                      start_index: options.delete(:start),
                                      timeout_ms: options.delete(:timeout)
      end

      def copy_table source, target, options = {}
        service.insert_job @project, copy_table_config(source, target, options)
      end

      def extract_table table, storage_files, options = {}
        service.insert_job @project, extract_table_config(table, storage_files, options)
      end

      def load_table_gs_url dataset_id, table_id, storage_url, options = {}
        #insert_job(project_id, job_object = nil, fields: nil, quota_user: nil, user_ip: nil, upload_source: nil, content_type: nil, options: nil) {|result, err| ... } ⇒ Google::Apis::BigqueryV2::Job
        load_opts = {
          destination_table: Google::Apis::BigqueryV2::TableReference.new(
            project_id: @project, dataset_id: dataset_id, table_id: table_id),
          source_uris: Array(storage_url),
          create_disposition: create_disposition(options[:create]),
          write_disposition: write_disposition(options[:write]),
          source_format: source_format(storage_url, options[:format]),
          projection_fields: projection_fields(options[:projection_fields]),
          allow_jagged_rows: options[:jagged_rows],
          allow_quoted_newlines: options[:quoted_newlines],
          encoding: options[:encoding],
          field_delimiter: options[:delimiter],
          ignore_unknown_values: options[:ignore_unknown],
          max_bad_records: options[:max_bad_records],
          quote: options[:quote],
          schema: options[:schema],
          skip_leading_rows: options[:skip_leading]
        }.delete_if { |_, v| v.nil? }
        insert_job = API::Job.new(
          configuration: API::JobConfiguration.new(
            load: API::JobConfigurationLoad.new(load_opts),
            dry_run: options[:dryrun]
          )
        )

        service.insert_job @project, insert_job
      end

      def load_table_file dataset_id, table_id, file, options = {}
        #insert_job(project_id, job_object = nil, fields: nil, quota_user: nil, user_ip: nil, upload_source: nil, content_type: nil, options: nil) {|result, err| ... } ⇒ Google::Apis::BigqueryV2::Job

        path = Pathname(file).to_path
        load_opts = {
          destination_table: Google::Apis::BigqueryV2::TableReference.new(
            project_id: @project, dataset_id: dataset_id, table_id: table_id),
          create_disposition: create_disposition(options[:create]),
          write_disposition: write_disposition(options[:write]),
          source_format: source_format(path, options[:format]),
          projection_fields: projection_fields(options[:projection_fields]),
          allow_jagged_rows: options[:jagged_rows],
          allow_quoted_newlines: options[:quoted_newlines],
          encoding: options[:encoding],
          field_delimiter: options[:delimiter],
          ignore_unknown_values: options[:ignore_unknown],
          max_bad_records: options[:max_bad_records],
          quote: options[:quote],
          schema: options[:schema],
          skip_leading_rows: options[:skip_leading]
        }.delete_if { |_, v| v.nil? }
        insert_job = API::Job.new(
          configuration: API::JobConfiguration.new(
            load: API::JobConfigurationLoad.new(load_opts),
            dry_run: options[:dryrun]
          )
        )

        service.insert_job \
          @project, insert_job, upload_source: file,
                                content_type: mime_type_for(file)
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
          fail ArgumentError, "unable to identify table from #{str.inspect}"
        end
        str_table_ref_hash = { project_id: m["prj"],
                               dataset_id: m["dts"],
                               table_id:   m["tbl"] }.delete_if { |_, v| v.nil? }
        new_table_ref_hash = default_table_ref.to_h.merge str_table_ref_hash
        Google::Apis::BigqueryV2::TableReference.new new_table_ref_hash
      end

      def inspect
        "#{self.class}(#{@project})"
      end

      protected

      ##
      # Job description for query job
      def query_table_config query, options
        dest_table = nil
        if options[:table]
          dest_table = API::TableReference.new(
            project_id: options[:table].project_id,
            dataset_id: options[:table].dataset_id,
            table_id: options[:table].table_id
          )
        end
        default_dataset = nil
        if dataset = options[:dataset]
          if dataset.respond_to? :dataset_id
            default_dataset = API::DatasetReference.new(
              project_id: dataset.project_id,
              dataset_id: dataset.dataset_id
            )
          else
            default_dataset = API::DatasetReference.new dataset_id: dataset
          end
        end
        API::Job.new(
          configuration: API::JobConfiguration.new(
            query: API::JobConfigurationQuery.new(
              query: query,
              # tableDefinitions: { ... },
              priority: priority_value(options[:priority]),
              use_query_cache: options[:cache],
              destination_table: dest_table,
              create_disposition: create_disposition(options[:create]),
              write_disposition: write_disposition(options[:write]),
              allow_large_results: options[:large_results],
              flatten_results: options[:flatten],
              default_dataset: default_dataset
            )
          )
        )
      end

      def query_config query, options = {}
        dataset_config = nil
        dataset_config = API::DatasetReference.new(
          dataset_id: options[:dataset],
          project_id: options[:project] || @project
        ) if options[:dataset]

        API::QueryRequest.new(
          query: query,
          max_results: options[:max],
          default_dataset: dataset_config,
          timeout_ms: options[:timeout],
          dry_run: options[:dryrun],
          use_query_cache: options[:cache]
        )
      end

      ##
      # Job description for copy job
      def copy_table_config source, target, options = {}
        API::Job.new(
          configuration: API::JobConfiguration.new(
            copy: API::JobConfigurationTableCopy.new(
              source_table: source,
              destination_table: target,
              create_disposition: create_disposition(options[:create]),
              write_disposition: write_disposition(options[:write])
            ),
            dry_run: options[:dryrun]
          )
        )
      end

      def extract_table_config table, storage_files, options = {}
        storage_urls = Array(storage_files).map do |url|
          url.respond_to?(:to_gs_url) ? url.to_gs_url : url
        end
        dest_format = source_format storage_urls.first, options[:format]
        API::Job.new(
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
      end

      def create_disposition str
        { "create_if_needed" => "CREATE_IF_NEEDED",
          "createifneeded" => "CREATE_IF_NEEDED",
          "if_needed" => "CREATE_IF_NEEDED",
          "needed" => "CREATE_IF_NEEDED",
          "create_never" => "CREATE_NEVER",
          "createnever" => "CREATE_NEVER",
          "never" => "CREATE_NEVER" }[str.to_s.downcase]
      end

      def write_disposition str
        { "write_truncate" => "WRITE_TRUNCATE",
          "writetruncate" => "WRITE_TRUNCATE",
          "truncate" => "WRITE_TRUNCATE",
          "write_append" => "WRITE_APPEND",
          "writeappend" => "WRITE_APPEND",
          "append" => "WRITE_APPEND",
          "write_empty" => "WRITE_EMPTY",
          "writeempty" => "WRITE_EMPTY",
          "empty" => "WRITE_EMPTY" }[str.to_s.downcase]
      end

      def priority_value str
        { "batch" => "BATCH",
          "interactive" => "INTERACTIVE" }[str.to_s.downcase]
      end

      def source_format path, format
        val = { "csv" => "CSV",
                "json" => "NEWLINE_DELIMITED_JSON",
                "newline_delimited_json" => "NEWLINE_DELIMITED_JSON",
                "avro" => "AVRO",
                "datastore" => "DATASTORE_BACKUP",
                "datastore_backup" => "DATASTORE_BACKUP"}[format.to_s.downcase]
        return val unless val.nil?
        return nil if path.nil?
        return "CSV" if path.end_with? ".csv"
        return "NEWLINE_DELIMITED_JSON" if path.end_with? ".json"
        return "AVRO" if path.end_with? ".avro"
        return "DATASTORE_BACKUP" if path.end_with? ".backup_info"
        nil
      end

      def projection_fields array_or_str
        Array(array_or_str) unless array_or_str.nil?
      end

      def mime_type_for file
        mime_type = MIME::Types.of(Pathname(file).to_path).first.to_s
        return nil if mime_type.empty?
        mime_type
      rescue
        nil
      end
    end
  end
end
