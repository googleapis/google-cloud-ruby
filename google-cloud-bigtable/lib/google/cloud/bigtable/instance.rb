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


require "google/cloud/bigtable/instance/job"
require "google/cloud/bigtable/instance/list"
require "google/cloud/bigtable/instance/cluster_map"
require "google/cloud/bigtable/app_profile"
require "google/cloud/bigtable/policy"

module Google
  module Cloud
    module Bigtable
      # # Instance
      #
      # Represents a Bigtable instance. Instances are dedicated Bigtable
      # serving and storage resources to be used by Bigtable tables.
      #
      # See {Google::Cloud::Bigtable::Project#instances},
      # {Google::Cloud::Bigtable::Project#instance}, and
      # {Google::Cloud::Bigtable::Project#create_instance}.
      #
      # @example
      #   require "google/cloud/bigtable"
      #
      #   bigtable = Google::Cloud::Bigtable.new
      #
      #   job = bigtable.create_instance(
      #     "my-instance",
      #     "Instance for user data",
      #     type: :DEVELOPMENT,
      #     labels: { "env" => "dev"}
      #   ) do |clusters|
      #     clusters.add("test-cluster", "us-east1-b", nodes: 1)
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
      class Instance
        # @private
        # The gRPC Service object.
        attr_accessor :service

        # @private
        #
        # Creates a new Instance instance.
        def initialize grpc, service
          @grpc = grpc
          @service = service
        end

        # The unique identifier for the project.
        #
        # @return [String]

        def project_id
          @grpc.name.split("/")[1]
        end

        # The unique identifier for the instance.
        #
        # @return [String]

        def instance_id
          @grpc.name.split("/")[3]
        end

        # The descriptive name for this instance as it appears in UIs. Must be
        # unique per project and between 4 and 30 characters in length.
        #
        # @return [String]

        def display_name
          @grpc.display_name
        end

        # Updates the descriptive name for this instance as it appears in UIs.
        # Can be changed at any time, but should be kept globally unique
        # to avoid confusion.
        #
        # @param value [String] The descriptive name for this instance.

        def display_name= value
          @grpc.display_name = value
        end

        # The full path for the instance resource. Values are of the form
        # `projects/<project_id>/instances/<instance_id>`.
        #
        # @return [String]

        def path
          @grpc.name
        end

        # The current instance state. Possible values are `:CREATING`,
        # `:READY`, `:STATE_NOT_KNOWN`.
        #
        # @return [Symbol]

        def state
          @grpc.state
        end

        # The instance has been successfully created and can serve requests
        # to its tables
        #
        # @return [Boolean]

        def ready?
          state == :READY
        end

        # The instance is currently being created, and may be destroyed if the
        # creation process encounters an error.
        #
        # @return [Boolean]

        def creating?
          state == :CREATING
        end

        # Instance type. Possible values are `:DEVELOPMENT`, `:PRODUCTION`,
        # `:TYPE_UNSPECIFIED`
        #
        # @return [Symbol]

        def type
          @grpc.type
        end

        # The instance is meant for development and testing purposes only; it has
        # no performance or uptime guarantees and is not covered by SLA.
        # After a development instance is created, it can be upgraded by
        # updating the instance to type `PRODUCTION`. An instance created
        # as a production instance cannot be changed to a development instance.
        # When creating a development instance, `serve_nodes` on the cluster must
        # not be set.
        #
        # @return [Boolean]

        def development?
          type == :DEVELOPMENT
        end

        # An instance meant for production use. `serve_nodes` must be set
        # on the cluster.
        #
        # @return [Boolean]

        def production?
          type == :PRODUCTION
        end

        # Set instance type.
        #
        # Valid values are `:DEVELOPMENT`, `:PRODUCTION`.
        # If instance already created then After a development instance is
        # created, it can be upgraded by updating the instance to type `PRODUCTION`.
        # An instance created as a production instance cannot be changed to a
        # development instance.
        #
        # @param instance_type [Symbol]

        def type= instance_type
          @grpc.type = instance_type
        end

        # Get instance labels.
        #
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

        def labels
          @grpc.labels
        end

        # Set the Cloud Labels.
        #
        # @param labels [Hash{String=>String}] The Cloud Labels.

        def labels= labels
          labels ||= {}
          @grpc.labels = Google::Protobuf::Map.new(
            :string, :string,
            Hash[labels.map { |k, v| [String(k), String(v)] }]
          )
        end

        # Update instance.
        #
        # Updatable attributes are :
        #   * `display_name` - The descriptive name for this instance.
        #   * `type` -  `:DEVELOPMENT` type instance can be upgraded to `:PRODUCTION` instance.
        #     An instance created as a production instance cannot be changed to a development instance.
        #   * `labels` - Cloud Labels are a flexible and lightweight mechanism for organizing cloud resources.
        #
        # @return [Google::Cloud::Bigtable::Instance::Job]
        #   The job representing the long-running, asynchronous processing of
        #   an instance update operation.
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #   instance.display_name = "My app dev instance"  # Set display name
        #   instance.labels = { env: "dev", data: "users" }
        #   job = instance.save
        #
        #   job.done? #=> false
        #
        #   # Reload job until completion.
        #   job.wait_until_done!
        #   job.done? #=> true
        #
        #   if job.error?
        #     puts job.error
        #   else
        #     instance = job.instance
        #     puts instance.name
        #     puts instance.labels
        #   end

        def save
          ensure_service!
          update_mask = Google::Protobuf::FieldMask.new(
            paths: %w[labels display_name type]
          )
          grpc = service.partial_update_instance(@grpc, update_mask)
          Instance::Job.from_grpc(grpc, service)
        end
        alias update save

        # Reload instance information.
        #
        # @return [Google::Cloud::Bigtable::Instance]

        def reload!
          @grpc = service.get_instance(instance_id)
          self
        end

        # Permanently deletes the instance from a project.
        #
        # @return [Boolean] Returns `true` if the instance was deleted.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #   instance.delete

        def delete
          ensure_service!
          service.delete_instance(instance_id)
          true
        end

        # Lists information about clusters in an instance.
        #
        #  See to delete {Google::Cloud::Bigtable::Cluster#delete} and update
        #  cluster {Google::Cloud::Bigtable::Cluster#save}.
        #
        # @param token [String] The `token` value returned by the last call to
        #   `clusters`; indicates that this is a continuation of a call,
        #   and that the system should return the next page of data.
        # @return [Array<Google::Cloud::Bigtable::Cluster>]
        #  See({Google::Cloud::Bigtable::Cluster::List})
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #
        #   instance.clusters.all do |cluster|
        #     puts cluster.cluster_id
        #   end

        def clusters token: nil
          ensure_service!
          grpc = service.list_clusters(instance_id, token: token)
          Cluster::List.from_grpc(grpc, service, instance_id: instance_id)
        end

        # Gets cluster information.
        #
        #  See to delete {Google::Cloud::Bigtable::Cluster#delete} and update
        #  cluster {Google::Cloud::Bigtable::Cluster#save}.
        #
        # @param cluster_id [String] The unique ID of the requested cluster.
        # @return [Google::Cloud::Bigtable::Cluster, nil]
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #
        #   cluster = instance.cluster("my-instance-cluster")
        #   puts cluster.cluster_id

        def cluster cluster_id
          ensure_service!
          grpc = service.get_cluster(instance_id, cluster_id)
          Cluster.from_grpc(grpc, service)
        rescue Google::Cloud::NotFoundError
          nil
        end

        # Creates a cluster within an instance.
        #
        # @param cluster_id [String]
        #   The ID to be used when referring to the new cluster within its instance,
        #   e.g., just +mycluster+
        # @param location [String]
        #   The location where this cluster's nodes and storage reside. For best
        #   performance, clients should be located as close as possible to this
        #   cluster. Currently only zones are supported.
        #   i.e "us-east-1b"
        # @param nodes [Integer] The number of nodes allocated to this cluster.
        #   More nodes enable higher throughput and more consistent performance.
        # @param storage_type [Symbol] Type of storage type.
        #   The type of storage used by this cluster to serve its
        #   parent instance's tables.
        #   Valid types are:
        #     * `:SSD` - Flash (SSD) storage.
        #     * `:HDD` - Magnetic drive (HDD).
        # @return [Google::Cloud::Bigtable::Cluster::Job]
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #   job = instance.create_cluster(
        #     "my-new-cluster",
        #     "us-east-1b",
        #     nodes: 3,
        #     storage_type: :SSD
        #   )
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
        #     cluster = job.cluster
        #   end

        def create_cluster cluster_id, location, nodes: nil, storage_type: nil
          ensure_service!
          attrs = {
            serve_nodes: nodes,
            default_storage_type: storage_type,
            location: location
          }.delete_if { |_, v| v.nil? }

          cluster = Google::Bigtable::Admin::V2::Cluster.new(attrs)
          grpc = service.create_cluster(instance_id, cluster_id, cluster)
          Cluster::Job.from_grpc(grpc, service)
        end

        # List all tables.
        #
        #  See to delete table {Google::Cloud::Bigtable::Table#delete} and update
        #  table {Google::Cloud::Bigtable::Table#save}.
        #
        # @return [Array<Google::Cloud::Bigtable::Table>]
        #   (See {Google::Cloud::Bigtable::Table::List})
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #
        #   # Default name only view
        #   instance.tables.all do |table|
        #     puts table.name
        #   end
        #
        #   # Full view
        #   instance.tables(view: :FULL).all do |table|
        #     puts table.name
        #     puts table.column_families
        #   end
        #
        def tables
          ensure_service!
          grpc = service.list_tables(instance_id)
          Table::List.from_grpc(grpc, service)
        end

        # Get metadata information of table.
        #
        # @param view [Symbol]
        #   The view to be applied to the returned tables' fields
        #   Defaults to `SCHEMA_VIEW` if unspecified.
        #   Valid view types are.
        #   * `:NAME_ONLY` - Only populates `name`
        #   * `:SCHEMA_VIEW` - Only populates `name` and fields related to the table's schema
        #   * `:REPLICATION_VIEW` - Only populates `name` and fields related to the table's replication state.
        #   * `:FULL` - Populates all fields
        # @param perform_lookup [Boolean] Create table object without verifying
        #   that the table resource exists.
        #   Calls made on this object will raise errors if the table.
        #   does not exist. Default value is `false`. Optional.
        #   It helps to reduce admin apis calls.
        # @param app_profile_id [String] The unique identifier for the app profile. Optional.
        #   It is used only in data operations.
        #   This value specifies routing for replication. If not specified, the
        #   "default" application profile will be used.
        # @return [Google::Cloud::Bigtable::Table]
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #
        #   # Default view is full view
        #   table = instance.table("my-table", perform_lookup: true)
        #   puts table.name
        #   puts table.column_families
        #
        #   # Name only view
        #   table = instance.table("my-table", view: :NAME_ONLY, perform_lookup: true)
        #   puts table.name
        #
        # @example  Mutate rows
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.table("my-instance", "my-table")
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

        #
        def table table_id, view: nil, perform_lookup: nil, app_profile_id: nil
          ensure_service!

          table = if perform_lookup
                    grpc = service.get_table(instance_id, table_id, view: view)
                    Table.from_grpc(grpc, service, view: view)
                  else
                    Table.from_path(
                      service.table_path(instance_id, table_id),
                      service
                    )
                  end

          table.app_profile_id = app_profile_id
          table
        rescue Google::Cloud::NotFoundError
          nil
        end

        # Create table
        #
        # The table can be created with a full set of initial column families,
        # specified in the request.
        #
        # @param name [String]
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
        #   * Row keys := +["a", "apple", "custom", "customer_1", "customer_2",+
        #     +"other", "zz"]+
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
        #   Cluster map of cluster name and cluster object.
        #   (See {Google::Cloud::Bigtable::Instance::ClusterMap})
        #   GC Rules for column family see {Google::Cloud::Bigtable::GcRule})
        #
        # @return [Google::Cloud::Bigtable::Table]
        #
        # @example Create table without column families.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #
        #   table = instance.create_table("my-table")
        #   puts table.name
        #
        # @example Create table with column families and initial splits.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #
        #   table = instance.create_table(my-table") do |column_families|
        #     column_families.add('cf1', Google::Cloud::Bigtable::GcRule.max_versions(3))
        #     column_families.add('cf2', Google::Cloud::Bigtable::GcRule.max_age(100))
        #
        #     gc_rule = Google::Cloud::Bigtable::GcRule.new
        #     gc_rule.union = [
        #       Google::Cloud::Bigtable::GcRule.max_versions(3),
        #        Google::Cloud::Bigtable::GcRule.max_age(1800),
        #     ]
        #     column_families.add('cf3', gc_rule)
        #   end
        #
        #   puts table

        def create_table \
            name,
            column_families: nil,
            granularity: nil,
            initial_splits: nil,
            &block
          ensure_service!
          Table.create(
            service,
            instance_id,
            name,
            column_families: column_families,
            granularity: granularity,
            initial_splits: initial_splits,
            &block
          )
        end

        # Create app profile of instance with routing policy.
        # Only one routing policy can applied to app profile. It can be
        # multi cluster routing or single cluster routing
        #
        # @param name [String] Unique Id of the app profile
        # @param routing_policy [Google::Bigtable::Admin::V2::AppProfile::SingleClusterRouting | Google::Bigtable::Admin::V2::AppProfile::MultiClusterRoutingUseAny]
        #   The routing policy for all read/write requests which use this app profile.
        #   A value must be explicitly set.
        #
        #   Routing Policies:
        #   * `multi_cluster_routing` - Read/write requests may be routed to any
        #     cluster in the instance, and will fail over to another cluster in the event
        #     of transient errors or delays. Choosing this option sacrifices
        #     read-your-writes consistency to improve availability.
        #   * `single_cluster_routing` - Unconditionally routes all read/write requests
        #     to a specific cluster. This option preserves read-your-writes consistency,
        #     but does not improve availability.
        #     Value contain `cluster_id` and optional field `allow_transactional_writes`.
        # @param description [String] Description of the use case for this AppProfile
        # @param etag [String]
        #   Strongly validated etag for optimistic concurrency control. Preserve the
        #   value returned from `GetAppProfile` when calling `UpdateAppProfile` to
        #   fail the request if there has been a modification in the mean time. The
        #   `update_mask` of the request need not include `etag` for this protection
        #   to apply.
        #   See [Wikipedia](https://en.wikipedia.org/wiki/HTTP_ETag) and
        #   [RFC 7232](https://tools.ietf.org/html/rfc7232#section-2.3) for more details.
        # @param ignore_warnings [Boolean]
        #   If true, ignore safety checks when creating the app profile.
        #   Default value is `false`
        # @return [Google::Cloud::Bigtable::AppProfile]
        #
        # @example Create app profile with single cluster routing policy
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #
        #   routing_policy = Google::Cloud::Bigtable::AppProfile.single_cluster_routing(
        #     "my-instance-cluster-1"
        #     allow_transactional_writes: true
        #   )
        #
        #   app_profile = instance.create_app_profile(
        #     "my-app-profile",
        #     routing_policy: routing_policy,
        #     description: "App profile for user data instance"
        #   )
        #   puts app_profile.name
        #
        # @example Create app profile with multi cluster routing policy
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #
        #   routing_policy = Google::Cloud::Bigtable::AppProfile.multi_cluster_routing
        #
        #   app_profile = instance.create_app_profile(
        #     "my-app-profile",
        #     routing_policy,
        #     description: "App profile for user data instance"
        #   )
        #   puts app_profile.name
        #
        # @example Create app profile and ignore warnings.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #
        #   routing_policy = Google::Cloud::Bigtable::AppProfile.multi_cluster_routing
        #
        #   app_profile = instance.create_app_profile(
        #     "my-app-profile",
        #     routing_policy,
        #     description: "App profile for user data instance",
        #     ignore_warnings: true
        #   )
        #   puts app_profile.name

        def create_app_profile \
            name,
            routing_policy,
            description: nil,
            etag: nil,
            ignore_warnings: false
          ensure_service!

          if routing_policy.is_a?(Google::Bigtable::Admin::V2::AppProfile:: \
              MultiClusterRoutingUseAny)
            multi_cluster_routing = routing_policy
          else
            single_cluster_routing = routing_policy
          end

          app_profile_attrs = {
            multi_cluster_routing_use_any: multi_cluster_routing,
            single_cluster_routing: single_cluster_routing,
            description: description,
            etag: etag
          }.delete_if { |_, v| v.nil? }

          grpc = service.create_app_profile(
            instance_id,
            name,
            Google::Bigtable::Admin::V2::AppProfile.new(app_profile_attrs),
            ignore_warnings: ignore_warnings
          )
          AppProfile.from_grpc(grpc, service)
        end

        # Get app profile.
        #
        #  See to delete app_profile {Google::Cloud::Bigtable::AppProfile#delete} and update
        #  app_profile {Google::Cloud::Bigtable::AppProfile#save}.
        #
        # @param app_profile_id [String] The unique name of the requested app profile.
        # @return [Google::Cloud::Bigtable::AppProfile, nil]
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #
        #   app_profile = instance.app_profile("my-app-profile")
        #
        #   if app_profile
        #     puts app_profile.name
        #   end

        def app_profile app_profile_id
          ensure_service!
          grpc = service.get_app_profile(instance_id, app_profile_id)
          AppProfile.from_grpc(grpc, service)
        rescue Google::Cloud::NotFoundError
          nil
        end

        # List all app profiles
        #
        #  See to delete app_profile {Google::Cloud::Bigtable::AppProfile#delete} and update
        #  app_profile {Google::Cloud::Bigtable::AppProfile#save}.
        #
        # @return [Array<Google::Cloud::Bigtable::AppProfile>]
        #  (See {Google::Cloud::Bigtable::AppProfile::List})
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #
        #   instance.app_profiles.all do |app_profile|
        #     puts app_profile.name
        #   end

        def app_profiles
          ensure_service!
          grpc = service.list_app_profiles(instance_id)
          AppProfile::List.from_grpc(grpc, service)
        end

        # Gets the [Cloud IAM](https://cloud.google.com/iam/) access control
        # policy for this instance.
        #
        # @see https://cloud.google.com/bigtable/docs/access-control
        #
        # @yield [policy] A block for updating the policy. The latest policy
        #   will be read from the Bigtable service and passed to the block. After
        #   the block completes, the modified policy will be written to the
        #   service.
        # @yieldparam [Policy] policy the current Cloud IAM Policy for this
        #   instance
        #
        # @return [Policy] The current Cloud IAM Policy for this instance.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #   policy = instance.policy
        #
        # @example Update the policy by passing a block:
        #   require "google/cloud/spanner"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   instance = bigtable.instance("my-instance")
        #
        #   instance.policy do |p|
        #     p.add("roles/owner", "user:owner@example.com")
        #   end # 2 API calls

        def policy
          ensure_service!
          grpc = service.get_instance_policy(instance_id)
          policy = Policy.from_grpc(grpc)
          return policy unless block_given?
          yield policy
          update_policy policy
        end

        # Updates the [Cloud IAM](https://cloud.google.com/iam/) access control
        # policy for this instance. The policy should be read from {#policy}.
        # See {Google::Cloud::Bigtable::Policy} for an explanation of the policy
        # `etag` property and how to modify policies.
        #
        # You can also update the policy by passing a block to {#policy}, which
        # will call this method internally after the block completes.
        #
        # @param new_policy [Policy] a new or modified Cloud IAM Policy for this
        #   instance
        #
        # @return [Policy] The policy returned by the API update operation.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #
        #   policy = instance.policy
        #   policy.add("roles/owner", "user:owner@example.com")
        #   updated_policy = instance.update_policy(policy)
        #
        #   puts update_policy.roles

        def update_policy new_policy
          ensure_service!
          grpc = service.set_instance_policy(instance_id, new_policy.to_grpc)
          Policy.from_grpc(grpc)
        end
        alias policy= update_policy

        # Tests the specified permissions against the [Cloud
        # IAM](https://cloud.google.com/iam/) access control policy.
        #
        # @see https://cloud.google.com/iam/docs/managing-policies Managing
        #   Policies
        #
        # @param permissions [String, Array<String>] permissions The set of permissions to
        #   check access for. Permissions with wildcards (such as `*` or
        #   `bigtable.*`) are not allowed.
        #   See (https://cloud.google.com/bigtable/docs/access-control)
        #
        #   Some of the permissions that can be checked on a instance are:
        #   * bigtable.instances.create
        #   * bigtable.instances.list
        #   * bigtable.instances.get
        #   * bigtable.tables.create
        #   * bigtable.tables.delete
        #   * bigtable.tables.get
        #   * bigtable.tables.list
        #
        # @return [Array<Strings>] The permissions that have access.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #
        #   permissions = bigtable.test_permissions(
        #     "bigtable.instances.get",
        #     "bigtable.instances.update"
        #   )
        #   permissions.include? "bigtable.instances.get" #=> true
        #   permissions.include? "bigtable.instances.update" #=> false

        def test_iam_permissions *permissions
          ensure_service!
          grpc = service.test_instance_permissions(
            instance_id,
            Array(permissions).flatten
          )
          grpc.permissions
        end

        # @private
        #
        # Creates a new Instance instance from a
        # Google::Bigtable::Admin::V2::Instance.
        #
        # @param grpc [Google::Bigtable::Admin::V2::Instance]
        # @param service [Google::Cloud::Bigtable::Service]
        # @return [Google::Cloud::Bigtable::Instance]

        def self.from_grpc grpc, service
          new(grpc, service)
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
