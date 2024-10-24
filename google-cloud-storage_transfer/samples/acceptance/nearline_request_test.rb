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
require_relative "../nearline_request"

describe "Storage Transfer Service To Nearline Transfer" do
  let(:project) { Google::Cloud::Storage.new }
  let(:source_bucket) { create_bucket_helper random_bucket_name }
  let(:sink_bucket) { create_nearline_bucket_helper random_bucket_name }
  let(:dummy_file_name) { "ruby_storagetransfer_samples_dummy_#{SecureRandom.hex}.txt" }

  before do
    # create dummy file in source bucket
    source_bucket.create_file StringIO.new("this is dummy"), dummy_file_name
    grant_sts_permissions project_id: project.project_id, bucket_name: source_bucket.name
    grant_sts_permissions project_id: project.project_id, bucket_name: sink_bucket.name
  end

  after do
    delete_bucket_helper source_bucket.name
    delete_bucket_helper sink_bucket.name
  end

  it "creates a transfer job" do
    out, _err = capture_io do
      create_daily_nearline_30_day_migration project_id: project.project_id, gcs_source_bucket: source_bucket.name, gcs_sink_bucket: sink_bucket.name, start_date: Time.now
    end
    assert_includes out, "transferJobs"
    job_name = out.scan(%r{(transferJobs/.*)}).flatten.first
    # delete transfer job
    delete_transfer_job project_id: project.project_id, job_name: job_name
  end

  it "checks the file is created in destination bucket" do
    out, _err = capture_io do
      retry_resource_exhaustion do
        create_daily_nearline_30_day_migration project_id: project.project_id, gcs_source_bucket: source_bucket.name, gcs_sink_bucket: sink_bucket.name, start_date: Time.now
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
