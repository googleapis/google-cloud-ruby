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
    module BareMetalSolution
      module V2
        # An NFS share.
        # @!attribute [rw] name
        #   @return [::String]
        #     Immutable. The name of the NFS share.
        # @!attribute [r] nfs_share_id
        #   @return [::String]
        #     Output only. An identifier for the NFS share, generated by the backend.
        #     This field will be deprecated in the future, use `id` instead.
        # @!attribute [r] id
        #   @return [::String]
        #     Output only. An identifier for the NFS share, generated by the backend.
        #     This is the same value as nfs_share_id and will replace it in the future.
        # @!attribute [r] state
        #   @return [::Google::Cloud::BareMetalSolution::V2::NfsShare::State]
        #     Output only. The state of the NFS share.
        # @!attribute [r] volume
        #   @return [::String]
        #     Output only. The underlying volume of the share. Created automatically
        #     during provisioning.
        # @!attribute [rw] allowed_clients
        #   @return [::Array<::Google::Cloud::BareMetalSolution::V2::NfsShare::AllowedClient>]
        #     List of allowed access points.
        # @!attribute [rw] labels
        #   @return [::Google::Protobuf::Map{::String => ::String}]
        #     Labels as key value pairs.
        # @!attribute [rw] requested_size_gib
        #   @return [::Integer]
        #     The requested size, in GiB.
        # @!attribute [rw] storage_type
        #   @return [::Google::Cloud::BareMetalSolution::V2::NfsShare::StorageType]
        #     Immutable. The storage type of the underlying volume.
        class NfsShare
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods

          # Represents an 'access point' for the share.
          # @!attribute [rw] network
          #   @return [::String]
          #     The network the access point sits on.
          # @!attribute [r] share_ip
          #   @return [::String]
          #     Output only. The IP address of the share on this network. Assigned
          #     automatically during provisioning based on the network's services_cidr.
          # @!attribute [rw] allowed_clients_cidr
          #   @return [::String]
          #     The subnet of IP addresses permitted to access the share.
          # @!attribute [rw] mount_permissions
          #   @return [::Google::Cloud::BareMetalSolution::V2::NfsShare::MountPermissions]
          #     Mount permissions.
          # @!attribute [rw] allow_dev
          #   @return [::Boolean]
          #     Allow dev flag.  Which controls whether to allow creation of devices.
          # @!attribute [rw] allow_suid
          #   @return [::Boolean]
          #     Allow the setuid flag.
          # @!attribute [rw] no_root_squash
          #   @return [::Boolean]
          #     Disable root squashing, which is a feature of NFS.
          #     Root squash is a special mapping of the remote superuser (root) identity
          #     when using identity authentication.
          # @!attribute [r] nfs_path
          #   @return [::String]
          #     Output only. The path to access NFS, in format shareIP:/InstanceID
          #     InstanceID is the generated ID instead of customer provided name.
          #     example like "10.0.0.0:/g123456789-nfs001"
          class AllowedClient
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # @!attribute [rw] key
          #   @return [::String]
          # @!attribute [rw] value
          #   @return [::String]
          class LabelsEntry
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # The possible states for this NFS share.
          module State
            # The share is in an unknown state.
            STATE_UNSPECIFIED = 0

            # The share has been provisioned.
            PROVISIONED = 1

            # The NFS Share is being created.
            CREATING = 2

            # The NFS Share is being updated.
            UPDATING = 3

            # The NFS Share has been requested to be deleted.
            DELETING = 4
          end

          # The possible mount permissions.
          module MountPermissions
            # Permissions were not specified.
            MOUNT_PERMISSIONS_UNSPECIFIED = 0

            # NFS share can be mount with read-only permissions.
            READ = 1

            # NFS share can be mount with read-write permissions.
            READ_WRITE = 2
          end

          # The storage type for a volume.
          module StorageType
            # The storage type for this volume is unknown.
            STORAGE_TYPE_UNSPECIFIED = 0

            # The storage type for this volume is SSD.
            SSD = 1

            # This storage type for this volume is HDD.
            HDD = 2
          end
        end

        # Message for requesting NFS share information.
        # @!attribute [rw] name
        #   @return [::String]
        #     Required. Name of the resource.
        class GetNfsShareRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Message for requesting a list of NFS shares.
        # @!attribute [rw] parent
        #   @return [::String]
        #     Required. Parent value for ListNfsSharesRequest.
        # @!attribute [rw] page_size
        #   @return [::Integer]
        #     Requested page size. The server might return fewer items than requested.
        #     If unspecified, server will pick an appropriate default.
        # @!attribute [rw] page_token
        #   @return [::String]
        #     A token identifying a page of results from the server.
        # @!attribute [rw] filter
        #   @return [::String]
        #     List filter.
        class ListNfsSharesRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Response message containing the list of NFS shares.
        # @!attribute [rw] nfs_shares
        #   @return [::Array<::Google::Cloud::BareMetalSolution::V2::NfsShare>]
        #     The list of NFS shares.
        # @!attribute [rw] next_page_token
        #   @return [::String]
        #     A token identifying a page of results from the server.
        # @!attribute [rw] unreachable
        #   @return [::Array<::String>]
        #     Locations that could not be reached.
        class ListNfsSharesResponse
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Message requesting to updating an NFS share.
        # @!attribute [rw] nfs_share
        #   @return [::Google::Cloud::BareMetalSolution::V2::NfsShare]
        #     Required. The NFS share to update.
        #
        #     The `name` field is used to identify the NFS share to update.
        #     Format: projects/\\{project}/locations/\\{location}/nfsShares/\\{nfs_share}
        # @!attribute [rw] update_mask
        #   @return [::Google::Protobuf::FieldMask]
        #     The list of fields to update.
        #     The only currently supported fields are:
        #       `labels`
        #       `allowed_clients`
        class UpdateNfsShareRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Message requesting rename of a server.
        # @!attribute [rw] name
        #   @return [::String]
        #     Required. The `name` field is used to identify the nfsshare.
        #     Format: projects/\\{project}/locations/\\{location}/nfsshares/\\{nfsshare}
        # @!attribute [rw] new_nfsshare_id
        #   @return [::String]
        #     Required. The new `id` of the nfsshare.
        class RenameNfsShareRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Message for creating an NFS share.
        # @!attribute [rw] parent
        #   @return [::String]
        #     Required. The parent project and location.
        # @!attribute [rw] nfs_share
        #   @return [::Google::Cloud::BareMetalSolution::V2::NfsShare]
        #     Required. The NfsShare to create.
        class CreateNfsShareRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Message for deleting an NFS share.
        # @!attribute [rw] name
        #   @return [::String]
        #     Required. The name of the NFS share to delete.
        class DeleteNfsShareRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end
      end
    end
  end
end
