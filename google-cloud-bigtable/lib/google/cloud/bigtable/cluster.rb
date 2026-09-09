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


require "google/cloud/bigtable/backup"
require "google/cloud/bigtable/cluster/list"
require "google/cloud/bigtable/cluster/job"

module Google
  module Cloud
    module Bigtable
      ##
      # # Cluster
      #
      # A configuration object describing how Cloud Bigtable should treat traffic
      # from a particular end user application.
      #
      # @example
      #   require "google/cloud/bigtable"
      #
      #   bigtable = Google::Cloud::Bigtable.new
      #
      #   instance = bigtable.instance "my-instance"
      #   cluster = instance.cluster "my-cluster"
      #
      #   # Update
      #   cluster.nodes = 3
      #   cluster.save
      #
      #   # Delete
      #   cluster.delete
      #
      class Cluster
        # @private
        # The gRPC Service object.
        attr_accessor :service

        # @private
        #
        # Creates a new Cluster instance.
        def initialize grpc, service
          @grpc = grpc
          @service = service
        end

        ##
        # The unique identifier for the project to which the cluster belongs.
        #
        # @return [String]
        #
        def project_id
          @grpc.name.split("/")[1]
        end

        ##
        # The unique identifier for the instance to which the cluster belongs.
        #
        # @return [String]
        #
        def instance_id
          @grpc.name.split("/")[3]
        end

        ##
        # The unique identifier for the cluster.
        #
        # @return [String]
        #
        def cluster_id
          @grpc.name.split("/")[5]
        end

        ##
        # The unique name of the cluster. Value in the form
        # `projects/<project_id>/instances/<instance_id>/clusters/<cluster_id>`.
        #
        # @return [String]
        #
        def path
          @grpc.name
        end

        ##
        # The current state of the cluster.
        # Possible values are
        # `:CREATING`, `:READY`, `:STATE_NOT_KNOWN`, `:RESIZING`, `:DISABLED`.
        #
        # @return [Symbol]
        #
        def state
          @grpc.state
        end

        ##
        # The cluster has been successfully created and is ready to serve requests.
        #
        # @return [Boolean]
        #
        def ready?
          state == :READY
        end

        ##
        # The cluster is currently being created, and may be destroyed if the
        # creation process encounters an error.
        #
        # @return [Boolean]
        #
        def creating?
          state == :CREATING
        end

        ##
        # The cluster is currently being resized, and may revert to its previous
        # node count if the process encounters an error.
        # A cluster is still capable of serving requests while being resized,
        # but may perform as if its number of allocated nodes is
        # between the starting and requested states.
        #
        # @return [Boolean]
        #
        def resizing?
          state == :RESIZING
        end

        ##
        # The cluster has no backing nodes. The data (tables) still
        # exist, but no operations can be performed on the cluster.
        #
        # @return [Boolean]
        #
        def disabled?
          state == :DISABLED
        end

        ##
        # The number of nodes allocated to this cluster.
        #
        # @return [Integer]
        #
        def nodes
          @grpc.serve_nodes
        end

        ##
        # The number of nodes allocated to this cluster. More nodes enable higher
        # throughput and more consistent performance.
        #
        # @param serve_nodes [Integer] Number of nodes
        #
        def nodes= serve_nodes
          @grpc.serve_nodes = serve_nodes
        end

        ##
        # The type of storage used by this cluster to serve its
        # parent instance's tables, unless explicitly overridden.
        # Valid values are:
        #
        #   * `:SSD` - Flash (SSD) storage should be used.
        #   * `:HDD` - Magnetic drive (HDD) storage should be used.
        #
        # @return [Symbol]
        #
        def storage_type
          @grpc.default_storage_type
        end

        ##
        # Cluster location.
        # For example, "us-east1-b"
        #
        # @return [String]
        #
        def location
          @grpc.location.split("/")[3]
        end

        ##
        # Cluster location path in form of
        # `projects/<project_id>/locations/<zone>`
        #
        # @return [String]
        #
        def location_path
          @grpc.location
        end

        ##
        # The full name of the Cloud KMS encryption key for the cluster, if it is CMEK-protected, in the format
        # `projects/{key_project_id}/locations/{location}/keyRings/{ring_name}/cryptoKeys/{key_name}`.
        #
        # The requirements for this key are:
        #
        # 1. The Cloud Bigtable service account associated with the project that contains this cluster must be granted
        #    the `cloudkms.cryptoKeyEncrypterDecrypter` role on the CMEK key.
        # 2. Only regional keys can be used and the region of the CMEK key must match the region of the cluster.
        # 3. All clusters within an instance must use the same CMEK key.
        #
        # @return [String, nil] The full name of the Cloud KMS encryption key, or `nil` if the cluster is not
        #   CMEK-protected.
        #
        def kms_key
          @grpc.encryption_config&.kms_key_name
        end

        ##
        # Creates a new Cloud Bigtable Backup.
        #
        # @param source_table [Table, String] The table object, or the name of the table,
        #   from which the backup is to be created. The table needs to be in the same
        #   instance as the backup. Required.
        # @param backup_id [String] The id of the backup to be created. This string must
        #   be between 1 and 50 characters in length and match the regex
        #   `[_a-zA-Z0-9][-_.a-zA-Z0-9]*`. Required.
        # @param expire_time [Time] The expiration time of the backup, with microseconds
        #     granularity that must be at least 6 hours and at most 30 days
        #     from the time the request is received. Once the `expire_time`
        #     has passed, Cloud Bigtable will delete the backup and free the
        #     resources used by the backup. Required.
        # @return [Google::Cloud::Bigtable::Backup::Job]
        #   The job representing the long-running, asynchronous processing of
        #   a backup create operation.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   instance = bigtable.instance "my-instance"
        #   cluster = instance.cluster "my-cluster"
        #   table = instance.table "my-table"
        #
        #   expire_time = Time.now + 60 * 60 * 7
        #   job = cluster.create_backup table, "my-backup", expire_time
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
        def create_backup source_table, backup_id, expire_time
          source_table_id = source_table.respond_to?(:name) ? source_table.name : source_table
          grpc = service.create_backup instance_id:     instance_id,
                                       cluster_id:      cluster_id,
                                       backup_id:       backup_id,
                                       source_table_id: source_table_id,
                                       expire_time:     expire_time
          Backup::Job.from_grpc grpc, service
        end

        ##
        # Gets a backup in the cluster.
        #
        # @param backup_id [String] The unique ID of the requested backup.
        #
        # @return [Google::Cloud::Bigtable::Backup, nil] The backup object, or `nil` if not found in the service.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance "my-instance"
        #   cluster = instance.cluster "my-cluster"
        #
        #   backup = cluster.backup "my-backup"
        #
        #   if backup
        #     puts backup.backup_id
        #   end
        #
        def backup backup_id
          grpc = service.get_backup instance_id, cluster_id, backup_id
          Backup.from_grpc grpc, service
        rescue Google::Cloud::NotFoundError
          nil
        end

        ##
        # Lists all backups in the cluster.
        #
        # @return [Array<Google::Cloud::Bigtable::Backup>] (See {Google::Cloud::Bigtable::Backup::List})
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance "my-instance"
        #   cluster = instance.cluster "my-cluster"
        #
        #   cluster.backups.all do |backup|
        #     puts backup.backup_id
        #   end
        #
        def backups
          grpc = service.list_backups instance_id, cluster_id
          Backup::List.from_grpc grpc, service
        end

        ##
        # Updates the cluster.
        #
        # `serve_nodes` is the only updatable field.
        #
        # @return [Google::Cloud::Bigtable::Cluster::Job]
        #   The job representing the long-running, asynchronous processing of
        #   an update cluster operation.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance "my-instance"
        #   cluster = instance.cluster "my-cluster"
        #   cluster.nodes = 3
        #   job = cluster.save
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
        #
        def save
          ensure_service!
          grpc = service.update_cluster instance_id, cluster_id, location_path, nodes
          Cluster::Job.from_grpc grpc, service
        end
        alias update save

        ##
        # Reloads cluster data.
        #
        # @return [Google::Cloud::Bigtable::Cluster]
        #
        def reload!
          @grpc = service.get_cluster instance_id, cluster_id
          self
        end

        ##
        # Permanently deletes the cluster.
        #
        # @return [Boolean] Returns `true` if the cluster was deleted.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance "my-instance"
        #   cluster = instance.cluster "my-cluster"
        #   cluster.delete
        #
        def delete
          ensure_service!
          service.delete_cluster instance_id, cluster_id
          true
        end

        # @private
        #
        # Creates a new Cluster instance from a
        # Google::Cloud::Bigtable::Admin::V2::Cluster.
        #
        # @param grpc [Google::Cloud::Bigtable::Admin::V2::Cluster]
        # @param service [Google::Cloud::Bigtable::Service]
        # @return [Google::Cloud::Bigtable::Cluster]
        def self.from_grpc grpc, service
          new grpc, service
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
