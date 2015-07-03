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

require "json"
require "gcloud/bigquery/errors"
require "gcloud/bigquery/table"
require "gcloud/bigquery/dataset/list"

module Gcloud
  module Bigquery
    ##
    # Represents a Dataset.
    class Dataset
      ##
      # The Connection object.
      attr_accessor :connection #:nodoc:

      ##
      # The Google API Client object.
      attr_accessor :gapi #:nodoc:

      ##
      # Create an empty Dataset object.
      def initialize #:nodoc:
        @connection = nil
        @gapi = {}
      end

      ##
      # A unique ID for this dataset, without the project name.
      # The ID must contain only letters (a-z, A-Z), numbers (0-9),
      # or underscores (_). The maximum length is 1,024 characters.
      def dataset_id
        @gapi["datasetReference"]["datasetId"]
      end

      ##
      # The ID of the project containing this dataset.
      def project_id
        @gapi["datasetReference"]["projectId"]
      end

      ##
      # A descriptive name for the dataset.
      def name
        @gapi["friendlyName"]
      end

      ##
      # A user-friendly description of the dataset.
      def description
        @gapi["description"]
      end

      ##
      # The default lifetime of all tables in the dataset, in milliseconds.
      def default_expiration
        @gapi["defaultTableExpirationMs"]
      end

      ##
      # The time when this dataset was created.
      def created_at
        return nil if @gapi["creationTime"].nil?
        Time.at(@gapi["creationTime"] / 1000.0)
      end

      ##
      # The date when this dataset or any of its tables was last modified.
      def modified_at
        return nil if @gapi["lastModifiedTime"].nil?
        Time.at(@gapi["lastModifiedTime"] / 1000.0)
      end

      ##
      # Permenently deletes the dataset.
      # The dataset must be empty before it can be deleted.
      #
      # === Parameters
      #
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:delete]</code>::
      #   If +true+, delete all the tables in the dataset. If +false+ and the
      #   dataset contains tables, the request will fail. Default is +false+.
      #   (+Boolean+)
      #
      # === Returns
      #
      # +true+ if the dataset was deleted.
      #
      # === Example
      #
      #   require "gcloud/bigquery"
      #
      #   bigquery = Gcloud.bigquery
      #
      #   dataset = bigquery.dataset "my-dataset"
      #   dataset.delete
      #
      def delete options = {}
        ensure_connection!
        resp = connection.delete_dataset dataset_id, options
        if resp.success?
          true
        else
          ApiError.from_response(resp)
        end
      end

      ##
      # Creates a table on a given dataset for a given subscriber.
      #
      # If the name is not provided in the request, the server will assign a
      # random name for this table on the same project as the dataset.
      ##
      # Creates a new table.
      #
      # === Parameters
      #
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:name]</code>::
      #   A descriptive name for the table. (+String+)
      # <code>options[:description]</code>::
      #   A user-friendly description of the table. (+String+)
      #
      # === Returns
      #
      # Gcloud::Bigquery::Table
      #
      # === Examples
      #
      #   require "gcloud/bigquery"
      #
      #   bigquery = Gcloud.bigquery
      #   dataset = bigquery.dataset "my-dataset"
      #   table = dataset.create_table
      #
      # A name and description can be provided:
      #
      #   require "gcloud/bigquery"
      #
      #   bigquery = Gcloud.bigquery
      #   dataset = bigquery.dataset "my-dataset"
      #   table = dataset.create_table name: "my-table",
      #                                description: "My Table"
      #
      def create_table options = {}
        ensure_connection!
        resp = connection.insert_table dataset_id, options
        if resp.success?
          Table.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Retrieves a table by name.
      #
      # === Parameters
      #
      # +table_name+::
      #   Name of a table. (+String+)
      #
      # === Returns
      #
      # Gcloud::Bigquery::Table or nil if table does not exist
      #
      # === Example
      #
      #   require "gcloud/bigquery"
      #
      #   bigquery = Gcloud.bigquery
      #   dataset = bigquery.dataset "my-dataset"
      #   table = dataset.table "my-table"
      #   puts table.name
      #
      def table table_name
        ensure_connection!
        resp = connection.get_table dataset_id, table_name
        if resp.success?
          Table.from_gapi resp.data, connection
        else
          nil
        end
      end

      ##
      # Retrieves a list of tables for the given dataset.
      #
      # === Parameters
      #
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:token]</code>::
      #   A previously-returned page token representing part of the larger set
      #   of results to view. (+String+)
      # <code>options[:max]</code>::
      #   Maximum number of tables to return. (+Integer+)
      #
      # === Returns
      #
      # Array of Gcloud::Bigquery::Table (Gcloud::Bigquery::Table::List)
      #
      # === Examples
      #
      #   require "glcoud/bigquery"
      #
      #   bigquery = Gcloud.bigquery
      #   dataset = bigquery.dataset "my-dataset"
      #   tables = dataset.tables
      #   tables.each do |table|
      #     puts table.name
      #   end
      #
      # If you have a significant number of tables, you may need to paginate
      # through them: (See Dataset::List#token)
      #
      #   require "glcoud/bigquery"
      #
      #   bigquery = Gcloud.bigquery
      #   dataset = bigquery.dataset "my-dataset"
      #
      #   all_tables = []
      #   tmp_tables = dataset.tables
      #   while tmp_tables.any? do
      #     tmp_tables.each do |table|
      #       all_tables << table
      #     end
      #     # break loop if no more tables available
      #     break if tmp_tables.token.nil?
      #     # get the next group of tables
      #     tmp_tables = dataset.tables token: tmp_tables.token
      #   end
      #
      def tables options = {}
        ensure_connection!
        resp = connection.list_tables dataset_id, options
        if resp.success?
          Table::List.from_resp resp, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # New Dataset from a Google API Client object.
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
