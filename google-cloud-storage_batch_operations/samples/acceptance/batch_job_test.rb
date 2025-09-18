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
require_relative "../storage_batch_list_job"
require_relative "../storage_batch_get_job"

describe "Batch jobs Snippets" do
  let(:bucket_name)           { random_bucket_name }
  let(:project_id)       { storage_client.project }
  let(:file_content)     { "some content" }
  let(:remote_file_name) { "ruby_file_#{SecureRandom.hex}" }

  before :all do
    bucket = create_bucket_helper bucket_name
    bucket.create_file StringIO.new(file_content), remote_file_name
  end

  after :all do
    delete_bucket_helper bucket_name
  end

  it "creates, lists, gets, cancels, and deletes a batch job in sequence" do
    job_id = "ruby-sbo-job-#{SecureRandom.hex}"

    # Create job
    assert_output "The #{job_id} is created.\n" do
      create_job bucket_name: bucket_name, prefix: "ruby_file", job_id: job_id, project_id: project_id
    end

    # List jobs
    out, _err = capture_io { list_job project_id: project_id }
    assert_includes out, job_id, "#{job_id} not found in the list"

    # Get job details
    out, _err = capture_io { get_job project_id: project_id, job_id: job_id }
    assert_includes out, job_id, "#{job_id} not found"

    # Cancel job
    expected_output_pattern = /The #{job_id} is canceled\.|#{job_id} was already completed or was not created\./

    assert_output expected_output_pattern do
      cancel_job project_id: project_id, job_id: job_id
    end

    # Delete job
    assert_output "The #{job_id} is deleted.\n" do
      delete_job project_id: project_id, job_id: job_id
    end
  end
end
