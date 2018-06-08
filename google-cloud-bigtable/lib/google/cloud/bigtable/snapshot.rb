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


require "google/cloud/bigtable/snapshot/list"
require "google/cloud/bigtable/snapshot/job"
require "google/cloud/bigtable/table/job"

module Google
  module Cloud
    module Bigtable
      # # Snapshot
      #
      # A snapshot of a table at a particular time. A snapshot can be used as a
      # checkpoint for data restoration or a data source for a new table.
      #
      # @example
      #   require "google/cloud/bigtable"
      #
      #   bigtable = Google::Cloud::Bigtable.new
      #
      #   instance = bigtable.instance("my-instance")
      #   table = instance.table("my-table")
      #   snapshot = table.snapshot("my-table-snapshot")
      #
      #   # Create table from snapshot
      #   snapshot.create_table("new-my-table", "my-cluster", "my-table-snapshot")
      #
      #   # Delete
      #   snapshot.delete
      #
      class Snapshot
        # @private
        # The gRPC Service object.
        attr_accessor :service

        # @private
        # Creates a new Snapshot instance.
        def initialize grpc, service
          @grpc = grpc
          @service = service
        end

        # The unique identifier for the project.
        # @return [String]
        def project_id
          @grpc.name.split("/")[1]
        end

        # The unique identifier for the instance.
        # @return [String]
        def instance_id
          @grpc.name.split("/")[3]
        end

        # The unique identifier for the cluster.
        # @return [String]
        def cluster_id
          @grpc.name.split("/")[5]
        end

        # The unique name identifier for the snapshot.
        # @return [String]
        def name
          @grpc.name.split("/")[7]
        end

        # The full path for the snapshot resource. Values are of the form
        # `projects/<project>/instances/<instance>/clusters/<cluster>/snapshots/<snapshot>`.
        # @return [String]
        def path
          @grpc.name
        end

        # The current snapshot state. Possible values are `:CREATING`,
        # `:READY`, `:STATE_NOT_KNOWN`.
        # @return [Symbol]
        def state
          @grpc.state
        end

        # The snapshot has been successfully created and can serve all requests.
        # @return [Boolean]
        def ready?
          state == :READY
        end

        # The snapshot is currently being created, and may be destroyed if the
        # creation process encounters an error. A snapshot may not be restored to a
        # table while it is being created.
        # @return [Boolean]
        def creating?
          state == :CREATING
        end

        # Description of the snapshot.
        # @return [String]
        def description
          @grpc.description
        end

        # Snapshot data size in bytes
        #
        # The size of the data in the source table at the time the snapshot was
        # taken. In some cases, this value may be computed asynchronously via a
        # background process and a placeholder of 0 will be used in the meantime
        # @return [Integer] Size of snapshot in bytes
        def data_size
          @grpc.data_size_bytes
        end

        # Get snapshot create time
        # The time when the snapshot is created
        # @return [Time]
        def create_time
          Convert.timestamp_to_time(@grpc.create_time)
        end

        # Get snapshot delete time
        #
        # The time when the snapshot will be deleted. The maximum amount of time a
        # snapshot can stay active is 365 days. If 'ttl' is not specified,
        # the default maximum of 365 days will be used.
        # @return [Time]
        def delete_time
          Convert.timestamp_to_time(@grpc.delete_time)
        end

        # The source table at the time the snapshot was taken.
        # @return [Google::Cloud::Bigtable::Table, nil]
        def source_table
          Table.from_grpc(@grpc.source_table, service) if @grpc.source_table
        end

        # Permanently deletes the snapshot..
        #
        # @return [Boolean] Returns `true` if the snapshot was deleted.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #   table = instance.table("my-table")
        #   snapshot = table.snapshot("my-table-snapshot")
        #
        #   snapshot.delete
        #
        def delete
          ensure_service!
          service.delete_snapshot(instance_id, cluster_id, name)
          true
        end

        # Creates a new table from the snapshot. The target table must
        # not exist. The snapshot and the table must be in the same instance.
        #
        # @param table_id [String]
        #   The name by which the new table should be referred to within the parent
        #   instance, e.g., +foobar+
        # @return [Google::Cloud::Bigtable::Table::Job]
        #   The job representing the long-running, asynchronous processing of
        #   an table create from snapshot operation.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #   table = instance.table("my-table")
        #   snapshot = table.snapshot("my-table-snapshot")
        #
        #   job = snapshot.create_table(
        #     "new-my-table",
        #     "my-cluster",
        #     "my-table-snapshot"
        #   )
        #
        #   job.done? #=> false
        #   job.reload! # API call
        #   job.done? #=> true
        #
        #   if job.error?
        #     status = job.error
        #   else
        #     table = job.table
        #   end

        def create_table table_id
          ensure_service!
          grpc = service.create_table_from_snapshot(
            instance_id,
            table_id,
            cluster_id,
            name
          )
          Table::Job.from_grpc(grpc, service)
        end

        # @private
        # Creates a new Snapshot instance from a
        # Google::Bigtable::Admin::V2::Snapshot.
        # @param grpc [Google::Bigtable::Admin::V2::Snapshot]
        # @param service [Google::Cloud::Bigtable::Service]
        # @return [Google::Cloud::Bigtable::Snapshot]
        def self.from_grpc grpc, service
          new(grpc, service)
        end

        protected

        # @private
        # Raise an error unless an active connection to the service is
        # available.
        def ensure_service!
          raise "Must have active connection to service" unless service
        end
      end
    end
  end
end
