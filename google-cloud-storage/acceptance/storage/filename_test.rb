# Copyright 2016 Google LLC
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

describe Google::Cloud::Storage::File, :storage do
  let(:bucket_name) {
    ENV["GCLOUD_TEST_STORAGE_BUCKET"] || "storage-library-test-bucket"
  }
  let :bucket do
    storage.bucket(bucket_name)
  end

  # Normalization Form C: a single character for e-acute U+00e9.
  # URL should end with Cafe%CC%81
  # Normalization Form D: an ASCII e followed by U+0301 combining character
  # URL should end with Caf%C3%A9
  let(:filenames) { ["Caf\u00e9", "Cafe\u0301"] }
  let(:filecontent) { ["Normalization Form C", "Normalization Form D"] }

  it "does not perform any file name normalization" do
    filenames.each_with_index do |name, i|
      file = bucket.file name
      file.name.must_equal name
      Tempfile.open "cafe" do |tmpfile|
        downloaded = file.download tmpfile
        File.read(downloaded.path).must_equal filecontent[i]
      end
    end
  end
end
