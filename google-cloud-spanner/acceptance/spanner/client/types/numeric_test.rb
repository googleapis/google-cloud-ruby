# Copyright 2020 Google LLC
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
require "bigdecimal"

describe "Spanner Client", :types, :numeric, :spanner do
  let(:db) { spanner_client }
  let(:table_name) { "stuffs" }

  it "writes and reads numeric" do
    skip if emulator_enabled?

    num = BigDecimal("0.123456789")
    id = SecureRandom.int64
    db.upsert table_name, { id: id, numeric: num }
    results = db.read table_name, [:id, :numeric], keys: id

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields.to_h).must_equal({ id: :INT64, numeric: :NUMERIC })
    _(results.rows.first.to_h).must_equal({ id: id, numeric: num })
  end

  it "writes and queries numeric" do
    skip if emulator_enabled?

    num = BigDecimal("0.123456789")
    id = SecureRandom.int64
    db.upsert table_name, { id: id, numeric: num }
    results = db.execute_sql "SELECT id, numeric FROM #{table_name} WHERE id = @id", params: { id: id }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields.to_h).must_equal({ id: :INT64, numeric: :NUMERIC })
    _(results.rows.first.to_h).must_equal({ id: id, numeric: num })
  end

  it "writes and reads NULL numeric" do
    skip if emulator_enabled?

    num = BigDecimal("0.123456789")
    id = SecureRandom.int64
    db.upsert table_name, { id: id, numeric: nil }
    results = db.read table_name, [:id, :numeric], keys: id

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields.to_h).must_equal({ id: :INT64, numeric: :NUMERIC })
    _(results.rows.first.to_h).must_equal({ id: id, numeric: nil })
  end

  it "writes and queries NULL numeric" do
    skip if emulator_enabled?

    num = BigDecimal("0.123456789")
    id = SecureRandom.int64
    db.upsert table_name, { id: id, numeric: nil }
    results = db.execute_sql "SELECT id, numeric FROM #{table_name} WHERE id = @id", params: { id: id }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields.to_h).must_equal({ id: :INT64, numeric: :NUMERIC })
    _(results.rows.first.to_h).must_equal({ id: id, numeric: nil })
  end

  it "writes and reads array of numeric" do
    skip if emulator_enabled?

    nums = [BigDecimal("0.123456789"), BigDecimal("1.23456789"), BigDecimal("12.3456789")]
    id = SecureRandom.int64
    db.upsert table_name, { id: id, numerics: nums }
    results = db.read table_name, [:id, :numerics], keys: id

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields.to_h).must_equal({ id: :INT64, numerics: [:NUMERIC] })
    _(results.rows.first.to_h).must_equal({ id: id, numerics: nums })
  end

  it "writes and queries array of numeric" do
    skip if emulator_enabled?

    nums = [BigDecimal("0.123456789"), BigDecimal("1.23456789"), BigDecimal("12.3456789")]
    id = SecureRandom.int64
    db.upsert table_name, { id: id, numerics: nums }
    results = db.execute_sql "SELECT id, numerics FROM #{table_name} WHERE id = @id", params: { id: id }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields.to_h).must_equal({ id: :INT64, numerics: [:NUMERIC] })
    _(results.rows.first.to_h).must_equal({ id: id, numerics: nums })
  end

  it "writes and reads array of numeric with NULL" do
    skip if emulator_enabled?

    nums = [nil, BigDecimal("0.123456789"), BigDecimal("1.23456789"), BigDecimal("12.3456789")]
    id = SecureRandom.int64
    db.upsert table_name, { id: id, numerics: nums }
    results = db.read table_name, [:id, :numerics], keys: id

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields.to_h).must_equal({ id: :INT64, numerics: [:NUMERIC] })
    _(results.rows.first.to_h).must_equal({ id: id, numerics: nums })
  end

  it "writes and queries array of numeric with NULL" do
    skip if emulator_enabled?

    nums = [nil, BigDecimal("0.123456789"), BigDecimal("1.23456789"), BigDecimal("12.3456789")]
    id = SecureRandom.int64
    db.upsert table_name, { id: id, numerics: nums }
    results = db.execute_sql "SELECT id, numerics FROM #{table_name} WHERE id = @id", params: { id: id }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields.to_h).must_equal({ id: :INT64, numerics: [:NUMERIC] })
    _(results.rows.first.to_h).must_equal({ id: id, numerics: nums })
  end

  it "writes and reads empty array of numeric" do
    skip if emulator_enabled?

    id = SecureRandom.int64
    db.upsert table_name, { id: id, numerics: [] }
    results = db.read table_name, [:id, :numerics], keys: id

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields.to_h).must_equal({ id: :INT64, numerics: [:NUMERIC] })
    _(results.rows.first.to_h).must_equal({ id: id, numerics: [] })
  end

  it "writes and queries empty array of numeric" do
    skip if emulator_enabled?

    id = SecureRandom.int64
    db.upsert table_name, { id: id, numerics: [] }
    results = db.execute_sql "SELECT id, numerics FROM #{table_name} WHERE id = @id", params: { id: id }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields.to_h).must_equal({ id: :INT64, numerics: [:NUMERIC] })
    _(results.rows.first.to_h).must_equal({ id: id, numerics: [] })
  end

  it "writes and reads NULL array of numeric" do
    skip if emulator_enabled?

    id = SecureRandom.int64
    db.upsert table_name, { id: id, numerics: nil }
    results = db.read table_name, [:id, :numerics], keys: id

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields.to_h).must_equal({ id: :INT64, numerics: [:NUMERIC] })
    _(results.rows.first.to_h).must_equal({ id: id, numerics: nil })
  end

  it "writes and queries NULL array of numeric" do
    skip if emulator_enabled?
    
    id = SecureRandom.int64
    db.upsert table_name, { id: id, numerics: nil }
    results = db.execute_sql "SELECT id, numerics FROM #{table_name} WHERE id = @id", params: { id: id }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields.to_h).must_equal({ id: :INT64, numerics: [:NUMERIC] })
    _(results.rows.first.to_h).must_equal({ id: id, numerics: nil })
  end
end
