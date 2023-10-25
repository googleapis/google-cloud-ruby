# Copyright 2014 Google LLC
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

require "helper"

describe Google::Cloud::Storage::File, :mock_storage do
  let(:bucket_gapi) { Google::Apis::StorageV1::Bucket.from_json random_bucket_hash(name: "bucket").to_json }
  let(:bucket) { Google::Cloud::Storage::Bucket.from_gapi bucket_gapi, storage.service }
  let(:bucket_user_project) { Google::Cloud::Storage::Bucket.from_gapi bucket_gapi, storage.service, user_project: true }

  let(:custom_time) { DateTime.new 2020, 2, 3, 4, 5, 6 }
  let(:file_hash) { random_file_hash bucket.name, "file.ext", custom_time: custom_time }
  let(:file_gapi) { Google::Apis::StorageV1::Object.from_json file_hash.to_json }
  let(:file) { Google::Cloud::Storage::File.from_gapi file_gapi, storage.service }
  let(:file_user_project) { Google::Cloud::Storage::File.from_gapi file_gapi, storage.service, user_project: true }
  let(:generation) { 1234567890 }
  let(:generations) { [1234567894, 1234567893, 1234567892, 1234567891] }
  let(:file_gapis) do
    generations.map { |g| Google::Apis::StorageV1::Object.from_json(random_file_hash(bucket.name, file.name, g).to_json) }
  end
  let(:metageneration) { 6 }

  let(:encryption_key) { "y\x03\"\x0E\xB6\xD3\x9B\x0E\xAB*\x19\xFAv\xDEY\xBEI\xF8ftA|[z\x1A\xFBE\xDE\x97&\xBC\xC7" }
  let(:encryption_key_sha256) { "5\x04_\xDF\x1D\x8A_d\xFEK\e6p[XZz\x13s]E\xF6\xBB\x10aQH\xF6o\x14f\xF9" }
  let(:key_headers) do {
      "x-goog-encryption-algorithm"  => "AES256",
      "x-goog-encryption-key"        => Base64.strict_encode64(encryption_key),
      "x-goog-encryption-key-sha256" => Base64.strict_encode64(encryption_key_sha256)
    }
  end
  let(:copy_key_headers) do {
      "x-goog-copy-source-encryption-algorithm"  => "AES256",
      "x-goog-copy-source-encryption-key"        => Base64.strict_encode64(encryption_key),
      "x-goog-copy-source-encryption-key-sha256" => Base64.strict_encode64(encryption_key_sha256),
      "x-goog-encryption-algorithm"  => "AES256",
      "x-goog-encryption-key"        => Base64.strict_encode64(encryption_key),
      "x-goog-encryption-key-sha256" => Base64.strict_encode64(encryption_key_sha256)
    }
  end
  let(:key_options) { { header: key_headers } }
  let(:copy_key_options) { { header: copy_key_headers } }

  let(:source_encryption_key) { "T\x80\xC2}\x91R\xD2\x05\fTo\xD4\xB3+\xAE\xBCbd\xD1\x81|\xCD\x06%\xC8|\xA2\x17\xF6\xB4^\xD0" }
  let(:source_encryption_key_sha256) { "\x03(M#\x1D(BF\x12$T\xD4\xDCP\xE6\x98\a\xEB'\x8A\xB9\x89\xEEM)\x94\xFD\xE3VR*\x86" }
  let(:source_key_headers) do {
      "x-goog-copy-source-encryption-algorithm"  => "AES256",
      "x-goog-copy-source-encryption-key"        => Base64.strict_encode64(source_encryption_key),
      "x-goog-copy-source-encryption-key-sha256" => Base64.strict_encode64(source_encryption_key_sha256)
    }
  end
  let(:kms_key) { "path/to/encryption_key_name" }

  it "knows its attributes" do
    _(file.id).must_equal file_hash["id"]
    _(file.name).must_equal file_hash["name"]
    _(file.created_at).must_be_within_delta file_hash["timeCreated"].to_datetime
    _(file.api_url).must_equal file_hash["selfLink"]
    _(file.media_url).must_equal file_hash["mediaLink"]
    _(file.public_url).must_equal "https://storage.googleapis.com/#{file.bucket}/#{file.name}"
    _(file.public_url(protocol: :http)).must_equal "http://storage.googleapis.com/#{file.bucket}/#{file.name}"
    _(file.url).must_equal file.public_url

    _(file.md5).must_equal file_hash["md5Hash"]
    _(file.crc32c).must_equal file_hash["crc32c"]
    _(file.etag).must_equal file_hash["etag"]

    _(file.cache_control).must_equal "public, max-age=3600"
    _(file.content_disposition).must_equal "attachment; filename=filename.ext"
    _(file.content_encoding).must_equal "gzip"
    _(file.content_language).must_equal "en"
    _(file.content_type).must_equal "text/plain"
    _(file.custom_time).must_equal custom_time

    _(file.metadata).must_be_kind_of Hash
    _(file.metadata.size).must_equal 2
    _(file.metadata.frozen?).must_equal true
    _(file.metadata["player"]).must_equal "Alice"
    _(file.metadata["score"]).must_equal "101"

    _(file.temporary_hold?).must_equal true
    _(file.event_based_hold?).must_equal true
    _(file.retention_expires_at).must_be_within_delta Time.now.to_datetime
  end

  it "can delete itself" do
    mock = Minitest::Mock.new
    mock.expect :delete_object, nil, [bucket.name, file.name], **delete_object_args(options: {retries: 0})

    file.service.mocked_service = mock

    file.delete

    mock.verify
  end

  it "can delete itself with generation set to true" do
    mock = Minitest::Mock.new
    mock.expect :delete_object, nil, [bucket.name, file.name], **delete_object_args(generation: generation)

    file.service.mocked_service = mock

    _(file.generation).must_equal generation
    file.delete generation: true

    mock.verify
  end

  it "can delete itself with generation set to a generation" do
    mock = Minitest::Mock.new
    mock.expect :delete_object, nil, [bucket.name, file.name], **delete_object_args(generation: generation)

    file.service.mocked_service = mock

    file.delete generation: generation

    mock.verify
  end

  it "can delete itself with if_generation_match set to a generation" do
    mock = Minitest::Mock.new
    mock.expect :delete_object, nil, [bucket.name, file.name], **delete_object_args(if_generation_match: generation)

    file.service.mocked_service = mock

    file.delete if_generation_match: generation

    mock.verify
  end

  it "can delete itself with if_generation_not_match set to a generation" do
    mock = Minitest::Mock.new
    mock.expect :delete_object, nil, [bucket.name, file.name], **delete_object_args(if_generation_not_match: generation, options: {retries: 0})

    file.service.mocked_service = mock

    file.delete if_generation_not_match: generation

    mock.verify
  end

  it "can delete itself with if_metageneration_match set to a metageneration" do
    mock = Minitest::Mock.new
    mock.expect :delete_object, nil, [bucket.name, file.name], **delete_object_args(if_metageneration_match: metageneration, options: {retries: 0})

    file.service.mocked_service = mock

    file.delete if_metageneration_match: metageneration

    mock.verify
  end

  it "can delete itself with if_metageneration_not_match set to a metageneration" do
    mock = Minitest::Mock.new
    mock.expect :delete_object, nil, [bucket.name, file.name], **delete_object_args(if_metageneration_not_match: metageneration, options: {retries: 0})

    file.service.mocked_service = mock

    file.delete if_metageneration_not_match: metageneration

    mock.verify
  end

  it "can delete itself with user_project set to true" do
    mock = Minitest::Mock.new
    mock.expect :delete_object, nil, [bucket.name, file_user_project.name], **delete_object_args(user_project: "test", options: {retries: 0})

    file_user_project.service.mocked_service = mock

    file_user_project.delete

    mock.verify
  end

  it "can delete itself with generation set to true and user_project set to true" do
    mock = Minitest::Mock.new
    mock.expect :delete_object, nil, [bucket.name, file_user_project.name], **delete_object_args(generation: generation, user_project: "test")

    file_user_project.service.mocked_service = mock

    file_user_project.delete generation: true

    mock.verify
  end

  it "can delete itself with generation set to a generation and user_project set to true" do
    mock = Minitest::Mock.new
    mock.expect :delete_object, nil, [bucket.name, file_user_project.name], **delete_object_args(generation: generation, user_project: "test")

    file_user_project.service.mocked_service = mock

    file_user_project.delete generation: generation

    mock.verify
  end

  it "can download itself to a file" do
    # Stub the md5 to match.
    def file.md5
      "X7A8HRvZUCT5gbq0KNDL8Q=="
    end

    Tempfile.open "google-cloud" do |tmpfile|
      # write to the file since the mocked call won't
      data = "yay!"
      tmpfile.write data
      tmpfile.rewind

      mock = Minitest::Mock.new
      mock.expect :get_object, [tmpfile, download_http_resp],
        [bucket.name, file.name], download_dest: tmpfile, generation: generation, user_project: nil, options: {}

      bucket.service.mocked_service = mock

      downloaded = file.download tmpfile
      _(downloaded).must_be_kind_of Tempfile
      _(tmpfile.read).must_equal data

      mock.verify
    end
  end

  it "can download and decompress itself to a file when Content-Encoding gzip response header" do
    data = "Hello world!"
    gzipped_data = gzip_data data

    # Stub the md5 to match.
    file.gapi.md5_hash = Digest::MD5.base64digest gzipped_data

    Tempfile.open "google-cloud" do |tmpfile|
      # write to the file since the mocked call won't
      tmpfile.write gzipped_data
      tmpfile.rewind

      mock = Minitest::Mock.new
      mock.expect :get_object, [tmpfile, download_http_resp(gzip: true)],
        [bucket.name, file.name], download_dest: tmpfile, generation: generation, user_project: nil, options: {}

      bucket.service.mocked_service = mock

      downloaded = file.download tmpfile
      _(downloaded).must_be_kind_of File
      _(tmpfile.read).must_equal data

      mock.verify
    end
  end

  it "can download itself to a file when Content-Encoding gzip response header with skip_decompress" do
    data = "Hello world!"
    gzipped_data = gzip_data data

    # Stub the md5 to match.
    file.gapi.md5_hash = Digest::MD5.base64digest gzipped_data

    Tempfile.open "google-cloud" do |tmpfile|
      # write to the file since the mocked call won't
      tmpfile.write gzipped_data
      tmpfile.rewind

      mock = Minitest::Mock.new
      mock.expect :get_object, [tmpfile, download_http_resp(gzip: true)],
        [bucket.name, file.name], download_dest: tmpfile, generation: generation, user_project: nil, options: {}

      bucket.service.mocked_service = mock

      downloaded = file.download tmpfile, skip_decompress: true
      _(downloaded).must_be_kind_of Tempfile
      _(tmpfile.read).must_equal gzipped_data

      mock.verify
    end
  end

  it "can download itself to a file by path" do
    # Stub the md5 to match.
    def file.md5
      "1B2M2Y8AsgTpgAmY7PhCfg=="
    end

    Tempfile.open "google-cloud" do |tmpfile|
      # write to the file since the mocked call won't
      tmpfile.write "yay!"

      mock = Minitest::Mock.new
      mock.expect :get_object, [tmpfile, download_http_resp],
        [bucket.name, file.name], download_dest: tmpfile.path, generation: generation, user_project: nil, options: {}

      bucket.service.mocked_service = mock

      downloaded = file.download tmpfile.path
      _(downloaded).must_be_kind_of Tempfile

      mock.verify
    end
  end

  it "can download itself to a file with user_project set to true" do
    # Stub the md5 to match.
    def file_user_project.md5
      "1B2M2Y8AsgTpgAmY7PhCfg=="
    end

    Tempfile.open "google-cloud" do |tmpfile|
      # write to the file since the mocked call won't
      tmpfile.write "yay!"

      mock = Minitest::Mock.new
      mock.expect :get_object, [tmpfile, download_http_resp],
        [bucket.name, file_user_project.name], download_dest: tmpfile, generation: generation, user_project: "test", options: {}

      bucket.service.mocked_service = mock

      downloaded = file_user_project.download tmpfile
      _(downloaded).must_be_kind_of Tempfile

      mock.verify
    end
  end

  it "can download itself to an IO" do
    # Stub the md5 to match.
    def file.md5
      "X7A8HRvZUCT5gbq0KNDL8Q=="
    end

    data = "yay!"
    downloadio = StringIO.new
    mock = Minitest::Mock.new
    mock.expect :get_object, [StringIO.new(data), download_http_resp],
      [bucket.name, file.name], download_dest: downloadio, generation: generation, user_project: nil, options: {}

    bucket.service.mocked_service = mock

    downloaded = file.download downloadio
    _(downloaded).must_be_kind_of StringIO
    _(downloaded.read).must_equal data

    mock.verify
  end

  it "can download and decompress itself to an IO when Content-Encoding gzip response header" do
    data = "Hello world!"
    gzipped_data = gzip_data data
    downloadio = StringIO.new

    # Stub the md5 to match.
    file.gapi.md5_hash = Digest::MD5.base64digest gzipped_data

    mock = Minitest::Mock.new
    mock.expect :get_object, [StringIO.new(gzipped_data), download_http_resp(gzip: true)],
      [bucket.name, file.name], download_dest: downloadio, generation: generation, user_project: nil, options: {}

    bucket.service.mocked_service = mock

    downloaded = file.download downloadio
    _(downloaded).must_be_kind_of StringIO
    _(downloaded.read).must_equal data

    mock.verify
  end

  it "can download itself to an IO when Content-Encoding gzip response header with skip_decompress" do
    data = "Hello world!"
    gzipped_data = gzip_data data
    downloadio = StringIO.new

    # Stub the md5 to match.
    file.gapi.md5_hash = Digest::MD5.base64digest gzipped_data

    mock = Minitest::Mock.new
    mock.expect :get_object, [StringIO.new(gzipped_data), download_http_resp(gzip: true)],
      [bucket.name, file.name], download_dest: downloadio, generation: generation, user_project: nil, options: {}

    bucket.service.mocked_service = mock

    downloaded = file.download downloadio, skip_decompress: true
    _(downloaded).must_be_kind_of StringIO
    _(downloaded.read).must_equal gzipped_data

    mock.verify
  end

  it "can download itself by specifying an IO" do
    # Stub the md5 to match.
    def file.md5
      "X7A8HRvZUCT5gbq0KNDL8Q=="
    end

    downloadio = StringIO.new

    mock = Minitest::Mock.new
    mock.expect :get_object, [StringIO.new("yay!"), download_http_resp],
      [bucket.name, file.name], download_dest: downloadio, generation: generation, user_project: nil, options: {}

    bucket.service.mocked_service = mock

    downloaded = file.download downloadio
    _(downloaded).must_be_kind_of StringIO
    _(downloadio).must_equal downloadio # should be the same object

    mock.verify
  end

  it "can download itself with customer-supplied encryption key" do
    # Stub the md5 to match.
    def file.md5
      "1B2M2Y8AsgTpgAmY7PhCfg=="
    end

    Tempfile.open "google-cloud" do |tmpfile|
      # write to the file since the mocked call won't
      tmpfile.write "yay!"

      mock = Minitest::Mock.new
      mock.expect :get_object, [nil, download_http_resp], # using encryption keys seems to return nil
        [bucket.name, file.name], download_dest: tmpfile, generation: generation, user_project: nil, options: key_options

      bucket.service.mocked_service = mock

      downloaded = file.download tmpfile, encryption_key: encryption_key
      _(downloaded.path).must_equal tmpfile.path

      mock.verify
    end
  end

  it "can partially download itself with a range" do
    Tempfile.open "google-cloud" do |tmpfile|
      mock = Minitest::Mock.new
      mock.expect :get_object, [tmpfile, download_http_resp],
        [bucket.name, file.name], download_dest: tmpfile, generation: generation, user_project: nil, options: { header: { 'Range' => 'bytes=3-6' }}

      bucket.service.mocked_service = mock

      downloaded = file.download tmpfile, range: 3..6
      _(downloaded.path).must_equal tmpfile.path

      mock.verify
    end
  end

  it "can partially download itself with a string" do
    Tempfile.open "google-cloud" do |tmpfile|
      mock = Minitest::Mock.new
      mock.expect :get_object, [tmpfile, download_http_resp],
        [bucket.name, file.name], download_dest: tmpfile, generation: generation, user_project: nil, options: { header: { 'Range' => 'bytes=-6' }}

      bucket.service.mocked_service = mock

      downloaded = file.download tmpfile, range: 'bytes=-6'
      _(downloaded.path).must_equal tmpfile.path

      mock.verify
    end
  end

  describe "verified downloads" do
    it "verifies m5d by default" do
      # Stub these values
      def file.md5; "md5="; end
      def file.crc32c; "crc32c="; end

      Tempfile.open "google-cloud" do |tmpfile|
        mock = Minitest::Mock.new
        mock.expect :get_object, [tmpfile, download_http_resp],
          [bucket.name, file.name], download_dest: tmpfile, generation: generation, user_project: nil, options: {}

        bucket.service.mocked_service = mock

        mocked_md5 = Minitest::Mock.new
        mocked_md5.expect :md5_mock, file.md5
        stubbed_md5 = lambda { |_| mocked_md5.md5_mock }
        stubbed_crc32c = lambda { |_| fail "Should not be called!" }

        Google::Cloud::Storage::File::Verifier.stub :md5_for, stubbed_md5 do
          Google::Cloud::Storage::File::Verifier.stub :crc32c_for, stubbed_crc32c do
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

      Tempfile.open "google-cloud" do |tmpfile|
        mock = Minitest::Mock.new
        mock.expect :get_object, [tmpfile, download_http_resp],
          [bucket.name, file.name], download_dest: tmpfile, generation: generation, user_project: nil, options: {}

        bucket.service.mocked_service = mock

        mocked_md5 = Minitest::Mock.new
        mocked_md5.expect :md5_mock, file.md5
        stubbed_md5 = lambda { |_| mocked_md5.md5_mock }
        stubbed_crc32c = lambda { |_| fail "Should not be called!" }

        Google::Cloud::Storage::File::Verifier.stub :md5_for, stubbed_md5 do
          Google::Cloud::Storage::File::Verifier.stub :crc32c_for, stubbed_crc32c do
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

      Tempfile.open "google-cloud" do |tmpfile|
        mock = Minitest::Mock.new
        mock.expect :get_object, [tmpfile, download_http_resp],
          [bucket.name, file.name], download_dest: tmpfile, generation: generation, user_project: nil, options: {}

        bucket.service.mocked_service = mock

        stubbed_md5 = lambda { |_| fail "Should not be called!" }
        mocked_crc32c = Minitest::Mock.new
        mocked_crc32c.expect :crc32c_mock, file.crc32c
        stubbed_crc32c = lambda { |_| mocked_crc32c.crc32c_mock }

        Google::Cloud::Storage::File::Verifier.stub :md5_for, stubbed_md5 do
          Google::Cloud::Storage::File::Verifier.stub :crc32c_for, stubbed_crc32c do
            file.download tmpfile, verify: :crc32c
          end
        end
        mocked_crc32c.verify
        mock.verify
      end
    end

    it "verifies crc32c downloading to an IO when specified" do
      data = "yay!"
      path = StringIO.new

      file.gapi.crc32c = Digest::CRC32c.base64digest data

      mock = Minitest::Mock.new
      mock.expect :get_object, [StringIO.new(data), download_http_resp],
        [bucket.name, file.name], download_dest: path, generation: 1234567890, user_project: nil, options: {}

      bucket.service.mocked_service = mock

      downloaded = file.download path, verify: :crc32c
      _(downloaded).must_be_kind_of StringIO
      _(downloaded.read).must_equal data

      mock.verify
    end

    it "verifies m5d and crc32c when specified" do
      # Stub these values
      def file.md5; "md5="; end
      def file.crc32c; "crc32c="; end

      Tempfile.open "google-cloud" do |tmpfile|
        mock = Minitest::Mock.new
        mock.expect :get_object, [tmpfile, download_http_resp],
          [bucket.name, file.name], download_dest: tmpfile, generation: generation, user_project: nil, options: {}

        bucket.service.mocked_service = mock

        mocked_md5 = Minitest::Mock.new
        mocked_md5.expect :md5_mock, file.md5
        stubbed_md5 = lambda { |_| mocked_md5.md5_mock }

        mocked_crc32c = Minitest::Mock.new
        mocked_crc32c.expect :crc32c_mock, file.crc32c
        stubbed_crc32c = lambda { |_| mocked_crc32c.crc32c_mock }

        Google::Cloud::Storage::File::Verifier.stub :md5_for, stubbed_md5 do
          Google::Cloud::Storage::File::Verifier.stub :crc32c_for, stubbed_crc32c do
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

      Tempfile.open "google-cloud" do |tmpfile|
        mock = Minitest::Mock.new
        mock.expect :get_object, [tmpfile, download_http_resp],
          [bucket.name, file.name], download_dest: tmpfile, generation: generation, user_project: nil, options: {}

        bucket.service.mocked_service = mock

        stubbed_md5 = lambda { |_| fail "Should not be called!" }
        stubbed_crc32c = lambda { |_| fail "Should not be called!" }

        Google::Cloud::Storage::File::Verifier.stub :md5_for, stubbed_md5 do
          Google::Cloud::Storage::File::Verifier.stub :crc32c_for, stubbed_crc32c do
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

      Tempfile.open "google-cloud" do |tmpfile|
        mock = Minitest::Mock.new
        mock.expect :get_object, [tmpfile, download_http_resp],
          [bucket.name, file.name], download_dest: tmpfile.path, generation: generation, user_project: nil, options: {}

        bucket.service.mocked_service = mock

        mocked_md5 = Minitest::Mock.new
        mocked_md5.expect :md5_mock, "NOPE="
        stubbed_md5 = lambda { |_| mocked_md5.md5_mock }
        stubbed_crc32c = lambda { |_| fail "Should not be called!" }

        Google::Cloud::Storage::File::Verifier.stub :md5_for, stubbed_md5 do
          Google::Cloud::Storage::File::Verifier.stub :crc32c_for, stubbed_crc32c do
            assert_raises Google::Cloud::Storage::FileVerificationError do
              file.download tmpfile.path
            end
          end
        end
        mocked_md5.verify
        mock.verify
      end
    end
  end

  describe "File#copy" do
    it "can copy itself in the same bucket" do
      mock = Minitest::Mock.new
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(options: {retries: 0})

      file.service.mocked_service = mock

      file.copy "new-file.ext"

      mock.verify
    end

    it "can copy itself in the same bucket with generation" do
      mock = Minitest::Mock.new
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(source_generation: generation, options: {retries: 0})

      file.service.mocked_service = mock

      file.copy "new-file.ext", generation: generation

      mock.verify
    end

    it "can copy itself in the same bucket with predefined ACL" do
      mock = Minitest::Mock.new
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(destination_predefined_acl: "private", options: {retries: 0})

      file.service.mocked_service = mock

      file.copy "new-file.ext", acl: "private"

      mock.verify
    end

    it "can copy itself in the same bucket with ACL alias" do
      mock = Minitest::Mock.new
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(destination_predefined_acl: "publicRead", options: {retries: 0})

      file.service.mocked_service = mock

      file.copy "new-file.ext", acl: :public

      mock.verify
    end

    it "can copy itself with customer-supplied encryption key" do
      mock = Minitest::Mock.new
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(rewrite_token: nil, user_project: nil, options: copy_key_options.merge(retries: 0))

      file.service.mocked_service = mock

      file.copy "new-file.ext", encryption_key: encryption_key

      mock.verify
    end

    it "can copy itself with user_project set to true" do
      mock = Minitest::Mock.new
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file_user_project.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(rewrite_token: nil, user_project: "test", options: {retries: 0})

      file_user_project.service.mocked_service = mock

      copied = file_user_project.copy "new-file.ext"
      _(copied.user_project).must_equal true

      mock.verify
    end

    it "can copy itself to a different bucket" do
      mock = Minitest::Mock.new
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file.name, "new-bucket", "new-file.ext", nil], **rewrite_object_args(options: {retries: 0})

      file.service.mocked_service = mock

      file.copy "new-bucket", "new-file.ext"

      mock.verify
    end

    it "can copy itself to a different bucket with generation" do
      mock = Minitest::Mock.new
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file.name, "new-bucket", "new-file.ext", nil], **rewrite_object_args(source_generation: generation, options: {retries: 0})

      file.service.mocked_service = mock

      file.copy "new-bucket", "new-file.ext", generation: generation

      mock.verify
    end

    it "can copy itself to a different bucket with predefined ACL" do
      mock = Minitest::Mock.new
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file.name, "new-bucket", "new-file.ext", nil], **rewrite_object_args(destination_predefined_acl: "private", options: {retries: 0})

      file.service.mocked_service = mock

      file.copy "new-bucket", "new-file.ext", acl: "private"

      mock.verify
    end

    it "can copy itself to a different bucket with ACL alias" do
      mock = Minitest::Mock.new
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file.name, "new-bucket", "new-file.ext", nil], **rewrite_object_args(destination_predefined_acl: "publicRead", options: {retries: 0})

      file.service.mocked_service = mock

      file.copy "new-bucket", "new-file.ext", acl: :public

      mock.verify
    end

    it "can copy itself to a different bucket with customer-supplied encryption key" do
      mock = Minitest::Mock.new
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file.name, "new-bucket", "new-file.ext", nil], **rewrite_object_args(rewrite_token: nil, user_project: nil, options: copy_key_options.merge(retries: 0))

      file.service.mocked_service = mock

      file.copy "new-bucket", "new-file.ext", encryption_key: encryption_key

      mock.verify
    end

    it "can copy itself calling rewrite multiple times" do
      mock = Minitest::Mock.new
      mock.expect :rewrite_object, undone_rewrite("notyetcomplete"),
        [bucket.name, file.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(options: {retries: 0})
      mock.expect :rewrite_object, undone_rewrite("keeptrying"),
        [bucket.name, file.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(rewrite_token: "notyetcomplete", options: {retries: 0})
      mock.expect :rewrite_object, undone_rewrite("almostthere"),
        [bucket.name, file.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(rewrite_token: "keeptrying", options: {retries: 0})
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(rewrite_token: "almostthere", options: {retries: 0})

      file.service.mocked_service = mock

      # mock out sleep to make the test run faster
      def file.sleep *args
      end

      file.copy "new-file.ext"

      mock.verify
    end

    it "can copy itself calling rewrite multiple times with user_project set to true" do
      mock = Minitest::Mock.new
      mock.expect :rewrite_object, undone_rewrite("notyetcomplete"),
        [bucket.name, file_user_project.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(rewrite_token: nil, user_project: "test", options: {retries: 0})
      mock.expect :rewrite_object, undone_rewrite("keeptrying"),
        [bucket.name, file_user_project.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(rewrite_token: "notyetcomplete", user_project: "test", options: {retries: 0})
      mock.expect :rewrite_object, undone_rewrite("almostthere"),
        [bucket.name, file_user_project.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(rewrite_token: "keeptrying", user_project: "test", options: {retries: 0})
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file_user_project.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(rewrite_token: "almostthere", user_project: "test", options: {retries: 0})

      file_user_project.service.mocked_service = mock

      # mock out sleep to make the test run faster
      def file_user_project.sleep *args
      end

      copied = file_user_project.copy "new-file.ext"
      _(copied.user_project).must_equal true

      mock.verify
    end

    it "can copy itself while updating its attributes" do
      mock = Minitest::Mock.new
      update_file_gapi = Google::Apis::StorageV1::Object.new
      update_file_gapi.cache_control = "private, max-age=0, no-cache"
      update_file_gapi.content_disposition = "inline; filename=filename.ext"
      update_file_gapi.content_encoding = "deflate"
      update_file_gapi.content_language = "de"
      update_file_gapi.content_type = "application/json"
      update_file_gapi.metadata = { "player" => "Bob", "score" => "10" }
      update_file_gapi.storage_class = "NEARLINE"

      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file.name, bucket.name, "new-file.ext", update_file_gapi], **rewrite_object_args(options: {retries: 0})

      file.service.mocked_service = mock

      file.copy "new-file.ext" do |f|
        f.cache_control = "private, max-age=0, no-cache"
        f.content_disposition = "inline; filename=filename.ext"
        f.content_encoding = "deflate"
        f.content_language = "de"
        f.content_type = "application/json"
        f.metadata["player"] = "Bob"
        f.metadata["score"] = "10"
        f.storage_class = :nearline
      end

      mock.verify
    end

    it "can copy itself while updating its attributes with force_copy_metadata set to true" do
      mock = Minitest::Mock.new
      update_file_gapi = Google::Apis::StorageV1::Object.new
      update_file_gapi.cache_control = "private, max-age=0, no-cache"
      update_file_gapi.content_disposition = "inline; filename=filename.ext"
      update_file_gapi.content_encoding = "deflate"
      update_file_gapi.content_language = "de"
      update_file_gapi.content_type = "application/json"
      update_file_gapi.metadata = { "player" => "Bob", "score" => "10" }
      update_file_gapi.storage_class = "NEARLINE"

      mock.expect :rewrite_object, done_rewrite(file_gapi),
                  [bucket.name, file.name, bucket.name, "new-file.ext", update_file_gapi], **rewrite_object_args(options: {retries: 0})

      file.service.mocked_service = mock

      file.copy "new-file.ext", force_copy_metadata: true do |f|
        f.cache_control = "private, max-age=0, no-cache"
        f.content_disposition = "inline; filename=filename.ext"
        f.content_encoding = "deflate"
        f.content_language = "de"
        f.content_type = "application/json"
        f.metadata["player"] = "Bob"
        f.metadata["score"] = "10"
        f.storage_class = :nearline
      end

      mock.verify
    end

    it "can copy itself while updating its attributes with user_project set to true" do
      mock = Minitest::Mock.new
      update_file_gapi = Google::Apis::StorageV1::Object.new
      update_file_gapi.cache_control = "private, max-age=0, no-cache"
      update_file_gapi.content_disposition = "inline; filename=filename.ext"
      update_file_gapi.content_encoding = "deflate"
      update_file_gapi.content_language = "de"
      update_file_gapi.content_type = "application/json"
      update_file_gapi.metadata = { "player" => "Bob", "score" => "10" }
      update_file_gapi.storage_class = "NEARLINE"

      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file_user_project.name, bucket.name, "new-file.ext", update_file_gapi], **rewrite_object_args(rewrite_token: nil, user_project: "test", options: {retries: 0})

      file_user_project.service.mocked_service = mock

      copied = file_user_project.copy "new-file.ext" do |f|
        f.cache_control = "private, max-age=0, no-cache"
        f.content_disposition = "inline; filename=filename.ext"
        f.content_encoding = "deflate"
        f.content_language = "de"
        f.content_type = "application/json"
        f.metadata["player"] = "Bob"
        f.metadata["score"] = "10"
        f.storage_class = :nearline
      end
      _(copied.user_project).must_equal true

      mock.verify
    end
  end

  describe "File#rewrite" do
    it "can rewrite itself in the same bucket" do
      mock = Minitest::Mock.new
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(options: {retries: 0})

      file.service.mocked_service = mock

      file.rewrite "new-file.ext"

      mock.verify
    end

    it "can rewrite itself in the same bucket with generation" do
      mock = Minitest::Mock.new
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(source_generation: generation, options: {retries: 0})

      file.service.mocked_service = mock

      file.rewrite "new-file.ext", generation: generation

      mock.verify
    end

    it "can rewrite itself with if_generation_match" do
      mock = Minitest::Mock.new
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(if_generation_match: generation)

      file.service.mocked_service = mock

      file.rewrite "new-file.ext", if_generation_match: generation

      mock.verify
    end

    it "can rewrite itself with if_generation_not_match" do
      mock = Minitest::Mock.new
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(if_generation_not_match: generation, options: {retries: 0})

      file.service.mocked_service = mock

      file.rewrite "new-file.ext", if_generation_not_match: generation

      mock.verify
    end

    it "can rewrite itself with if_metageneration_match" do
      mock = Minitest::Mock.new
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(if_metageneration_match: metageneration, options: {retries: 0})

      file.service.mocked_service = mock

      file.rewrite "new-file.ext", if_metageneration_match: metageneration

      mock.verify
    end

    it "can rewrite itself with if_metageneration_not_match" do
      mock = Minitest::Mock.new
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(if_metageneration_not_match: metageneration, options: {retries: 0})

      file.service.mocked_service = mock

      file.rewrite "new-file.ext", if_metageneration_not_match: metageneration

      mock.verify
    end

    it "can rewrite itself with if_source_generation_match" do
      mock = Minitest::Mock.new
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(if_source_generation_match: generation, options: {retries: 0})

      file.service.mocked_service = mock

      file.rewrite "new-file.ext", if_source_generation_match: generation

      mock.verify
    end

    it "can rewrite itself with if_source_generation_not_match" do
      mock = Minitest::Mock.new
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(if_source_generation_not_match: generation, options: {retries: 0})

      file.service.mocked_service = mock

      file.rewrite "new-file.ext", if_source_generation_not_match: generation

      mock.verify
    end

    it "can rewrite itself with if_source_metageneration_match" do
      mock = Minitest::Mock.new
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(if_source_metageneration_match: metageneration, options: {retries: 0})

      file.service.mocked_service = mock

      file.rewrite "new-file.ext", if_source_metageneration_match: metageneration

      mock.verify
    end

    it "can rewrite itself with if_source_metageneration_not_match" do
      mock = Minitest::Mock.new
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(if_source_metageneration_not_match: metageneration, options: {retries: 0})

      file.service.mocked_service = mock

      file.rewrite "new-file.ext", if_source_metageneration_not_match: metageneration

      mock.verify
    end

    it "can rewrite itself in the same bucket with predefined ACL" do
      mock = Minitest::Mock.new
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(destination_predefined_acl: "private", options: {retries: 0})

      file.service.mocked_service = mock

      file.rewrite "new-file.ext", acl: "private"

      mock.verify
    end

    it "can rewrite itself in the same bucket with ACL alias" do
      mock = Minitest::Mock.new
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(destination_predefined_acl: "publicRead", options: {retries: 0})

      file.service.mocked_service = mock

      file.rewrite "new-file.ext", acl: :public

      mock.verify
    end

    it "can rewrite itself to a new customer-supplied encryption key (CSEK)" do
      options = { header: source_key_headers.merge(key_headers), retries: 0 }
      mock = Minitest::Mock.new
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(rewrite_token: nil, user_project: nil, options: options)

      file.service.mocked_service = mock

      file.rewrite "new-file.ext", encryption_key: source_encryption_key, new_encryption_key: encryption_key

      mock.verify
    end

    it "can rewrite itself from default service encryption to a new customer-managed encryption key (CMEK) with new_kms_key" do
      mock = Minitest::Mock.new
      mock.expect :rewrite_object, done_rewrite(file_gapi),
                  [bucket.name, file.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(destination_kms_key_name: kms_key, options: {retries: 0})

      file.service.mocked_service = mock

      file.rewrite "new-file.ext", new_kms_key: kms_key

      mock.verify
    end

    it "can rewrite itself from a customer-supplied encryption key (CSEK) to a new customer-managed encryption key (CMEK) with new_kms_key" do
      options = { header: source_key_headers, retries: 0 }
      mock = Minitest::Mock.new
      mock.expect :rewrite_object, done_rewrite(file_gapi),
                  [bucket.name, file.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(destination_kms_key_name: kms_key, rewrite_token: nil, user_project: nil, options: options)

      file.service.mocked_service = mock

      file.rewrite "new-file.ext", encryption_key: source_encryption_key, new_kms_key: kms_key

      mock.verify
    end

    it "can rewrite itself with user_project set to true" do
      mock = Minitest::Mock.new
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file_user_project.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(rewrite_token: nil, user_project: "test", options: {retries: 0})

      file_user_project.service.mocked_service = mock

      copied = file_user_project.copy "new-file.ext"
      _(copied.user_project).must_equal true

      mock.verify
    end

    it "can rewrite itself to a different bucket" do
      mock = Minitest::Mock.new
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file.name, "new-bucket", "new-file.ext", nil], **rewrite_object_args(options: {retries: 0})

      file.service.mocked_service = mock

      file.rewrite "new-bucket", "new-file.ext"

      mock.verify
    end

    it "can rewrite itself to a different bucket with generation" do
      mock = Minitest::Mock.new
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file.name, "new-bucket", "new-file.ext", nil], **rewrite_object_args(source_generation: generation, options: {retries: 0})

      file.service.mocked_service = mock

      file.rewrite "new-bucket", "new-file.ext", generation: generation

      mock.verify
    end

    it "can rewrite itself to a different bucket with predefined ACL" do
      mock = Minitest::Mock.new
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file.name, "new-bucket", "new-file.ext", nil], **rewrite_object_args(destination_predefined_acl: "private", options: {retries: 0})

      file.service.mocked_service = mock

      file.rewrite "new-bucket", "new-file.ext", acl: "private"

      mock.verify
    end

    it "can rewrite itself to a different bucket with ACL alias" do
      mock = Minitest::Mock.new
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file.name, "new-bucket", "new-file.ext", nil], **rewrite_object_args(destination_predefined_acl: "publicRead", options: {retries: 0})

      file.service.mocked_service = mock

      file.rewrite "new-bucket", "new-file.ext", acl: :public

      mock.verify
    end

    it "can rewrite itself to a different bucket with customer-supplied encryption key" do
      options = { header: source_key_headers.merge(key_headers), retries: 0 }
      mock = Minitest::Mock.new
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file.name, "new-bucket", "new-file.ext", nil], **rewrite_object_args(rewrite_token: nil, user_project: nil, options: options)


      file.service.mocked_service = mock

      file.rewrite "new-bucket", "new-file.ext", encryption_key: source_encryption_key, new_encryption_key: encryption_key

      mock.verify
    end

    it "can rewrite itself calling rewrite multiple times" do
      mock = Minitest::Mock.new
      mock.expect :rewrite_object, undone_rewrite("notyetcomplete"),
        [bucket.name, file.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(options: {retries: 0})
      mock.expect :rewrite_object, undone_rewrite("keeptrying"),
        [bucket.name, file.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(rewrite_token: "notyetcomplete", options: {retries: 0})
      mock.expect :rewrite_object, undone_rewrite("almostthere"),
        [bucket.name, file.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(rewrite_token: "keeptrying", options: {retries: 0})
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(rewrite_token: "almostthere", options: {retries: 0})

      file.service.mocked_service = mock

      # mock out sleep to make the test run faster
      def file.sleep *args
      end

      file.rewrite "new-file.ext"

      mock.verify
    end

    it "can rewrite itself calling rewrite multiple times with user_project set to true" do
      mock = Minitest::Mock.new
      mock.expect :rewrite_object, undone_rewrite("notyetcomplete"),
        [bucket.name, file_user_project.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(rewrite_token: nil, user_project: "test", options: {retries: 0})
      mock.expect :rewrite_object, undone_rewrite("keeptrying"),
        [bucket.name, file_user_project.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(rewrite_token: "notyetcomplete", user_project: "test", options: {retries: 0})
      mock.expect :rewrite_object, undone_rewrite("almostthere"),
        [bucket.name, file_user_project.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(rewrite_token: "keeptrying", user_project: "test", options: {retries: 0})
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file_user_project.name, bucket.name, "new-file.ext", nil], **rewrite_object_args(rewrite_token: "almostthere", user_project: "test", options: {retries: 0})

      file_user_project.service.mocked_service = mock

      # mock out sleep to make the test run faster
      def file_user_project.sleep *args
      end

      copied = file_user_project.copy "new-file.ext"
      _(copied.user_project).must_equal true

      mock.verify
    end

    it "can rewrite itself while updating its attributes" do
      mock = Minitest::Mock.new
      update_file_gapi = Google::Apis::StorageV1::Object.new
      update_file_gapi.cache_control = "private, max-age=0, no-cache"
      update_file_gapi.content_disposition = "inline; filename=filename.ext"
      update_file_gapi.content_encoding = "deflate"
      update_file_gapi.content_language = "de"
      update_file_gapi.content_type = "application/json"
      update_file_gapi.metadata = { "player" => "Bob", "score" => "10" }
      update_file_gapi.storage_class = "NEARLINE"

      mock.expect :rewrite_object, done_rewrite(file_gapi),
                  [bucket.name, file.name, bucket.name, "new-file.ext", update_file_gapi], **rewrite_object_args(options: {retries: 0})

      file.service.mocked_service = mock

      file.rewrite "new-file.ext" do |f|
        f.cache_control = "private, max-age=0, no-cache"
        f.content_disposition = "inline; filename=filename.ext"
        f.content_encoding = "deflate"
        f.content_language = "de"
        f.content_type = "application/json"
        f.metadata["player"] = "Bob"
        f.metadata["score"] = "10"
        f.storage_class = :nearline
      end

      mock.verify
    end

    it "can rewrite itself while updating its attributes with force_copy_metadata set to true" do
      mock = Minitest::Mock.new
      update_file_gapi = Google::Apis::StorageV1::Object.new
      update_file_gapi.cache_control = "private, max-age=0, no-cache"
      update_file_gapi.content_disposition = "inline; filename=filename.ext"
      update_file_gapi.content_encoding = "deflate"
      update_file_gapi.content_language = "de"
      update_file_gapi.content_type = "application/json"
      update_file_gapi.metadata = { "player" => "Bob", "score" => "10" }
      update_file_gapi.storage_class = "NEARLINE"

      mock.expect :rewrite_object, done_rewrite(file_gapi),
                  [bucket.name, file.name, bucket.name, "new-file.ext", update_file_gapi], **rewrite_object_args(options: {retries: 0})

      file.service.mocked_service = mock

      file.rewrite "new-file.ext", force_copy_metadata: true do |f|
        f.cache_control = "private, max-age=0, no-cache"
        f.content_disposition = "inline; filename=filename.ext"
        f.content_encoding = "deflate"
        f.content_language = "de"
        f.content_type = "application/json"
        f.metadata["player"] = "Bob"
        f.metadata["score"] = "10"
        f.storage_class = :nearline
      end

      mock.verify
    end

    it "can rewrite itself while updating its attributes with user_project set to true" do
      mock = Minitest::Mock.new
      update_file_gapi = Google::Apis::StorageV1::Object.new
      update_file_gapi.cache_control = "private, max-age=0, no-cache"
      update_file_gapi.content_disposition = "inline; filename=filename.ext"
      update_file_gapi.content_encoding = "deflate"
      update_file_gapi.content_language = "de"
      update_file_gapi.content_type = "application/json"
      update_file_gapi.metadata = { "player" => "Bob", "score" => "10" }
      update_file_gapi.storage_class = "NEARLINE"

      mock.expect :rewrite_object, done_rewrite(file_gapi),
                  [bucket.name, file_user_project.name, bucket.name, "new-file.ext", update_file_gapi], **rewrite_object_args(rewrite_token: nil, user_project: "test", options: {retries: 0})

      file_user_project.service.mocked_service = mock

      copied = file_user_project.rewrite "new-file.ext" do |f|
        f.cache_control = "private, max-age=0, no-cache"
        f.content_disposition = "inline; filename=filename.ext"
        f.content_encoding = "deflate"
        f.content_language = "de"
        f.content_type = "application/json"
        f.metadata["player"] = "Bob"
        f.metadata["score"] = "10"
        f.storage_class = :nearline
      end
      _(copied.user_project).must_equal true

      mock.verify
    end
  end

  describe "File#rotate" do
    it "can rotate its customer-supplied encryption keys" do
      mock = Minitest::Mock.new
      options = { header: source_key_headers.merge(key_headers), retries: 0 }
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file.name, bucket.name, file.name, nil], **rewrite_object_args(options: options)

      file.service.mocked_service = mock

      updated = file.rotate encryption_key: source_encryption_key, new_encryption_key: encryption_key
      _(updated.name).must_equal file.name

      mock.verify
    end

    it "can rotate its customer-supplied encryption keys with user_project set to true" do
      mock = Minitest::Mock.new
      options = { header: source_key_headers.merge(key_headers), retries: 0 }
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file_user_project.name, bucket.name, file_user_project.name, nil], **rewrite_object_args(user_project: "test", options: options)

      file_user_project.service.mocked_service = mock

      updated = file_user_project.rotate encryption_key: source_encryption_key, new_encryption_key: encryption_key
      _(updated.name).must_equal file_user_project.name
      _(updated.user_project).must_equal true

      mock.verify
    end

    it "can rotate to a customer-supplied encryption key if previously unencrypted with customer key" do
      mock = Minitest::Mock.new
      options = { header: key_headers, retries: 0 }
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file.name, bucket.name, file.name, nil], **rewrite_object_args(options: options)

      file.service.mocked_service = mock

      updated = file.rotate new_encryption_key: encryption_key
      _(updated.name).must_equal file.name

      mock.verify
    end

    it "can rotate from a customer-supplied encryption key to default service encryption" do
      mock = Minitest::Mock.new
      options = { header: source_key_headers, retries: 0 }
      mock.expect :rewrite_object, done_rewrite(file_gapi),
        [bucket.name, file.name, bucket.name, file.name, nil], **rewrite_object_args(options: options)

      file.service.mocked_service = mock

      updated = file.rotate encryption_key: source_encryption_key
      _(updated.name).must_equal file.name

      mock.verify
    end

    it "can rotate from default service encryption to a new customer-managed encryption key (CMEK) with new_kms_key" do
      mock = Minitest::Mock.new
      mock.expect :rewrite_object, done_rewrite(file_gapi), [bucket.name, file.name, bucket.name, file.name, nil], **rewrite_object_args(destination_kms_key_name: kms_key, options: {retries: 0})

      file.service.mocked_service = mock

      updated = file.rotate new_kms_key: kms_key
      _(updated.name).must_equal file.name

      mock.verify
    end

    it "can rotate from a customer-supplied encryption key (CSEK) to a new customer-managed encryption key (CMEK) with new_kms_key" do
      mock = Minitest::Mock.new
      options = { header: source_key_headers, retries: 0 }
      mock.expect :rewrite_object, done_rewrite(file_gapi), [bucket.name, file.name, bucket.name, file.name, nil], **rewrite_object_args(destination_kms_key_name: kms_key, options: options)

      file.service.mocked_service = mock

      updated = file.rotate encryption_key: source_encryption_key, new_kms_key: kms_key
      _(updated.name).must_equal file.name

      mock.verify
    end

    it "can rotate its customer-supplied encryption keys with multiple requests for large objects" do
      mock = Minitest::Mock.new
      options = { header: source_key_headers.merge(key_headers), retries: 0 }
      mock.expect :rewrite_object, undone_rewrite("notyetcomplete"), [bucket.name, file.name, bucket.name, file.name, nil], **rewrite_object_args(options: options)
      mock.expect :rewrite_object, done_rewrite(file_gapi),
                  [bucket.name, file.name, bucket.name, file.name, nil], **rewrite_object_args(rewrite_token: "notyetcomplete", options: options)

      file.service.mocked_service = mock

      # mock out sleep to make the test run faster
      def file.sleep *args
      end

      updated = file.rotate encryption_key: source_encryption_key, new_encryption_key: encryption_key
      _(updated.name).must_equal file.name

      mock.verify
    end

    it "can rotate its customer-supplied encryption keys with multiple requests for large objects with user_project set to true" do
      mock = Minitest::Mock.new
      options = { header: source_key_headers.merge(key_headers), retries: 0 }
      mock.expect :rewrite_object, undone_rewrite("notyetcomplete"),
                  [bucket.name, file_user_project.name, bucket.name, file_user_project.name, nil], **rewrite_object_args(user_project: "test", options: options)
      mock.expect :rewrite_object, done_rewrite(file_gapi),
                  [bucket.name, file_user_project.name, bucket.name, file_user_project.name, nil], **rewrite_object_args(rewrite_token: "notyetcomplete", user_project: "test", options: options)

      file_user_project.service.mocked_service = mock

      # mock out sleep to make the test run faster
      def file_user_project.sleep *args
      end

      updated = file_user_project.rotate encryption_key: source_encryption_key, new_encryption_key: encryption_key
      _(updated.name).must_equal file_user_project.name
      _(updated.user_project).must_equal true

      mock.verify
    end
  end

  it "can reload itself" do
    file_name = "file.ext"

    mock = Minitest::Mock.new
    mock.expect :get_object, Google::Apis::StorageV1::Object.from_json(random_file_hash(bucket.name, file_name, generations[3]).to_json),
      [bucket.name, file_name], **get_object_args
    mock.expect :get_object, Google::Apis::StorageV1::Object.from_json(random_file_hash(bucket.name, file_name, generations[2]).to_json),
      [bucket.name, file_name], **get_object_args

    bucket.service.mocked_service = mock
    file.service.mocked_service = mock

    file = bucket.file file_name
    _(file.generation).must_equal generations[3]
    file.reload!
    _(file.generation).must_equal generations[2]

    mock.verify
  end

  it "can reload itself with user_project set to true" do
    file_name = "file.ext"

    mock = Minitest::Mock.new
    mock.expect :get_object, Google::Apis::StorageV1::Object.from_json(random_file_hash(bucket_user_project.name, file_name, generations[3]).to_json),
      [bucket_user_project.name, file_name], **get_object_args(user_project: "test")
    mock.expect :get_object, Google::Apis::StorageV1::Object.from_json(random_file_hash(bucket_user_project.name, file_name, generations[2]).to_json),
      [bucket_user_project.name, file_name], **get_object_args(user_project: "test")

    bucket_user_project.service.mocked_service = mock
    file.service.mocked_service = mock

    file = bucket_user_project.file file_name
    _(file.generation).must_equal generations[3]
    file.reload!
    _(file.generation).must_equal generations[2]

    mock.verify
  end

  it "can list its generations" do
    file_name = "file.ext"

    mock = Minitest::Mock.new
    mock.expect :get_object, Google::Apis::StorageV1::Object.from_json(random_file_hash(bucket.name, file_name, generations[0]).to_json),
      [bucket.name, file_name], **get_object_args
    mock.expect :list_objects, Google::Apis::StorageV1::Objects.new(kind: "storage#objects", items: file_gapis),
      [bucket.name], delimiter: nil, match_glob: nil, max_results: nil, page_token: nil, prefix: file_name, versions: true, user_project: nil, options: {}

    bucket.service.mocked_service = mock
    file.service.mocked_service = mock

    file = bucket.file file_name
    _(file.generation).must_equal generations[0]

    file_generations = file.generations
    _(file_generations.count).must_equal 4
    file_generations.each do |f|
      _(f).must_be_kind_of Google::Cloud::Storage::File
      _(f.user_project).must_be :nil?
    end
    _(file_generations.map(&:generation)).must_equal generations

    mock.verify
  end

  it "can list its generations with user_project set to true" do
    file_name = "file.ext"

    mock = Minitest::Mock.new
    mock.expect :get_object, Google::Apis::StorageV1::Object.from_json(random_file_hash(bucket_user_project.name, file_name, generations[0]).to_json),
      [bucket_user_project.name, file_name], **get_object_args(user_project: "test")
    mock.expect :list_objects, Google::Apis::StorageV1::Objects.new(kind: "storage#objects", items: file_gapis),
      [bucket.name], delimiter: nil, match_glob: nil, max_results: nil, page_token: nil, prefix: file_name, versions: true, user_project: "test", options: {}

    bucket_user_project.service.mocked_service = mock
    file.service.mocked_service = mock

    file = bucket_user_project.file file_name
    _(file.generation).must_equal generations[0]
    _(file.user_project).must_equal true

    file_generations = file.generations
    _(file_generations.count).must_equal 4
    file_generations.each do |f|
      _(f).must_be_kind_of Google::Cloud::Storage::File
      _(f.user_project).must_equal true
    end
    _(file_generations.map(&:generation)).must_equal generations

    mock.verify
  end

  it "knows its KMS encryption key" do
    _(file.kms_key).must_equal kms_key
  end

  def gzip_data data
    gz = StringIO.new("")
    z = Zlib::GzipWriter.new(gz)
    z.write data
    z.close # write the gzip footer

    gz.string
  end
end
