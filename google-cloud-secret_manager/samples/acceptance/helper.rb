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
require "google/cloud/resource_manager/v3"

require_relative "../../../.toys/.lib/sample_loader"

class SecretManagerSnippetSpec < Minitest::Spec
  let(:client) { Google::Cloud::SecretManager.secret_manager_service }
  let(:project_id) { ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT") }

  let(:secret_id) { "ruby-quickstart-#{(Time.now.to_f * 1000).to_i}" }
  let(:secret_name) { "projects/#{project_id}/secrets/#{secret_id}" }

  let(:iam_user) { "user:sethvargo@google.com" }

  let(:annotation_key) { "annotation-key" }
  let(:annotation_value) { "annotation-value" }

  let(:updated_annotation_key) { "updated-annotation-key" }
  let(:updated_annotation_value) { "updated-annotation-value" }

  let(:label_key) { "label-key" }
  let(:label_value) { "label-value" }

  let(:time_to_live) { 86_400 }

  let :secret do
    client.create_secret(
      parent:    "projects/#{project_id}",
      secret_id: secret_id,
      secret:    {
        replication: {
          automatic: {}
        },
        annotations: {
          annotation_key => annotation_value
        },
        labels: {
          label_key => label_value
        }
      }
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

  let(:version_id) { URI(secret_version.name).path.split("/").last }
  let(:version_name) { "projects/#{project_id}/secrets/#{secret_id}/versions/#{version_id}" }

  after do
    client.delete_secret name: secret_name
  rescue Google::Cloud::NotFoundError
    # Do nothing
  end

  register_spec_type(self) { |*descs| descs.include? :secret_manager_snippet }
end
