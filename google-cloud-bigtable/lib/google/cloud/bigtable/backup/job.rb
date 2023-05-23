# frozen_string_literal: true

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


module Google
  module Cloud
    module Bigtable
      class Backup
        ##
        # # Job
        #
        # A resource representing the long-running, asynchronous processing of an backup create operation. The job can
        # be refreshed to retrieve the backup object once the operation has been completed.
        #
        # See {Cluster#create_backup}.
        #
        # @see https://cloud.google.com/bigtable/docs/reference/admin/rpc/google.longrunning#google.longrunning.Operation
        #   Long-running Operation
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   instance = bigtable.instance "my-instance"
        #   cluster = instance.cluster "my-cluster"
        #   table = instance.table "my-table"
        #
        #   expire_time = Time.now + 60 * 60 * 7
        #   job = cluster.create_backup table, "my-backup", expire_time
        #
        #   job.wait_until_done!
        #   job.done? #=> true
        #
        #   if job.error?
        #     status = job.error
        #   else
        #     backup = job.backup
        #   end
        #
        class Job < LongrunningJob
          ##
          # Get the backup object from operation results.
          #
          # @return [Google::Cloud::Bigtable::Backup, nil] The backup instance, or `nil` if the operation is not
          #   complete.
          #
          # @example
          #   require "google/cloud/bigtable"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #   instance = bigtable.instance "my-instance"
          #   cluster = instance.cluster "my-cluster"
          #   table = instance.table "my-table"
          #
          #   expire_time = Time.now + 60 * 60 * 7
          #   job = cluster.create_backup table, "my-backup", expire_time
          #
          #   job.wait_until_done!
          #   job.done? #=> true
          #
          #   if job.error?
          #     status = job.error
          #   else
          #     backup = job.backup
          #   end
          #
          def backup
            Backup.from_grpc results, service if results
          end
        end
      end
    end
  end
end
