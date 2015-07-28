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
    # Represents a Job.
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
      # The ID must contain only letters (a-z, A-Z), numbers (0-9), underscores
      # (_), or dashes (-). The maximum length is 1,024 characters.
      def job_id
        @gapi["jobReference"]["jobId"]
      end

      ##
      # The ID of the project containing this job.
      def project_id
        @gapi["jobReference"]["projectId"]
      end

      ##
      # Running state of the job.
      def state
        return nil if @gapi["status"].nil?
        @gapi["status"]["state"]
      end

      ##
      # Checks if the job's status is "running".
      def running?
        return false if state.nil?
        "running".casecmp(state).zero?
      end

      ##
      # Checks if the job's status is "pending".
      def pending?
        return false if state.nil?
        "pending".casecmp(state).zero?
      end

      ##
      # Checks if the job's status is "done".
      def done?
        return false if state.nil?
        "done".casecmp(state).zero?
      end

      ##
      # The time when this job was created.
      def created_at
        return nil if @gapi["statistics"].nil?
        return nil if @gapi["statistics"]["creationTime"].nil?
        Time.at(@gapi["statistics"]["creationTime"] / 1000.0)
      end

      ##
      # The time when this job was started.
      # This field will be present when the job transitions from the PENDING
      # state to either RUNNING or DONE.
      def started_at
        return nil if @gapi["statistics"].nil?
        return nil if @gapi["statistics"]["startTime"].nil?
        Time.at(@gapi["statistics"]["startTime"] / 1000.0)
      end

      ##
      # The time when this job ended.
      # This field will be present whenever a job is in the DONE state.
      def ended_at
        return nil if @gapi["statistics"].nil?
        return nil if @gapi["statistics"]["endTime"].nil?
        Time.at(@gapi["statistics"]["endTime"] / 1000.0)
      end

      def config
        @gapi["configuration"] || {}
      end

      ##
      # Refreshes the job with current data from the BigQuery service.
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
