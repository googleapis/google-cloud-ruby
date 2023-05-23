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

require_relative "helper"

describe "Secret Manager Quickstart" do
  let(:client) { Google::Cloud::SecretManager.secret_manager_service }
  let(:project_id) { ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT") }

  let(:secret_id) { "ruby-quickstart-#{(Time.now.to_f * 1000).to_i}" }
  let(:secret_name) { "projects/#{project_id}/secrets/#{secret_id}" }

  after do
    client.delete_secret name: secret_name
  rescue Google::Cloud::NotFoundError
    # Do nothing
  end

  it "creates and accesses a secret" do
    sample = SampleLoader.load "quickstart.rb"

    assert_output "Plaintext: hello world!\n" do
      sample.run project_id: project_id, secret_id: secret_id
    end

    secret = client.get_secret name: secret_name
    refute_nil secret

    versions = client.list_secret_versions parent: secret_name
    refute_empty versions.to_a

    version = client.access_secret_version name: "#{secret_name}/versions/latest"
    refute_nil version
    assert_equal "hello world!", version.payload.data
  end
end
