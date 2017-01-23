# Copyright 2016 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require "google/cloud/spanner/instance/job"
require "google/cloud/spanner/instance/list"
require "google/cloud/spanner/instance/config"
require "google/cloud/spanner/database"
require "google/cloud/spanner/policy"

module Google
  module Cloud
    module Spanner
      ##
      # # Instance
      #
      # ...
      #
      # See {Google::Cloud#spanner}
      #
      # @example
      #   require "google/cloud"
      #
      #   gcloud = Google::Cloud.new
      #   spanner = gcloud.spanner
      #
      #   # ...
      class Instance
        ##
        # @private The gRPC Service object.
        attr_accessor :service

        # @private Creates a new Instance instance.
        def initialize grpc, service
          @grpc = grpc
          @service = service
        end

        # The unique identifier for the project.
        # @return [String]
        def project_id
          Admin::Instance::V1::InstanceAdminClient
            .match_project_from_instance_name @grpc.name
        end

        # The unique identifier for the instance.
        # @return [String]
        def instance_id
          Admin::Instance::V1::InstanceAdminClient
            .match_instance_from_instance_name @grpc.name
        end

        ##
        # The full path for the instance resource. Values are of the form
        # `projects/<project_id>/instances/<instance_id>`.
        # @return [String]
        def path
          @grpc.name
        end

        ##
        # The descriptive name for this instance as it appears in UIs. Must be
        # unique per project and between 4 and 30 characters in length.
        # @return [String]
        def name
          @grpc.display_name
        end
        alias_method :display_name, :name

        ##
        # The instance config resource.
        # @return [Instance::Config]
        def config
          ensure_service!
          config_grpc = service.get_instance_config @grpc.config
          Instance::Config.from_grpc config_grpc
        rescue Google::Cloud::NotFoundError
          @grpc.config
        end

        ##
        # Updates the descriptive name for this instance as it appears in UIs.
        # @param display_name [String] The descriptive name for this instance.
        def name= display_name
          @grpc.display_name = display_name
        end
        alias_method :display_name=, :name=

        ##
        # The number of nodes allocated to this instance.
        # @return [Integer]
        def nodes
          @grpc.node_count
        end
        alias_method :node_count, :nodes

        ##
        # Updates the number of nodes allocated to this instance.
        # @param nodes [Integer] The number of nodes allocated to this instance.
        def nodes= nodes
          @grpc.node_count = nodes
        end
        alias_method :node_count=, :nodes=

        ##
        # The current instance state.
        # @return [Symbol]
        def state
          @grpc.state
        end

        ##
        # The instance is still being created. Resources may not be available
        # yet, and operations such as database creation may not work.
        # @return [Boolean]
        def creating?
          state == :CREATING
        end

        ##
        # The instance is fully created and ready to do work such as creating
        # databases.
        # @return [Boolean]
        def ready?
          state == :READY
        end

        ##
        # Cloud Labels are a flexible and lightweight mechanism for organizing
        # cloud resources into groups that reflect a customer's organizational
        # needs and deployment strategies. Cloud Labels can be used to filter
        # collections of resources. They can be used to control how resource
        # metrics are aggregated. And they can be used as arguments to policy
        # management rules (e.g. route, firewall, load balancing, etc.).
        #
        # * Label keys must be between 1 and 63 characters long and must conform
        #   to the following regular expression: `[a-z]([-a-z0-9]*[a-z0-9])?`.
        # * Label values must be between 0 and 63 characters long and must
        #   conform to the regular expression `([a-z]([-a-z0-9]*[a-z0-9])?)?`.
        # * No more than 64 labels can be associated with a given resource.
        # @return [Hash{String=>String}]
        def labels
          @grpc.labels
        end

        ##
        # Updates the Cloud Labels.
        # @param labels [Hash{String=>String}] The Cloud Labels.
        def labels= labels
          @grpc.labels = Google::Protobuf::Map.new(
            :string, :string,
            Hash[labels.map { |k, v| [String(k), String(v)] }])
        end

        def save
          job_grpc = service.update_instance @grpc
          Instance::Job.from_grpc job_grpc, service
        end
        alias_method :update, :save

        ##
        # Permanently deletes the instance.
        #
        # Immediately upon completion of the request:
        #
        # * Billing ceases for all of the instance's reserved resources.
        #
        # Soon afterward:
        #
        # * The instance and all of its databases immediately and irrevocably
        #   disappear from the API. All data in the databases is permanently
        #   deleted.
        #
        # @return [Boolean] Returns `true` if the instance was deleted.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   instance = spanner.instance "my-instance"
        #   instance.delete
        #
        def delete
          ensure_service!
          service.delete_instance path
          true
        end

        def database database_id = nil
          ensure_service!
          database_id ||= ENV["GCLOUD_DATABASE"]
          Database.new instance_id, database_id, service
        end

        ##
        # Gets the [Cloud IAM](https://cloud.google.com/iam/) access control
        # policy for this instance.
        #
        # @see https://cloud.google.com/spanner/reference/rpc/google.iam.v1#google.iam.v1.Policy
        #   google.iam.v1.IAMPolicy
        #
        # @param [Boolean] force Force the latest policy to be retrieved from
        #   the Spanner service when `true`. Otherwise the policy will be
        #   memoized to reduce the number of API calls made to the Spanner
        #   service. The default is `false`.
        #
        # @yield [policy] A block for updating the policy. The latest policy
        #   will be read from the Spanner service and passed to the block. After
        #   the block completes, the modified policy will be written to the
        #   service.
        # @yieldparam [Policy] policy the current Cloud IAM Policy for this
        #   instance
        #
        # @return [Policy] the current Cloud IAM Policy for this instance
        #
        # @example Policy values are memoized to reduce the number of API calls:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   instance = spanner.instance "my-instance"
        #
        #   policy = instance.policy # API call
        #   policy_2 = instance.policy # No API call
        #
        # @example Use `force` to retrieve the latest policy from the service:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   instance = spanner.instance "my-instance"
        #
        #   policy = instance.policy force: true # API call
        #   policy_2 = instance.policy force: true # API call
        #
        # @example Update the policy by passing a block:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   instance = spanner.instance "my-instance"
        #
        #   policy = instance.policy do |p|
        #     p.add "roles/owner", "user:owner@example.com"
        #   end # 2 API calls
        #
        def policy force: nil
          @policy = nil if force || block_given?
          @policy ||= begin
            ensure_service!
            grpc = service.get_instance_policy path
            Policy.from_grpc grpc
          end
          return @policy unless block_given?
          p = @policy.deep_dup
          yield p
          self.policy = p
        end

        ##
        # Updates the [Cloud IAM](https://cloud.google.com/iam/) access control
        # policy for this instance. The policy should be read from {#policy}.
        # See {Google::Cloud::Spanner::Policy} for an explanation of the policy
        # `etag` property and how to modify policies.
        #
        # You can also update the policy by passing a block to {#policy}, which
        # will call this method internally after the block completes.
        #
        # @see https://cloud.google.com/spanner/reference/rpc/google.iam.v1#google.iam.v1.Policy
        #   google.iam.v1.IAMPolicy
        #
        # @param [Policy] new_policy a new or modified Cloud IAM Policy for this
        #   instance
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   instance = spanner.instance "my-instance"
        #
        #   policy = instance.policy # API call
        #
        #   policy.add "roles/owner", "user:owner@example.com"
        #
        #   instance.policy = policy # API call
        #
        def policy= new_policy
          ensure_service!
          grpc = service.set_instance_policy path, new_policy.to_grpc
          @policy = Policy.from_grpc grpc
        end

        ##
        # Tests the specified permissions against the [Cloud
        # IAM](https://cloud.google.com/iam/) access control policy.
        #
        # @see https://cloud.google.com/iam/docs/managing-policies Managing
        #   Policies
        #
        # @param [String, Array<String>] permissions The set of permissions to
        #   check access for. Permissions with wildcards (such as `*` or
        #   `storage.*`) are not allowed.
        #
        #   The permissions that can be checked on a instance are:
        #
        #   * TODO
        #
        # @return [Array<Strings>] The permissions that have access.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   instance = spanner.instance "my-instance"
        #   perms = instance.test_permissions "spanner.instances.get",
        #                                     "spanner.instances.update"
        #   perms.include? "spanner.instances.get" #=> true
        #   perms.include? "spanner.instances.update" #=> false
        #
        def test_permissions *permissions
          permissions = Array(permissions).flatten
          permissions = Array(permissions).flatten
          ensure_service!
          grpc = service.test_instance_permissions path, permissions
          grpc.permissions
        end

        ##
        # @private Creates a new Instance instance from a
        # Google::Spanner::Admin::Instance::V1::Instance.
        def self.from_grpc grpc, service
          new grpc, service
        end

        protected

        ##
        # @private Raise an error unless an active connection to the service is
        # available.
        def ensure_service!
          fail "Must have active connection to service" unless service
        end

        def instance_config_path name
          return name if name.to_s.include? "/"
          Admin::Instance::V1::InstanceAdminClient.instance_config_path(
            project, name.to_s)
        end
      end
    end
  end
end
