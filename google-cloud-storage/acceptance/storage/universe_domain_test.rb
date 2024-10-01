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

describe Google::Cloud::Storage do
  # Fetch secret values from the secret_manager path
  TEST_UNIVERSE_PROJECT_ID = File.read(File.realpath(File.join(ENV["KOKORO_GFILE_DIR"], "secret_manager", "client-library-test-universe-project-id")))
  TEST_UNIVERSE_LOCATION = File.read(File.realpath(File.join(ENV["KOKORO_GFILE_DIR"], "secret_manager", "client-library-test-universe-storage-location")))
  TEST_UNIVERSE_DOMAIN = File.read(File.realpath(File.join( ENV["KOKORO_GFILE_DIR"], "secret_manager", "client-library-test-universe-domain")))
  TEST_UNIVERSE_DOMAIN_CREDENTIAL = File.realpath(File.join( ENV["KOKORO_GFILE_DIR"], "secret_manager", "client-library-test-universe-domain-credential"))


  let :storage do
    # Fetching Universe Domain Test project Credentials
    Google::Cloud::Storage.new(
      project_id: TEST_UNIVERSE_PROJECT_ID,
      credentials: TEST_UNIVERSE_DOMAIN_CREDENTIAL,
      universe_domain: TEST_UNIVERSE_DOMAIN
    )
  end
  let(:bucket_name) { $bucket_names.first }
  let(:bucket_location) { TEST_UNIVERSE_LOCATION }
  let :bucket do
    storage.bucket(bucket_name) || safe_gcs_execute { storage.create_bucket bucket_name, location: bucket_location }
  end

  let :files do
    { logo: { path: "acceptance/data/CloudPlatform_128px_Retina.png" } }
  end

  before do
    # always create the bucket
    bucket
  end

  after :all do
    # Clean up: Ensure the bucket and objects are deleted after tests
    bucket = storage.bucket bucket_name
    if bucket
      bucket.files.each(&:delete) # Delete all objects in the bucket
      bucket.delete
    end
  end

  it "creates a new bucket with universe_domain" do
    # Verify that the bucket is created
    _(bucket.name).must_equal bucket_name
  end

  it "uploads an object form a path in the bucket" do
    # Upload an object
    object_name = "CloudLogo.png"
    original = File.new files[:logo][:path]
    uploaded_file = bucket.create_file original, "CloudLogo.png"
    # Verify object was uploaded
    _(uploaded_file.name).must_equal object_name

    # Retrive object
    retrieved_file = bucket.file object_name

    # Verify object
    _(retrieved_file.name).must_equal object_name
  end

  it "uploads and verifies an object in the bucket" do
    # Upload an object
    object_name = "test-object.txt"
    object_content = "Hello this a test file"
    uploaded_file = bucket.create_file StringIO.new(object_content), object_name

    # Verify object was uploaded
    _(uploaded_file.name).must_equal object_name

    # Verify object content
    retrieved_file = bucket.file object_name
    downloaded_content = retrieved_file.download.read
    _(downloaded_content).must_equal object_content
  end
end
