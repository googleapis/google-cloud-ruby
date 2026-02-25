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

  before(:all) do
    # always create the bucket
    @bucket = bucket
  end

  after(:all) do
    @bucket.files.all &:delete
    safe_gcs_execute { @bucket.delete }
  end

  let(:files) do
    { logo: { path: "acceptance/data/CloudPlatform_128px_Retina.png" },
      big:  { path: "acceptance/data/three-mb-file.tif" } }
  end
  describe "KMS customer-managed encryption key (CMEK)" do

    it "knows its encryption configuration" do
      _(@bucket.default_kms_key).wont_be :nil?
      _(@bucket.default_kms_key).must_equal kms_key
      @bucket.reload!
      _(@bucket.default_kms_key).wont_be :nil?
      _(@bucket.default_kms_key).must_equal kms_key
    end

    it "can update its default kms key to another key" do
      _(@bucket.default_kms_key).must_equal kms_key
      @bucket.default_kms_key = kms_key_2
      _(@bucket.default_kms_key).must_equal kms_key_2
      @bucket.reload!
      _(@bucket.default_kms_key).must_equal kms_key_2
    end

    it "can remove its default kms key by setting encryption to nil" do
      _(@bucket.default_kms_key).must_equal kms_key
      @bucket.default_kms_key = nil
      _(@bucket.default_kms_key).must_be :nil?
      @bucket.reload!
      _(@bucket.default_kms_key).must_be :nil?
    end
  end

  describe "bucket encryption enforcement config" do
    customer_supplied_config = Google::Apis::StorageV1::Bucket::Encryption::CustomerSuppliedEncryptionEnforcementConfig.new restriction_mode: "FullyRestricted"
    customer_managed_config = Google::Apis::StorageV1::Bucket::Encryption::CustomerManagedEncryptionEnforcementConfig.new restriction_mode: "NotRestricted"
    google_managed_config = Google::Apis::StorageV1::Bucket::Encryption::GoogleManagedEncryptionEnforcementConfig.new restriction_mode: "FullyRestricted"
 
    it "gets, sets and clears customer supplied encryption enforcement config" do
      # set customer supplied encryption enforcement config to bucket
      @bucket.customer_supplied_encryption_enforcement_config = customer_supplied_config
      @bucket.reload!
      # get customer supplied encryption enforcement config from bucket and verify its values
      _(@bucket.customer_supplied_encryption_enforcement_config).wont_be_nil
      _(@bucket.customer_supplied_encryption_enforcement_config.restriction_mode).must_equal "FullyRestricted"
      # clear customer supplied encryption enforcement config from bucket
      @bucket.customer_supplied_encryption_enforcement_config = nil
      @bucket.reload!
      _(@bucket.customer_supplied_encryption_enforcement_config).must_be_nil
    end

    it "gets, sets and clears customer managed encryption enforcement config" do
      # set customer managed encryption enforcement config to bucket   
      @bucket.customer_managed_encryption_enforcement_config = customer_managed_config
      @bucket.reload!
      # get customer managed encryption enforcement config from bucket and verify its values
      _(@bucket.customer_managed_encryption_enforcement_config).wont_be_nil
      _(@bucket.customer_managed_encryption_enforcement_config.restriction_mode).must_equal "NotRestricted"
      # clear customer managed encryption enforcement config from bucket
      @bucket.customer_managed_encryption_enforcement_config = nil
      @bucket.reload!
      _(@bucket.customer_managed_encryption_enforcement_config).must_be_nil
    end

    it "gets, sets and clears google managed encryption enforcement config" do
      # set google managed encryption enforcement config to bucket    
      @bucket.google_managed_encryption_enforcement_config = google_managed_config
      @bucket.reload!
      # get google managed encryption enforcement config from bucket and verify its values
      _(@bucket.google_managed_encryption_enforcement_config).wont_be_nil
      _(@bucket.google_managed_encryption_enforcement_config.restriction_mode).must_equal "FullyRestricted"
      # clear google managed encryption enforcement config from bucket
      @bucket.google_managed_encryption_enforcement_config = nil
      @bucket.reload!
      _(@bucket.google_managed_encryption_enforcement_config).must_be_nil
    end

    it "raises error when setting invalid encryption enforcement config" do
      customer_supplied_config1 = Google::Apis::StorageV1::Bucket::Encryption::CustomerSuppliedEncryptionEnforcementConfig.new restriction_mode: "test"
      expect {@bucket.customer_supplied_encryption_enforcement_config = customer_supplied_config1}.must_raise Google::Cloud::InvalidArgumentError
    end

    it "setting and clearing encryption enforcement config does not affect bucket's default kms key" do
      # set default kms key to bucket
      @bucket.google_managed_encryption_enforcement_config = google_managed_config
      @bucket.reload!
      # verify default kms key is set
      _(@bucket.default_kms_key).must_equal kms_key
      # clear encryption enforcement config
      @bucket.customer_supplied_encryption_enforcement_config = nil
      @bucket.customer_managed_encryption_enforcement_config = nil
      @bucket.google_managed_encryption_enforcement_config = nil
      @bucket.reload!
      # verify default kms key is still set
      _(@bucket.default_kms_key).must_equal kms_key
    end
  end
end
