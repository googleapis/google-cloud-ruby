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
      # Opaque ID field of the job.
      def id
        @gapi["id"]
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
        state == "running"
      end

      ##
      # Checks if the job's status is "pending".
      def pending?
        state == "pending"
      end

      ##
      # Checks if the job's status is "done".
      def done?
        state == "done"
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

      ##
      # Refreshes the job with current data from the BigQuery service.
      def refresh!
        ensure_connection!
        resp = connection.get_job id
        if resp.success?
          @gapi = resp.data
        else
          ApiError.from_response(resp)
        end
      end

      ##
      # New Job from a Google API Client object.
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
