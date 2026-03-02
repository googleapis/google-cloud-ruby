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
  let(:customer_supplied_config) { Google::Apis::StorageV1::Bucket::Encryption::CustomerSuppliedEncryptionEnforcementConfig.new restriction_mode: "FullyRestricted" }
  let(:customer_managed_config) { Google::Apis::StorageV1::Bucket::Encryption::CustomerManagedEncryptionEnforcementConfig.new restriction_mode: "NotRestricted" }
  let(:google_managed_config) { Google::Apis::StorageV1::Bucket::Encryption::GoogleManagedEncryptionEnforcementConfig.new restriction_mode: "FullyRestricted" }
  let(:customer_supplied_config1) { Google::Apis::StorageV1::Bucket::Encryption::CustomerSuppliedEncryptionEnforcementConfig.new restriction_mode: "test" }
  let :bucket do
    b = storage.bucket(bucket_name) || storage.create_bucket(bucket_name, location: bucket_location)
    b.default_kms_key = kms_key
    b.google_managed_encryption_enforcement_config = google_managed_config
    b.customer_supplied_encryption_enforcement_config = customer_supplied_config
    b.customer_managed_encryption_enforcement_config = customer_managed_config
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
  describe "bucket encryption configuration" do

    it "knows its encryption configuration" do
      _(bucket.default_kms_key).wont_be :nil?
      _(bucket.default_kms_key).must_equal kms_key
      _(bucket.google_managed_encryption_enforcement_config).wont_be :nil?
      _(bucket.google_managed_encryption_enforcement_config.restriction_mode).must_equal "FullyRestricted"
      _(bucket.customer_supplied_encryption_enforcement_config).wont_be :nil?
      _(bucket.customer_supplied_encryption_enforcement_config.restriction_mode).must_equal "FullyRestricted"
      _(bucket.customer_managed_encryption_enforcement_config).wont_be :nil?
      _(bucket.customer_managed_encryption_enforcement_config.restriction_mode).must_equal "NotRestricted"
    
      bucket.reload!
      _(bucket.default_kms_key).wont_be :nil?
      _(bucket.default_kms_key).must_equal kms_key
      _(bucket.google_managed_encryption_enforcement_config).wont_be :nil?
      _(bucket.google_managed_encryption_enforcement_config.restriction_mode).must_equal "FullyRestricted"
      _(bucket.customer_supplied_encryption_enforcement_config).wont_be :nil?
      _(bucket.customer_supplied_encryption_enforcement_config.restriction_mode).must_equal "FullyRestricted"
      _(bucket.customer_managed_encryption_enforcement_config).wont_be :nil?
      _(bucket.customer_managed_encryption_enforcement_config.restriction_mode).must_equal "NotRestricted"
    end

    it "can update its default kms key to another key" do
      _(bucket.default_kms_key).must_equal kms_key
      bucket.default_kms_key = kms_key_2
      _(bucket.default_kms_key).must_equal kms_key_2
      bucket.reload!
      _(bucket.default_kms_key).must_equal kms_key_2
    end

    it "can remove its default kms key by setting encryption to nil" do
      _(bucket.default_kms_key).must_equal kms_key
      bucket.default_kms_key = nil
      _(bucket.default_kms_key).must_be :nil?
      bucket.reload!
      _(bucket.default_kms_key).must_be :nil?
    end

    it "can update its google managed encryption config to nil" do
      _(bucket.google_managed_encryption_enforcement_config).wont_be :nil?
      bucket.google_managed_encryption_enforcement_config = nil
      _(bucket.google_managed_encryption_enforcement_config).must_be :nil?
      bucket.reload!
      _(bucket.google_managed_encryption_enforcement_config).must_be :nil?
    end

    it "can update its customer supplied encryption config to nil" do
      _(bucket.customer_supplied_encryption_enforcement_config).wont_be :nil?
      bucket.customer_supplied_encryption_enforcement_config = nil
      _(bucket.customer_supplied_encryption_enforcement_config).must_be :nil?
      bucket.reload!
      _(bucket.customer_supplied_encryption_enforcement_config).must_be :nil?
    end

    it "can update its customer managed encryption config to nil" do
      _(bucket.customer_managed_encryption_enforcement_config).wont_be :nil?
      bucket.customer_managed_encryption_enforcement_config = nil
      _(bucket.customer_managed_encryption_enforcement_config).must_be :nil?
      bucket.reload!
      _(bucket.customer_managed_encryption_enforcement_config).must_be :nil?
    end

  end
end