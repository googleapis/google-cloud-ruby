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
require "gcloud/bigquery/table/schema"
require "gcloud/bigquery/dataset/list"
require "gcloud/bigquery/dataset/access"

module Gcloud
  module Bigquery
    ##
    # = Dataset
    #
    # Represents a Dataset. A dataset is a grouping mechanism that holds zero or
    # more tables. Datasets are the lowest level unit of access control; you
    # cannot control access at the table level. A dataset is contained within a
    # specific project.
    #
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   bigquery = gcloud.bigquery
    #
    #   dataset = bigquery.create_dataset "my_dataset",
    #                                     name: "My Dataset",
    #                                     description: "This is my Dataset"
    #
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
      #
      # :category: Attributes
      #
      def dataset_id
        @gapi["datasetReference"]["datasetId"]
      end

      ##
      # The ID of the project containing this dataset.
      #
      # :category: Attributes
      #
      def project_id
        @gapi["datasetReference"]["projectId"]
      end

      ##
      # The gapi fragment containing the Project ID and Dataset ID as a
      # camel-cased hash.
      def dataset_ref #:nodoc:
        dataset_ref = @gapi["datasetReference"]
        dataset_ref = dataset_ref.to_hash if dataset_ref.respond_to? :to_hash
        dataset_ref
      end

      ##
      # A descriptive name for the dataset.
      #
      # :category: Attributes
      #
      def name
        @gapi["friendlyName"]
      end

      ##
      # Updates the descriptive name for the dataset.
      #
      # :category: Attributes
      #
      def name= new_name
        patch_gapi! name: new_name
      end

      ##
      # A string hash of the dataset.
      #
      # :category: Attributes
      #
      def etag
        ensure_full_data!
        @gapi["etag"]
      end

      ##
      # A URL that can be used to access the dataset using the REST API.
      #
      # :category: Attributes
      #
      def url
        ensure_full_data!
        @gapi["selfLink"]
      end

      ##
      # A user-friendly description of the dataset.
      #
      # :category: Attributes
      #
      def description
        ensure_full_data!
        @gapi["description"]
      end

      ##
      # Updates the user-friendly description of the dataset.
      #
      # :category: Attributes
      #
      def description= new_description
        patch_gapi! description: new_description
      end

      ##
      # The default lifetime of all tables in the dataset, in milliseconds.
      #
      # :category: Attributes
      #
      def default_expiration
        ensure_full_data!
        @gapi["defaultTableExpirationMs"]
      end

      ##
      # Updates the default lifetime of all tables in the dataset, in
      # milliseconds.
      #
      # :category: Attributes
      #
      def default_expiration= new_default_expiration
        patch_gapi! default_expiration: new_default_expiration
      end

      ##
      # The time when this dataset was created.
      #
      # :category: Attributes
      #
      def created_at
        ensure_full_data!
        Time.at(@gapi["creationTime"] / 1000.0)
      end

      ##
      # The date when this dataset or any of its tables was last modified.
      #
      # :category: Attributes
      #
      def modified_at
        ensure_full_data!
        Time.at(@gapi["lastModifiedTime"] / 1000.0)
      end

      ##
      # The geographic location where the dataset should reside. Possible
      # values include EU and US. The default value is US.
      #
      # :category: Attributes
      #
      def location
        ensure_full_data!
        @gapi["location"]
      end

      ##
      # Retrieves the access rules for a Dataset using the Google Cloud
      # Datastore API data structure of an array of hashes. The rules can be
      # updated when passing a block, see Dataset::Access for all the methods
      # available. See {BigQuery Access
      # Control}[https://cloud.google.com/bigquery/access-control] for more
      # information.
      #
      # === Examples
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   dataset = bigquery.dataset "my_dataset"
      #
      #   dataset.access #=> [{"role"=>"OWNER",
      #                        "specialGroup"=>"projectOwners"},
      #                       {"role"=>"WRITER",
      #                        "specialGroup"=>"projectWriters"},
      #                       {"role"=>"READER",
      #                        "specialGroup"=>"projectReaders"},
      #                       {"role"=>"OWNER",
      #                        "userByEmail"=>"123456789-...com"}]
      #
      # Manage the access rules by passing a block.
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   dataset = bigquery.dataset "my_dataset"
      #
      #   dataset.access do |access|
      #     access.add_owner_group "owners@example.com"
      #     access.add_writer_user "writer@example.com"
      #     access.remove_writer_user "readers@example.com"
      #     access.add_reader_special :all
      #     access.add_reader_view other_dataset_view_object
      #   end
      #
      def access
        ensure_full_data!
        g = @gapi
        g = g.to_hash if g.respond_to? :to_hash
        a = g["access"] ||= []
        return a unless block_given?
        a2 = Access.new a, dataset_ref
        yield a2
        self.access = a2.access if a2.changed?
      end

      ##
      # Sets the access rules for a Dataset using the Google Cloud Datastore API
      # data structure of an array of hashes. See {BigQuery Access
      # Control}[https://cloud.google.com/bigquery/access-control] for more
      # information.
      #
      # This method is provided for advanced usage of managing the access rules.
      # Calling #access with a block is the preferred way to manage access
      # rules.
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   dataset = bigquery.dataset "my_dataset"
      #
      #   dataset.access = [{"role"=>"OWNER",
      #                      "specialGroup"=>"projectOwners"},
      #                     {"role"=>"WRITER",
      #                      "specialGroup"=>"projectWriters"},
      #                     {"role"=>"READER",
      #                      "specialGroup"=>"projectReaders"},
      #                     {"role"=>"OWNER",
      #                      "userByEmail"=>"123456789-...com"}]
      #
      def access= new_access
        patch_gapi! access: new_access
      end

      ##
      # Permanently deletes the dataset. The dataset must be empty before it can
      # be deleted unless the +force+ option is set to +true+.
      #
      # === Parameters
      #
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:force]</code>::
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
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #
      #   dataset = bigquery.dataset "my_dataset"
      #   dataset.delete
      #
      # :category: Lifecycle
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
      # <code>options[:schema]</code>::
      #   A hash specifying fields and data types for the table. A block may be
      #   passed instead (see examples.) For the format of this hash, see the
      #   {Tables resource
      #   }[https://cloud.google.com/bigquery/docs/reference/v2/tables#resource]
      #   . (+Hash+)
      #
      # === Returns
      #
      # Gcloud::Bigquery::Table
      #
      # === Examples
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   dataset = bigquery.dataset "my_dataset"
      #   table = dataset.create_table "my_table"
      #
      # You can also pass name and description options.
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   dataset = bigquery.dataset "my_dataset"
      #   table = dataset.create_table "my_table"
      #                                name: "My Table",
      #                                description: "A description of my table."
      #
      # You can define the table's schema using a block.
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   dataset = bigquery.dataset "my_dataset"
      #   table = dataset.create_table "my_table" do |schema|
      #     schema.string "first_name", mode: :required
      #     schema.record "cities_lived", mode: :repeated do |nested_schema|
      #       nested_schema.string "place", mode: :required
      #       nested_schema.integer "number_of_years", mode: :required
      #     end
      #   end
      #
      # Or, if you are adapting existing code that was written for the {Rest API
      # }[https://cloud.google.com/bigquery/docs/reference/v2/tables#resource],
      # you can pass the table's schema as a hash.
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   dataset = bigquery.dataset "my_dataset"
      #
      #   schema = {
      #     "fields" => [
      #       {
      #         "name" => "first_name",
      #         "type" => "STRING",
      #         "mode" => "REQUIRED"
      #       },
      #       {
      #         "name" => "cities_lived",
      #         "type" => "RECORD",
      #         "mode" => "REPEATED",
      #         "fields" => [
      #           {
      #             "name" => "place",
      #             "type" => "STRING",
      #             "mode" => "REQUIRED"
      #           },
      #           {
      #             "name" => "number_of_years",
      #             "type" => "INTEGER",
      #             "mode" => "REQUIRED"
      #           }
      #         ]
      #       }
      #     ]
      #   }
      #   table = dataset.create_table "my_table", schema: schema
      #
      # :category: Table
      #
      def create_table table_id, options = {}
        ensure_connection!
        if block_given?
          if options[:schema]
            fail ArgumentError, "only schema block or schema option is allowed"
          end
          schema_builder = Table::Schema.new nil
          yield schema_builder
          options[:schema] = schema_builder.schema if schema_builder.changed?
        end
        insert_table table_id, options
      end

      ##
      # Creates a new view table from the given query.
      #
      # === Parameters
      #
      # +table_id+::
      #   The ID of the view table. The ID must contain only letters (a-z, A-Z),
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
      # Gcloud::Bigquery::View
      #
      # === Examples
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   dataset = bigquery.dataset "my_dataset"
      #   view = dataset.create_view "my_view",
      #             "SELECT name, age FROM [proj:dataset.users]"
      #
      # A name and description can be provided:
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   dataset = bigquery.dataset "my_dataset"
      #   view = dataset.create_view "my_view",
      #             "SELECT name, age FROM [proj:dataset.users]",
      #             name: "My View", description: "This is my view"
      #
      # :category: Table
      #
      def create_view table_id, query, options = {}
        options[:query] = query
        create_table table_id, options
      end

      ##
      # Retrieves an existing table by ID.
      #
      # === Parameters
      #
      # +table_id+::
      #   The ID of a table. (+String+)
      #
      # === Returns
      #
      # Gcloud::Bigquery::Table or Gcloud::Bigquery::View or nil if the table
      # does not exist
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   dataset = bigquery.dataset "my_dataset"
      #   table = dataset.table "my_table"
      #   puts table.name
      #
      # :category: Table
      #
      def table table_id
        ensure_connection!
        resp = connection.get_table dataset_id, table_id
        if resp.success?
          Table.from_gapi resp.data, connection
        else
          nil
        end
      end

      ##
      # Retrieves the list of tables belonging to the dataset.
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
      # Array of Gcloud::Bigquery::Table or Gcloud::Bigquery::View
      # (Gcloud::Bigquery::Table::List)
      #
      # === Examples
      #
      #   require "gcloud"
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
      #   require "gcloud"
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
      # :category: Table
      #
      def tables options = {}
        ensure_connection!
        resp = connection.list_tables dataset_id, options
        if resp.success?
          Table::List.from_response resp, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Queries data using the {asynchronous
      # method}[https://cloud.google.com/bigquery/querying-data].
      #
      # Sets the current dataset as the default dataset in the query. Useful for
      # using unqualified table names.
      #
      # === Parameters
      #
      # +query+::
      #   A query string, following the BigQuery {query
      #   syntax}[https://cloud.google.com/bigquery/query-reference], of the
      #   query to execute. Example: "SELECT count(f1) FROM
      #   [myProjectId:myDatasetId.myTableId]". (+String+)
      # <code>options[:priority]</code>::
      #   Specifies a priority for the query. Possible values include
      #   +INTERACTIVE+ and +BATCH+. The default value is +INTERACTIVE+.
      #   (+String+)
      # <code>options[:cache]</code>::
      #   Whether to look for the result in the query cache. The query cache is
      #   a best-effort cache that will be flushed whenever tables in the query
      #   are modified. The default value is +true+. (+Boolean+)
      # <code>options[:table]</code>::
      #   The destination table where the query results should be stored. If not
      #   present, a new table will be created to store the results. (+Table+)
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
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #
      #   job = bigquery.query_job "SELECT name FROM my_table"
      #
      #   job.wait_until_done!
      #   if !job.failed?
      #     job.query_results.each do |row|
      #       puts row["name"]
      #     end
      #   end
      #
      # :category: Data
      #
      def query_job query, options = {}
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
      # Queries data using the {synchronous
      # method}[https://cloud.google.com/bigquery/querying-data].
      #
      # Sets the current dataset as the default dataset in the query. Useful for
      # using unqualified table names.
      #
      # === Parameters
      #
      # +query+::
      #   A query string, following the BigQuery {query
      #   syntax}[https://cloud.google.com/bigquery/query-reference], of the
      #   query to execute. Example: "SELECT count(f1) FROM
      #   [myProjectId:myDatasetId.myTableId]". (+String+)
      # <code>options[:max]</code>::
      #   The maximum number of rows of data to return per page of results.
      #   Setting this flag to a small value such as 1000 and then paging
      #   through results might improve reliability when the query result set is
      #   large. In addition to this limit, responses are also limited to 10 MB.
      #   By default, there is no maximum row count, and only the byte limit
      #   applies. (+Integer+)
      # <code>options[:timeout]</code>::
      #   How long to wait for the query to complete, in milliseconds, before
      #   the request times out and returns. Note that this is only a timeout
      #   for the request, not the query. If the query takes longer to run than
      #   the timeout value, the call returns without any results and with
      #   QueryData#complete? set to false. The default value is 10000
      #   milliseconds (10 seconds). (+Integer+)
      # <code>options[:dryrun]</code>::
      #   If set to +true+, BigQuery doesn't run the job. Instead, if the query
      #   is valid, BigQuery returns statistics about the job such as how many
      #   bytes would be processed. If the query is invalid, an error returns.
      #   The default value is +false+. (+Boolean+)
      # <code>options[:cache]</code>::
      #   Whether to look for the result in the query cache. The query cache is
      #   a best-effort cache that will be flushed whenever tables in the query
      #   are modified. The default value is true. For more information, see
      #   {query caching}[https://developers.google.com/bigquery/querying-data].
      #   (+Boolean+)
      #
      # === Returns
      #
      # Gcloud::Bigquery::QueryData
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #
      #   data = bigquery.query "SELECT name FROM my_table"
      #   data.each do |row|
      #     puts row["name"]
      #   end
      #
      # :category: Data
      #
      def query query, options = {}
        options[:dataset] ||= dataset_id
        options[:project] ||= project_id
        ensure_connection!
        resp = connection.query query, options
        if resp.success?
          QueryData.from_gapi resp.data, connection
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

      def insert_table table_id, options
        resp = connection.insert_table dataset_id, table_id, options
        if resp.success?
          Table.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end

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
