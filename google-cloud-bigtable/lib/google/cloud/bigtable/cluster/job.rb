# Copyright 2018 Google LLC
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
      class Cluster
        ##
        # # Job
        #
        # A resource representing the long-running, asynchronous processing of
        # an cluster create or update operation. The job can be refreshed to
        # retrieve the cluster object once the operation has been completed.
        #
        # See {Instance#create_cluster} and {Cluster#save}.
        #
        # @see https://cloud.google.com/bigtable/docs/reference/admin/rpc/google.longrunning#google.longrunning.Operation
        #   Long-running Operation
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance "my-instance"
        #   job = instance.create_cluster(
        #     "my-new-cluster",
        #     "us-east-1b",
        #     nodes: 3,
        #     storage_type: :SSD
        #   )
        #
        #   job.done? #=> false
        #   job.reload! # API call
        #   job.done? #=> true
        #
        #   # OR wail until  complete
        #   job.wait_until_done!
        #
        #   if job.error?
        #     status = job.error
        #   else
        #     cluster = job.cluster
        #   end
        #
        class Job < LongrunningJob
          ##
          # Gets the cluster object from job results
          #
          # @return [Google::Cloud::Bigtable::Cluster, nil] The cluster instance, or
          #   `nil` if the operation is not complete.
          #
          # @example
          #   require "google/cloud/bigtable"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #
          #   instance = bigtable.instance "my-instance"
          #   job = instance.create_cluster(
          #     "my-new-cluster",
          #     "us-east-1b",
          #     nodes: 3,
          #     storage_type: :SSD
          #   )
          #
          #   job.wait_until_done!
          #   cluster = job.cluster
          #
          def cluster
            Cluster.from_grpc results, service if results
          end
        end
      end
    end
  end
end
