# frozen_string_literal: true

# Copyright 2023 Google LLC
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
    module BareMetalSolution
      module V2
        # A snapshot of a volume. Only boot volumes can have snapshots.
        # @!attribute [rw] name
        #   @return [::String]
        #     The name of the snapshot.
        # @!attribute [r] id
        #   @return [::String]
        #     Output only. An identifier for the snapshot, generated by the backend.
        # @!attribute [rw] description
        #   @return [::String]
        #     The description of the snapshot.
        # @!attribute [r] create_time
        #   @return [::Google::Protobuf::Timestamp]
        #     Output only. The creation time of the snapshot.
        # @!attribute [r] storage_volume
        #   @return [::String]
        #     Output only. The name of the volume which this snapshot belongs to.
        # @!attribute [r] type
        #   @return [::Google::Cloud::BareMetalSolution::V2::VolumeSnapshot::SnapshotType]
        #     Output only. The type of the snapshot which indicates whether it was
        #     scheduled or manual/ad-hoc.
        class VolumeSnapshot
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods

          # Represents the type of a snapshot.
          module SnapshotType
            # Type is not specified.
            SNAPSHOT_TYPE_UNSPECIFIED = 0

            # Snapshot was taken manually by user.
            AD_HOC = 1

            # Snapshot was taken automatically as a part of a snapshot schedule.
            SCHEDULED = 2
          end
        end

        # Message for requesting volume snapshot information.
        # @!attribute [rw] name
        #   @return [::String]
        #     Required. The name of the snapshot.
        class GetVolumeSnapshotRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Message for requesting a list of volume snapshots.
        # @!attribute [rw] parent
        #   @return [::String]
        #     Required. Parent value for ListVolumesRequest.
        # @!attribute [rw] page_size
        #   @return [::Integer]
        #     Requested page size. The server might return fewer items than requested.
        #     If unspecified, server will pick an appropriate default.
        # @!attribute [rw] page_token
        #   @return [::String]
        #     A token identifying a page of results from the server.
        class ListVolumeSnapshotsRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Response message containing the list of volume snapshots.
        # @!attribute [rw] volume_snapshots
        #   @return [::Array<::Google::Cloud::BareMetalSolution::V2::VolumeSnapshot>]
        #     The list of snapshots.
        # @!attribute [rw] next_page_token
        #   @return [::String]
        #     A token identifying a page of results from the server.
        # @!attribute [rw] unreachable
        #   @return [::Array<::String>]
        #     Locations that could not be reached.
        class ListVolumeSnapshotsResponse
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Message for deleting named Volume snapshot.
        # @!attribute [rw] name
        #   @return [::String]
        #     Required. The name of the snapshot to delete.
        class DeleteVolumeSnapshotRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Message for creating a volume snapshot.
        # @!attribute [rw] parent
        #   @return [::String]
        #     Required. The volume to snapshot.
        # @!attribute [rw] volume_snapshot
        #   @return [::Google::Cloud::BareMetalSolution::V2::VolumeSnapshot]
        #     Required. The snapshot to create.
        class CreateVolumeSnapshotRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Message for restoring a volume snapshot.
        # @!attribute [rw] volume_snapshot
        #   @return [::String]
        #     Required. Name of the snapshot which will be used to restore its parent
        #     volume.
        class RestoreVolumeSnapshotRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end
      end
    end
  end
end
