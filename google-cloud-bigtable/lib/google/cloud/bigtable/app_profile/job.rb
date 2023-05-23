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
      class AppProfile
        ##
        # # Job
        #
        # A resource representing the long-running, asynchronous processing of
        # an app profile create or update operation. The job can be refreshed to
        # retrieve the app profile object once the operation has been completed.
        #
        # See {AppProfile#save}.
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
        #   app_profile = instance.app_profile "my-app-profile"
        #
        #   app_profile.description = "User data instance app profile"
        #   routing_policy = Google::Cloud::Bigtable::AppProfile.single_cluster_routing(
        #     "my-cluster",
        #     allow_transactional_writes: true
        #   )
        #   app_profile.routing_policy = routing_policy
        #
        #   job = app_profile.save
        #
        #   job.done? #=> false
        #   job.reload! # API call
        #   job.done? #=> true
        #
        #   # OR
        #   job.wait_until_done!
        #
        #   if job.error?
        #     status = job.error
        #   else
        #     app_profile = job.app_profile
        #   end
        #
        class Job < LongrunningJob
          ##
          # The instance that is the object of the operation.
          #
          # @return [Google::Cloud::Bigtable::AppProfile, nil] The app profile instance, or
          #   `nil` if the operation is not complete.
          #
          # @example
          #   require "google/cloud/bigtable"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #
          #   instance = bigtable.instance "my-instance"
          #   app_profile = instance.app_profile "my-app-profile"
          #
          #   app_profile.description = "User data instance app profile"
          #   routing_policy = Google::Cloud::Bigtable::AppProfile.single_cluster_routing(
          #     "my-cluster",
          #     allow_transactional_writes: true
          #   )
          #   app_profile.routing_policy = routing_policy
          #
          #   job = app_profile.save
          #
          #   job.wait_until_done!
          #
          #   app_profile = job.app_profile
          #
          def app_profile
            return nil unless done?
            return nil unless @grpc.grpc_op.result == :response
            AppProfile.from_grpc @grpc.results, service
          end
        end
      end
    end
  end
end
