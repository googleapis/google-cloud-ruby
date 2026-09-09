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

describe Google::Cloud::Bigquery::Project, :jobs, :mock_bigquery do
  # let(:email) { "my_service_account@bigquery-encryption.iam.gserviceaccount.com" }
  # let(:service_account_resp) { OpenStruct.new email: email }
  # let(:dataset_id) { "my_dataset" }
  # let(:filter) { "labels.foo:bar" }
  let(:min_time) { Time.now - 60*60*24*7 }
  let(:max_time) { Time.now }
  let(:min_millis) { Google::Cloud::Bigquery::Convert.time_to_millis min_time }
  let(:max_millis) { Google::Cloud::Bigquery::Convert.time_to_millis max_time }
  let(:parent_job) { Google::Cloud::Bigquery::Job.from_gapi query_job_gapi("select * from my_table"), bigquery.service }
  let(:parent_job_id) { parent_job.job_id }


  it "lists jobs" do
    mock = Minitest::Mock.new
    mock.expect :list_jobs, list_jobs_gapi(3),
      [project], all_users: nil, max_results: nil, page_token: nil, projection: "full", state_filter: nil, min_creation_time: nil, max_creation_time: nil, parent_job_id: nil
    bigquery.service.mocked_service = mock

    jobs = bigquery.jobs

    mock.verify

    _(jobs.size).must_equal 3
    jobs.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Job }
  end

  it "lists jobs with max set" do
    mock = Minitest::Mock.new
    mock.expect :list_jobs, list_jobs_gapi(3, "next_page_token"),
      [project], all_users: nil, max_results: 3, page_token: nil, projection: "full", state_filter: nil, min_creation_time: nil, max_creation_time: nil, parent_job_id: nil
    bigquery.service.mocked_service = mock

    jobs = bigquery.jobs max: 3

    mock.verify

    _(jobs.count).must_equal 3
    jobs.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Job }
    _(jobs.token).wont_be :nil?
    _(jobs.token).must_equal "next_page_token"
  end

  it "lists jobs with filter set" do
    mock = Minitest::Mock.new
    mock.expect :list_jobs, list_jobs_gapi(3, "next_page_token"),
      [project], all_users: nil, max_results: nil, page_token: nil, projection: "full", state_filter: "running", min_creation_time: nil, max_creation_time: nil, parent_job_id: nil
    bigquery.service.mocked_service = mock

    jobs = bigquery.jobs filter: "running"

    mock.verify

    _(jobs.count).must_equal 3
    jobs.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Job }
    _(jobs.token).wont_be :nil?
    _(jobs.token).must_equal "next_page_token"
  end

  it "lists jobs with only min_created_at set" do
    mock = Minitest::Mock.new
    mock.expect :list_jobs, list_jobs_gapi(3, "next_page_token"),
      [project], all_users: nil, max_results: nil, page_token: nil, projection: "full", state_filter: nil, min_creation_time: min_millis, max_creation_time: nil, parent_job_id: nil
    bigquery.service.mocked_service = mock

    jobs = bigquery.jobs min_created_at: min_time

    mock.verify

    _(jobs.count).must_equal 3
    jobs.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Job }
    _(jobs.token).wont_be :nil?
    _(jobs.token).must_equal "next_page_token"
  end

  it "lists jobs with only max_created_at set" do
    mock = Minitest::Mock.new
    mock.expect :list_jobs, list_jobs_gapi(3, "next_page_token"),
      [project], all_users: nil, max_results: nil, page_token: nil, projection: "full", state_filter: nil, min_creation_time: nil, max_creation_time: max_millis, parent_job_id: nil
    bigquery.service.mocked_service = mock

    jobs = bigquery.jobs max_created_at: max_time

    mock.verify

    _(jobs.count).must_equal 3
    jobs.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Job }
    _(jobs.token).wont_be :nil?
    _(jobs.token).must_equal "next_page_token"
  end

  it "lists jobs with created_at set" do
    mock = Minitest::Mock.new
    mock.expect :list_jobs, list_jobs_gapi(3, "next_page_token"),
      [project], all_users: nil, max_results: nil, page_token: nil, projection: "full", state_filter: nil, min_creation_time: min_millis, max_creation_time: max_millis, parent_job_id: nil
    bigquery.service.mocked_service = mock

    jobs = bigquery.jobs min_created_at: min_time, max_created_at: max_time

    mock.verify

    _(jobs.count).must_equal 3
    jobs.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Job }
    _(jobs.token).wont_be :nil?
    _(jobs.token).must_equal "next_page_token"
  end

  it "lists jobs with parent_job set to a string" do
    mock = Minitest::Mock.new
    mock.expect :list_jobs, list_jobs_gapi(3, "next_page_token"),
      [project], all_users: nil, max_results: nil, page_token: nil, projection: "full", state_filter: nil, min_creation_time: nil, max_creation_time: nil, parent_job_id: parent_job_id
    bigquery.service.mocked_service = mock

    jobs = bigquery.jobs parent_job: parent_job_id

    mock.verify

    _(jobs.count).must_equal 3
    jobs.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Job }
    _(jobs.token).wont_be :nil?
    _(jobs.token).must_equal "next_page_token"
  end

  it "lists jobs with parent_job set to a job" do
    mock = Minitest::Mock.new
    mock.expect :list_jobs, list_jobs_gapi(3, "next_page_token"),
      [project], all_users: nil, max_results: nil, page_token: nil, projection: "full", state_filter: nil, min_creation_time: nil, max_creation_time: nil, parent_job_id: parent_job_id
    bigquery.service.mocked_service = mock

    jobs = bigquery.jobs parent_job: parent_job

    mock.verify

    _(jobs.count).must_equal 3
    jobs.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Job }
    _(jobs.token).wont_be :nil?
    _(jobs.token).must_equal "next_page_token"
  end

  it "lists jobs with filter and created_at set" do
    mock = Minitest::Mock.new
    mock.expect :list_jobs, list_jobs_gapi(3, "next_page_token"),
      [project], all_users: nil, max_results: nil, page_token: nil, projection: "full", state_filter: "running", min_creation_time: min_millis, max_creation_time: max_millis, parent_job_id: nil
    bigquery.service.mocked_service = mock

    jobs = bigquery.jobs filter: "running", min_created_at: min_time, max_created_at: max_time

    mock.verify

    _(jobs.count).must_equal 3
    jobs.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Job }
    _(jobs.token).wont_be :nil?
    _(jobs.token).must_equal "next_page_token"
  end

  it "paginates jobs" do
    mock = Minitest::Mock.new
    mock.expect :list_jobs, list_jobs_gapi(3, "next_page_token"),
      [project], all_users: nil, max_results: nil, page_token: nil, projection: "full", state_filter: nil, min_creation_time: nil, max_creation_time: nil, parent_job_id: nil
    mock.expect :list_jobs, list_jobs_gapi(2),
      [project], all_users: nil, max_results: nil, page_token: "next_page_token", projection: "full", state_filter: nil, min_creation_time: nil, max_creation_time: nil, parent_job_id: nil
    bigquery.service.mocked_service = mock

    first_jobs = bigquery.jobs
    second_jobs = bigquery.jobs token: first_jobs.token

    mock.verify

    _(first_jobs.count).must_equal 3
    first_jobs.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Job }
    _(first_jobs.token).wont_be :nil?
    _(first_jobs.token).must_equal "next_page_token"

    _(second_jobs.count).must_equal 2
    second_jobs.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Job }
    _(second_jobs.token).must_be :nil?
  end

  it "paginates jobs using next? and next" do
    mock = Minitest::Mock.new
    mock.expect :list_jobs, list_jobs_gapi(3, "next_page_token"),
      [project], all_users: nil, max_results: nil, page_token: nil, projection: "full", state_filter: nil, min_creation_time: nil, max_creation_time: nil, parent_job_id: nil
    mock.expect :list_jobs, list_jobs_gapi(2),
      [project], all_users: nil, max_results: nil, page_token: "next_page_token", projection: "full", state_filter: nil, min_creation_time: nil, max_creation_time: nil, parent_job_id: nil
    bigquery.service.mocked_service = mock

    first_jobs = bigquery.jobs
    second_jobs = first_jobs.next

    mock.verify

    _(first_jobs.count).must_equal 3
    first_jobs.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Job }
    _(first_jobs.next?).must_equal true

    _(second_jobs.count).must_equal 2
    second_jobs.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Job }
    _(second_jobs.next?).must_equal false
  end

  it "paginates jobs with next? and next and filter set" do
    mock = Minitest::Mock.new
    mock.expect :list_jobs, list_jobs_gapi(3, "next_page_token"),
      [project], all_users: nil, max_results: nil, page_token: nil, projection: "full", state_filter: "running", min_creation_time: nil, max_creation_time: nil, parent_job_id: nil
    mock.expect :list_jobs, list_jobs_gapi(2),
      [project], all_users: nil, max_results: nil, page_token: "next_page_token", projection: "full", state_filter: "running", min_creation_time: nil, max_creation_time: nil, parent_job_id: nil
    bigquery.service.mocked_service = mock

    first_jobs = bigquery.jobs filter: "running"
    second_jobs = first_jobs.next

    mock.verify

    _(first_jobs.count).must_equal 3
    first_jobs.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Job }
    _(first_jobs.next?).must_equal true

    _(second_jobs.count).must_equal 2
    second_jobs.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Job }
    _(second_jobs.next?).must_equal false
  end

  it "paginates jobs with next? and next and created_at set" do
    mock = Minitest::Mock.new
    mock.expect :list_jobs, list_jobs_gapi(3, "next_page_token"),
      [project], all_users: nil, max_results: nil, page_token: nil, projection: "full", state_filter: nil, min_creation_time: min_millis, max_creation_time: max_millis, parent_job_id: nil
    mock.expect :list_jobs, list_jobs_gapi(2),
      [project], all_users: nil, max_results: nil, page_token: "next_page_token", projection: "full", state_filter: nil, min_creation_time: min_millis, max_creation_time: max_millis, parent_job_id: nil
    bigquery.service.mocked_service = mock

    first_jobs = bigquery.jobs min_created_at: min_time, max_created_at: max_time
    second_jobs = first_jobs.next

    mock.verify

    _(first_jobs.count).must_equal 3
    first_jobs.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Job }
    _(first_jobs.next?).must_equal true

    _(second_jobs.count).must_equal 2
    second_jobs.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Job }
    _(second_jobs.next?).must_equal false
  end

  it "paginates jobs with next? and next and parent_job_id set" do
    mock = Minitest::Mock.new
    mock.expect :list_jobs, list_jobs_gapi(3, "next_page_token"),
      [project], all_users: nil, max_results: nil, page_token: nil, projection: "full", state_filter: nil, min_creation_time: nil, max_creation_time: nil, parent_job_id: parent_job_id
    mock.expect :list_jobs, list_jobs_gapi(2),
      [project], all_users: nil, max_results: nil, page_token: "next_page_token", projection: "full", state_filter: nil, min_creation_time: nil, max_creation_time: nil, parent_job_id: parent_job_id
    bigquery.service.mocked_service = mock

    first_jobs = bigquery.jobs parent_job: parent_job_id
    second_jobs = first_jobs.next

    mock.verify

    _(first_jobs.count).must_equal 3
    first_jobs.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Job }
    _(first_jobs.next?).must_equal true

    _(second_jobs.count).must_equal 2
    second_jobs.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Job }
    _(second_jobs.next?).must_equal false
  end

  it "paginates jobs with next? and next and filter and created_at set" do
    mock = Minitest::Mock.new
    mock.expect :list_jobs, list_jobs_gapi(3, "next_page_token"),
      [project], all_users: nil, max_results: nil, page_token: nil, projection: "full", state_filter: "running", min_creation_time: min_millis, max_creation_time: max_millis, parent_job_id: nil
    mock.expect :list_jobs, list_jobs_gapi(2),
      [project], all_users: nil, max_results: nil, page_token: "next_page_token", projection: "full", state_filter: "running", min_creation_time: min_millis, max_creation_time: max_millis, parent_job_id: nil
    bigquery.service.mocked_service = mock

    first_jobs = bigquery.jobs filter: "running", min_created_at: min_time, max_created_at: max_time
    second_jobs = first_jobs.next

    mock.verify

    _(first_jobs.count).must_equal 3
    first_jobs.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Job }
    _(first_jobs.next?).must_equal true

    _(second_jobs.count).must_equal 2
    second_jobs.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Job }
    _(second_jobs.next?).must_equal false
  end

  it "paginates jobs with all" do
    mock = Minitest::Mock.new
    mock.expect :list_jobs, list_jobs_gapi(3, "next_page_token"),
      [project], all_users: nil, max_results: nil, page_token: nil, projection: "full", state_filter: nil, min_creation_time: nil, max_creation_time: nil, parent_job_id: nil
    mock.expect :list_jobs, list_jobs_gapi(2),
      [project], all_users: nil, max_results: nil, page_token: "next_page_token", projection: "full", state_filter: nil, min_creation_time: nil, max_creation_time: nil, parent_job_id: nil
    bigquery.service.mocked_service = mock

    jobs = bigquery.jobs.all.to_a

    mock.verify

    _(jobs.count).must_equal 5
    jobs.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Job }
  end

  it "paginates jobs with all and filter set" do
    mock = Minitest::Mock.new
    mock.expect :list_jobs, list_jobs_gapi(3, "next_page_token"),
      [project], all_users: nil, max_results: nil, page_token: nil, projection: "full", state_filter: "running", min_creation_time: nil, max_creation_time: nil, parent_job_id: nil
    mock.expect :list_jobs, list_jobs_gapi(2),
      [project], all_users: nil, max_results: nil, page_token: "next_page_token", projection: "full", state_filter: "running", min_creation_time: nil, max_creation_time: nil, parent_job_id: nil
    bigquery.service.mocked_service = mock

    jobs = bigquery.jobs(filter: "running").all.to_a

    mock.verify

    _(jobs.count).must_equal 5
    jobs.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Job }
  end

  it "paginates jobs with all and created_at set" do
    mock = Minitest::Mock.new
    mock.expect :list_jobs, list_jobs_gapi(3, "next_page_token"),
      [project], all_users: nil, max_results: nil, page_token: nil, projection: "full", state_filter: nil, min_creation_time: min_millis, max_creation_time: max_millis, parent_job_id: nil
    mock.expect :list_jobs, list_jobs_gapi(2),
      [project], all_users: nil, max_results: nil, page_token: "next_page_token", projection: "full", state_filter: nil, min_creation_time: min_millis, max_creation_time: max_millis, parent_job_id: nil
    bigquery.service.mocked_service = mock

    jobs = bigquery.jobs(min_created_at: min_time, max_created_at: max_time).all.to_a

    mock.verify

    _(jobs.count).must_equal 5
    jobs.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Job }
  end

  it "paginates jobs with all and parent_job_id set" do
    mock = Minitest::Mock.new
    mock.expect :list_jobs, list_jobs_gapi(3, "next_page_token"),
      [project], all_users: nil, max_results: nil, page_token: nil, projection: "full", state_filter: nil, min_creation_time: nil, max_creation_time: nil, parent_job_id: parent_job_id
    mock.expect :list_jobs, list_jobs_gapi(2),
      [project], all_users: nil, max_results: nil, page_token: "next_page_token", projection: "full", state_filter: nil, min_creation_time: nil, max_creation_time: nil, parent_job_id: parent_job_id
    bigquery.service.mocked_service = mock

    jobs = bigquery.jobs(parent_job: parent_job_id).all.to_a

    mock.verify

    _(jobs.count).must_equal 5
    jobs.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Job }
  end

  it "paginates jobs with all and filter and created_at set" do
    mock = Minitest::Mock.new
    mock.expect :list_jobs, list_jobs_gapi(3, "next_page_token"),
      [project], all_users: nil, max_results: nil, page_token: nil, projection: "full", state_filter: "running", min_creation_time: min_millis, max_creation_time: max_millis, parent_job_id: nil
    mock.expect :list_jobs, list_jobs_gapi(2),
      [project], all_users: nil, max_results: nil, page_token: "next_page_token", projection: "full", state_filter: "running", min_creation_time: min_millis, max_creation_time: max_millis, parent_job_id: nil
    bigquery.service.mocked_service = mock

    jobs = bigquery.jobs(filter: "running", min_created_at: min_time, max_created_at: max_time).all.to_a

    mock.verify

    _(jobs.count).must_equal 5
    jobs.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Job }
  end

  it "iterates jobs with all using Enumerator" do
    mock = Minitest::Mock.new
    mock.expect :list_jobs, list_jobs_gapi(3, "next_page_token"),
      [project], all_users: nil, max_results: nil, page_token: nil, projection: "full", state_filter: nil, min_creation_time: nil, max_creation_time: nil, parent_job_id: nil
    mock.expect :list_jobs, list_jobs_gapi(3, "second_page_token"),
      [project], all_users: nil, max_results: nil, page_token: "next_page_token", projection: "full", state_filter: nil, min_creation_time: nil, max_creation_time: nil, parent_job_id: nil
    bigquery.service.mocked_service = mock

    jobs = bigquery.jobs.all.take(5)

    mock.verify

    _(jobs.count).must_equal 5
    jobs.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Job }
  end

  it "iterates jobs with all with request_limit set" do
    mock = Minitest::Mock.new
    mock.expect :list_jobs, list_jobs_gapi(3, "next_page_token"),
      [project], all_users: nil, max_results: nil, page_token: nil, projection: "full", state_filter: nil, min_creation_time: nil, max_creation_time: nil, parent_job_id: nil
    mock.expect :list_jobs, list_jobs_gapi(3, "second_page_token"),
      [project], all_users: nil, max_results: nil, page_token: "next_page_token", projection: "full", state_filter: nil, min_creation_time: nil, max_creation_time: nil, parent_job_id: nil
    bigquery.service.mocked_service = mock

    jobs = bigquery.jobs.all(request_limit: 1).to_a

    mock.verify

    _(jobs.count).must_equal 6
    jobs.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Job }
  end

  def list_jobs_gapi count = 2, token = nil
    hash = {
      "kind" => "bigquery#jobList",
      "etag" => "etag",
      "jobs" => count.times.map { random_job_hash }
    }
    hash["nextPageToken"] = token unless token.nil?

    Google::Apis::BigqueryV2::JobList.from_json hash.to_json
  end
end
