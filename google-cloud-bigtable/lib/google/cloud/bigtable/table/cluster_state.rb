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


module Google
  module Cloud
    module Bigtable
      class Table
        # Table::ClusterState is the state of a table's data in a particular cluster.
        class ClusterState
          attr_reader :cluster_name

          # @private
          # Creates a new Table::ClusterState
          #
          def initialize grpc, cluster_name
            @grpc = grpc
            @cluster_name = cluster_name
          end

          # The state of replication for the table in this cluster.
          #   Valid values are:
          #   * `:INITIALIZING` - The cluster was recently created.
          #   * `:PLANNED_MAINTENANCE` - The table is temporarily unable to serve.
          #   * `:UNPLANNED_MAINTENANCE` - The table is temporarily unable to serve.
          #   * `:READY` - The table can serve.
          # @return [Symbol]
          #
          def replication_state
            @grpc.replication_state
          end

          # The cluster was recently created, and the table must finish copying
          # over pre-existing data from other clusters before it can begin
          # receiving live replication updates and serving.
          # @return [Boolean]
          #
          def initializing?
            replication_state == :INITIALIZING
          end

          # The table is temporarily unable to serve
          # requests from this cluster due to planned internal maintenance.
          # @return [Boolean]
          #
          def planned_maintenance?
            replication_state == :PLANNED_MAINTENANCE
          end

          # The table is temporarily unable to serve requests from this
          # cluster due to unplanned or emergency maintenance.
          # @return [Boolean]
          #
          def unplanned_maintenance?
            replication_state == :UNPLANNED_MAINTENANCE
          end

          # The table can serve requests from this cluster.
          # Depending on replication delay, reads may not immediately
          # reflect the state of the table in other clusters.
          # @return [Boolean]
          #
          def ready?
            replication_state == :READY
          end

          # @private
          # New Table::ClusterState from a Google::Bigtable::Admin::V2::Table::ClusterState object.
          # @param grpc [Google::Bigtable::Admin::V2::Table::ClusterState]
          # @param cluster_name [String]
          # @return [Google::Cloud::Bigtable::Table::ClusterState]
          #
          def self.from_grpc grpc, cluster_name
            new(grpc, cluster_name)
          end
        end
      end
    end
  end
end
