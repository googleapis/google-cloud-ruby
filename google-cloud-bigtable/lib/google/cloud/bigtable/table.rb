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


require "google/cloud/bigtable/table/list"
require "google/cloud/bigtable/table/cluster_state"
require "google/cloud/bigtable/column_family_map"
require "google/cloud/bigtable/gc_rule"
require "google/cloud/bigtable/mutation_operations"
require "google/cloud/bigtable/policy"
require "google/cloud/bigtable/read_operations"

module Google
  module Cloud
    module Bigtable
      ##
      # # Table
      #
      # A collection of user data indexed by row, column, and timestamp.
      # Each table is served using the resources of its parent cluster.
      #
      # @example
      #   require "google/cloud/bigtable"
      #
      #   bigtable = Google::Cloud::Bigtable.new
      #
      #   table = bigtable.table "my-instance", "my-table"
      #
      #   if table.exists?
      #     p "Table exists."
      #   else
      #     p "Table does not exist"
      #   end
      #
      class Table
        # @!parse extend MutationOperations
        include MutationOperations

        # @!parse extend ReadOperations
        include ReadOperations

        # @private
        # The gRPC Service object.
        attr_accessor :service

        # @private
        # The current gRPC resource, for testing only.
        attr_accessor :grpc

        # @private
        # The current loaded_views, for testing only. See #check_view_and_load, below.
        attr_reader :loaded_views

        ##
        # @return [String] App profile ID for request routing.
        #
        attr_accessor :app_profile_id

        # @private
        #
        # Creates a new Table instance.
        def initialize grpc, service, view:, app_profile_id: nil
          @grpc = grpc
          @service = service
          @app_profile_id = app_profile_id
          raise ArgumentError, "view must not be nil" if view.nil?
          @loaded_views = Set[view]
          @service.client path, app_profile_id
        end

        ##
        # The unique identifier for the project to which the table belongs.
        #
        # @return [String]
        #
        def project_id
          @grpc.name.split("/")[1]
        end

        ##
        # The unique identifier for the instance to which the table belongs.
        #
        # @return [String]
        #
        def instance_id
          @grpc.name.split("/")[3]
        end

        ##
        # The unique identifier for the table.
        #
        # @return [String]
        #
        def name
          @grpc.name.split("/")[5]
        end
        alias table_id name

        ##
        # The full path for the table resource. Values are of the form
        # `projects/<project_id>/instances/<instance_id>/table/<table_id>`.
        #
        # @return [String]
        #
        def path
          @grpc.name
        end

        ##
        # Reloads table data with the provided `view`, or with `SCHEMA_VIEW`
        # if none is provided. Previously loaded data is not retained.
        #
        # @param view [Symbol] Table view type.
        #   Default view type is `:SCHEMA_VIEW`.
        #   Valid view types are:
        #
        #   * `:NAME_ONLY` - Only populates `name`.
        #   * `:SCHEMA_VIEW` - Only populates `name` and fields related to the table's schema.
        #   * `:REPLICATION_VIEW` - Only populates `name` and fields related to the table's replication state.
        #   * `:FULL` - Populates all fields.
        #
        # @return [Google::Cloud::Bigtable::Table]
        #
        def reload! view: nil
          view ||= :SCHEMA_VIEW
          @grpc = service.get_table instance_id, name, view: view
          @loaded_views = Set[view]
          self
        end

        ##
        # Returns an array of {Table::ClusterState} objects that map cluster ID
        # to per-cluster table state.
        #
        # If it could not be determined whether or not the table has data in a
        # particular cluster (for example, if its zone is unavailable), then
        # the cluster state's `replication_state` will be `UNKNOWN`.
        #
        # Reloads the table with the `FULL` view type to retrieve the cluster states
        # data, unless the table was previously loaded with view type `ENCRYPTION_VIEW`,
        # `REPLICATION_VIEW` or `FULL`.
        #
        # @return [Array<Google::Cloud::Bigtable::Table::ClusterState>]
        #
        # @example Retrieve a table with cluster states.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.table "my-instance", "my-table", view: :FULL, perform_lookup: true
        #
        #   table.cluster_states.each do |cs|
        #     puts cs.cluster_name
        #     puts cs.replication_state
        #     puts cs.encryption_infos.first.encryption_type
        #   end
        #
        def cluster_states
          check_view_and_load :FULL, skip_if: [:ENCRYPTION_VIEW, :REPLICATION_VIEW]
          @grpc.cluster_states.map do |name, state_grpc|
            ClusterState.from_grpc state_grpc, name
          end
        end

        ##
        # Returns a frozen object containing the column families configured for
        # the table, mapped by column family name.
        #
        # Reloads the table if necessary to retrieve the column families data,
        # since it is only available in a table with view type `SCHEMA_VIEW`
        # or `FULL`. Previously loaded data is retained.
        #
        # Also accepts a block for making modifications to the table's column
        # families. After the modifications are completed, the table will be
        # updated with the changes, and the updated column families will be
        # returned.
        #
        # @see https://cloud.google.com/bigtable/docs/garbage-collection Garbage collection
        #
        # @yield [column_families] A block for modifying the table's column
        #   families. Applies multiple column modifications. Performs a series
        #   of column family modifications on the specified table. Either all or
        #   none of the modifications will occur before this method returns, but
        #   data requests received prior to that point may see a table where
        #   only some modifications have taken effect.
        # @yieldparam [ColumnFamilyMap] column_families
        #   A mutable object containing the column families for the table,
        #   mapped by column family name. Any changes made to this object will
        #   be stored in API.
        #
        # @return [ColumnFamilyMap] A frozen object containing the
        #   column families for the table, mapped by column family name.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.table "my-instance", "my-table", perform_lookup: true
        #
        #   table.column_families.each do |name, cf|
        #     puts name
        #     puts cf.gc_rule
        #   end
        #
        #   # Get a column family by name
        #   cf1 = table.column_families["cf1"]
        #
        # @example Modify the table's column families
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.table "my-instance", "my-table", perform_lookup: true
        #
        #   table.column_families do |cfm|
        #     cfm.add "cf4", gc_rule: Google::Cloud::Bigtable::GcRule.max_age(600)
        #     cfm.add "cf5", gc_rule: Google::Cloud::Bigtable::GcRule.max_versions(5)
        #
        #     rule_1 = Google::Cloud::Bigtable::GcRule.max_versions 3
        #     rule_2 = Google::Cloud::Bigtable::GcRule.max_age 600
        #     rule_union = Google::Cloud::Bigtable::GcRule.union rule_1, rule_2
        #     cfm.update "cf2", gc_rule: rule_union
        #
        #     cfm.delete "cf3"
        #   end
        #
        #   puts table.column_families["cf3"] #=> nil
        #
        def column_families
          check_view_and_load :SCHEMA_VIEW

          if block_given?
            column_families = ColumnFamilyMap.from_grpc @grpc.column_families
            yield column_families
            modifications = column_families.modifications @grpc.column_families
            @grpc = service.modify_column_families instance_id, table_id, modifications if modifications.any?
          end

          ColumnFamilyMap.from_grpc(@grpc.column_families).freeze
        end

        ##
        # The granularity (e.g. `MILLIS`, `MICROS`) at which timestamps are stored in
        # this table. Timestamps not matching the granularity will be rejected.
        # If unspecified at creation time, the value will be set to `MILLIS`.
        #
        # Reloads the table if necessary to retrieve the column families data,
        # since it is only available in a table with view type `SCHEMA_VIEW`
        # or `FULL`. Previously loaded data is retained.
        #
        # @return [Symbol]
        #
        def granularity
          check_view_and_load :SCHEMA_VIEW
          @grpc.granularity
        end

        ##
        # The table keeps data versioned at a granularity of 1 ms.
        #
        # @return [Boolean]
        #
        def granularity_millis?
          granularity == :MILLIS
        end

        ##
        # Gets the [Cloud IAM](https://cloud.google.com/iam/) access control
        # policy for the table.
        #
        # @see https://cloud.google.com/bigtable/docs/access-control
        #
        # @yield [policy] A block for updating the policy. The latest policy
        #   will be read from the Bigtable service and passed to the block. After
        #   the block completes, the modified policy will be written to the
        #   service.
        # @yieldparam [Policy] policy the current Cloud IAM Policy for this
        #   table.
        #
        # @return [Policy] The current Cloud IAM Policy for the table.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.table "my-instance", "my-table", perform_lookup: true
        #   policy = table.policy
        #
        # @example Update the policy by passing a block.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.table "my-instance", "my-table", perform_lookup: true
        #
        #   table.policy do |p|
        #     p.add "roles/owner", "user:owner@example.com"
        #   end # 2 API calls
        #
        def policy
          ensure_service!
          grpc = service.get_table_policy instance_id, name
          policy = Policy.from_grpc grpc
          return policy unless block_given?
          yield policy
          update_policy policy
        end

        ##
        # Updates the [Cloud IAM](https://cloud.google.com/iam/) access control
        # policy for the table. The policy should be read from {#policy}.
        # See {Google::Cloud::Bigtable::Policy} for an explanation of the policy
        # `etag` property and how to modify policies.
        #
        # You can also update the policy by passing a block to {#policy}, which
        # will call this method internally after the block completes.
        #
        # @param new_policy [Policy] a new or modified Cloud IAM Policy for this
        #   table
        #
        # @return [Policy] The policy returned by the API update operation.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.table "my-instance", "my-table", perform_lookup: true
        #
        #   policy = table.policy
        #   policy.add "roles/owner", "user:owner@example.com"
        #   updated_policy = table.update_policy policy
        #
        #   puts updated_policy.roles
        #
        def update_policy new_policy
          ensure_service!
          grpc = service.set_table_policy instance_id, name, new_policy.to_grpc
          Policy.from_grpc grpc
        end
        alias policy= update_policy

        ##
        # Tests the specified permissions against the [Cloud
        # IAM](https://cloud.google.com/iam/) access control policy.
        #
        # @see https://cloud.google.com/iam/docs/managing-policies Managing Policies
        # @see https://cloud.google.com/bigtable/docs/access-control Access Control
        #
        # @param permissions [String, Array<String>] permissions The set of permissions to
        #   check access for. Permissions with wildcards (such as `*` or
        #   `bigtable.*`) are not allowed.
        #   See [Access Control](https://cloud.google.com/bigtable/docs/access-control).
        #
        # @return [Array<String>] The permissions that are configured for the policy.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.table "my-instance", "my-table", perform_lookup: true
        #
        #   permissions = table.test_iam_permissions(
        #     "bigtable.tables.delete",
        #     "bigtable.tables.get"
        #   )
        #   permissions.include? "bigtable.tables.delete" #=> false
        #   permissions.include? "bigtable.tables.get" #=> true
        #
        def test_iam_permissions *permissions
          ensure_service!
          grpc = service.test_table_permissions instance_id, name, permissions.flatten
          grpc.permissions.to_a
        end

        ##
        # Permanently deletes the table from a instance.
        #
        # @return [Boolean] Returns `true` if the table was deleted.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.table "my-instance", "my-table"
        #   table.delete
        #
        def delete
          ensure_service!
          service.delete_table instance_id, name
          true
        end

        ##
        # Checks to see if the table exists.
        #
        # @return [Boolean]
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.table "my-instance", "my-table"
        #
        #   if table.exists?
        #     p "Table exists."
        #   else
        #     p "Table does not exist"
        #   end
        #
        # @example Using Cloud Bigtable instance
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance "my-instance"
        #   table = instance.table "my-table"
        #
        #   if table.exists?
        #     p "Table exists."
        #   else
        #     p "Table does not exist"
        #   end
        #
        def exists?
          !service.get_table(instance_id, name, view: :NAME_ONLY).nil?
        rescue Google::Cloud::NotFoundError
          false
        end

        # @private
        # Creates a table.
        #
        # @param service [Google::Cloud::Bigtable::Service]
        # @param instance_id [String]
        # @param table_id [String]
        # @param column_families [ColumnFamilyMap]
        # @param granularity [Symbol]
        # @param initial_splits [Array<String>]
        # @yield [column_families] A block for adding column_families.
        # @yieldparam [ColumnFamilyMap]
        #
        # @return [Google::Cloud::Bigtable::Table]
        #
        def self.create service, instance_id, table_id, column_families: nil, granularity: nil, initial_splits: nil
          if column_families
            # create an un-frozen and duplicate object
            column_families = ColumnFamilyMap.from_grpc column_families.to_grpc
          end
          column_families ||= ColumnFamilyMap.new

          yield column_families if block_given?

          table = Google::Cloud::Bigtable::Admin::V2::Table.new({
            column_families: column_families.to_grpc_hash,
            granularity:     granularity
          }.compact)

          grpc = service.create_table instance_id, table_id, table, initial_splits: initial_splits
          from_grpc grpc, service, view: :SCHEMA_VIEW
        end

        ##
        # Generates a consistency token for a table. The token can be used in
        # CheckConsistency to check whether mutations to the table that finished
        # before this call started have been replicated. The tokens will be available
        # for 90 days.
        #
        # @return [String] The generated consistency token
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance "my-instance"
        #   table = instance.table "my-table"
        #
        #   table.generate_consistency_token # "l947XelENinaxJQP0nnrZJjHnAF7YrwW8HCJLotwrF"
        #
        def generate_consistency_token
          ensure_service!
          response = service.generate_consistency_token instance_id, name
          response.consistency_token
        end

        ##
        # Checks replication consistency based on a consistency token. Replication is
        # considered consistent if replication has caught up based on the conditions
        # specified in the token and the check request.
        # @param token [String] Consistency token
        # @return [Boolean] `true` if replication is consistent
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance "my-instance"
        #   table = instance.table "my-table"
        #
        #   token = "l947XelENinaxJQP0nnrZJjHnAF7YrwW8HCJLotwrF"
        #
        #   if table.check_consistency token
        #     puts "Replication is consistent"
        #   end
        #
        def check_consistency token
          ensure_service!
          response = service.check_consistency instance_id, name, token
          response.consistent
        end

        ##
        # Wait for replication to check replication consistency.
        # Checks replication consistency by generating a consistency token and
        # making the `check_consistency` API call 5 times (by default).
        # If the response is consistent, returns `true`. Otherwise tries again
        # repeatedly until the timeout. If the check does not succeed by the
        # timeout, returns `false`.
        #
        # @param timeout [Integer]
        #   Timeout in seconds. Defaults value is 600 seconds.
        # @param check_interval [Integer]
        #   Consistency check interval in seconds. Default is 5 seconds.
        # @return [Boolean] `true` if replication is consistent
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.table "my-instance", "my-table", perform_lookup: true
        #
        #   if table.wait_for_replication
        #     puts "Replication done"
        #   end
        #
        #   # With custom timeout and interval
        #   if table.wait_for_replication timeout: 300, check_interval: 10
        #     puts "Replication done"
        #   end
        #
        def wait_for_replication timeout: 600, check_interval: 5
          raise InvalidArgumentError, "'check_interval' cannot be greater than timeout" if check_interval > timeout
          token = generate_consistency_token
          status = false
          start_at = Time.now

          loop do
            status = check_consistency token

            break if status || (Time.now - start_at) >= timeout
            sleep check_interval
          end
          status
        end

        ##
        # Deletes all rows.
        #
        # @param timeout [Integer] Call timeout in seconds.
        #   Use in case of insufficient deadline for DropRowRange, then
        #   try again with a longer request deadline.
        # @return [Boolean]
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance "my-instance"
        #   table = instance.table "my-table"
        #   table.delete_all_rows
        #
        #   # With timeout
        #   table.delete_all_rows timeout: 120 # 120 seconds.
        #
        def delete_all_rows timeout: nil
          drop_row_range delete_all_data: true, timeout: timeout
        end

        ##
        # Deletes rows using row key prefix.
        #
        # @param prefix [String] Row key prefix (for example, "user").
        # @param timeout [Integer] Call timeout in seconds.
        # @return [Boolean]
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.table "my-instance", "my-table"
        #
        #   table.delete_rows_by_prefix "user-100"
        #
        #   # With timeout
        #   table.delete_rows_by_prefix "user-1", timeout: 120 # 120 seconds.
        #
        def delete_rows_by_prefix prefix, timeout: nil
          drop_row_range row_key_prefix: prefix, timeout: timeout
        end

        ##
        # Drops row range by row key prefix or deletes all.
        #
        # @param row_key_prefix [String] Row key prefix (for example, "user").
        # @param delete_all_data [Boolean]
        # @param timeout [Integer] Call timeout in seconds.
        # @return [Boolean]
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.table "my-instance", "my-table"
        #
        #   # Delete rows using row key prefix.
        #   table.drop_row_range row_key_prefix: "user-100"
        #
        #   # Delete all data With timeout
        #   table.drop_row_range delete_all_data: true, timeout: 120 # 120 seconds.
        #
        def drop_row_range row_key_prefix: nil, delete_all_data: nil, timeout: nil
          ensure_service!
          service.drop_row_range(
            instance_id,
            name,
            row_key_prefix:             row_key_prefix,
            delete_all_data_from_table: delete_all_data,
            timeout:                    timeout
          )
          true
        end

        # @private
        # Creates a new Table instance from a Google::Cloud::Bigtable::Admin::V2::Table.
        #
        # @param grpc [Google::Cloud::Bigtable::Admin::V2::Table]
        # @param service [Google::Cloud::Bigtable::Service]
        # @param view [Symbol] View type.
        # @return [Google::Cloud::Bigtable::Table]
        #
        def self.from_grpc grpc, service, view:, app_profile_id: nil
          new grpc, service, view: view, app_profile_id: app_profile_id
        end

        # @private
        # Creates a new Table object from table path.
        #
        # @param path [String] Table path.
        #   Formatted table path
        #   +projects/<project>/instances/<instance>/tables/<table>+
        # @param service [Google::Cloud::Bigtable::Service]
        # @return [Google::Cloud::Bigtable::Table]
        #
        def self.from_path path, service, app_profile_id: nil
          grpc = Google::Cloud::Bigtable::Admin::V2::Table.new name: path
          new grpc, service, view: :NAME_ONLY, app_profile_id: app_profile_id
        end

        protected

        # @private
        # Raises an error unless an active connection to the service is
        # available.
        #
        def ensure_service!
          raise "Must have active connection to service" unless service
        end

        FIELDS_BY_VIEW = {
          SCHEMA_VIEW:      ["granularity", "column_families"],
          ENCRYPTION_VIEW:  ["cluster_states"],
          REPLICATION_VIEW: ["cluster_states"],
          FULL:             ["granularity", "column_families", "cluster_states"]
        }.freeze

        # @private
        #
        # Checks and reloads table with expected view. Performs additive updates to fields specified by the given view.
        # @param view [Symbol] The view type to load. If already loaded, no load is performed.
        # @param skip_if [Symbol] Additional satisfying view types. If already loaded, no load is performed.
        #
        def check_view_and_load view, skip_if: nil
          ensure_service!

          skip = Set.new skip_if
          skip << view
          skip << :FULL
          return if (@loaded_views & skip).any?

          grpc = service.get_table instance_id, table_id, view: view
          @loaded_views << view

          FIELDS_BY_VIEW[view].each do |field|
            case grpc[field]
            when Google::Protobuf::Map
              # Special handling for column_families:
              # Replace contents of existing Map since setting the new Map won't work.
              # See https://github.com/protocolbuffers/protobuf/issues/4969
              @grpc[field].clear
              grpc[field].each { |k, v| @grpc[field][k] = v }
            else
              @grpc[field] = grpc[field]
            end
          end
        end
      end
    end
  end
end
