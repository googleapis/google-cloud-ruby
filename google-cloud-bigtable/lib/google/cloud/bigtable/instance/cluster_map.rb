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


require "google/cloud/bigtable/admin/v2"

module Google
  module Cloud
    module Bigtable
      class Instance
        ##
        # Instance::ClusterMap is a hash with cluster ID keys and cluster configuration values. It is used to create a
        # cluster.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   job = bigtable.create_instance "my-instance" do |clusters|
        #     clusters.add "test-cluster", "us-east1-b", nodes: 3, storage_type: :SSD
        #   end
        #
        #   job.wait_until_done!
        #
        class ClusterMap < DelegateClass(::Hash)
          # @private
          #
          # Creates a new Instance::ClusterMap with an hash of Cluster name and cluster grpc instances.
          def initialize value = {}
            super value
          end

          ##
          # Adds a cluster to the cluster map.
          #
          # @param name [String] The unique identifier for the cluster.
          # @param location [String] The location where this cluster's nodes and storage reside. For best performance,
          #   clients should be located as close as possible to this cluster. Currently only zones are supported.
          # @param nodes [Integer] Number of nodes for the cluster. When creating an instance of type `:DEVELOPMENT`,
          #   `nodes` must not be set.
          # @param storage_type [Symbol] The type of storage used by this cluster to serve its parent instance's tables,
          #   unless explicitly overridden. Valid values are:
          #
          #   * `:SSD` - Flash (SSD) storage should be used.
          #   * `:HDD` - Magnetic drive (HDD) storage should be used.
          #
          #   If not set then default will set to `:STORAGE_TYPE_UNSPECIFIED`.
          # @param kms_key [String] The full name of a Cloud KMS encryption key for a CMEK-protected cluster, in the
          #   format `projects/{key_project_id}/locations/{location}/keyRings/{ring_name}/cryptoKeys/{key_name}`.
          #
          #   The requirements for this key are:
          #
          #   1. The Cloud Bigtable service account associated with the project that contains this cluster must be
          #      granted the `cloudkms.cryptoKeyEncrypterDecrypter` role on the CMEK key.
          #   2. Only regional keys can be used and the region of the CMEK key must match the region of the cluster.
          #   3. All clusters within an instance must use the same CMEK key.
          #
          # @example
          #   require "google/cloud/bigtable"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #
          #   job = bigtable.create_instance "my-instance" do |clusters|
          #     clusters.add "test-cluster", "us-east1-b", nodes: 3, storage_type: :SSD
          #   end
          #
          #   job.wait_until_done!
          #
          # @example With a Cloud KMS encryption key name for a CMEK-protected cluster:
          #   require "google/cloud/bigtable"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #
          #   kms_key_name = "projects/a/locations/b/keyRings/c/cryptoKeys/d"
          #   job = bigtable.create_instance "my-instance" do |clusters|
          #     clusters.add "test-cluster", "us-east1-b", kms_key: kms_key_name
          #   end
          #
          #   job.wait_until_done!
          #
          def add name, location, nodes: nil, storage_type: nil, kms_key: nil
            if kms_key
              encryption_config = Google::Cloud::Bigtable::Admin::V2::Cluster::EncryptionConfig.new(
                kms_key_name: kms_key
              )
            end
            attrs = {
              serve_nodes:          nodes,
              location:             location,
              default_storage_type: storage_type,
              encryption_config:    encryption_config
            }.delete_if { |_, v| v.nil? }

            self[name] = Google::Cloud::Bigtable::Admin::V2::Cluster.new attrs
          end
        end
      end
    end
  end
end
