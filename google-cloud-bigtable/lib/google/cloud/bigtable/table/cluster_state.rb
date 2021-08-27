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


require "google/cloud/bigtable/encryption_info"

module Google
  module Cloud
    module Bigtable
      class Table
        ##
        # Table::ClusterState is the state of a table's data in a particular cluster.
        #
        # @attr [String] cluster_name The name of the cluster.
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
        class ClusterState
          attr_reader :cluster_name

          # @private
          # Creates a new Table::ClusterState
          #
          def initialize grpc, cluster_name
            @grpc = grpc
            @cluster_name = cluster_name
          end

          ##
          # The state of replication for the table in this cluster.
          #   Valid values include:
          #   * `:INITIALIZING` - The cluster was recently created.
          #   * `:PLANNED_MAINTENANCE` - The table is temporarily unable to serve.
          #   * `:UNPLANNED_MAINTENANCE` - The table is temporarily unable to serve.
          #   * `:READY` - The table can serve.
          #   * `:READY_OPTIMIZING` - The table is fully created and ready for use
          #     after a restore, and is being optimized for performance. When
          #     optimizations are complete, the table will transition to `READY`
          #     state.
          #   * `:STATE_NOT_KNOWN` - If replication state is not present in the object
          #      because the table view is not `REPLICATION_VIEW` or `FULL`.
          #   * `:UNKNOWN` - If it could not be determined whether or not the table
          #     has data in a particular cluster (for example, if its zone is unavailable.)
          #
          # @return [Symbol] The state of replication.
          #
          def replication_state
            @grpc.replication_state
          end

          ##
          # The cluster was recently created, and the table must finish copying
          # over pre-existing data from other clusters before it can begin
          # receiving live replication updates and serving.
          #
          # @return [Boolean] `true` if the value of {#replication_state} is `INITIALIZING`,
          #   `false` otherwise.
          #
          def initializing?
            replication_state == :INITIALIZING
          end

          ##
          # The table is temporarily unable to serve
          # requests from this cluster due to planned internal maintenance.
          #
          # @return [Boolean] `true` if the value of {#replication_state} is `PLANNED_MAINTENANCE`,
          #   `false` otherwise.
          #
          def planned_maintenance?
            replication_state == :PLANNED_MAINTENANCE
          end

          ##
          # The table is temporarily unable to serve requests from this
          # cluster due to unplanned or emergency maintenance.
          #
          # @return [Boolean] `true` if the value of {#replication_state} is `UNPLANNED_MAINTENANCE`,
          #   `false` otherwise.
          #
          def unplanned_maintenance?
            replication_state == :UNPLANNED_MAINTENANCE
          end

          ##
          # The table can serve requests from this cluster.
          # Depending on replication delay, reads may not immediately
          # reflect the state of the table in other clusters.
          #
          # @return [Boolean] `true` if the value of {#replication_state} is `READY`,
          #   `false` otherwise.
          #
          def ready?
            replication_state == :READY
          end

          ##
          # The table is fully created and ready for use after a
          # restore, and is being optimized for performance. When
          # optimizations are complete, the table will transition to `READY`
          # state.
          #
          # @return [Boolean] `true` if the value of {#replication_state} is `READY_OPTIMIZING`,
          #   `false` otherwise.
          #
          def ready_optimizing?
            replication_state == :READY_OPTIMIZING
          end

          ##
          # The encryption info value objects for the table in this cluster. The encryption info
          # is only present when the table view is `ENCRYPTION_VIEW` or `FULL`. See also
          # {Instance::ClusterMap#add}.
          #
          # @return [Array<Google::Cloud::Bigtable::EncryptionInfo>] The array of encryption info
          #   value objects, or an empty array if none are present.
          #
          def encryption_infos
            @grpc.encryption_info.map { |ei_grpc| Google::Cloud::Bigtable::EncryptionInfo.from_grpc ei_grpc }
          end

          # @private
          # New Table::ClusterState from a Google::Cloud::Bigtable::Admin::V2::Table::ClusterState object.
          # @param grpc [Google::Cloud::Bigtable::Admin::V2::Table::ClusterState]
          # @param cluster_name [String]
          # @return [Google::Cloud::Bigtable::Table::ClusterState]
          #
          def self.from_grpc grpc, cluster_name
            new grpc, cluster_name
          end
        end
      end
    end
  end
end
