# Copyright 2017 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License 00:00:00Z");
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

require "spanner_helper"

describe "Spanner Client", :types, :timestamp, :spanner do
  let(:db) { spanner_client }
  let(:table_name) { "stuffs" }
  let(:table_types) { stuffs_table_types }

  it "writes and reads timestamp" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, timestamp: Time.parse("2017-01-01 00:00:00Z") }
    results = db.read table_name, [:id, :timestamp], keys: id

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, timestamp: :TIMESTAMP })
    results.rows.first.to_h.must_equal({ id: id, timestamp: Time.parse("2017-01-01 00:00:00Z") })
  end

  it "writes and queries timestamp" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, timestamp: Time.parse("2017-01-01 00:00:00Z") }
    results = db.execute "SELECT id, timestamp FROM #{table_name} WHERE id = @id", params: { id: id }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, timestamp: :TIMESTAMP })
    results.rows.first.to_h.must_equal({ id: id, timestamp: Time.parse("2017-01-01 00:00:00Z") })
  end

  it "writes and reads NULL timestamp" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, timestamp: nil }
    results = db.read table_name, [:id, :timestamp], keys: id

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, timestamp: :TIMESTAMP })
    results.rows.first.to_h.must_equal({ id: id, timestamp: nil })
  end

  it "writes and queries NULL timestamp" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, timestamp: nil }
    results = db.execute "SELECT id, timestamp FROM #{table_name} WHERE id = @id", params: { id: id }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, timestamp: :TIMESTAMP })
    results.rows.first.to_h.must_equal({ id: id, timestamp: nil })
  end

  it "writes and reads array of timestamp" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, timestamps: [Time.parse("2016-12-30 00:00:00Z"), Time.parse("2016-12-31 00:00:00Z"), Time.parse("2017-01-01 00:00:00Z")] }
    results = db.read table_name, [:id, :timestamps], keys: id

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, timestamps: [:TIMESTAMP] })
    results.rows.first.to_h.must_equal({ id: id, timestamps: [Time.parse("2016-12-30 00:00:00Z"), Time.parse("2016-12-31 00:00:00Z"), Time.parse("2017-01-01 00:00:00Z")] })
  end

  it "writes and queries array of timestamp" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, timestamps: [Time.parse("2016-12-30 00:00:00Z"), Time.parse("2016-12-31 00:00:00Z"), Time.parse("2017-01-01 00:00:00Z")] }
    results = db.execute "SELECT id, timestamps FROM #{table_name} WHERE id = @id", params: { id: id }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, timestamps: [:TIMESTAMP] })
    results.rows.first.to_h.must_equal({ id: id, timestamps: [Time.parse("2016-12-30 00:00:00Z"), Time.parse("2016-12-31 00:00:00Z"), Time.parse("2017-01-01 00:00:00Z")] })
  end

  it "writes and reads array of timestamp with NULL" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, timestamps: [nil, Time.parse("2016-12-30 00:00:00Z"), Time.parse("2016-12-31 00:00:00Z"), Time.parse("2017-01-01 00:00:00Z")] }
    results = db.read table_name, [:id, :timestamps], keys: id

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, timestamps: [:TIMESTAMP] })
    results.rows.first.to_h.must_equal({ id: id, timestamps: [nil, Time.parse("2016-12-30 00:00:00Z"), Time.parse("2016-12-31 00:00:00Z"), Time.parse("2017-01-01 00:00:00Z")] })
  end

  it "writes and queries array of timestamp with NULL" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, timestamps: [nil, Time.parse("2016-12-30 00:00:00Z"), Time.parse("2016-12-31 00:00:00Z"), Time.parse("2017-01-01 00:00:00Z")] }
    results = db.execute "SELECT id, timestamps FROM #{table_name} WHERE id = @id", params: { id: id }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, timestamps: [:TIMESTAMP] })
    results.rows.first.to_h.must_equal({ id: id, timestamps: [nil, Time.parse("2016-12-30 00:00:00Z"), Time.parse("2016-12-31 00:00:00Z"), Time.parse("2017-01-01 00:00:00Z")] })
  end

  it "writes and reads empty array of timestamp" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, timestamps: [] }
    results = db.read table_name, [:id, :timestamps], keys: id

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, timestamps: [:TIMESTAMP] })
    results.rows.first.to_h.must_equal({ id: id, timestamps: [] })
  end

  it "writes and queries empty array of timestamp" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, timestamps: [] }
    results = db.execute "SELECT id, timestamps FROM #{table_name} WHERE id = @id", params: { id: id }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, timestamps: [:TIMESTAMP] })
    results.rows.first.to_h.must_equal({ id: id, timestamps: [] })
  end

  it "writes and reads NULL array of timestamp" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, timestamps: nil }
    results = db.read table_name, [:id, :timestamps], keys: id

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, timestamps: [:TIMESTAMP] })
    results.rows.first.to_h.must_equal({ id: id, timestamps: nil })
  end

  it "writes and queries NULL array of timestamp" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, timestamps: nil }
    results = db.execute "SELECT id, timestamps FROM #{table_name} WHERE id = @id", params: { id: id }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, timestamps: [:TIMESTAMP] })
    results.rows.first.to_h.must_equal({ id: id, timestamps: nil })
  end
end
