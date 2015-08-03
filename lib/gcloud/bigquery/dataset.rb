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
      # Updates the descriptive name for the dataset.
      def name= new_name
        patch_gapi! name: new_name
      end

      ##
      # A string hash of the dataset.
      def etag
        ensure_full_data!
        @gapi["etag"]
      end

      ##
      # A URL that can be used to access the dataset using the REST API.
      def url
        ensure_full_data!
        @gapi["selfLink"]
      end

      ##
      # A user-friendly description of the dataset.
      def description
        ensure_full_data!
        @gapi["description"]
      end

      ##
      # Updates the user-friendly description of the dataset.
      def description= new_description
        patch_gapi! description: new_description
      end

      ##
      # The default lifetime of all tables in the dataset, in milliseconds.
      def default_expiration
        ensure_full_data!
        @gapi["defaultTableExpirationMs"]
      end

      ##
      # Updates the default lifetime of all tables in the dataset, in
      # milliseconds.
      def default_expiration= new_default_expiration
        patch_gapi! default_expiration: new_default_expiration
      end

      ##
      # The time when this dataset was created.
      def created_at
        ensure_full_data!
        Time.at(@gapi["creationTime"] / 1000.0)
      end

      ##
      # The date when this dataset or any of its tables was last modified.
      def modified_at
        ensure_full_data!
        Time.at(@gapi["lastModifiedTime"] / 1000.0)
      end

      ##
      # The geographic location where the dataset should reside. Possible
      # values include EU and US. The default value is US.
      def location
        ensure_full_data!
        @gapi["location"]
      end

      ##
      # Permanently deletes the dataset.
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
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #
      #   dataset = bigquery.dataset "my_dataset"
      #   dataset.delete
      #
      def delete options = {}
        ensure_connection!
        resp = connection.delete_dataset dataset_id, options
        if resp.success?
          true
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Creates a new table.
      #
      # === Parameters
      #
      # +table_id+::
      #   The ID of the table. The ID must contain only letters (a-z, A-Z),
      #   numbers (0-9), or underscores (_). The maximum length is 1,024
      #   characters. (+String+)
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
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   dataset = bigquery.dataset "my_dataset"
      #   table = dataset.create_table "my_table"
      #
      # A name and description can be provided:
      #
      #   require "gcloud/bigquery"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   dataset = bigquery.dataset "my_dataset"
      #   table = dataset.create_table "my_table"
      #                                name: "My Table",
      #                                description: "This is my table"
      #
      def create_table table_id, options = {}
        ensure_connection!
        resp = connection.insert_table dataset_id, table_id, options
        if resp.success?
          Table.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Creates a new view table from the given query.
      #
      # === Parameters
      #
      # +table_id+::
      #   The ID of the table. The ID must contain only letters (a-z, A-Z),
      #   numbers (0-9), or underscores (_). The maximum length is 1,024
      #   characters. (+String+)
      # +query+::
      #   The query that BigQuery executes when the view is referenced.
      #   (+String+)
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
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   dataset = bigquery.dataset "my_dataset"
      #   table = dataset.create_view "my_table",
      #             "SELECT name, age FROM [proj:dataset.users]"
      #
      # A name and description can be provided:
      #
      #   require "gcloud/bigquery"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   dataset = bigquery.dataset "my_dataset"
      #   table = dataset.create_view "my_table",
      #             "SELECT name, age FROM [proj:dataset.users]",
      #             name: "My Table", description: "This is my table"
      #
      def create_view table_id, query, options = {}
        options[:query] = query
        create_table table_id, options
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
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   dataset = bigquery.dataset "my_dataset"
      #   table = dataset.table "my_table"
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
      #   require "gcloud/bigquery"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   dataset = bigquery.dataset "my_dataset"
      #   tables = dataset.tables
      #   tables.each do |table|
      #     puts table.name
      #   end
      #
      # If you have a significant number of tables, you may need to paginate
      # through them: (See Dataset::List#token)
      #
      #   require "gcloud/bigquery"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   dataset = bigquery.dataset "my_dataset"
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
      # Queries data.
      #
      # Sets the current dataset as the default dataset in the query. Useful for
      # using unqualified table names.
      #
      # === Parameters
      #
      # +query+::
      #   Query. (+String+)
      # <code>options[:priority]</code>::
      #   Specifies a priority for the query. Possible values include
      #   +INTERACTIVE+ and +BATCH+. The default value is +INTERACTIVE+.
      #   (+String+)
      # <code>options[:cache]</code>::
      #   Whether to look for the result in the query cache. The query cache is
      #   a best-effort cache that will be flushed whenever tables in the query
      #   are modified. The default value is +true+. (+Boolean+)
      # <code>options[:table]</code>::
      #   The table where the query results should be stored. If not present, a
      #   new table will be created to store the results. (+Table+)
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
      # <code>options[:large_results]</code>::
      #   If +true+, allows the query to produce arbitrarily large result tables
      #   at a slight cost in performance. Requires <code>options[:table]</code>
      #   to be set. (+Boolean+)
      # <code>options[:flatten]</code>::
      #   Flattens all nested and repeated fields in the query results. The
      #   default value is +true+. <code>options[:large_results]</code> must be
      #   +true+ if this is set to +false+. (+Boolean+)
      #
      # === Returns
      #
      # Gcloud::Bigquery::QueryJob
      #
      # === Example
      #
      #   require "gcloud/bigquery"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #
      #   job = bigquery.query "SELECT name FROM [my_proj:my_data.my_table]"
      #   if job.complete?
      #     job.query_results.each do |row|
      #       puts row["name"]
      #     end
      #   end
      #
      def query query, options = {}
        options[:dataset] ||= self
        ensure_connection!
        resp = connection.query_job query, options
        if resp.success?
          Job.from_gapi resp.data, connection
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

      def patch_gapi! options = {}
        ensure_connection!
        resp = connection.patch_dataset dataset_id, options
        if resp.success?
          @gapi = resp.data
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Load the complete representation of the dataset if it has been
      # only partially loaded by a request to the API list method.
      def ensure_full_data!
        reload_gapi! unless data_complete?
      end

      def reload_gapi!
        ensure_connection!
        resp = connection.get_dataset dataset_id
        if resp.success?
          @gapi = resp.data
        else
          fail ApiError.from_response(resp)
        end
      end

      def data_complete?
        !@gapi["creationTime"].nil?
      end
    end
  end
end
