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

require "google/apis/bigquery_v2"

module Google
  module Cloud
    module Bigquery
      ##
      # # Encryption Configuration
      #
      # A builder for BigQuery table encryption configurations, passed to block
      # arguments to {Dataset#create_table} and
      # {Table#encryption_configuration}.
      #
      # @see https://cloud.google.com/bigquery/docs/customer-managed-encryption
      #   Protecting Data with Cloud KMS Keys
      #
      # @example
      #   require "google/cloud/bigquery"
      #
      #   bigquery = Google::Cloud::Bigquery.new
      #   dataset = bigquery.dataset "my_dataset"
      #   encrypt_config = Google::Cloud::Bigquery::EncryptionConfiguration.new
      #   encrypt_config.kms_key_name = "my_key_name"
      #   table = dataset.create_table "my_table",
      #                                encryption_configuration: encrypt_config
      #
      class EncryptionConfiguration
        ##
        # @private The Google API Client object.
        attr_accessor :gapi

        ##
        # @private Create an empty EncryptionConfiguration object.
        def initialize
          @gapi = Google::Apis::BigqueryV2::EncryptionConfiguration.new
        end

        ##
        # The Cloud KMS encryption key that will be used to protect the table.
        # For example: `projects/a/locations/b/keyRings/c/cryptoKeys/d`
        # The default value is `nil`, which means default encryption is used.
        #
        # @return [String]
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   config = Google::Cloud::Bigquery::EncryptionConfiguration.new
        #   key_name = "projects/a/locations/b/keyRings/c/cryptoKeys/d"
        #   config.kms_key_name = key_name
        #
        def kms_key_name
          @gapi.kms_key_name
        end

        ##
        # Set the Cloud KMS encryption key that will be used to protect the
        # table. For example: `projects/a/locations/b/keyRings/c/cryptoKeys/d`
        # The default value is `nil`, which means default encryption is used.
        #
        # @param [String] new_kms_key_name New Cloud KMS key name
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   config = Google::Cloud::Bigquery::EncryptionConfiguration.new
        #   key_name = "projects/a/locations/b/keyRings/c/cryptoKeys/d"
        #   config.kms_key_name = key_name
        #
        def kms_key_name= new_kms_key_name
          frozen_check!
          @gapi.kms_key_name = new_kms_key_name
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
          return false unless other.is_a? EncryptionConfiguration
          to_gapi.to_json == other.to_gapi.to_json
        end

        protected

        def frozen_check!
          return unless frozen?
          raise ArgumentError, "Cannot modify a frozen encryption configuration"
        end
      end
    end
  end
end
