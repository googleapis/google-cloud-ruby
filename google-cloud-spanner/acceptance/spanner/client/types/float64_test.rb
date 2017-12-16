# Copyright 2017 Google LLC
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

require "spanner_helper"

describe "Spanner Client", :types, :float64, :spanner do
  let(:db) { spanner_client }
  let(:table_name) { "stuffs" }

  it "writes and reads float64" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, float: 99.99 }
    results = db.read table_name, [:id, :float], keys: id

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, float: :FLOAT64 })
    results.rows.first.to_h.must_equal({ id: id, float: 99.99 })
  end

  it "writes and queries float64" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, float: 99.99 }
    results = db.execute "SELECT id, float FROM #{table_name} WHERE id = @id", params: { id: id }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, float: :FLOAT64 })
    results.rows.first.to_h.must_equal({ id: id, float: 99.99 })
  end

  it "writes and reads Infinity float64" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, float: Float::INFINITY }
    results = db.read table_name, [:id, :float], keys: id

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, float: :FLOAT64 })
    results.rows.first.to_h.must_equal({ id: id, float: Float::INFINITY })
  end

  it "writes and queries Infinity float64" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, float: Float::INFINITY }
    results = db.execute "SELECT id, float FROM #{table_name} WHERE id = @id", params: { id: id }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, float: :FLOAT64 })
    results.rows.first.to_h.must_equal({ id: id, float: Float::INFINITY })
  end

  it "writes and reads -Infinity float64" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, float: -Float::INFINITY }
    results = db.read table_name, [:id, :float], keys: id

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, float: :FLOAT64 })
    results.rows.first.to_h.must_equal({ id: id, float: -Float::INFINITY })
  end

  it "writes and queries -Infinity float64" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, float: -Float::INFINITY }
    results = db.execute "SELECT id, float FROM #{table_name} WHERE id = @id", params: { id: id }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, float: :FLOAT64 })
    results.rows.first.to_h.must_equal({ id: id, float: -Float::INFINITY })
  end

  it "writes and reads NaN float64" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, float: Float::NAN }
    results = db.read table_name, [:id, :float], keys: id

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, float: :FLOAT64 })
    returned_hash = results.rows.first.to_h
    returned_value = returned_hash[:float]
    returned_value.must_be_kind_of Float
    returned_value.must_be :nan?
  end

  it "writes and queries NaN float64" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, float: Float::NAN }
    results = db.execute "SELECT id, float FROM #{table_name} WHERE id = @id", params: { id: id }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, float: :FLOAT64 })
    returned_hash = results.rows.first.to_h
    returned_value = returned_hash[:float]
    returned_value.must_be_kind_of Float
    returned_value.must_be :nan?
  end

  it "writes and reads NULL float64" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, float: nil }
    results = db.read table_name, [:id, :float], keys: id

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, float: :FLOAT64 })
    results.rows.first.to_h.must_equal({ id: id, float: nil })
  end

  it "writes and queries NULL float64" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, float: nil }
    results = db.execute "SELECT id, float FROM #{table_name} WHERE id = @id", params: { id: id }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, float: :FLOAT64 })
    results.rows.first.to_h.must_equal({ id: id, float: nil })
  end

  it "writes and reads array of float64" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, floats: [77.77, 88.88, 99.99] }
    results = db.read table_name, [:id, :floats], keys: id

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, floats: [:FLOAT64] })
    results.rows.first.to_h.must_equal({ id: id, floats: [77.77, 88.88, 99.99] })
  end

  it "writes and queries array of float64" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, floats: [77.77, 88.88, 99.99] }
    results = db.execute "SELECT id, floats FROM #{table_name} WHERE id = @id", params: { id: id }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, floats: [:FLOAT64] })
    results.rows.first.to_h.must_equal({ id: id, floats: [77.77, 88.88, 99.99] })
  end

  it "writes and reads array of float64 with NULL" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, floats: [nil, 77.77, 88.88, 99.99] }
    results = db.read table_name, [:id, :floats], keys: id

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, floats: [:FLOAT64] })
    results.rows.first.to_h.must_equal({ id: id, floats: [nil, 77.77, 88.88, 99.99] })
  end

  it "writes and queries array of float64 with NULL" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, floats: [nil, 77.77, 88.88, 99.99] }
    results = db.execute "SELECT id, floats FROM #{table_name} WHERE id = @id", params: { id: id }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, floats: [:FLOAT64] })
    results.rows.first.to_h.must_equal({ id: id, floats: [nil, 77.77, 88.88, 99.99] })
  end

  it "writes and reads empty array of float64" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, floats: [] }
    results = db.read table_name, [:id, :floats], keys: id

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, floats: [:FLOAT64] })
    results.rows.first.to_h.must_equal({ id: id, floats: [] })
  end

  it "writes and queries empty array of float64" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, floats: [] }
    results = db.execute "SELECT id, floats FROM #{table_name} WHERE id = @id", params: { id: id }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, floats: [:FLOAT64] })
    results.rows.first.to_h.must_equal({ id: id, floats: [] })
  end

  it "writes and reads NULL array of float64" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, floats: nil }
    results = db.read table_name, [:id, :floats], keys: id

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, floats: [:FLOAT64] })
    results.rows.first.to_h.must_equal({ id: id, floats: nil })
  end

  it "writes and queries NULL array of float64" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, floats: nil }
    results = db.execute "SELECT id, floats FROM #{table_name} WHERE id = @id", params: { id: id }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, floats: [:FLOAT64] })
    results.rows.first.to_h.must_equal({ id: id, floats: nil })
  end
end
