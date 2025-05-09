# frozen_string_literal: true

# Copyright 2022 Google LLC
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

# Auto-generated by gapic-generator-ruby. DO NOT EDIT!


module Google
  module Cloud
    module GkeBackup
      module V1
        # Represents the backup of a specific persistent volume as a component of a
        # Backup - both the record of the operation and a pointer to the underlying
        # storage-specific artifacts.
        # @!attribute [r] name
        #   @return [::String]
        #     Output only. The full name of the VolumeBackup resource.
        #     Format: `projects/*/locations/*/backupPlans/*/backups/*/volumeBackups/*`.
        # @!attribute [r] uid
        #   @return [::String]
        #     Output only. Server generated global unique identifier of
        #     [UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier) format.
        # @!attribute [r] create_time
        #   @return [::Google::Protobuf::Timestamp]
        #     Output only. The timestamp when this VolumeBackup resource was
        #     created.
        # @!attribute [r] update_time
        #   @return [::Google::Protobuf::Timestamp]
        #     Output only. The timestamp when this VolumeBackup resource was last
        #     updated.
        # @!attribute [r] source_pvc
        #   @return [::Google::Cloud::GkeBackup::V1::NamespacedName]
        #     Output only. A reference to the source Kubernetes PVC from which this
        #     VolumeBackup was created.
        # @!attribute [r] volume_backup_handle
        #   @return [::String]
        #     Output only. A storage system-specific opaque handle to the underlying
        #     volume backup.
        # @!attribute [r] format
        #   @return [::Google::Cloud::GkeBackup::V1::VolumeBackup::VolumeBackupFormat]
        #     Output only. The format used for the volume backup.
        # @!attribute [r] storage_bytes
        #   @return [::Integer]
        #     Output only. The aggregate size of the underlying artifacts associated with
        #     this VolumeBackup in the backup storage. This may change over time when
        #     multiple backups of the same volume share the same backup storage
        #     location. In particular, this is likely to increase in size when
        #     the immediately preceding backup of the same volume is deleted.
        # @!attribute [r] disk_size_bytes
        #   @return [::Integer]
        #     Output only. The minimum size of the disk to which this VolumeBackup can be
        #     restored.
        # @!attribute [r] complete_time
        #   @return [::Google::Protobuf::Timestamp]
        #     Output only. The timestamp when the associated underlying volume backup
        #     operation completed.
        # @!attribute [r] state
        #   @return [::Google::Cloud::GkeBackup::V1::VolumeBackup::State]
        #     Output only. The current state of this VolumeBackup.
        # @!attribute [r] state_message
        #   @return [::String]
        #     Output only. A human readable message explaining why the VolumeBackup is in
        #     its current state. This field is only meant for human consumption and
        #     should not be used programmatically as this field is not guaranteed to be
        #     consistent.
        # @!attribute [r] etag
        #   @return [::String]
        #     Output only. `etag` is used for optimistic concurrency control as a way to
        #     help prevent simultaneous updates of a volume backup from overwriting each
        #     other. It is strongly suggested that systems make use of the `etag` in the
        #     read-modify-write cycle to perform volume backup updates in order to avoid
        #     race conditions.
        # @!attribute [r] satisfies_pzs
        #   @return [::Boolean]
        #     Output only. [Output Only] Reserved for future use.
        # @!attribute [r] satisfies_pzi
        #   @return [::Boolean]
        #     Output only. [Output Only] Reserved for future use.
        class VolumeBackup
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods

          # Identifies the format used for the volume backup.
          module VolumeBackupFormat
            # Default value, not specified.
            VOLUME_BACKUP_FORMAT_UNSPECIFIED = 0

            # Compute Engine Persistent Disk snapshot based volume backup.
            GCE_PERSISTENT_DISK = 1
          end

          # The current state of a VolumeBackup
          module State
            # This is an illegal state and should not be encountered.
            STATE_UNSPECIFIED = 0

            # A volume for the backup was identified and backup process is about to
            # start.
            CREATING = 1

            # The volume backup operation has begun and is in the initial "snapshot"
            # phase of the process. Any defined ProtectedApplication "pre" hooks will
            # be executed before entering this state and "post" hooks will be executed
            # upon leaving this state.
            SNAPSHOTTING = 2

            # The snapshot phase of the volume backup operation has completed and
            # the snapshot is now being uploaded to backup storage.
            UPLOADING = 3

            # The volume backup operation has completed successfully.
            SUCCEEDED = 4

            # The volume backup operation has failed.
            FAILED = 5

            # This VolumeBackup resource (and its associated artifacts) is in the
            # process of being deleted.
            DELETING = 6

            # The underlying artifacts of a volume backup (eg: persistent disk
            # snapshots) are deleted.
            CLEANED_UP = 7
          end
        end

        # Represents the operation of restoring a volume from a VolumeBackup.
        # @!attribute [r] name
        #   @return [::String]
        #     Output only. Full name of the VolumeRestore resource.
        #     Format: `projects/*/locations/*/restorePlans/*/restores/*/volumeRestores/*`
        # @!attribute [r] uid
        #   @return [::String]
        #     Output only. Server generated global unique identifier of
        #     [UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier) format.
        # @!attribute [r] create_time
        #   @return [::Google::Protobuf::Timestamp]
        #     Output only. The timestamp when this VolumeRestore resource was
        #     created.
        # @!attribute [r] update_time
        #   @return [::Google::Protobuf::Timestamp]
        #     Output only. The timestamp when this VolumeRestore resource was last
        #     updated.
        # @!attribute [r] volume_backup
        #   @return [::String]
        #     Output only. The full name of the VolumeBackup from which the volume will
        #     be restored. Format:
        #     `projects/*/locations/*/backupPlans/*/backups/*/volumeBackups/*`.
        # @!attribute [r] target_pvc
        #   @return [::Google::Cloud::GkeBackup::V1::NamespacedName]
        #     Output only. The reference to the target Kubernetes PVC to be restored.
        # @!attribute [r] volume_handle
        #   @return [::String]
        #     Output only. A storage system-specific opaque handler to the underlying
        #     volume created for the target PVC from the volume backup.
        # @!attribute [r] volume_type
        #   @return [::Google::Cloud::GkeBackup::V1::VolumeRestore::VolumeType]
        #     Output only. The type of volume provisioned
        # @!attribute [r] complete_time
        #   @return [::Google::Protobuf::Timestamp]
        #     Output only. The timestamp when the associated underlying volume
        #     restoration completed.
        # @!attribute [r] state
        #   @return [::Google::Cloud::GkeBackup::V1::VolumeRestore::State]
        #     Output only. The current state of this VolumeRestore.
        # @!attribute [r] state_message
        #   @return [::String]
        #     Output only. A human readable message explaining why the VolumeRestore is
        #     in its current state.
        # @!attribute [r] etag
        #   @return [::String]
        #     Output only. `etag` is used for optimistic concurrency control as a way to
        #     help prevent simultaneous updates of a volume restore from overwriting each
        #     other. It is strongly suggested that systems make use of the `etag` in the
        #     read-modify-write cycle to perform volume restore updates in order to avoid
        #     race conditions.
        class VolumeRestore
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods

          # Supported volume types.
          module VolumeType
            # Default
            VOLUME_TYPE_UNSPECIFIED = 0

            # Compute Engine Persistent Disk volume
            GCE_PERSISTENT_DISK = 1
          end

          # The current state of a VolumeRestore
          module State
            # This is an illegal state and should not be encountered.
            STATE_UNSPECIFIED = 0

            # A volume for the restore was identified and restore process is about to
            # start.
            CREATING = 1

            # The volume is currently being restored.
            RESTORING = 2

            # The volume has been successfully restored.
            SUCCEEDED = 3

            # The volume restoration process failed.
            FAILED = 4

            # This VolumeRestore resource is in the process of being deleted.
            DELETING = 5
          end
        end
      end
    end
  end
end
