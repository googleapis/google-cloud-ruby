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
require "google/cloud/bigquery/convert"
require "json"

module Google
  module Cloud
    module Bigquery
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
      #   bigquery = Google::Cloud::Bigquery.new
      #
      #   job = bigquery.query_job "SELECT COUNT(word) as count FROM " \
      #                            "`bigquery-public-data.samples.shakespeare`"
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
        # @return [String] The ID must contain only letters (`[A-Za-z]`), numbers
        #   (`[0-9]`), underscores (`_`), or dashes (`-`). The maximum length is 1,024
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
        # The geographic location where the job runs.
        #
        # @return [String]  A geographic location, such as "US", "EU" or
        #   "asia-northeast1".
        #
        # @!group Attributes
        def location
          @gapi.job_reference.location
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
          Convert.millis_to_time @gapi.statistics.creation_time
        end

        ##
        # The time when the job was started.
        # This field is present after the job's state changes from `PENDING`
        # to either `RUNNING` or `DONE`.
        #
        # @return [Time, nil] The start time from the job statistics.
        #
        def started_at
          Convert.millis_to_time @gapi.statistics.start_time
        end

        ##
        # The time when the job ended.
        # This field is present when the job's state is `DONE`.
        #
        # @return [Time, nil] The end time from the job statistics.
        #
        def ended_at
          Convert.millis_to_time @gapi.statistics.end_time
        end

        ##
        # The number of child jobs executed.
        #
        # @return [Integer] The number of child jobs executed.
        #
        def num_child_jobs
          @gapi.statistics.num_child_jobs || 0
        end

        ##
        # If this is a child job, the id of the parent.
        #
        # @return [String, nil] The ID of the parent job, or `nil` if not a child job.
        #
        def parent_job_id
          @gapi.statistics.parent_job_id
        end

        ##
        # An array containing the job resource usage breakdown by reservation, if present. Reservation usage statistics
        # are only reported for jobs that are executed within reservations.  On-demand jobs do not report this data.
        #
        # @return [Array<Google::Cloud::Bigquery::Job::ReservationUsage>, nil] The reservation usage, if present.
        #
        def reservation_usage
          return nil unless @gapi.statistics.reservation_usage
          Array(@gapi.statistics.reservation_usage).map { |g| ReservationUsage.from_gapi g }
        end

        ##
        # The ID of a multi-statement transaction.
        #
        # @return [String, nil] The transaction ID, or `nil` if not associated with a transaction.
        #
        def transaction_id
          @gapi.statistics.transaction_info&.transaction_id
        end

        ##
        # The statistics including stack frames for a child job of a script.
        #
        # @return [Google::Cloud::Bigquery::Job::ScriptStatistics, nil] The script statistics, or `nil` if the job is
        #   not a child job.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   multi_statement_sql = <<~SQL
        #     -- Declare a variable to hold names as an array.
        #     DECLARE top_names ARRAY<STRING>;
        #     -- Build an array of the top 100 names from the year 2017.
        #     SET top_names = (
        #     SELECT ARRAY_AGG(name ORDER BY number DESC LIMIT 100)
        #     FROM `bigquery-public-data.usa_names.usa_1910_current`
        #     WHERE year = 2017
        #     );
        #     -- Which names appear as words in Shakespeare's plays?
        #     SELECT
        #     name AS shakespeare_name
        #     FROM UNNEST(top_names) AS name
        #     WHERE name IN (
        #     SELECT word
        #     FROM `bigquery-public-data.samples.shakespeare`
        #     );
        #   SQL
        #
        #   job = bigquery.query_job multi_statement_sql
        #
        #   job.wait_until_done!
        #
        #   child_jobs = bigquery.jobs parent_job: job
        #
        #   child_jobs.each do |child_job|
        #     script_statistics = child_job.script_statistics
        #     puts script_statistics.evaluation_kind
        #     script_statistics.stack_frames.each do |stack_frame|
        #       puts stack_frame.text
        #     end
        #   end
        #
        def script_statistics
          ScriptStatistics.from_gapi @gapi.statistics.script_statistics if @gapi.statistics.script_statistics
        end

        ##
        # The configuration for the job. Returns a hash.
        #
        # @see https://cloud.google.com/bigquery/docs/reference/v2/jobs Jobs API
        #   reference
        def configuration
          JSON.parse @gapi.configuration.to_json
        end
        alias config configuration

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
        alias stats statistics

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
        #     "message"=>"Not found: Table bigquery-public-data:samples.BAD_ID"
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
        #     "message"=>"Not found: Table bigquery-public-data:samples.BAD_ID"
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
        # {CopyJob::Updater#labels=} or {ExtractJob::Updater#labels=} or
        # {LoadJob::Updater#labels=} or {QueryJob::Updater#labels=} to replace
        # the entire hash.
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
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   query = "SELECT COUNT(word) as count FROM " \
        #           "`bigquery-public-data.samples.shakespeare`"
        #
        #   job = bigquery.query_job query
        #
        #   job.cancel
        #
        def cancel
          ensure_service!
          resp = service.cancel_job job_id, location: location
          @gapi = resp.job
          true
        end

        ##
        # Requests that a job is deleted. This call will return when the job is deleted.
        #
        # @return [Boolean] Returns `true` if the job was deleted.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   job = bigquery.job "my_job"
        #
        #   job.delete
        #
        # @!group Lifecycle
        #
        def delete
          ensure_service!
          service.delete_job job_id, location: location
          true
        end

        ##
        # Created a new job with the current configuration.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   query = "SELECT COUNT(word) as count FROM " \
        #           "`bigquery-public-data.samples.shakespeare`"
        #
        #   job = bigquery.query_job query
        #
        #   job.wait_until_done!
        #   job.rerun!
        #
        def rerun!
          ensure_service!
          gapi = service.insert_job @gapi.configuration, location: location
          Job.from_gapi gapi, service
        end

        ##
        # Reloads the job with current data from the BigQuery service.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   query = "SELECT COUNT(word) as count FROM " \
        #           "`bigquery-public-data.samples.shakespeare`"
        #
        #   job = bigquery.query_job query
        #
        #   job.done?
        #   job.reload!
        #   job.done? #=> true
        #
        def reload!
          ensure_service!
          gapi = service.get_job job_id, location: location
          @gapi = gapi
        end
        alias refresh! reload!

        ##
        # Refreshes the job until the job is `DONE`. The delay between refreshes
        # starts at 5 seconds and increases exponentially to a maximum of 60
        # seconds.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
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
            delay = [retries**2 + 5, 60].min # Maximum delay is 60
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
                                  body:        error_body
        end

        ##
        # @private
        # Get the subclass for a job type
        def self.klass_for gapi
          if gapi.configuration.copy
            CopyJob
          elsif gapi.configuration.extract
            ExtractJob
          elsif gapi.configuration.load
            LoadJob
          elsif gapi.configuration.query
            QueryJob
          else
            Job
          end
        end

        ##
        # Represents Job resource usage breakdown by reservation.
        #
        # @attr_reader [String] name The reservation name or "unreserved" for on-demand resources usage.
        # @attr_reader [Fixnum] slot_ms The slot-milliseconds the job spent in the given reservation.
        #
        class ReservationUsage
          attr_reader :name
          attr_reader :slot_ms

          ##
          # @private Creates a new ReservationUsage instance.
          def initialize name, slot_ms
            @name = name
            @slot_ms = slot_ms
          end

          ##
          # @private New ReservationUsage from a statistics.reservation_usage value.
          def self.from_gapi gapi
            new gapi.name, gapi.slot_ms
          end
        end

        ##
        # Represents statistics for a child job of a script.
        #
        # @attr_reader [String] evaluation_kind Indicates the type of child job. Possible values include `STATEMENT` and
        #   `EXPRESSION`.
        # @attr_reader [Array<Google::Cloud::Bigquery::Job::ScriptStackFrame>] stack_frames Stack trace where the
        #   current evaluation happened. Shows line/column/procedure name of each frame on the stack at the point where
        #   the current evaluation happened. The leaf frame is first, the primary script is last.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   multi_statement_sql = <<~SQL
        #     -- Declare a variable to hold names as an array.
        #     DECLARE top_names ARRAY<STRING>;
        #     -- Build an array of the top 100 names from the year 2017.
        #     SET top_names = (
        #     SELECT ARRAY_AGG(name ORDER BY number DESC LIMIT 100)
        #     FROM `bigquery-public-data.usa_names.usa_1910_current`
        #     WHERE year = 2017
        #     );
        #     -- Which names appear as words in Shakespeare's plays?
        #     SELECT
        #     name AS shakespeare_name
        #     FROM UNNEST(top_names) AS name
        #     WHERE name IN (
        #     SELECT word
        #     FROM `bigquery-public-data.samples.shakespeare`
        #     );
        #   SQL
        #
        #   job = bigquery.query_job multi_statement_sql
        #
        #   job.wait_until_done!
        #
        #   child_jobs = bigquery.jobs parent_job: job
        #
        #   child_jobs.each do |child_job|
        #     script_statistics = child_job.script_statistics
        #     puts script_statistics.evaluation_kind
        #     script_statistics.stack_frames.each do |stack_frame|
        #       puts stack_frame.text
        #     end
        #   end
        #
        class ScriptStatistics
          attr_reader :evaluation_kind
          attr_reader :stack_frames

          ##
          # @private Creates a new ScriptStatistics instance.
          def initialize evaluation_kind, stack_frames
            @evaluation_kind = evaluation_kind
            @stack_frames = stack_frames
          end

          ##
          # @private New ScriptStatistics from a statistics.script_statistics value.
          def self.from_gapi gapi
            frames = Array(gapi.stack_frames).map { |g| ScriptStackFrame.from_gapi g }
            new gapi.evaluation_kind, frames
          end
        end

        ##
        # Represents a stack frame showing the line/column/procedure name where the current evaluation happened.
        #
        # @attr_reader [Integer] start_line One-based start line.
        # @attr_reader [Integer] start_column One-based start column.
        # @attr_reader [Integer] end_line One-based end line.
        # @attr_reader [Integer] end_column One-based end column.
        # @attr_reader [String] text Text of the current statement/expression.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   multi_statement_sql = <<~SQL
        #     -- Declare a variable to hold names as an array.
        #     DECLARE top_names ARRAY<STRING>;
        #     -- Build an array of the top 100 names from the year 2017.
        #     SET top_names = (
        #     SELECT ARRAY_AGG(name ORDER BY number DESC LIMIT 100)
        #     FROM `bigquery-public-data.usa_names.usa_1910_current`
        #     WHERE year = 2017
        #     );
        #     -- Which names appear as words in Shakespeare's plays?
        #     SELECT
        #     name AS shakespeare_name
        #     FROM UNNEST(top_names) AS name
        #     WHERE name IN (
        #     SELECT word
        #     FROM `bigquery-public-data.samples.shakespeare`
        #     );
        #   SQL
        #
        #   job = bigquery.query_job multi_statement_sql
        #
        #   job.wait_until_done!
        #
        #   child_jobs = bigquery.jobs parent_job: job
        #
        #   child_jobs.each do |child_job|
        #     script_statistics = child_job.script_statistics
        #     puts script_statistics.evaluation_kind
        #     script_statistics.stack_frames.each do |stack_frame|
        #       puts stack_frame.text
        #     end
        #   end
        #
        class ScriptStackFrame
          attr_reader :start_line
          attr_reader :start_column
          attr_reader :end_line
          attr_reader :end_column
          attr_reader :text

          ##
          # @private Creates a new ScriptStackFrame instance.
          def initialize start_line, start_column, end_line, end_column, text
            @start_line = start_line
            @start_column = start_column
            @end_line = end_line
            @end_column = end_column
            @text = text
          end

          ##
          # @private New ScriptStackFrame from a statistics.script_statistics[].stack_frames element.
          def self.from_gapi gapi
            new gapi.start_line, gapi.start_column, gapi.end_line, gapi.end_column, gapi.text
          end
        end

        protected

        ##
        # Raise an error unless an active connection is available.
        def ensure_service!
          raise "Must have active connection" unless service
        end

        def retrieve_table project_id, dataset_id, table_id
          ensure_service!
          gapi = service.get_project_table project_id, dataset_id, table_id
          Table.from_gapi gapi, service
        rescue Google::Cloud::NotFoundError
          nil
        end

        def status_code_for_reason reason
          codes = { "accessDenied" => 403, "backendError" => 500, "billingNotEnabled" => 403,
                    "billingTierLimitExceeded" => 400, "blocked" => 403, "duplicate" => 409, "internalError" => 500,
                    "invalid" => 400, "invalidQuery" => 400, "notFound" => 404, "notImplemented" => 501,
                    "quotaExceeded" => 403, "rateLimitExceeded" => 403, "resourceInUse" => 400,
                    "resourcesExceeded" => 400, "responseTooLarge" => 403, "tableUnavailable" => 400 }
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
