# Copyright 2014 Google Inc. All rights reserved.
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

require "helper"
require "json"
require "uri"

describe Gcloud::Storage::File, :mock_storage do
  let(:bucket_gapi) { Google::Apis::StorageV1::Bucket.from_json random_bucket_hash("bucket").to_json }
  let(:bucket) { Gcloud::Storage::Bucket.from_gapi bucket_gapi, storage.service }

  let(:file_hash) { random_file_hash bucket.name, "file.ext" }
  let(:file_gapi) { Google::Apis::StorageV1::Object.from_json file_hash.to_json }
  let(:file) { Gcloud::Storage::File.from_gapi file_gapi, storage.service }

  let(:encryption_key) { "y\x03\"\x0E\xB6\xD3\x9B\x0E\xAB*\x19\xFAv\xDEY\xBEI\xF8ftA|[z\x1A\xFBE\xDE\x97&\xBC\xC7" }
  let(:encryption_key_sha256) { "5\x04_\xDF\x1D\x8A_d\xFEK\e6p[XZz\x13s]E\xF6\xBB\x10aQH\xF6o\x14f\xF9" }
  let(:key_options) do { header: {
      "x-goog-encryption-algorithm"  => "AES256",
      "x-goog-encryption-key"        => Base64.encode64(encryption_key),
      "x-goog-encryption-key-sha256" => Base64.encode64(encryption_key_sha256)
    } }
  end

  it "knows its attributes" do
    file.id.must_equal file_hash["id"]
    file.name.must_equal file_hash["name"]
    file.created_at.must_be_within_delta file_hash["timeCreated"].to_datetime
    file.api_url.must_equal file_hash["selfLink"]
    file.media_url.must_equal file_hash["mediaLink"]
    file.public_url.must_equal "https://storage.googleapis.com/#{file.bucket}/#{file.name}"
    file.public_url(protocol: :http).must_equal "http://storage.googleapis.com/#{file.bucket}/#{file.name}"
    file.url.must_equal file.public_url

    file.md5.must_equal file_hash["md5Hash"]
    file.crc32c.must_equal file_hash["crc32c"]
    file.etag.must_equal file_hash["etag"]

    file.cache_control.must_equal "public, max-age=3600"
    file.content_disposition.must_equal "attachment; filename=filename.ext"
    file.content_encoding.must_equal "gzip"
    file.content_language.must_equal "en"
    file.content_type.must_equal "text/plain"

    file.metadata.must_be_kind_of Hash
    file.metadata.size.must_equal 2
    file.metadata.frozen?.must_equal true
    file.metadata["player"].must_equal "Alice"
    file.metadata["score"].must_equal "101"
  end

  it "can delete itself" do
    mock = Minitest::Mock.new
    mock.expect :delete_object, nil, [bucket.name, file.name]

    file.service.mocked_service = mock

    file.delete

    mock.verify
  end

  it "can download itself" do
    # Stub the md5 to match.
    def file.md5
      "1B2M2Y8AsgTpgAmY7PhCfg=="
    end

    Tempfile.open "gcloud-ruby" do |tmpfile|
      # write to the file since the mocked call won't
      tmpfile.write "yay!"

      mock = Minitest::Mock.new
      mock.expect :get_object, file_gapi,
        [bucket.name, file.name, download_dest: tmpfile, generation: nil, options: {}]

      bucket.service.mocked_service = mock

      file.download tmpfile

      mock.verify
    end
  end

  it "can download itself with customer-supplied encryption key" do
    # Stub the md5 to match.
    def file.md5
      "1B2M2Y8AsgTpgAmY7PhCfg=="
    end

    Tempfile.open "gcloud-ruby" do |tmpfile|
      # write to the file since the mocked call won't
      tmpfile.write "yay!"

      mock = Minitest::Mock.new
      mock.expect :get_object, file_gapi,
        [bucket.name, file.name, download_dest: tmpfile, generation: nil, options: key_options]

      bucket.service.mocked_service = mock

      file.download tmpfile, encryption_key: encryption_key

      mock.verify
    end
  end

  it "can download itself with customer-supplied encryption key and sha" do
    # Stub the md5 to match.
    def file.md5
      "1B2M2Y8AsgTpgAmY7PhCfg=="
    end

    Tempfile.open "gcloud-ruby" do |tmpfile|
      # write to the file since the mocked call won't
      tmpfile.write "yay!"

      mock = Minitest::Mock.new
      mock.expect :get_object, file_gapi,
        [bucket.name, file.name, download_dest: tmpfile, generation: nil, options: key_options]

      bucket.service.mocked_service = mock

      file.download tmpfile, encryption_key: encryption_key, encryption_key_sha256: encryption_key_sha256

      mock.verify
    end
  end

  describe "verified downloads" do
    it "verifies m5d by default" do
      # Stub these values
      def file.md5; "md5="; end
      def file.crc32c; "crc32c="; end

      Tempfile.open "gcloud-ruby" do |tmpfile|
        mock = Minitest::Mock.new
        mock.expect :get_object, file_gapi,
          [bucket.name, file.name, download_dest: tmpfile, generation: nil, options: {}]

        bucket.service.mocked_service = mock

        mocked_md5 = Minitest::Mock.new
        mocked_md5.expect :md5_mock, file.md5
        stubbed_md5 = lambda { |_| mocked_md5.md5_mock }
        stubbed_crc32c = lambda { |_| fail "Should not be called!" }

        Gcloud::Storage::File::Verifier.stub :md5_for, stubbed_md5 do
          Gcloud::Storage::File::Verifier.stub :crc32c_for, stubbed_crc32c do
            file.download tmpfile
          end
        end
        mocked_md5.verify
        mock.verify
      end
    end

    it "verifies m5d when specified" do
      # Stub these values
      def file.md5; "md5="; end
      def file.crc32c; "crc32c="; end

      Tempfile.open "gcloud-ruby" do |tmpfile|
        mock = Minitest::Mock.new
        mock.expect :get_object, file_gapi,
          [bucket.name, file.name, download_dest: tmpfile, generation: nil, options: {}]

        bucket.service.mocked_service = mock

        mocked_md5 = Minitest::Mock.new
        mocked_md5.expect :md5_mock, file.md5
        stubbed_md5 = lambda { |_| mocked_md5.md5_mock }
        stubbed_crc32c = lambda { |_| fail "Should not be called!" }

        Gcloud::Storage::File::Verifier.stub :md5_for, stubbed_md5 do
          Gcloud::Storage::File::Verifier.stub :crc32c_for, stubbed_crc32c do
            file.download tmpfile, verify: :md5
          end
        end
        mocked_md5.verify
        mock.verify
      end
    end

    it "verifies crc32c when specified" do
      # Stub these values
      def file.md5; "md5="; end
      def file.crc32c; "crc32c="; end

      Tempfile.open "gcloud-ruby" do |tmpfile|
        mock = Minitest::Mock.new
        mock.expect :get_object, file_gapi,
          [bucket.name, file.name, download_dest: tmpfile, generation: nil, options: {}]

        bucket.service.mocked_service = mock

        stubbed_md5 = lambda { |_| fail "Should not be called!" }
        mocked_crc32c = Minitest::Mock.new
        mocked_crc32c.expect :crc32c_mock, file.crc32c
        stubbed_crc32c = lambda { |_| mocked_crc32c.crc32c_mock }

        Gcloud::Storage::File::Verifier.stub :md5_for, stubbed_md5 do
          Gcloud::Storage::File::Verifier.stub :crc32c_for, stubbed_crc32c do
            file.download tmpfile, verify: :crc32c
          end
        end
        mocked_crc32c.verify
        mock.verify
      end
    end

    it "verifies m5d and crc32c when specified" do
      # Stub these values
      def file.md5; "md5="; end
      def file.crc32c; "crc32c="; end

      Tempfile.open "gcloud-ruby" do |tmpfile|
        mock = Minitest::Mock.new
        mock.expect :get_object, file_gapi,
          [bucket.name, file.name, download_dest: tmpfile, generation: nil, options: {}]

        bucket.service.mocked_service = mock

        mocked_md5 = Minitest::Mock.new
        mocked_md5.expect :md5_mock, file.md5
        stubbed_md5 = lambda { |_| mocked_md5.md5_mock }

        mocked_crc32c = Minitest::Mock.new
        mocked_crc32c.expect :crc32c_mock, file.crc32c
        stubbed_crc32c = lambda { |_| mocked_crc32c.crc32c_mock }

        Gcloud::Storage::File::Verifier.stub :md5_for, stubbed_md5 do
          Gcloud::Storage::File::Verifier.stub :crc32c_for, stubbed_crc32c do
            file.download tmpfile, verify: :all
          end
        end
        mocked_md5.verify
        mocked_crc32c.verify
        mock.verify
      end
    end

    it "doesn't verify at all when specified" do
      # Stub these values
      def file.md5; "md5="; end
      def file.crc32c; "crc32c="; end

      Tempfile.open "gcloud-ruby" do |tmpfile|
        mock = Minitest::Mock.new
        mock.expect :get_object, file_gapi,
          [bucket.name, file.name, download_dest: tmpfile, generation: nil, options: {}]

        bucket.service.mocked_service = mock

        stubbed_md5 = lambda { |_| fail "Should not be called!" }
        stubbed_crc32c = lambda { |_| fail "Should not be called!" }

        Gcloud::Storage::File::Verifier.stub :md5_for, stubbed_md5 do
          Gcloud::Storage::File::Verifier.stub :crc32c_for, stubbed_crc32c do
            file.download tmpfile, verify: :none
          end
        end

        mock.verify
      end
    end

    it "raises when verification fails" do
      # Stub these values
      def file.md5; "md5="; end
      def file.crc32c; "crc32c="; end

      Tempfile.open "gcloud-ruby" do |tmpfile|
        mock = Minitest::Mock.new
        mock.expect :get_object, file_gapi,
          [bucket.name, file.name, download_dest: tmpfile, generation: nil, options: {}]

        bucket.service.mocked_service = mock

        mocked_md5 = Minitest::Mock.new
        mocked_md5.expect :md5_mock, "NOPE="
        stubbed_md5 = lambda { |_| mocked_md5.md5_mock }
        stubbed_crc32c = lambda { |_| fail "Should not be called!" }

        Gcloud::Storage::File::Verifier.stub :md5_for, stubbed_md5 do
          Gcloud::Storage::File::Verifier.stub :crc32c_for, stubbed_crc32c do
            assert_raises Gcloud::Storage::FileVerificationError do
              file.download tmpfile
            end
          end
        end
        mocked_md5.verify
        mock.verify
      end
    end
  end

  it "can copy itself in the same bucket" do
    mock = Minitest::Mock.new
    mock.expect :copy_object, file_gapi,
      [bucket.name, file.name, bucket.name, "new-file.ext", destination_predefined_acl: nil, source_generation: nil, options: {}]

    file.service.mocked_service = mock

    file.copy "new-file.ext"

    mock.verify
  end

  it "can copy itself in the same bucket with generation" do
    mock = Minitest::Mock.new
    mock.expect :copy_object, file_gapi,
      [bucket.name, file.name, bucket.name, "new-file.ext", destination_predefined_acl: nil, source_generation: 123, options: {}]

    file.service.mocked_service = mock

    file.copy "new-file.ext", generation: 123

    mock.verify
  end

  it "can copy itself in the same bucket with predefined ACL" do
    mock = Minitest::Mock.new
    mock.expect :copy_object, file_gapi,
      [bucket.name, file.name, bucket.name, "new-file.ext", destination_predefined_acl: "private", source_generation: nil, options: {}]

    file.service.mocked_service = mock

    file.copy "new-file.ext", acl: "private"

    mock.verify
  end

  it "can copy itself in the same bucket with ACL alias" do
    mock = Minitest::Mock.new
    mock.expect :copy_object, file_gapi,
      [bucket.name, file.name, bucket.name, "new-file.ext", destination_predefined_acl: "publicRead", source_generation: nil, options: {}]

    file.service.mocked_service = mock

    file.copy "new-file.ext", acl: :public

    mock.verify
  end

  it "can copy itself with customer-supplied encryption key" do
    mock = Minitest::Mock.new
    mock.expect :copy_object, file_gapi,
      [bucket.name, file.name, bucket.name, "new-file.ext", destination_predefined_acl: nil, source_generation: nil, options: key_options]

    file.service.mocked_service = mock

    file.copy "new-file.ext", encryption_key: encryption_key

    mock.verify
  end

  it "can copy itself with customer-supplied encryption key and sha" do
    mock = Minitest::Mock.new
    mock.expect :copy_object, file_gapi,
      [bucket.name, file.name, bucket.name, "new-file.ext", destination_predefined_acl: nil, source_generation: nil, options: key_options]

    file.service.mocked_service = mock

    file.copy "new-file.ext", encryption_key: encryption_key, encryption_key_sha256: encryption_key_sha256

    mock.verify
  end

  it "can copy itself to a different bucket" do
    mock = Minitest::Mock.new
    mock.expect :copy_object, file_gapi,
      [bucket.name, file.name, "new-bucket", "new-file.ext", destination_predefined_acl: nil, source_generation: nil, options: {}]

    file.service.mocked_service = mock

    file.copy "new-bucket", "new-file.ext"

    mock.verify
  end

  it "can copy itself to a different bucket with generation" do
    mock = Minitest::Mock.new
    mock.expect :copy_object, file_gapi,
      [bucket.name, file.name, "new-bucket", "new-file.ext", destination_predefined_acl: nil, source_generation: 123, options: {}]

    file.service.mocked_service = mock

    file.copy "new-bucket", "new-file.ext", generation: 123

    mock.verify
  end

  it "can copy itself to a different bucket with predefined ACL" do
    mock = Minitest::Mock.new
    mock.expect :copy_object, file_gapi,
      [bucket.name, file.name, "new-bucket", "new-file.ext", destination_predefined_acl: "private", source_generation: nil, options: {}]

    file.service.mocked_service = mock

    file.copy "new-bucket", "new-file.ext", acl: "private"

    mock.verify
  end

  it "can copy itself to a different bucket with ACL alias" do
    mock = Minitest::Mock.new
    mock.expect :copy_object, file_gapi,
      [bucket.name, file.name, "new-bucket", "new-file.ext", destination_predefined_acl: "publicRead", source_generation: nil, options: {}]

    file.service.mocked_service = mock

    file.copy "new-bucket", "new-file.ext", acl: :public

    mock.verify
  end

  it "can copy itself to a different bucket with customer-supplied encryption key" do
    mock = Minitest::Mock.new
    mock.expect :copy_object, file_gapi,
      [bucket.name, file.name, "new-bucket", "new-file.ext", destination_predefined_acl: nil, source_generation: nil, options: key_options]

    file.service.mocked_service = mock

    file.copy "new-bucket", "new-file.ext", encryption_key: encryption_key

    mock.verify
  end

  it "can copy itself to a different bucket with customer-supplied encryption key and sha" do
    mock = Minitest::Mock.new
    mock.expect :copy_object, file_gapi,
      [bucket.name, file.name, "new-bucket", "new-file.ext", destination_predefined_acl: nil, source_generation: nil, options: key_options]

    file.service.mocked_service = mock

    file.copy "new-bucket", "new-file.ext", encryption_key: encryption_key, encryption_key_sha256: encryption_key_sha256

    mock.verify
  end

  it "can reload itself" do
    file_name = "file.ext"

    mock = Minitest::Mock.new
    mock.expect :get_object, Google::Apis::StorageV1::Object.from_json(random_file_hash(bucket.name, file_name, 1234567891).to_json),
      [bucket.name, file_name, generation: nil, options: {}]
    mock.expect :get_object, Google::Apis::StorageV1::Object.from_json(random_file_hash(bucket.name, file_name, 1234567892).to_json),
      [bucket.name, file_name, generation: nil, options: {}]

    bucket.service.mocked_service = mock
    file.service.mocked_service = mock

    file = bucket.file file_name
    file.generation.must_equal 1234567891
    file.reload!
    file.generation.must_equal 1234567892

    mock.verify
  end
end
