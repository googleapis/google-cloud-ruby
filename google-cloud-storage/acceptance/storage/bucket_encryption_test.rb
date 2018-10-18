# Copyright 2018 Google LLC
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

describe Google::Cloud::Storage::Bucket, :encryption, :storage do
  let(:bucket_name) { "#{$bucket_names[1]}-encryption" }
  let(:bucket_location) { "us-central1" }
  let(:kms_key) {
    ENV["GCLOUD_TEST_STORAGE_KMS_KEY_1"] ||
      "projects/#{storage.project_id}/locations/#{bucket_location}/keyRings/ruby-test/cryptoKeys/ruby-test-key-1"
  }
  let(:kms_key_2) {
    ENV["GCLOUD_TEST_STORAGE_KMS_KEY_2"] ||
      "projects/#{storage.project_id}/locations/#{bucket_location}/keyRings/ruby-test/cryptoKeys/ruby-test-key-2"
  }
  let :bucket do
    b = safe_gcs_execute { storage.create_bucket(bucket_name, location: bucket_location) }
    b.default_kms_key = kms_key
    b
  end

  before do
    # always create the bucket
    bucket
  end

  after do
    bucket.files.all &:delete
    safe_gcs_execute { bucket.delete }
  end

  let(:files) do
    { logo: { path: "acceptance/data/CloudPlatform_128px_Retina.png" },
      big:  { path: "acceptance/data/three-mb-file.tif" } }
  end
  describe "KMS customer-managed encryption key (CMEK)" do

    it "knows its encryption configuration" do
      bucket.default_kms_key.wont_be :nil?
      bucket.default_kms_key.must_equal kms_key
      bucket.reload!
      bucket.default_kms_key.wont_be :nil?
      bucket.default_kms_key.must_equal kms_key
    end

    it "can update its default kms key to another key" do
      bucket.default_kms_key.must_equal kms_key
      bucket.default_kms_key = kms_key_2
      bucket.default_kms_key.must_equal kms_key_2
      bucket.reload!
      bucket.default_kms_key.must_equal kms_key_2
    end

    it "can remove its default kms key by setting encryption to nil" do
      bucket.default_kms_key.must_equal kms_key
      bucket.default_kms_key = nil
      bucket.default_kms_key.must_be :nil?
      bucket.reload!
      bucket.default_kms_key.must_be :nil?
    end
  end
end
