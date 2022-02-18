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

describe "Spanner Client", :dml, :spanner do
  let :db do
    { gsql: spanner_client, pg: spanner_pg_client }
  end
  let :insert_dml do
    { gsql: "INSERT INTO accounts (account_id, username, active, reputation) \
             VALUES (@account_id, @username, @active, @reputation)",
      pg: "INSERT INTO accounts (account_id, username, active, reputation) VALUES ($1, $2, $3, $4)" }
  end
  let :update_dml do
    { gsql: "UPDATE accounts SET username = @username, active = @active WHERE account_id = @account_id",
      pg: "UPDATE accounts SET username = $2, active = $3 WHERE account_id = $1" }
  end
  let :select_dql do
    { gsql: "SELECT username FROM accounts WHERE account_id = @account_id",
      pg: "SELECT username FROM accounts WHERE account_id = $1" }
  end
  let :insert_params do
    { gsql: { account_id: 4, username: "inserted", active: true, reputation: 88.8 },
      pg: { p1: 4, p2: "inserted", p3: true, p4: 88.8 } }
  end
  let :update_params do
    { gsql: { account_id: 4, username: "updated", active: false },
      pg:  { p1: 4, p2: "updated", p3: false } }
  end
  let :select_params do
    { gsql: { account_id: 4 }, pg: { p1: 4 } }
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
    db[:pg].delete "accounts" unless emulator_enabled?
    db[:gsql].delete "accounts"
  end

  dialects = [:gsql]
  dialects.push :pg unless emulator_enabled?

  dialects.each do |dialect|
    it "executes multiple DML statements in a transaction for #{dialect}" do
      prior_results = db[dialect].execute_sql "SELECT * FROM accounts"
      _(prior_results.rows.count).must_equal 3

      timestamp = db[dialect].transaction do |tx|
        _(tx.transaction_id).wont_be :nil?

        # Execute a DML using execute_update and make sure data is updated and correct count is returned.
        insert_row_count = tx.execute_update \
          insert_dml[dialect],
          params: insert_params[dialect]
        _(insert_row_count).must_equal 1

        insert_results = tx.execute_sql \
          select_dql[dialect],
          params: select_params[dialect]
        insert_rows = insert_results.rows.to_a
        _(insert_rows.count).must_equal 1
        _(insert_rows.first[:username]).must_equal "inserted"

        # Execute a DML using execute_sql and make sure data is updated and correct count is returned.
        update_results = tx.execute_sql \
          update_dml[dialect],
          params: update_params[dialect]
        update_results.rows.to_a # fetch all the results
        _(update_results).must_be :row_count_exact?
        _(update_results.row_count).must_equal 1

        update_results = tx.execute_sql \
          select_dql[dialect],
          params: select_params[dialect]
        update_rows = update_results.rows.to_a
        _(update_rows.count).must_equal 1
        _(update_rows.first[:username]).must_equal "updated"
      end
      _(timestamp).must_be_kind_of Time

      post_results = db[dialect].execute_sql "SELECT * FROM accounts", single_use: { timestamp: timestamp }
      _(post_results.rows.count).must_equal 4
    end

    it "executes a DML statement, then rollback the transaction for #{dialect}" do
      prior_results = db[dialect].execute_sql "SELECT * FROM accounts"
      _(prior_results.rows.count).must_equal 3

      timestamp = db[dialect].transaction do |tx|
        _(tx.transaction_id).wont_be :nil?

        # Execute a DML using execute_update and make sure data is updated and correct count is returned.
        insert_row_count = tx.execute_update \
          insert_dml[dialect],
          params: insert_params[dialect]
        _(insert_row_count).must_equal 1

        insert_results = tx.execute_sql \
          select_dql[dialect],
          params: select_params[dialect]
        insert_rows = insert_results.rows.to_a
        _(insert_rows.count).must_equal 1
        _(insert_rows.first[:username]).must_equal "inserted"

        # Execute a DML statement, then rollback the transaction and assert that data is not updated.
        raise Google::Cloud::Spanner::Rollback
      end
      _(timestamp).must_be :nil? # because the transaction was rolled back

      post_results = db[dialect].execute_sql "SELECT * FROM accounts"
      _(post_results.rows.count).must_equal 3
    end

    it "executes a DML statement, then a mutation for #{dialect}" do
      prior_results = db[dialect].execute_sql "SELECT * FROM accounts"
      _(prior_results.rows.count).must_equal 3

      timestamp = db[dialect].transaction do |tx|
        _(tx.transaction_id).wont_be :nil?

        # Execute a DML statement, followed by calling existing insert method,
        # commit the transaction and assert that both the updates are present.
        insert_row_count = tx.execute_update \
          insert_dml[dialect],
          params: insert_params[dialect]
        _(insert_row_count).must_equal 1

        insert_mut_rows = tx.insert "accounts",
                                    { account_id: 5, username: "inserted by mutation", active: true, reputation: 99.9 }
        _(insert_mut_rows.count).must_equal 1
      end
      _(timestamp).must_be_kind_of Time

      post_results = db[dialect].execute_sql "SELECT * FROM accounts", single_use: { timestamp: timestamp }
      _(post_results.rows.count).must_equal 5
    end

    describe "request options for #{dialect}" do
      it "execute DML statement with priority options for #{dialect}" do
        request_options = { priority: :PRIORITY_MEDIUM }

        db[dialect].transaction request_options: request_options do |tx|
          insert_row_count = tx.execute_update \
            insert_dml[dialect],
            params: insert_params[dialect],
            request_options: request_options
          _(insert_row_count).must_equal 1
        end
      end
    end
  end
end
