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

require_relative "../../../.toys/.lib/sample_loader"

# Documentation for the RegionalParameterManagerSnippetSpec class.
# This class is a custom test spec for the regional Parameter Manager snippets.
#
# It inherits from Minitest::Spec and provides additional setup and teardown
# functionality specific to regional Parameter Manager tests.
#
class RegionalParameterManagerSnippetSpec < Minitest::Spec
  let(:project_id) { ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT") }
  let(:location_id) { ENV["GOOGLE_CLOUD_LOCATION"] || "us-central1" }

  let(:api_endpoint) { "parametermanager.#{location_id}.rep.googleapis.com" }
  let(:secret_api_endpoint) { "secretmanager.#{location_id}.rep.googleapis.com" }

  let(:parameter_id) { "ruby-#{(Time.now.to_f * 1000).to_i}" }
  let(:parameter_id_1) { "ruby-#{(Time.now.to_f * 1000).to_i}" }
  let(:version_id) { "ruby-#{(Time.now.to_f * 1000).to_i}" }
  let(:version_id_1) { "ruby-#{(Time.now.to_f * 1000).to_i}" }
  let(:render_secret_id) { "ruby-#{(Time.now.to_f * 1000).to_i}" }

  let(:payload) { "test123" }
  let(:json_payload) { '{"username": "test-user", "host": "localhost"}' }
  let(:secret_id) { "projects/my-project/locations/us-central1/secrets/my-secret/versions/latest" }
  let(:format) { Google::Cloud::ParameterManager::V1::ParameterFormat::JSON }

  let(:location_name) { "projects/#{project_id}/locations/#{location_id}" }
  let(:parameter_name) { "projects/#{project_id}/locations/#{location_id}/parameters/#{parameter_id}" }
  let(:parameter_name_1) { "projects/#{project_id}/locations/#{location_id}/parameters/#{parameter_id_1}" }
  let :parameter_version_name do
    "projects/#{project_id}/locations/#{location_id}/parameters/#{parameter_id}/versions/#{version_id}"
  end
  let :parameter_version_name_1 do
    "projects/#{project_id}/locations/#{location_id}/parameters/#{parameter_id}/versions/#{version_id_1}"
  end
  let(:secret_name) { "projects/#{project_id}/locations/#{location_id}/secrets/#{render_secret_id}" }

  let :client do
    Google::Cloud::ParameterManager.parameter_manager do |config|
      config.endpoint = api_endpoint
    end
  end

  let :secret_client do
    Google::Cloud::SecretManager.secret_manager_service do |config|
      config.endpoint = secret_api_endpoint
    end
  end

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
  end

  register_spec_type(self) { |*descs| descs.include? :regional_parameter_manager_snippet }
end
