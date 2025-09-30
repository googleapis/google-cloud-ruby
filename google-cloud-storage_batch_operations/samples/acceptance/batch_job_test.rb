# Copyright 2025 Google LLC
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
require_relative "../storage_batch_create_job"
require_relative "../storage_batch_delete_job"
require_relative "../storage_batch_cancel_job"
require_relative "../storage_batch_list_jobs"
require_relative "../storage_batch_get_job"

describe "Storage Batch Operations" do
  let(:bucket_name) { random_bucket_name }
  let(:project_id)       { storage_client.project }
  let(:file_content)     { "some content" }
  let(:remote_file_name) { "ruby_file_#{SecureRandom.hex}" }
  let(:job_name_prefix) { "projects/#{project_id}/locations/global/jobs/" }

  before :all do
    bucket = create_bucket_helper bucket_name
    bucket.create_file StringIO.new(file_content), remote_file_name
  end

  after :all do
    delete_bucket_helper bucket_name
  end

  it "handles Storage batch operation lifecycle in sequence" do
    job_id = "ruby-sbo-job-#{SecureRandom.hex}"
    job_name = "#{job_name_prefix}#{job_id}"

    # Create job
    assert_output(/Storage Batch Operations job #{job_name} is created./) do
      create_job bucket_name: bucket_name, prefix: "ruby_file", job_id: job_id, project_id: project_id
    end

    # List jobs
    assert_output(/Job name: #{job_name} present in the list/) do
      list_jobs project_id: project_id
    end

    # Get job details
    assert_output(/Storage Batch Operations job Found - #{job_name}, job_status- /) do
      get_job project_id: project_id, job_id: job_id
    end

    # Cancel job
    expected_output_pattern = /Storage Batch Operations job #{job_name} (is canceled|was already completed)\./
    assert_output expected_output_pattern do
      cancel_job project_id: project_id, job_id: job_id
    end

    # Delete job
    assert_output "The #{job_id} is deleted.\n" do
      delete_job project_id: project_id, job_id: job_id
    end
  end
end
