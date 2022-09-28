# Copyright 2022 Google LLC
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

require_relative "helper"
require_relative "../storage_configure_retries"

describe "Retry Samples" do
  let(:local_file) { File.expand_path "data/file.txt", __dir__ }
  let(:remote_file_name) { "path/file_name_#{SecureRandom.hex}.txt" }
  let(:bucket) { @bucket }

  before :all do
    @bucket = create_bucket_helper random_bucket_name
  end

  after :all do
    delete_bucket_helper @bucket.name
  end

  after do
    bucket.files.each(&:delete)
  end

  it "configure_retries" do
    bucket.create_file local_file, remote_file_name

    assert_output "File #{remote_file_name} deleted with a customized retry strategy.\n" do
      configure_retries bucket_name: bucket.name, file_name: remote_file_name
    end

    assert_nil bucket.file remote_file_name
  end
end
