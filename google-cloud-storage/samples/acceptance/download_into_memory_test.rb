# Copyright 2021 Google LLC
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

require "google/cloud/storage"
require_relative "helper"
require_relative "../storage_download_file_into_memory"

describe "Download file into memory" do
  let(:storage_client) { Google::Cloud::Storage.new }
  let(:bucket) { @bucket }
  let(:remote_file_name) { "path/file_name_#{SecureRandom.hex}.txt" }
  let(:file_content) { "some content" }

  before :all do
    @bucket = create_bucket_helper random_bucket_name
  end

  after :all do
    delete_bucket_helper bucket.name
  end

  it "downloads file into memory" do
    bucket.create_file StringIO.new(file_content), remote_file_name

    assert_output "Contents of storage object #{remote_file_name} in bucket #{bucket.name} are: #{file_content}\n" do
      download_file_into_memory bucket_name: bucket.name,
                                file_name: remote_file_name
    end
  end
end