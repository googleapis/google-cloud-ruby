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
  # Create a bucket object with the project's mocked connection object
  let(:bucket) { Gcloud::Storage::Bucket.from_gapi random_bucket_hash("bucket"),
                                                   storage.connection }

  # Create a file object with the project's mocked connection object
  let(:file_hash) { random_file_hash bucket.name, "file.ext" }
  let(:file) { Gcloud::Storage::File.from_gapi file_hash, storage.connection }

  it "knows its attributes" do
    file.id.must_equal file_hash["id"]
    file.name.must_equal file_hash["name"]
    file.created_at.must_equal file_hash["timeCreated"]
    file.api_url.must_equal file_hash["selfLink"]
    file.media_url.must_equal file_hash["mediaLink"]

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
    mock_connection.delete "/storage/v1/b/#{bucket.name}/o/#{file.name}" do |env|
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    file.delete
  end

  it "can download itself" do
    # Stub the md5 to match.
    def file.md5
      "X7A8HRvZUCT5gbq0KNDL8Q=="
    end
    mock_connection.get "/storage/v1/b/#{bucket.name}/o/#{file.name}?alt=media" do |env|
      [200, {"Content-Type"=>"text/plain"},
       "yay!"]
    end

    Tempfile.open "gcloud-ruby" do |tmpfile|
      file.download tmpfile
      File.read(tmpfile).must_equal "yay!"
    end
  end

  describe "verified downloads" do
    before do
      # Stub these values
      def file.md5; "md5="; end
      def file.crc32c; "crc32c="; end
      # Mock the download
      mock_connection.get "/storage/v1/b/#{bucket.name}/o/#{file.name}?alt=media" do |env|
        [200, {"Content-Type"=>"text/plain"},
         "The quick brown fox jumps over the lazy dog."]
      end
    end

    it "verifies m5d by default" do
      mocked_md5 = Minitest::Mock.new
      mocked_md5.expect :md5_mock, file.md5
      stubbed_md5 = lambda { |_| mocked_md5.md5_mock }
      stubbed_crc32c = lambda { |_| fail "Should not be called!" }

      Gcloud::Storage::File::Verifier.stub :md5_for, stubbed_md5 do
        Gcloud::Storage::File::Verifier.stub :crc32c_for, stubbed_crc32c do
          Tempfile.open "gcloud-ruby" do |tmpfile|
            file.download tmpfile
          end
        end
      end
      mocked_md5.verify
    end

    it "verifies m5d when specified" do
      mocked_md5 = Minitest::Mock.new
      mocked_md5.expect :md5_mock, file.md5
      stubbed_md5 = lambda { |_| mocked_md5.md5_mock }
      stubbed_crc32c = lambda { |_| fail "Should not be called!" }

      Gcloud::Storage::File::Verifier.stub :md5_for, stubbed_md5 do
        Gcloud::Storage::File::Verifier.stub :crc32c_for, stubbed_crc32c do
          Tempfile.open "gcloud-ruby" do |tmpfile|
            file.download tmpfile, verify: :md5
          end
        end
      end
      mocked_md5.verify
    end

    it "verifies crc32c when specified" do
      stubbed_md5 = lambda { |_| fail "Should not be called!" }
      mocked_crc32c = Minitest::Mock.new
      mocked_crc32c.expect :crc32c_mock, file.crc32c
      stubbed_crc32c = lambda { |_| mocked_crc32c.crc32c_mock }

      Gcloud::Storage::File::Verifier.stub :md5_for, stubbed_md5 do
        Gcloud::Storage::File::Verifier.stub :crc32c_for, stubbed_crc32c do
          Tempfile.open "gcloud-ruby" do |tmpfile|
            file.download tmpfile, verify: :crc32c
          end
        end
      end
      mocked_crc32c.verify
    end

    it "verifies m5d and crc32c when specified" do
      mocked_md5 = Minitest::Mock.new
      mocked_md5.expect :md5_mock, file.md5
      stubbed_md5 = lambda { |_| mocked_md5.md5_mock }

      mocked_crc32c = Minitest::Mock.new
      mocked_crc32c.expect :crc32c_mock, file.crc32c
      stubbed_crc32c = lambda { |_| mocked_crc32c.crc32c_mock }

      Gcloud::Storage::File::Verifier.stub :md5_for, stubbed_md5 do
        Gcloud::Storage::File::Verifier.stub :crc32c_for, stubbed_crc32c do
          Tempfile.open "gcloud-ruby" do |tmpfile|
            file.download tmpfile, verify: :all
          end
        end
      end
      mocked_md5.verify
      mocked_crc32c.verify
    end

    it "doesn't verify at all when specified" do
      stubbed_md5 = lambda { |_| fail "Should not be called!" }
      stubbed_crc32c = lambda { |_| fail "Should not be called!" }

      Gcloud::Storage::File::Verifier.stub :md5_for, stubbed_md5 do
        Gcloud::Storage::File::Verifier.stub :crc32c_for, stubbed_crc32c do
          Tempfile.open "gcloud-ruby" do |tmpfile|
            file.download tmpfile, verify: :none
          end
        end
      end
    end

    it "raises when verification fails" do
      mocked_md5 = Minitest::Mock.new
      mocked_md5.expect :md5_mock, "NOPE="
      stubbed_md5 = lambda { |_| mocked_md5.md5_mock }
      stubbed_crc32c = lambda { |_| fail "Should not be called!" }

      Gcloud::Storage::File::Verifier.stub :md5_for, stubbed_md5 do
        Gcloud::Storage::File::Verifier.stub :crc32c_for, stubbed_crc32c do
          Tempfile.open "gcloud-ruby" do |tmpfile|
            assert_raises Gcloud::Storage::FileVerificationError do
              file.download tmpfile
            end
          end
        end
      end
      mocked_md5.verify
    end
  end

  it "can copy itself in the same bucket" do
    mock_connection.post "/storage/v1/b/#{bucket.name}/o/#{file.name}/copyTo/b/#{bucket.name}/o/new-file.ext" do |env|
      env.params.wont_include "sourceGeneration"
      env.params.wont_include "predefinedAcl"
      [200, {"Content-Type"=>"application/json"},
       file.gapi.to_json]
    end

    file.copy "new-file.ext"
  end

  it "can copy itself in the same bucket with generation" do
    mock_connection.post "/storage/v1/b/#{bucket.name}/o/#{file.name}/copyTo/b/#{bucket.name}/o/new-file.ext" do |env|
      env.params["sourceGeneration"].must_equal "123"
      [200, {"Content-Type"=>"application/json"},
       file.gapi.to_json]
    end

    file.copy "new-file.ext", generation: 123
  end

  it "can copy itself in the same bucket with predefined ACL" do
    mock_connection.post "/storage/v1/b/#{bucket.name}/o/#{file.name}/copyTo/b/#{bucket.name}/o/new-file.ext" do |env|
      env.params["predefinedAcl"].must_equal "private"
      [200, {"Content-Type"=>"application/json"},
       file.gapi.to_json]
    end

    file.copy "new-file.ext", acl: "private"
  end

  it "can copy itself in the same bucket with ACL alias" do
    mock_connection.post "/storage/v1/b/#{bucket.name}/o/#{file.name}/copyTo/b/#{bucket.name}/o/new-file.ext" do |env|
      env.params["predefinedAcl"].must_equal "publicRead"
      [200, {"Content-Type"=>"application/json"},
       file.gapi.to_json]
    end

    file.copy "new-file.ext", acl: :public
  end

  it "can copy itself to a different bucket" do
    mock_connection.post "/storage/v1/b/#{bucket.name}/o/#{file.name}/copyTo/b/new-bucket/o/new-file.ext" do |env|
      env.params.wont_include "sourceGeneration"
      env.params.wont_include "predefinedAcl"
      [200, {"Content-Type"=>"application/json"},
       file.gapi.to_json]
    end

    file.copy "new-bucket", "new-file.ext"
  end

  it "can copy itself to a different bucket with generation" do
    mock_connection.post "/storage/v1/b/#{bucket.name}/o/#{file.name}/copyTo/b/new-bucket/o/new-file.ext" do |env|
      env.params["sourceGeneration"].must_equal "123"
      [200, {"Content-Type"=>"application/json"},
       file.gapi.to_json]
    end

    file.copy "new-bucket", "new-file.ext", generation: 123
  end

  it "can copy itself to a different bucket with predefined ACL" do
    mock_connection.post "/storage/v1/b/#{bucket.name}/o/#{file.name}/copyTo/b/new-bucket/o/new-file.ext" do |env|
      env.params["predefinedAcl"].must_equal "private"
      [200, {"Content-Type"=>"application/json"},
       file.gapi.to_json]
    end

    file.copy "new-bucket", "new-file.ext", acl: "private"
  end

  it "can copy itself to a different bucket with ACL alias" do
    mock_connection.post "/storage/v1/b/#{bucket.name}/o/#{file.name}/copyTo/b/new-bucket/o/new-file.ext" do |env|
      env.params["predefinedAcl"].must_equal "publicRead"
      [200, {"Content-Type"=>"application/json"},
       file.gapi.to_json]
    end

    file.copy "new-bucket", "new-file.ext", acl: :public
  end

  it "can reload itself" do

    file_name = "file.ext"

    mock_connection.get "/storage/v1/b/#{bucket.name}/o/#{file_name}" do |env|
      URI(env.url).query.must_be :nil?
      [200, {"Content-Type"=>"application/json"},
        random_file_hash(bucket.name, file_name, 1234567891).to_json]
    end

    mock_connection.get "/storage/v1/b/#{bucket.name}/o/#{file_name}" do |env|
      URI(env.url).query.must_be :nil?
      [200, {"Content-Type"=>"application/json"},
        random_file_hash(bucket.name, file_name, 1234567892).to_json]
    end

    file = bucket.file file_name
    file.generation.must_equal 1234567891
    file.reload!
    file.generation.must_equal 1234567892
  end
end
