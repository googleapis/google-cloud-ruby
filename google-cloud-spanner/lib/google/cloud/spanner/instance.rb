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
      # NOTE: From `google-cloud-spanner/v2.11.0` onwards, new features for
      # mananging instances will only be available through the
      # [google-cloud-spanner-admin-instance-v1](https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud-spanner-admin-instance-v1)
      # client. See the
      # [README](https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud-spanner#google-cloud-spanner)
      # for further details.
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
      # @deprecated Use
      # {Google::Cloud::Spanner::Admin::Instance#instance_admin}
      # instead.
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
      #   if job.error?
      #     status = job.error
      #   else
      #     instance = job.instance
      #   end
      #
      class Instance
        ##
        # @private The gRPC Service object.
        attr_accessor :service

        # @private Creates a new Instance instance.
        def initialize grpc, service
          @grpc = grpc
          @service = service
          @current_values = grpc.to_h
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
        alias display_name name

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
        alias display_name= name=

        ##
        # The number of nodes allocated to this instance.
        # @return [Integer]
        def nodes
          @grpc.node_count
        end
        alias node_count nodes

        ##
        # Updates the number of nodes allocated to this instance.
        # @param nodes [Integer] The number of nodes allocated to this instance.
        def nodes= nodes
          @grpc.node_count = nodes
        end
        alias node_count= nodes=

        ##
        # The number of processing units allocated to this instance.
        #
        # @return [Integer]
        def processing_units
          @grpc.processing_units
        end

        ##
        # Updates number of processing units allocated to this instance.
        #
        # @param units [Integer] The number of processing units allocated
        #   to this instance.
        def processing_units= units
          @grpc.processing_units = units
        end

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
            Hash[labels.map { |k, v| [String(k), String(v)] }]
          )
        end

        ##
        # Update changes.
        #  `display_name`, `labels`, `nodes`, `processing_units` can be
        #  updated. `processing_units` and `nodes` can be used interchangeably
        #  to update.
        #
        # @return [Instance::Job] The job representing the long-running,
        #   asynchronous processing of an instance update operation.
        # @raise [ArgumentError] if both processing_units or nodes are specified.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   instance = spanner.instance "my-instance"
        #   instance.display_name = "prod-instance"
        #   instance.labels = { env: "prod", app: "api" }
        #   instance.nodes = 2
        #   # OR
        #   # instance.processing_units = 500
        #
        #   job = instance.save
        #
        #   job.done? #=> false
        #   job.reload! # API call
        #   job.done? #=> true
        #
        #   if job.error?
        #     status = job.error
        #   else
        #     instance = job.instance
        #   end
        #
        def save
          ensure_service!

          field_mask = []
          @current_values.each do |field, value|
            field_mask << field unless @grpc[field.to_s] == value
          end

          job_grpc = service.update_instance @grpc, field_mask: field_mask
          @current_values = @grpc.to_h
          Instance::Job.from_grpc job_grpc, service
        end
        alias update save

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
        # @example Retrieve all: (See {Instance::Config::List#all})
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
        # @param [Hash] encryption_config An encryption configuration describing
        #   the encryption type and key resources in Cloud KMS. Optional. The
        #   following settings can be provided:
        #
        #   * `:kms_key_name` (String) The name of KMS key to use which should
        #     be the full path, e.g., `projects/<project>/locations/<location>\
        #     /keyRings/<key_ring>/cryptoKeys/<kms_key_name>`
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
        #
        #   if job.error?
        #     status = job.error
        #   else
        #     database = job.database
        #   end
        #
        # @example Create with encryption config
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   instance = spanner.instance "my-instance"
        #
        #   kms_key_name = "projects/<project>/locations/<location>/keyRings/<key_ring>/cryptoKeys/<kms_key_name>"
        #   job = instance.create_database "my-new-database", encryption_config: { kms_key_name: kms_key_name }
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
        def create_database database_id, statements: [], encryption_config: nil
          grpc = service.create_database instance_id, database_id,
                                         statements: statements,
                                         encryption_config: encryption_config
          Database::Job.from_grpc grpc, service
        end

        ##
        # Retrieves the list of database operations for the given instance.
        #
        # @param filter [String]
        #   A filter expression that filters what operations are returned in the
        #   response.
        #
        #   The response returns a list of
        #  `Google::Longrunning::Operation` long-running operations whose names
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
        #   instance = spanner.instance "my-instance"
        #
        #   jobs = instance.database_operations
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
        #   instance = spanner.instance "my-instance"
        #
        #   jobs = instance.database_operations
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
        #   instance = spanner.instance "my-instance"
        #
        #   jobs = instance.database_operations page_size: 10
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
        #   instance = spanner.instance "my-instance"
        #
        #   filter = "metadata.@type:CreateDatabaseMetadata"
        #   jobs = instance.database_operations filter: filter
        #   jobs.each do |job|
        #     if job.error?
        #       p job.error
        #     else
        #       puts job.database.database_id
        #     end
        #   end
        #
        def database_operations filter: nil, page_size: nil
          grpc = service.list_database_operations \
            instance_id,
            filter: filter,
            page_size: page_size
          Database::Job::List.from_grpc grpc, service
        end

        ##
        # Retrieves backups belonging to the instance.
        #
        # @param [String] filter Optional. A filter expression that filters
        #   backups listed in the response. The expression must specify the
        #   field name, a comparison operator, and the value that you want to
        #   use for filtering. The value must be a string, a number, or a
        #   boolean. The comparison operator must be
        #   <, >, <=, >=, !=, =, or :. Colon ':' represents a HAS operator
        #   which is roughly synonymous with equality.
        #   Filter rules are case insensitive.
        #
        #   The fields eligible for filtering are:
        #     * `name`
        #     * `database`
        #     * `state`
        #     * `create_time`(and values are of the format YYYY-MM-DDTHH:MM:SSZ)
        #     * `expire_time`(and values are of the format YYYY-MM-DDTHH:MM:SSZ)
        #     * `size_bytes`
        #
        #   To filter on multiple expressions, provide each separate expression
        #   within parentheses. By default, each expression is an AND
        #   expression. However, you can include AND, OR, and NOT expressions
        #   explicitly.
        #
        #   Some examples of using filters are:
        #
        #     * `name:Howl` --> The backup's name contains the string "howl".
        #     * `database:prod`
        #          --> The database's name contains the string "prod".
        #     * `state:CREATING` --> The backup is pending creation.
        #     * `state:READY` --> The backup is fully created and ready for use.
        #     * `(name:howl) AND (create_time < \"2018-03-28T14:50:00Z\")`
        #          --> The backup name contains the string "howl" and
        #              `create_time` of the backup is before
        #               2018-03-28T14:50:00Z.
        #     * `expire_time < \"2018-03-28T14:50:00Z\"`
        #          --> The backup `expire_time` is before 2018-03-28T14:50:00Z.
        #     * `size_bytes > 10000000000` -->
        #              The backup's size is greater than 10GB
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
        #   instance = spanner.instance "my-instance"
        #
        #   instance.backups.all.each do |backup|
        #     puts backup.backup_id
        #   end
        #
        # @example List backups by page size
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   instance = spanner.instance "my-instance"
        #
        #   instance.backups(page_size: 5).all.each do |backup|
        #     puts backup.backup_id
        #   end
        #
        # @example Filter and list backups
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   instance = spanner.instance "my-instance"
        #
        #   # filter backups by name.
        #   instance.backups(filter: "name:my-backup").all.each do |backup|
        #     puts backup.backup_id
        #   end
        #
        #   # filter backups by database name.
        #   instance.backups(filter: "database:prod-db").all.each do |backup|
        #     puts backup.backup_id
        #   end
        #
        def backups filter: nil, page_size: nil
          ensure_service!
          grpc = service.list_backups \
            instance_id,
            filter: filter,
            page_size: page_size
          Backup::List.from_grpc grpc, service
        end

        ##
        # Retrieves a backup belonging to the instance by identifier.
        #
        # @param [String] backup_id The unique identifier for the backup.
        #
        # @return [Google::Cloud::Spanner::Backup, nil] Returns `nil`
        #   if database does not exist.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   instance = spanner.instance "my-instance"
        #   backup = instance.backup "my-backup"
        #
        # @example Will return `nil` if backup does not exist.
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   instance = spanner.instance "my-instance"
        #   backup = instance.backup "non-existing-backup" # nil
        #
        def backup backup_id
          ensure_service!
          grpc = service.get_backup instance_id, backup_id
          Backup.from_grpc grpc, service
        rescue Google::Cloud::NotFoundError
          nil
        end

        ##
        # Retrieves the list of database backup operations for the given
        # instance.
        #
        # @param filter [String]
        #   A filter expression that filters what operations are returned in the
        #   response.
        #
        #   The response returns a list of
        #   `Google::Longrunning::Operation` long-running operations whose names
        #   are prefixed by a backup name within the specified instance.
        #   The long-running operation
        #   `Google::Longrunning::Operation#metadata` metadata field type
        #   `metadata.type_url` describes the type of the metadata.
        #
        #   The filter expression must specify the field name of an operation, a
        #   comparison operator, and the value that you want to use for
        #   filtering.
        #   The value must be a string, a number, or a boolean. The comparison
        #   operator must be
        #   <, >, <=, >=, !=, =, or :. Colon ':'' represents a HAS operator
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
        #       response.value) are eligible for filtering.
        #
        #     To filter on multiple expressions, provide each separate
        #     expression within parentheses. By default, each expression is an
        #     AND expression. However, you can include AND, OR, and NOT
        #     expressions explicitly.
        #
        #   Some examples of using filters are:
        #
        #     * `done:true` --> The operation is complete.
        #     * `metadata.database:prod`
        #       --> The database the backup was taken from has a name containing
        #       the string "prod".
        #     * `(metadata.@type:type.googleapis.com/google.spanner.admin.\
        #       database.v1.CreateBackupMetadata)
        #       AND (metadata.name:howl)
        #       AND (metadata.progress.start_time < \"2018-03-28T14:50:00Z\")
        #       AND (error:*)`
        #       --> Return CreateBackup operations where the created backup name
        #       contains the string "howl", the progress.start_time of the
        #       backup operation is before 2018-03-28T14:50:00Z, and the
        #       operation returned an error.
        # @param page_size [Integer]
        #   The maximum number of resources contained in the underlying API
        #   response. If page streaming is performed per-resource, this
        #   parameter does not affect the return value. If page streaming is
        #   performed per-page, this determines the maximum number of
        #   resources in a page.
        #
        # @return [Array<Google::Cloud::Spanner::Backup::Job>] List representing
        #   the long-running, asynchronous processing of a backup operations.
        #   (See {Google::Cloud::Spanner::Backup::Job::List})
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   instance = spanner.instance "my-instance"
        #
        #   jobs = instance.backup_operations
        #   jobs.each do |job|
        #     if job.error?
        #       p job.error
        #     else
        #       p job.backup.backup_id
        #     end
        #   end
        #
        # @example Retrieve all
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   instance = spanner.instance "my-instance"
        #
        #   jobs = instance.backup_operations
        #   jobs.all do |job|
        #     if job.error?
        #       p job.error
        #     else
        #       p job.backup.backup_id
        #     end
        #   end
        #
        # @example List by page size
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   instance = spanner.instance "my-instance"
        #
        #   jobs = instance.backup_operations page_size: 10
        #   jobs.each do |job|
        #     if job.error?
        #       p job.error
        #     else
        #       puts job.backup.backup_id
        #     end
        #   end
        #
        # @example Filter and list
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   instance = spanner.instance "my-instance"
        #
        #   filter = "metadata.@type:CreateBackupMetadata"
        #   jobs = instance.backup_operations filter: filter
        #   jobs.each do |job|
        #     if job.error?
        #       p job.error
        #     else
        #       puts job.backup.backup_id
        #     end
        #   end
        #
        def backup_operations filter: nil, page_size: nil
          grpc = service.list_backup_operations \
            instance_id,
            filter: filter,
            page_size: page_size
          Backup::Job::List.from_grpc grpc, service
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
          update_policy policy
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
        #   instance.update_policy policy # API call
        #
        def update_policy new_policy
          ensure_service!
          grpc = service.set_instance_policy path, new_policy.to_grpc
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
        # `Google::Cloud::Spanner::Admin::Instance::V1::Instance`.
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
      end
    end
  end
end
