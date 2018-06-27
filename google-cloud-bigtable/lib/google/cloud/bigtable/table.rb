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
require "google/cloud/bigtable/column_family"
require "google/cloud/bigtable/table/column_family_map"
require "google/cloud/bigtable/gc_rule"

module Google
  module Cloud
    module Bigtable
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
      #   instance = bigtable.instance("my-instance")
      #   table = instance.table("my-table")
      #
      #   table.column_families.each do |cf|
      #     p cf.name
      #     p cf.gc_rule
      #   end
      #
      #   # Get column family by name
      #   cf1 = table.column_families.find_by_name("cf1")
      #
      #   # Create column family
      #   gc_rule = Google::Cloud::Bigtable::GcRule.max_versions(3)
      #   cf2 = table.column_families.create("cf2", gc_rule)
      #
      #   # Delete table
      #   table.delete
      #
      class Table
        # @private
        # The gRPC Service object.
        attr_accessor :service

        # @private
        #
        # Creates a new Table instance.
        def initialize grpc, service, view: nil
          @grpc = grpc
          @service = service
          @view = view || :SCHEMA_VIEW
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

        # The unique identifier for the table.
        #
        # @return [String]
        def name
          @grpc.name.split("/")[5]
        end
        alias table_id name

        # The full path for the instance resource. Values are of the form
        # `projects/<project_id>/instances/<instance_id>`.
        #
        # @return [String]
        def path
          @grpc.name
        end

        # Reload table information.
        #
        # @param view [Symbol] Table view type.
        #   Default view type is `:SCHEMA_VIEW`
        #   Valid view types are.
        #   * `:NAME_ONLY` - Only populates `name`
        #   * `:SCHEMA_VIEW` - Only populates `name` and fields related to the table's schema
        #   * `:REPLICATION_VIEW` - Only populates `name` and fields related to the table's replication state.
        #   * `:FULL` - Populates all fields
        #
        # @return [Google::Cloud::Bigtable::Table]

        def reload! view: nil
          @view = view || :SCHEMA_VIEW
          @grpc = service.get_table(instance_id, name, view: view)
          self
        end

        # Map from cluster ID to per-cluster table state.
        # If it could not be determined whether or not the table has data in a
        # particular cluster (for example, if its zone is unavailable), then
        # there will be an entry for the cluster with UNKNOWN `replication_status`.
        # Views: `FULL`
        #
        # @return [Array<Google::Cloud::Bigtable::Table::ClusterState>]
        def cluster_states
          check_view_and_load(:REPLICATION_VIEW)
          @grpc.cluster_states.map do |name, state_grpc|
            ClusterState.from_grpc(state_grpc, name)
          end
        end

        # The column families configured for this table, mapped by column family ID.
        # Available column families data only in table view types: `SCHEMA_VIEW`, `FULL`
        #
        #
        # @return [Array<Google::Bigtable::ColumnFamily>]
        #
        def column_families
          check_view_and_load(:SCHEMA_VIEW)
          @grpc.column_families.map do |cf_name, cf_grpc|
            ColumnFamily.from_grpc(
              cf_grpc,
              service,
              name: cf_name,
              instance_id: instance_id,
              table_id: table_id
            )
          end
        end

        # The granularity (e.g. `MILLIS`, `MICROS`) at which timestamps are stored in
        # this table. Timestamps not matching the granularity will be rejected.
        # If unspecified at creation time, the value will be set to `MILLIS`.
        # Views: `SCHEMA_VIEW`, `FULL`
        #
        # @return [Symbol]
        #
        def granularity
          check_view_and_load(:SCHEMA_VIEW)
          @grpc.granularity
        end

        # The table keeps data versioned at a granularity of 1ms.
        #
        # @return [Boolean]
        #
        def granularity_millis?
          granularity == :MILLIS
        end

        # Permanently deletes the table from a instance.
        #
        # @return [Boolean] Returns `true` if the table was deleted.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #   table = instance.table("my-table")
        #   table.delete
        #
        def delete
          ensure_service!
          service.delete_table(instance_id, name)
          true
        end

        # Create column family object to perform create,update or delete operation.
        #
        # @param name [String] Name of the column family
        # @param gc_rule [Google::Cloud::Bigtable::GcRule] Optional.
        #   GC Rule only required for create and update.
        #
        # @example Create column family
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.table("my-instance", my-table)
        #
        #   # OR get table from Instance object.
        #   instance = bigtable.instance("my-instance")
        #   table = instance.table("my-table")
        #
        #   gc_rule = Google::Cloud::Bigtable::GcRule.max_versions(5)
        #   column_family = table.column_family("cf1", gc_rule)
        #   column_family.create
        #
        # @example Update column family
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.table("my-instance", my-table)
        #
        #   gc_rule = Google::Cloud::Bigtable::GcRule.max_age(1800)
        #   column_family = table.column_family("cf2", gc_rule)
        #   column_family.save
        #   # OR Using alias method update.
        #   column_family.update
        #
        # @example Delete column family
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.table("my-instance", my-table)
        #
        #   column_family = table.column_family("cf3")
        #   column_family.delete
        #
        def column_family name, gc_rule = nil
          cf_grpc = Google::Bigtable::Admin::V2::ColumnFamily.new
          cf_grpc.gc_rule = gc_rule.to_grpc if gc_rule

          ColumnFamily.from_grpc(
            cf_grpc,
            service,
            name: name,
            instance_id: instance_id,
            table_id: table_id
          )
        end

        # Apply multitple column modifications
        # Performs a series of column family modifications on the specified table.
        # Either all or none of the modifications will occur before this method
        # returns, but data requests received prior to that point may see a table
        # where only some modifications have taken effect.
        #
        # @param modifications [Array<Google::Cloud::Bigtable::ColumnFamilyModification>]
        #   Modifications to be atomically applied to the specified table's families.
        #   Entries are applied in order, meaning that earlier modifications can be
        #   masked by later ones (in the case of repeated updates to the same family,
        #   for example).
        # @return [Google::Cloud::Bigtable::Table] Table with updated column families.
        #
        # @example Apply multiple modificationss
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #   table = instance.table("my-table")
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
        #   table = bigtable.modify_column_families(modifications)
        #
        #   p table.column_families

        def modify_column_families modifications
          ensure_service!
          self.class.modify_column_families(
            service,
            instance_id,
            table_id,
            modifications
          )
        end

        # @private
        #
        # Performs a series of column family modifications on the specified table.
        # Either all or none of the modifications will occur before this method
        # returns, but data requests received prior to that point may see a table
        # where only some modifications have taken effect.
        #
        # @param service [Google::Cloud::Bigtable::Service]
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
        def self.modify_column_families \
            service,
            instance_id,
            table_id,
            modifications
          modifications = [modifications] unless modifications.is_a?(Array)
          grpc = service.modify_column_families(
            instance_id,
            table_id,
            modifications
          )
          from_grpc(grpc, service)
        end

        # @private
        # Creates a table.
        #
        # @param service [Google::Cloud::Bigtable::Service]
        # @param instance_id [String]
        # @param table_id [String]
        # @param column_families [Hash{String => Google::Cloud::Bigtable::ColumnFamily}]
        # @param granularity [Symbol]
        # @param initial_splits [Array<String>]
        # @yield [column_families] A block for adding column_families.
        # @yieldparam [Hash{String => Google::Cloud::Bigtable::ColumnFamily}]
        #
        # @return [Google::Cloud::Bigtable::Table]
        def self.create \
            service,
            instance_id,
            table_id,
            column_families: nil,
            granularity: nil,
            initial_splits: nil
          column_families ||= Table::ColumnFamilyMap.new
          yield column_families if block_given?

          table = Google::Bigtable::Admin::V2::Table.new({
            column_families: column_families.to_h,
            granularity: granularity
          }.delete_if { |_, v| v.nil? })

          grpc = service.create_table(
            instance_id,
            table_id,
            table,
            initial_splits: initial_splits
          )
          from_grpc(grpc, service)
        end

        # Generates a consistency token for a Table, which can be used in
       # CheckConsistency to check whether mutations to the table that finished
       # before this call started have been replicated. The tokens will be available
       # for 90 days.
       #
       # @return [String] Generated consistency token
       #
       # @example
       #   require "google/cloud/bigtable"
       #
       #   bigtable = Google::Cloud::Bigtable.new
       #
       #   instance = bigtable.instance("my-instance")
       #   table = instance.table("my-table")
       #
       #   table.generate_consistency_token # "l947XelENinaxJQP0nnrZJjHnAF7YrwW8HCJLotwrF"
       #
       def generate_consistency_token
         ensure_service!
         response = service.generate_consistency_token(instance_id, name)
         response.consistency_token
       end

       # Checks replication consistency based on a consistency token, that is, if
       # replication has caught up based on the conditions specified in the token
       # and the check request.
       # @param token [String] Consistency token
       # @return [Boolean] Replication is consistent or not.
       #
       # @example
       #   require "google/cloud/bigtable"
       #
       #   bigtable = Google::Cloud::Bigtable.new
       #
       #   instance = bigtable.instance("my-instance")
       #   table = instance.table("my-table")
       #
       #   token = "l947XelENinaxJQP0nnrZJjHnAF7YrwW8HCJLotwrF"
       #
       #   if table.check_consistency(token)
       #     puts "Replication is consistent"
       #   end
       #
       def check_consistency token
         ensure_service!
         response = service.check_consistency(instance_id, name, token)
         response.consistent
       end

       # Wait for replication to check replication consistency of table
       # Checks replication consistency by generating consistency token and
       # calling +check_consistency+ api call 5 times(default).
       # If the response is consistent then return true. Otherwise try again.
       # If consistency checking will run for more than 10 minutes and still
       # not got the +true+ response then return +false+.
       #
       # @param timeout [Integer]
       #   Timeout in seconds. Defaults value is 600 seconds.
       # @param check_interval [Integer]
       #   Consistency check interval in seconds. Default is 5 seconds.
       # @return [Boolean] Replication is consistent or not.
       #
       # @example
       #   require "google/cloud/bigtable"
       #
       #   bigtable = Google::Cloud::Bigtable.new
       #
       #   instance = bigtable.instance("my-instance")
       #   table = instance.table("my-table")
       #
       #   if table.wait_for_replication
       #     puts "Replication done"
       #   end
       #
       #   # With custom timeout and interval
       #   if table.wait_for_replication(timeout: 300, check_interval: 10)
       #     puts "Replication done"
       #   end
       #
       def wait_for_replication timeout: 600, check_interval: 5
         if check_interval > timeout
           raise(
             InvalidArgumentError,
             "'check_interval' can not be greather then timeout"
           )
         end
         token = generate_consistency_token
         status = false
         start_at = Time.now

         loop do
           status = check_consistency(token)

           break if status || (Time.now - start_at) >= timeout
           sleep(check_interval)
         end
         status
       end

        # @private
        # Creates a new Table instance from a Google::Bigtable::Admin::V2::Table.
        #
        # @param grpc [Google::Bigtable::Admin::V2::Table]
        # @param service [Google::Cloud::Bigtable::Service]
        # @param view [Symbol] View type.
        # @return [Google::Cloud::Bigtable::Table]
        #
        def self.from_grpc grpc, service, view: nil
          new(grpc, service, view: view)
        end

        protected

        # @private
        # Raise an error unless an active connection to the service is
        # available.
        #
        def ensure_service!
          raise "Must have active connection to service" unless service
        end

        FIELDS_BY_VIEW = {
          SCHEMA_VIEW: %w[granularity column_families],
          REPLICATION_VIEW: ["cluster_states"],
          FULL: %w[granularity column_families cluster_states]
        }.freeze

        # @private
        #
        # Check and reload table with expected view and set fields
        # @param view [Symbol] Expected view type.
        #
        def check_view_and_load view
          @loaded_views ||= Set.new([@view])

          if @loaded_views.include?(view) || @loaded_views.include?(:FULL)
            return
          end

          grpc = service.get_table(instance_id, table_id, view: view)
          @loaded_views << view

          FIELDS_BY_VIEW[view].each do |field|
            case grpc[field]
            when Google::Protobuf::Map
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
