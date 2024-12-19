# Copyright 2020 Google, Inc
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

require "google/cloud/secret_manager"

require_relative "../../../.toys/.lib/sample_loader"

class SecretManagerSnippetSpec < Minitest::Spec
  let(:project_id) { ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT") }
  let(:location_id) { "us-west1" }
  let(:api_endpoint) { "secretmanager.#{location_id}.rep.googleapis.com" }
  let(:filter) { "name : ruby-quickstart-" }

  let :client do
    Google::Cloud::SecretManager.secret_manager_service do |config|
      config.endpoint = api_endpoint
    end
  end

  let(:secret_id) { "ruby-quickstart-#{(Time.now.to_f * 1000).to_i}" }
  let(:secret_name) { "projects/#{project_id}/locations/#{location_id}/secrets/#{secret_id}" }
  let(:iam_user) { "user:sarafy@google.com" }

  let :secret do
    client.create_secret(
      parent:    "projects/#{project_id}/locations/#{location_id}",
      secret_id: secret_id,
      secret:    {}
    )
  end

  let :secret_version do
    client.add_secret_version(
      parent:  secret.name,
      payload: {
        data: "hello world!"
      }
    )
  end

  let(:etag) { secret_version.etag }

  let(:version_id) { URI(secret_version.name).path.split("/").last }
  let(:version_name) { "projects/#{project_id}/locations/#{location_id}/secrets/#{secret_id}/versions/#{version_id}" }

  after do
    client.delete_secret name: secret_name
  rescue Google::Cloud::NotFoundError
    # Do nothing
  end

  register_spec_type(self) { |*descs| descs.include? :secret_manager_snippet }
end
