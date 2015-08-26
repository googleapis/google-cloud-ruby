# Copyright 2015 Google Inc. All rights reserved.
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

require "bigquery_helper"
require "gcloud/storage"

# This test is a ruby version of gcloud-node's bigquery test.

describe Gcloud::Pubsub, :bigquery do
  let(:dataset_id) { "#{prefix}_dataset" }
  let(:dataset) do
    d = bigquery.dataset dataset_id
    if d.nil?
      d = bigquery.create_dataset dataset_id
    end
    d
  end
  let(:table_id) { "kittens" }
  let(:schema) do
    { "fields" => [
        { "name" => "id",    "type" => "INTEGER" },
        { "name" => "breed", "type" => "STRING" },
        { "name" => "name",  "type" => "STRING" },
        { "name" => "dob",   "type" => "TIMESTAMP" }
      ] }
  end
  let(:table) do
    t = dataset.table table_id
    if t.nil?
      t = dataset.create_table table_id, schema: schema
    end
    t
  end
  let(:publicdata_query) { "SELECT url FROM [publicdata:samples.github_nested] LIMIT 100" }

  before do
    table
  end

  it "should get a list of datasets" do
    datasets = bigquery.datasets
    # The code in before ensures we have at least one dataset
    datasets.count.wont_be :zero?
    datasets.each { |ds| ds.must_be_kind_of Gcloud::Bigquery::Dataset }
  end

  it "should run an query" do
    rows = bigquery.query publicdata_query
    rows.class.must_equal Gcloud::Bigquery::QueryData
    rows.count.must_equal 100
  end

  it "should run an query job" do
    job = bigquery.query_job publicdata_query
    job.must_be_kind_of Gcloud::Bigquery::Job

    rows = job.query_results
    rows.count.must_equal 100
  end

  it "should get a list of jobs" do
    jobs = bigquery.jobs
    jobs.each { |job| job.must_be_kind_of Gcloud::Bigquery::Job }
  end

  describe "BigQuery/Dataset" do
    it "should set & get metadata" do
      new_desc = "New description!"
      dataset.description = new_desc

      fresh = bigquery.dataset dataset.dataset_id
      fresh.wont_be :nil?
      fresh.must_be_kind_of Gcloud::Bigquery::Dataset
      fresh.dataset_id.must_equal dataset.dataset_id
      fresh.description.must_equal new_desc
    end
  end

  describe "BigQuery/Table" do
    let(:local_file) { "acceptance/data/kitten-test-data.json" }

    it "has the correct schema" do
      table.schema.must_equal({
        "fields" => [
          { "name" => "id",    "type" => "INTEGER" },
          { "name" => "breed", "type" => "STRING" },
          { "name" => "name",  "type" => "STRING" },
          { "name" => "dob",   "type" => "TIMESTAMP" }
        ]
      })
    end

    it "gets and sets metadata" do
      new_desc = "New description!"
      table.description = new_desc

      fresh = dataset.table table.table_id
      fresh.wont_be :nil?
      fresh.must_be_kind_of Gcloud::Bigquery::Table
      fresh.table_id.must_equal table.table_id
      fresh.description.must_equal new_desc
    end

    it "inserts rows directly" do
      rows = [
        { name: "silvano", breed: "the cat kind",      id: 4, dob: Time.now.utc },
        { name: "ryan",    breed: "golden retriever?", id: 5, dob: Time.now.utc },
        { name: "stephen", breed: "idkanycatbreeds",   id: 6, dob: Time.now.utc }
      ]
      result = table.insert rows
      result.must_be :success?
    end

    it "imports data from a local files" do
      job = table.load local_file
      job.wait_until_done!
      job.output_rows.must_equal "3"
    end

    it "imports data from a file in your bucket" do
      begin
        bucket = Gcloud.storage.create_bucket "#{prefix}_bucket"
        file = bucket.create_file local_file

        job = table.load file
        job.wait_until_done!
        job.wont_be :failed?
      ensure
        post_bucket = Gcloud.storage.bucket "#{prefix}_bucket"
        if post_bucket
          post_bucket.files.map &:delete
          post_bucket.delete
        end
      end
    end

    it "extracts data to a url in your bucket" do
      begin
        # Make sure there is data to extract...
        load_job = table.load(local_file)
        load_job.wait_until_done!
        Tempfile.open "empty_extract_file.json" do |tmp|
          bucket = Gcloud.storage.create_bucket "#{prefix}_bucket"
          extract_url = "gs://#{bucket.name}/kitten-test-data-backup.json"
          extract_job = table.extract extract_url
          extract_job.wait_until_done!
          extract_job.wont_be :failed?
          extract_file = bucket.file "kitten-test-data-backup.json"
          downloaded_file = extract_file.download tmp.path
          downloaded_file.size.must_be :>, 0
        end
      ensure
        post_bucket = Gcloud.storage.bucket "#{prefix}_bucket"
        if post_bucket
          post_bucket.files.map &:delete
          post_bucket.delete
        end
      end
    end

    it "extracts data to a file in your bucket" do
      begin
        # Make sure there is data to extract...
        load_job = table.load(local_file)
        load_job.wait_until_done!
        Tempfile.open "empty_extract_file.json" do |tmp|
          tmp.size.must_equal 0
          bucket = Gcloud.storage.create_bucket "#{prefix}_bucket"
          extract_file = bucket.create_file tmp, "kitten-test-data-backup.json"
          extract_job = table.extract extract_file
          extract_job.wait_until_done!
          extract_job.wont_be :failed?
          # Refresh to get the latest file data
          extract_file = bucket.file "kitten-test-data-backup.json"
          downloaded_file = extract_file.download tmp.path
          downloaded_file.size.must_be :>, 0
        end
      ensure
        post_bucket = Gcloud.storage.bucket "#{prefix}_bucket"
        if post_bucket
          post_bucket.files.map &:delete
          post_bucket.delete
        end
      end
    end
  end
end
