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

require "google/apis/storage_v1"

module Google
  module Cloud
    module Storage
      class Bucket
        ##
        # # Encryption Configuration
        #
        # A builder for Google Cloud Storage encryption configurations, passed
        # to {Bucket#encryption=} in block arguments to {Project#create_bucket}
        # and {Bucket#update}. See {Project#encryption} for creating instances.
        #
        # @see https://cloud.google.com/kms/docs/ Cloud Key Management Service
        #   Documentation
        #
        # @example Encrypt a new file with a default KMS key:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   # KMS key ring should use the same location as the bucket.
        #   kms_key_name = "projects/a/locations/b/keyRings/c/cryptoKeys/d"
        #   encryption = storage.encryption default_kms_key: kms_key_name
        #
        #   bucket = storage.create_bucket "my-bucket" do |b|
        #     b.encryption = encryption
        #   end
        #
        #   bucket.create_file "path/to/local.file.ext",
        #                      "destination/path/file.ext"
        #
        #   file = bucket.file "destination/path/file.ext"
        #   file.kms_key #=> kms_key_name
        #
        class Encryption
          ##
          # @private The Google API Client object.
          attr_accessor :gapi

          ##
          # @private Create an empty Storage::Bucket::Encryption object.
          def initialize
            @gapi = Google::Apis::StorageV1::Bucket::Encryption.new
          end

          ##
          # The Cloud KMS encryption key that will be used to protect files.
          # For example: `projects/a/locations/b/keyRings/c/cryptoKeys/d`
          #
          # @return [String, nil] A Cloud KMS encryption key, or `nil` if none
          #   has been configured.
          #
          # @example
          #   require "google/cloud/storage"
          #
          #   storage = Google::Cloud::Storage.new
          #
          #   # KMS key ring should use the same location as the bucket.
          #   kms_key_name = "projects/a/locations/b/keyRings/c/cryptoKeys/d"
          #   encryption = storage.encryption default_kms_key: kms_key_name
          #
          #   encryption.default_kms_key #=> kms_key_name
          #
          def default_kms_key
            @gapi.default_kms_key_name
          end

          ##
          # Set the Cloud KMS encryption key that will be used to protect files.
          # For example: `projects/a/locations/b/keyRings/c/cryptoKeys/d`
          #
          # @param [String] new_default_kms_key_name New Cloud KMS key name
          #
          # @example
          #   require "google/cloud/storage"
          #
          #   storage = Google::Cloud::Storage.new
          #
          #   # KMS key ring should use the same location as the bucket.
          #   kms_key_name = "projects/a/locations/b/keyRings/c/cryptoKeys/d"
          #   encryption = storage.encryption
          #
          #   encryption.default_kms_key = kms_key_name
          #
          def default_kms_key= new_default_kms_key_name
            frozen_check!
            @gapi.default_kms_key_name = new_default_kms_key_name
          end

          # @private
          def changed?
            return false if frozen?
            @original_json != @gapi.to_json
          end

          ##
          # @private Google API Client object.
          def to_gapi
            @gapi
          end

          ##
          # @private Google API Client object.
          def self.from_gapi gapi
            new_config = new
            new_config.instance_variable_set :@gapi, gapi
            new_config
          end

          # @private
          def == other
            return false unless other.is_a? Encryption
            to_gapi.to_json == other.to_gapi.to_json
          end

          protected

          def frozen_check!
            return unless frozen?
            raise ArgumentError, "Cannot modify a frozen encryption"
          end
        end
      end
    end
  end
end
