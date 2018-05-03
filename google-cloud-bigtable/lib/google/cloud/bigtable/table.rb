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
require "google/cloud/bigtable/snapshot"

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
      #   # Get snapshots
      #   snapshots = table.snapshots
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

        # The unique identifier for the table.
        #
        # @return [String]
        def name
          @grpc.name.split("/")[5]
        end

        # The full path for the instance resource. Values are of the form
        # `projects/<project_id>/instances/<instance_id>`.
        #
        # @return [String]
        def path
          @grpc.name
        end

        # Map from cluster ID to per-cluster table state.
        # If it could not be determined whether or not the table has data in a
        # particular cluster (for example, if its zone is unavailable), then
        # there will be an entry for the cluster with UNKNOWN `replication_status`.
        # Views: `FULL`
        #
        # @return [Array<Google::Cloud::Bigtable::Table::ClusterState>]
        def cluster_states
          @cluster_states ||= \
            @grpc.cluster_states.map do |name, state_grpc|
              ClusterState.from_grpc(state_grpc, name)
            end
        end

        # The column families configured for this table, mapped by column family ID.
        # Available column families data only in table view types: `SCHEMA_VIEW`, `FULL`
        #
        #  See to delete column family {Google::Cloud::Bigtable::ColumnFamily#delete}
        #  update {Google::Cloud::Bigtable::ColumnFamily#update} or create
        #  {Google::Cloud::Bigtable::ColumnFamily#create}
        #
        # @return [Array<Google::Bigtable::ColumnFamily>]
        #   (See {Google::Cloud::Bigtable::ColumnFamily::List})
        #
        def column_families
          @column_families ||= ColumnFamily::List.from_grpc(
            @grpc.column_families,
            service,
            instance_id: instance_id,
            table_id: name
          )
        end

        # The granularity (e.g. `MILLIS`, `MICROS`) at which timestamps are stored in
        # this table. Timestamps not matching the granularity will be rejected.
        # If unspecified at creation time, the value will be set to `MILLIS`.
        # Views: `SCHEMA_VIEW`, `FULL`
        #
        # @return [Symbol]
        def granularity
          @grpc.granularity
        end

        # The table keeps data versioned at a granularity of 1ms.
        #
        # @return [Boolean]
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

        # Delete all rows
        #
        # @param timeout [Integer] Call timeout in seconds
        #   Use in case of : Insufficient deadline for DropRowRange then
        #   try again with a longer request deadline.
        # @return [Boolean]
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #   table = instance.table("my-table")
        #   table.delete_all_rows
        #
        #   # With timeout
        #   table.delete_all_rows(timeout: 120) # 120 seconds.
        #
        def delete_all_rows timeout: nil
          drop_row_range(delete_all_data: true, timeout: timeout)
        end

        # Delete rows using row key prefix.
        #
        # @param prefix [String] Row key prefix. i.e "user"
        # @param timeout [Integer] Call timeout in seconds
        # @return [Boolean]
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #   table = instance.table("my-table")
        #   table.delete_rows_by_prefix("user-100")
        #
        #   # With timeout
        #   table.delete_all_rows("user-1", timeout: 120) # 120 seconds.
        #
        def delete_rows_by_prefix prefix, timeout: nil
          drop_row_range(row_key_prefix: prefix, timeout: timeout)
        end

        # Drop row range by row key prefix or delete all.
        #
        # @param row_key_prefix [String] Row key prefix. i.e "user"
        # @param delete_all_data [Boolean]
        # @return [Boolean]
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #   table = instance.table("my-table")
        #
        #   # Delete rows using row key prefix.
        #   table.drop_row_range("user-100")
        #
        #   # Delete all data With timeout
        #   table.drop_row_range(delete_all_data: true, timeout: 120) # 120 seconds.
        #
        def drop_row_range \
            row_key_prefix: nil,
            delete_all_data: nil,
            timeout: nil
          ensure_service!
          service.drop_row_range(
            instance_id,
            name,
            row_key_prefix: row_key_prefix,
            delete_all_data_from_table: delete_all_data,
            timeout: timeout
          )
          true
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

        # Creates a new snapshot in the specified cluster from the specified
        # source table. The cluster and the table must be in the same instance.
        #
        # @param snapshot_id [String] The snapshot name by which the new snapshot
        #   should be referred to within the parent cluster.
        # @param cluster_id [String] The name of the cluster where the snapshot will be created in.
        # @param description [String] Description of the snapshot.
        # @param ttl [Integer]  The amount of time in seconds that the new snapshot can stay active after it is
        #   created. Once 'ttl' expires, the snapshot will get deleted. The maximum
        #   amount of time a snapshot can stay active is 7 days. If 'ttl' is not
        #   specified, the default value of 24 hours will be used.
        # @return [Google::Cloud::Bigtable::Snapshot::Job]
        #   The job representing the long-running, asynchronous processing of
        #   an snapshot create operation.
        #
        # @example Create snapshot
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #   table = instance.table("my-table")
        #
        #   job = table.create_snapshot("my-table-snapshot", "my-cluster")
        #
        #   job.done? #=> false
        #   job.reload!
        #   job.done? #=> true
        #
        #   if job.error?
        #     puts job.error
        #   else
        #     snapshot = job.snapshot
        #     puts snapshot.name
        #     puts instance.state
        #   end
        #
        # @example Create snapshot with ttl.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #   table = instance.table("my-table")
        #
        #   job = table.create_snapshot(
        #     "my-table-snapshot",
        #     "my-cluster",
        #     description: "My table snapshot",
        #     ttl: 1800 # 30 minutes
        #   )
        #
        #   job.done? #=> false
        #   job.reload!
        #   job.done? #=> false
        #
        #   # Reload job until completion.
        #   job.wait_until_done
        #   job.done? #=> true
        #
        #   if job.error?
        #     puts job.error
        #   else
        #     snapshot = job.snapshot
        #     puts snapshot.name
        #     puts instance.state
        #   end
        #
        def create_snapshot snapshot_id, cluster_id, description: nil, ttl: nil
          ensure_service!
          grpc = service.snapshot_table(
            instance_id,
            name,
            cluster_id,
            snapshot_id,
            description,
            ttl: Convert.number_to_duration(ttl)
          )
          Snapshot::Job.from_grpc(grpc, service)
        end

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
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #   table = instance.table("my-table")
        #
        #   modifications = []
        #   modifications << Google::Cloud::Bigtable::ColumnFamilyModification.create(
        #     "cf1", Google::Cloud::Bigtable::GcRule.max_age(600))
        #   )
        #
        #   modifications << Google::Cloud::Bigtable::ColumnFamilyModification.update(
        #     "cf2", Google::Cloud::Bigtable::GcRule.max_versions(5)
        #   )
        #
        #   gc_rule_1 = Google::Cloud::Bigtable::GcRule.max_versions(3)
        #   gc_rule_2 = Google::Cloud::Bigtable::GcRule.max_age(600)
        #   modifications << Google::Cloud::Bigtable::ColumnFamilyModification.update(
        #     "cf3", Google::Cloud::Bigtable::GcRule.union(gc_rule_1, gc_rule_2)
        #   )
        #
        #   max_age_gc_rule = Google::Cloud::Bigtable::GcRule.max_age(300)
        #   modifications << Google::Cloud::Bigtable::ColumnFamilyModification.update(
        #     "cf4", Google::Cloud::Bigtable::GcRule.union(max_version_gc_rule)
        #   )
        #
        #   modifications << Google::Cloud::Bigtable::ColumnFamilyModification.drop("cf5")
        #
        #   table = bigtable.modify_column_families(modifications)
        #
        #   puts table.column_families

        def modify_column_families modifications
          ensure_service!
          grpc = service.modify_column_families(
            instance_id,
            name,
            modifications.map(&:to_grpc)
          )
          Table.from_grpc(grpc, service)
        end

        # @private
        # Creates a new Table instance from a Google::Bigtable::Admin::V2::Table.
        #
        # @param grpc [Google::Bigtable::Admin::V2::Table]
        # @param service [Google::Cloud::Bigtable::Service]
        # @return [Google::Cloud::Bigtable::Table]
        #
        def self.from_grpc grpc, service
          new(grpc, service)
        end

        protected

        # @private
        # Raise an error unless an active connection to the service is
        # available.
        #
        def ensure_service!
          raise "Must have active connection to service" unless service
        end
      end
    end
  end
end
