# Copyright 2018 Google LLC
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
require "concurrent"

describe "Spanner Client", :pdml, :spanner do
  let :db do
    { gsql: spanner_client, pg: spanner_pg_client }
  end

  before do
    db[:gsql].commit do |c|
      c.delete "accounts"
      c.insert "accounts", default_account_rows
    end
    unless emulator_enabled?
      db[:pg].commit do |c|
        c.delete "accounts"
        c.insert "accounts", default_pg_account_rows
      end
    end
  end

  after do
    db[:gsql].delete "accounts"
    db[:pg].delete "accounts" unless emulator_enabled?
  end

  dialects = [:gsql]
  dialects.push :pg unless emulator_enabled?

  dialects.each do |dialect|
    it "executes a simple Partitioned DML statement for #{dialect}" do
      prior_results = db[dialect].execute_sql "SELECT * FROM accounts WHERE active = TRUE"
      _(prior_results.rows.count).must_equal 2

      pdml_row_count = db[dialect].execute_partition_update "UPDATE accounts SET active = TRUE WHERE active = FALSE"
      _(pdml_row_count).must_equal 1

      post_results = db[dialect].execute_sql "SELECT * FROM accounts WHERE active = TRUE", single_use: { strong: true }
      _(post_results.rows.count).must_equal 3
    end

    it "executes a simple Partitioned DML statement with query options for #{dialect}" do
      prior_results = db[dialect].execute_sql "SELECT * FROM accounts WHERE active = TRUE"
      _(prior_results.rows.count).must_equal 2

      query_options = { optimizer_version: "3", optimizer_statistics_package: "latest" }
      pdml_row_count = db[dialect].execute_partition_update "UPDATE accounts SET active = TRUE WHERE active = FALSE",
                                                            query_options: query_options
      _(pdml_row_count).must_equal 1

      post_results = db[dialect].execute_sql "SELECT * FROM accounts WHERE active = TRUE", single_use: { strong: true }
      _(post_results.rows.count).must_equal 3
    end

    describe "request options for #{dialect}" do
      it "execute Partitioned DML statement with priority options for #{dialect}" do
        pdml_row_count = db[dialect].execute_partition_update "UPDATE accounts SET active = TRUE WHERE active = FALSE",
                                                              request_options: { priority: :PRIORITY_MEDIUM }

        _(pdml_row_count).must_equal 1
      end
    end

    it "executes a Partitioned DML statement with request tagging option for #{dialect}" do
      pdml_row_count = db[dialect].execute_partition_update "UPDATE accounts  SET active = TRUE WHERE active = FALSE",
                                                            request_options: { tag: "Tag-P-1" }
      _(pdml_row_count).must_equal 1
    end
  end
end
