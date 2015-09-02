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

require "gcloud/bigquery/connection"
require "gcloud/bigquery/credentials"
require "gcloud/bigquery/errors"
require "gcloud/bigquery/dataset"
require "gcloud/bigquery/job"
require "gcloud/bigquery/query_data"

module Gcloud
  module Bigquery
    ##
    # = Project
    #
    # Projects are top-level containers in Google Cloud Platform. They store
    # information about billing and authorized users, and they contain BigQuery
    # data. Each project has a friendly name and a unique ID.
    #
    # Gcloud::Bigquery::Project is the main object for interacting with
    # Google BigQuery. Gcloud::Bigquery::Dataset objects are created,
    # accessed, and deleted by Gcloud::Bigquery::Project.
    #
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   bigquery = gcloud.bigquery
    #   dataset = bigquery.dataset "my_dataset"
    #   table = dataset.table "my_table"
    #
    # See Gcloud#bigquery
    class Project
      ##
      # The Connection object.
      attr_accessor :connection #:nodoc:

      ##
      # Creates a new Connection instance.
      #
      # See Gcloud.bigquery
      def initialize project, credentials
        project = project.to_s # Always cast to a string
        fail ArgumentError, "project is missing" if project.empty?
        @connection = Connection.new project, credentials
      end

      ##
      # The BigQuery project connected to.
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new "my-todo-project", "/path/to/keyfile.json"
      #   bigquery = gcloud.bigquery
      #
      #   bigquery.project #=> "my-todo-project"
      #
      def project
        connection.project
      end

      ##
      # Default project.
      def self.default_project #:nodoc:
        ENV["BIGQUERY_PROJECT"] ||
          ENV["GCLOUD_PROJECT"] ||
          ENV["GOOGLE_CLOUD_PROJECT"]
      end

      ##
      # Queries data using the {asynchronous
      # method}[https://cloud.google.com/bigquery/querying-data].
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
      # <code>options[:dataset]</code>::
      #   Specifies the default dataset to use for unqualified table names in
      #   the query. (+Dataset+ or +String+)
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
      #   job = bigquery.query_job "SELECT name FROM [my_proj:my_data.my_table]"
      #
      #   job.wait_until_done!
      #   if !job.failed?
      #     job.query_results.each do |row|
      #       puts row["name"]
      #     end
      #   end
      #
      def query_job query, options = {}
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
      # <code>options[:dataset]</code>::
      #   Specifies the default datasetId and projectId to assume for any
      #   unqualified table names in the query. If not set, all table names in
      #   the query string must be qualified in the format 'datasetId.tableId'.
      #   (+String+)
      # <code>options[:project]</code>::
      #   Specifies the default projectId to assume for any unqualified table
      #   names in the query. Only used if +dataset+ option is set. (+String+)
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
      #   data = bigquery.query "SELECT name FROM [my_proj:my_data.my_table]"
      #   data.each do |row|
      #     puts row["name"]
      #   end
      #
      def query query, options = {}
        ensure_connection!
        resp = connection.query query, options
        if resp.success?
          QueryData.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Retrieves an existing dataset by ID.
      #
      # === Parameters
      #
      # +dataset_id+::
      #   The ID of a dataset. (+String+)
      #
      # === Returns
      #
      # Gcloud::Bigquery::Dataset or nil if dataset does not exist
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #
      #   dataset = bigquery.dataset "my_dataset"
      #   puts dataset.name
      #
      def dataset dataset_id
        ensure_connection!
        resp = connection.get_dataset dataset_id
        if resp.success?
          Dataset.from_gapi resp.data, connection
        else
          return nil if resp.status == 404
          fail ApiError.from_response(resp)
        end
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      # Disabled rubocop because the level of abstraction is not violated here

      ##
      # Creates a new dataset.
      #
      # === Parameters
      #
      # +dataset_id+::
      #   A unique ID for this dataset, without the project name.
      #   The ID must contain only letters (a-z, A-Z), numbers (0-9), or
      #   underscores (_). The maximum length is 1,024 characters. (+String+)
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:name]</code>::
      #   A descriptive name for the dataset. (+String+)
      # <code>options[:description]</code>::
      #   A user-friendly description of the dataset. (+String+)
      # <code>options[:expiration]</code>::
      #   The default lifetime of all tables in the dataset, in milliseconds.
      #   The minimum value is 3600000 milliseconds (one hour). (+Integer+)
      # <code>options[:access]</code>::
      #   The access rules for a Dataset using the Google Cloud Datastore API
      #   data structure of an array of hashes. See {BigQuery Access
      #   Control}[https://cloud.google.com/bigquery/access-control] for more
      #   information. (+Array of Hashes+)
      #
      # === Returns
      #
      # Gcloud::Bigquery::Dataset
      #
      # === Examples
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #
      #   dataset = bigquery.create_dataset "my_dataset"
      #
      # A name and description can be provided:
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
      # Access rules can be provided with the +access+ option:
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #
      #   dataset = bigquery.create_dataset "my_dataset",
      #     access: [{"role"=>"WRITER", "userByEmail"=>"writers@example.com"}]
      #
      # Or access rules can be configured by using the block syntax:
      # (See Dataset::Access)
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #
      #   dataset = bigquery.create_dataset "my_dataset" do |access|
      #     access.add_writer_user "writers@example.com"
      #   end
      #
      def create_dataset dataset_id, options = {}
        if block_given?
          access_builder = Dataset::Access.new connection.default_access_rules,
                                               "projectId" => project
          yield access_builder
          options[:access] = access_builder.access if access_builder.changed?
        end

        ensure_connection!
        resp = connection.insert_dataset dataset_id, options
        if resp.success?
          Dataset.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      ##
      # Retrieves the list of datasets belonging to the project.
      #
      # === Parameters
      #
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:all]</code>::
      #   Whether to list all datasets, including hidden ones. The default is
      #   +false+. (+Boolean+)
      # <code>options[:token]</code>::
      #   A previously-returned page token representing part of the larger set
      #   of results to view. (+String+)
      # <code>options[:max]</code>::
      #   Maximum number of datasets to return. (+Integer+)
      #
      # === Returns
      #
      # Array of Gcloud::Bigquery::Dataset (Gcloud::Bigquery::Dataset::List)
      #
      # === Examples
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #
      #   datasets = bigquery.datasets
      #   datasets.each do |dataset|
      #     puts dataset.name
      #   end
      #
      # You can also retrieve all datasets, including hidden ones, by providing
      # the +:all+ option:
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #
      #   all_datasets = bigquery.datasets, all: true
      #
      # If you have a significant number of datasets, you may need to paginate
      # through them: (See Dataset::List#token)
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
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
      #
      def datasets options = {}
        ensure_connection!
        resp = connection.list_datasets options
        if resp.success?
          Dataset::List.from_response resp, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Retrieves an existing job by ID.
      #
      # === Parameters
      #
      # +job_id+::
      #   The ID of a job. (+String+)
      #
      # === Returns
      #
      # Gcloud::Bigquery::Job or nil if job does not exist
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #
      #   job = bigquery.job "my_job"
      #
      def job job_id
        ensure_connection!
        resp = connection.get_job job_id
        if resp.success?
          Job.from_gapi resp.data, connection
        else
          return nil if resp.status == 404
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Retrieves the list of jobs belonging to the project.
      #
      # === Parameters
      #
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:all]</code>::
      #   Whether to display jobs owned by all users in the project.
      #   The default is +false+. (+Boolean+)
      # <code>options[:token]</code>::
      #   A previously-returned page token representing part of the larger set
      #   of results to view. (+String+)
      # <code>options[:max]</code>::
      #   Maximum number of jobs to return. (+Integer+)
      # <code>options[:filter]</code>::
      #   A filter for job state. (+String+)
      #
      #   Acceptable values are:
      #   * +done+ - Finished jobs
      #   * +pending+ - Pending jobs
      #   * +running+ - Running jobs
      #
      # === Returns
      #
      # Array of Gcloud::Bigquery::Job (Gcloud::Bigquery::Job::List)
      #
      # === Examples
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #
      #   jobs = bigquery.jobs
      #
      # You can also retrieve only running jobs using the +:filter+ option:
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #
      #   running_jobs = bigquery.jobs filter: "running"
      #
      # If you have a significant number of jobs, you may need to paginate
      # through them: (See Job::List#token)
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #
      #   all_jobs = []
      #   tmp_jobs = bigquery.jobs
      #   while tmp_jobs.any? do
      #     tmp_jobs.each do |job|
      #       all_jobs << job
      #     end
      #     # break loop if no more jobs available
      #     break if tmp_jobs.token.nil?
      #     # get the next group of jobs
      #     tmp_jobs = bigquery.jobs token: tmp_jobs.token
      #   end
      #
      def jobs options = {}
        ensure_connection!
        resp = connection.list_jobs options
        if resp.success?
          Job::List.from_response resp, connection
        else
          fail ApiError.from_response(resp)
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
