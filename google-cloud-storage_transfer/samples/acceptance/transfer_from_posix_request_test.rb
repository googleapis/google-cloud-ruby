# Copyright 2024 Google LLC
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
require_relative "../transfer_from_posix_request"

describe "Storage Transfer Service from POSIX" do
  let(:storage) { Google::Cloud::Storage.new }
  let(:sink_bucket) { create_bucket_helper random_bucket_name }
  let(:description) { "This is a posix to bucket transfer job" }
  let(:agent_pool_name) { "" }
  let(:root_directory) { Dir.mktmpdir }
  let(:dummy_file_name) { "ruby_storagetransfer_samples_dummy_#{SecureRandom.hex}.txt" }
  let(:dummy_file_path) { "#{root_directory}/#{dummy_file_name}" }
  let(:create_dummy_file) {
    # create dummy file
    File.write dummy_file_path, "w" do |file|
      file.write "this is dummy"
    end
  }

  before do
    create_dummy_file
    puts "Dummy file created"
    grant_sts_permissions project_id: storage.project_id, bucket_name: sink_bucket.name
  end

  after do
    # delete dummy file and folder
    if Dir.exist? root_directory
      FileUtils.rm_rf root_directory
      puts "folder deleted #{root_directory}."
    else
      puts "folder not found #{root_directory}"
    end
    puts "Delete bucket"
    delete_bucket_helper sink_bucket.name
  end

  it "creates a transfer job" do
    out, _err = capture_io do
      retry_resource_exhaustion do
        posix_request project_id: storage.project_id, description: description, gcs_sink_bucket: sink_bucket.name, source_agent_pool_name: agent_pool_name, root_directory: root_directory
      end
    end
    assert_includes out, "transferJobs"
    job_name = out.scan(%r{(transferJobs/.*)}).flatten.first
    delete_transfer_job project_id: storage.project_id, job_name: job_name
  end
end
