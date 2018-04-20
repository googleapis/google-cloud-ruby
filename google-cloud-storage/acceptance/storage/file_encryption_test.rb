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
require "net/http"
require "uri"
require "zlib"

describe Google::Cloud::Storage::File, :storage do
  let(:bucket_name) { $bucket_names.first }

  let(:files) do
    { logo: { path: "acceptance/data/CloudPlatform_128px_Retina.png" },
      big:  { path: "acceptance/data/three-mb-file.tif" } }
  end
  let(:file_path) { "CloudLogo.png" }

  let(:cipher) do
    cipher = OpenSSL::Cipher.new "aes-256-cfb"
    cipher.encrypt
    cipher
  end

  let(:encryption_key) { cipher.random_key }
  let(:encryption_key_2) { cipher.random_key }

  before do
    # always create the bucket
    bucket
  end

  after do
    bucket.files(versions: true).all { |f| f.delete generation: true rescue nil }
  end

  describe "customer-supplied encryption key (CSEK)" do
    let :bucket do
      storage.bucket(bucket_name) || storage.create_bucket(bucket_name)
    end

    it "should upload and download a file with customer-supplied encryption key" do
      original = File.new files[:logo][:path], "rb"
      uploaded = bucket.create_file original, file_path, encryption_key: encryption_key

      Tempfile.open ["CloudLogo", ".png"] do |tmpfile|
        downloaded = uploaded.download tmpfile.path, encryption_key: encryption_key

        downloaded.size.must_equal original.size
        downloaded.size.must_equal uploaded.size
        downloaded.size.must_equal original.size # Same file

        File.read(downloaded.path, mode: "rb").must_equal File.read(original.path, mode: "rb")
      end

      uploaded.delete
    end

    it "should upload and partially download a file with customer-supplied encryption key" do
      original = File.new files[:logo][:path], "rb"
      uploaded = bucket.create_file original, "CloudLogo.png", encryption_key: encryption_key

      Tempfile.open ["CloudLogo", ".png"] do |tmpfile|
        downloaded = uploaded.download tmpfile.path, range: 3..1024, encryption_key: encryption_key
        downloaded.size.must_equal 1022
        File.read(downloaded.path, mode: "rb").must_equal File.read(original.path, mode: "rb")[3..1024]
      end

      uploaded.delete
    end

    it "should copy an existing file with customer-supplied encryption key" do
      uploaded = bucket.create_file files[:logo][:path], file_path, encryption_key: encryption_key
      copied = try_with_backoff "copying existing file with encryption key" do
        uploaded.copy "CloudLogoCopy.png", encryption_key: encryption_key
      end
      uploaded.name.must_equal file_path
      copied.name.must_equal "CloudLogoCopy.png"
      copied.size.must_equal uploaded.size

      Tempfile.open ["CloudLogo", ".png"] do |tmpfile1|
        Tempfile.open ["CloudLogoCopy", ".png"] do |tmpfile2|
          downloaded1 = uploaded.download tmpfile1.path, encryption_key: encryption_key
          downloaded2 = copied.download tmpfile2.path, encryption_key: encryption_key
          downloaded1.size.must_equal downloaded2.size

          File.read(downloaded1.path, mode: "rb").must_equal File.read(downloaded2.path, mode: "rb")
        end
      end

      uploaded.delete
      copied.delete
    end

    it "should add, rotate, and remove customer-supplied encryption keys for an existing file" do
      uploaded = bucket.create_file files[:logo][:path], file_path

      rewritten = try_with_backoff "add encryption key" do
        uploaded.rotate new_encryption_key: encryption_key
      end
      rewritten.name.must_equal uploaded.name
      rewritten.size.must_equal uploaded.size

      rewritten2 = try_with_backoff "rotate encryption keys" do
        uploaded.rotate encryption_key: encryption_key, new_encryption_key: encryption_key_2
      end
      rewritten2.name.must_equal uploaded.name
      rewritten2.size.must_equal uploaded.size

      Tempfile.open ["CloudLogo", ".png"] do |tmpfile|
        downloaded = uploaded.download tmpfile.path, encryption_key: encryption_key_2
        downloaded.size.must_equal uploaded.size
      end

      rewritten4 = try_with_backoff "remove encryption key" do
        uploaded.rotate encryption_key: encryption_key_2
      end
      rewritten4.name.must_equal uploaded.name
      rewritten4.size.must_equal uploaded.size

      Tempfile.open ["CloudLogo", ".png"] do |tmpfile|
        downloaded = uploaded.download tmpfile.path
        downloaded.size.must_equal uploaded.size
      end

      rewritten4.delete
    end

    it "should compose existing files with customer-supplied encryption key into a new file with customer-supplied encryption key" do
      uploaded_a = bucket.create_file StringIO.new("a"), "a.txt", encryption_key: encryption_key
      uploaded_b = bucket.create_file StringIO.new("b"), "b.txt", encryption_key: encryption_key

      composed = try_with_backoff "copying existing file" do
        bucket.compose [uploaded_a, uploaded_b], "ab.txt", encryption_key: encryption_key
      end

      composed.name.must_equal "ab.txt"
      composed.size.must_equal uploaded_a.size + uploaded_b.size

      Tempfile.open ["ab", ".txt"] do |tmpfile|
        downloaded = composed.download tmpfile, encryption_key: encryption_key

        File.read(downloaded.path).must_equal "ab"
      end

      uploaded_a.delete
      uploaded_b.delete
      composed.delete
    end
  end

  describe "KMS customer-managed encryption key (CMEK)" do
    let(:kms_key) { "projects/helical-zone-771/locations/us-central1/keyRings/ruby-test/cryptoKeys/ruby-test-key-1" }
    let(:kms_key_2) { "projects/helical-zone-771/locations/us-central1/keyRings/ruby-test/cryptoKeys/ruby-test-key-2" }
    let(:encryption) { storage.encryption default_kms_key: kms_key }
    let :bucket do
      b = storage.bucket(bucket_name) || storage.create_bucket(bucket_name)
      b.encryption = encryption
      b
    end

    it "should upload and download a file with default_kms_key" do
      original = File.new files[:logo][:path], "rb"

      uploaded = bucket.create_file original, file_path
      uploaded.kms_key.must_equal versioned(kms_key)

      uploaded_copy = bucket.file file_path
      uploaded_copy.kms_key.must_equal versioned(kms_key)

      Tempfile.open ["CloudLogo", ".png"] do |tmpfile|
        downloaded = uploaded_copy.download tmpfile.path

        downloaded.size.must_equal original.size
        File.read(downloaded.path, mode: "rb").must_equal File.read(original.path, mode: "rb")
      end

      # Ensure kms_key is visible in file listings.
      uploaded_from_list = bucket.files.find { |f| f.name == file_path }
      uploaded_from_list.wont_be :nil?
      uploaded_from_list.kms_key.must_equal versioned(kms_key)

      uploaded_copy.delete
    end

    it "should upload and download a file with kms_key option" do
      bucket.encryption = nil
      original = File.new files[:logo][:path], "rb"

      bucket.encryption.must_be :nil?

      uploaded = bucket.create_file original, file_path, kms_key: kms_key_2
      uploaded.kms_key.must_equal versioned(kms_key_2)

      uploaded_copy = bucket.file file_path
      uploaded_copy.kms_key.must_equal versioned(kms_key_2)

      Tempfile.open ["CloudLogo", ".png"] do |tmpfile|
        downloaded = uploaded_copy.download tmpfile.path

        downloaded.size.must_equal original.size
        File.read(downloaded.path, mode: "rb").must_equal File.read(original.path, mode: "rb")
      end

      # Ensure kms_key is visible in file listings.
      uploaded_from_list = bucket.files.find { |f| f.name == file_path }
      uploaded_from_list.wont_be :nil?
      uploaded_from_list.kms_key.must_equal versioned(kms_key_2)

      uploaded_copy.delete
    end

    it "should upload a file with no kms key" do
      bucket.encryption = nil
      original = File.new files[:logo][:path], "rb"

      bucket.encryption.must_be :nil?

      uploaded = bucket.create_file original, file_path
      uploaded.kms_key.must_be :nil?

      uploaded_copy = bucket.file file_path
      uploaded_copy.kms_key.must_be :nil?

      uploaded_copy.delete
    end

    it "should rotate a customer-supplied encryption key (CSEK) to a kms key (CMEK), to no key and back to CSEK" do
      bucket.encryption = nil

      uploaded = bucket.create_file files[:logo][:path], file_path, encryption_key: encryption_key
      uploaded.kms_key.must_be :nil?

      rewritten = try_with_backoff "rotate from CSEK to CMEK" do
        uploaded.rotate encryption_key: encryption_key, new_kms_key: kms_key
      end
      rewritten.kms_key.must_equal versioned(kms_key)
      rewritten.size.must_equal uploaded.size

      Tempfile.open ["CloudLogo", ".png"] do |tmpfile|
        downloaded = rewritten.download tmpfile.path
        downloaded.size.must_equal uploaded.size
      end

      rewritten2 = try_with_backoff "rotate from CMEK to default encryption" do
        uploaded.rotate
      end
      rewritten2.kms_key.must_be :nil?
      rewritten2.size.must_equal uploaded.size

      Tempfile.open ["CloudLogo", ".png"] do |tmpfile|
        downloaded = rewritten2.download tmpfile.path
        downloaded.size.must_equal uploaded.size
      end

      rewritten3 = try_with_backoff "rotate from default encryption to CMEK" do
        uploaded.rotate  new_kms_key: kms_key_2
      end
      rewritten3.kms_key.must_equal versioned(kms_key_2)
      rewritten3.size.must_equal uploaded.size

      Tempfile.open ["CloudLogo", ".png"] do |tmpfile|
        downloaded = rewritten3.download tmpfile.path
        downloaded.size.must_equal uploaded.size
      end

      rewritten4 = try_with_backoff "rotate from CMEK to CSEK" do
        uploaded.rotate  new_encryption_key: encryption_key_2
      end
      rewritten4.kms_key.must_be :nil?
      rewritten4.size.must_equal uploaded.size

      Tempfile.open ["CloudLogo", ".png"] do |tmpfile|
        downloaded = rewritten4.download tmpfile.path, encryption_key: encryption_key_2
        downloaded.size.must_equal uploaded.size
      end

      rewritten4.delete
    end

    def versioned kms_key
      "#{kms_key}/cryptoKeyVersions/1"
    end
  end
end
