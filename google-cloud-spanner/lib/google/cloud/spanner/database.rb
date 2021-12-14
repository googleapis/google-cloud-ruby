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


require "google/cloud/spanner/database/job"
require "google/cloud/spanner/database/list"
require "google/cloud/spanner/database/restore_info"
require "google/cloud/spanner/backup"
require "google/cloud/spanner/policy"

module Google
  module Cloud
    module Spanner
      ##
      # # Database
      #
      # NOTE: From `google-cloud-spanner/v2.11.0` onwards, new features for
      # mananging databases will only be available through the
      # [google-cloud-spanner-admin-database-v1](https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud-spanner-admin-database-v1)
      # client. See the
      # [README](https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud-spanner#google-cloud-spanner)
      # for further details.
      #
      # Represents a Cloud Spanner database. To use Cloud Spanner's read and
      # write operations, you must first create a database. A database belongs
      # to a {Instance} and contains tables and indexes. You may create multiple
      # databases in an {Instance}.
      #
      # See {Google::Cloud::Spanner::Instance#databases},
      # {Google::Cloud::Spanner::Instance#database}, and
      # {Google::Cloud::Spanner::Instance#create_database}.
      #
      # To read and/or modify data in a Cloud Spanner database, use an instance
      # of {Google::Cloud::Spanner::Client}. See
      # {Google::Cloud::Spanner::Project#client}.
      #
      # @deprecated Use
      # {Google::Cloud::Spanner::Admin::Database#database_admin} instead.
      #
      # @example
      #   require "google/cloud"
      #
      #   spanner = Google::Cloud::Spanner.new
      #   instance = spanner.instance "my-instance"
      #
      #   job = instance.create_database "my-new-database"
      #
      #   job.done? #=> false
      #   job.reload! # API call
      #   job.done? #=> true
      #
      #   if job.error?
      #     status = job.error
      #   else
      #     database = job.database
      #   end
      #
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
          @grpc.name.split("/")[1]
        end

        # The unique identifier for the instance.
        # @return [String]
        def instance_id
          @grpc.name.split("/")[3]
        end

        # The unique identifier for the database.
        # @return [String]
        def database_id
          @grpc.name.split("/")[5]
        end

        # The version retention period for a database.
        # @return [String]
        def version_retention_period
          @grpc.version_retention_period
        end

        # The earliest available version time for a database.
        # @return [Time]
        def earliest_version_time
          Convert.timestamp_to_time @grpc.earliest_version_time
        end

        ##
        # The full path for the database resource. Values are of the form
        # `projects/<project_id>/instances/<instance_id>/databases/<database_id>`.
        # @return [String]
        def path
          @grpc.name
        end

        ##
        # The current database state. Possible values are `:CREATING` and
        # `:READY`.
        # @return [Symbol]
        def state
          @grpc.state
        end

        ##
        # Time at which the database creation started.
        # @return [Time]
        def create_time
          Convert.timestamp_to_time @grpc.create_time
        end

        # An encryption configuration describing the encryption type and key
        # resources in Cloud KMS.
        #
        # @return [Google::Cloud::Spanner::Admin::Database::V1::EncryptionConfig, nil]
        def encryption_config
          @grpc.encryption_config
        end

        # Encryption information for the database.
        #
        # For databases that are using customer managed encryption, this
        # field contains the encryption information for the database, such as
        # encryption state and the Cloud KMS key versions that are in use.
        #
        # For databases that are using Google default or other types of encryption,
        # this field is empty.
        #
        # This field is propagated lazily from the backend. There might be a delay
        # from when a key version is being used and when it appears in this field.
        #
        # @return [Array<Google::Cloud::Spanner::Admin::Database::V1::EncryptionInfo>]
        def encryption_info
          @grpc.encryption_info.to_a
        end

        ##
        # The database is still being created. Operations on the database may
        # raise with `FAILED_PRECONDITION` in this state.
        # @return [Boolean]
        def creating?
          state == :CREATING
        end

        ##
        # The database is fully created and ready for use.
        # @return [Boolean]
        def ready?
          state == :READY
        end

        ##
        # The database is fully created from backup and optimizing.
        # @return [Boolean]
        def ready_optimizing?
          state == :READY_OPTIMIZING
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
        # @return [Array<String>] The DDL statements.
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
        # @return [Database::Job] The job representing the long-running,
        #   asynchronous processing of a database schema update operation.
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

        # @private
        DATBASE_OPERATION_METADAT_FILTER_TEMPLATE = [
          "(metadata.@type:CreateDatabaseMetadata AND " \
          "metadata.database:%<database_id>s)",
          "(metadata.@type:RestoreDatabaseMetadata AND "\
          "metadata.name:%<database_id>s)",
          "(metadata.@type:UpdateDatabaseDdl AND "\
          "metadata.database:%<database_id>s)"
        ].join(" OR ")

        ##
        # Retrieves the list of database operations for the given database.
        #
        # @param filter [String]
        #   A filter expression that filters what operations are returned in the
        #   response.
        #
        #   The response returns a list of
        #   `Google::Longrunning::Operation` long-running operations whose names
        #   are prefixed by a database name within the specified instance.
        #   The long-running operation
        #   `Google::Longrunning::Operation#metadata` metadata field type
        #   `metadata.type_url` describes the type of the metadata.
        #
        #   The filter expression must specify the field name,
        #   a comparison operator, and the value that you want to use for
        #   filtering. The value must be a string, a number, or a boolean.
        #   The comparison operator must be
        #   <, >, <=, >=, !=, =, or :. Colon ':' represents a HAS operator
        #   which is roughly synonymous with equality. Filter rules are case
        #   insensitive.
        #
        #   The long-running operation fields eligible for filtering are:
        #     * `name` --> The name of the long-running operation
        #     * `done` --> False if the operation is in progress, else true.
        #     * `metadata.type_url` (using filter string `metadata.@type`) and
        #       fields in `metadata.value` (using filter string
        #       `metadata.<field_name>`, where <field_name> is a field in
        #       metadata.value) are eligible for filtering.
        #     * `error` --> Error associated with the long-running operation.
        #     * `response.type_url` (using filter string `response.@type`) and
        #       fields in `response.value` (using filter string
        #       `response.<field_name>`, where <field_name> is a field in
        #       response.value)are eligible for filtering.
        #
        #     To filter on multiple expressions, provide each separate
        #     expression within parentheses. By default, each expression
        #     is an AND expression. However, you can include AND, OR, and NOT
        #     expressions explicitly.
        #
        #   Some examples of using filters are:
        #
        #     * `done:true` --> The operation is complete.
        #     * `(metadata.@type:type.googleapis.com/google.spanner.admin.\
        #       database.v1.RestoreDatabaseMetadata)
        #       AND (metadata.source_type:BACKUP)
        #       AND (metadata.backup_info.backup:backup_howl)
        #       AND (metadata.name:restored_howl)
        #       AND (metadata.progress.start_time < \"2018-03-28T14:50:00Z\")
        #       AND (error:*)`
        #       --> Return RestoreDatabase operations from backups whose name
        #       contains "backup_howl", where the created database name
        #       contains the string "restored_howl", the start_time of the
        #       restore operation is before 2018-03-28T14:50:00Z,
        #       and the operation returned an error.
        # @param page_size [Integer]
        #   The maximum number of resources contained in the underlying API
        #   response. If page streaming is performed per-resource, this
        #   parameter does not affect the return value. If page streaming is
        #   performed per-page, this determines the maximum number of
        #   resources in a page.
        #
        # @return [Array<Google::Cloud::Spanner::Database::Job>] List
        #   representing the long-running, asynchronous processing
        #   of a database operations.
        #   (See {Google::Cloud::Spanner::Database::Job::List})
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   database = spanner.database "my-instance", "my-database"
        #
        #   jobs = database.database_operations
        #   jobs.each do |job|
        #     if job.error?
        #       p job.error
        #     else
        #       p job.database.database_id
        #     end
        #   end
        #
        # @example Retrieve all
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   database = spanner.database "my-instance", "my-database"
        #
        #   jobs = database.database_operations
        #   jobs.all do |job|
        #     if job.error?
        #       p job.error
        #     else
        #       puts job.database.database_id
        #     end
        #   end
        #
        # @example List by page size
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   database = spanner.database "my-instance", "my-database"
        #
        #   jobs = database.database_operations page_size: 10
        #   jobs.each do |job|
        #     if job.error?
        #       p job.error
        #     else
        #       puts job.database.database_id
        #     end
        #   end
        #
        # @example Filter and list
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   database = spanner.database "my-instance", "my-database"
        #
        #   jobs = database.database_operations filter: "done:true"
        #   jobs.each do |job|
        #     if job.error?
        #       p job.error
        #     else
        #       puts job.database.database_id
        #     end
        #   end
        #
        def database_operations filter: nil, page_size: nil
          database_filter = format(
            DATBASE_OPERATION_METADAT_FILTER_TEMPLATE,
            database_id: database_id
          )

          if filter
            database_filter = format(
              "(%<filter>s) AND (%<database_filter>s)",
              filter: filter, database_filter: database_filter
            )
          end

          grpc = service.list_database_operations instance_id,
                                                  filter: database_filter,
                                                  page_size: page_size
          Database::Job::List.from_grpc grpc, service
        end

        ##
        # Creates a database backup.
        #
        # @param [String] backup_id The unique identifier for the backup.
        #   Values are of the form `[a-z][a-z0-9_\-]*[a-z0-9]` and must be
        #   between 2 and 60 characters in length. Required.
        # @param [Time] expire_time The expiration time of the backup, with
        #   microseconds granularity that must be at least 6 hours and at most
        #   366 days from the time the request is received. Required.
        #   Once the `expire_time` has passed, Cloud Spanner will delete the
        #   backup and free the resources used by the backup. Required.
        # @param [Time] version_time Specifies the time to have an externally
        #   consistent copy of the database. If no version time is specified,
        #   it will be automatically set to the backup create time. The version
        #   time can be as far in the past as specified by the database earliest
        #   version time. Optional.
        # @param [Hash] encryption_config An encryption configuration describing
        #   the encryption type and key resources in Cloud KMS. Optional. The
        #   following settings can be provided:
        #
        #   * `:kms_key_name` (String) The name of KMS key to use which should
        #     be the full path, e.g., `projects/<project>/locations/<location>\
        #     /keyRings/<key_ring>/cryptoKeys/<kms_key_name>`
        #     This field should be set only when encryption type
        #     `:CUSTOMER_MANAGED_ENCRYPTION`.
        #   * `:encryption_type` (Symbol) The encryption type of the backup.
        #     Valid values are:
        #       1. `:USE_DATABASE_ENCRYPTION` - Use the same encryption configuration as
        #         the database.
        #       2. `:GOOGLE_DEFAULT_ENCRYPTION` - Google default encryption.
        #       3. `:CUSTOMER_MANAGED_ENCRYPTION` - Use customer managed encryption.
        #         If specified, `:kms_key_name` must contain a valid Cloud KMS key.
        #
        # @raise [ArgumentError] if `:CUSTOMER_MANAGED_ENCRYPTION` specified without
        #   customer managed kms key.
        #
        # @return [Google::Cloud::Spanner::Backup::Job] The job representing
        #   the long-running, asynchronous processing of a backup create
        #   operation.
        #
        # @example Create backup with expiration time
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   database = spanner.database "my-instance", "my-database"
        #
        #   backup_id = "my-backup"
        #   expire_time = Time.now + (24 * 60 * 60) # 1 day from now
        #   version_time = Time.now - (24 * 60 * 60) # 1 day ago (optional)
        #
        #   job = database.create_backup backup_id, expire_time, version_time: version_time
        #
        #   job.done? #=> false
        #   job.reload! # API call
        #   job.done? #=> true
        #
        #   if job.error?
        #     status = job.error
        #   else
        #     backup = job.backup
        #   end
        #
        # @example Create backup with encryption config
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   database = spanner.database "my-instance", "my-database"
        #
        #   kms_key_name = "projects/<project>/locations/<location>/keyRings/<key_ring>/cryptoKeys/<kms_key_name>"
        #   encryption_config = {
        #     kms_key_name: kms_key_name,
        #     encryption_type: :CUSTOMER_MANAGED_ENCRYPTION
        #   }
        #   job = database.create_backup "my-backup",
        #                                Time.now + 36000,
        #                                encryption_config: encryption_config
        #
        #   job.done? #=> false
        #   job.reload! # API call
        #   job.done? #=> true
        #
        #   if job.error?
        #     status = job.error
        #   else
        #     backup = job.backup
        #   end
        #
        def create_backup backup_id, expire_time,
                          version_time: nil, encryption_config: nil
          ensure_service!

          if encryption_config&.include?(:kms_key_name) &&
             encryption_config[:encryption_type] != :CUSTOMER_MANAGED_ENCRYPTION
            raise Google::Cloud::InvalidArgumentError,
                  "kms_key_name only used with CUSTOMER_MANAGED_ENCRYPTION"
          end

          grpc = service.create_backup \
            instance_id,
            database_id,
            backup_id,
            expire_time,
            version_time,
            encryption_config: encryption_config
          Backup::Job.from_grpc grpc, service
        end

        ##
        # Retrieves backups belonging to the database.
        #
        # @param [Integer] page_size Optional. Number of backups to be returned
        #   in the response. If 0 or less, defaults to the server's maximum
        #   allowed page size.
        # @return [Array<Google::Cloud::Spanner::Backup>] Enumerable list of
        #   backups. (See {Google::Cloud::Spanner::Backup::List})
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   database = spanner.database "my-instance", "my-database"
        #
        #   database.backups.all.each do |backup|
        #     puts backup.backup_id
        #   end
        #
        # @example List backups by page size
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   database = spanner.database "my-instance", "my-database"
        #
        #   database.backups(page_size: 5).all.each do |backup|
        #     puts backup.backup_id
        #   end
        #
        def backups page_size: nil
          ensure_service!
          grpc = service.list_backups \
            instance_id,
            filter: "database:#{database_id}",
            page_size: page_size
          Backup::List.from_grpc grpc, service
        end

        # Information about the source used to restore the database.
        #
        # @return [Google::Cloud::Spanner::Database::RestoreInfo, nil]
        def restore_info
          return nil unless @grpc.restore_info
          RestoreInfo.from_grpc @grpc.restore_info
        end

        ##
        # Gets the [Cloud IAM](https://cloud.google.com/iam/) access control
        # policy for this database.
        #
        # @see https://cloud.google.com/spanner/reference/rpc/google.iam.v1#google.iam.v1.Policy
        #   google.iam.v1.IAMPolicy
        #
        # @yield [policy] A block for updating the policy. The latest policy
        #   will be read from the Spanner service and passed to the block. After
        #   the block completes, the modified policy will be written to the
        #   service.
        # @yieldparam [Policy] policy the current Cloud IAM Policy for this
        #   database
        #
        # @return [Policy] The current Cloud IAM Policy for this database.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   database = spanner.database "my-instance", "my-database"
        #
        #   policy = database.policy
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
        def policy
          ensure_service!
          grpc = service.get_database_policy instance_id, database_id
          policy = Policy.from_grpc grpc
          return policy unless block_given?
          yield policy
          update_policy policy
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
        # @return [Policy] The policy returned by the API update operation.
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
        #   database.update_policy policy # API call
        #
        def update_policy new_policy
          ensure_service!
          grpc = service.set_database_policy \
            instance_id, database_id, new_policy.to_grpc
          Policy.from_grpc grpc
        end
        alias policy= update_policy

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
        #  * spanner.databases.beginPartitionedDmlTransaction
        #  * spanner.databases.create
        #  * spanner.databases.createBackup
        #  * spanner.databases.list
        #  * spanner.databases.update
        #  * spanner.databases.updateDdl
        #  * spanner.databases.get
        #  * spanner.databases.getDdl
        #  * spanner.databases.getIamPolicy
        #  * spanner.databases.setIamPolicy
        #  * spanner.databases.beginReadOnlyTransaction
        #  * spanner.databases.beginOrRollbackReadWriteTransaction
        #  * spanner.databases.read
        #  * spanner.databases.select
        #  * spanner.databases.write
        #  * spanner.databases.drop
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
        # `Google::Cloud::Spanner::Admin::Database::V1::Database`.
        def self.from_grpc grpc, service
          new grpc, service
        end

        protected

        ##
        # @private Raise an error unless an active connection to the service is
        # available.
        def ensure_service!
          raise "Must have active connection to service" unless service
        end

        def session_path instance_id, database_id, session_id
          V1::SpannerClient.session_path(
            project_id, instance_id, database_id, session_id
          )
        end
      end
    end
  end
end
