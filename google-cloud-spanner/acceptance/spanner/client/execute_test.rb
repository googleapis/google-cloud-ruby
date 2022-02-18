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
  let :db do
    { gsql: spanner_client, pg: spanner_pg_client }
  end

  dialects = [:gsql]
  dialects.push :pg unless emulator_enabled?

  dialects.each do |dialect|
    it "runs SELECT 1 for #{dialect}" do
      results = db[dialect].execute_sql "SELECT 1"
      _(results).must_be_kind_of Google::Cloud::Spanner::Results

      _(results.fields).must_be_kind_of Google::Cloud::Spanner::Fields
      _(results.fields.keys.count).must_equal 1
      _(results.fields[0]).must_equal :INT64

      rows = results.rows.to_a # grab all from the enumerator
      _(rows.count).must_equal 1
      row = rows.first
      _(row).must_be_kind_of Google::Cloud::Spanner::Data
      _(row[0]).must_equal 1
    end

    it "runs a simple query for #{dialect}" do
      results = db[dialect].execute_sql "SELECT 42 AS num"
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

    it "runs a simple query using a single-use strong option for #{dialect}" do
      results = db[dialect].execute_sql "SELECT 42 AS num", single_use: { strong: true }
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

    it "runs a simple query using a single-use timestamp option for #{dialect}" do
      results = db[dialect].execute_sql "SELECT 42 AS num", single_use: { timestamp: (Time.now - 60) }
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

    it "runs a simple query using a single-use staleness option for #{dialect}" do
      results = db[dialect].execute_sql "SELECT 42 AS num", single_use: { staleness: 60 }
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

    it "runs a simple query using a single-use bounded_timestamp option for #{dialect}" do
      results = db[dialect].execute_sql "SELECT 42 AS num", single_use: { bounded_timestamp: (Time.now - 60) }
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

    it "runs a simple query using a single-use bounded_staleness option for #{dialect}" do
      results = db[dialect].execute_sql "SELECT 42 AS num", single_use: { bounded_staleness: 60 }
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

    it "runs a simple query with query options for #{dialect}" do
      query_options = { optimizer_version: "3", optimizer_statistics_package: "latest" }
      results = db[dialect].execute_sql "SELECT 42 AS num", query_options: query_options
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

    it "runs a simple query when the client-level config of query options is set for #{dialect}" do
      query_options = { optimizer_version: "3", optimizer_statistics_package: "latest" }
      new_spanner = Google::Cloud::Spanner.new
      new_db = new_spanner.client db[dialect].instance_id, db[dialect].database_id, query_options: query_options
      _(new_db.query_options).must_equal({ optimizer_version: "3", optimizer_statistics_package: "latest" })

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

    describe "when the environment variable of query options is set for #{dialect}" do
      let(:origin_opt_version) { nil }
      let(:origin_opt_stats_pkg) { nil }

      before do
        origin_opt_version = ENV["SPANNER_OPTIMIZER_VERSION"] # rubocop:disable Lint/UselessAssignment
        ENV["SPANNER_OPTIMIZER_VERSION"] = "3"
        origin_opt_stats_pkg = ENV["SPANNER_OPTIMIZER_STATISTICS_PACKAGE"] # rubocop:disable Lint/UselessAssignment
        ENV["SPANNER_OPTIMIZER_STATISTICS_PACKAGE"] = "latest"
      end

      after do
        ENV["SPANNER_OPTIMIZER_VERSION"] = origin_opt_version
        ENV["SPANNER_OPTIMIZER_STATISTICS_PACKAGE"] = origin_opt_stats_pkg
      end

      it "runs a simple query  for #{dialect}" do
        new_spanner = Google::Cloud::Spanner.new
        new_db = new_spanner.client db[dialect].instance_id, db[dialect].database_id
        _(new_db.project.query_options).must_equal({ optimizer_version: "3", optimizer_statistics_package: "latest" })

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

    describe "request options for #{dialect}" do
      it "run sample query with priority for #{dialect}" do
        results = db[dialect].execute_sql "SELECT 1", request_options: { priority: :PRIORITY_MEDIUM }
        _(results).must_be_kind_of Google::Cloud::Spanner::Results

        _(results.rows.count).must_equal 1
      end
    end
  end
end
