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

require_relative "helper"
require_relative "../quickstart"

describe "Storage Transfer Service Quickstart" do
  let(:project) { Google::Cloud::Storage.new }
  let(:source_bucket) { create_bucket_helper random_bucket_name }
  let(:sink_bucket) { create_bucket_helper random_bucket_name }

  after do
    delete_bucket_helper source_bucket.name
    delete_bucket_helper sink_bucket.name
  end

  it "creates a transfer job" do
    grant_sts_permissions project_id: project.project_id, bucket_name: source_bucket.name
    grant_sts_permissions project_id: project.project_id, bucket_name: sink_bucket.name
    out, _err = capture_io do
      retry_resource_exhaustion do
        quickstart project_id: project.project_id, gcs_source_bucket: source_bucket.name, gcs_sink_bucket: sink_bucket.name
      end
    end

    assert_includes out, "transferJobs"
    job_name = out.scan(%r{transferJobs/\d+})[0]

    delete_transfer_job project_id: project.project_id, job_name: job_name
  end
end
