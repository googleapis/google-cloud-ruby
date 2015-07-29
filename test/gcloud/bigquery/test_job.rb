# Copyright 2014 Google Inc. All rights reserved.
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

require "helper"
require "json"
require "uri"

describe Gcloud::Bigquery::Job, :mock_bigquery do
  # Create a job object with the project's mocked connection object
  let(:job_hash) { random_job_hash }
  let(:job) { Gcloud::Bigquery::Job.from_gapi job_hash,
                                              bigquery.connection }
  let(:job_id) { job.job_id }

  it "knows its attributes" do
    job.job_id.must_equal job_hash["jobReference"]["jobId"]
  end

  it "knows its state" do
    job.state.must_equal "running"
    job.must_be :running?
    job.wont_be :pending?
    job.wont_be :done?

    job.gapi["status"]["state"] = "RUNNING"
    job.state.must_equal "RUNNING"
    job.must_be :running?
    job.wont_be :pending?
    job.wont_be :done?

    job.gapi["status"]["state"] = "pending"
    job.state.must_equal "pending"
    job.wont_be :running?
    job.must_be :pending?
    job.wont_be :done?

    job.gapi["status"]["state"] = "PENDING"
    job.state.must_equal "PENDING"
    job.wont_be :running?
    job.must_be :pending?
    job.wont_be :done?

    job.gapi["status"]["state"] = "done"
    job.state.must_equal "done"
    job.wont_be :running?
    job.wont_be :pending?
    job.must_be :done?

    job.gapi["status"]["state"] = "DONE"
    job.state.must_equal "DONE"
    job.wont_be :running?
    job.wont_be :pending?
    job.must_be :done?

    job.gapi["status"]["state"] = nil
    job.state.must_equal nil
    job.wont_be :running?
    job.wont_be :pending?
    job.wont_be :done?
  end

  it "knows its creation and modification times" do
    job.gapi["statistics"]["creationTime"] = nil
    job.gapi["statistics"]["startTime"] = nil
    job.gapi["statistics"]["endTime"] = nil

    job.created_at.must_be :nil?
    job.started_at.must_be :nil?
    job.ended_at.must_be :nil?

    nowish = Time.now
    timestamp = (nowish.to_f * 1000).floor

    job.gapi["statistics"]["creationTime"] = timestamp
    job.gapi["statistics"]["startTime"] = timestamp
    job.gapi["statistics"]["endTime"] = timestamp

    job.created_at.must_be_close_to nowish
    job.started_at.must_be_close_to nowish
    job.ended_at.must_be_close_to nowish
  end

  it "knows its stats config" do
    job.stats.must_be_kind_of Hash
    job.stats["creationTime"].wont_be :nil?
  end

  it "can refresh itself" do
    mock_connection.get "/bigquery/v2/projects/#{project}/jobs/#{job_id}" do |env|
      [200, {"Content-Type"=>"application/json"},
       random_job_hash(job_id, "done").to_json]
    end

    job.must_be :running?
    job.refresh!
    job.must_be :done?
  end
end
