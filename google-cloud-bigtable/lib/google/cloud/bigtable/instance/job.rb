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
      class Instance
        ##
        # # Job
        #
        # A resource representing the long-running, asynchronous processing of
        # an instance create or update operation. The job can be refreshed to
        # retrieve the instance object once the operation has been completed.
        #
        # See {Project#create_instance} and {Instance#update}.
        #
        # @see https://cloud.google.com/bigtable/docs/reference/admin/rpc/google.longrunning#google.longrunning.Operation
        #   Long-running Operation
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   job = bigtable.create_instance(
        #     "my-instance",
        #     display_name: "Instance for user data",
        #     type: :DEVELOPMENT,
        #     labels: { "env" => "dev" }
        #   ) do |clusters|
        #     clusters.add "test-cluster", "us-east1-b" # nodes not allowed
        #   end
        #
        #   # Check and reload.
        #   job.done? #=> false
        #   job.reload! # API call
        #   job.done? #=> true
        #
        #   # OR - Wailt until complete
        #   job.wait_until_done!
        #   job.done? #=> true
        #
        #   if job.error?
        #     status = job.error
        #   else
        #     instance = job.instance
        #   end
        #
        class Job < LongrunningJob
          ##
          # Get the instance object from operation results.
          #
          # @return [Google::Cloud::Bigtable::Instance, nil] The Instance instance, or
          #   `nil` if the operation is not complete.
          #
          # @example
          #   require "google/cloud/bigtable"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #
          #   job = bigtable.create_instance(
          #     "my-instance",
          #     display_name: "Instance for user data",
          #     type: :DEVELOPMENT,
          #     labels: { "env" => "dev" }
          #   ) do |clusters|
          #     clusters.add "test-cluster", "us-east1-b" # nodes not allowed
          #   end
          #
          #   job.done? #=> false
          #   job.reload!
          #   job.done? #=> true
          #
          #   # OR
          #   job.wait_until_done!
          #
          #   instance = job.instance
          #
          def instance
            Instance.from_grpc results, service if results
          end
        end
      end
    end
  end
end
