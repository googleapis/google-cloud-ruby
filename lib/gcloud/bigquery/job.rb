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

require "gcloud/bigquery/query_data"
require "gcloud/bigquery/job/list"
require "gcloud/bigquery/errors"

module Gcloud
  module Bigquery
    ##
    # = Job
    #
    # Represents a generic Job that may be performed on a Table.
    #
    # See {Managing Jobs, Datasets, and Projects
    # }[https://cloud.google.com/bigquery/docs/managing_jobs_datasets_projects]
    # for an overview of BigQuery jobs, and the {Jobs API
    # reference}[https://cloud.google.com/bigquery/docs/reference/v2/jobs]
    # for details.
    #
    # The subclasses of Job represent the specific BigQuery job types: CopyJob,
    # ExtractJob, LoadJob, and QueryJob.
    #
    # A job instance is created when you call Project#query_job,
    # Dataset#query_job, Table#copy, Table#extract, Table#load, or View#data.
    #
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   bigquery = gcloud.bigquery
    #
    #   q = "SELECT COUNT(word) as count FROM publicdata:samples.shakespeare"
    #   job = bigquery.query_job q
    #
    #   loop do
    #     break if job.done?
    #     sleep 1
    #     job.refresh!
    #   end
    #
    #   if job.failed?
    #     puts job.error
    #   else
    #     puts job.query_results.first
    #   end
    #
    class Job
      ##
      # The Connection object.
      attr_accessor :connection #:nodoc:

      ##
      # The Google API Client object.
      attr_accessor :gapi #:nodoc:

      ##
      # Create an empty Job object.
      def initialize #:nodoc:
        @connection = nil
        @gapi = {}
      end

      ##
      # The ID of the job.
      def job_id
        @gapi["jobReference"]["jobId"]
      end

      ##
      # The ID of the project containing the job.
      def project_id
        @gapi["jobReference"]["projectId"]
      end

      ##
      # The current state of the job. The possible values are +PENDING+,
      # +RUNNING+, and +DONE+. A +DONE+ state does not mean that the job
      # completed successfully. Use #failed? to discover if an error occurred
      # or if the job was successful.
      def state
        return nil if @gapi["status"].nil?
        @gapi["status"]["state"]
      end

      ##
      # Checks if the job's state is +RUNNING+.
      def running?
        return false if state.nil?
        "running".casecmp(state).zero?
      end

      ##
      # Checks if the job's state is +PENDING+.
      def pending?
        return false if state.nil?
        "pending".casecmp(state).zero?
      end

      ##
      # Checks if the job's state is +DONE+. When +true+, the job has stopped
      # running. However, a +DONE+ state does not mean that the job completed
      # successfully.  Use #failed? to detect if an error occurred or if the
      # job was successful.
      def done?
        return false if state.nil?
        "done".casecmp(state).zero?
      end

      ##
      # Checks if an error is present.
      def failed?
        !error.nil?
      end

      ##
      # The time when the job was created.
      def created_at
        return nil if @gapi["statistics"].nil?
        return nil if @gapi["statistics"]["creationTime"].nil?
        Time.at(@gapi["statistics"]["creationTime"] / 1000.0)
      end

      ##
      # The time when the job was started.
      # This field is present after the job's state changes from +PENDING+
      # to either +RUNNING+ or +DONE+.
      def started_at
        return nil if @gapi["statistics"].nil?
        return nil if @gapi["statistics"]["startTime"].nil?
        Time.at(@gapi["statistics"]["startTime"] / 1000.0)
      end

      ##
      # The time when the job ended.
      # This field is present when the job's state is +DONE+.
      def ended_at
        return nil if @gapi["statistics"].nil?
        return nil if @gapi["statistics"]["endTime"].nil?
        Time.at(@gapi["statistics"]["endTime"] / 1000.0)
      end

      ##
      # The configuration for the job. Returns a hash. See the {Jobs API
      # reference}[https://cloud.google.com/bigquery/docs/reference/v2/jobs].
      def configuration
        hash = @gapi["configuration"] || {}
        hash = hash.to_hash if hash.respond_to? :to_hash
        hash
      end
      alias_method :config, :configuration

      ##
      # The statistics for the job. Returns a hash. See the {Jobs API
      # reference}[https://cloud.google.com/bigquery/docs/reference/v2/jobs].
      def statistics
        hash = @gapi["statistics"] || {}
        hash = hash.to_hash if hash.respond_to? :to_hash
        hash
      end
      alias_method :stats, :statistics

      ##
      # The job's status. Returns a hash. The values contained in the hash are
      # also exposed by #state, #error, and #errors.
      def status
        hash = @gapi["status"] || {}
        hash = hash.to_hash if hash.respond_to? :to_hash
        hash
      end

      ##
      # The last error for the job, if any errors have occurred. Returns a
      # hash. See the {Jobs API
      # reference}[https://cloud.google.com/bigquery/docs/reference/v2/jobs].
      #
      # === Returns
      #
      # +Hash+
      #
      #   {
      #     "reason"=>"notFound",
      #     "message"=>"Not found: Table publicdata:samples.BAD_ID"
      #   }
      #
      def error
        status["errorResult"]
      end

      ##
      # The errors for the job, if any errors have occurred. Returns an array
      # of hash objects. See #error.
      def errors
        Array status["errors"]
      end

      ##
      # Created a new job with the current configuration.
      def rerun!
        ensure_connection!
        resp = connection.insert_job configuration
        if resp.success?
          Job.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Reloads the job with current data from the BigQuery service.
      def refresh!
        ensure_connection!
        resp = connection.get_job job_id
        if resp.success?
          @gapi = resp.data
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # New Job from a Google API Client object.
      def self.from_gapi gapi, conn #:nodoc:
        klass = klass_for gapi
        klass.new.tap do |f|
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

      ##
      # Get the subclass for a job type
      def self.klass_for gapi
        if gapi["configuration"]["copy"]
          return CopyJob
        elsif gapi["configuration"]["extract"]
          return ExtractJob
        elsif gapi["configuration"]["load"]
          return LoadJob
        elsif gapi["configuration"]["query"]
          return QueryJob
        end
        Job
      end

      def retrieve_table project_id, dataset_id, table_id
        ensure_connection!
        resp = connection.get_project_table project_id, dataset_id, table_id
        if resp.success?
          Table.from_gapi resp.data, connection
        else
          return nil if resp.status == 404
          fail ApiError.from_response(resp)
        end
      end
    end
  end
end

# We need Job to be defined before loading these.
require "gcloud/bigquery/copy_job"
require "gcloud/bigquery/extract_job"
require "gcloud/bigquery/load_job"
require "gcloud/bigquery/query_job"
