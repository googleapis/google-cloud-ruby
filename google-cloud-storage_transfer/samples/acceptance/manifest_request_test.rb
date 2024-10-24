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
require_relative "../manifest_request"
require "csv"


describe "Storage Transfer Service manifest_request" do
  let(:project) { Google::Cloud::Storage.new }
  let(:source_bucket) { create_bucket_helper random_bucket_name }
  let(:sink_bucket) { create_bucket_helper random_bucket_name }
  let(:root_directory) { "/tmp/uploads" }
  let(:dummy_file_name) { "ruby_storagetransfer_samples_dummy_#{SecureRandom.hex}.txt" }
  let(:dummy_file_path) { "#{root_directory}/#{dummy_file_name}" }
  let(:create_dummy_file) {
    # create dummy file 
    File.open dummy_file_path, "w" do |file|
      file.write "this is dummy"
    end
  }
  let(:manifestfile_path) { "manifest.csv" }
  let(:manifest_location) { "gs://#{source_bucket.name}/#{manifestfile_path}" }
  let(:agent_pool_name) { "" }
  let(:data_csv) {
    create_dummy_file
    # create manifestcsv file
    CSV.generate { |csv| csv << [dummy_file_name] }
  }
  let(:data_io) { StringIO.new data_csv }
  let(:create_manifest_file) { source_bucket.file(manifestfile_path) || source_bucket.create_file(data_io, manifestfile_path) }

  before do
    create_manifest_file
    grant_sts_permissions project_id: project.project_id, bucket_name: source_bucket.name
    grant_sts_permissions project_id: project.project_id, bucket_name: sink_bucket.name
  end
  after do
    # delete dummy file
    if File.exist? dummy_file_path
      File.delete dummy_file_path
      puts "File deleted: #{dummy_file_path}"
    else
      puts "File not found: #{dummy_file_path}"
    end
    delete_bucket_helper source_bucket.name
    delete_bucket_helper sink_bucket.name
  end

  it "creates a transfer job" do
    out, _err = capture_io do
      retry_resource_exhaustion do
        manifest_request project_id: project.project_id, gcs_sink_bucket: sink_bucket.name, manifest_location: manifest_location, source_agent_pool_name: agent_pool_name, root_directory: root_directory
      end
    end
    assert_includes out, "transferJobs"
    job_name = out.scan(%r{(transferJobs/.*)}).flatten.first
    delete_transfer_job project_id: project.project_id, job_name: job_name
  end

  it "checks the file is created in destination bucket" do
    out, _err = capture_io do
      retry_resource_exhaustion do
        manifest_request project_id: project.project_id, gcs_sink_bucket: sink_bucket.name, manifest_location: manifest_location, source_agent_pool_name: agent_pool_name, root_directory: root_directory
      end
    end
    # Object takes time to be created on bucket hence retrying
    file = retry_untill_tranfer_is_done do
            sink_bucket.file dummy_file_name
          end
    assert file.is_a?(Google::Cloud::Storage::File), "File #{dummy_file_name} should exist on #{sink_bucket.name}"
    # Delete transfer jobs
    job_name = out.scan(%r{(transferJobs/.*)}).flatten.first
    delete_transfer_job project_id: project.project_id, job_name: job_name
  end
end
