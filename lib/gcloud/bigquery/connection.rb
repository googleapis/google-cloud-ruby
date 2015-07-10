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

require "gcloud/version"
require "google/api_client"
require "mime/types"

module Gcloud
  module Bigquery
    ##
    # Represents the connection to Bigquery,
    # as well as expose the API calls.
    class Connection #:nodoc:
      API_VERSION = "v2"

      attr_accessor :project
      attr_accessor :credentials #:nodoc:

      ##
      # Creates a new Connection instance.
      def initialize project, credentials
        @project = project
        @credentials = credentials
        @client = Google::APIClient.new application_name:    "gcloud-ruby",
                                        application_version: Gcloud::VERSION
        @client.authorization = @credentials.client
        @bigquery = @client.discovered_api "bigquery", API_VERSION
      end

      ##
      # Lists all datasets in the specified project to which you have
      # been granted the READER dataset role.
      def list_datasets options = {}
        params = { projectId: @project,
                   all: options.delete(:all),
                   pageToken: options.delete(:token),
                   maxResults: options.delete(:max)
                 }.delete_if { |_, v| v.nil? }

        @client.execute(
          api_method: @bigquery.datasets.list,
          parameters: params
        )
      end

      ##
      # Returns the dataset specified by datasetID.
      def get_dataset dataset_id
        @client.execute(
          api_method: @bigquery.datasets.get,
          parameters: { projectId: @project, datasetId: dataset_id }
        )
      end

      ##
      # Creates a new empty dataset.
      def insert_dataset dataset_id, options = {}
        @client.execute(
          api_method: @bigquery.datasets.insert,
          parameters: { projectId: @project },
          body_object: insert_dataset_request(dataset_id, options)
        )
      end

      ##
      # Updates information in an existing dataset, only replacing
      # fields that are provided in the submitted dataset resource.
      def patch_dataset project_id, dataset_id, options = {}
        body = { friendlyName: options[:name],
                 description: options[:description],
                 defaultTableExpirationMs: options[:table_expiration]
               }.delete_if { |_, v| v.nil? }

        @client.execute(
          api_method: @bigquery.datasets.patch,
          parameters: { projectId: project_id, datasetId: dataset_id },
          body_object: body
        )
      end

      ##
      # Deletes the dataset specified by the datasetId value.
      # Before you can delete a dataset, you must delete all its tables,
      # either manually or by specifying force: true in options.
      # Immediately after deletion, you can create another dataset with
      # the same name.
      def delete_dataset dataset_id, options = {}
        @client.execute(
          api_method: @bigquery.datasets.delete,
          parameters: { projectId: @project, datasetId: dataset_id,
                        deleteContents: options[:force]
                      }.delete_if { |_, v| v.nil? }
        )
      end

      ##
      # Lists all tables in the specified dataset.
      # Requires the READER dataset role.
      def list_tables dataset_id, options = {}
        params = { projectId: @project,
                   datasetId: dataset_id,
                   pageToken: options.delete(:token),
                   maxResults: options.delete(:max)
                 }.delete_if { |_, v| v.nil? }

        @client.execute(
          api_method: @bigquery.tables.list,
          parameters: params
        )
      end

      ##
      # Gets the specified table resource by table ID.
      # This method does not return the data in the table,
      # it only returns the table resource,
      # which describes the structure of this table.
      def get_table dataset_id, table_id
        @client.execute(
          api_method: @bigquery.tables.get,
          parameters: { projectId: @project, datasetId: dataset_id,
                        tableId: table_id }
        )
      end

      ##
      # Creates a new, empty table in the dataset.
      def insert_table dataset_id, table_id, options = {}
        @client.execute(
          api_method: @bigquery.tables.insert,
          parameters: { projectId: @project, datasetId: dataset_id },
          body_object: insert_table_request(dataset_id, table_id, options)
        )
      end

      ##
      # Updates information in an existing table, replacing fields that
      # are provided in the submitted table resource.
      def patch_table dataset_id, table_id, options = {}
        body = { friendlyName: options[:name],
                 description: options[:description]
               }.delete_if { |_, v| v.nil? }

        @client.execute(
          api_method: @bigquery.tables.patch,
          parameters: { projectId: @project, datasetId: dataset_id,
                        tableId: table_id },
          body_object: body
        )
      end

      ##
      # Deletes the table specified by tableId from the dataset.
      # If the table contains data, all the data will be deleted.
      def delete_table dataset_id, table_id
        @client.execute(
          api_method: @bigquery.tables.delete,
          parameters: { projectId: @project, datasetId: dataset_id,
                        tableId: table_id }
        )
      end

      ##
      # Lists all jobs in the specified project to which you have
      # been granted the READER job role.
      def list_jobs options = {}
        @client.execute(
          api_method: @bigquery.jobs.list,
          parameters: list_jobs_params(options)
        )
      end

      ##
      # Returns the job specified by jobID.
      def get_job job_id
        @client.execute(
          api_method: @bigquery.jobs.get,
          parameters: { projectId: @project, jobId: job_id }
        )
      end

      def copy_table source, target, options = {}
        @client.execute(
          api_method: @bigquery.jobs.insert,
          parameters: { projectId: @project },
          body_object: copy_table_config(source, target, options)
        )
      end

      def link_table table, urls, options = {}
        @client.execute(
          api_method: @bigquery.jobs.insert,
          parameters: { projectId: @project },
          body_object: link_table_config(table, urls, options)
        )
      end

      def extract_table table, storage_files, options = {}
        @client.execute(
          api_method: @bigquery.jobs.insert,
          parameters: { projectId: @project },
          body_object: extract_table_config(table, storage_files, options)
        )
      end

      def load_table table, storage_url, options = {}
        @client.execute(
          api_method: @bigquery.jobs.insert,
          parameters: { projectId: @project },
          body_object: load_table_config(table, storage_url, options)
        )
      end

      def load_multipart table, file, options = {}
        media = load_media file

        @client.execute(
          api_method: @bigquery.jobs.insert,
          media: media,
          parameters: { projectId: @project, uploadType: "multipart" },
          body_object: load_table_config(table, nil, options)
        )
      end

      def load_resumable table, file, chunk_size = nil, options = {}
        media = load_media file, chunk_size

        result = @client.execute(
          api_method: @bigquery.jobs.insert,
          media: media,
          parameters: { projectId: @project, uploadType: "resumable" },
          body_object: load_table_config(table, nil, options)
        )
        upload = result.resumable_upload
        result = @client.execute upload while upload.resumable?
        result
      end

      protected

      ##
      # Make sure the object is converted to a hash
      # Ruby 1.9.3 doesn't support to_h, so here we are.
      def hashify hash
        if hash.respond_to? :to_h
          hash.to_h
        else
          Hash.try_convert(hash) || {}
        end
      end

      ##
      # Create the HTTP body for insert dataset
      def insert_dataset_request dataset_id, options = {}
        {
          "kind" => "bigquery#dataset",
          "datasetReference" => {
            "projectId" => @project,
            "datasetId" => dataset_id
          },
          "friendlyName" => options[:name],
          "description" => options[:description],
          "defaultTableExpirationMs" => options[:expiration]
        }.delete_if { |_, v| v.nil? }
      end

      ##
      # The parameters for the list_jobs call.
      def list_jobs_params options = {}
        params = { projectId: @project,
                   allUsers: options.delete(:all),
                   pageToken: options.delete(:token),
                   maxResults: options.delete(:max),
                   projection: options.delete(:projection),
                   stateFilter: options.delete(:filter)
                 }.delete_if { |_, v| v.nil? }
        params
      end

      ##
      # Create the HTTP body for insert table
      def insert_table_request dataset_id, table_id, options = {}
        {
          tableReference: {
            projectId: @project,
            datasetId: dataset_id,
            tableId: table_id
          },
          friendlyName: options[:name],
          description: options[:description]
        }.delete_if { |_, v| v.nil? }
      end

      # rubocop:disable all
      # Disabled rubocop because the API is verbose and so these methods
      # are going to be verbose.

      ##
      # Job descrption for copy job
      def copy_table_config source, target, options = {}
        {
          "configuration" => {
            "copy" => {
              "sourceTable" => {
                "projectId" => source["tableReference"]["projectId"],
                "datasetId" => source["tableReference"]["datasetId"],
                "tableId" => source["tableReference"]["tableId"]
              }.delete_if { |_, v| v.nil? },
              "destinationTable" => {
                "projectId" => target["tableReference"]["projectId"],
                "datasetId" => target["tableReference"]["datasetId"],
                "tableId" => target["tableReference"]["tableId"]
              }.delete_if { |_, v| v.nil? },
              "createDisposition" => create_disposition(options[:create]),
              "writeDisposition" => write_disposition(options[:write])
            }.delete_if { |_, v| v.nil? },
            "dryRun" => options[:dryrun]
          }.delete_if { |_, v| v.nil? }
        }
      end

      def link_table_config table, urls, options = {}
        {
          "configuration" => {
            "link" => {
              "sourceUri" => Array(urls),
              "destinationTable" => {
                "projectId" => table["tableReference"]["projectId"],
                "datasetId" => table["tableReference"]["datasetId"],
                "tableId" => table["tableReference"]["tableId"]
              }.delete_if { |_, v| v.nil? },
              "createDisposition" => create_disposition(options[:create]),
              "writeDisposition" => write_disposition(options[:write])
            }.delete_if { |_, v| v.nil? },
            "dryRun" => options[:dryrun]
          }.delete_if { |_, v| v.nil? }
        }
      end

      def extract_table_config table, storage_files, options = {}
        storage_urls = Array(storage_files).map do |url|
          url.respond_to?(:to_gs_url) ? url.to_gs_url : url
        end
        dest_format = extract_destination_format storage_urls.first, options[:format]
        {
          "configuration" => {
            "extract" => {
              "destinationUris" => Array(storage_urls),
              "sourceTable" => {
                "projectId" => table["tableReference"]["projectId"],
                "datasetId" => table["tableReference"]["datasetId"],
                "tableId" => table["tableReference"]["tableId"]
              }.delete_if { |_, v| v.nil? },
              "destinationFormat" => dest_format,
            }.delete_if { |_, v| v.nil? },
            "dryRun" => options[:dryrun]
          }.delete_if { |_, v| v.nil? }
        }
      end

      def load_table_config table, urls, options = {}
        {
          "configuration" => {
            "load" => {
              "sourceUri" => Array(urls),
              "destinationTable" => {
                "projectId" => table["tableReference"]["projectId"],
                "datasetId" => table["tableReference"]["datasetId"],
                "tableId" => table["tableReference"]["tableId"]
              }.delete_if { |_, v| v.nil? },
              "createDisposition" => create_disposition(options[:create]),
              "writeDisposition" => write_disposition(options[:write])
            }.delete_if { |_, v| v.nil? },
            "dryRun" => options[:dryrun]
          }.delete_if { |_, v| v.nil? }
        }
      end

      def create_disposition str #:nodoc:
        { "create_if_needed" => "CREATE_IF_NEEDED",
          "createifneeded" => "CREATE_IF_NEEDED",
          "if_needed" => "CREATE_IF_NEEDED",
          "needed" => "CREATE_IF_NEEDED",
          "create_never" => "CREATE_NEVER",
          "createnever" => "CREATE_NEVER",
          "never" => "CREATE_NEVER" }[str.to_s.downcase]
      end

      def write_disposition str #:nodoc:
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

      def extract_destination_format url, format
        val = { "csv" => "CSV",
                "json" => "NEWLINE_DELIMITED_JSON",
                "newline_delimited_json" => "NEWLINE_DELIMITED_JSON",
                "avro" => "AVRO" }[format.to_s.downcase]
        return val unless val.nil?
        return "CSV" if url.end_with? ".csv"
        return "NEWLINE_DELIMITED_JSON" if url.end_with? ".json"
        return "AVRO" if url.end_with? ".avro"
        nil
      end

      # rubocop:enable all

      def load_media file, chunk_size = nil
        local_path = Pathname(file).to_path
        mime_type = MIME::Types.of(local_path).first.to_s

        media = Google::APIClient::UploadIO.new local_path, mime_type
        media.chunk_size = chunk_size unless chunk_size.nil?
        media
      end
    end
  end
end
