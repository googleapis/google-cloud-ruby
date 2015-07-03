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
    # used, and deleted by Gcloud::Bigquery::Project.
    #
    #   require "glcoud/bigquery"
    #
    #   bigquery = Gcloud.bigquery
    #   dataset = bigquery.dataset "my-dataset"
    #   table = dataset.table "my-table"
    #
    # See Gcloud.bigquery
    class Project
      ##
      # The Connection object.
      attr_accessor :connection #:nodoc:

      ##
      # Creates a new Connection instance.
      #
      # See Gcloud.bigquery
      def initialize project, credentials
        @connection = Connection.new project, credentials
      end

      ##
      # The BigQuery project connected to.
      #
      # === Example
      #
      #   require "glcoud/bigquery"
      #
      #   bigquery = Gcloud.bigquery "my-todo-project",
      #                              "/path/to/keyfile.json"
      #
      #   bigquery.project #=> "my-todo-project"
      #
      def project
        connection.project
      end

      ##
      # Default project.
      def self.default_project #:nodoc:
        ENV["PUBSUB_PROJECT"] || ENV["GOOGLE_CLOUD_PROJECT"]
      end

      ##
      # Retrieves dataset by name.
      #
      # === Parameters
      #
      # +dataset_name+::
      #   Name of a dataset. (+String+)
      #
      # === Returns
      #
      # Gcloud::Bigquery::Dataset or nil if dataset does not exist
      #
      # === Example
      #
      #   require "gcloud/bigquery"
      #
      #   bigquery = Gcloud.bigquery
      #
      #   dataset = bigquery.dataset "my-dataset"
      #   puts dataset.name
      #
      def dataset dataset_name
        ensure_connection!
        resp = connection.get_dataset dataset_name
        if resp.success?
          Dataset.from_gapi resp.data, connection
        else
          return nil if resp.data["error"]["code"] == 404
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Creates a new dataset.
      #
      # === Parameters
      #
      # +options+::
      #   An optional Hash for controlling additional behavor. (+Hash+)
      # <code>options[:name]</code>::
      #   A descriptive name for the dataset. (+String+)
      # <code>options[:description]</code>::
      #   A user-friendly description of the dataset. (+String+)
      # <code>options[:retries]</code>::
      #   The default lifetime of all tables in the dataset, in milliseconds.
      #   The minimum value is 3600000 milliseconds (one hour). (+Integer+)
      #
      # === Returns
      #
      # Gcloud::Bigquery::Dataset
      #
      # === Examples
      #
      #   require "gcloud/bigquery"
      #
      #   bigquery = Gcloud.bigquery
      #
      #   dataset = bigquery.create_dataset
      #
      # A name and description can be provided:
      #
      #   require "gcloud/bigquery"
      #
      #   bigquery = Gcloud.bigquery
      #
      #   dataset = bigquery.create_dataset name: "my-dataset",
      #                                     description: "My Dataset"
      #
      def create_dataset options = {}
        ensure_connection!
        resp = connection.insert_dataset options
        if resp.success?
          Dataset.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Retrieves a list of datasets for the given project.
      #
      # === Parameters
      #
      # +options+::
      #   An optional Hash for controlling additional behavor. (+Hash+)
      # <code>options[:all]</code>::
      #   Whether to list all datasets, including hidden ones.
      #   (+Boolean+)
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
      #
      def datasets options = {}
        ensure_connection!
        resp = connection.list_datasets options
        if resp.success?
          Dataset::List.from_resp resp, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Retrieves job by ID.
      #
      # === Parameters
      #
      # +job_id+::
      #   Job ID of the requested job. (+String+)
      #
      # === Returns
      #
      # Gcloud::Bigquery::Job or nil if job does not exist
      #
      # === Example
      #
      #   require "gcloud/bigquery"
      #
      #   bigquery = Gcloud.bigquery
      #
      #   job = bigquery.job "existing-job"
      #
      def job job_id
        ensure_connection!
        resp = connection.get_job job_id
        if resp.success?
          Job.from_gapi resp.data, connection
        else
          return nil if resp.data["error"]["code"] == 404
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Retrieves a list of jobs for the given project.
      #
      # === Parameters
      #
      # +options+::
      #   An optional Hash for controlling additional behavor. (+Hash+)
      # <code>options[:all]</code>::
      #   Whether to display jobs owned by all users in the project.
      #   Default is false. (+Boolean+)
      # <code>options[:token]</code>::
      #   A previously-returned page token representing part of the larger set
      #   of results to view. (+String+)
      # <code>options[:max]</code>::
      #   Maximum number of jobs to return. (+Integer+)
      # <code>options[:projection]</code>::
      #   Restrict information returned to a set of selected fields (+String+)
      #
      #   Acceptable values are:
      #   * +full+ - Includes all job data.
      #   * +minimal+ - Does not include the job configuration.
      # <code>options[:filter]</code>::
      #   Filter for job state (+String+)
      #
      #   Acceptable values are:
      #   * +done+ - Finished jobs.
      #   * +pending+ - Pending jobs.
      #   * +running+ - Running jobs.
      #
      # === Returns
      #
      # Array of Gcloud::Bigquery::Job (Gcloud::Bigquery::Job::List)
      #
      # === Examples
      #
      #   require "gcloud/bigquery"
      #
      #   bigquery = Gcloud.bigquery
      #
      #   jobs = bigquery.jobs
      #
      # You can also retrieve all running jobs using the +:filter+ option:
      #
      #   require "gcloud/bigquery"
      #
      #   bigquery = Gcloud.bigquery
      #
      #   running_jobs = bigquery.jobs filter: "running"
      #
      # If you have a significant number of jobs, you may need to paginate
      # through them: (See Job::List#token)
      #
      #   require "gcloud/bigquery"
      #
      #   bigquery = Gcloud.bigquery
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
          Job::List.from_resp resp, connection
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
