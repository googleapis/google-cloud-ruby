# frozen_string_literal: true

# Copyright 2021 Google LLC
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


require "google/cloud/bigtable/status"

module Google
  module Cloud
    module Bigtable
      ##
      # # EncryptionInfo
      #
      # Encryption information for a given resource.
      #
      # See {Backup#encryption_info} and {Table::ClusterState#encryption_infos}.
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
      # @example Retrieve a table with cluster states containing encryption info.
      #   require "google/cloud/bigtable"
      #
      #   bigtable = Google::Cloud::Bigtable.new
      #
      #   table = bigtable.table "my-instance", "my-table", view: :ENCRYPTION_VIEW, perform_lookup: true
      #
      #   table.cluster_states.each do |cs|
      #     puts cs.cluster_name
      #     puts cs.encryption_infos.first.encryption_type
      #   end
      #
      class EncryptionInfo
        # @private
        #
        # Creates a new EncryptionInfo instance.
        def initialize grpc
          @grpc = grpc
        end

        ##
        # The type of encryption used to protect the resource. Possible values:
        #
        # * `ENCRYPTION_TYPE_UNSPECIFIED` - Encryption type was not specified, though data at rest remains encrypted.
        # * `GOOGLE_DEFAULT_ENCRYPTION` - The data backing the resource is encrypted at rest with a key that is
        #   fully managed by Google. No key version or status will be populated. This is the default state.
        # * `CUSTOMER_MANAGED_ENCRYPTION` - The data backing the resource is encrypted at rest with a key that is
        #   managed by the customer. The in-use version of the key and its status are populated for CMEK-protected
        #   tables. CMEK-protected backups are pinned to the key version that was in use at the time the backup was
        #   taken. This key version is populated but its status is not tracked and is reported as `UNKNOWN`.
        #
        # See also {#encryption_status}, {#kms_key_version} and {Instance::ClusterMap#add}.
        #
        # @return [Symbol] The encryption type code as an uppercase symbol.
        #
        def encryption_type
          @grpc.encryption_type
        end

        ##
        # The status of encrypt/decrypt calls on underlying data for the resource. Regardless of status, the existing
        # data is always encrypted at rest.
        #
        # See also {#encryption_type}, {#kms_key_version} and {Instance::ClusterMap#add}.
        #
        # @return [Google::Cloud::Bigtable::Status, nil] The encryption status object, or `nil` if not present.
        #
        def encryption_status
          status_grpc = @grpc.encryption_status
          Status.from_grpc status_grpc if status_grpc
        end

        ##
        # The version of the Cloud KMS key specified in the parent cluster that is in use for the data underlying the
        # table.
        #
        # See also {#encryption_type}, {#encryption_status} and {Instance::ClusterMap#add}.
        #
        # @return [String, nil] The Cloud KMS key version, or `nil` if not present.
        #
        def kms_key_version
          @grpc.kms_key_version unless @grpc.kms_key_version.empty?
        end

        # @private
        #
        # Creates a new EncryptionInfo instance from a Google::Cloud::Bigtable::Admin::V2::EncryptionInfo.
        #
        # @param grpc [Google::Cloud::Bigtable::Admin::V2::EncryptionInfo]
        # @return [Google::Cloud::Bigtable::EncryptionInfo]
        def self.from_grpc grpc
          new grpc
        end
      end
    end
  end
end
