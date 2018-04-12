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

describe Google::Cloud::Storage::Bucket::Encryption, :storage do
  let(:bucket_name) { $bucket_names.first + "-encryption" }
  let(:kms_key) { "projects/helical-zone-771/locations/us-central1/keyRings/ruby-test/cryptoKeys/ruby-test-key-1" }
  let(:kms_key_2) { "projects/helical-zone-771/locations/us-central1/keyRings/ruby-test/cryptoKeys/ruby-test-key-2" }
  let(:encryption) { storage.encryption default_kms_key: kms_key }
  let :bucket do
    storage.bucket(bucket_name) ||
        storage.create_bucket(bucket_name) do |b|
          b.encryption = encryption
        end
  end

  let(:files) do
    { logo: { path: "acceptance/data/CloudPlatform_128px_Retina.png" },
      big:  { path: "acceptance/data/three-mb-file.tif" } }
  end

  it "knows its encryption configuration" do
    bucket.encryption.wont_be :nil?
    bucket.encryption.default_kms_key.wont_be :nil?
    bucket.reload!
    bucket.encryption.wont_be :nil?
    bucket.encryption.default_kms_key.wont_be :nil?
  end

  it "can update its default customer-managed encryption key to another key" do
    bucket.encryption.default_kms_key.wont_be :nil?
    bucket.encryption = storage.encryption(default_kms_key: kms_key_2)
    bucket.encryption.default_kms_key.must_equal kms_key_2
    bucket.reload!
    bucket.encryption.default_kms_key.must_equal kms_key_2

    bucket.encryption = storage.encryption(default_kms_key: kms_key)
  end

  it "can remove its default customer-managed encryption key by setting encryption to nil" do
    bucket.encryption.default_kms_key.must_equal kms_key
    bucket.encryption = nil
    bucket.encryption.must_be :nil?
    bucket.reload!
    bucket.encryption.must_be :nil?

    bucket.encryption = storage.encryption(default_kms_key: kms_key)
  end

  it "can remove its default customer-managed encryption key by setting encryption default_kms_key to nil" do
    skip "Fails with Expected 'projects/helical-zone-771/locations/us-central1/keyRings/ruby-test/cryptoKeys/ruby-test-key-1' to be nil?."
    bucket.encryption.default_kms_key.must_equal kms_key
    bucket.encryption = storage.encryption(default_kms_key: nil)
    bucket.encryption.default_kms_key.must_be :nil?
    bucket.reload!
    bucket.encryption.default_kms_key.must_be :nil?

    bucket.encryption = storage.encryption(default_kms_key: kms_key)
  end

  it "should upload and download a file with default customer-managed encryption key" do
    original = File.new files[:logo][:path], "rb"

    uploaded = bucket.create_file original, "CloudLogo.png"
    uploaded.kms_key.wont_be :nil?

    uploaded_copy = bucket.file "CloudLogo.png"
    uploaded_copy.kms_key.wont_be :nil?

    Tempfile.open ["CloudLogo", ".png"] do |tmpfile|
      downloaded = uploaded_copy.download tmpfile.path

      downloaded.size.must_equal original.size
      File.read(downloaded.path, mode: "rb").must_equal File.read(original.path, mode: "rb")
    end

    uploaded_copy.delete
  end
end
