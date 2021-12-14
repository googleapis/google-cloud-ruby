# Copyright 2015 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"
require "json"
require "uri"

describe Google::Cloud::Bigquery::Job, :mock_bigquery do
  # Create a job object with the project's mocked connection object
  let(:region) { "US" }
  let(:labels) { { "foo" => "bar" } }
  let(:session_id) { "mysessionid" }
  let(:job_hash) { random_job_hash location: region, transaction_id: "123456789", session_id: session_id }
  let(:job_gapi) do
    job_gapi = Google::Apis::BigqueryV2::Job.from_json job_hash.to_json
    job_gapi.configuration.labels = labels
    job_gapi
  end
  let(:job) { Google::Cloud::Bigquery::Job.from_gapi job_gapi,
                                              bigquery.service }
  let(:job_id) { job.job_id }

  let(:failed_job_hash) do
    hash = random_job_hash "1234567890", "DONE", location: region
    hash["status"]["errorResult"] = {
      "reason"    => "r34s0n",
      "location"  => "l0c4t10n",
      "debugInfo" => "d3bugInf0",
      "message"   => "m3ss4g3"
    }
    hash["status"]["errors"] = [{
      "reason"    => "r34s0n",
      "location"  => "l0c4t10n",
      "debugInfo" => "d3bugInf0",
      "message"   => "m3ss4g3"
    }]
    hash
  end
  let(:failed_job_gapi) { Google::Apis::BigqueryV2::Job.from_json failed_job_hash.to_json }
  let(:failed_job) { Google::Cloud::Bigquery::Job.from_gapi failed_job_gapi,
                                              bigquery.service }
  let(:failed_job_id) { failed_job.job_id }

  it "knows its attributes" do
    _(job.job_id).wont_be :nil?
    _(job.job_id).must_equal job_gapi.job_reference.job_id
    _(job.location).must_equal region
    _(job.labels).must_equal labels
    _(job.labels).must_be :frozen?
    _(job.user_email).must_equal "user@example.com"
    _(job.num_child_jobs).must_equal 2
    _(job.parent_job_id).must_equal "2222222222"
    _(job.session_id).must_equal session_id
  end

  it "knows its state" do
    _(job.state).must_equal "running"
    _(job).must_be :running?
    _(job).wont_be :pending?
    _(job).wont_be :done?
    _(job).wont_be :failed?

    job.gapi.status.state = "RUNNING"
    _(job.state).must_equal "RUNNING"
    _(job).must_be :running?
    _(job).wont_be :pending?
    _(job).wont_be :done?
    _(job).wont_be :failed?

    job.gapi.status.state = "pending"
    _(job.state).must_equal "pending"
    _(job).wont_be :running?
    _(job).must_be :pending?
    _(job).wont_be :done?
    _(job).wont_be :failed?

    job.gapi.status.state = "PENDING"
    _(job.state).must_equal "PENDING"
    _(job).wont_be :running?
    _(job).must_be :pending?
    _(job).wont_be :done?
    _(job).wont_be :failed?

    job.gapi.status.state = "done"
    _(job.state).must_equal "done"
    _(job).wont_be :running?
    _(job).wont_be :pending?
    _(job).must_be :done?
    _(job).wont_be :failed?

    job.gapi.status.state = "DONE"
    _(job.state).must_equal "DONE"
    _(job).wont_be :running?
    _(job).wont_be :pending?
    _(job).must_be :done?
    _(job).wont_be :failed?

    job.gapi.status.state = nil
    _(job.state).must_be :nil?
    _(job).wont_be :running?
    _(job).wont_be :pending?
    _(job).wont_be :done?
    _(job).wont_be :failed?
  end

  it "knows its creation and modification times" do
    job.gapi.statistics.creation_time = nil
    job.gapi.statistics.start_time = nil
    job.gapi.statistics.end_time = nil

    _(job.created_at).must_be :nil?
    _(job.started_at).must_be :nil?
    _(job.ended_at).must_be :nil?

    nowish = ::Time.now
    timestamp = time_millis

    job.gapi.statistics.creation_time = timestamp
    job.gapi.statistics.start_time = timestamp
    job.gapi.statistics.end_time = timestamp

    _(job.created_at).must_be_close_to nowish, 1
    _(job.started_at).must_be_close_to nowish, 1
    _(job.ended_at).must_be_close_to nowish, 1
  end

  it "knows its configuration" do
    _(job.config).must_be_kind_of Hash
    _(job.config["dryRun"]).must_equal false
    _(job.configuration).must_be_kind_of Hash
    _(job.configuration["dryRun"]).must_equal false
  end

  it "knows its reservation usage" do
    _(job.reservation_usage).must_be_kind_of Array
    _(job.reservation_usage.count).must_equal 1
    _(job.reservation_usage[0]).must_be_kind_of Google::Cloud::Bigquery::Job::ReservationUsage
    _(job.reservation_usage[0].name).must_equal "unreserved"
    _(job.reservation_usage[0].slot_ms).must_equal 12345
  end

  it "knows its transaction_info transaction ID" do
    _(job.transaction_id).must_equal "123456789"
  end

  it "knows its statistics config" do
    _(job.statistics).must_be_kind_of Hash
    _(job.statistics["creationTime"]).wont_be :nil?
    _(job.stats).must_be_kind_of Hash
    _(job.stats["creationTime"]).wont_be :nil?
  end

  it "knows its script statistics" do
    _(job.script_statistics).must_be_kind_of Google::Cloud::Bigquery::Job::ScriptStatistics
    _(job.script_statistics.evaluation_kind).must_equal "EXPRESSION"
    _(job.script_statistics.stack_frames).wont_be :nil?
    _(job.script_statistics.stack_frames).must_be_kind_of Array
    _(job.script_statistics.stack_frames.count).must_equal 1
    _(job.script_statistics.stack_frames[0]).must_be_kind_of Google::Cloud::Bigquery::Job::ScriptStackFrame
    _(job.script_statistics.stack_frames[0].start_line).must_equal 5
    _(job.script_statistics.stack_frames[0].start_column).must_equal 29
    _(job.script_statistics.stack_frames[0].end_line).must_equal 9
    _(job.script_statistics.stack_frames[0].end_column).must_equal 14
    _(job.script_statistics.stack_frames[0].text).must_equal "QUERY TEXT"
  end

  it "knows its error info if it has not failed" do
    _(job).wont_be :failed?
    _(job.error).must_be :nil?
    _(job.errors.count).must_equal 0
  end

  it "knows if it has failed" do
    _(failed_job.state).must_equal "DONE"
    _(failed_job).must_be :failed?
    _(failed_job.error).must_be_kind_of Hash
    _(failed_job.error).wont_be :empty?
    _(failed_job.error["reason"]).must_equal "r34s0n"
    _(failed_job.error["location"]).must_equal "l0c4t10n"
    _(failed_job.error["debugInfo"]).must_equal "d3bugInf0"
    _(failed_job.error["message"]).must_equal "m3ss4g3"
    _(failed_job.errors.count).must_equal 1
    _(failed_job.errors.first["reason"]).must_equal "r34s0n"
    _(failed_job.errors.first["location"]).must_equal "l0c4t10n"
    _(failed_job.errors.first["debugInfo"]).must_equal "d3bugInf0"
    _(failed_job.errors.first["message"]).must_equal "m3ss4g3"
  end

  it "can reload itself" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :get_job,
                Google::Apis::BigqueryV2::Job.from_json(random_job_hash(job_id, "done").to_json),
                [project, job_id, {location: "US"}]

    _(job).must_be :running?
    job.reload!
    _(job).must_be :done?
    mock.verify
  end

  it "can wait until done" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :get_job,
                get_job_resp("pending"),
                [project, job_id, {location: "US"}]
    mock.expect :get_job,
                get_job_resp("pending"),
                [project, job_id, {location: "US"}]
    mock.expect :get_job,
                get_job_resp("running"),
                [project, job_id, {location: "US"}]
    mock.expect :get_job,
                get_job_resp("running"),
                [project, job_id, {location: "US"}]
    mock.expect :get_job,
                get_job_resp("done"),
                [project, job_id, {location: "US"}]


    # mock out the sleep method so the test doesn't actually block
    def job.sleep *args
    end

    _(job).must_be :running?
    job.wait_until_done!
    _(job).must_be :done?
    mock.verify
  end

  it "can cancel itself" do
    mock = Minitest::Mock.new
    mock.expect :cancel_job, Google::Apis::BigqueryV2::CancelJobResponse.new(job: job_gapi),
      [project, job_id, location: region]
    bigquery.service.mocked_service = mock

    job.cancel
    mock.verify
  end

  it "can delete itself" do
    mock = Minitest::Mock.new
    mock.expect :delete_job, nil, [project, job_id, location: region]
    bigquery.service.mocked_service = mock

    job.delete
    mock.verify
  end

  def get_job_resp state
    Google::Apis::BigqueryV2::Job.from_json(random_job_hash(job_id, state, location: region).to_json)
  end
end
