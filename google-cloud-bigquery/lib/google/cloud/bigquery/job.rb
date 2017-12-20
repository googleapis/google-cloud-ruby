# Copyright 2015 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require "google/cloud/errors"
require "google/cloud/bigquery/service"
require "google/cloud/bigquery/job/list"
require "json"

module Google
  module Cloud
    module BigQuery
      ##
      # # Job
      #
      # Represents a generic Job that may be performed on a {Table}.
      #
      # The subclasses of Job represent the specific BigQuery job types:
      # {CopyJob}, {ExtractJob}, {LoadJob}, and {QueryJob}.
      #
      # A job instance is created when you call {Project#query_job},
      # {Dataset#query_job}, {Table#copy_job}, {Table#extract_job},
      # {Table#load_job}.
      #
      # @see https://cloud.google.com/bigquery/docs/managing-jobs Running and
      #   Managing Jobs
      # @see https://cloud.google.com/bigquery/docs/reference/v2/jobs Jobs API
      #   reference
      #
      # @example
      #   require "google/cloud/bigquery"
      #
      #   bigquery = Google::Cloud::BigQuery.new
      #
      #   job = bigquery.query_job "SELECT COUNT(word) as count FROM " \
      #                            "publicdata.samples.shakespeare"
      #
      #   job.wait_until_done!
      #
      #   if job.failed?
      #     puts job.error
      #   else
      #     puts job.data.first
      #   end
      #
      class Job
        ##
        # @private The Service object.
        attr_accessor :service

        ##
        # @private The Google API Client object.
        attr_accessor :gapi

        ##
        # @private Create an empty Job object.
        def initialize
          @service = nil
          @gapi = {}
        end

        ##
        # The ID of the job.
        #
        # @return [String] The ID must contain only letters (a-z, A-Z), numbers
        #   (0-9), underscores (_), or dashes (-). The maximum length is 1,024
        #   characters.
        #
        def job_id
          @gapi.job_reference.job_id
        end

        ##
        # The ID of the project containing the job.
        #
        # @return [String] The project ID.
        #
        def project_id
          @gapi.job_reference.project_id
        end

        ##
        # The email address of the user who ran the job.
        #
        # @return [String] The email address.
        #
        def user_email
          @gapi.user_email
        end

        ##
        # The current state of the job. A `DONE` state does not mean that the
        # job completed successfully. Use {#failed?} to discover if an error
        # occurred or if the job was successful.
        #
        # @return [String] The state code. The possible values are `PENDING`,
        #   `RUNNING`, and `DONE`.
        #
        def state
          return nil if @gapi.status.nil?
          @gapi.status.state
        end

        ##
        # Checks if the job's state is `RUNNING`.
        #
        # @return [Boolean] `true` when `RUNNING`, `false` otherwise.
        #
        def running?
          return false if state.nil?
          "running".casecmp(state).zero?
        end

        ##
        # Checks if the job's state is `PENDING`.
        #
        # @return [Boolean] `true` when `PENDING`, `false` otherwise.
        #
        def pending?
          return false if state.nil?
          "pending".casecmp(state).zero?
        end

        ##
        # Checks if the job's state is `DONE`. When `true`, the job has stopped
        # running. However, a `DONE` state does not mean that the job completed
        # successfully.  Use {#failed?} to detect if an error occurred or if the
        # job was successful.
        #
        # @return [Boolean] `true` when `DONE`, `false` otherwise.
        #
        def done?
          return false if state.nil?
          "done".casecmp(state).zero?
        end

        ##
        # Checks if an error is present. Use {#error} to access the error
        # object.
        #
        # @return [Boolean] `true` when there is an error, `false` otherwise.
        #
        def failed?
          !error.nil?
        end

        ##
        # The time when the job was created.
        #
        # @return [Time, nil] The creation time from the job statistics.
        #
        def created_at
          ::Time.at(Integer(@gapi.statistics.creation_time) / 1000.0)
        rescue
          nil
        end

        ##
        # The time when the job was started.
        # This field is present after the job's state changes from `PENDING`
        # to either `RUNNING` or `DONE`.
        #
        # @return [Time, nil] The start time from the job statistics.
        #
        def started_at
          ::Time.at(Integer(@gapi.statistics.start_time) / 1000.0)
        rescue
          nil
        end

        ##
        # The time when the job ended.
        # This field is present when the job's state is `DONE`.
        #
        # @return [Time, nil] The end time from the job statistics.
        #
        def ended_at
          ::Time.at(Integer(@gapi.statistics.end_time) / 1000.0)
        rescue
          nil
        end

        ##
        # The configuration for the job. Returns a hash.
        #
        # @see https://cloud.google.com/bigquery/docs/reference/v2/jobs Jobs API
        #   reference
        def configuration
          JSON.parse @gapi.configuration.to_json
        end
        alias_method :config, :configuration

        ##
        # The statistics for the job. Returns a hash.
        #
        # @see https://cloud.google.com/bigquery/docs/reference/v2/jobs Jobs API
        #   reference
        #
        # @return [Hash] The job statistics.
        #
        def statistics
          JSON.parse @gapi.statistics.to_json
        end
        alias_method :stats, :statistics

        ##
        # The job's status. Returns a hash. The values contained in the hash are
        # also exposed by {#state}, {#error}, and {#errors}.
        #
        # @return [Hash] The job status.
        #
        def status
          JSON.parse @gapi.status.to_json
        end

        ##
        # The last error for the job, if any errors have occurred. Returns a
        # hash.
        #
        # @see https://cloud.google.com/bigquery/docs/reference/v2/jobs Jobs API
        #   reference
        #
        # @return [Hash, nil] Returns a hash containing `reason` and `message`
        #   keys:
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
        # of hash objects. See {#error}.
        #
        # @return [Array<Hash>, nil] Returns an array of hashes containing
        #   `reason` and `message` keys:
        #
        #   {
        #     "reason"=>"notFound",
        #     "message"=>"Not found: Table publicdata:samples.BAD_ID"
        #   }
        #
        def errors
          Array status["errors"]
        end

        ##
        # A hash of user-provided labels associated with this job. Labels can be
        # provided when the job is created, and used to organize and group jobs.
        #
        # The returned hash is frozen and changes are not allowed. Use
        # {#labels=} to replace the entire hash.
        #
        # @return [Hash] The job labels.
        #
        # @!group Attributes
        #
        def labels
          m = @gapi.configuration.labels
          m = m.to_h if m.respond_to? :to_h
          m.dup.freeze
        end

        ##
        # Cancels the job.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::BigQuery.new
        #
        #   job = bigquery.query_job "SELECT COUNT(word) as count FROM " \
        #                            "publicdata.samples.shakespeare"
        #
        #   job.cancel
        #
        def cancel
          ensure_service!
          resp = service.cancel_job job_id
          @gapi = resp.job
          true
        end

        ##
        # Created a new job with the current configuration.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::BigQuery.new
        #
        #   job = bigquery.query_job "SELECT COUNT(word) as count FROM " \
        #                            "publicdata.samples.shakespeare"
        #
        #   job.wait_until_done!
        #   job.rerun!
        #
        def rerun!
          ensure_service!
          gapi = service.insert_job @gapi.configuration
          Job.from_gapi gapi, service
        end

        ##
        # Reloads the job with current data from the BigQuery service.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::BigQuery.new
        #
        #   job = bigquery.query_job "SELECT COUNT(word) as count FROM " \
        #                            "publicdata.samples.shakespeare"
        #
        #   job.done?
        #   job.reload!
        #   job.done? #=> true
        #
        def reload!
          ensure_service!
          gapi = service.get_job job_id
          @gapi = gapi
        end
        alias_method :refresh!, :reload!

        ##
        # Refreshes the job until the job is `DONE`. The delay between refreshes
        # starts at 5 seconds and increases exponentially to a maximum of 60
        # seconds.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::BigQuery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.table "my_table"
        #
        #   extract_job = table.extract_job "gs://my-bucket/file-name.json",
        #                                   format: "json"
        #   extract_job.wait_until_done!
        #   extract_job.done? #=> true
        #
        def wait_until_done!
          backoff = lambda do |retries|
            delay = [retries ** 2 + 5, 60].min # Maximum delay is 60
            sleep delay
          end
          retries = 0
          until done?
            backoff.call retries
            retries += 1
            reload!
          end
        end

        ##
        # @private New Job from a Google API Client object.
        def self.from_gapi gapi, conn
          klass = klass_for gapi
          klass.new.tap do |f|
            f.gapi = gapi
            f.service = conn
          end
        end

        ##
        # @private New Google::Apis::Error with job failure details
        def gapi_error
          return nil unless failed?

          error_status_code = status_code_for_reason error["reason"]
          error_body = error
          error_body["errors"] = errors

          Google::Apis::Error.new error["message"],
                                  status_code: error_status_code,
                                  body: error_body
        end

        protected

        ##
        # Raise an error unless an active connection is available.
        def ensure_service!
          fail "Must have active connection" unless service
        end

        ##
        # Get the subclass for a job type
        def self.klass_for gapi
          if gapi.configuration.copy
            return CopyJob
          elsif gapi.configuration.extract
            return ExtractJob
          elsif gapi.configuration.load
            return LoadJob
          elsif gapi.configuration.query
            return QueryJob
          end
          Job
        end

        def retrieve_table project_id, dataset_id, table_id
          ensure_service!
          gapi = service.get_project_table project_id, dataset_id, table_id
          Table.from_gapi gapi, service
        rescue Google::Cloud::NotFoundError
          nil
        end

        def status_code_for_reason reason
          codes = { "accessDenied" => 403, "backendError" => 500,
                    "billingNotEnabled" => 403,
                    "billingTierLimitExceeded" => 400, "blocked" => 403,
                    "duplicate" => 409, "internalError" =>500, "invalid" => 400,
                    "invalidQuery" => 400, "notFound" =>404,
                    "notImplemented" => 501, "quotaExceeded" => 403,
                    "rateLimitExceeded" => 403, "resourceInUse" => 400,
                    "resourcesExceeded" => 400, "responseTooLarge" => 403,
                    "tableUnavailable" => 400 }
          codes[reason] || 0
        end
      end
    end
  end
end

# We need Job to be defined before loading these.
require "google/cloud/bigquery/copy_job"
require "google/cloud/bigquery/extract_job"
require "google/cloud/bigquery/load_job"
require "google/cloud/bigquery/query_job"
