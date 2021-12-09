# Copyright 2016 Google LLC
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


require "google/cloud/spanner/instance/config/list"

module Google
  module Cloud
    module Spanner
      class Instance
        ##
        # # Instance Config
        #
        # Represents a Cloud Spanner instance configuration. Instance
        # configurations define the geographic placement of nodes and their
        # replication.
        #
        # See {Google::Cloud::Spanner::Project#instance_configs} and
        # {Google::Cloud::Spanner::Project#instance_config}.
        #
        # @deprecated Use
        # {Google::Cloud::Spanner::Admin::Instance::V1::InstanceConfig}
        # instead.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   instance_configs = spanner.instance_configs
        #   instance_configs.each do |config|
        #     puts config.instance_config_id
        #   end
        #
        class Config
          ##
          # @private Creates a new Instance::Config instance.
          def initialize grpc
            @grpc = grpc
          end

          # The unique identifier for the project.
          # @return [String]
          def project_id
            @grpc.name.split("/")[1]
          end

          ##
          # A unique identifier for the instance configuration.
          # @return [String]
          def instance_config_id
            @grpc.name.split("/")[3]
          end

          ##
          # The full path for the instance config resource. Values are of the
          # form `projects/<project_id>/instanceConfigs/<instance_config_id>`.
          # @return [String]
          def path
            @grpc.name
          end

          ##
          # The name of this instance configuration as it appears in UIs.
          # @return [String]
          def name
            @grpc.display_name
          end
          alias display_name name

          ##
          # @private Creates a new Instance::Config instance from a
          # `Google::Cloud::Spanner::Admin::Instance::V1::InstanceConfig`.
          def self.from_grpc grpc
            new grpc
          end

          protected

          ##
          # @private Raise an error unless an active connection to the service
          # is available.
          def ensure_service!
            raise "Must have active connection to service" unless service
          end
        end
      end
    end
  end
end
