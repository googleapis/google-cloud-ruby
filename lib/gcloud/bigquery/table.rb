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

require "gcloud/bigquery/data"
require "gcloud/bigquery/table/list"
require "gcloud/bigquery/errors"

module Gcloud
  module Bigquery
    ##
    # Represents a Table.
    class Table
      ##
      # The Connection object.
      attr_accessor :connection #:nodoc:

      ##
      # The Google API Client object.
      attr_accessor :gapi #:nodoc:

      ##
      # Create an empty Table object.
      def initialize #:nodoc:
        @connection = nil
        @gapi = {}
      end

      ##
      # A unique ID for this table.
      # The ID must contain only letters (a-z, A-Z), numbers (0-9),
      # or underscores (_). The maximum length is 1,024 characters.
      def table_id
        @gapi["tableReference"]["tableId"]
      end

      ##
      # The ID of the dataset containing this table.
      def dataset_id
        @gapi["tableReference"]["datasetId"]
      end

      ##
      # The ID of the project containing this table.
      def project_id
        @gapi["tableReference"]["projectId"]
      end

      ##
      # The name of the table.
      def name
        @gapi["friendlyName"]
      end

      ##
      # The description of the table.
      def description
        @gapi["description"]
      end

      ##
      # The time when this table was created.
      def created_at
        return nil if @gapi["creationTime"].nil?
        Time.at(@gapi["creationTime"] / 1000.0)
      end

      ##
      # The date when this table was last modified.
      def modified_at
        return nil if @gapi["lastModifiedTime"].nil?
        Time.at(@gapi["lastModifiedTime"] / 1000.0)
      end

      ##
      # The time when this table expires.
      # If not present, the table will persist indefinitely.
      # Expired tables will be deleted and their storage reclaimed.
      def expires_at
        return nil if @gapi["expirationTime"].nil?
        Time.at(@gapi["expirationTime"] / 1000.0)
      end

      ##
      # Retrieves data from the table.
      #
      # === Returns
      #
      # Gcloud::Bigquery::Data
      #
      def data
        ensure_connection!
        resp = connection.list_tabledata dataset_id, table_id
        if resp.success?
          Data.from_response resp, self
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Copy data from one table to another.
      #
      # === Parameters
      #
      # +target_table+::
      #   A Table to copy data to. (+Table+)
      # +options+::
      #   An optional Hash for controlling additional behavor. (+Hash+)
      # <code>options[:create]</code>::
      #   Specifies whether the job is allowed to create new tables. (+String+)
      #
      #   The following values are supported:
      #   * +needed+ - Create the table if it does not exist.
      #   * +never+ - The table must already exist. A 'notFound' error is
      #     raised if the table does not exist.
      # <code>options[:write]</code>::
      #   Specifies the action that occurs if the destination table already
      #   exists. (+String+)
      #
      #   The following values are supported:
      #   * +truncate+ - BigQuery overwrites the table data.
      #   * +append+ - BigQuery appends the data to the table.
      #   * +empty+ - A 'duplicate' error is returned in the job result if the
      #     table exists and contains data.
      #
      # === Returns
      #
      # Gcloud::Bigquery::Job
      #
      def copy target_table, options = {}
        ensure_connection!
        resp = connection.copy_table gapi, target_table.gapi, options
        if resp.success?
          Job.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Link table data from URL.
      #
      # === Parameters
      #
      # +source_url+::
      #   URI of source table to link. (+String+)
      # +options+::
      #   An optional Hash for controlling additional behavor. (+Hash+)
      # <code>options[:create]</code>::
      #   Specifies whether the job is allowed to create new tables. (+String+)
      #
      #   The following values are supported:
      #   * +needed+ - Create the table if it does not exist.
      #   * +never+ - The table must already exist. A 'notFound' error is
      #     raised if the table does not exist.
      # <code>options[:write]</code>::
      #   Specifies the action that occurs if the destination table already
      #   exists. (+String+)
      #
      #   The following values are supported:
      #   * +truncate+ - BigQuery overwrites the table data.
      #   * +append+ - BigQuery appends the data to the table.
      #   * +empty+ - A 'duplicate' error is returned in the job result if the
      #     table exists and contains data.
      #
      # === Returns
      #
      # Gcloud::Bigquery::Job
      #
      def link source_url, options = {}
        ensure_connection!
        resp = connection.link_table gapi, source_url, options
        if resp.success?
          Job.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Extract data from the table to a Storage file.
      #
      # === Parameters
      #
      # +extract_url+::
      #   URI of the location and file name where BigQuery should export the
      #   files to, in the format of <code>gs://my-bucket/file-name.json</code>.
      #   (+Gcloud::Storage::File+ or +String+)
      # +options+::
      #   An optional Hash for controlling additional behavor. (+Hash+)
      # <code>options[:format]</code>::
      #   The exported file format. (+String+)
      #
      #   The following values are supported:
      #   * +csv+ - CSV formatted data.
      #   * +json+ - JSON formatted data.
      #   * +avro+ - Avro formatted data.
      #
      # === Returns
      #
      # Gcloud::Bigquery::Job
      #
      def extract extract_url, options = {}
        ensure_connection!
        resp = connection.extract_table gapi, extract_url, options
        if resp.success?
          Job.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Load data to the table.
      #
      # === Parameters
      #
      # +file+::
      #   A file containing the data to load in the table. (+File+ or
      #   +Gcloud::Storage::File+ or +String+)
      # +options+::
      #   An optional Hash for controlling additional behavor. (+Hash+)
      # <code>options[:create]</code>::
      #   Specifies whether the job is allowed to create new tables. (+String+)
      #
      #   The following values are supported:
      #   * +needed+ - Create the table if it does not exist.
      #   * +never+ - The table must already exist. A 'notFound' error is
      #     raised if the table does not exist.
      # <code>options[:write]</code>::
      #   Specifies the action that occurs if the destination table already
      #   exists. (+String+)
      #
      #   The following values are supported:
      #   * +truncate+ - BigQuery overwrites the table data.
      #   * +append+ - BigQuery appends the data to the table.
      #   * +empty+ - A 'duplicate' error is returned in the job result if the
      #     table exists and contains data.
      #
      # === Returns
      #
      # Gcloud::Bigquery::Job
      #
      def load file, options = {}
        ensure_connection!
        if storage_url? file
          load_storage file, options
        elsif local_file? file
          load_local file, options
        else
          fail Gcloud::Bigquery::Error, "Don't know how to load #{file}"
        end
      end

      ##
      # Permenently deletes the table.
      #
      # === Returns
      #
      # +true+ if the table was deleted.
      #
      # === Example
      #
      #   require "gcloud/bigquery"
      #
      #   bigquery = Gcloud.bigquery
      #   dataset = bigquery.dataset "my_dataset"
      #   table = dataset.table "my_table"
      #   table.delete
      #
      def delete
        ensure_connection!
        resp = connection.delete_table dataset_id, table_id
        if resp.success?
          true
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # New Table from a Google API Client object.
      def self.from_gapi gapi, conn #:nodoc:
        new.tap do |f|
          f.gapi = gapi
          f.connection = conn
        end
      end

      protected

      ##
      # Raise an error unless an active connection is available.
      def ensure_connection!
        fail "Must have active connection" unless connection
      end

      def load_storage file, options = {}
        # Convert to storage URL
        file = file.to_gs_url if file.respond_to? :to_gs_url

        resp = connection.load_table gapi, file, options
        if resp.success?
          Job.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      def load_local file, options = {}
        if resumable_upload? file
          load_resumable file, options
        else
          load_multipart file, options
        end
      end

      def load_resumable file, options = {}
        chunk_size = verify_chunk_size! options[:chunk_size]
        resp = connection.load_resumable gapi, file, chunk_size, options
        if resp.success?
          Job.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      def load_multipart file, options = {}
        resp = connection.load_multipart gapi, file, options
        if resp.success?
          Job.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Determines if a resumable upload should be used.
      def resumable_upload? file #:nodoc:
        ::File.size?(file).to_i > Storage.resumable_threshold
      end

      def storage_url? file
        file.respond_to?(:to_gs_url) ||
          (file.respond_to?(:to_str) &&
          file.to_str.downcase.start_with?("gs://"))
      end

      def local_file? file
        ::File.file? file
      rescue
        false
      end

      ##
      # Determines if a chunk_size is valid.
      def verify_chunk_size! chunk_size
        chunk_size = chunk_size.to_i
        chunk_mod = 256 * 1024 # 256KB
        if (chunk_size.to_i % chunk_mod) != 0
          chunk_size = (chunk_size / chunk_mod) * chunk_mod
        end
        return if chunk_size.zero?
        chunk_size
      end
    end
  end
end
