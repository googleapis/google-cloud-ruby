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

describe "Spanner Client", :execute, :spanner do
  let(:db) { spanner_client }

  it "runs SELECT 1" do
    results = db.execute "SELECT 1"
    results.must_be_kind_of Google::Cloud::Spanner::Results

    results.fields.must_be_kind_of Google::Cloud::Spanner::Fields
    results.fields.keys.count.must_equal 1
    results.fields[0].must_equal :INT64

    rows = results.rows.to_a # grab all from the enumerator
    rows.count.must_equal 1
    row = rows.first
    row.must_be_kind_of Google::Cloud::Spanner::Data
    row.keys.must_equal [0]
    row[0].must_equal 1
  end

  it "runs a simple query" do
    results = db.execute "SELECT 42 AS num"
    results.must_be_kind_of Google::Cloud::Spanner::Results

    results.fields.must_be_kind_of Google::Cloud::Spanner::Fields
    results.fields.keys.count.must_equal 1
    results.fields[:num].must_equal :INT64

    rows = results.rows.to_a # grab all from the enumerator
    rows.count.must_equal 1
    row = rows.first
    row.must_be_kind_of Google::Cloud::Spanner::Data
    row.keys.must_equal [:num]
    row[:num].must_equal 42
  end

  it "runs a simple query using a single-use strong option" do
    results = db.execute "SELECT 42 AS num", single_use: { strong: true }
    results.must_be_kind_of Google::Cloud::Spanner::Results

    results.fields.must_be_kind_of Google::Cloud::Spanner::Fields
    results.fields.keys.count.must_equal 1
    results.fields[:num].must_equal :INT64

    rows = results.rows.to_a # grab all from the enumerator
    rows.count.must_equal 1
    row = rows.first
    row.must_be_kind_of Google::Cloud::Spanner::Data
    row.keys.must_equal [:num]
    row[:num].must_equal 42
  end

  it "runs a simple query using a single-use timestamp option" do
    results = db.execute "SELECT 42 AS num", single_use: { timestamp: (Time.now - 60) }
    results.must_be_kind_of Google::Cloud::Spanner::Results

    results.fields.must_be_kind_of Google::Cloud::Spanner::Fields
    results.fields.keys.count.must_equal 1
    results.fields[:num].must_equal :INT64

    rows = results.rows.to_a # grab all from the enumerator
    rows.count.must_equal 1
    row = rows.first
    row.must_be_kind_of Google::Cloud::Spanner::Data
    row.keys.must_equal [:num]
    row[:num].must_equal 42
  end

  it "runs a simple query using a single-use staleness option" do
    results = db.execute "SELECT 42 AS num", single_use: { staleness: 60 }
    results.must_be_kind_of Google::Cloud::Spanner::Results

    results.fields.must_be_kind_of Google::Cloud::Spanner::Fields
    results.fields.keys.count.must_equal 1
    results.fields[:num].must_equal :INT64

    rows = results.rows.to_a # grab all from the enumerator
    rows.count.must_equal 1
    row = rows.first
    row.must_be_kind_of Google::Cloud::Spanner::Data
    row.keys.must_equal [:num]
    row[:num].must_equal 42
  end

  it "runs a simple query using a single-use bounded_timestamp option" do
    results = db.execute "SELECT 42 AS num", single_use: { bounded_timestamp: (Time.now - 60) }
    results.must_be_kind_of Google::Cloud::Spanner::Results

    results.fields.must_be_kind_of Google::Cloud::Spanner::Fields
    results.fields.keys.count.must_equal 1
    results.fields[:num].must_equal :INT64

    rows = results.rows.to_a # grab all from the enumerator
    rows.count.must_equal 1
    row = rows.first
    row.must_be_kind_of Google::Cloud::Spanner::Data
    row.keys.must_equal [:num]
    row[:num].must_equal 42
  end

  it "runs a simple query using a single-use bounded_staleness option" do
    results = db.execute "SELECT 42 AS num", single_use: { bounded_staleness: 60 }
    results.must_be_kind_of Google::Cloud::Spanner::Results

    results.fields.must_be_kind_of Google::Cloud::Spanner::Fields
    results.fields.keys.count.must_equal 1
    results.fields[:num].must_equal :INT64

    rows = results.rows.to_a # grab all from the enumerator
    rows.count.must_equal 1
    row = rows.first
    row.must_be_kind_of Google::Cloud::Spanner::Data
    row.keys.must_equal [:num]
    row[:num].must_equal 42
  end
end
