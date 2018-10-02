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

describe "Spanner Client", :crud, :spanner do
  let(:db) { spanner_client }

  before do
    @setup_timestamp = db.delete "accounts"
  end

  it "inserts, updates, upserts, reads, and deletes records" do
    results = db.read "accounts", ["account_id"], single_use: { timestamp: @setup_timestamp }
    results.rows.count.must_equal 0
    results.timestamp.wont_be :nil?

    db.insert "accounts", default_account_rows[0]
    db.upsert "accounts", default_account_rows[1]
    timestamp = db.insert "accounts", default_account_rows[2]

    results = db.read "accounts", ["account_id"], single_use: { timestamp: timestamp }
    results.rows.count.must_equal 3
    results.timestamp.wont_be :nil?

    active_count_sql = "SELECT COUNT(*) AS count FROM accounts WHERE active = true"

    results = db.execute_query active_count_sql, single_use: { timestamp: timestamp }
    results.rows.first[:count].must_equal 2
    results.timestamp.wont_be :nil?

    activate_inactive_account = { account_id: 3, active: true }

    timestamp = db.upsert "accounts", activate_inactive_account

    results = db.execute_query active_count_sql, single_use: { timestamp: timestamp }
    results.rows.first[:count].must_equal 3
    results.timestamp.wont_be :nil?

    timestamp = db.delete "accounts", [1, 2, 3]

    results = db.read "accounts", ["account_id"], single_use: { timestamp: timestamp }
    results.rows.count.must_equal 0
    results.timestamp.wont_be :nil?
  end

  it "inserts, updates, upserts, reads, and deletes records using commit" do
    results = db.read "accounts", ["account_id"], single_use: { timestamp: @setup_timestamp }
    results.rows.count.must_equal 0
    results.timestamp.wont_be :nil?

    timestamp = db.commit do |c|
      c.insert "accounts", default_account_rows[0]
      c.upsert "accounts", default_account_rows[1]
      c.insert "accounts", default_account_rows[2]
    end

    results = db.read "accounts", ["account_id"], single_use: { timestamp: timestamp }
    results.rows.count.must_equal 3
    results.timestamp.wont_be :nil?

    active_count_sql = "SELECT COUNT(*) AS count FROM accounts WHERE active = true"

    results = db.execute_query active_count_sql, single_use: { timestamp: timestamp }
    results.rows.first[:count].must_equal 2
    results.timestamp.wont_be :nil?

    activate_inactive_account = { account_id: 3, active: true }

    timestamp = db.commit do |c|
      c.upsert "accounts", activate_inactive_account
    end

    results = db.execute_query active_count_sql, single_use: { timestamp: timestamp }
    results.rows.first[:count].must_equal 3
    results.timestamp.wont_be :nil?

    timestamp = db.commit do |c|
      c.delete "accounts", [1, 2, 3]
    end

    results = db.read "accounts", ["account_id"], single_use: { timestamp: timestamp }
    results.rows.count.must_equal 0
    results.timestamp.wont_be :nil?
  end

  it "inserts, updates, upserts, reads, and deletes records in a transaction" do
    timestamp = @setup_timestamp
    active_count_sql = "SELECT COUNT(*) AS count FROM accounts WHERE active = true"

    db.transaction do |tx|
      tx.read("accounts", ["account_id"]).rows.count.must_equal 0

      tx.insert "accounts", default_account_rows[0]
      tx.upsert "accounts", default_account_rows[1]
      tx.insert "accounts", default_account_rows[2]
    end

    timestamp = db.transaction do |tx|
      db.read("accounts", ["account_id"]).rows.count.must_equal 3

      tx.execute_query(active_count_sql).rows.first[:count].must_equal 2

      activate_inactive_account = { account_id: 3, active: true }

      tx.upsert "accounts", activate_inactive_account
    end

    timestamp = db.transaction do |tx|
      tx.execute_query(active_count_sql).rows.first[:count].must_equal 3

      tx.delete "accounts", [1, 2, 3]
    end

    results = db.read "accounts", ["account_id"], single_use: { timestamp: timestamp }
    results.rows.count.must_equal 0
    results.timestamp.wont_be :nil?
  end
end
