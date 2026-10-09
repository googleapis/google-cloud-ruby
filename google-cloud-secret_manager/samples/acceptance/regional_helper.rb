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

class RegionalSecretManagerSnippetSpec < Minitest::Spec
  let(:project_id) { ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT") }
  let(:location_id) { ENV["GOOGLE_LOCATION_ID"] || "us-west1" }

  let(:api_endpoint) { "secretmanager.#{location_id}.rep.googleapis.com" }
  let(:filter) { "name : ruby-quickstart-" }

  let(:annotation_key) { "annotation-key" }
  let(:annotation_value) { "annotation-value" }

  let(:updated_annotation_key) { "updated-annotation-key" }
  let(:updated_annotation_value) { "updated-annotation-value" }

  let(:label_key) { "label-key" }
  let(:label_value) { "label-value" }

  let(:time_to_live) { 86_400 }

  let :client do
    Google::Cloud::SecretManager.secret_manager_service do |config|
      config.endpoint = api_endpoint
    end
  end

  let(:secret_id) { "ruby-quickstart-#{(Time.now.to_f * 1000).to_i}" }
  let(:secret_name) { "projects/#{project_id}/locations/#{location_id}/secrets/#{secret_id}" }
  let(:iam_user) { "user:sarafy@google.com" }

  # Role granted to a Cloud SQL DB credentials secret's built-in identity so
  # that managed rotation can update the Cloud SQL user's password. This
  # grant is per-secret (the member is the secret's own generated
  # principal), so it has to be made fresh for every secret managed
  # rotation tests create.
  CLOUD_SQL_ROLE = "roles/cloudsql.admin".freeze

  let(:cloud_sql_instance_id) { ENV["CLOUD_SQL_INSTANCE"] || raise("missing CLOUD_SQL_INSTANCE") }
  let(:cloud_sql_username) { ENV["CLOUD_SQL_USER"] || raise("missing CLOUD_SQL_USER") }
  let(:projects_client) { Google::Cloud::ResourceManager::V3::Projects::Client.new }

  # A Cloud SQL DB credentials secret, created at the shared secret_name so
  # the existing `after` teardown below deletes it like any other secret.
  let :cloud_sql_credentials_secret do
    client.create_secret(
      parent:    "projects/#{project_id}/locations/#{location_id}",
      secret_id: secret_id,
      secret:    {
        secret_type: :CLOUD_SQL_DB_CREDENTIALS
      }
    )
  end

  # Grants CLOUD_SQL_ROLE to member on the project. set_iam_policy replaces
  # the whole policy, so this reads the current policy, adds the member to
  # the existing (or a new) binding for the role, and writes it back --
  # retrying the whole read-modify-write if another writer raced us, or if
  # a transient error (e.g. an etag conflict or a momentary Unavailable)
  # got in the way.
  def grant_cloud_sql_role member
    resource = "projects/#{project_id}"
    retry_cloud_sql_iam_call do
      policy = projects_client.get_iam_policy resource: resource
      binding = policy.bindings.find { |b| b.role == CLOUD_SQL_ROLE }
      if binding
        binding.members << member unless binding.members.include? member
      else
        policy.bindings << Google::Iam::V1::Binding.new(role: CLOUD_SQL_ROLE, members: [member])
      end
      projects_client.set_iam_policy resource: resource, policy: policy
    end
    # IAM grants are eventually consistent; give it a moment before a
    # caller tries to use it for managed rotation.
    sleep 10
  end

  # Removes member from CLOUD_SQL_ROLE on the project, added by grant_cloud_sql_role.
  def revoke_cloud_sql_role member
    resource = "projects/#{project_id}"
    retry_cloud_sql_iam_call do
      policy = projects_client.get_iam_policy resource: resource
      changed = false
      policy.bindings.each do |binding|
        next unless binding.role == CLOUD_SQL_ROLE && binding.members.include?(member)
        binding.members.delete member
        changed = true
      end
      projects_client.set_iam_policy resource: resource, policy: policy if changed
    end
  end

  CLOUD_SQL_IAM_RETRY_INTERVAL = 15
  CLOUD_SQL_IAM_RETRY_MAX_DURATION = 60

  # Retries a project IAM policy read-modify-write for up to
  # CLOUD_SQL_IAM_RETRY_MAX_DURATION seconds, logging each attempt. Mirrors
  # the time-boxed, broad-rescue pattern already used by
  # cleanup_tag_value/cleanup_tag_key in create_secret_with_tags_test.rb --
  # a plain attempt-count retry limited to AbortedError missed a transient
  # Google::Cloud::UnavailableError observed live against a real project.
  def retry_cloud_sql_iam_call
    end_time = Time.now + CLOUD_SQL_IAM_RETRY_MAX_DURATION
    begin
      yield
    rescue StandardError => e
      raise if Time.now >= end_time
      puts "An error occurred updating the Cloud SQL IAM policy: #{e.message}. Retrying."
      sleep CLOUD_SQL_IAM_RETRY_INTERVAL
      retry
    end
  end

  let :secret do
    client.create_secret(
      parent:    "projects/#{project_id}/locations/#{location_id}",
      secret_id: secret_id,
      secret:    {
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

  let(:etag) { secret_version.etag }

  let(:version_id) { URI(secret_version.name).path.split("/").last }
  let(:version_name) { "projects/#{project_id}/locations/#{location_id}/secrets/#{secret_id}/versions/#{version_id}" }

  after do
    client.delete_secret name: secret_name
  rescue Google::Cloud::NotFoundError
    # Do nothing
  end

  register_spec_type(self) { |*descs| descs.include? :regional_secret_manager_snippet }
end
