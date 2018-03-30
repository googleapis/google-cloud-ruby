# Copyright 2018 Google LLC
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

describe Google::Cloud::Bigquery, :location, :bigquery do
  let(:region) { "EU" }
  let(:dataset_id) { "#{prefix}_dataset_location" }
  let(:dataset) do
    d = bigquery.dataset dataset_id
    if d.nil?
      d = bigquery.create_dataset dataset_id, location: region
    end
    d
  end
  let(:table_id) { "kittens_location" }
  let(:table) do
    t = dataset.table table_id
    if t.nil?
      t = dataset.create_table table_id do |schema|
        schema.integer   "id",    description: "id description",    mode: :required
        schema.string    "breed", description: "breed description", mode: :required
        schema.string    "name",  description: "name description",  mode: :required
        schema.timestamp "dob",   description: "dob description",   mode: :required
      end
    end
    t
  end
  let(:query) { "SELECT id, breed, name, dob FROM #{table.query_id}" }
  let(:rows) do
    [
      { name: "silvano", breed: "the cat kind",      id: 4, dob: Time.now.utc },
      { name: "ryan",    breed: "golden retriever?", id: 5, dob: Time.now.utc },
      { name: "stephen", breed: "idkanycatbreeds",   id: 6, dob: Time.now.utc }
    ]
  end
  let(:invalid_rows) do
    [
        { name: "silvano", breed: "the cat kind",      id: 4, dob: Time.now.utc },
        { name: nil,       breed: "golden retriever?", id: 5, dob: Time.now.utc },
        { name: "stephen", breed: "idkanycatbreeds",   id: 6, dob: Time.now.utc }
    ]
  end
  let(:local_file) { "acceptance/data/kitten-test-data.json" }
  let(:target_table_id) { "kittens_location_copy" }
  let(:target_table_2_id) { "kittens_location_copy_2" }
  let(:target_table_3_id) { "kittens_location_copy_3" }
  let(:target_table_4_id) { "kittens_location_copy_4" }

  it "inserts rows directly and gets its data" do
    # data = table.data
    insert_response = table.insert rows
    insert_response.must_be :success?
    insert_response.insert_count.must_equal 3
    insert_response.insert_errors.must_be :empty?
    insert_response.error_rows.must_be :empty?

    job_id = "test_job_#{SecureRandom.urlsafe_base64(21)}" # client-generated
    query_job = dataset.query_job query, job_id: job_id do |j|
      j.location = region
    end
    query_job.must_be_kind_of Google::Cloud::Bigquery::QueryJob
    query_job.job_id.must_equal job_id
    query_job.wait_until_done!

    # Job methods
    query_job.done?.must_equal true
    query_job.running?.must_equal false
    query_job.pending?.must_equal false
    query_job.created_at.must_be_kind_of Time
    query_job.started_at.must_be_kind_of Time
    query_job.ended_at.must_be_kind_of Time
    query_job.configuration.wont_be :nil?
    query_job.statistics.wont_be :nil?
    query_job.status.wont_be :nil?
    query_job.errors.must_be :empty?
    query_job.rerun!
    query_job.wait_until_done!

    query_job.batch?.must_equal false
    query_job.interactive?.must_equal true
    query_job.large_results?.must_equal false
    query_job.cache?.must_equal true
    query_job.flatten?.must_equal true
    query_job.cache_hit?.must_equal false
    query_job.bytes_processed.wont_be :nil?
    query_job.destination.wont_be :nil?
    query_job.data.class.must_equal Google::Cloud::Bigquery::Data
    query_job.data.total.wont_be :nil?

    data = table.data max: 1
    data.class.must_equal Google::Cloud::Bigquery::Data
    data.kind.wont_be :nil?
    data.etag.wont_be :nil?
    [nil, 0].must_include data.total
    data.count.wont_be :nil?
    data.all(request_limit: 2).each do |row|
      row.must_be_kind_of Hash
      [:id, :breed, :name, :dob].each { |k| row.keys.must_include k }
    end
    more_data = data.next
    more_data.wont_be :nil?

    data = dataset.query query
    data.class.must_equal Google::Cloud::Bigquery::Data
    data.total.wont_be(:nil?)
    data.schema.must_be_kind_of Google::Cloud::Bigquery::Schema
    data.fields.count.must_equal 4
    [:id, :breed, :name, :dob].each { |k| data.headers.must_include k }
    data.all.each do |row|
      row.must_be_kind_of Hash
    end
    data.next.must_be :nil?
  end

  it "imports data from a file in your bucket with load_job" do
    skip "TODO: add location"
    begin
      bucket = Google::Cloud.storage.create_bucket "#{prefix}_bucket"
      file = bucket.create_file local_file

      job = table.load_job file
      job.wait_until_done!
      job.wont_be :failed?
    ensure
      post_bucket = Google::Cloud.storage.bucket "#{prefix}_bucket"
      if post_bucket
        post_bucket.files.map &:delete
        post_bucket.delete
      end
    end
  end

  it "copies itself to another table with copy_job block updater" do
    skip "TODO: add location"
    job_id = "test_job_#{SecureRandom.urlsafe_base64(21)}" # client-generated
    copy_job = table.copy_job target_table_2_id, job_id: job_id do |j|
      j.create = :needed
      j.write = :empty
      j.labels = labels
    end

    copy_job.must_be_kind_of Google::Cloud::Bigquery::CopyJob
    copy_job.job_id.must_equal job_id
    copy_job.labels.must_equal labels
    copy_job.wait_until_done!

    copy_job.wont_be :failed?
    copy_job.source.table_id.must_equal table.table_id
    copy_job.destination.table_id.must_equal target_table_2_id
    copy_job.create_if_needed?.must_equal true
    copy_job.create_never?.must_equal false
    copy_job.write_truncate?.must_equal false
    copy_job.write_append?.must_equal false
    copy_job.write_empty?.must_equal true
  end

  it "creates and cancels jobs" do
    skip "TODO: add location"
    load_job = table.load_job local_file

    load_job.must_be_kind_of Google::Cloud::Bigquery::LoadJob
    load_job.wont_be :done?

    load_job.cancel
    load_job.wait_until_done!

    load_job.must_be :done?

    load_job.wont_be :failed?
  end

  it "extracts data to a file in your bucket with extract_job" do
    skip "TODO: add location"
    begin
      # Make sure there is data to extract...
      load_job = table.load_job local_file
      load_job.wait_until_done!
      Tempfile.open "empty_extract_file.json" do |tmp|
        tmp.size.must_equal 0
        bucket = Google::Cloud.storage.create_bucket "#{prefix}_bucket"
        extract_file = bucket.create_file tmp, "kitten-test-data-backup.json"
        job_id = "test_job_#{SecureRandom.urlsafe_base64(21)}" # client-generated

        extract_job = table.extract_job extract_file, job_id: job_id
        extract_job.job_id.must_equal job_id
        extract_job.wait_until_done!
        extract_job.wont_be :failed?
        # Refresh to get the latest file data
        extract_file = bucket.file "kitten-test-data-backup.json"
        downloaded_file = extract_file.download tmp.path
        downloaded_file.size.must_be :>, 0
      end
    ensure
      post_bucket = Google::Cloud.storage.bucket "#{prefix}_bucket"
      if post_bucket
        post_bucket.files.map &:delete
        post_bucket.delete
      end
    end
  end
end
