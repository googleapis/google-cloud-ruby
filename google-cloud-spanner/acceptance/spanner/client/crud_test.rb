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
  let :db do
    { gsql: spanner_client, pg: spanner_pg_client }
  end

  before do
    setup_timestamp_gsql = db[:gsql].delete "accounts"
    setup_timestamp_pg = db[:pg].delete "accounts" unless emulator_enabled?
    @setup_timestamp = { gsql: setup_timestamp_gsql, pg: setup_timestamp_pg }
    @default_rows = { gsql: default_account_rows, pg: default_pg_account_rows }
  end

  dialects = [:gsql]
  dialects.push :pg unless emulator_enabled?

  dialects.each do |dialect|
    it "inserts, updates, upserts, reads, and deletes records for #{dialect}" do
      results = db[dialect].read "accounts", ["account_id"], single_use: { timestamp: @setup_timestamp[dialect] }
      _(results.rows.count).must_equal 0
      _(results.timestamp).wont_be :nil?

      db[dialect].insert "accounts", @default_rows[dialect][0]
      db[dialect].upsert "accounts", @default_rows[dialect][1]
      timestamp = db[dialect].insert "accounts", @default_rows[dialect][2]

      results = db[dialect].read "accounts", ["account_id"], single_use: { timestamp: timestamp }
      _(results.rows.count).must_equal 3
      _(results.timestamp).wont_be :nil?

      active_count_sql = "SELECT COUNT(*) AS count FROM accounts WHERE active = true"

      results = db[dialect].execute_query active_count_sql, single_use: { timestamp: timestamp }
      _(results.rows.first[:count]).must_equal 2
      _(results.timestamp).wont_be :nil?

      activate_inactive_account = { account_id: 3, active: true }

      timestamp = db[dialect].upsert "accounts", activate_inactive_account

      results = db[dialect].execute_query active_count_sql, single_use: { timestamp: timestamp }
      _(results.rows.first[:count]).must_equal 3
      _(results.timestamp).wont_be :nil?

      timestamp = db[dialect].delete "accounts", [1, 2, 3]

      results = db[dialect].read "accounts", ["account_id"], single_use: { timestamp: timestamp }
      _(results.rows.count).must_equal 0
      _(results.timestamp).wont_be :nil?
    end

    it "inserts, updates, upserts, reads, and deletes records using commit for #{dialect}" do
      results = db[dialect].read "accounts", ["account_id"], single_use: { timestamp: @setup_timestamp[dialect] }
      _(results.rows.count).must_equal 0
      _(results.timestamp).wont_be :nil?

      timestamp = db[dialect].commit do |c|
        c.insert "accounts", @default_rows[dialect][0]
        c.upsert "accounts", @default_rows[dialect][1]
        c.insert "accounts", @default_rows[dialect][2]
      end

      results = db[dialect].read "accounts", ["account_id"], single_use: { timestamp: timestamp }
      _(results.rows.count).must_equal 3
      _(results.timestamp).wont_be :nil?

      active_count_sql = "SELECT COUNT(*) AS count FROM accounts WHERE active = true"

      results = db[dialect].execute_query active_count_sql, single_use: { timestamp: timestamp }
      _(results.rows.first[:count]).must_equal 2
      _(results.timestamp).wont_be :nil?

      activate_inactive_account = { account_id: 3, active: true }

      timestamp = db[dialect].commit do |c|
        c.upsert "accounts", activate_inactive_account
      end

      results = db[dialect].execute_query active_count_sql, single_use: { timestamp: timestamp }
      _(results.rows.first[:count]).must_equal 3
      _(results.timestamp).wont_be :nil?

      timestamp = db[dialect].commit do |c|
        c.delete "accounts", [1, 2, 3]
      end

      results = db[dialect].read "accounts", ["account_id"], single_use: { timestamp: timestamp }
      _(results.rows.count).must_equal 0
      _(results.timestamp).wont_be :nil?
    end

    it "inserts, updates, upserts, reads, and deletes records using commit and return commit stats for #{dialect}" do
      skip if emulator_enabled?

      commit_options = { return_commit_stats: true }
      commit_resp = db[dialect].commit commit_options: commit_options do |c|
        c.insert "accounts", @default_rows[dialect][0]
      end

      assert_commit_response commit_resp, commit_options

      results = db[dialect].read "accounts", ["account_id"], single_use: { timestamp: commit_resp.timestamp }
      _(results.rows.count).must_equal 1
      _(results.timestamp).wont_be :nil?

      commit_resp = db[dialect].commit commit_options: commit_options do |c|
        c.upsert "accounts", @default_rows[dialect][0]
      end

      assert_commit_response commit_resp, commit_options

      commit_resp = db[dialect].commit commit_options: commit_options do |c|
        c.delete "accounts", [1]
      end

      assert_commit_response commit_resp, commit_options

      results = db[dialect].read "accounts", ["account_id"], single_use: { timestamp: commit_resp.timestamp }
      _(results.rows.count).must_equal 0
      _(results.timestamp).wont_be :nil?
    end

    it "inserts, updates, upserts, reads, and deletes records in a transaction for #{dialect}" do
      @setup_timestamp[dialect]
      active_count_sql = "SELECT COUNT(*) AS count FROM accounts WHERE active = true"

      db[dialect].transaction do |tx|
        _(tx.read("accounts", ["account_id"]).rows.count).must_equal 0

        tx.insert "accounts", @default_rows[dialect][0]
        tx.upsert "accounts", @default_rows[dialect][1]
        tx.insert "accounts", @default_rows[dialect][2]
      end

      db[dialect].transaction do |tx|
        _(db[dialect].read("accounts", ["account_id"]).rows.count).must_equal 3

        _(tx.execute_query(active_count_sql).rows.first[:count]).must_equal 2

        activate_inactive_account = { account_id: 3, active: true }

        tx.upsert "accounts", activate_inactive_account
      end

      timestamp = db[dialect].transaction do |tx|
        _(tx.execute_query(active_count_sql).rows.first[:count]).must_equal 3

        tx.delete "accounts", [1, 2, 3]
      end

      results = db[dialect].read "accounts", ["account_id"], single_use: { timestamp: timestamp }
      _(results.rows.count).must_equal 0
      _(results.timestamp).wont_be :nil?
    end

    describe "request options for #{dialect}" do
      it "execute CRUD statement with priority options for #{dialect}" do
        request_options = { priority: :PRIORITY_MEDIUM }
        results = db[dialect].read "accounts", ["account_id"], request_options: request_options
        _(results.rows.count).must_equal 0

        db[dialect].insert "accounts", @default_rows[dialect][0], request_options: request_options
        db[dialect].upsert "accounts", @default_rows[dialect][1], request_options: request_options

        results = db[dialect].read "accounts", ["account_id"]
        _(results.rows.count).must_equal 2

        db[dialect].replace "accounts", @default_rows[dialect][0], request_options: request_options
        db[dialect].delete "accounts", [1, 2, 3], request_options: request_options

        results = db[dialect].read "accounts", ["account_id"]
        _(results.rows.count).must_equal 0
      end
    end

    it "inserts, updates, upserts, reads, and deletes records with request tagging options for #{dialect}" do
      timestamp = db[dialect].insert "accounts", @default_rows[dialect][0],
                                     request_options: { tag: "Tag-CRUD-1" }
      _(timestamp).wont_be :nil?

      results = db[dialect].read "accounts", ["account_id"], single_use: { timestamp: @setup_timestamp[dialect] },
                        request_options: { tag: "Tag-CRUD-2" }
      _(results.timestamp).wont_be :nil?

      timestamp = db[dialect].update "accounts", @default_rows[dialect][0],
                                     request_options: { tag: "Tag-CRUD-2" }
      _(timestamp).wont_be :nil?

      timestamp = db[dialect].upsert "accounts", @default_rows[dialect][1],
                                     request_options: { tag: "Tag-CRUD-4" }
      _(timestamp).wont_be :nil?

      timestamp = db[dialect].delete "accounts", [1, 2, 3],
                                     request_options: { tag: "Tag-CRUD-5" }
      _(timestamp).wont_be :nil?
    end
  end
end
