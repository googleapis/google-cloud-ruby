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

require "bigquery_helper"

describe Google::Cloud::BigQuery, :bigquery do
  let(:publicdata_query) { "SELECT url FROM publicdata.samples.github_nested LIMIT 100" }
  let(:dataset_id) { "#{prefix}_dataset" }
  let(:dataset) do
    d = bigquery.dataset dataset_id
    if d.nil?
      d = bigquery.create_dataset dataset_id
    end
    d
  end
  let(:labels) { { "prefix" => prefix } }
  let(:udfs) { [ "return x+1;", "gs://my-bucket/my-lib.js" ] }
  let(:filter) { "labels.prefix:#{prefix}" }
  let(:dataset_2_id) { "#{prefix}_dataset_2" }
  let(:dataset_2) do
    d = bigquery.dataset dataset_2_id
    if d.nil?
      d = bigquery.create_dataset dataset_2_id do |ds|
        ds.labels = labels
      end
    end
    d
  end
  let(:table_id) { "bigquery_table" }
  let(:table) do
    t = dataset.table table_id
    if t.nil?
      t = dataset.create_table table_id
    end
    t
  end
  let(:view_id) { "bigquery_view" }
  let(:view) do
    t = dataset.table view_id
    if t.nil?
      t = dataset.create_view view_id, publicdata_query
    end
    t
  end
  let(:dataset_with_access_id) { "#{prefix}_dataset_with_access" }

  before do
    dataset_2
    table
    view
  end

  it "should get a list of datasets" do
    datasets = bigquery.datasets max: 1
    # The code in before ensures we have at least one dataset
    datasets.count.wont_be :zero?
    datasets.all(request_limit: 1).each do |ds|
      ds.must_be_kind_of Google::Cloud::BigQuery::Dataset
      ds.created_at.must_be_kind_of Time # Loads full representation
    end
    more_datasets = datasets.next
    more_datasets.wont_be :nil?
  end

  it "should get a list of datasets by labels filter" do
    datasets = bigquery.datasets filter: filter
    datasets.count.must_equal 1
    ds = datasets.first
    ds.must_be_kind_of Google::Cloud::BigQuery::Dataset
    ds.labels.must_equal labels
  end

  it "create a dataset with access rules" do
    bigquery.create_dataset dataset_with_access_id do |ds|
      ds.access do |acl|
        acl.add_writer_special :all
      end
    end
    fresh = bigquery.dataset dataset_with_access_id
    fresh.wont_be :nil?
    fresh.access.wont_be :empty?
    fresh.access.to_a.must_be_kind_of Array
    assert fresh.access.writer_special? :all
  end

  it "should run an query" do
    rows = bigquery.query publicdata_query
    rows.class.must_equal Google::Cloud::BigQuery::Data
    rows.count.must_equal 100
  end

  it "should run an query without legacy SQL syntax" do
    rows = bigquery.query "SELECT url FROM `publicdata.samples.github_nested` LIMIT 100", legacy_sql: false
    rows.class.must_equal Google::Cloud::BigQuery::Data
    rows.count.must_equal 100
  end

  it "should run an query with standard SQL syntax" do
    rows = bigquery.query "SELECT url FROM `publicdata.samples.github_nested` LIMIT 100", standard_sql: true
    rows.class.must_equal Google::Cloud::BigQuery::Data
    rows.count.must_equal 100
  end

  it "should run a query job with job id" do
    job_id = "test_job_#{SecureRandom.urlsafe_base64(21)}" # client-generated
    job = bigquery.query_job publicdata_query, job_id: job_id
    job.must_be_kind_of Google::Cloud::BigQuery::Job
    job.job_id.must_equal job_id
    job.user_email.wont_be_nil
    job.wait_until_done!
    rows = job.data
    rows.total.must_equal 100
  end

  it "should run a query job with job labels" do
    job = bigquery.query_job publicdata_query, labels: labels
    job.must_be_kind_of Google::Cloud::BigQuery::Job
    job.labels.must_equal labels
  end

  it "should run a query job with user defined function resources" do
    job = bigquery.query_job publicdata_query, udfs: udfs
    job.must_be_kind_of Google::Cloud::BigQuery::Job
    job.udfs.must_equal udfs
  end

  it "should get a list of jobs" do
    jobs = bigquery.jobs.all request_limit: 3
    jobs.each { |job| job.must_be_kind_of Google::Cloud::BigQuery::Job }
  end

  it "should get a list of projects" do
    projects = bigquery.projects.all
    projects.count.must_be :>, 0
    projects.each do |project|
      project.must_be_kind_of Google::Cloud::BigQuery::Project
      project.name.must_be_kind_of String
      project.service.must_be_kind_of Google::Cloud::BigQuery::Service
      project.service.project.must_be_kind_of String
      project.datasets.each do |ds|
        ds.must_be_kind_of Google::Cloud::BigQuery::Dataset
      end
    end
  end
end
