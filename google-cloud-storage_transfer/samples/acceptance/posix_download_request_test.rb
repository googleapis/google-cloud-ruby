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
require "pry"

describe "Storage Transfer Service from POSIX" do
  let(:project) { Google::Cloud::Storage.new }
  let(:source_bucket) { create_bucket_helper random_bucket_name }
  let(:sink_agent_pool_name) {"projects/storage-sdk-vendor/agentPools/shubhangi-test-pool"}
  let(:description) { "This is a posix download transfer job" }
  let(:dummy_dir_prefix) {"ruby_storagetransfer_dummy_dir_#{SecureRandom.hex}"}
  let(:destination_directory) { "/tmp/downloads/#{dummy_dir_prefix}" }
  let(:dummy_file_name) { "ruby_storagetransfer_samples_dummy_#{SecureRandom.hex}.txt" }
  let(:destination_file_path) { "#{destination_directory}/#{dummy_file_name}" }
  let(:create_dummy_file) {
    source_bucket.create_file StringIO.new("this is dummy"), dummy_file_name
  }
  let(:gcs_source_path) {"/"}



  before do
    create_dummy_file
    puts "Dummy file created"
    grant_sts_permissions project_id: project.project_id, bucket_name: source_bucket.name
  end

  after do
    # delete dummy file and folder
    # if File.exist? dummy_file_path
    #   FileUtils.rm_rf(root_directory)
    #   puts "File deleted: #{dummy_file_path}"
    # else
    #   puts "File not found: #{dummy_file_path}"
    # end
    puts "Delete bucket"
    delete_bucket_helper source_bucket.name
  end

  # it "creates a transfer job" do
  #   out, _err = capture_io do
  #     retry_resource_exhaustion do
  #       download_from_gcs project_id: project.project_id, description: description, sink_agent_pool_name: sink_agent_pool_name, destination_directory: destination_directory, source_bucket: source_bucket.name, gcs_source_path: gcs_source_path
  #     end
  #   end
  #   assert_includes out, "transferJobs"
  #   job_name = out.scan(%r{(transferJobs/.*)}).flatten.first
  #   binding.pry
  #   delete_transfer_job project_id: project.project_id, job_name: job_name
  # end

  it "checks the file is created in destination directory" do
    out, _err = capture_io do
      retry_resource_exhaustion do
        download_from_gcs project_id: project.project_id, description: description, sink_agent_pool_name: sink_agent_pool_name, destination_directory: destination_directory, source_bucket: source_bucket.name, gcs_source_path: gcs_source_path
      end
    end

    binding.pry
    # Object takes time to be created on destination folder
    retry_destination_folder_check(destination_directory)
    assert File.exist?(destination_file_path), "File #{dummy_file_name} should exist on #{destination_directory}"
    # delete destination folder
    if Dir.exist? destination_directory
      FileUtils.rm_rf(destination_directory)
      puts " folder  deleted#{destination_directory}."
    else
      puts " folder not found '#{destination_directory}'"
    end
    # Delete transfer jobs
    job_name = out.scan(%r{(transferJobs/.*)}).flatten.first
    delete_transfer_job project_id: project.project_id, job_name: job_name
  end
end

def retry_destination_folder_check(destination_directory)
    5.times do
      return true if Dir.exist?(destination_directory)
      puts "retry destination folder check"
      sleep rand(20..25)
    end
end