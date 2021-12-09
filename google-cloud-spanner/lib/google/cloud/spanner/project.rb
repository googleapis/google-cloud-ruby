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


require "google/cloud/spanner/errors"
require "google/cloud/spanner/service"
require "google/cloud/spanner/client"
require "google/cloud/spanner/batch_client"
require "google/cloud/spanner/instance"
require "google/cloud/spanner/database"
require "google/cloud/spanner/range"

module Google
  module Cloud
    module Spanner
      ##
      # # Project
      #
      # Projects are top-level containers in Google Cloud Platform. They store
      # information about billing and authorized users, and they contain
      # Cloud Spanner data. Each project has a friendly name and a unique ID.
      #
      # Google::Cloud::Spanner::Project is the main object for interacting with
      # Cloud Spanner.
      #
      # {Google::Cloud::Spanner::Instance} and
      # {Google::Cloud::Spanner::Database} objects are created,
      # accessed, and managed by Google::Cloud::Spanner::Project.
      #
      # A {Google::Cloud::Spanner::Client} obtained from a project can be used
      # to read and/or modify data in a Cloud Spanner database.
      #
      # See {Google::Cloud::Spanner.new} and {Google::Cloud#spanner}.
      #
      # @example Obtaining an instance and a database from a project.
      #   require "google/cloud"
      #
      #   spanner = Google::Cloud::Spanner.new
      #   instance = spanner.instance "my-instance"
      #   database = instance.database "my-database"
      #
      # @example Obtaining a client for use with a database.
      #   require "google/cloud/spanner"
      #
      #   spanner = Google::Cloud::Spanner.new
      #
      #   db = spanner.client "my-instance", "my-database"
      #
      #   db.transaction do |tx|
      #     results = tx.execute_query "SELECT * FROM users"
      #
      #     results.rows.each do |row|
      #       puts "User #{row[:id]} is #{row[:name]}"
      #     end
      #   end
      #
      class Project
        ##
        # @private The Service object.
        attr_accessor :service, :query_options

        ##
        # @private Creates a new Spanner Project instance.
        def initialize service, query_options: nil
          @service = service
          @query_options = query_options
        end

        ##
        # The identifier for the Cloud Spanner project.
        #
        # @example
        #   require "google/cloud"
        #
        #   spanner = Google::Cloud::Spanner.new(
        #     project_id: "my-project",
        #     credentials: "/path/to/keyfile.json"
        #   )
        #
        #   spanner.project_id #=> "my-project"
        #
        def project_id
          service.project
        end
        alias project project_id

        ##
        # Retrieves the list of Cloud Spanner instances for the project.
        #
        # @param [String] token The `token` value returned by the last call to
        #   `instances`; indicates that this is a continuation of a call,
        #   and that the system should return the next page of data.
        # @param [Integer] max Maximum number of instances to return.
        #
        # @return [Array<Google::Cloud::Spanner::Instance>] The list of
        #   instances. (See {Google::Cloud::Spanner::Instance::List})
        #
        # @deprecated Use
        # {Google::Cloud::Spanner::Admin::Instance#instance_admin Client#list_instances}
        # instead.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   instances = spanner.instances
        #   instances.each do |instance|
        #     puts instance.instance_id
        #   end
        #
        # @example Retrieve all: (See {Instance::Config::List#all})
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   instances = spanner.instances
        #   instances.all do |instance|
        #     puts instance.instance_id
        #   end
        #
        def instances token: nil, max: nil
          ensure_service!
          grpc = service.list_instances token: token, max: max
          Instance::List.from_grpc grpc, service, max
        end

        ##
        # Retrieves a Cloud Spanner instance by unique identifier.
        #
        # @param [String] instance_id The unique identifier for the instance.
        #
        # @return [Google::Cloud::Spanner::Instance, nil] The instance, or `nil`
        #   if the instance does not exist.
        #
        # @deprecated Use
        # {Google::Cloud::Spanner::Admin::Instance#instance_admin Client#get_instance}
        # instead.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   instance = spanner.instance "my-instance"
        #
        # @example Will return `nil` if instance does not exist.
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   instance = spanner.instance "non-existing" # nil
        #
        def instance instance_id
          ensure_service!
          grpc = service.get_instance instance_id
          Instance.from_grpc grpc, service
        rescue Google::Cloud::NotFoundError
          nil
        end

        ##
        # Creates a Cloud Spanner instance and starts preparing it to begin
        # serving.
        #
        # See {Instance::Job}.
        #
        # @param [String] instance_id The unique identifier for the instance,
        #   which cannot be changed after the instance is created. Values are of
        #   the form `[a-z][-a-z0-9]*[a-z0-9]` and must be between 6 and 30
        #   characters in length. Required.
        # @param [String] name The descriptive name for this instance as it
        #   appears in UIs. Must be unique per project and between 4 and 30
        #   characters in length. Required.
        # @param [String, Instance::Config] config The name of the instance's
        #   configuration. Values can be the `instance_config_id`, the full
        #   path, or an {Instance::Config} object. Required.
        # @param [Integer] nodes The number of nodes allocated to this instance.
        #   Optional. Specify either `nodes` or `processing_units`
        # @param [Integer] processing_units The number of processing units
        #   allocated to this instance. Optional. Specify either `nodes`
        #   or `processing_units`
        # @param [Hash] labels Cloud Labels are a flexible and lightweight
        #   mechanism for organizing cloud resources into groups that reflect a
        #   customer's organizational needs and deployment strategies. Cloud
        #   Labels can be used to filter collections of resources. They can be
        #   used to control how resource metrics are aggregated. And they can be
        #   used as arguments to policy management rules (e.g. route, firewall,
        #   load balancing, etc.).
        #
        #   * Label keys must be between 1 and 63 characters long and must
        #     conform to the following regular expression:
        #     `[a-z]([-a-z0-9]*[a-z0-9])?`.
        #   * Label values must be between 0 and 63 characters long and must
        #     conform to the regular expression `([a-z]([-a-z0-9]*[a-z0-9])?)?`.
        #   * No more than 64 labels can be associated with a given resource.
        #
        # @return [Instance::Job] The job representing the long-running,
        #   asynchronous processing of an instance create operation.
        # @raise [ArgumentError] if both processing_units or nodes are specified.
        #
        # @deprecated Use
        # {Google::Cloud::Spanner::Admin::Instance#instance_admin Client#create_instance}
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
        # @example Create instance using processsing units
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   job = spanner.create_instance "my-new-instance",
        #                                 name: "My New Instance",
        #                                 config: "regional-us-central1",
        #                                 processing_units: 500,
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
        def create_instance instance_id, name: nil, config: nil, nodes: nil,
                            processing_units: nil, labels: nil
          config = config.path if config.respond_to? :path

          # Convert from possible Google::Protobuf::Map
          labels = Hash[labels.map { |k, v| [String(k), String(v)] }] if labels
          grpc = service.create_instance \
            instance_id, name: name, config: config, nodes: nodes,
                         processing_units: processing_units, labels: labels
          Instance::Job.from_grpc grpc, service
        end

        ##
        # Retrieves the list of instance configurations for the project.
        #
        # @param [String] token The `token` value returned by the last call to
        #   `instance_configs`; indicates that this is a continuation of a call,
        #   and that the system should return the next page of data.
        # @param [Integer] max Maximum number of instance configs to return.
        #
        # @return [Array<Google::Cloud::Spanner::Instance::Config>] The list of
        #   instance configurations. (See
        #   {Google::Cloud::Spanner::Instance::Config::List})
        #
        # @deprecated Use
        # {Google::Cloud::Spanner::Admin::Instance#instance_admin Client#list_instance_configs}
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
        # @example Retrieve all: (See {Instance::Config::List#all})
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   instance_configs = spanner.instance_configs
        #   instance_configs.all do |config|
        #     puts config.instance_config_id
        #   end
        #
        def instance_configs token: nil, max: nil
          ensure_service!
          grpc = service.list_instance_configs token: token, max: max
          Instance::Config::List.from_grpc grpc, service, max
        end

        ##
        # Retrieves an instance configuration by unique identifier.
        #
        # @param [String] instance_config_id The instance configuration
        #   identifier. Values can be the `instance_config_id`, or the full
        #   path.
        #
        # @return [Google::Cloud::Spanner::Instance::Config, nil] The instance
        #   configuration, or `nil` if the instance configuration does not
        #   exist.
        #
        # @deprecated Use
        # {Google::Cloud::Spanner::Admin::Instance#instance_admin Client#get_instance_config}
        # instead.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   config = spanner.instance_config "regional-us-central1"
        #
        # @example Will return `nil` if instance config does not exist.
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   config = spanner.instance_config "non-existing" # nil
        #
        def instance_config instance_config_id
          ensure_service!
          grpc = service.get_instance_config instance_config_id
          Instance::Config.from_grpc grpc
        rescue Google::Cloud::NotFoundError
          nil
        end

        ##
        # Retrieves the list of databases for the project.
        #
        # @param [String] instance_id The unique identifier for the instance.
        # @param [String] token The `token` value returned by the last call to
        #   `databases`; indicates that this is a continuation of a call,
        #   and that the system should return the next page of data.
        # @param [Integer] max Maximum number of databases to return.
        #
        # @return [Array<Google::Cloud::Spanner::Database>] The list of
        #   databases. (See {Google::Cloud::Spanner::Database::List})
        #
        # @deprecated Use
        # {Google::Cloud::Spanner::Admin::Database#database_admin Client#list_databases}
        # instead.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   databases = spanner.databases "my-instance"
        #   databases.each do |database|
        #     puts database.database_id
        #   end
        #
        # @example Retrieve all: (See {Instance::Config::List#all})
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   databases = spanner.databases "my-instance"
        #   databases.all do |database|
        #     puts database.database_id
        #   end
        #
        def databases instance_id, token: nil, max: nil
          ensure_service!
          grpc = service.list_databases instance_id, token: token, max: max
          Database::List.from_grpc grpc, service, instance_id, max
        end

        ##
        # Retrieves a database by unique identifier.
        #
        # @param [String] instance_id The unique identifier for the instance.
        # @param [String] database_id The unique identifier for the database.
        #
        # @return [Google::Cloud::Spanner::Database, nil] The database, or `nil`
        #   if the database does not exist.
        #
        # @deprecated Use
        # {Google::Cloud::Spanner::Admin::Database#database_admin Client#get_database}
        # instead.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   database = spanner.database "my-instance", "my-database"
        #
        # @example Will return `nil` if instance does not exist.
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   database = spanner.database "my-instance", "my-database" # nil
        #
        def database instance_id, database_id
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
        # @param [String] instance_id The unique identifier for the instance.
        #   Required.
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
        # @deprecated Use
        # {Google::Cloud::Spanner::Admin::Database#database_admin Client#create_database}
        # instead.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   job = spanner.create_database "my-instance",
        #                                 "my-new-database"
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
        #   kms_key_name = "projects/<project>/locations/<location>/keyRings/<key_ring>/cryptoKeys/<kms_key_name>"
        #   encryption_config = { kms_key_name: kms_key_name }
        #   job = spanner.create_database "my-instance",
        #                                 "my-new-database",
        #                                 encryption_config: encryption_config
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
        def create_database instance_id, database_id, statements: [],
                            encryption_config: nil
          grpc = service.create_database instance_id, database_id,
                                         statements: statements,
                                         encryption_config: encryption_config
          Database::Job.from_grpc grpc, service
        end

        ##
        # Creates a Cloud Spanner client. A client is used to read and/or modify
        # data in a Cloud Spanner database.
        #
        # @param [String] instance_id The unique identifier for the instance.
        #   Required.
        # @param [String] database_id The unique identifier for the database.
        #   Required.
        # @param [Hash] pool Settings to control how and when sessions are
        #   managed by the client. The following settings can be provided:
        #
        #   * `:min` (Integer) Minimum number of sessions that the client will
        #     maintain at any point in time. The default is 10.
        #   * `:max` (Integer) Maximum number of sessions that the client will
        #     have at any point in time. The default is 100.
        #   * `:keepalive` (Numeric) The amount of time a session can be idle
        #     before an attempt is made to prevent the idle sessions from being
        #     closed by the Cloud Spanner service. The default is 1800 (30
        #     minutes).
        #   * `:write_ratio` (Float) The ratio of sessions with pre-allocated
        #     transactions to those without. Pre-allocating transactions
        #     improves the performance of writes made by the client. The higher
        #     the value, the more transactions are pre-allocated. The value must
        #     be >= 0 and <= 1. The default is 0.3.
        #   * `:fail` (true/false) When `true` the client raises a
        #     {SessionLimitError} when the client has allocated the `max` number
        #     of sessions. When `false` the client blocks until a session
        #     becomes available. The default is `true`.
        #   * `:threads` (Integer) The number of threads in the thread pool. The
        #     default is twice the number of available CPUs.
        # @param [Hash] labels The labels to be applied to all sessions
        #   created by the client. Cloud Labels are a flexible and lightweight
        #   mechanism for organizing cloud resources into groups that reflect a
        #   customer's organizational needs and deployment strategies. Cloud
        #   Labels can be used to filter collections of resources. They can be
        #   used to control how resource metrics are aggregated. And they can be
        #   used as arguments to policy management rules (e.g. route, firewall,
        #   load balancing, etc.). Optional. The default is `nil`.
        #
        #   * Label keys must be between 1 and 63 characters long and must
        #     conform to the following regular expression:
        #     `[a-z]([-a-z0-9]*[a-z0-9])?`.
        #   * Label values must be between 0 and 63 characters long and must
        #     conform to the regular expression `([a-z]([-a-z0-9]*[a-z0-9])?)?`.
        #   * No more than 64 labels can be associated with a given resource.
        # @param [Hash] query_options A hash of values to specify the custom
        #   query options for executing SQL query. Query options are optional.
        #   The following settings can be provided:
        #
        #   * `:optimizer_version` (String) The version of optimizer to use.
        #     Empty to use database default. "latest" to use the latest
        #     available optimizer version.
        #   * `:optimizer_statistics_package` (String) Statistics package to
        #     use. Empty to use the database default.
        #
        # @return [Client] The newly created client.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.transaction do |tx|
        #     results = tx.execute_query "SELECT * FROM users"
        #
        #     results.rows.each do |row|
        #       puts "User #{row[:id]} is #{row[:name]}"
        #     end
        #   end
        #
        def client instance_id, database_id, pool: {}, labels: nil,
                   query_options: nil
          # Convert from possible Google::Protobuf::Map
          labels = Hash[labels.map { |k, v| [String(k), String(v)] }] if labels
          # Configs set by environment variables take over client-level configs.
          if query_options.nil?
            query_options = @query_options
          else
            query_options = query_options.merge @query_options unless @query_options.nil?
          end
          Client.new self, instance_id, database_id,
                     session_labels: labels,
                     pool_opts: valid_session_pool_options(pool),
                     query_options: query_options
        end

        ##
        # Creates a Cloud Spanner batch client. A batch client is used to read
        # data across multiple machines or processes.
        #
        # @param [String] instance_id The unique identifier for the instance.
        #   Required.
        # @param [String] database_id The unique identifier for the database.
        #   Required.
        # @param [Hash] labels The labels to be applied to all sessions
        #   created by the batch client. Labels are a flexible and lightweight
        #   mechanism for organizing cloud resources into groups that reflect a
        #   customer's organizational needs and deployment strategies. Cloud
        #   Labels can be used to filter collections of resources. They can be
        #   used to control how resource metrics are aggregated. And they can be
        #   used as arguments to policy management rules (e.g. route, firewall,
        #   load balancing, etc.). Optional. The default is `nil`.
        #
        #   * Label keys must be between 1 and 63 characters long and must
        #     conform to the following regular expression:
        #     `[a-z]([-a-z0-9]*[a-z0-9])?`.
        #   * Label values must be between 0 and 63 characters long and must
        #     conform to the regular expression `([a-z]([-a-z0-9]*[a-z0-9])?)?`.
        #   * No more than 64 labels can be associated with a given resource.
        # @param [Hash] query_options A hash of values to specify the custom
        #   query options for executing SQL query. Query options are optional.
        #   The following settings can be provided:
        #
        #   * `:optimizer_version` (String) The version of optimizer to use.
        #     Empty to use database default. "latest" to use the latest
        #     available optimizer version.
        #   * `:optimizer_statistics_package` (String) Statistics package to
        #     use. Empty to use the database default.
        #
        # @return [Client] The newly created client.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   batch_client = spanner.batch_client "my-instance", "my-database"
        #
        #   batch_snapshot = batch_client.batch_snapshot
        #   serialized_snapshot = batch_snapshot.dump
        #
        #   partitions = batch_snapshot.partition_read "users", [:id, :name]
        #
        #   partition = partitions.first
        #   serialized_partition = partition.dump
        #
        #   # In a separate process
        #   new_batch_snapshot = batch_client.load_batch_snapshot \
        #     serialized_snapshot
        #
        #   new_partition = batch_client.load_partition \
        #     serialized_partition
        #
        #   results = new_batch_snapshot.execute_partition \
        #     new_partition
        #
        def batch_client instance_id, database_id, labels: nil,
                         query_options: nil
          # Convert from possible Google::Protobuf::Map
          labels = Hash[labels.map { |k, v| [String(k), String(v)] }] if labels
          BatchClient.new self, instance_id, database_id, session_labels: labels,
                          query_options: query_options
        end

        protected

        ##
        # @private Raise an error unless an active connection to the service is
        # available.
        def ensure_service!
          raise "Must have active connection to service" unless service
        end

        # @deprecated Use
        # {Google::Cloud::Spanner::Admin::Database#database_admin Client#database_path}
        # instead.
        def database_path instance_id, database_id
          Admin::Database::V1::DatabaseAdminClient.database_path(
            project, instance_id, database_id
          )
        end

        def valid_session_pool_options opts = {}
          {
            min: opts[:min], max: opts[:max], keepalive: opts[:keepalive],
            write_ratio: opts[:write_ratio], fail: opts[:fail],
            threads: opts[:threads]
          }.delete_if { |_k, v| v.nil? }
        end
      end
    end
  end
end
