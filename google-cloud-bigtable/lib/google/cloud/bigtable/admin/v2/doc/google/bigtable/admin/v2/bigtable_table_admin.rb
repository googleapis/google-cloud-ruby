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


module Google
  module Bigtable
    module Admin
      module V2
        # Request message for
        # {Google::Bigtable::Admin::V2::BigtableTableAdmin::CreateTable}
        # @!attribute [rw] parent
        #   @return [String]
        #     The unique name of the instance in which to create the table.
        #     Values are of the form +projects/<project>/instances/<instance>+.
        # @!attribute [rw] table_id
        #   @return [String]
        #     The name by which the new table should be referred to within the parent
        #     instance, e.g., +foobar+ rather than +<parent>/tables/foobar+.
        # @!attribute [rw] table
        #   @return [Google::Bigtable::Admin::V2::Table]
        #     The Table to create.
        # @!attribute [rw] initial_splits
        #   @return [Array<Google::Bigtable::Admin::V2::CreateTableRequest::Split>]
        #     The optional list of row keys that will be used to initially split the
        #     table into several tablets (tablets are similar to HBase regions).
        #     Given two split keys, +s1+ and +s2+, three tablets will be created,
        #     spanning the key ranges: +[, s1), [s1, s2), [s2, )+.
        #
        #     Example:
        #
        #     * Row keys := +["a", "apple", "custom", "customer_1", "customer_2",+
        #       +"other", "zz"]+
        #     * initial_split_keys := +["apple", "customer_1", "customer_2", "other"]+
        #     * Key assignment:
        #       * Tablet 1 +[, apple)                => {"a"}.+
        #         * Tablet 2 +[apple, customer_1)      => {"apple", "custom"}.+
        #         * Tablet 3 +[customer_1, customer_2) => {"customer_1"}.+
        #         * Tablet 4 +[customer_2, other)      => {"customer_2"}.+
        #         * Tablet 5 +[other, )                => {"other", "zz"}.+
        class CreateTableRequest
          # An initial split point for a newly created table.
          # @!attribute [rw] key
          #   @return [String]
          #     Row key to use as an initial tablet boundary.
          class Split; end
        end

        # Request message for
        # {Google::Bigtable::Admin::V2::BigtableTableAdmin::CreateTableFromSnapshot}
        #
        # Note: This is a private alpha release of Cloud Bigtable snapshots. This
        # feature is not currently available to most Cloud Bigtable customers. This
        # feature might be changed in backward-incompatible ways and is not recommended
        # for production use. It is not subject to any SLA or deprecation policy.
        # @!attribute [rw] parent
        #   @return [String]
        #     The unique name of the instance in which to create the table.
        #     Values are of the form +projects/<project>/instances/<instance>+.
        # @!attribute [rw] table_id
        #   @return [String]
        #     The name by which the new table should be referred to within the parent
        #     instance, e.g., +foobar+ rather than +<parent>/tables/foobar+.
        # @!attribute [rw] source_snapshot
        #   @return [String]
        #     The unique name of the snapshot from which to restore the table. The
        #     snapshot and the table must be in the same instance.
        #     Values are of the form
        #     +projects/<project>/instances/<instance>/clusters/<cluster>/snapshots/<snapshot>+.
        class CreateTableFromSnapshotRequest; end

        # Request message for
        # {Google::Bigtable::Admin::V2::BigtableTableAdmin::DropRowRange}
        # @!attribute [rw] name
        #   @return [String]
        #     The unique name of the table on which to drop a range of rows.
        #     Values are of the form
        #     +projects/<project>/instances/<instance>/tables/<table>+.
        # @!attribute [rw] row_key_prefix
        #   @return [String]
        #     Delete all rows that start with this row key prefix. Prefix cannot be
        #     zero length.
        # @!attribute [rw] delete_all_data_from_table
        #   @return [true, false]
        #     Delete all rows in the table. Setting this to false is a no-op.
        class DropRowRangeRequest; end

        # Request message for
        # {Google::Bigtable::Admin::V2::BigtableTableAdmin::ListTables}
        # @!attribute [rw] parent
        #   @return [String]
        #     The unique name of the instance for which tables should be listed.
        #     Values are of the form +projects/<project>/instances/<instance>+.
        # @!attribute [rw] view
        #   @return [Google::Bigtable::Admin::V2::Table::View]
        #     The view to be applied to the returned tables' fields.
        #     Defaults to +NAME_ONLY+ if unspecified; no others are currently supported.
        # @!attribute [rw] page_token
        #   @return [String]
        #     The value of +next_page_token+ returned by a previous call.
        class ListTablesRequest; end

        # Response message for
        # {Google::Bigtable::Admin::V2::BigtableTableAdmin::ListTables}
        # @!attribute [rw] tables
        #   @return [Array<Google::Bigtable::Admin::V2::Table>]
        #     The tables present in the requested instance.
        # @!attribute [rw] next_page_token
        #   @return [String]
        #     Set if not all tables could be returned in a single response.
        #     Pass this value to +page_token+ in another request to get the next
        #     page of results.
        class ListTablesResponse; end

        # Request message for
        # {Google::Bigtable::Admin::V2::BigtableTableAdmin::GetTable}
        # @!attribute [rw] name
        #   @return [String]
        #     The unique name of the requested table.
        #     Values are of the form
        #     +projects/<project>/instances/<instance>/tables/<table>+.
        # @!attribute [rw] view
        #   @return [Google::Bigtable::Admin::V2::Table::View]
        #     The view to be applied to the returned table's fields.
        #     Defaults to +SCHEMA_VIEW+ if unspecified.
        class GetTableRequest; end

        # Request message for
        # {Google::Bigtable::Admin::V2::BigtableTableAdmin::DeleteTable}
        # @!attribute [rw] name
        #   @return [String]
        #     The unique name of the table to be deleted.
        #     Values are of the form
        #     +projects/<project>/instances/<instance>/tables/<table>+.
        class DeleteTableRequest; end

        # Request message for
        # {Google::Bigtable::Admin::V2::BigtableTableAdmin::ModifyColumnFamilies}
        # @!attribute [rw] name
        #   @return [String]
        #     The unique name of the table whose families should be modified.
        #     Values are of the form
        #     +projects/<project>/instances/<instance>/tables/<table>+.
        # @!attribute [rw] modifications
        #   @return [Array<Google::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification>]
        #     Modifications to be atomically applied to the specified table's families.
        #     Entries are applied in order, meaning that earlier modifications can be
        #     masked by later ones (in the case of repeated updates to the same family,
        #     for example).
        class ModifyColumnFamiliesRequest
          # A create, update, or delete of a particular column family.
          # @!attribute [rw] id
          #   @return [String]
          #     The ID of the column family to be modified.
          # @!attribute [rw] create
          #   @return [Google::Bigtable::Admin::V2::ColumnFamily]
          #     Create a new column family with the specified schema, or fail if
          #     one already exists with the given ID.
          # @!attribute [rw] update
          #   @return [Google::Bigtable::Admin::V2::ColumnFamily]
          #     Update an existing column family to the specified schema, or fail
          #     if no column family exists with the given ID.
          # @!attribute [rw] drop
          #   @return [true, false]
          #     Drop (delete) the column family with the given ID, or fail if no such
          #     family exists.
          class Modification; end
        end

        # Request message for
        # {Google::Bigtable::Admin::V2::BigtableTableAdmin::GenerateConsistencyToken}
        # @!attribute [rw] name
        #   @return [String]
        #     The unique name of the Table for which to create a consistency token.
        #     Values are of the form
        #     +projects/<project>/instances/<instance>/tables/<table>+.
        class GenerateConsistencyTokenRequest; end

        # Response message for
        # {Google::Bigtable::Admin::V2::BigtableTableAdmin::GenerateConsistencyToken}
        # @!attribute [rw] consistency_token
        #   @return [String]
        #     The generated consistency token.
        class GenerateConsistencyTokenResponse; end

        # Request message for
        # {Google::Bigtable::Admin::V2::BigtableTableAdmin::CheckConsistency}
        # @!attribute [rw] name
        #   @return [String]
        #     The unique name of the Table for which to check replication consistency.
        #     Values are of the form
        #     +projects/<project>/instances/<instance>/tables/<table>+.
        # @!attribute [rw] consistency_token
        #   @return [String]
        #     The token created using GenerateConsistencyToken for the Table.
        class CheckConsistencyRequest; end

        # Response message for
        # {Google::Bigtable::Admin::V2::BigtableTableAdmin::CheckConsistency}
        # @!attribute [rw] consistent
        #   @return [true, false]
        #     True only if the token is consistent. A token is consistent if replication
        #     has caught up with the restrictions specified in the request.
        class CheckConsistencyResponse; end

        # Request message for
        # {Google::Bigtable::Admin::V2::BigtableTableAdmin::SnapshotTable}
        #
        # Note: This is a private alpha release of Cloud Bigtable snapshots. This
        # feature is not currently available to most Cloud Bigtable customers. This
        # feature might be changed in backward-incompatible ways and is not recommended
        # for production use. It is not subject to any SLA or deprecation policy.
        # @!attribute [rw] name
        #   @return [String]
        #     The unique name of the table to have the snapshot taken.
        #     Values are of the form
        #     +projects/<project>/instances/<instance>/tables/<table>+.
        # @!attribute [rw] cluster
        #   @return [String]
        #     The name of the cluster where the snapshot will be created in.
        #     Values are of the form
        #     +projects/<project>/instances/<instance>/clusters/<cluster>+.
        # @!attribute [rw] snapshot_id
        #   @return [String]
        #     The ID by which the new snapshot should be referred to within the parent
        #     cluster, e.g., +mysnapshot+ of the form: +[_a-zA-Z0-9][-_.a-zA-Z0-9]*+
        #     rather than
        #     +projects/<project>/instances/<instance>/clusters/<cluster>/snapshots/mysnapshot+.
        # @!attribute [rw] ttl
        #   @return [Google::Protobuf::Duration]
        #     The amount of time that the new snapshot can stay active after it is
        #     created. Once 'ttl' expires, the snapshot will get deleted. The maximum
        #     amount of time a snapshot can stay active is 7 days. If 'ttl' is not
        #     specified, the default value of 24 hours will be used.
        # @!attribute [rw] description
        #   @return [String]
        #     Description of the snapshot.
        class SnapshotTableRequest; end

        # Request message for
        # {Google::Bigtable::Admin::V2::BigtableTableAdmin::GetSnapshot}
        #
        # Note: This is a private alpha release of Cloud Bigtable snapshots. This
        # feature is not currently available to most Cloud Bigtable customers. This
        # feature might be changed in backward-incompatible ways and is not recommended
        # for production use. It is not subject to any SLA or deprecation policy.
        # @!attribute [rw] name
        #   @return [String]
        #     The unique name of the requested snapshot.
        #     Values are of the form
        #     +projects/<project>/instances/<instance>/clusters/<cluster>/snapshots/<snapshot>+.
        class GetSnapshotRequest; end

        # Request message for
        # {Google::Bigtable::Admin::V2::BigtableTableAdmin::ListSnapshots}
        #
        # Note: This is a private alpha release of Cloud Bigtable snapshots. This
        # feature is not currently available to most Cloud Bigtable customers. This
        # feature might be changed in backward-incompatible ways and is not recommended
        # for production use. It is not subject to any SLA or deprecation policy.
        # @!attribute [rw] parent
        #   @return [String]
        #     The unique name of the cluster for which snapshots should be listed.
        #     Values are of the form
        #     +projects/<project>/instances/<instance>/clusters/<cluster>+.
        #     Use +<cluster> = '-'+ to list snapshots for all clusters in an instance,
        #     e.g., +projects/<project>/instances/<instance>/clusters/-+.
        # @!attribute [rw] page_size
        #   @return [Integer]
        #     The maximum number of snapshots to return.
        # @!attribute [rw] page_token
        #   @return [String]
        #     The value of +next_page_token+ returned by a previous call.
        class ListSnapshotsRequest; end

        # Response message for
        # {Google::Bigtable::Admin::V2::BigtableTableAdmin::ListSnapshots}
        #
        # Note: This is a private alpha release of Cloud Bigtable snapshots. This
        # feature is not currently available to most Cloud Bigtable customers. This
        # feature might be changed in backward-incompatible ways and is not recommended
        # for production use. It is not subject to any SLA or deprecation policy.
        # @!attribute [rw] snapshots
        #   @return [Array<Google::Bigtable::Admin::V2::Snapshot>]
        #     The snapshots present in the requested cluster.
        # @!attribute [rw] next_page_token
        #   @return [String]
        #     Set if not all snapshots could be returned in a single response.
        #     Pass this value to +page_token+ in another request to get the next
        #     page of results.
        class ListSnapshotsResponse; end

        # Request message for
        # {Google::Bigtable::Admin::V2::BigtableTableAdmin::DeleteSnapshot}
        #
        # Note: This is a private alpha release of Cloud Bigtable snapshots. This
        # feature is not currently available to most Cloud Bigtable customers. This
        # feature might be changed in backward-incompatible ways and is not recommended
        # for production use. It is not subject to any SLA or deprecation policy.
        # @!attribute [rw] name
        #   @return [String]
        #     The unique name of the snapshot to be deleted.
        #     Values are of the form
        #     +projects/<project>/instances/<instance>/clusters/<cluster>/snapshots/<snapshot>+.
        class DeleteSnapshotRequest; end

        # The metadata for the Operation returned by SnapshotTable.
        #
        # Note: This is a private alpha release of Cloud Bigtable snapshots. This
        # feature is not currently available to most Cloud Bigtable customers. This
        # feature might be changed in backward-incompatible ways and is not recommended
        # for production use. It is not subject to any SLA or deprecation policy.
        # @!attribute [rw] original_request
        #   @return [Google::Bigtable::Admin::V2::SnapshotTableRequest]
        #     The request that prompted the initiation of this SnapshotTable operation.
        # @!attribute [rw] request_time
        #   @return [Google::Protobuf::Timestamp]
        #     The time at which the original request was received.
        # @!attribute [rw] finish_time
        #   @return [Google::Protobuf::Timestamp]
        #     The time at which the operation failed or was completed successfully.
        class SnapshotTableMetadata; end

        # The metadata for the Operation returned by CreateTableFromSnapshot.
        #
        # Note: This is a private alpha release of Cloud Bigtable snapshots. This
        # feature is not currently available to most Cloud Bigtable customers. This
        # feature might be changed in backward-incompatible ways and is not recommended
        # for production use. It is not subject to any SLA or deprecation policy.
        # @!attribute [rw] original_request
        #   @return [Google::Bigtable::Admin::V2::CreateTableFromSnapshotRequest]
        #     The request that prompted the initiation of this CreateTableFromSnapshot
        #     operation.
        # @!attribute [rw] request_time
        #   @return [Google::Protobuf::Timestamp]
        #     The time at which the original request was received.
        # @!attribute [rw] finish_time
        #   @return [Google::Protobuf::Timestamp]
        #     The time at which the operation failed or was completed successfully.
        class CreateTableFromSnapshotMetadata; end
      end
    end
  end
end