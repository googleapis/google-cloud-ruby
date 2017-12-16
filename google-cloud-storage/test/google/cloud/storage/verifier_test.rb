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

describe Google::Cloud::Storage::File::Verifier, :mock_storage do
  let(:file_contents) { "The quick brown fox jumps over the lazy dog." }
  let(:md5_digest) { "1B2M2Y8AsgTpgAmY7PhCfg==" }
  let(:crc32c_digest) { "AAAAAA==" }
  let(:file_gapi) { Google::Apis::StorageV1::Object.from_json corrected_file_hash.to_json }
  let(:file) { Google::Cloud::Storage::File.from_gapi file_gapi, OpenStruct.new }

  it "verifies md5 digest" do
    Tempfile.open "google-cloud" do |tmpfile|
      tmpfile.write file_contents
      assert Google::Cloud::Storage::File::Verifier.verify_md5(file, tmpfile)
    end
  end

  it "verifies crc32c digest" do
    Tempfile.open "google-cloud" do |tmpfile|
      tmpfile.write file_contents
      assert Google::Cloud::Storage::File::Verifier.verify_crc32c(file, tmpfile)
    end
  end

  it "calculates md5 digest" do
    Tempfile.open "google-cloud" do |tmpfile|
      tmpfile.write file_contents
      digest = Google::Cloud::Storage::File::Verifier.md5_for tmpfile
      digest.must_equal md5_digest
    end
  end

  it "calculates crc32c digest" do
    Tempfile.open "google-cloud" do |tmpfile|
      tmpfile.write file_contents
      digest = Google::Cloud::Storage::File::Verifier.crc32c_for tmpfile
      digest.must_equal crc32c_digest
    end
  end

  def corrected_file_hash
    hash = random_file_hash("bucket", "file.ext")
    hash["md5Hash"] = md5_digest
    hash["crc32c"] = crc32c_digest
    hash
  end
end
