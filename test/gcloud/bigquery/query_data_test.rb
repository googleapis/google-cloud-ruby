# Copyright 2015 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a extract of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Gcloud::Bigquery::QueryData, :mock_bigquery do
  let(:query_data) { Gcloud::Bigquery::QueryData.from_gapi query_data_gapi,
                                                           bigquery.service }

  it "returns data as a list of hashes" do
    query_data.count.must_equal 3
    query_data[0].must_be_kind_of Hash
    query_data[0]["name"].must_equal "Heidi"
    query_data[0]["age"].must_equal 36
    query_data[0]["score"].must_equal 7.65
    query_data[0]["active"].must_equal true
    query_data[1].must_be_kind_of Hash
    query_data[1]["name"].must_equal "Aaron"
    query_data[1]["age"].must_equal 42
    query_data[1]["score"].must_equal 8.15
    query_data[1]["active"].must_equal false
    query_data[2].must_be_kind_of Hash
    query_data[2]["name"].must_equal "Sally"
    query_data[2]["age"].must_equal nil
    query_data[2]["score"].must_equal nil
    query_data[2]["active"].must_equal nil
  end

  it "knows the data metadata" do
    query_data.kind.must_equal "bigquery#getQueryResultsResponse"
    query_data.token.must_equal "token1234567890"
    query_data.total.must_equal 3
    query_data.total_bytes.must_equal 456789
    # Cannot call `query_data.must_be :complete?` on a delegate
    query_data.complete?.must_equal true
    query_data.cache_hit?.must_equal false
  end

  it "knows the raw, unformatted data" do
    query_data.raw.wont_be :nil?
    query_data.raw.count.must_equal query_data.count

    query_data.raw[0][0].must_equal query_data[0]["name"].to_s
    query_data.raw[0][1].must_equal query_data[0]["age"].to_s
    query_data.raw[0][2].must_equal query_data[0]["score"].to_s
    query_data.raw[0][3].must_equal query_data[0]["active"].to_s

    query_data.raw[1][0].must_equal query_data[1]["name"].to_s
    query_data.raw[1][1].must_equal query_data[1]["age"].to_s
    query_data.raw[1][2].must_equal query_data[1]["score"].to_s
    query_data.raw[1][3].must_equal query_data[1]["active"].to_s

    query_data.raw[2][0].must_equal query_data[2]["name"].to_s
    query_data.raw[2][1].must_equal nil
    query_data.raw[2][2].must_equal nil
    query_data.raw[2][3].must_equal nil
  end

  it "knows schema, fields, and headers" do
    query_data.schema.must_be_kind_of Gcloud::Bigquery::Schema
    query_data.fields.must_equal query_data.schema.fields
    query_data.headers.must_equal ["name", "age", "score", "active"]
  end

  it "can get the job associated with the data" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :get_job,
                Google::Apis::BigqueryV2::Job.from_json(random_job_hash("job9876543210", "done").to_json),
                [project, "job9876543210"]

    job = query_data.job
    mock.verify

    job.must_be_kind_of Gcloud::Bigquery::Job
    job.job_id.must_equal "job9876543210"
  end

  it "memoizes the job associated with the data" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :get_job,
                Google::Apis::BigqueryV2::Job.from_json(random_job_hash("job9876543210", "done").to_json),
                [project, "job9876543210"]

    job = query_data.job

    job.must_be_kind_of Gcloud::Bigquery::Job
    job.job_id.must_equal "job9876543210"

    # Additional calls do not make additional HTTP API calls
    job2 = query_data.job
    job2.must_equal job
    job3 = query_data.job
    job3.must_equal job
    mock.verify
  end

  it "can hold a job object and not make HTTP API calls to return it" do
    query_data.instance_variable_set "@job", "I AM A STUBBED JOB"

    job = query_data.job
    job.must_equal "I AM A STUBBED JOB"
  end

  it "handles missing schema" do
    nil_query_data = Gcloud::Bigquery::QueryData.from_gapi nil_query_data_gapi,
                                                           bigquery.service

    nil_query_data.class.must_equal Gcloud::Bigquery::QueryData
    nil_query_data.count.must_equal 0
  end

  it "handles empty rows and fields" do
    empty_query_data = Gcloud::Bigquery::QueryData.from_gapi empty_query_data_gapi,
                                                             bigquery.service

    empty_query_data.class.must_equal Gcloud::Bigquery::QueryData
    empty_query_data.count.must_equal 0
  end

  def nil_query_data_gapi
    gapi = query_data_gapi
    gapi.schema = nil
    gapi
  end

  def empty_query_data_gapi
    gapi = query_data_gapi
    gapi.rows = []
    gapi.schema.fields = []
    gapi
  end
end
