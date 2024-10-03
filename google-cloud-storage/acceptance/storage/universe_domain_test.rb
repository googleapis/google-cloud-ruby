# Copyright 2024 Google LLC
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

require "storage_helper"

describe Google::Cloud::Storage, :universe_domain do
  Google::Apis.logger.level = Logger::DEBUG
  
    # Universe Domain Test project Credentials
  secret_project = 'cloud-devrel-kokoro-resources'
  secret_domain_id = 'client-library-test-universe-domain'
  secret_project_id = 'client-library-test-universe-project-id'
  secret_location_id = 'client-library-test-universe-storage-location'
  secret_version = 'latest'

  client = Google::Cloud::SecretManager.secret_manager_service
  ENV["TEST_UNIVERSE_DOMAIN"] = client.secret_version_path(
    project:        secret_project,
    secret:         secret_domain_id,
    secret_version: secret_version
  )
  ENV["TEST_UNIVERSE_PROJECT_ID"] = client.secret_version_path(
    project:        secret_project,
    secret:         secret_project_id,
    secret_version: secret_version
  )
  ENV["TEST_UNIVERSE_LOCATION"] = client.secret_version_path(
    project:        secret_project,
    secret:         secret_location_id,
    secret_version: secret_version
  )
  ENV["TEST_UNIVERSE_DOMAIN_CREDENTIAL"] = File.realpath(File.join(ENV['KOKORO_GFILE_DIR'], 'secret_manager', 'client-library-test-universe-domain-credential'))
  let :ud_storage do
    Google::Cloud::Storage.new(
      project_id: TEST_UNIVERSE_PROJECT_ID,
      credentials: TEST_UNIVERSE_DOMAIN_CREDENTIAL,
      universe_domain: TEST_UNIVERSE_DOMAIN
    )
  end
  let(:t) { Time.now.utc.iso8601.gsub ":", "-" }
  let(:ud_bucket_name) { "ud-test-ruby-bucket-#{t}-#{SecureRandom.hex(4)}".downcase }


  after do
    ud_bucket = ud_storage.bucket ud_bucket_name
    if ud_bucket
      ud_bucket.files.all &:delete
      safe_gcs_execute { ud_bucket.delete }
    end
  end

  it "creates a new bucket and uploads an object with universe_domain" do
    # Create a bucket
    ud_bucket = safe_gcs_execute { ud_storage.create_bucket ud_bucket_name, location: TEST_UNIVERSE_LOCATION }
    puts "shubhangi_ud_bucket: #{ud_bucket.inspect}"
    _(ud_bucket).wont_be_nil
    _(ud_bucket.name).must_equal ud_bucket_name

    # Upload an object
    ud_file_name = "ud-test-file"
    ud_payload = StringIO.new "Hello world!"
    ud_file = ud_bucket.create_file ud_payload, ud_file_name
    _(ud_file.name).must_equal ud_file_name

    # Read the file uploaded
    uploaded_ud_file = ud_bucket.file ud_file_name
    _(uploaded_ud_file.name).must_equal ud_file_name

    # Delete the object
    uploaded_ud_file.delete
    _(uploaded_ud_file).must_be_nil

    # Delete the bucket
    ud_bucket.delete
    _(ud_bucket).must_be_nil
  end
end
