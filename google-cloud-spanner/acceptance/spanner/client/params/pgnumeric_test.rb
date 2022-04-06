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

describe "Spanner Client", :params, :bool, :spanner do
  let(:db) { spanner_pg_client }

  it "queries and returns a BigDecimal parameter" do
    skip if emulator_enabled?
    results = db.execute_query "SELECT $1 AS value", params: { p1: BigDecimal(1) }, types: { p1: :PG_NUMERIC }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields[:value]).must_equal :NUMERIC
    _(results.rows.first[:value]).must_equal BigDecimal(1)
  end

  it "queries and returns a NULL parameter" do
    skip if emulator_enabled?
    results = db.execute_query "SELECT $1 AS value", params: { p1: nil }, types: { p1: :PG_NUMERIC }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields[:value]).must_equal :NUMERIC
    _(results.rows.first[:value]).must_be :nil?
  end

  it "queries and returns a NAN BigDecimal parameter" do
    skip if emulator_enabled?
    results = db.execute_query "SELECT $1 AS value", params: { p1: BigDecimal("NaN") }, types: { p1: :PG_NUMERIC }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields[:value]).must_equal :NUMERIC
    _(results.rows.first[:value]).must_be :nan?
  end
end
