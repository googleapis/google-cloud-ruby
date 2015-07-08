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
      # Array of Gcloud::Bigquery::Dataset (Gcloud::Bigquery::Dataset::List)
      #
      # === Examples
      #
      #   require "glcoud/bigquery"
      #
      #   bigquery = Gcloud.bigquery
      #
      #   datasets = bigquery.datasets
      #   datasets.each do |dataset|
      #     puts dataset.name
      #   end
      #
      # You can also retrieve all datasets, including hidden ones, by providing
      # the +:all+ option:
      #
      #   require "glcoud/bigquery"
      #
      #   bigquery = Gcloud.bigquery
      #
      #   all_datasets = bigquery.datasets, all: true
      #
      # If you have a significant number of datasets, you may need to paginate
      # through them: (See Dataset::List#token)
      #
      #   require "glcoud/bigquery"
      #
      #   bigquery = Gcloud.bigquery
      #
      #   all_datasets = []
      #   tmp_datasets = bigquery.datasets
      #   while tmp_datasets.any? do
      #     tmp_datasets.each do |dataset|
      #       all_datasets << dataset
      #     end
      #     # break loop if no more datasets available
      #     break if tmp_datasets.token.nil?
      #     # get the next group of datasets
      #     tmp_datasets = bigquery.datasets token: tmp_datasets.token
      #   end
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
