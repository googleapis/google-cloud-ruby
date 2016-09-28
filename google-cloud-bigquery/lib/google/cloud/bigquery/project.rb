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


require "google/cloud/core/gce"
require "google/cloud/errors"
require "google/cloud/bigquery/service"
require "google/cloud/bigquery/credentials"
require "google/cloud/bigquery/dataset"
require "google/cloud/bigquery/job"
require "google/cloud/bigquery/query_data"
require "google/cloud/bigquery/project/list"

module Google
  module Cloud
    module Bigquery
      ##
      # # Project
      #
      # Projects are top-level containers in Google Cloud Platform. They store
      # information about billing and authorized users, and they contain
      # BigQuery data. Each project has a friendly name and a unique ID.
      #
      # Google::Cloud::Bigquery::Project is the main object for interacting with
      # Google BigQuery. {Google::Cloud::Bigquery::Dataset} objects are created,
      # accessed, and deleted by Google::Cloud::Bigquery::Project.
      #
      # See {Google::Cloud#bigquery}.
      #
      # @attr_reader [String, nil] name The descriptive name of the project.
      #   Can only be present if the project was retrieved with {#projects}.
      # @attr_reader [Integer, nil] numeric_id The numeric ID of the project.
      #   Can only be present if the project was retrieved with {#projects}.
      #
      # @example
      #   require "google/cloud"
      #
      #   gcloud = Google::Cloud.new
      #   bigquery = gcloud.bigquery
      #   dataset = bigquery.dataset "my_dataset"
      #   table = dataset.table "my_table"
      #
      class Project
        ##
        # @private The Service object.
        attr_accessor :service

        attr_reader :name, :numeric_id

        ##
        # Creates a new Service instance.
        #
        # See {Google::Cloud.bigquery}
        def initialize service
          @service = service
        end

        ##
        # The BigQuery project connected to.
        #
        # @example
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new "my-todo-project",
        #                              "/path/to/keyfile.json"
        #   bigquery = gcloud.bigquery
        #
        #   bigquery.project #=> "my-todo-project"
        #
        def project
          service.project
        end

        ##
        # @private Default project.
        def self.default_project
          ENV["BIGQUERY_PROJECT"] ||
            ENV["GOOGLE_CLOUD_PROJECT"] ||
            ENV["GCLOUD_PROJECT"] ||
            Google::Cloud::Core::GCE.project_id
        end

        ##
        # Queries data using the [asynchronous
        # method](https://cloud.google.com/bigquery/querying-data).
        #
        # @param [String] query A query string, following the BigQuery [query
        #   syntax](https://cloud.google.com/bigquery/query-reference), of the
        #   query to execute. Example: "SELECT count(f1) FROM
        #   [myProjectId:myDatasetId.myTableId]".
        # @param [String] priority Specifies a priority for the query. Possible
        #   values include `INTERACTIVE` and `BATCH`. The default value is
        #   `INTERACTIVE`.
        # @param [Boolean] cache Whether to look for the result in the query
        #   cache. The query cache is a best-effort cache that will be flushed
        #   whenever tables in the query are modified. The default value is
        #   true. For more information, see [query
        #   caching](https://developers.google.com/bigquery/querying-data).
        # @param [Table] table The destination table where the query results
        #   should be stored. If not present, a new table will be created to
        #   store the results.
        # @param [String] create Specifies whether the job is allowed to create
        #   new tables.
        #
        #   The following values are supported:
        #
        #   * `needed` - Create the table if it does not exist.
        #   * `never` - The table must already exist. A 'notFound' error is
        #     raised if the table does not exist.
        # @param [String] write Specifies the action that occurs if the
        #   destination table already exists.
        #
        #   The following values are supported:
        #
        #   * `truncate` - BigQuery overwrites the table data.
        #   * `append` - BigQuery appends the data to the table.
        #   * `empty` - A 'duplicate' error is returned in the job result if the
        #     table exists and contains data.
        # @param [Boolean] large_results If `true`, allows the query to produce
        #   arbitrarily large result tables at a slight cost in performance.
        #   Requires `table` parameter to be set.
        # @param [Boolean] flatten Flattens all nested and repeated fields in
        #   the query results. The default value is `true`. `large_results`
        #   parameter must be `true` if this is set to `false`.
        # @param [Dataset, String] dataset Specifies the default dataset to use
        #   for unqualified table names in the query.
        #
        # @return [Google::Cloud::Bigquery::QueryJob]
        #
        # @example
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   bigquery = gcloud.bigquery
        #
        #   job = bigquery.query_job "SELECT name FROM " \
        #                            "[my_proj:my_data.my_table]"
        #
        #   job.wait_until_done!
        #   if !job.failed?
        #     job.query_results.each do |row|
        #       puts row["name"]
        #     end
        #   end
        #
        def query_job query, priority: "INTERACTIVE", cache: true, table: nil,
                      create: nil, write: nil, large_results: nil, flatten: nil,
                      dataset: nil
          ensure_service!
          options = { priority: priority, cache: cache, table: table,
                      create: create, write: write,
                      large_results: large_results, flatten: flatten,
                      dataset: dataset }
          gapi = service.query_job query, options
          Job.from_gapi gapi, service
        end

        ##
        # Queries data using the [synchronous
        # method](https://cloud.google.com/bigquery/querying-data).
        #
        # @param [String] query A query string, following the BigQuery [query
        #   syntax](https://cloud.google.com/bigquery/query-reference), of the
        #   query to execute. Example: "SELECT count(f1) FROM
        #   [myProjectId:myDatasetId.myTableId]".
        # @param [Integer] max The maximum number of rows of data to return per
        #   page of results. Setting this flag to a small value such as 1000 and
        #   then paging through results might improve reliability when the query
        #   result set is large. In addition to this limit, responses are also
        #   limited to 10 MB. By default, there is no maximum row count, and
        #   only the byte limit applies.
        # @param [Integer] timeout How long to wait for the query to complete,
        #   in milliseconds, before the request times out and returns. Note that
        #   this is only a timeout for the request, not the query. If the query
        #   takes longer to run than the timeout value, the call returns without
        #   any results and with QueryData#complete? set to false. The default
        #   value is 10000 milliseconds (10 seconds).
        # @param [Boolean] dryrun If set to `true`, BigQuery doesn't run the
        #   job. Instead, if the query is valid, BigQuery returns statistics
        #   about the job such as how many bytes would be processed. If the
        #   query is invalid, an error returns. The default value is `false`.
        # @param [Boolean] cache Whether to look for the result in the query
        #   cache. The query cache is a best-effort cache that will be flushed
        #   whenever tables in the query are modified. The default value is
        #   true. For more information, see [query
        #   caching](https://developers.google.com/bigquery/querying-data).
        # @param [String] dataset Specifies the default datasetId and projectId
        #   to assume for any unqualified table names in the query. If not set,
        #   all table names in the query string must be qualified in the format
        #   'datasetId.tableId'.
        # @param [String] project Specifies the default projectId to assume for
        #   any unqualified table names in the query. Only used if `dataset`
        #   option is set.
        #
        # @return [Google::Cloud::Bigquery::QueryData]
        #
        # @example
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   bigquery = gcloud.bigquery
        #
        #   data = bigquery.query "SELECT name FROM [my_proj:my_data.my_table]"
        #   data.each do |row|
        #     puts row["name"]
        #   end
        #
        # @example Retrieve all rows: (See {QueryData#all})
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   bigquery = gcloud.bigquery
        #
        #   data = bigquery.query "SELECT name FROM [my_proj:my_data.my_table]"
        #   data.all do |row|
        #     puts row["name"]
        #   end
        #
        def query query, max: nil, timeout: 10000, dryrun: nil, cache: true,
                  dataset: nil, project: nil
          ensure_service!
          options = { max: max, timeout: timeout, dryrun: dryrun, cache: cache,
                      dataset: dataset, project: project }
          gapi = service.query query, options
          QueryData.from_gapi gapi, service
        end

        ##
        # Retrieves an existing dataset by ID.
        #
        # @param [String] dataset_id The ID of a dataset.
        #
        # @return [Google::Cloud::Bigquery::Dataset, nil] Returns `nil` if the
        #   dataset does not exist.
        #
        # @example
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   bigquery = gcloud.bigquery
        #
        #   dataset = bigquery.dataset "my_dataset"
        #   puts dataset.name
        #
        def dataset dataset_id
          ensure_service!
          gapi = service.get_dataset dataset_id
          Dataset.from_gapi gapi, service
        rescue Google::Cloud::NotFoundError
          nil
        end

        ##
        # Creates a new dataset.
        #
        # @param [String] dataset_id A unique ID for this dataset, without the
        #   project name. The ID must contain only letters (a-z, A-Z), numbers
        #   (0-9), or underscores (_). The maximum length is 1,024 characters.
        # @param [String] name A descriptive name for the dataset.
        # @param [String] description A user-friendly description of the
        #   dataset.
        # @param [Integer] expiration The default lifetime of all tables in the
        #   dataset, in milliseconds. The minimum value is 3600000 milliseconds
        #   (one hour).
        # @param [String] location The geographic location where the dataset
        #   should reside. Possible values include `EU` and `US`. The default
        #   value is `US`.
        # @yield [access] a block for setting rules
        # @yieldparam [Dataset::Access] access the object accepting rules
        #
        # @return [Google::Cloud::Bigquery::Dataset]
        #
        # @example
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   bigquery = gcloud.bigquery
        #
        #   dataset = bigquery.create_dataset "my_dataset"
        #
        # @example A name and description can be provided:
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   bigquery = gcloud.bigquery
        #
        #   dataset = bigquery.create_dataset "my_dataset",
        #                                     name: "My Dataset",
        #                                     description: "This is my Dataset"
        #
        # @example Access rules can be provided with the `access` option:
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   bigquery = gcloud.bigquery
        #
        #   dataset = bigquery.create_dataset "my_dataset",
        #     access: [{"role"=>"WRITER", "userByEmail"=>"writers@example.com"}]
        #
        # @example Or, configure access with a block: (See {Dataset::Access})
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   bigquery = gcloud.bigquery
        #
        #   dataset = bigquery.create_dataset "my_dataset" do |access|
        #     access.add_writer_user "writers@example.com"
        #   end
        #
        def create_dataset dataset_id, name: nil, description: nil,
                           expiration: nil, location: nil
          ensure_service!

          new_ds = Google::Apis::BigqueryV2::Dataset.new(
            dataset_reference: Google::Apis::BigqueryV2::DatasetReference.new(
              project_id: project, dataset_id: dataset_id))

          # Can set location only on creation, no Dataset#location method
          new_ds.update! location: location unless location.nil?

          updater = Dataset::Updater.new(new_ds).tap do |b|
            b.name = name unless name.nil?
            b.description = description unless description.nil?
            b.default_expiration = expiration unless expiration.nil?
          end

          if block_given?
            yield updater
            updater.check_for_mutated_access!
          end

          gapi = service.insert_dataset new_ds
          Dataset.from_gapi gapi, service
        end

        ##
        # Retrieves the list of datasets belonging to the project.
        #
        # @param [Boolean] all Whether to list all datasets, including hidden
        #   ones. The default is `false`.
        # @param [String] token A previously-returned page token representing
        #   part of the larger set of results to view.
        # @param [Integer] max Maximum number of datasets to return.
        #
        # @return [Array<Google::Cloud::Bigquery::Dataset>] (See
        #   {Google::Cloud::Bigquery::Dataset::List})
        #
        # @example
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   bigquery = gcloud.bigquery
        #
        #   datasets = bigquery.datasets
        #   datasets.each do |dataset|
        #     puts dataset.name
        #   end
        #
        # @example Retrieve hidden datasets with the `all` optional arg:
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   bigquery = gcloud.bigquery
        #
        #   all_datasets = bigquery.datasets all: true
        #
        # @example Retrieve all datasets: (See {Dataset::List#all})
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   bigquery = gcloud.bigquery
        #
        #   datasets = bigquery.datasets
        #   datasets.all do |dataset|
        #     puts dataset.name
        #   end
        #
        def datasets all: nil, token: nil, max: nil
          ensure_service!
          options = { all: all, token: token, max: max }
          gapi = service.list_datasets options
          Dataset::List.from_gapi gapi, service, all, max
        end

        ##
        # Retrieves an existing job by ID.
        #
        # @param [String] job_id The ID of a job.
        #
        # @return [Google::Cloud::Bigquery::Job, nil] Returns `nil` if the job
        #   does not exist.
        #
        # @example
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   bigquery = gcloud.bigquery
        #
        #   job = bigquery.job "my_job"
        #
        def job job_id
          ensure_service!
          gapi = service.get_job job_id
          Job.from_gapi gapi, service
        rescue Google::Cloud::NotFoundError
          nil
        end

        ##
        # Retrieves the list of jobs belonging to the project.
        #
        # @param [Boolean] all Whether to display jobs owned by all users in the
        #   project. The default is `false`.
        # @param [String] token A previously-returned page token representing
        #   part of the larger set of results to view.
        # @param [Integer] max Maximum number of jobs to return.
        # @param [String] filter A filter for job state.
        #
        #   Acceptable values are:
        #
        #   * `done` - Finished jobs
        #   * `pending` - Pending jobs
        #   * `running` - Running jobs
        #
        # @return [Array<Google::Cloud::Bigquery::Job>] (See
        #   {Google::Cloud::Bigquery::Job::List})
        #
        # @example
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   bigquery = gcloud.bigquery
        #
        #   jobs = bigquery.jobs
        #   jobs.each do |job|
        #     # process job
        #   end
        #
        # @example Retrieve only running jobs using the `filter` optional arg:
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   bigquery = gcloud.bigquery
        #
        #   running_jobs = bigquery.jobs filter: "running"
        #   running_jobs.each do |job|
        #     # process job
        #   end
        #
        # @example Retrieve all jobs: (See {Job::List#all})
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   bigquery = gcloud.bigquery
        #
        #   jobs = bigquery.jobs
        #   jobs.all do |job|
        #     # process job
        #   end
        #
        def jobs all: nil, token: nil, max: nil, filter: nil
          ensure_service!
          options = { all: all, token: token, max: max, filter: filter }
          gapi = service.list_jobs options
          Job::List.from_gapi gapi, service, all, max, filter
        end

        ##
        # Retrieves the list of all projects for which the currently authorized
        # account has been granted any project role. The returned project
        # instances share the same credentials as the project used to retrieve
        # them, but lazily create a new API connection for interactions with the
        # BigQuery service.
        #
        # @param [String] token A previously-returned page token representing
        #   part of the larger set of results to view.
        # @param [Integer] max Maximum number of projects to return.
        #
        # @return [Array<Google::Cloud::Bigquery::Project>] (See
        #   {Google::Cloud::Bigquery::Project::List})
        #
        # @example
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   bigquery = gcloud.bigquery
        #
        #   projects = bigquery.projects
        #   projects.each do |project|
        #     puts project.name
        #     project.datasets.all.each do |dataset|
        #       puts dataset.name
        #     end
        #   end
        #
        # @example Retrieve all projects: (See {Project::List#all})
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   bigquery = gcloud.bigquery
        #
        #   projects = bigquery.projects
        #
        #   projects.all do |project|
        #     puts project.name
        #     project.datasets.all.each do |dataset|
        #       puts dataset.name
        #     end
        #   end
        #
        def projects token: nil, max: nil
          ensure_service!
          options = { token: token, max: max }
          gapi = service.list_projects options
          Project::List.from_gapi gapi, service, max
        end

        ##
        # @private New Project from a Google API Client object, using the
        # same Credentials as this project.
        def self.from_gapi gapi, service
          project_service = Service.new gapi.project_reference.project_id,
                                        service.credentials,
                                        retries: service.retries,
                                        timeout: service.timeout
          new(project_service).tap do |p|
            p.instance_variable_set :@name, gapi.friendly_name

            # TODO: remove `Integer` and set normally after migrating to Gax or
            # to google-api-client 0.10 (See google/google-api-ruby-client#439)
            if gapi.numeric_id
              p.instance_variable_set :@numeric_id, Integer(gapi.numeric_id)
            end
          end
        end

        protected

        ##
        # Raise an error unless an active service is available.
        def ensure_service!
          fail "Must have active connection" unless service
        end
      end
    end
  end
end
