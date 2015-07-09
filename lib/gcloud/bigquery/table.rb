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
          ApiError.from_response(resp)
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
          ApiError.from_response(resp)
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
          ApiError.from_response(resp)
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
          ApiError.from_response(resp)
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
    end
  end
end
