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
require_relative "../posix_to_posix_request"

describe "Storage Transfer Service POSIX to POSIX" do
  let(:project) { Google::Cloud::Storage.new }
  let(:intermediate_bucket) { create_bucket_helper random_bucket_name }
  let(:source_agent_pool_name) { "" }
  let(:sink_agent_pool_name) { "" }
  let(:description) { "This is a posix to posix transfer job" }
  let(:root_directory) { Dir.mktmpdir }
  let(:destination_directory) { Dir.mktmpdir }
  let(:dummy_file_name) { "ruby_storagetransfer_samples_dummy_#{SecureRandom.hex}.txt" }
  let(:dummy_file_path) { "#{root_directory}/#{dummy_file_name}" }
  let(:destination_file_path) { "#{destination_directory}/#{dummy_file_name}" }
  let(:create_dummy_file) {
    # create dummy file
    File.write dummy_file_path, "This is the dummy content of the file."
  }

  before do
    create_dummy_file
    puts "Dummy file created"
    grant_sts_permissions project_id: project.project_id, bucket_name: intermediate_bucket.name
  end

  after do
    # delete dummy source file and folder
    if Dir.exist? root_directory
      FileUtils.rm_rf root_directory
      puts "Source Folder deleted: #{root_directory}"
    else
      puts "Source folder not found: #{root_directory}"
    end

    # delete dummy destination file and folder
    if Dir.exist? destination_directory
      FileUtils.rm_rf destination_directory
      puts "Destination folder deleted#{destination_directory}."
    else
      puts "Destination folder not found '#{destination_directory}'"
    end

    puts "Delete bucket"
    delete_bucket_helper intermediate_bucket.name
  end

  it "creates a transfer job" do
    out, _err = capture_io do
      retry_resource_exhaustion do
        transfer_between_posix project_id: project.project_id, description: description, source_agent_pool_name: source_agent_pool_name, sink_agent_pool_name: sink_agent_pool_name, root_directory: root_directory, destination_directory: destination_directory, intermediate_bucket: intermediate_bucket.name
      end
    end
    assert_includes out, "transferJobs"
    job_name = out.scan(%r{(transferJobs/.*)}).flatten.first
    delete_transfer_job project_id: project.project_id, job_name: job_name
  end

  it "checks the file is created in destination directory" do
    out, _err = capture_io do
      retry_resource_exhaustion do
        transfer_between_posix project_id: project.project_id, description: description, source_agent_pool_name: source_agent_pool_name, sink_agent_pool_name: sink_agent_pool_name, root_directory: root_directory, destination_directory: destination_directory, intermediate_bucket: intermediate_bucket.name
      end
    end
    # Object takes time to be created on destination folder
    retry_destination_folder_check destination_file_path
    assert File.exist?(destination_file_path), "File #{dummy_file_name} should exist on #{destination_directory}"

    # Delete transfer jobs
    job_name = out.scan(%r{(transferJobs/.*)}).flatten.first
    delete_transfer_job project_id: project.project_id, job_name: job_name
  end
end

def retry_destination_folder_check destination_file_path
  5.times do
    return true if File.exist? destination_file_path
    puts "retry destination folder check"
    sleep rand(25..35)
  end
end
