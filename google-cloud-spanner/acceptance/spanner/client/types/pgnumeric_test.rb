# Copyright 2022 Google LLC
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
  let(:db) { spanner_pg_client }
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
    results = db.execute_sql "SELECT id, numeric FROM #{table_name} WHERE id = $1", params: { p1: id },
types: { p1: :PG_NUMERIC }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields.to_h).must_equal({ id: :INT64, numeric: :NUMERIC })
    _(results.rows.first.to_h).must_equal({ id: id, numeric: num })
  end

  it "writes and reads NULL numeric" do
    skip if emulator_enabled?

    id = SecureRandom.int64
    db.upsert table_name, { id: id, numeric: nil }
    results = db.read table_name, [:id, :numeric], keys: id

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields.to_h).must_equal({ id: :INT64, numeric: :NUMERIC })
    _(results.rows.first.to_h).must_equal({ id: id, numeric: nil })
  end

  it "writes and queries NULL numeric" do
    skip if emulator_enabled?

    id = SecureRandom.int64
    db.upsert table_name, { id: id, numeric: nil }
    results = db.execute_sql "SELECT id, numeric FROM #{table_name} WHERE id = $1", params: { p1: id },
types: { p1: :PG_NUMERIC }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields.to_h).must_equal({ id: :INT64, numeric: :NUMERIC })
    _(results.rows.first.to_h).must_equal({ id: id, numeric: nil })
  end

  it "writes and reads nan of numeric" do
    skip if emulator_enabled?

    id = SecureRandom.int64
    db.upsert table_name, { id: id, numeric: BigDecimal("NaN") }
    results = db.read table_name, [:id, :numeric], keys: id

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields.to_h).must_equal({ id: :INT64, numeric: :NUMERIC })
    _(results.rows.first.to_h[:numeric]).must_be :nan?
  end

  it "writes and queries nan of numeric" do
    skip if emulator_enabled?

    id = SecureRandom.int64
    db.upsert table_name, { id: id, numeric: BigDecimal("NaN") }
    results = db.execute_sql "SELECT id, numeric FROM #{table_name} WHERE id = $1", params: { p1: id },
types: { p1: :PG_NUMERIC }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields.to_h).must_equal({ id: :INT64, numeric: :NUMERIC })
    _(results.rows.first.to_h[:numeric]).must_be :nan?
  end
end
