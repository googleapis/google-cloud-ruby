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

module Google
  module Cloud
    module Bigtable
      # # Project
      #
      # Projects are top-level containers in Google Cloud Platform. They store
      # information about billing and authorized users, and they contain
      # Cloud Bigtable data. Each project has a friendly name and a unique ID.
      #
      # Google::Cloud::Bigtable::Project is the main object for interacting with
      # Cloud Bigtable.
      #
      # {Google::Cloud::Bigtable::Cluster}, {Google::Cloud::Bigtable::Instance}
      # objects are created, accessed, and managed by Google::Cloud::Bigtable::Project.
      #
      # See {Google::Cloud::Bigtable.new} and {Google::Cloud#bigtable}.
      #
      # @example Obtaining an instance and the clusters from a project.
      #   require "google/cloud"
      #
      #   bigtable = Google::Cloud::Bigtable.new
      #
      #   instance = bigtable.instance("my-instance")
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

        # The identifier for the Cloud Bigtable project.
        #
        # @return [String] Project id.
        #
        # @example
        #   require "google/cloud"
        #
        #   bigtable = Google::Cloud::Bigtable.new(
        #     project_id: "my-project",
        #     credentials: "/path/to/keyfile.json"
        #   )
        #
        #   bigtable.project_id #=> "my-project"

        def project_id
          ensure_service!
          service.project_id
        end

        # Retrieves the list of Bigtable instances for the project.
        #
        # @param token [String] The `token` value returned by the last call to
        #   `instances`; indicates that this is a continuation of a call,
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

        def instances token: nil
          ensure_service!
          grpc = service.list_instances(token: token)
          Instance::List.from_grpc(grpc, service)
        end

        # Get existing Bigtable instance.
        #
        # @param instance_id [String] Existing instance id.
        # @return [Google::Cloud::Bigtable::Instance, nil]
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #
        #   if instance
        #     puts instance.instance_id
        #   end

        def instance instance_id
          ensure_service!
          grpc = service.get_instance(instance_id)
          Instance.from_grpc(grpc, service)
        rescue Google::Cloud::NotFoundError
          nil
        end

        # Create a Bigtable instance.
        #
        # @see https://cloud.google.com/compute/docs/regions-zones for cluster zone locations
        #
        # @param instance_id [String] The unique identifier for the instance,
        #   which cannot be changed after the instance is created. Values are of
        #   the form `[a-z][-a-z0-9]*[a-z0-9]` and must be between 6 and 30
        #   characters in length. Required.
        # @param display_name [String] The descriptive name for this instance as it
        #   appears in UIs. Must be unique per project and between 4 and 30
        #   characters in length.
        # @param type [Symbol] The type of the instance.
        #   Valid values are `:DEVELOPMENT` or `:PRODUCTION`.
        #   Default `:PRODUCTION` instance will created if left blank.
        # @param labels [Hash{String=>String}] labels Cloud Labels are a flexible and lightweight
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
        # @param clusters [Hash{String => Google::Cloud::Bigtable::Cluster}]
        #   (See {Google::Cloud::Bigtable::Instance::ClusterMap})
        #   If passed as an empty use code block to add clusters.
        #   Minimum one cluster must be specified.
        # @yield [clusters] A block for adding clusters.
        # @yieldparam [Hash{String => Google::Cloud::Bigtable::Cluster}]
        #   Cluster map of cluster name and cluster object.
        #   (See {Google::Cloud::Bigtable::Instance::ClusterMap})
        # @return [Google::Cloud::Bigtable::Instance::Job]
        #   The job representing the long-running, asynchronous processing of
        #   an instance create operation.
        #
        # @example Create development instance.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   job = bigtable.create_instance(
        #     "my-instance",
        #     display_name: "Instance for user data",
        #     type: :DEVELOPMENT,
        #     labels: { "env" => "dev"}
        #   ) do |clusters|
        #     clusters.add("test-cluster", "us-east1-b", nodes: 1)
        #   end
        #
        #   job.done? #=> false
        #
        #   # Reload job until completion.
        #   job.wait_until_done
        #   job.done? #=> true
        #
        #   if job.error?
        #     status = job.error
        #   else
        #     instance = job.instance
        #   end
        #
        # @example Create production instance.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   job = bigtable.create_instance(
        #     "my-instance",
        #     display_name: "Instance for user data",
        #     labels: { "env" => "dev"}
        #   ) do |clusters|
        #     clusters.add("test-cluster", "us-east1-b", nodes: 3, storage_type: :SSD)
        #   end
        #
        #   job.done? #=> false
        #
        #   # To block until the operation completes.
        #   job.wait_until_done
        #   job.done? #=> true
        #
        #   if job.error?
        #     status = job.error
        #   else
        #     instance = job.instance
        #   end

        def create_instance \
            instance_id,
            display_name: nil,
            type: nil,
            labels: nil,
            clusters: nil
          labels = Hash[labels.map { |k, v| [String(k), String(v)] }] if labels

          instance_attrs = {
            display_name: display_name,
            type: type,
            labels: labels
          }.delete_if { |_, v| v.nil? }
          instance = Google::Bigtable::Admin::V2::Instance.new(instance_attrs)
          clusters ||= Instance::ClusterMap.new
          yield clusters if block_given?

          clusters.each_value do |cluster|
            unless cluster.location == "".freeze
              cluster.location = service.location_path(cluster.location)
            end
          end

          grpc = service.create_instance(
            instance_id,
            instance,
            clusters.to_h
          )
          Instance::Job.from_grpc(grpc, service)
        end

        # List all clusters in project.
        #
        # @param token [String] The `token` value returned by the last call to
        #   `clusters`; indicates that this is a continuation of a call,
        #   and that the system should return the next page of data.
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

        def clusters token: nil
          ensure_service!
          grpc = service.list_clusters("-", token: token)
          Cluster::List.from_grpc(grpc, service, instance_id: "-")
        end

        # List all tables for given instance.
        #
        # @param instance_id [String] Existing instance Id.
        # @return [Array<Google::Cloud::Bigtable::Table>]
        #   (See {Google::Cloud::Bigtable::Table::List})
        #
        # @example Get tables
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   bigtable.tables("my-instance").all do |table|
        #     puts table.name
        #     puts table.column_families
        #   end

        def tables instance_id
          ensure_service!
          grpc = service.list_tables(instance_id)
          Table::List.from_grpc(grpc, service)
        end

        # Get table information.
        #
        #
        # @param instance_id [String] Existing instance Id.
        # @param table_id [String] Existing table Id.
        # @param view [Symbol] Optional. Table view type. Default `:SCHEMA_VIEW`
        #   Valid view types are.
        #   * `:NAME_ONLY` - Only populates `name`
        #   * `:SCHEMA_VIEW` - Only populates `name` and fields related to the table's schema
        #   * `:REPLICATION_VIEW` - Only populates `name` and fields related to the table's replication state.
        #   * `:FULL` - Populates all fields
        # @param skip_lookup [Boolean] Create table object without verifying
        #   that the table resource exists.
        #   Calls made on this object will raise errors if the table.
        #   does not exist. Default is `false`. Optional.
        #   It helps to reduce admin apis calls.
        # @param app_profile_id [String] The unique identifier for the app profile. Optional.
        #   It is used only in data operations.
        #   This value specifies routing for replication. If not specified, the
        #   "default" application profile will be used.
        # @return [Google::Cloud::Bigtable::Table, nil]
        #
        # @example Get table with schema only view
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.table("my-instance", "my-table")
        #   if table
        #     p table.name
        #     p table.column_families
        #   end
        #
        # @example Get table with all fields. Clusters states, column families
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.table("my-instance", "my-table", view: :FULL)
        #   if table
        #     puts table.name
        #     p table.column_families
        #     p table.cluster_states
        #   end
        #
        # @example Mutate rows
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.table("my-instance", "my-table", skip_lookup: true)
        #
        #   entry = table.new_mutation_entry("user-1")
        #   entry.set_cell(
        #     "cf-1",
        #     "field-1",
        #     "XYZ"
        #     timestamp: Time.now.to_i * 1000 # Time stamp in milli seconds.
        #   ).delete_from_column("cf2", "field02")
        #
        #   table.mutate_row(entry)

        def table \
            instance_id,
            table_id,
            view: nil,
            skip_lookup: nil,
            app_profile_id: nil
          ensure_service!

          if skip_lookup
            table = Table.from_path(
              service.table_path(instance_id, table_id),
              service
            )
            table.app_profile_id = app_profile_id
            return table
          end

          grpc = service.get_table(instance_id, table_id, view: view)
          Table.from_grpc(grpc, service, view: view)
        rescue Google::Cloud::NotFoundError
          nil
        end

        # Creates a new table in the specified instance.
        # The table can be created with a full set of initial column families,
        # specified in the request.
        #
        # @param instance_id [String]
        #   The unique Id of the instance in which to create the table.
        # @param table_id [String]
        #   The name by which the new table should be referred to within the parent
        #   instance, e.g., +foobar+
        # @param column_families [Hash{String => Google::Cloud::Bigtable::ColumnFamily}]
        #   (See {Google::Cloud::Bigtable::Table::ColumnFamilyMap})
        #   If passed as an empty use code block to add column families.
        # @param granularity [Symbol]
        #   The granularity at which timestamps are stored in this table.
        #   Timestamps not matching the granularity will be rejected.
        #   Valid values are `:MILLIS`.
        #   If unspecified, the value will be set to `:MILLIS`
        # @param initial_splits [Array<String>]
        #   The optional list of row keys that will be used to initially split the
        #   table into several tablets (tablets are similar to HBase regions).
        #   Given two split keys, +s1+ and +s2+, three tablets will be created,
        #   spanning the key ranges: +[, s1), [s1, s2), [s2, )+.
        #
        #   Example:
        #
        #   * Row keys := ["a", "apple", "custom", "customer_1", "customer_2",+
        #     +"other", "zz"]
        #   * initial_split_keys := +["apple", "customer_1", "customer_2", "other"]+
        #   * Key assignment:
        #     * Tablet 1 : +[, apple)                => {"a"}.+
        #     * Tablet 2 : +[apple, customer_1)      => {"apple", "custom"}.+
        #     * Tablet 3 : +[customer_1, customer_2) => {"customer_1"}.+
        #     * Tablet 4 : +[customer_2, other)      => {"customer_2"}.+
        #     * Tablet 5 : +[other, )                => {"other", "zz"}.+
        #   A hash of the same form as `Google::Bigtable::Admin::V2::CreateTableRequest::Split`
        #   can also be provided.
        # @yield [column_families] A block for adding column_families.
        # @yieldparam [Hash{String => Google::Cloud::Bigtable::ColumnFamily}]
        #    Map of family name and column family object.
        #   (See {Google::Cloud::Bigtable::Instance::ColumnFamilyMap})
        #   GC Rules for column family see {Google::Cloud::Bigtable::GcRule})
        #
        # @return [Google::Cloud::Bigtable::Table]
        #
        # @example Create table without column family
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.create_table("my-instance", "my-table")
        #   puts table.name
        #
        # @example Create table with column families and initial splits.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   initial_splits = ["user-00001", "user-100000", "others"]
        #   table = bigtable.create_table("my-instance", "my-table", initial_splits: initial_splits) do |column_families|
        #     column_families.add('cf1', Google::Cloud::Bigtable::GcRule.max_versions(5))
        #     column_families.add('cf2', Google::Cloud::Bigtable::GcRule.max_age(600))
        #
        #     gc_rule = Google::Cloud::Bigtable::GcRule.union(
        #       Google::Cloud::Bigtable::GcRule.max_age(1800),
        #       Google::Cloud::Bigtable::GcRule.max_versions(3)
        #     )
        #     column_families.add('cf3', gc_rule)
        #   end
        #
        #   p table

        def create_table \
            instance_id,
            table_id,
            column_families: nil,
            granularity: nil,
            initial_splits: nil,
            &block
          ensure_service!
          Table.create(
            service,
            instance_id,
            table_id,
            column_families: column_families,
            granularity: granularity,
            initial_splits: initial_splits,
            &block
          )
        end

        # Permanently deletes a specified table and all of its data.
        #
        # @param instance_id [String]
        #  The unique Id of the instance in which table is exists.
        # @param table_id [String]
        #   The unique name of the table to be deleted.
        #   e.g., +foobar+
        #
        # @example Create table with column families and initial splits.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   bigtable.delete_table("my-instance", "my-table")
        #
        def delete_table instance_id, table_id
          service.delete_table(instance_id, table_id)
          true
        end

        # Performs a series of column family modifications on the specified table.
        # Either all or none of the modifications will occur before this method
        # returns, but data requests received prior to that point may see a table
        # where only some modifications have taken effect.
        #
        # @param instance_id [String]
        #   The unique Id of the instance in which table is exists.
        # @param table_id [String]
        #   The unique Id of the table whose families should be modified.
        # @param modifications [Array<Google::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification> | Google::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification]
        #   Modifications to be atomically applied to the specified table's families.
        #   Entries are applied in order, meaning that earlier modifications can be
        #   masked by later ones (in the case of repeated updates to the same family,
        #   for example).
        # @return [Google::Cloud::Bigtable::Table] Table with updated column families.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   modifications = []
        #   modifications << Google::Cloud::Bigtable::ColumnFamily.create_modification(
        #     "cf1", Google::Cloud::Bigtable::GcRule.max_age(600))
        #   )
        #
        #   modifications << Google::Cloud::Bigtable::ColumnFamily.update_modification(
        #     "cf2", Google::Cloud::Bigtable::GcRule.max_versions(5)
        #   )
        #
        #   gc_rule_1 = Google::Cloud::Bigtable::GcRule.max_versions(3)
        #   gc_rule_2 = Google::Cloud::Bigtable::GcRule.max_age(600)
        #   modifications << Google::Cloud::Bigtable::ColumnFamily.update_modification(
        #     "cf3", Google::Cloud::Bigtable::GcRule.union(gc_rule_1, gc_rule_2)
        #   )
        #
        #   max_age_gc_rule = Google::Cloud::Bigtable::GcRule.max_age(300)
        #   modifications << Google::Cloud::Bigtable::ColumnFamily.update_modification(
        #     "cf4", Google::Cloud::Bigtable::GcRule.union(max_version_gc_rule)
        #   )
        #
        #   modifications << Google::Cloud::Bigtable::ColumnFamily.drop_modification("cf5")
        #
        #   table = bigtable.modify_column_families("my-instance", "my-table", modifications)
        #
        #   p table.column_families

        def modify_column_families instance_id, table_id, modifications
          ensure_service!
          Table.modify_column_families(
            service,
            instance_id,
            table_id,
            modifications
          )
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
