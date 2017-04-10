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


require "google/cloud/spanner/database/job"
require "google/cloud/spanner/database/list"
require "google/cloud/spanner/session"
require "google/cloud/spanner/policy"

module Google
  module Cloud
    module Spanner
      ##
      # # Database
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
      class Database
        ##
        # @private The gRPC Service object.
        attr_accessor :service

        # @private Creates a new Database instance.
        def initialize grpc, service
          @grpc = grpc
          @service = service
        end

        # The unique identifier for the project.
        # @return [String]
        def project_id
          Admin::Database::V1::DatabaseAdminClient
            .match_project_from_database_name @grpc.name
        end

        # The unique identifier for the instance.
        # @return [String]
        def instance_id
          Admin::Database::V1::DatabaseAdminClient
            .match_instance_from_database_name @grpc.name
        end

        # The unique identifier for the database.
        # @return [String]
        def database_id
          Admin::Database::V1::DatabaseAdminClient
            .match_database_from_database_name @grpc.name
        end

        # rubocop:disable LineLength

        ##
        # The full path for the database resource. Values are of the form
        # `projects/<project_id>/instances/<instance_id>/databases/<database_id>`.
        # @return [String]
        def path
          @grpc.name
        end

        # rubocop:enable LineLength

        ##
        # The current database state.
        # @return [Symbol]
        def state
          @grpc.state
        end

        ##
        # The database is still being created. Resources may not be available
        # yet, and operations such as database creation may not work.
        # @return [Boolean]
        def creating?
          state == :CREATING
        end

        ##
        # The database is fully created and ready to do work such as creating
        # databases.
        # @return [Boolean]
        def ready?
          state == :READY
        end

        ##
        # Retrieve the Data Definition Language (DDL) statements that define
        # database structures. DDL statements are used to create, update,
        # and delete tables and indexes.
        #
        # @see https://cloud.google.com/spanner/docs/data-definition-language
        #   Data Definition Language
        #
        # @param [Boolean] force Force the latest DDL statements to be retrieved
        #   from the Spanner service when `true`. Otherwise the DDL statements
        #   will be memoized to reduce the number of API calls made to the
        #   Spanner service. The default is `false`.
        #
        # @return [Array<String>] the DDL statements
        #
        # @example statements are memoized to reduce the number of API calls:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   database = spanner.database "my-instance", "my-database"
        #
        #   statements = database.ddl # API call
        #   statements_2 = database.ddl # No API call
        #
        # @example Use `force` to retrieve the statements from the service:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   database = spanner.database "my-instance", "my-database"
        #
        #   statements = database.ddl force: true # API call
        #   statements_2 = database.ddl force: true # API call
        #
        def ddl force: nil
          return @ddl if @ddl && !force
          ensure_service!
          ddl_grpc = service.get_database_ddl instance_id, database_id
          @ddl = ddl_grpc.statements
        end

        ##
        # Updates the database schema by adding Data Definition Language (DDL)
        # statements to create, update, and delete tables and indexes.
        #
        # @see https://cloud.google.com/spanner/docs/data-definition-language
        #   Data Definition Language
        #
        # @param [Array<String>] statements The DDL statements to be applied to
        #   the database.
        # @param [String, nil] operation_id The operation ID used to perform the
        #   update. When `nil`, the update request is assigned an
        #   automatically-generated operation ID. Specifying an explicit value
        #   simplifies determining whether the statements were executed in the
        #   event that the update is replayed, or the return value is otherwise
        #   lost. This value should be unique within the database, and must be a
        #   valid identifier: `[a-z][a-z0-9_]*`. Will raise
        #   {Google::Cloud::AlreadyExistsError} if the named operation already
        #   exists. Optional.
        #
        # @return [Database::Job] the DDL statements
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   database = spanner.database "my-instance", "my-database"
        #
        #   add_users_table_sql = %q(
        #     CREATE TABLE users (
        #       id INT64 NOT NULL,
        #       username STRING(25) NOT NULL,
        #       name STRING(45) NOT NULL,
        #       email STRING(128),
        #     ) PRIMARY KEY(id)
        #   )
        #
        #   database.update statements: [add_users_table_sql]
        #
        def update statements: [], operation_id: nil
          ensure_service!
          grpc = service.update_database_ddl instance_id, database_id,
                                             statements: statements,
                                             operation_id: operation_id
          Database::Job.from_grpc grpc, service
        end

        ##
        # Drops (deletes) the Cloud Spanner database.
        #
        # @return [Boolean] Returns `true` if the database was deleted.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   database = spanner.database "my-instance", "my-database"
        #
        #   database.drop
        #
        def drop
          ensure_service!
          service.drop_database instance_id, database_id
          true
        end

        ##
        # Creates or retrieves a session. A session can read and/or modify data
        # in a Cloud Spanner database.
        #
        # @param [String] session_id The unique identifier for the database.
        #   Optional.
        #
        # @return [Session, nil] The newly created session if a `session_id` was
        #   not provided, or an existing session if a `session_id` was provided.
        #   Can return `nil` if the `session_id` provided is not found.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   database = spanner.database "my-instance", "my-database"
        #
        #   db = database.session
        #
        #   ...
        #
        def session session_id = nil
          ensure_service!
          if session_id.nil?
            grpc = service.create_session path
            return Session.from_grpc(grpc, service)
          end
          grpc = service.get_session \
            session_path(instance_id, database_id, session_id)
          Session.from_grpc grpc, service
        end

        ##
        # Gets the [Cloud IAM](https://cloud.google.com/iam/) access control
        # policy for this database.
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
        #   database
        #
        # @return [Policy] the current Cloud IAM Policy for this database
        #
        # @example Policy values are memoized to reduce the number of API calls:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   database = spanner.database "my-instance", "my-database"
        #
        #   policy = database.policy # API call
        #   policy_2 = database.policy # No API call
        #
        # @example Use `force` to retrieve the latest policy from the service:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   database = spanner.database "my-instance", "my-database"
        #
        #   policy = database.policy force: true # API call
        #   policy_2 = database.policy force: true # API call
        #
        # @example Update the policy by passing a block:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   database = spanner.database "my-instance", "my-database"
        #
        #   database.policy do |p|
        #     p.add "roles/owner", "user:owner@example.com"
        #   end # 2 API calls
        #
        def policy force: nil
          @policy = nil if force || block_given?
          @policy ||= begin
            ensure_service!
            grpc = service.get_database_policy instance_id, database_id
            Policy.from_grpc grpc
          end
          return @policy unless block_given?
          p = @policy.deep_dup
          yield p
          self.policy = p
        end

        ##
        # Updates the [Cloud IAM](https://cloud.google.com/iam/) access control
        # policy for this database. The policy should be read from {#policy}.
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
        #   database
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   database = spanner.database "my-instance", "my-database"
        #
        #   policy = database.policy # API call
        #
        #   policy.add "roles/owner", "user:owner@example.com"
        #
        #   database.policy = policy # API call
        #
        def policy= new_policy
          ensure_service!
          grpc = service.set_database_policy \
            instance_id, database_id, new_policy.to_grpc
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
        #   The permissions that can be checked on a database are:
        #
        #   * TODO
        #
        # @return [Array<Strings>] The permissions that have access.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   database = spanner.database "my-instance", "my-database"
        #   perms = database.test_permissions "spanner.databases.get",
        #                                     "spanner.databases.update"
        #   perms.include? "spanner.databases.get" #=> true
        #   perms.include? "spanner.databases.update" #=> false
        #
        def test_permissions *permissions
          permissions = Array(permissions).flatten
          permissions = Array(permissions).flatten
          ensure_service!
          grpc = service.test_database_permissions \
            instance_id, database_id, permissions
          grpc.permissions
        end

        ##
        # @private Creates a new Database instance from a
        # Google::Spanner::Admin::Database::V1::Database.
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

        def session_path instance_id, database_id, session_id
          V1::SpannerClient.session_path(
            project_id, instance_id, database_id, session_id)
        end
      end
    end
  end
end
