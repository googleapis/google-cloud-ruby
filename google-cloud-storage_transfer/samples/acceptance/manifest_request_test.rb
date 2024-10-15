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
require "google/cloud/storage_transfer"

require "stringio"
require "csv"


describe "Storage Transfer Service manifest_request" do
  let(:storage_transfer) {Google::Cloud::StorageTransfer.new}
  let(:project) { Google::Cloud::Storage.new }
  let(:source_bucket) { create_bucket_helper random_bucket_name}
  let(:sink_bucket) { create_bucket_helper random_bucket_name }
  let(:my_file_path) {"testfile.jpeg"}
  let(:manifestfile_path) {"manifest.csv"}
  let(:manifest_location) {"gs://#{source_bucket.name}/#{manifestfile_path}"}
  let(:source_agent_pool_name) {'test-pool'}
  let(:data_csv) { CSV.generate { |csv|  csv << ["gs://#{source_bucket.name}/#{manifestfile_path}"] } }
  let(:data_io) { StringIO.new data_csv }
    let(:file) { source_bucket.file(manifestfile_path) || source_bucket.create_file(data_io, manifestfile_path) }

  # let(:agent_pool) {
  #   Google::Cloud::StorageTransfer.new.create_agent_pool(
  #     agent_pool_name: source_agent_pool_name
  #   )
  # }

  before do
    file_content = "This is a dummy file ."
    string_io = StringIO.new(file_content)
    source_bucket.create_file string_io, my_file_path
    puts "#{my_file_path}  file uploaded to GCS at gs://#{source_bucket.name}/#{my_file_path}"

    file
    puts "#{manifestfile_path}  file uploaded to GCS at gs://#{source_bucket.name}/#{manifestfile_path}"
    grant_sts_permissions project_id: project.project_id, bucket_name: source_bucket.name
    grant_sts_permissions project_id: project.project_id, bucket_name: sink_bucket.name


  end
  # after do
  #   delete_bucket_helper source_bucket.name
  #   delete_bucket_helper sink_bucket.name
  # end

  # it "creates a transfer job" do
 
  #   out, _err = capture_io do
  #     retry_resource_exhaustion do
  #       manifest_request project_id: project.project_id, gcs_source_bucket: source_bucket.name, gcs_sink_bucket: sink_bucket.name , manifest_location: manifest_location
  #     end
  #   end
  #   assert_includes out, "transferJobs"
  #   job_name = out.scan(%r{transferJobs/\d+})[0]

  #   #  file = sink_bucket.file(my_file_path)
  #   #  assert file

  #   # delete_transfer_job project_id: project.project_id, job_name: job_name
  # end

  it "checks the file is created in destination bucket" do
    out, _err = capture_io do
      retry_resource_exhaustion do
        manifest_request project_id: project.project_id, gcs_source_bucket: source_bucket.name, gcs_sink_bucket: sink_bucket.name , manifest_location: manifest_location
      end
    end
     file = sink_bucket.file(my_file_path)
     assert file
  end
end


