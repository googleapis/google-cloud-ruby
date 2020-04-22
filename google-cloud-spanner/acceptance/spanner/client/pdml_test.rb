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
  let(:db) { spanner_client }

  before do
    db.commit do |c|
      c.delete "accounts"
      c.insert "accounts", default_account_rows
    end
  end

  after do
    db.delete "accounts"
  end

  it "executes a simple Partitioned DML statement" do
    prior_results = db.execute_sql "SELECT * FROM accounts WHERE active = TRUE"
    _(prior_results.rows.count).must_equal 2

    pdml_row_count = db.execute_partition_update "UPDATE accounts a SET a.active = TRUE WHERE a.active = FALSE"
    _(pdml_row_count).must_equal 1

    post_results = db.execute_sql "SELECT * FROM accounts WHERE active = TRUE", single_use: { strong: true }
    _(post_results.rows.count).must_equal 3
  end

  it "executes a simple Partitioned DML statement with query options" do
    prior_results = db.execute_sql "SELECT * FROM accounts WHERE active = TRUE"
    _(prior_results.rows.count).must_equal 2

    query_options = { optimizer_version: "1" }
    pdml_row_count = db.execute_partition_update "UPDATE accounts a SET a.active = TRUE WHERE a.active = FALSE", query_options: query_options
    _(pdml_row_count).must_equal 1

    post_results = db.execute_sql "SELECT * FROM accounts WHERE active = TRUE", single_use: { strong: true }
    _(post_results.rows.count).must_equal 3
  end
end
