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

describe Google::Cloud::Bigquery, :bigquery do
  let(:dataset_id) { "#{prefix}_dataset" }
  let(:dataset) do
    d = bigquery.dataset dataset_id
    if d.nil?
      d = bigquery.create_dataset dataset_id
    end
    d
  end
  let(:table_id) { "queries" }
  let(:table) { dataset.table table_id, skip_lookup: true }

  let(:timestamp_table_id) { "timestamp_queries" }
  let(:timestamp_table) { dataset.table timestamp_table_id, skip_lookup: true }

  it "sends query results to destination table" do
    rows = bigquery.query "SELECT 123 AS value", standard_sql: true do |query|
      query.write = :truncate
      query.table = table
    end

    dest_table = dataset.table table_id
    rows = dest_table.data
    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.count.must_equal 1
    rows.first[:value].must_equal 123
  end

  it "sends query results to destination table with encryption" do
    encrypt_config = bigquery.encryption(kms_key: kms_key)
    rows = bigquery.query "SELECT 456 AS value", standard_sql: true do |query|
      query.write = :truncate
      query.table = table
      query.encryption = encrypt_config
    end

    dest_table = dataset.table table_id
    dest_table.encryption.must_equal encrypt_config
    rows = dest_table.data
    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.count.must_equal 1
    rows.first[:value].must_equal 456
  end

  it "sends query results to a time partitioned destination table" do
    job = bigquery.query_job "SELECT * FROM UNNEST(" \
                             "GENERATE_TIMESTAMP_ARRAY(" \
                             "'2099-10-01 00:00:00', '2099-10-10 00:00:00', " \
                             "INTERVAL 1 DAY)) AS dob" do |job|
      job.write = :truncate
      job.table = timestamp_table
      job.time_partitioning_type = "DAY"
      job.time_partitioning_field = "dob"
      job.time_partitioning_expiration = 86_400
      job.time_partitioning_require_filter = true
    end

    job.must_be_kind_of Google::Cloud::Bigquery::QueryJob
    job.wait_until_done!

    job.time_partitioning_type.must_equal "DAY"
    job.time_partitioning_field.must_equal "dob"
    job.time_partitioning_expiration.must_equal 86_400
    job.time_partitioning_require_filter?.must_equal true

    dest_table = dataset.table timestamp_table_id
    rows = dest_table.data
    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.count.must_equal 10
  end
end