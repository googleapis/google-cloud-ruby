# Copyright 2020 Google LLC
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

# DO NOT EDIT: Unless you're fixing a P0/P1 and/or a security issue. This class
# is frozen to all new features from `google-cloud-spanner/v2.11.0` onwards.


require "google/cloud/spanner/status"

module Google
  module Cloud
    module Spanner
      class Backup
        class Restore
          ##
          # # Job
          #
          # A resource representing the long-running, asynchronous processing of
          # a backup restore. The job can be refreshed to retrieve the restored
          # database object once the operation has been completed.
          #
          # See {Backup#restore}
          #
          # @see https://cloud.google.com/spanner/reference/rpc/google.longrunning#google.longrunning.Operation
          #   Long-running Operation
          #
          # @deprecated Use the long-running operation returned by
          # {Google::Cloud::Spanner::Admin::Database#database_admin Client#restore_database}
          # instead.
          #
          # @example
          #   require "google/cloud/spanner"
          #
          #   spanner = Google::Cloud::Spanner.new
          #
          #   instance = spanner.instance "my-instance"
          #   backup = instance.backup "my-backup"
          #   job = backup.restore "my-restored-database"
          #
          #   job.done? #=> false
          #   job.reload! # API call
          #   job.done? #=> true
          #
          #   if job.error?
          #     status = job.error
          #   else
          #     database = job.database
          #   end
          #
          class Job
            ##
            # @private The `Gapic::Operation` gRPC object.
            attr_accessor :grpc

            ##
            # @private The gRPC Service object.
            attr_accessor :service

            ##
            # @private Creates a new Restore::Job instance.
            def initialize
              @grpc = nil
              @service = nil
            end

            ##
            # The database is the object of the operation.
            #
            # @return [Database, nil] The database instance, or
            #   `nil` if the operation is not complete.
            #
            # @example
            #   require "google/cloud/spanner"
            #
            #   spanner = Google::Cloud::Spanner.new
            #
            #   instance = spanner.instance "my-instance"
            #   backup = instance.backup "my-backup"
            #   job = backup.restore "my-restored-database"
            #
            #   job.done? #=> false
            #   job.reload!
            #   job.done? #=> true
            #   database = job.database
            #
            def database
              return nil unless done?
              return nil unless @grpc.grpc_op.result == :response
              Database.from_grpc @grpc.results, service
            end

            ##
            # Checks if the processing of the restore operation is complete.
            #
            # @return [boolean] `true` when complete, `false` otherwise.
            #
            # @example
            #   require "google/cloud/spanner"
            #
            #   spanner = Google::Cloud::Spanner.new
            #
            #   instance = spanner.instance "my-instance"
            #   backup = instance.backup "my-backup"
            #   job = backup.restore "my-restored-database"
            #
            #   job.done? #=> false
            #
            def done?
              @grpc.done?
            end

            ##
            # Checks if the processing of the restore operation has errored.
            #
            # @return [boolean] `true` when errored, `false` otherwise.
            #
            # @example
            #   require "google/cloud/spanner"
            #
            #   spanner = Google::Cloud::Spanner.new
            #
            #   instance = spanner.instance "my-instance"
            #   backup = instance.backup "my-backup"
            #   job = backup.restore "my-restored-database"
            #
            #   job.error? #=> false
            #
            def error?
              @grpc.error?
            end

            ##
            # The status if the operation associated with this job produced an
            # error.
            #
            # @return [Google::Cloud::Spanner::Status, nil] A status object with
            #   the status code and message, or `nil` if no error occurred.
            #
            # @example
            #   require "google/cloud/spanner"
            #
            #   spanner = Google::Cloud::Spanner.new
            #
            #   instance = spanner.instance "my-instance"
            #   backup = instance.backup "my-backup"
            #   job = backup.restore "my-restored-database"
            #
            #   job.error? # true
            #
            #   error = job.error
            #
            def error
              return nil unless error?
              Google::Cloud::Spanner::Status.from_grpc @grpc.error
            end

            ##
            # Reloads the job with current data from the long-running,
            # asynchronous processing of a restore operation.
            #
            # @return [Backup::Job] The same job instance.
            #
            # @example
            #   require "google/cloud/spanner"
            #
            #   spanner = Google::Cloud::Spanner.new
            #
            #   instance = spanner.instance "my-instance"
            #   backup = instance.backup "my-backup"
            #   job = backup.restore "my-restored-database"
            #
            #   job.done? #=> false
            #   job.reload! # API call
            #   job.done? #=> true
            #
            def reload!
              @grpc.reload!
              self
            end
            alias refresh! reload!

            ##
            # Reloads the job until the operation is complete. The delay between
            # reloads will incrementally increase.
            #
            # @example
            #   require "google/cloud/spanner"
            #
            #   spanner = Google::Cloud::Spanner.new
            #
            #   instance = spanner.instance "my-instance"
            #   backup = instance.backup "my-backup"
            #   job = backup.restore "my-restored-database"
            #
            #   job.done? #=> false
            #   job.wait_until_done!
            #   job.done? #=> true
            #
            def wait_until_done!
              @grpc.wait_until_done!
            end

            ##
            # The operation progress in percentage.
            #
            # @return [Integer]
            def progress_percent
              @grpc.metadata.progress.progress_percent
            end

            ##
            # The operation start time.
            #
            # @return [Time, nil]
            def start_time
              return nil unless @grpc.metadata.progress.start_time
              Convert.timestamp_to_time @grpc.metadata.progress.start_time
            end

            ##
            # The operation end time.
            #
            # @return [Time, nil]
            def end_time
              return nil unless @grpc.metadata.progress.end_time
              Convert.timestamp_to_time @grpc.metadata.progress.end_time
            end

            ##
            # @private New Restore::Job from a `Gapic::Operation` object.
            def self.from_grpc grpc, service
              new.tap do |job|
                job.instance_variable_set :@grpc, grpc
                job.instance_variable_set :@service, service
              end
            end
          end
        end
      end
    end
  end
end
