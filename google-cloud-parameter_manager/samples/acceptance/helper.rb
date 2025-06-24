# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "minitest/autorun"
require "minitest/focus"
require "minitest/rg"

require "google/cloud/parameter_manager"
require "google/cloud/secret_manager"
require "google/cloud/kms"

require_relative "../../../.toys/.lib/sample_loader"

# Documentation for the ParameterManagerSnippetSpec class.
# This class is a custom test spec for the Parameter Manager snippets.
#
# It inherits from Minitest::Spec and provides additional setup and teardown
# functionality specific to Parameter Manager tests.
#
class ParameterManagerSnippetSpec < Minitest::Spec
  let(:client) { Google::Cloud::ParameterManager.parameter_manager }
  let(:secret_client) { Google::Cloud::SecretManager.secret_manager_service }
  let(:kms_client) { Google::Cloud::Kms.key_management_service }
  let(:project_id) { ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT") }

  let(:parameter_id) { "ruby-#{(Time.now.to_f * 1000).to_i}" }
  let(:parameter_id_1) { "ruby-#{(Time.now.to_f * 1000).to_i}" }
  let(:version_id) { "ruby-#{(Time.now.to_f * 1000).to_i}" }
  let(:version_id_1) { "ruby-#{(Time.now.to_f * 1000).to_i}" }
  let(:render_secret_id) { "ruby-#{(Time.now.to_f * 1000).to_i}" }

  let(:key_ring_id) { "ruby-parameter-manager-key" }
  let(:crypt_key_id1) { "ruby-#{(Time.now.to_f * 1000).to_i}" }
  let(:crypt_key_id2) { "ruby-#{(Time.now.to_f * 1000).to_i}" }

  let(:payload) { "test123" }
  let(:json_payload) { '{"username": "test-user", "host": "localhost"}' }
  let(:secret_id) { "projects/my-project/secrets/my-secret/versions/latest" }
  let(:format) { Google::Cloud::ParameterManager::V1::ParameterFormat::JSON }

  let(:project_name) { "projects/#{project_id}" }
  let(:location_name) { "projects/#{project_id}/locations/global" }
  let(:parameter_name) { "projects/#{project_id}/locations/global/parameters/#{parameter_id}" }
  let(:parameter_name_1) { "projects/#{project_id}/locations/global/parameters/#{parameter_id_1}" }
  let :parameter_version_name do
    "projects/#{project_id}/locations/global/parameters/#{parameter_id}/versions/#{version_id}"
  end
  let :parameter_version_name_1 do
    "projects/#{project_id}/locations/global/parameters/#{parameter_id}/versions/#{version_id_1}"
  end
  let(:secret_name) { "projects/#{project_id}/secrets/#{render_secret_id}" }
  let(:key_ring_name) { "projects/#{project_id}/locations/global/keyRings/#{key_ring_id}" }
  let(:crypt_key_id1_name) { "#{key_ring_name}/cryptoKeys/#{crypt_key_id1}" }
  let(:crypt_key_id2_name) { "#{key_ring_name}/cryptoKeys/#{crypt_key_id2}" }

  after do
    begin
      secret_client.delete_secret name: secret_name
    rescue Google::Cloud::NotFoundError
      # Do nothing for this specific error
    end
    begin
      client.delete_parameter_version name: parameter_version_name
    rescue Google::Cloud::NotFoundError
      # Do nothing for this specific error
    end
    begin
      client.delete_parameter_version name: parameter_version_name_1
    rescue Google::Cloud::NotFoundError
      # Do nothing for this specific error
    end
    begin
      client.delete_parameter name: parameter_name
    rescue Google::Cloud::NotFoundError
      # Do nothing for this specific error
    end
    begin
      client.delete_parameter name: parameter_name_1
    rescue Google::Cloud::NotFoundError
      # Do nothing for this specific error
    end
    destroy_key_versions
  end

  register_spec_type(self) { |*descs| descs.include? :parameter_manager_snippet }
end

def destroy_key_versions
  begin
    kms_client.destroy_crypto_key_version name: "#{crypt_key_id1_name}/cryptoKeyVersions/1"
  rescue Google::Cloud::NotFoundError
    # Do nothing for this specific error
  end
  begin
    kms_client.destroy_crypto_key_version name: "#{crypt_key_id2_name}/cryptoKeyVersions/1"
  rescue Google::Cloud::NotFoundError
    # Do nothing for this specific error
  end
end
