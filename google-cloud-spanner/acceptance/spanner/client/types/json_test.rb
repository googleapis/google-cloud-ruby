# Copyright 2021 Google LLC
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

describe "Spanner Client", :types, :json, :spanner do
  let(:db) { spanner_client }
  let(:table_name) { "stuffs" }
  let(:table_types) { stuffs_table_types }
  let(:json_params) { { "venue" => "abc", "rating" => 10 } }
  let(:json_array_params) do
    3.times.map do |i|
      { "venue" => "abc-#{i}", "rating" => 10 + i }
    end
  end

  it "writes and reads json" do
    skip if emulator_enabled?

    id = SecureRandom.int64
    db.upsert table_name, { id: id, json: json_params }
    results = db.read table_name, [:id, :json], keys: id

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields.to_h).must_equal({ id: :INT64, json: :JSON })
    _(results.rows.first.to_h).must_equal({ id: id, json: json_params })
  end

  it "writes and queries json" do
    skip if emulator_enabled?

    id = SecureRandom.int64
    db.upsert table_name, { id: id, json: json_params }
    results = db.execute_query "SELECT id, json FROM #{table_name} WHERE id = @id", params: { id: id }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields.to_h).must_equal({ id: :INT64, json: :JSON })
    _(results.rows.first.to_h).must_equal({ id: id, json: json_params })
  end

  it "writes and reads NULL json" do
    skip if emulator_enabled?

    id = SecureRandom.int64
    db.upsert table_name, { id: id, json: nil }
    results = db.read table_name, [:id, :json], keys: id

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields.to_h).must_equal({ id: :INT64, json: :JSON })
    _(results.rows.first.to_h).must_equal({ id: id, json: nil })
  end

  it "writes and queries NULL json" do
    skip if emulator_enabled?

    id = SecureRandom.int64
    db.upsert table_name, { id: id, json: nil }
    results = db.execute_query "SELECT id, json FROM #{table_name} WHERE id = @id", params: { id: id }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields.to_h).must_equal({ id: :INT64, json: :JSON })
    _(results.rows.first.to_h).must_equal({ id: id, json: nil })
  end

  it "writes and reads array of json" do
    skip if emulator_enabled?

    id = SecureRandom.int64
    db.upsert table_name, { id: id, json_array: json_array_params }
    results = db.read table_name, [:id, :json_array], keys: id

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields.to_h).must_equal({ id: :INT64, json_array: [:JSON] })
    _(results.rows.first.to_h).must_equal({ id: id, json_array: json_array_params })
  end

  it "writes and queries array of json" do
    skip if emulator_enabled?

    id = SecureRandom.int64
    db.upsert table_name, { id: id, json_array: json_array_params }
    results = db.execute_query "SELECT id, json_array FROM #{table_name} WHERE id = @id", params: { id: id }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields.to_h).must_equal({ id: :INT64, json_array: [:JSON] })
    _(results.rows.first.to_h).must_equal({ id: id, json_array: json_array_params })
  end

  it "writes and reads array of json with NULL" do
    skip if emulator_enabled?

    id = SecureRandom.int64
    params = [nil].concat(json_array_params)
    db.upsert table_name, { id: id, json_array: params }
    results = db.read table_name, [:id, :json_array], keys: id

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields.to_h).must_equal({ id: :INT64, json_array: [:JSON] })
    _(results.rows.first.to_h).must_equal({ id: id, json_array: params })
  end

  it "writes and queries array of json with NULL" do
    skip if emulator_enabled?

    id = SecureRandom.int64
    params = [nil].concat(json_array_params)
    db.upsert table_name, { id: id, json_array: params }
    results = db.execute_query "SELECT id, json_array FROM #{table_name} WHERE id = @id", params: { id: id }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields.to_h).must_equal({ id: :INT64, json_array: [:JSON] })
    _(results.rows.first.to_h).must_equal({ id: id, json_array: params })
  end

  it "writes and reads empty array of json" do
    skip if emulator_enabled?

    id = SecureRandom.int64
    db.upsert table_name, { id: id, json_array: [] }
    results = db.read table_name, [:id, :json_array], keys: id

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields.to_h).must_equal({ id: :INT64, json_array: [:JSON] })
    _(results.rows.first.to_h).must_equal({ id: id, json_array: [] })
  end

  it "writes and queries empty array of json array" do
    skip if emulator_enabled?

    id = SecureRandom.int64
    db.upsert table_name, { id: id, json_array: [] }
    results = db.execute_query "SELECT id, json_array FROM #{table_name} WHERE id = @id", params: { id: id }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields.to_h).must_equal({ id: :INT64, json_array: [:JSON] })
    _(results.rows.first.to_h).must_equal({ id: id, json_array: [] })
  end

  it "writes and reads NULL array of json" do
    skip if emulator_enabled?

    id = SecureRandom.int64
    db.upsert table_name, { id: id, json_array: nil }
    results = db.read table_name, [:id, :json_array], keys: id

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields.to_h).must_equal({ id: :INT64, json_array: [:JSON] })
    _(results.rows.first.to_h).must_equal({ id: id, json_array: nil })
  end

  it "writes and queries NULL array of json" do
    skip if emulator_enabled?

    id = SecureRandom.int64
    db.upsert table_name, { id: id, json_array: nil }
    results = db.execute_query "SELECT id, json_array FROM #{table_name} WHERE id = @id", params: { id: id }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields.to_h).must_equal({ id: :INT64, json_array: [:JSON] })
    _(results.rows.first.to_h).must_equal({ id: id, json_array: nil })
  end
end
