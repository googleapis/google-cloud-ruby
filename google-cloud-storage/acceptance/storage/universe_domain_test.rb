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


  let :universe_domain_storage do
    Google::Cloud::Storage.new(
      project_id: TEST_UNIVERSE_PROJECT_ID,
      keyfile: TEST_UNIVERSE_DOMAIN_CREDENTIAL,
      universe_domain: TEST_UNIVERSE_DOMAIN
    )
  end

  it "creates a new bucket and uploads an object with universe_domain" do
    # Create a bucket
    bucket_name = $bucket_names.first
    bucket = safe_gcs_execute { universe_domain_storage.create_bucket bucket_name, location: TEST_UNIVERSE_LOCATION }
    _(bucket.name).must_equal bucket_name

    # Upload an object
    file_name = "ud-test-file"
    payload = StringIO.new "Hello world!"
    file = bucket.create_file payload, file_name
    _(file.name).must_equal file_name

    # Delete the object
    file.delete
    file = bucket.file file_name
    _(file).must_be_nil

    # Delete the bucket
    bucket.delete
    _(bucket).must_be_nil
  end
end
