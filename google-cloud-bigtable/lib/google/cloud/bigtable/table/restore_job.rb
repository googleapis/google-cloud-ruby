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
      class Table
        ##
        # # RestoreJob
        #
        # A resource representing the long-running, asynchronous processing of an table create or update operation. The
        # job can be refreshed to retrieve the table object once the operation has been completed.
        #
        # See {Backup#restore}.
        #
        # @see https://cloud.google.com/bigtable/docs/reference/admin/rpc/google.longrunning#google.longrunning.Operation
        #   Long-running Operation
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   instance = bigtable.instance("my-instance")
        #   cluster = instance.cluster("my-cluster")
        #
        #   backup = cluster.backup("my-backup")
        #
        #   job = backup.restore("my-new-table")
        #
        #   job.wait_until_done!
        #   job.done? #=> true
        #
        #   if job.error?
        #     status = job.error
        #   else
        #     table = job.table
        #   end
        #
        class RestoreJob < LongrunningJob
          ##
          # Get the table object from operation results.
          #
          # @return [Google::Cloud::Bigtable::Table, nil] The table instance, or `nil` if the operation is not complete.
          #
          # @example
          #   require "google/cloud/bigtable"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #   instance = bigtable.instance("my-instance")
          #   cluster = instance.cluster("my-cluster")
          #
          #   backup = cluster.backup("my-backup")
          #
          #   job = backup.restore("my-new-table")
          #
          #   job.wait_until_done!
          #   job.done? #=> true
          #
          #   if job.error?
          #     status = job.error
          #   else
          #     table = job.table
          #   end
          #
          def table
            Table.from_grpc results, service if results
          end
        end
      end
    end
  end
end
