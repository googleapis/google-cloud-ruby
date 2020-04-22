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

describe "Spanner Client", :execute_sql, :spanner do
  let(:db) { spanner_client }

  it "runs SELECT 1" do
    results = db.execute_sql "SELECT 1"
    _(results).must_be_kind_of Google::Cloud::Spanner::Results

    _(results.fields).must_be_kind_of Google::Cloud::Spanner::Fields
    _(results.fields.keys.count).must_equal 1
    _(results.fields[0]).must_equal :INT64

    rows = results.rows.to_a # grab all from the enumerator
    _(rows.count).must_equal 1
    row = rows.first
    _(row).must_be_kind_of Google::Cloud::Spanner::Data
    _(row.keys).must_equal [0]
    _(row[0]).must_equal 1
  end

  it "runs a simple query" do
    results = db.execute_sql "SELECT 42 AS num"
    _(results).must_be_kind_of Google::Cloud::Spanner::Results

    _(results.fields).must_be_kind_of Google::Cloud::Spanner::Fields
    _(results.fields.keys.count).must_equal 1
    _(results.fields[:num]).must_equal :INT64

    rows = results.rows.to_a # grab all from the enumerator
    _(rows.count).must_equal 1
    row = rows.first
    _(row).must_be_kind_of Google::Cloud::Spanner::Data
    _(row.keys).must_equal [:num]
    _(row[:num]).must_equal 42
  end

  it "runs a simple query using a single-use strong option" do
    results = db.execute_sql "SELECT 42 AS num", single_use: { strong: true }
    _(results).must_be_kind_of Google::Cloud::Spanner::Results

    _(results.fields).must_be_kind_of Google::Cloud::Spanner::Fields
    _(results.fields.keys.count).must_equal 1
    _(results.fields[:num]).must_equal :INT64

    rows = results.rows.to_a # grab all from the enumerator
    _(rows.count).must_equal 1
    row = rows.first
    _(row).must_be_kind_of Google::Cloud::Spanner::Data
    _(row.keys).must_equal [:num]
    _(row[:num]).must_equal 42
  end

  it "runs a simple query using a single-use timestamp option" do
    results = db.execute_sql "SELECT 42 AS num", single_use: { timestamp: (Time.now - 60) }
    _(results).must_be_kind_of Google::Cloud::Spanner::Results

    _(results.fields).must_be_kind_of Google::Cloud::Spanner::Fields
    _(results.fields.keys.count).must_equal 1
    _(results.fields[:num]).must_equal :INT64

    rows = results.rows.to_a # grab all from the enumerator
    _(rows.count).must_equal 1
    row = rows.first
    _(row).must_be_kind_of Google::Cloud::Spanner::Data
    _(row.keys).must_equal [:num]
    _(row[:num]).must_equal 42
  end

  it "runs a simple query using a single-use staleness option" do
    results = db.execute_sql "SELECT 42 AS num", single_use: { staleness: 60 }
    _(results).must_be_kind_of Google::Cloud::Spanner::Results

    _(results.fields).must_be_kind_of Google::Cloud::Spanner::Fields
    _(results.fields.keys.count).must_equal 1
    _(results.fields[:num]).must_equal :INT64

    rows = results.rows.to_a # grab all from the enumerator
    _(rows.count).must_equal 1
    row = rows.first
    _(row).must_be_kind_of Google::Cloud::Spanner::Data
    _(row.keys).must_equal [:num]
    _(row[:num]).must_equal 42
  end

  it "runs a simple query using a single-use bounded_timestamp option" do
    results = db.execute_sql "SELECT 42 AS num", single_use: { bounded_timestamp: (Time.now - 60) }
    _(results).must_be_kind_of Google::Cloud::Spanner::Results

    _(results.fields).must_be_kind_of Google::Cloud::Spanner::Fields
    _(results.fields.keys.count).must_equal 1
    _(results.fields[:num]).must_equal :INT64

    rows = results.rows.to_a # grab all from the enumerator
    _(rows.count).must_equal 1
    row = rows.first
    _(row).must_be_kind_of Google::Cloud::Spanner::Data
    _(row.keys).must_equal [:num]
    _(row[:num]).must_equal 42
  end

  it "runs a simple query using a single-use bounded_staleness option" do
    results = db.execute_sql "SELECT 42 AS num", single_use: { bounded_staleness: 60 }
    _(results).must_be_kind_of Google::Cloud::Spanner::Results

    _(results.fields).must_be_kind_of Google::Cloud::Spanner::Fields
    _(results.fields.keys.count).must_equal 1
    _(results.fields[:num]).must_equal :INT64

    rows = results.rows.to_a # grab all from the enumerator
    _(rows.count).must_equal 1
    row = rows.first
    _(row).must_be_kind_of Google::Cloud::Spanner::Data
    _(row.keys).must_equal [:num]
    _(row[:num]).must_equal 42
  end

  it "runs a simple query with query options" do
    query_options = { optimizer_version: "1" }
    results = db.execute_sql "SELECT 42 AS num", query_options: query_options
    _(results).must_be_kind_of Google::Cloud::Spanner::Results

    _(results.fields).must_be_kind_of Google::Cloud::Spanner::Fields
    _(results.fields.keys.count).must_equal 1
    _(results.fields[:num]).must_equal :INT64

    rows = results.rows.to_a # grab all from the enumerator
    _(rows.count).must_equal 1
    row = rows.first
    _(row).must_be_kind_of Google::Cloud::Spanner::Data
    _(row.keys).must_equal [:num]
    _(row[:num]).must_equal 42
  end

  it "runs a simple query when the client-level config of query options is set" do
    query_options = { optimizer_version: "1" }
    new_spanner = Google::Cloud::Spanner.new
    new_db = new_spanner.client db.instance_id, db.database_id, query_options: query_options
    _(new_db.query_options).must_equal({ optimizer_version: "1" })

    results = new_db.execute_sql "SELECT 42 AS num"
    _(results).must_be_kind_of Google::Cloud::Spanner::Results

    _(results.fields).must_be_kind_of Google::Cloud::Spanner::Fields
    _(results.fields.keys.count).must_equal 1
    _(results.fields[:num]).must_equal :INT64

    rows = results.rows.to_a # grab all from the enumerator
    _(rows.count).must_equal 1
    row = rows.first
    _(row).must_be_kind_of Google::Cloud::Spanner::Data
    _(row.keys).must_equal [:num]
    _(row[:num]).must_equal 42
  end

  describe "when the environment variable of query options is set" do
    let(:origin_env) { nil }

    before do
      origin_env = ENV["SPANNER_OPTIMIZER_VERSION"]
      ENV["SPANNER_OPTIMIZER_VERSION"] = "1"
    end

    after do
      ENV["SPANNER_OPTIMIZER_VERSION"] = origin_env
    end

    it "runs a simple query " do
      new_spanner = Google::Cloud::Spanner.new
      new_db = new_spanner.client db.instance_id, db.database_id
      _(new_db.project.query_options).must_equal({ optimizer_version: "1" })

      results = new_db.execute_sql "SELECT 42 AS num"
      _(results).must_be_kind_of Google::Cloud::Spanner::Results

      _(results.fields).must_be_kind_of Google::Cloud::Spanner::Fields
      _(results.fields.keys.count).must_equal 1
      _(results.fields[:num]).must_equal :INT64

      rows = results.rows.to_a # grab all from the enumerator
      _(rows.count).must_equal 1
      row = rows.first
      _(row).must_be_kind_of Google::Cloud::Spanner::Data
      _(row.keys).must_equal [:num]
      _(row[:num]).must_equal 42
    end
  end
end
