# Copyright 2016 Google LLC
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
      # Represents a Cloud Spanner instance. Instances are dedicated Cloud
      # Spanner serving and storage resources to be used by Cloud Spanner
      # databases. Instances offer isolation: problems with databases in one
      # instance will not affect other instances. However, within an instance
      # databases can affect each other. For example, if one database in an
      # instance receives a lot of requests and consumes most of the instance
      # resources, fewer resources are available for other databases in that
      # instance, and their performance may suffer.
      #
      # See {Google::Cloud::Spanner::Project#instances},
      # {Google::Cloud::Spanner::Project#instance}, and
      # {Google::Cloud::Spanner::Project#create_instance}.
      #
      # @example
      #   require "google/cloud/spanner"
      #
      #   spanner = Google::Cloud::Spanner.new
      #
      #   job = spanner.create_instance "my-new-instance",
      #                                 name: "My New Instance",
      #                                 config: "regional-us-central1",
      #                                 nodes: 5,
      #                                 labels: { production: :env }
      #
      #   job.done? #=> false
      #   job.reload! # API call
      #   job.done? #=> true
      #
      #   instance = spanner.instance "my-new-instance"
      #
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
          @grpc.name.split("/")[1]
        end

        # The unique identifier for the instance.
        # @return [String]
        def instance_id
          @grpc.name.split("/")[3]
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
        # The instance configuration resource.
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
        # The current instance state. Possible values are `:CREATING` and
        # `:READY`.
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
        #
        # @return [Hash{String=>String}] The label keys and values in a hash.
        #
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

        ##
        # Retrieves the list of databases for the given instance.
        #
        # @param [String] token The `token` value returned by the last call to
        #   `databases`; indicates that this is a continuation of a call,
        #   and that the system should return the next page of data.
        # @param [Integer] max Maximum number of databases to return.
        #
        # @return [Array<Google::Cloud::Spanner::Database>] (See
        #   {Google::Cloud::Spanner::Database::List})
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   instance = spanner.instance "my-instance"
        #   databases = instance.databases
        #   databases.each do |database|
        #     puts database.database_id
        #   end
        #
        # @example Retrieve all: (See {Instance::Config::List::List#all})
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   instance = spanner.instance "my-instance"
        #   databases = instance.databases
        #   databases.all do |database|
        #     puts database.database_id
        #   end
        #
        def databases token: nil, max: nil
          ensure_service!
          grpc = service.list_databases instance_id, token: token, max: max
          Database::List.from_grpc grpc, service, instance_id, max
        end

        ##
        # Retrieves a database belonging to the instance by identifier.
        #
        # @param [String] database_id The unique identifier for the database.
        #
        # @return [Google::Cloud::Spanner::Database, nil] Returns `nil`
        #   if database does not exist.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   instance = spanner.instance "my-instance"
        #   database = instance.database "my-database"
        #
        # @example Will return `nil` if instance does not exist.
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   instance = spanner.instance "my-instance"
        #   database = instance.database "my-database" # nil
        #
        def database database_id
          ensure_service!
          grpc = service.get_database instance_id, database_id
          Database.from_grpc grpc, service
        rescue Google::Cloud::NotFoundError
          nil
        end

        ##
        # Creates a database and starts preparing it to begin serving.
        #
        # See {Database::Job}.
        #
        # @param [String] database_id The unique identifier for the database,
        #   which cannot be changed after the database is created. Values are of
        #   the form `[a-z][a-z0-9_\-]*[a-z0-9]` and must be between 2 and 30
        #   characters in length. Required.
        # @param [Array<String>] statements DDL statements to run inside the
        #   newly created database. Statements can create tables, indexes, etc.
        #   These statements execute atomically with the creation of the
        #   database: if there is an error in any statement, the database is not
        #   created. Optional.
        #
        # @return [Database::Job] The job representing the long-running,
        #   asynchronous processing of a database create operation.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   instance = spanner.instance "my-instance"
        #   job = instance.create_database "my-new-database"
        #
        #   job.done? #=> false
        #   job.reload! # API call
        #   job.done? #=> true
        #   database = job.database
        #
        def create_database database_id, statements: []
          grpc = service.create_database instance_id, database_id,
                                         statements: statements
          Database::Job.from_grpc grpc, service
        end

        ##
        # Gets the [Cloud IAM](https://cloud.google.com/iam/) access control
        # policy for this instance.
        #
        # @see https://cloud.google.com/spanner/reference/rpc/google.iam.v1#google.iam.v1.Policy
        #   google.iam.v1.IAMPolicy
        #
        # @yield [policy] A block for updating the policy. The latest policy
        #   will be read from the Spanner service and passed to the block. After
        #   the block completes, the modified policy will be written to the
        #   service.
        # @yieldparam [Policy] policy the current Cloud IAM Policy for this
        #   instance
        #
        # @return [Policy] The current Cloud IAM Policy for this instance.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   instance = spanner.instance "my-instance"
        #
        #   policy = instance.policy
        #
        # @example Update the policy by passing a block:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   instance = spanner.instance "my-instance"
        #
        #   instance.policy do |p|
        #     p.add "roles/owner", "user:owner@example.com"
        #   end # 2 API calls
        #
        def policy
          ensure_service!
          grpc = service.get_instance_policy path
          policy = Policy.from_grpc grpc
          return policy unless block_given?
          yield policy
          self.policy = policy
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
        # @return [Policy] The policy returned by the API update operation.
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
          Policy.from_grpc grpc
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
        #   * pubsub.instances.create
        #   * pubsub.instances.list
        #   * pubsub.instances.get
        #   * pubsub.instances.getIamPolicy
        #   * pubsub.instances.update
        #   * pubsub.instances.setIamPolicy
        #   * pubsub.instances.delete
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
