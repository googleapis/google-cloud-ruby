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


require "google/cloud/spanner/backup/job"
require "google/cloud/spanner/backup/list"
require "google/cloud/spanner/backup/restore/job"

module Google
  module Cloud
    module Spanner
      ##
      # # Backup
      #
      # A backup is a representation of Cloud Spanner database backup.
      #
      # See {Google::Cloud::Spanner::Instance#backups},
      # {Google::Cloud::Spanner::Instance#backup}, and
      # {Google::Cloud::Spanner::Database#create_backup}.
      #
      # @example
      #   require "google/cloud"
      #
      #   spanner = Google::Cloud::Spanner.new
      #   database = spanner.database "my-instance", "my-database"
      #
      #   expire_time = Time.now + 36000
      #   job = database.create_backup "my-backup", expire_time
      #
      #   job.done? #=> false
      #   job.reload! # API call
      #   job.done? #=> true
      #
      #   if job.error?
      #     status = job.error
      #   else
      #     backup = job.backup
      #   end
      #
      class Backup
        ##
        # @private The gRPC Service object.
        attr_accessor :service

        ##
        # @private Creates a new Backup instance.
        def initialize grpc, service
          @grpc = grpc
          @service = service
        end

        ##
        # The unique identifier for the project.
        # @return [String]
        def project_id
          @grpc.name.split("/")[1]
        end

        ##
        # The unique identifier for the instance.
        # @return [String]
        def instance_id
          @grpc.name.split("/")[3]
        end

        ##
        # The unique identifier for the backup.
        # @return [String]
        def backup_id
          @grpc.name.split("/")[5]
        end

        ##
        # Name of the database from which this backup was created.
        # @return [String]
        def database_id
          @grpc.database.split("/")[5]
        end

        # Encryption information for a given resource.
        # @return [Google::Cloud::Spanner::Admin::Database::V1::EncryptionInfo, nil]
        def encryption_info
          @grpc.encryption_info
        end

        ##
        # The full path for the backup. Values are of the form
        # `projects/<project>/instances/<instance>/backups/<backup_id>`.
        # @return [String]
        def path
          @grpc.name
        end

        ##
        # The current backup state. Possible values are `:CREATING` and
        # `:READY`.
        # @return [Symbol]
        def state
          @grpc.state
        end

        ##
        # The backup is still being created. A backup is not yet available
        # for the database restore operation.
        # @return [Boolean]
        def creating?
          state == :CREATING
        end

        ##
        # The backup is created and can be used to restore a database.
        # @return [Boolean]
        def ready?
          state == :READY
        end

        ##
        # The expiration time of the backup, with microseconds granularity.
        # @return [Time]
        def expire_time
          Convert.timestamp_to_time @grpc.expire_time
        end

        ##
        # Update backup expiration time.
        #
        # Set expiration time of the backup, with microseconds granularity
        # that must be at least 6 hours and at most 366 days from the time the
        # request is received. Once the `expire_time` has passed, Cloud Spanner
        # will delete the backup and free the resources used by the backup.
        #
        # @param [Time] time Backup expiration time.
        # @raise [Google::Cloud::Error] if expire time is in past or update
        #   call is aborted.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   instance = spanner.instance "my-instance"
        #   backup = instance.backup "my-backup"
        #   backup.expire_time = Time.now + 36000
        #   puts backup.expire_time
        #
        def expire_time= time
          ensure_service!

          expire_time_was = @grpc.expire_time
          @grpc.expire_time = Convert.time_to_timestamp time
          update_mask = Google::Protobuf::FieldMask.new paths: ["expire_time"]
          @grpc = service.update_backup @grpc, update_mask
        rescue Google::Cloud::Error => error
          @grpc.expire_time = expire_time_was
          raise error
        end

        ##
        # Create time is approximately the time when the backup request was
        # received.
        # @return [Time]
        def create_time
          Convert.timestamp_to_time @grpc.create_time
        end

        ##
        # Size of the backup in bytes.
        # @return [Integer]
        def size_in_bytes
          @grpc.size_bytes
        end

        ##
        # The instances of the restored databases that reference the backup.
        # Referencing databases may exist in different instances.
        # The existence of any referencing database prevents the backup from
        # being deleted. When a restored database from the backup enters the
        # `READY` state, the reference to the backup is removed.
        #
        # @return [Array<Google::Cloud::Spanner::Database>] Returns list of
        #   referencing database instances.
        #
        # @example
        #   spanner = Google::Cloud::Spanner.new
        #
        #   instance = spanner.instance "my-instance"
        #   backup = instance.backup "my-backup"
        #
        #   backup.referencing_databases.each do |database|
        #     puts database.database_id
        #   end
        #
        def referencing_databases
          ensure_service!

          @grpc.referencing_databases.map do |referencing_database|
            segments = referencing_database.split "/"
            database_grpc = service.get_database segments[3], segments[5]
            Database.from_grpc database_grpc, service
          end
        end

        ##
        # Permanently deletes the backup.
        #
        # @return [Boolean] Returns `true` if the backup was deleted.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   instance = spanner.instance "my-instance"
        #   backup = instance.backup "my-backup"
        #   backup.delete # true
        #
        def delete
          ensure_service!
          service.delete_backup instance_id, backup_id
          true
        end

        ##
        # Restores deleted database from the backup.
        #
        # @param [String] database_id The unique identifier for the database,
        #   which cannot be changed after the database is created. Values are of
        #   the form `[a-z][a-z0-9_\-]*[a-z0-9]` and must be between 2 and 30
        #   characters in length. Required.
        # @param [String] instance_id The name of the instance in which to
        #   create the restored database. This instance must be in the same
        #   project and have the same instance configuration as the instance
        #   containing the source backup. Optional. Default value is same as a
        #   backup instance.
        # @return [Database] Restored database.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   instance = spanner.instance "my-instance"
        #   backup = instance.backup "my-backup"
        #   job = backup.restore "my-restored-database"
        #
        #   job.done? #=> false
        #   job.reload! # API call
        #   job.done? #=> true
        #
        #   if job.error?
        #     status = job.error
        #   else
        #     database = job.database
        #   end
        #
        # @example Restore database in provided instance id
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   instance = spanner.instance "my-instance"
        #   backup = instance.backup "my-backup"
        #   job = backup.restore(
        #     "my-restored-database",
        #     instance_id: "other-instance"
        #   )
        #
        #   job.done? #=> false
        #   job.reload! # API call
        #   job.done? #=> true
        #
        #   if job.error?
        #     status = job.error
        #   else
        #     database = job.database
        #   end
        #
        def restore database_id, instance_id: nil, encryption_config: nil
          ensure_service!

          instance_id ||= self.instance_id

          grpc = service.restore_database \
            self.instance_id,
            backup_id,
            instance_id,
            database_id,
            encryption_config: encryption_config
          Restore::Job.from_grpc grpc, service
        end

        ##
        # @private
        # Creates a new Backup instance from a
        # `Google::Cloud::Spanner::Admin::Database::V1::Backup`.
        def self.from_grpc grpc, service
          new grpc, service
        end

        protected

        ##
        # @private Raise an error unless an active connection to the service is
        # available.
        def ensure_service!
          raise "Must have active connection to service" unless service
        end
      end
    end
  end
end
