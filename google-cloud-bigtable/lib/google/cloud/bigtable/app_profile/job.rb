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
        # # Job
        #
        # A resource representing the long-running, asynchronous processing of
        # an cluster create or update operation. The job can be refreshed to
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
        #   instance = bigtable.instance("my-instance")
        #   app_profile = bigtable.instance("my-app-profile")
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
        #   if job.error?
        #     status = job.error
        #   else
        #     app_profile = job.app_profile
        #   end
        #
        class Job
          # @private
          # The Google::Gax::Operation gRPC object.
          attr_accessor :grpc

          # @private
          # The gRPC Service object.
          attr_accessor :service

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
          #   instance = bigtable.instance("my-instance")
          #   app_profile = bigtable.instance("my-app-profile")
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
          #   job.reload!
          #   job.done? #=> true
          #   app_profile = job.app_profile
          #
          def app_profile
            return nil unless done?
            return nil unless @grpc.grpc_op.result == :response
            AppProfile.from_grpc(@grpc.results, service)
          end

          ##
          # Checks if the processing of the cluster operation is complete.
          #
          # @return [boolean] `true` when complete, `false` otherwise.
          #
          # @example
          #   require "google/cloud/bigtable"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #
          #   instance = bigtable.instance("my-instance")
          #   app_profile = bigtable.instance("my-app-profile")
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
          #
          def done?
            @grpc.done?
          end

          ##
          # Checks if the processing of the instance operation has errored.
          #
          # @return [boolean] `true` when errored, `false` otherwise.
          #
          # @example
          #   require "google/cloud/bigtable"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #
          #   instance = bigtable.instance("my-instance")
          #   app_profile = bigtable.instance("my-app-profile")
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
          #   job.error? #=> false
          #
          def error?
            @grpc.error?
          end

          ##
          # The status if the operation associated with this job produced an
          # error.
          #
          # @return [Object, Google::Rpc::Status, nil] A status object with
          #   the status code and message, or `nil` if no error occurred.
          #
          # @example
          #   require "google/cloud/bigtable"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #
          #   instance = bigtable.instance("my-instance")
          #   app_profile = bigtable.instance("my-app-profile")
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
          #   job.error? # true
          #
          #   error = job.error
          #
          def error
            return nil unless error?
            @grpc.error
          end

          # Reloads the job with current data from the long-running,
          # asynchronous processing of an cluster operation.
          #
          # @return [Google::Cloud::Bigtable::AppProfile::Job] The same job
          #   instance.
          #
          # @example
          #   require "google/cloud/bigtable"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #
          #   instance = bigtable.instance("my-instance")
          #   app_profile = bigtable.instance("my-app-profile")
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
          def reload!
            @grpc.reload!
            self
          end

          # Reloads the job until the operation is complete. The delay between
          # reloads will incrementally increase.
          #
          # @example
          #   require "google/cloud/bigtable"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #
          #   instance = bigtable.instance("my-instance")
          #   app_profile = bigtable.instance("my-app-profile")
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
          #   job.wait_until_done!
          #   job.done? #=> true
          #
          def wait_until_done!
            @grpc.wait_until_done!
          end

          # @private
          # New AppProfile::Job from a Google::Gax::Operation object.
          def self.from_grpc grpc, service
            new.tap do |job|
              job.grpc =  grpc
              job.service = service
            end
          end
        end
      end
    end
  end
end
