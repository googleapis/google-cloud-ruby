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
require_relative "../posix_download_request"

describe "Storage Transfer Service  POSIX download" do
  let(:project) { Google::Cloud::Storage.new }
  let(:source_bucket) { create_bucket_helper random_bucket_name }
  let(:sink_agent_pool_name) { "" }
  let(:description) { "This is a posix download transfer job" }
  let(:destination_directory) { Dir.mktmpdir }
  let(:dummy_file_name) { "ruby_storagetransfer_samples_dummy_#{SecureRandom.hex}.txt" }
  let(:destination_file_path) { "#{destination_directory}/#{dummy_file_name}" }
  let(:gcs_source_path) { "test/" }
  let(:create_dummy_file) {
    source_bucket.create_file StringIO.new("this is dummy"), gcs_source_path + dummy_file_name
  }
  before do
    create_dummy_file
    puts "Dummy file created"
    grant_sts_permissions project_id: project.project_id, bucket_name: source_bucket.name
  end

  after do
    # delete dummy file and folder
    if Dir.exist? destination_directory
      FileUtils.rm_rf destination_directory
      puts "folder  deleted#{destination_directory}."
    else
      puts "folder not found '#{destination_directory}'"
    end
    puts "Delete bucket"
    delete_bucket_helper source_bucket.name
  end

  it "creates a transfer job" do
    out, _err = capture_io do
      retry_resource_exhaustion do
        download_from_gcs project_id: project.project_id, description: description, sink_agent_pool_name: sink_agent_pool_name, destination_directory: destination_directory, source_bucket: source_bucket.name, gcs_source_path: gcs_source_path
      end
    end
    assert_includes out, "transferJobs"
    job_name = out.scan(%r{(transferJobs/.*)}).flatten.first
    delete_transfer_job project_id: project.project_id, job_name: job_name
  end
end
