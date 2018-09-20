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

  it "executes multiple DML statements in a transaction" do
    prior_results = db.execute "SELECT * FROM accounts"
    prior_results.rows.count.must_equal 3

    timestamp = db.transaction do |tx|
      tx.transaction_id.wont_be :nil?

      # Execute a DML using execute_update and make sure data is updated and correct count is returned.
      insert_row_count = tx.execute_update \
        "INSERT INTO accounts (account_id, username, active, reputation) VALUES (@account_id, @username, @active, @reputation)",
        params: { account_id: 4, username: "inserted", active: true, reputation: 88.8 }
      insert_row_count.must_equal 1

      insert_results = tx.execute \
        "SELECT username FROM accounts WHERE account_id = @account_id",
        params: { account_id: 4 }
      insert_rows = insert_results.rows.to_a
      insert_rows.count.must_equal 1
      insert_rows.first[:username].must_equal "inserted"

      # Execute a DML using execute_sql and make sure data is updated and correct count is returned.
      update_results = tx.execute \
        "UPDATE accounts SET username = @username, active = @active WHERE account_id = @account_id",
        params: { account_id: 4, username: "updated", active: false }
      update_results.rows.to_a # fetch all the results
      update_results.must_be :row_count_exact?
      update_results.row_count.must_equal 1

      update_results = tx.execute \
        "SELECT username FROM accounts WHERE account_id = @account_id",
        params: { account_id: 4 }
      update_rows = update_results.rows.to_a
      update_rows.count.must_equal 1
      update_rows.first[:username].must_equal "updated"
    end
    timestamp.must_be_kind_of Time

    post_results = db.execute "SELECT * FROM accounts", single_use: { timestamp: timestamp }
    post_results.rows.count.must_equal 4
  end

  it "executes a DML statement, then rollback the transaction" do
    prior_results = db.execute "SELECT * FROM accounts"
    prior_results.rows.count.must_equal 3

    timestamp = db.transaction do |tx|
      tx.transaction_id.wont_be :nil?

      # Execute a DML using execute_update and make sure data is updated and correct count is returned.
      insert_row_count = tx.execute_update \
        "INSERT INTO accounts (account_id, username, active, reputation) VALUES (@account_id, @username, @active, @reputation)",
        params: { account_id: 4, username: "inserted", active: true, reputation: 88.8 }
      insert_row_count.must_equal 1

      insert_results = tx.execute \
        "SELECT username FROM accounts WHERE account_id = @account_id",
        params: { account_id: 4 }
      insert_rows = insert_results.rows.to_a
      insert_rows.count.must_equal 1
      insert_rows.first[:username].must_equal "inserted"

      # Execute a DML statement, then rollback the transaction and assert that data is not updated.
      raise Google::Cloud::Spanner::Rollback
    end
    timestamp.must_be :nil? # because the transaction was rolled back

    post_results = db.execute "SELECT * FROM accounts"
    post_results.rows.count.must_equal 3
  end

  it "executes a DML statement, then a mutation" do
    prior_results = db.execute "SELECT * FROM accounts"
    prior_results.rows.count.must_equal 3

    timestamp = db.transaction do |tx|
      tx.transaction_id.wont_be :nil?

      # Execute a DML statement, followed by calling existing insert method, commit the transaction and assert that both the updates are present.
      insert_row_count = tx.execute_update \
        "INSERT INTO accounts (account_id, username, active, reputation) VALUES (@account_id, @username, @active, @reputation)",
        params: { account_id: 4, username: "inserted by DML", active: true, reputation: 88.8 }
      insert_row_count.must_equal 1

      insert_mut_rows = tx.insert "accounts", { account_id: 5, username: "inserted by mutation", active: true, reputation: 99.9 }
      insert_mut_rows.count.must_equal 1
    end
    timestamp.must_be_kind_of Time

    post_results = db.execute "SELECT * FROM accounts", single_use: { timestamp: timestamp }
    post_results.rows.count.must_equal 5
  end
end
