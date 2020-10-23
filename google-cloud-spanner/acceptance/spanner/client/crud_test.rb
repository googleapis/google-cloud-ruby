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
    commit_resp = db.delete "accounts"
    @setup_timestamp = commit_resp.timestamp
  end

  it "inserts, updates, upserts, reads, and deletes records" do
    results = db.read "accounts", ["account_id"], single_use: { timestamp: @setup_timestamp }
    _(results.rows.count).must_equal 0
    _(results.timestamp).wont_be :nil?

    db.insert "accounts", default_account_rows[0]
    db.upsert "accounts", default_account_rows[1]
    commit_resp = db.insert "accounts", default_account_rows[2]
    assert_commit_resp commit_resp

    results = db.read "accounts", ["account_id"], single_use: { timestamp: commit_resp.timestamp }
    _(results.rows.count).must_equal 3
    _(results.timestamp).wont_be :nil?

    active_count_sql = "SELECT COUNT(*) AS count FROM accounts WHERE active = true"

    results = db.execute_query active_count_sql, single_use: { timestamp: commit_resp.timestamp }
    _(results.rows.first[:count]).must_equal 2
    _(results.timestamp).wont_be :nil?

    activate_inactive_account = { account_id: 3, active: true }

    commit_resp = db.upsert "accounts", activate_inactive_account
    assert_commit_resp commit_resp

    results = db.execute_query active_count_sql, single_use: { timestamp: commit_resp.timestamp }
    _(results.rows.first[:count]).must_equal 3
    _(results.timestamp).wont_be :nil?

    commit_resp = db.delete "accounts", [1, 2, 3]
    assert_commit_resp commit_resp

    results = db.read "accounts", ["account_id"], single_use: { timestamp: commit_resp.timestamp }
    _(results.rows.count).must_equal 0
    _(results.timestamp).wont_be :nil?
  end

  it "inserts, updates, upserts, reads, and deletes records with commit stats" do
    results = db.read "accounts", ["account_id"], single_use: { timestamp: @setup_timestamp }
    _(results.rows.count).must_equal 0
    _(results.timestamp).wont_be :nil?

    commit_resp = db.insert "accounts", default_account_rows[0], commit_stats: true
    assert_commit_resp commit_resp, stats: true

    db.upsert "accounts", default_account_rows[1]
    commit_resp = db.insert "accounts", default_account_rows[2], commit_stats: true
    assert_commit_resp commit_resp, stats: true

    results = db.read "accounts", ["account_id"], single_use: { timestamp: commit_resp.timestamp }
    _(results.rows.count).must_equal 3
    _(results.timestamp).wont_be :nil?

    active_count_sql = "SELECT COUNT(*) AS count FROM accounts WHERE active = true"

    results = db.execute_query active_count_sql, single_use: { timestamp: commit_resp.timestamp }
    _(results.rows.first[:count]).must_equal 2
    _(results.timestamp).wont_be :nil?

    activate_inactive_account = { account_id: 3, active: true }

    commit_resp = db.upsert "accounts", activate_inactive_account, commit_stats: true
    assert_commit_resp commit_resp, stats: true

    results = db.execute_query active_count_sql, single_use: { timestamp: commit_resp.timestamp }
    _(results.rows.first[:count]).must_equal 3
    _(results.timestamp).wont_be :nil?

    commit_resp = db.delete "accounts", [1, 2, 3], commit_stats: true
    assert_commit_resp commit_resp, stats: true

    results = db.read "accounts", ["account_id"], single_use: { timestamp: commit_resp.timestamp }
    _(results.rows.count).must_equal 0
    _(results.timestamp).wont_be :nil?
  end

  it "inserts, updates, upserts, reads, and deletes records using commit" do
    results = db.read "accounts", ["account_id"], single_use: { timestamp: @setup_timestamp }
    _(results.rows.count).must_equal 0
    _(results.timestamp).wont_be :nil?

    commit_resp = db.commit do |c|
      c.insert "accounts", default_account_rows[0]
      c.upsert "accounts", default_account_rows[1]
      c.insert "accounts", default_account_rows[2]
    end
    assert_commit_resp commit_resp

    results = db.read "accounts", ["account_id"], single_use: { timestamp: commit_resp.timestamp }
    _(results.rows.count).must_equal 3
    _(results.timestamp).wont_be :nil?

    active_count_sql = "SELECT COUNT(*) AS count FROM accounts WHERE active = true"

    results = db.execute_query active_count_sql, single_use: { timestamp: commit_resp.timestamp }
    _(results.rows.first[:count]).must_equal 2
    _(results.timestamp).wont_be :nil?

    activate_inactive_account = { account_id: 3, active: true }

    commit_resp = db.commit do |c|
      c.upsert "accounts", activate_inactive_account
    end
    assert_commit_resp commit_resp

    results = db.execute_query active_count_sql, single_use: { timestamp: commit_resp.timestamp }
    _(results.rows.first[:count]).must_equal 3
    _(results.timestamp).wont_be :nil?

    commit_resp = db.commit do |c|
      c.delete "accounts", [1, 2, 3]
    end
    assert_commit_resp commit_resp

    results = db.read "accounts", ["account_id"], single_use: { timestamp: commit_resp.timestamp }
    _(results.rows.count).must_equal 0
    _(results.timestamp).wont_be :nil?
  end

  it "inserts, updates, upserts, reads, and deletes records using commit with commit stats" do
    results = db.read "accounts", ["account_id"], single_use: { timestamp: @setup_timestamp }
    _(results.rows.count).must_equal 0
    _(results.timestamp).wont_be :nil?

    commit_resp = db.commit commit_stats: true do |c|
      c.insert "accounts", default_account_rows[0]
      c.upsert "accounts", default_account_rows[1]
      c.insert "accounts", default_account_rows[2]
    end
    assert_commit_resp commit_resp, stats: true

    results = db.read "accounts", ["account_id"], single_use: { timestamp: commit_resp.timestamp }
    _(results.rows.count).must_equal 3
    _(results.timestamp).wont_be :nil?

    active_count_sql = "SELECT COUNT(*) AS count FROM accounts WHERE active = true"

    results = db.execute_query active_count_sql, single_use: { timestamp: commit_resp.timestamp }
    _(results.rows.first[:count]).must_equal 2
    _(results.timestamp).wont_be :nil?

    activate_inactive_account = { account_id: 3, active: true }

    commit_resp = db.commit commit_stats: true do |c|
      c.upsert "accounts", activate_inactive_account
    end
    assert_commit_resp commit_resp, stats: true

    results = db.execute_query active_count_sql, single_use: { timestamp: commit_resp.timestamp }
    _(results.rows.first[:count]).must_equal 3
    _(results.timestamp).wont_be :nil?

    commit_resp = db.commit commit_stats: true do |c|
      c.delete "accounts", [1, 2, 3]
    end
    assert_commit_resp commit_resp, stats: true

    results = db.read "accounts", ["account_id"], single_use: { timestamp: commit_resp.timestamp }
    _(results.rows.count).must_equal 0
    _(results.timestamp).wont_be :nil?
  end

  it "inserts, updates, upserts, reads, and deletes records in a transaction" do
    timestamp = @setup_timestamp
    active_count_sql = "SELECT COUNT(*) AS count FROM accounts WHERE active = true"

    commit_resp = db.transaction do |tx|
      _(tx.read("accounts", ["account_id"]).rows.count).must_equal 0

      tx.insert "accounts", default_account_rows[0]
      tx.upsert "accounts", default_account_rows[1]
      tx.insert "accounts", default_account_rows[2]
    end
    assert_commit_resp commit_resp

    commit_resp = db.transaction do |tx|
      _(db.read("accounts", ["account_id"]).rows.count).must_equal 3

      _(tx.execute_query(active_count_sql).rows.first[:count]).must_equal 2

      activate_inactive_account = { account_id: 3, active: true }

      tx.upsert "accounts", activate_inactive_account
    end
    assert_commit_resp commit_resp

    commit_resp = db.transaction do |tx|
      _(tx.execute_query(active_count_sql).rows.first[:count]).must_equal 3

      tx.delete "accounts", [1, 2, 3]
    end
    assert_commit_resp commit_resp

    results = db.read "accounts", ["account_id"], single_use: { timestamp: commit_resp.timestamp }
    _(results.rows.count).must_equal 0
    _(results.timestamp).wont_be :nil?
  end

  it "inserts, updates, upserts, reads, and deletes records in a transaction with commit stats" do
    timestamp = @setup_timestamp
    active_count_sql = "SELECT COUNT(*) AS count FROM accounts WHERE active = true"

    commit_resp = db.transaction commit_stats: true do |tx|
      _(tx.read("accounts", ["account_id"]).rows.count).must_equal 0

      tx.insert "accounts", default_account_rows[0]
      tx.upsert "accounts", default_account_rows[1]
      tx.insert "accounts", default_account_rows[2]
    end
    assert_commit_resp commit_resp, stats: true

    commit_resp = db.transaction commit_stats: true do |tx|
      _(db.read("accounts", ["account_id"]).rows.count).must_equal 3

      _(tx.execute_query(active_count_sql).rows.first[:count]).must_equal 2

      activate_inactive_account = { account_id: 3, active: true }

      tx.upsert "accounts", activate_inactive_account
    end
    assert_commit_resp commit_resp, stats: true

    commit_resp = db.transaction commit_stats: true do |tx|
      _(tx.execute_query(active_count_sql).rows.first[:count]).must_equal 3

      tx.delete "accounts", [1, 2, 3]
    end
    assert_commit_resp commit_resp, stats: true

    results = db.read "accounts", ["account_id"], single_use: { timestamp: commit_resp.timestamp }
    _(results.rows.count).must_equal 0
    _(results.timestamp).wont_be :nil?
  end
end
