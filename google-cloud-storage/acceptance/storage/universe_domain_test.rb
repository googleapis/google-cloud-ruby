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
  
  # Fetch secret values from the secret_manager path
  TEST_UNIVERSE_PROJECT_ID = File.read(File.realpath(File.join(ENV["KOKORO_GFILE_DIR"], "secret_manager", "client-library-test-universe-project-id")))
  TEST_UNIVERSE_LOCATION = File.read(File.realpath(File.join(ENV["KOKORO_GFILE_DIR"], "secret_manager", "client-library-test-universe-storage-location")))
  TEST_UNIVERSE_DOMAIN = File.read(File.realpath(File.join( ENV["KOKORO_GFILE_DIR"], "secret_manager", "client-library-test-universe-domain")))
  TEST_UNIVERSE_DOMAIN_CREDENTIAL = File.realpath(File.join( ENV["KOKORO_GFILE_DIR"], "secret_manager", "client-library-test-universe-domain-credential"))

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

  it "validates presense of test project secret values" do
    refute_nil TEST_UNIVERSE_PROJECT_ID, "TEST_UNIVERSE_PROJECT_ID should not be nil"
    refute_nil TEST_UNIVERSE_LOCATION, "TEST_UNIVERSE_LOCATION should not be nil"
    refute_nil TEST_UNIVERSE_DOMAIN, "TEST_UNIVERSE_DOMAIN should not be nil"
    refute_nil TEST_UNIVERSE_DOMAIN_CREDENTIAL, "TEST_UNIVERSE_DOMAIN_CREDENTIAL should not be nil"
  end

  it "creates a new bucket and uploads an object with universe_domain" do
    # Create a bucket
    ud_bucket =  ud_storage.create_bucket ud_bucket_name, location: TEST_UNIVERSE_LOCATION 
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
    _(ud_bucket.file uploaded_ud_file.name).must_be_nil

    # Delete the bucket
    ud_bucket.delete
    bucket= ud_storage.bucket ud_bucket_name
    assert_nil bucket, "Bucket #{ud_bucket_name} should not exist"

  end
end
