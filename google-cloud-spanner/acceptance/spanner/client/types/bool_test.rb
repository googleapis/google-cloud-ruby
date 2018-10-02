# Copyright 2017 Google LLC
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

require "spanner_helper"

describe "Spanner Client", :types, :bool, :spanner do
  let(:db) { spanner_client }
  let(:table_name) { "stuffs" }

  it "writes and reads bool" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, bool: true }
    results = db.read table_name, [:id, :bool], keys: id

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, bool: :BOOL })
    results.rows.first.to_h.must_equal({ id: id, bool: true })
  end

  it "writes and queries bool" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, bool: true }
    results = db.execute_query "SELECT id, bool FROM #{table_name} WHERE id = @id", params: { id: id }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, bool: :BOOL })
    results.rows.first.to_h.must_equal({ id: id, bool: true })
  end

  it "writes and reads NULL bool" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, bool: nil }
    results = db.read table_name, [:id, :bool], keys: id

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, bool: :BOOL })
    results.rows.first.to_h.must_equal({ id: id, bool: nil })
  end

  it "writes and queries NULL bool" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, bool: nil }
    results = db.execute_query "SELECT id, bool FROM #{table_name} WHERE id = @id", params: { id: id }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, bool: :BOOL })
    results.rows.first.to_h.must_equal({ id: id, bool: nil })
  end

  it "writes and reads array of bool" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, bools: [true, false, true] }
    results = db.read table_name, [:id, :bools], keys: id

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, bools: [:BOOL] })
    results.rows.first.to_h.must_equal({ id: id, bools: [true, false, true] })
  end

  it "writes and queries array of bool" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, bools: [true, false, true] }
    results = db.execute_query "SELECT id, bools FROM #{table_name} WHERE id = @id", params: { id: id }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, bools: [:BOOL] })
    results.rows.first.to_h.must_equal({ id: id, bools: [true, false, true] })
  end

  it "writes and reads array of bool with NULL" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, bools: [nil, true, false, true] }
    results = db.read table_name, [:id, :bools], keys: id

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, bools: [:BOOL] })
    results.rows.first.to_h.must_equal({ id: id, bools: [nil, true, false, true] })
  end

  it "writes and queries array of bool with NULL" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, bools: [nil, true, false, true] }
    results = db.execute_query "SELECT id, bools FROM #{table_name} WHERE id = @id", params: { id: id }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, bools: [:BOOL] })
    results.rows.first.to_h.must_equal({ id: id, bools: [nil, true, false, true] })
  end

  it "writes and reads empty array of bool" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, bools: [] }
    results = db.read table_name, [:id, :bools], keys: id

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, bools: [:BOOL] })
    results.rows.first.to_h.must_equal({ id: id, bools: [] })
  end

  it "writes and queries empty array of bool" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, bools: [] }
    results = db.execute_query "SELECT id, bools FROM #{table_name} WHERE id = @id", params: { id: id }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, bools: [:BOOL] })
    results.rows.first.to_h.must_equal({ id: id, bools: [] })
  end

  it "writes and reads NULL array of bool" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, bools: nil }
    results = db.read table_name, [:id, :bools], keys: id

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, bools: [:BOOL] })
    results.rows.first.to_h.must_equal({ id: id, bools: nil })
  end

  it "writes and queries NULL array of bool" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, bools: nil }
    results = db.execute_query "SELECT id, bools FROM #{table_name} WHERE id = @id", params: { id: id }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, bools: [:BOOL] })
    results.rows.first.to_h.must_equal({ id: id, bools: nil })
  end
end
