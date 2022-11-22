# frozen_string_literal: true

# Copyright 2020 Google LLC
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


require "google/cloud/bigtable/backup/job"
require "google/cloud/bigtable/backup/list"
require "google/cloud/bigtable/convert"
require "google/cloud/bigtable/encryption_info"
require "google/cloud/bigtable/policy"
require "google/cloud/bigtable/table/restore_job"

module Google
  module Cloud
    module Bigtable
      ##
      # # Backup
      #
      # A backup of a Cloud Bigtable table. See {Cluster#create_backup}, {Cluster#backup} and {Cluster#backups}.
      #
      # @example
      #   require "google/cloud/bigtable"
      #
      #   bigtable = Google::Cloud::Bigtable.new
      #   instance = bigtable.instance "my-instance"
      #   cluster = instance.cluster "my-cluster"
      #
      #   backup = cluster.backup "my-backup"
      #
      #   # Update
      #   backup.expire_time = Time.now + 60 * 60 * 7
      #   backup.save
      #
      #   # Delete
      #   backup.delete
      #
      class Backup
        # @private
        # The gRPC Service object.
        attr_accessor :service

        ##
        # @private A list of attributes that were updated.
        attr_reader :updates

        # @private
        #
        # Creates a new Backup instance.
        def initialize grpc, service
          @grpc = grpc
          @service = service
        end

        ##
        # The unique identifier for the project to which the backup belongs.
        #
        # @return [String]
        #
        def project_id
          @grpc.name.split("/")[1]
        end

        ##
        # The unique identifier for the instance to which the backup belongs.
        #
        # @return [String]
        #
        def instance_id
          @grpc.name.split("/")[3]
        end

        ##
        # The unique identifier for the cluster to which the backup belongs.
        #
        # @return [String]
        #
        def cluster_id
          @grpc.name.split("/")[5]
        end

        ##
        # The unique identifier for the backup.
        #
        # @return [String]
        #
        def backup_id
          @grpc.name.split("/")[7]
        end

        ##
        # The unique name of the backup. Value in the form
        # `projects/<project>/instances/<instance>/clusters/<cluster>/backups/<backup>`.
        #
        # @return [String]
        #
        def path
          @grpc.name
        end

        ##
        # The table from which this backup was created.
        #
        # @param perform_lookup [Boolean] Creates table object without verifying that the table resource exists. Calls
        #   made on this object will raise errors if the table does not exist. Default value is `false`. Optional. Helps
        #   to reduce admin API calls.
        # @param view [Symbol] Table view type. Default view type is `:SCHEMA_VIEW`. Valid view types are:
        #
        #   * `:NAME_ONLY` - Only populates `name`.
        #   * `:SCHEMA_VIEW` - Only populates `name` and fields related to the table's schema.
        #   * `:REPLICATION_VIEW` - Only populates `name` and fields related to the table's replication state.
        #   * `:FULL` - Populates all fields.
        #
        # @return [Table]
        #
        def source_table perform_lookup: nil, view: nil
          table = Table.from_path @grpc.source_table, service
          return table.reload! view: view if perform_lookup
          table
        end

        ##
        # The expiration time of the backup, with microseconds granularity that must be at least 6 hours and at most 30
        # days from the time the request is received. Once the expire time has passed, Cloud Bigtable will delete the
        # backup and free the resources used by the backup.
        #
        # @return [Time]
        #
        def expire_time
          Convert.timestamp_to_time @grpc.expire_time
        end

        ##
        # Sets the expiration time of the backup, with microseconds granularity that must be at least 6 hours and at
        # most 30 days from the time the request is received. Once the {#expire_time} has passed, Cloud Bigtable will
        # delete the backup and free the resources used by the backup.
        #
        # @param [Time] new_expire_time The new expiration time of the backup.
        #
        def expire_time= new_expire_time
          @grpc.expire_time = Convert.time_to_timestamp new_expire_time
        end

        ##
        # The time that the backup was started (i.e. approximately the time the `CreateBackup` request is received). The
        # row data in this backup will be no older than this timestamp.
        #
        # @return [Time]
        #
        def start_time
          Convert.timestamp_to_time @grpc.start_time
        end

        ##
        # The time that the backup was finished. The row data in the backup will be no newer than this timestamp.
        #
        # @return [Time]
        #
        def end_time
          Convert.timestamp_to_time @grpc.end_time
        end

        ##
        # The size of the backup in bytes.
        #
        # @return [Integer]
        #
        def size_bytes
          @grpc.size_bytes
        end

        ##
        # The current state of the backup. Possible values are `:CREATING` and `:READY`.
        #
        # @return [Symbol]
        #
        def state
          @grpc.state
        end

        ##
        # The backup is currently being created, and may be destroyed if the creation process encounters an error.
        #
        # @return [Boolean]
        #
        def creating?
          state == :CREATING
        end

        ##
        # The backup has been successfully created and is ready to serve requests.
        #
        # @return [Boolean]
        #
        def ready?
          state == :READY
        end

        ##
        # The encryption information for the backup. See also {Instance::ClusterMap#add}.
        #
        # @return [Google::Cloud::Bigtable::EncryptionInfo] The encryption information for the backup.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   instance = bigtable.instance "my-instance"
        #   cluster = instance.cluster "my-cluster"
        #
        #   backup = cluster.backup "my-backup"
        #
        #   encryption_info = backup.encryption_info
        #   encryption_info.encryption_type #=> :GOOGLE_DEFAULT_ENCRYPTION
        #
        def encryption_info
          EncryptionInfo.from_grpc @grpc.encryption_info
        end

        ##
        # Gets the [Cloud IAM](https://cloud.google.com/iam/) access control
        # policy for the backup.
        #
        # @see https://cloud.google.com/bigtable/docs/access-control
        #
        # @yield [policy] A block for updating the policy. The latest policy
        #   will be read from the Bigtable service and passed to the block. After
        #   the block completes, the modified policy will be written to the
        #   service.
        # @yieldparam [Policy] policy the current Cloud IAM Policy for this
        #   backup.
        #
        # @return [Policy] The current Cloud IAM Policy for the backup.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   instance = bigtable.instance "my-instance"
        #   cluster = instance.cluster "my-cluster"
        #
        #   backup = cluster.backup "my-backup"
        #
        #   policy = backup.policy
        #
        # @example Update the policy by passing a block.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   instance = bigtable.instance "my-instance"
        #   cluster = instance.cluster "my-cluster"
        #
        #   backup = cluster.backup "my-backup"
        #
        #   backup.policy do |p|
        #     p.add "roles/owner", "user:owner@example.com"
        #   end # 2 API calls
        #
        def policy
          ensure_service!
          grpc = service.get_backup_policy instance_id, cluster_id, backup_id
          policy = Policy.from_grpc grpc
          return policy unless block_given?
          yield policy
          update_policy policy
        end

        ##
        # Updates the [Cloud IAM](https://cloud.google.com/iam/) access control
        # policy for the backup. The policy should be read from {#policy}.
        # See {Google::Cloud::Bigtable::Policy} for an explanation of the policy
        # `etag` property and how to modify policies.
        #
        # You can also update the policy by passing a block to {#policy}, which
        # will call this method internally after the block completes.
        #
        # @param new_policy [Policy] a new or modified Cloud IAM Policy for this
        #   backup
        #
        # @return [Policy] The policy returned by the API update operation.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   instance = bigtable.instance "my-instance"
        #   cluster = instance.cluster "my-cluster"
        #
        #   backup = cluster.backup "my-backup"
        #
        #   policy = backup.policy
        #   policy.add "roles/owner", "user:owner@example.com"
        #   updated_policy = backup.update_policy policy
        #
        #   puts updated_policy.roles
        #
        def update_policy new_policy
          ensure_service!
          grpc = service.set_backup_policy instance_id, cluster_id, backup_id, new_policy.to_grpc
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
        #   check access for. Permissions with wildcards (such as `*` or `bigtable.*`) are
        #   not allowed.
        #   See [Access Control](https://cloud.google.com/bigtable/docs/access-control).
        #
        # @return [Array<String>] The permissions that are configured for the policy.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   instance = bigtable.instance "my-instance"
        #   cluster = instance.cluster "my-cluster"
        #
        #   backup = cluster.backup "my-backup"
        #
        #   permissions = backup.test_iam_permissions(
        #     "bigtable.backups.delete",
        #     "bigtable.backups.get"
        #   )
        #   permissions.include? "bigtable.backups.delete" #=> false
        #   permissions.include? "bigtable.backups.get" #=> true
        #
        def test_iam_permissions *permissions
          ensure_service!
          grpc = service.test_backup_permissions instance_id, cluster_id, backup_id, permissions.flatten
          grpc.permissions.to_a
        end

        ##
        # Creates a new table by restoring data from a completed backup. The new table may be created in an instance
        # different than that of the backup.
        #
        # @param table_id [String] The table ID for the new table. This table must not yet exist. Required.
        # @param instance [Instance, String] The instance or the ID of the instance for the new table, if different from
        #   the instance of the backup. Optional.
        #
        # @return [Google::Cloud::Bigtable::Table::RestoreJob] The job representing the long-running, asynchronous
        #   processing of a backup restore table operation.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   instance = bigtable.instance "my-instance"
        #   cluster = instance.cluster "my-cluster"
        #
        #   backup = cluster.backup "my-backup"
        #
        #   job = backup.restore "my-new-table"
        #
        #   job.wait_until_done!
        #   job.done? #=> true
        #
        #   if job.error?
        #     status = job.error
        #   else
        #     table = job.table
        #     optimized = job.optimize_table_operation_name
        #   end
        #
        # @example Create the table in a different instance.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   instance = bigtable.instance "my-instance"
        #   cluster = instance.cluster "my-cluster"
        #
        #   backup = cluster.backup "my-backup"
        #
        #   table_instance = bigtable.instance "my-other-instance"
        #   job = backup.restore "my-new-table", instance: table_instance
        #
        #   job.wait_until_done!
        #   job.done? #=> true
        #
        #   if job.error?
        #     status = job.error
        #   else
        #     table = job.table
        #     optimized = job.optimize_table_operation_name
        #   end
        #
        def restore table_id, instance: nil
          table_instance_id = instance.respond_to?(:instance_id) ? instance.instance_id : instance
          grpc = service.restore_table table_id,
                                       instance_id,
                                       cluster_id,
                                       backup_id,
                                       table_instance_id: table_instance_id
          Table::RestoreJob.from_grpc grpc, service
        end

        ##
        # Updates the backup.
        #
        # `expire_time` is the only updatable field.
        #
        # @return [Boolean] Returns `true` if the update succeeded.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   instance = bigtable.instance "my-instance"
        #   cluster = instance.cluster "my-cluster"
        #
        #   backup = cluster.backup "my-backup"
        #
        #   # Update
        #   backup.expire_time = Time.now + 60 * 60 * 7
        #   backup.save
        #
        def save
          ensure_service!
          @grpc = service.update_backup @grpc, [:expire_time]
          true
        end
        alias update save

        ##
        # Reloads backup data.
        #
        # @return [Google::Cloud::Bigtable::Backup]
        #
        def reload!
          @grpc = service.get_backup instance_id, cluster_id, backup_id
          self
        end

        ##
        # Permanently deletes the backup.
        #
        # @return [Boolean] Returns `true` if the backup was deleted.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   instance = bigtable.instance "my-instance"
        #   cluster = instance.cluster "my-cluster"
        #
        #   backup = cluster.backup "my-backup"
        #
        #   backup.delete
        #
        def delete
          ensure_service!
          service.delete_backup instance_id, cluster_id, backup_id
          true
        end

        # @private
        #
        # Creates a new Backup instance from a Google::Cloud::Bigtable::Admin::V2::Backup.
        #
        # @param grpc [Google::Cloud::Bigtable::Admin::V2::Backup]
        # @param service [Google::Cloud::Bigtable::Service]
        # @return [Google::Cloud::Bigtable::Backup]
        def self.from_grpc grpc, service
          new grpc, service
        end

        protected

        # @private
        #
        # Raise an error unless an active connection to the service is available.
        def ensure_service!
          raise "Must have active connection to service" unless service
        end
      end
    end
  end
end
