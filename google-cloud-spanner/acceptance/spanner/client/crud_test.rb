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
    _(results.rows.count).must_equal 0
    _(results.timestamp).wont_be :nil?

    db.insert "accounts", default_account_rows[0]
    db.upsert "accounts", default_account_rows[1]
    timestamp = db.insert "accounts", default_account_rows[2]

    results = db.read "accounts", ["account_id"], single_use: { timestamp: timestamp }
    _(results.rows.count).must_equal 3
    _(results.timestamp).wont_be :nil?

    active_count_sql = "SELECT COUNT(*) AS count FROM accounts WHERE active = true"

    results = db.execute_query active_count_sql, single_use: { timestamp: timestamp }
    _(results.rows.first[:count]).must_equal 2
    _(results.timestamp).wont_be :nil?

    activate_inactive_account = { account_id: 3, active: true }

    timestamp = db.upsert "accounts", activate_inactive_account

    results = db.execute_query active_count_sql, single_use: { timestamp: timestamp }
    _(results.rows.first[:count]).must_equal 3
    _(results.timestamp).wont_be :nil?

    timestamp = db.delete "accounts", [1, 2, 3]

    results = db.read "accounts", ["account_id"], single_use: { timestamp: timestamp }
    _(results.rows.count).must_equal 0
    _(results.timestamp).wont_be :nil?
  end

  it "inserts, updates, upserts, reads, and deletes records using commit" do
    results = db.read "accounts", ["account_id"], single_use: { timestamp: @setup_timestamp }
    _(results.rows.count).must_equal 0
    _(results.timestamp).wont_be :nil?

    timestamp = db.commit do |c|
      c.insert "accounts", default_account_rows[0]
      c.upsert "accounts", default_account_rows[1]
      c.insert "accounts", default_account_rows[2]
    end

    results = db.read "accounts", ["account_id"], single_use: { timestamp: timestamp }
    _(results.rows.count).must_equal 3
    _(results.timestamp).wont_be :nil?

    active_count_sql = "SELECT COUNT(*) AS count FROM accounts WHERE active = true"

    results = db.execute_query active_count_sql, single_use: { timestamp: timestamp }
    _(results.rows.first[:count]).must_equal 2
    _(results.timestamp).wont_be :nil?

    activate_inactive_account = { account_id: 3, active: true }

    timestamp = db.commit do |c|
      c.upsert "accounts", activate_inactive_account
    end

    results = db.execute_query active_count_sql, single_use: { timestamp: timestamp }
    _(results.rows.first[:count]).must_equal 3
    _(results.timestamp).wont_be :nil?

    timestamp = db.commit do |c|
      c.delete "accounts", [1, 2, 3]
    end

    results = db.read "accounts", ["account_id"], single_use: { timestamp: timestamp }
    _(results.rows.count).must_equal 0
    _(results.timestamp).wont_be :nil?
  end

  it "inserts, updates, upserts, reads, and deletes records using commit and return commit stats" do
    skip if emulator_enabled?

    commit_options = { return_commit_stats: true }
    commit_resp = db.commit commit_options: commit_options do |c|
      c.insert "accounts", default_account_rows[0]
    end

    assert_commit_response commit_resp, commit_options

    results = db.read "accounts", ["account_id"], single_use: { timestamp: commit_resp.timestamp }
    _(results.rows.count).must_equal 1
    _(results.timestamp).wont_be :nil?

    commit_resp = db.commit commit_options: commit_options do |c|
      c.upsert "accounts", default_account_rows[0]
    end

    assert_commit_response commit_resp, commit_options

    commit_resp = db.commit commit_options: commit_options do |c|
      c.delete "accounts", [1]
    end

    assert_commit_response commit_resp, commit_options

    results = db.read "accounts", ["account_id"], single_use: { timestamp: commit_resp.timestamp }
    _(results.rows.count).must_equal 0
    _(results.timestamp).wont_be :nil?
  end

  it "inserts, updates, upserts, reads, and deletes records in a transaction" do
    timestamp = @setup_timestamp
    active_count_sql = "SELECT COUNT(*) AS count FROM accounts WHERE active = true"

    db.transaction do |tx|
      _(tx.read("accounts", ["account_id"]).rows.count).must_equal 0

      tx.insert "accounts", default_account_rows[0]
      tx.upsert "accounts", default_account_rows[1]
      tx.insert "accounts", default_account_rows[2]
    end

    timestamp = db.transaction do |tx|
      _(db.read("accounts", ["account_id"]).rows.count).must_equal 3

      _(tx.execute_query(active_count_sql).rows.first[:count]).must_equal 2

      activate_inactive_account = { account_id: 3, active: true }

      tx.upsert "accounts", activate_inactive_account
    end

    timestamp = db.transaction do |tx|
      _(tx.execute_query(active_count_sql).rows.first[:count]).must_equal 3

      tx.delete "accounts", [1, 2, 3]
    end

    results = db.read "accounts", ["account_id"], single_use: { timestamp: timestamp }
    _(results.rows.count).must_equal 0
    _(results.timestamp).wont_be :nil?
  end

  describe "request options" do
    it "execute CRUD statement with priority options" do
      request_options = { priority: :PRIORITY_MEDIUM }
      results = db.read "accounts", ["account_id"], request_options: request_options
      _(results.rows.count).must_equal 0

      db.insert "accounts", default_account_rows[0], request_options: request_options
      db.upsert "accounts", default_account_rows[1], request_options: request_options

      results = db.read "accounts", ["account_id"]
      _(results.rows.count).must_equal 2

      db.replace "accounts", default_account_rows[0], request_options: request_options
      db.delete "accounts", [1, 2, 3], request_options: request_options

      results = db.read "accounts", ["account_id"]
      _(results.rows.count).must_equal 0
    end
  end

  it "inserts, updates, upserts, reads, and deletes records with request tagging options" do
    timestamp = db.insert "accounts", default_account_rows[0],
                          request_options: { tag: "Tag-CRUD-1" }
    _(timestamp).wont_be :nil?

    results = db.read "accounts", ["account_id"], single_use: { timestamp: @setup_timestamp },
                      request_options: { tag: "Tag-CRUD-2" }
    _(results.timestamp).wont_be :nil?

    timestamp = db.update "accounts", default_account_rows[0],
                          request_options: { tag: "Tag-CRUD-2" }
    _(timestamp).wont_be :nil?

    timestamp = db.upsert "accounts", default_account_rows[1],
                          request_options: { tag: "Tag-CRUD-4" }
    _(timestamp).wont_be :nil?

    timestamp = db.delete "accounts", [1, 2, 3],
                          request_options: { tag: "Tag-CRUD-5" }
    _(timestamp).wont_be :nil?
  end
end
