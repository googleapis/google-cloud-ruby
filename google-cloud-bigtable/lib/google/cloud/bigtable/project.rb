# frozen_string_literal: true

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


require "google/cloud/bigtable/errors"
require "google/cloud/bigtable/longrunning_job"
require "google/cloud/bigtable/convert"
require "google/cloud/bigtable/service"
require "google/cloud/bigtable/instance"
require "google/cloud/bigtable/cluster"
require "google/cloud/bigtable/table"

module Google
  module Cloud
    module Bigtable
      ##
      # # Project
      #
      # Projects are top-level containers in Google Cloud Platform. They store
      # information about billing and authorized users, and they contain
      # Cloud Bigtable data. Each project has a friendly name and a unique ID.
      #
      # `Google::Cloud::Bigtable::Project` is the main object for interacting with
      # Cloud Bigtable.
      #
      # {Google::Cloud::Bigtable::Cluster} and {Google::Cloud::Bigtable::Instance}
      # objects are created, accessed, and managed by Google::Cloud::Bigtable::Project.
      #
      # To create a `Project` instance, use {Google::Cloud::Bigtable.new}.
      #
      # @example Obtaining an instance and the clusters from a project.
      #   require "google/cloud/bigtable"
      #
      #   bigtable = Google::Cloud::Bigtable.new
      #
      #   instance = bigtable.instance "my-instance"
      #   clusters = bigtable.clusters # All clusters in the project
      #
      class Project
        # @private
        # The Service object
        attr_accessor :service

        # @private
        # Creates a new Bigtable Project instance.
        # @param service [Google::Cloud::Bigtable::Service]
        def initialize service
          @service = service
        end

        ##
        # The identifier for the Cloud Bigtable project.
        #
        # @return [String] Project ID.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new(
        #     project_id: "my-project",
        #     credentials: "/path/to/keyfile.json"
        #   )
        #
        #   bigtable.project_id #=> "my-project"
        #
        def project_id
          ensure_service!
          service.project_id
        end

        ##
        # Retrieves the list of Bigtable instances for the project.
        #
        # @param token [String] The `token` value returned by the last call to
        #   `instances`; indicates that this is a continuation of a call
        #   and that the system should return the next page of data.
        # @return [Array<Google::Cloud::Bigtable::Instance>] The list of instances.
        #   (See {Google::Cloud::Bigtable::Instance::List})
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instances = bigtable.instances
        #   instances.all do |instance|
        #     puts instance.instance_id
        #   end
        #
        def instances token: nil
          ensure_service!
          grpc = service.list_instances token: token
          Instance::List.from_grpc grpc, service
        end

        ##
        # Gets an existing Bigtable instance.
        #
        # @param instance_id [String] Existing instance ID.
        # @return [Google::Cloud::Bigtable::Instance, nil]
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance "my-instance"
        #
        #   if instance
        #     puts instance.instance_id
        #   end
        #
        def instance instance_id
          ensure_service!
          grpc = service.get_instance instance_id
          Instance.from_grpc grpc, service
        rescue Google::Cloud::NotFoundError
          nil
        end

        ##
        # Creates a Bigtable instance.
        #
        # @see https://cloud.google.com/compute/docs/regions-zones Cluster zone locations
        #
        # @param instance_id [String] The unique identifier for the instance,
        #   which cannot be changed after the instance is created. Values are of
        #   the form `[a-z][-a-z0-9]*[a-z0-9]` and must be between 6 and 30
        #   characters. Required.
        # @param display_name [String] The descriptive name for this instance as it
        #   appears in UIs. Must be unique per project and between 4 and 30
        #   characters.
        # @param type [Symbol] The type of the instance. When creating a development instance,
        #   `nodes` on the cluster must not be set.
        #   Valid values are `:DEVELOPMENT` or `:PRODUCTION`. Default is `:PRODUCTION`.
        # @param labels [Hash{String=>String}] labels Cloud Labels are a flexible and lightweight
        #   mechanism for organizing cloud resources into groups that reflect a
        #   customer's organizational needs and deployment strategies. Cloud
        #   Labels can be used to filter collections of resources. They can be
        #   used to control how resource metrics are aggregated. Cloud Labels can be
        #   used as arguments to policy management rules (e.g., route, firewall, or
        #   load balancing).
        #
        #   * Label keys must be between 1 and 63 characters and must
        #     conform to the following regular expression:
        #     `[a-z]([-a-z0-9]*[a-z0-9])?`.
        #   * Label values must be between 0 and 63 characters and must
        #     conform to the regular expression `([a-z]([-a-z0-9]*[a-z0-9])?)?`.
        #   * No more than 64 labels can be associated with a given resource.
        # @param clusters [Hash{String => Google::Cloud::Bigtable::Cluster}]
        #   (See {Google::Cloud::Bigtable::Instance::ClusterMap})
        #   If unspecified, you may use a code block to add clusters.
        #   Minimum of one cluster must be specified.
        # @yield [clusters] A block for adding clusters.
        # @yieldparam [Hash{String => Google::Cloud::Bigtable::Cluster}]
        #   Cluster map of cluster name and cluster object.
        #   (See {Google::Cloud::Bigtable::Instance::ClusterMap})
        # @return [Google::Cloud::Bigtable::Instance::Job]
        #   The job representing the long-running, asynchronous processing of
        #   an instance create operation.
        #
        # @example Create a development instance.
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
        #
        #   # Reload job until completion.
        #   job.wait_until_done!
        #   job.done? #=> true
        #
        #   if job.error?
        #     status = job.error
        #   else
        #     instance = job.instance
        #   end
        #
        # @example Create a production instance.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   job = bigtable.create_instance(
        #     "my-instance",
        #     display_name: "Instance for user data",
        #     labels: { "env" => "dev" }
        #   ) do |clusters|
        #     clusters.add "test-cluster", "us-east1-b", nodes: 3, storage_type: :SSD
        #   end
        #
        #   job.done? #=> false
        #
        #   # To block until the operation completes.
        #   job.wait_until_done!
        #   job.done? #=> true
        #
        #   if job.error?
        #     status = job.error
        #   else
        #     instance = job.instance
        #   end
        #
        def create_instance instance_id, display_name: nil, type: nil, labels: nil, clusters: nil
          labels = labels.to_h { |k, v| [String(k), String(v)] } if labels

          instance_attrs = { display_name: display_name, type: type, labels: labels }.compact
          instance = Google::Cloud::Bigtable::Admin::V2::Instance.new instance_attrs
          clusters ||= Instance::ClusterMap.new
          yield clusters if block_given?

          clusters.each_value do |cluster|
            cluster.location = service.location_path cluster.location unless cluster.location == ""
          end

          grpc = service.create_instance instance_id, instance, clusters.to_h
          Instance::Job.from_grpc grpc, service
        end

        ##
        # Lists all clusters in the project.
        #
        # @param token [String] The `token` value returned by the last call to
        #   `clusters` indicates that this is a continuation of a call
        #   and the system should return the next page of data.
        # @return [Array<Google::Cloud::Bigtable::Cluster>]
        #   (See {Google::Cloud::Bigtable::Cluster::List})
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   bigtable.clusters.all do |cluster|
        #     puts cluster.cluster_id
        #     puts cluster.ready?
        #   end
        #
        def clusters token: nil
          ensure_service!
          grpc = service.list_clusters "-", token: token
          Cluster::List.from_grpc grpc, service, instance_id: "-"
        end

        ##
        # Lists all tables for the given instance.
        #
        # @param instance_id [String] Existing instance Id.
        # @return [Array<Google::Cloud::Bigtable::Table>]
        #   (See {Google::Cloud::Bigtable::Table::List})
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   bigtable.tables("my-instance").all do |table|
        #     puts table.name
        #     puts table.column_families
        #   end
        #
        def tables instance_id
          ensure_service!
          grpc = service.list_tables instance_id
          Table::List.from_grpc grpc, service
        end

        ##
        # Returns a table representation. If `perform_lookup` is `false` (the default), a sparse representation will be
        # returned without performing an RPC and without verifying that the table resource exists.
        #
        # @param instance_id [String] Existing instance Id.
        # @param table_id [String] Existing table Id.
        # @param view [Symbol] Optional. Table view type. Default `:SCHEMA_VIEW`
        #   Valid view types are the following:
        #   * `:NAME_ONLY` - Only populates `name`
        #   * `:SCHEMA_VIEW` - Only populates `name` and fields related to the table's schema
        #   * `:REPLICATION_VIEW` - Only populates `name` and fields related to the table's replication state.
        #   * `:FULL` - Populates all fields
        # @param perform_lookup [Boolean]
        #   Get table object without verifying that the table resource exists.
        #   Calls made on this object will raise errors if the table does not exist.
        #   Default value is `false`. Optional.
        #   Helps to reduce admin API calls.
        # @param app_profile_id [String] The unique identifier for the app profile. Optional.
        #   Used only in data operations.
        #   This value specifies routing for replication. If not specified, the
        #   "default" application profile will be used.
        # @return [Google::Cloud::Bigtable::Table, nil]
        #
        # @example Get a sparse table representation without performing an RPC.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.table "my-instance", "my-table"
        #
        # @example Retrieve a table with a schema-only view.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.table "my-instance", "my-table", perform_lookup: true
        #   if table
        #     puts table.name
        #     puts table.column_families
        #   end
        #
        # @example Retrieve a table with all fields, cluster states, and column families.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.table "my-instance", "my-table", view: :FULL, perform_lookup: true
        #   if table
        #     puts table.name
        #     puts table.column_families
        #     puts table.cluster_states
        #   end
        #
        def table instance_id, table_id, view: nil, perform_lookup: nil, app_profile_id: nil
          ensure_service!

          view ||= :SCHEMA_VIEW
          if perform_lookup
            grpc = service.get_table instance_id, table_id, view: view
            Table.from_grpc grpc, service, view: view, app_profile_id: app_profile_id
          else
            Table.from_path service.table_path(instance_id, table_id), service, app_profile_id: app_profile_id
          end
        rescue Google::Cloud::NotFoundError
          nil
        end

        ##
        # Creates a new table in the specified instance.
        # The table can be created with a full set of initial column families,
        # specified in the request.
        #
        # @param instance_id [String]
        #   The unique ID of the instance in which to create the table.
        # @param table_id [String]
        #   The ID by which the new table should be referred to within the
        #   instance, e.g., `foobar`.
        # @param column_families [Google::Cloud::Bigtable::ColumnFamilyMap]
        #   An object containing the column families for the table, mapped by
        #   column family name.
        # @param granularity [Symbol]
        #   The granularity at which timestamps are stored in this table.
        #   Timestamps not matching the granularity will be rejected.
        #   Valid value is `:MILLIS`.
        #   If unspecified, the value will be set to `:MILLIS`.
        # @param initial_splits [Array<String>]
        #   The optional list of row keys that will be used to initially split the
        #   table into several tablets (tablets are similar to HBase regions).
        #   Given two split keys, `s1` and `s2`, three tablets will be created,
        #   spanning the key ranges: `[, s1), [s1, s2), [s2, )`.
        #
        #   Example:
        #
        #   * Row keys := `["a", "apple", "custom", "customer_1", "customer_2", "other", "zz"]`
        #   * initial_split_keys := `["apple", "customer_1", "customer_2", "other"]`
        #   * Key assignment:
        #     * Tablet 1 : `[, apple)                => {"a"}`
        #     * Tablet 2 : `[apple, customer_1)      => {"apple", "custom"}`
        #     * Tablet 3 : `[customer_1, customer_2) => {"customer_1"}`
        #     * Tablet 4 : `[customer_2, other)      => {"customer_2"}`
        #     * Tablet 5 : `[other, )                => {"other", "zz"}`
        # @yield [column_families] A block for adding column families.
        # @yieldparam [Google::Cloud::Bigtable::ColumnFamilyMap] column_families
        #   A mutable object containing the column families for the table,
        #   mapped by column family name.
        #
        # @return [Google::Cloud::Bigtable::Table]
        #
        # @example Create a table without column families.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.create_table "my-instance", "my-table"
        #   puts table.name
        #
        # @example Create a table with initial splits and column families.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   initial_splits = ["user-00001", "user-100000", "others"]
        #   table = bigtable.create_table "my-instance", "my-table", initial_splits: initial_splits do |cfm|
        #     cfm.add "cf1", gc_rule: Google::Cloud::Bigtable::GcRule.max_versions(5)
        #     cfm.add "cf2", gc_rule: Google::Cloud::Bigtable::GcRule.max_age(600)
        #
        #     gc_rule = Google::Cloud::Bigtable::GcRule.union(
        #       Google::Cloud::Bigtable::GcRule.max_age(1800),
        #       Google::Cloud::Bigtable::GcRule.max_versions(3)
        #     )
        #     cfm.add "cf3", gc_rule: gc_rule
        #   end
        #
        #   puts table
        #
        def create_table instance_id, table_id, column_families: nil, granularity: nil, initial_splits: nil, &block
          ensure_service!
          Table.create(
            service,
            instance_id,
            table_id,
            column_families: column_families,
            granularity:     granularity,
            initial_splits:  initial_splits,
            &block
          )
        end

        ##
        # Permanently deletes the specified table and all of its data.
        #
        # @param instance_id [String]
        #  The unique ID of the instance the table is in.
        # @param table_id [String]
        #   The unique ID of the table to be deleted.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   bigtable.delete_table "my-instance", "my-table"
        #
        def delete_table instance_id, table_id
          service.delete_table instance_id, table_id
          true
        end

        ##
        # Creates a copy of the backup at the desired location. Copy of the backup won't be created
        # if the backup is already a copied one.
        #
        # @param dest_project_id [String] Existing project ID. Copy of the backup
        #   will be created in this project. Required.
        # @param dest_instance_id [Instance, String] Existing instance ID. Copy
        #   of the backup will be created in this instance. Required.
        # @param dest_cluster_id [String] Existing cluster ID. Copy of the backup
        #   will be created in this cluster. Required.
        # @param new_backup_id [String] The id of the copy of the backup to be created. This string must
        #   be between 1 and 50 characters in length and match the regex
        #   `[_a-zA-Z0-9][-_.a-zA-Z0-9]*`. Required.
        # @param source_instance_id [String] Existing instance ID. Backup will be copied from this instance. Required.
        # @param source_cluster_id [String] Existing cluster ID. Backup will be copied from this cluster. Required.
        # @param source_backup_id [Instance, String] Existing backup ID. This backup will be copied. Required.
        # @param expire_time [Time] The expiration time of the copy of the backup, with microseconds
        #   granularity that must be at least 6 hours and at most 30 days from the time the request
        #   is received. Once the `expire_time` has passed, Cloud Bigtable will delete the backup
        #   and free the resources used by the backup. Required.
        #
        # @return [Google::Cloud::Bigtable::Backup::Job] The job representing the long-running, asynchronous
        #   processing of a copy backup operation.
        #
        # @example Create a copy of the specified backup at a specific location
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   job = bigtable.copy_backup dest_project_id:"my-project-2",
        #                              dest_instance_id:"my-instance-2",
        #                              dest_cluster_id:"my-cluster-2",
        #                              new_backup_id:"my-backup-2",
        #                              source_instance_id:"my-instance",
        #                              source_cluster_id:"my-cluster",
        #                              source_backup_id:"my-backup",
        #                              expire_time: Time.now + 60 * 60 * 7
        #
        #   job.wait_until_done!
        #   job.done? #=> true
        #
        #   if job.error?
        #     status = job.error
        #   else
        #     backup = job.backup
        #   end
        #
        def copy_backup dest_project_id:, dest_instance_id:, dest_cluster_id:, new_backup_id:,
                        source_instance_id:, source_cluster_id:, source_backup_id:, expire_time:
          ensure_service!
          grpc = service.copy_backup project_id: dest_project_id,
                                     instance_id: dest_instance_id,
                                     cluster_id: dest_cluster_id,
                                     backup_id: new_backup_id,
                                     source_backup: service.backup_path(source_instance_id,
                                                                        source_cluster_id,
                                                                        source_backup_id),
                                     expire_time: expire_time
          Backup::Job.from_grpc grpc, service
        end

        protected

        # @private
        #
        # Raise an error unless an active connection to the service is
        # available.
        def ensure_service!
          raise "Must have active connection to service" unless service
        end
      end
    end
  end
end
