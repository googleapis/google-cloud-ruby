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

describe "Spanner Client", :types, :string, :spanner do
  let(:db) { spanner_client }
  let(:table_name) { "stuffs" }
  let(:table_types) { stuffs_table_types }

  it "writes and reads string" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, string: "hello" }
    results = db.read table_name, [:id, :string], keys: id

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, string: :STRING })
    results.rows.first.to_h.must_equal({ id: id, string: "hello" })
  end

  it "writes and queries string" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, string: "hello" }
    results = db.execute "SELECT id, string FROM #{table_name} WHERE id = @id", params: { id: id }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, string: :STRING })
    results.rows.first.to_h.must_equal({ id: id, string: "hello" })
  end

  it "writes and reads NULL string" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, string: nil }
    results = db.read table_name, [:id, :string], keys: id

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, string: :STRING })
    results.rows.first.to_h.must_equal({ id: id, string: nil })
  end

  it "writes and queries NULL string" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, string: nil }
    results = db.execute "SELECT id, string FROM #{table_name} WHERE id = @id", params: { id: id }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, string: :STRING })
    results.rows.first.to_h.must_equal({ id: id, string: nil })
  end

  it "writes and reads array of string" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, strings: ["howdy", "hola", "hello"] }
    results = db.read table_name, [:id, :strings], keys: id

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, strings: [:STRING] })
    results.rows.first.to_h.must_equal({ id: id, strings: ["howdy", "hola", "hello"] })
  end

  it "writes and queries array of string" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, strings: ["howdy", "hola", "hello"] }
    results = db.execute "SELECT id, strings FROM #{table_name} WHERE id = @id", params: { id: id }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, strings: [:STRING] })
    results.rows.first.to_h.must_equal({ id: id, strings: ["howdy", "hola", "hello"] })
  end

  it "writes and reads array of string with NULL" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, strings: [nil, "howdy", "hola", "hello"] }
    results = db.read table_name, [:id, :strings], keys: id

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, strings: [:STRING] })
    results.rows.first.to_h.must_equal({ id: id, strings: [nil, "howdy", "hola", "hello"] })
  end

  it "writes and queries array of string with NULL" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, strings: [nil, "howdy", "hola", "hello"] }
    results = db.execute "SELECT id, strings FROM #{table_name} WHERE id = @id", params: { id: id }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, strings: [:STRING] })
    results.rows.first.to_h.must_equal({ id: id, strings: [nil, "howdy", "hola", "hello"] })
  end

  it "writes and reads empty array of string" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, strings: [] }
    results = db.read table_name, [:id, :strings], keys: id

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, strings: [:STRING] })
    results.rows.first.to_h.must_equal({ id: id, strings: [] })
  end

  it "writes and queries empty array of string" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, strings: [] }
    results = db.execute "SELECT id, strings FROM #{table_name} WHERE id = @id", params: { id: id }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, strings: [:STRING] })
    results.rows.first.to_h.must_equal({ id: id, strings: [] })
  end

  it "writes and reads NULL array of string" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, strings: nil }
    results = db.read table_name, [:id, :strings], keys: id

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, strings: [:STRING] })
    results.rows.first.to_h.must_equal({ id: id, strings: nil })
  end

  it "writes and queries NULL array of string" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, strings: nil }
    results = db.execute "SELECT id, strings FROM #{table_name} WHERE id = @id", params: { id: id }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, strings: [:STRING] })
    results.rows.first.to_h.must_equal({ id: id, strings: nil })
  end
end
