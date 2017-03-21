# Copyright 2017 Google Inc. All rights reserved.
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

describe "Spanner Client", :non_streaming, :crud, :spanner do
  let(:db) { spanner_client }

  before do
    db.transaction do |tx|
      existing_ids = tx.read("accounts", ["account_id"]).rows.map { |row| row[:account_id] }
      tx.delete "accounts", existing_ids
    end
  end

  after do
    db.transaction do |tx|
      existing_ids = tx.read("accounts", ["account_id"]).rows.map { |row| row[:account_id] }
      tx.delete "accounts", existing_ids
    end
  end

  it "inserts, updates, upserts, reads, and deletes records" do
    db.read("accounts", ["account_id"], streaming: false).rows.count.must_equal 0

    db.insert "accounts", default_account_rows[0]
    db.upsert "accounts", default_account_rows[1]
    db.insert "accounts", default_account_rows[2]

    db.read("accounts", ["account_id"], streaming: false).rows.count.must_equal 3

    active_count_sql = "SELECT COUNT(*) AS count FROM accounts WHERE active = true"

    db.execute(active_count_sql, streaming: false).rows.first[:count].must_equal 2

    activate_inactive_account = { account_id: 3, active: true }

    db.upsert "accounts", activate_inactive_account

    db.execute(active_count_sql, streaming: false).rows.first[:count].must_equal 3

    db.delete "accounts", [1, 2, 3]

    db.read("accounts", ["account_id"], streaming: false).rows.count.must_equal 0
  end

  it "inserts, updates, upserts, reads, and deletes records using commit" do
    db.read("accounts", ["account_id"], streaming: false).rows.count.must_equal 0

    db.commit do |c|
      c.insert "accounts", default_account_rows[0]
      c.upsert "accounts", default_account_rows[1]
      c.insert "accounts", default_account_rows[2]
    end

    db.read("accounts", ["account_id"], streaming: false).rows.count.must_equal 3

    active_count_sql = "SELECT COUNT(*) AS count FROM accounts WHERE active = true"

    db.execute(active_count_sql, streaming: false).rows.first[:count].must_equal 2

    activate_inactive_account = { account_id: 3, active: true }

    db.commit do |c|
      c.upsert "accounts", activate_inactive_account
    end

    db.execute(active_count_sql, streaming: false).rows.first[:count].must_equal 3

    db.commit do |c|
      c.delete "accounts", [1, 2, 3]
    end

    db.read("accounts", ["account_id"], streaming: false).rows.count.must_equal 0
  end

  it "inserts, updates, upserts, reads, and deletes records in a transaction" do
    active_count_sql = "SELECT COUNT(*) AS count FROM accounts WHERE active = true"

    db.transaction do |tx|
      tx.read("accounts", ["account_id"], streaming: false).rows.count.must_equal 0

      tx.commit do |c|
        c.insert "accounts", default_account_rows[0]
        c.upsert "accounts", default_account_rows[1]
        c.insert "accounts", default_account_rows[2]
      end
    end

    db.transaction do |tx|
      db.read("accounts", ["account_id"], streaming: false).rows.count.must_equal 3

      tx.execute(active_count_sql).rows.first[:count].must_equal 2

      activate_inactive_account = { account_id: 3, active: true }

      tx.upsert "accounts", activate_inactive_account
    end

    db.transaction do |tx|
      tx.execute(active_count_sql, streaming: false).rows.first[:count].must_equal 3

      tx.delete "accounts", [1, 2, 3]
    end

    db.read("accounts", ["account_id"], streaming: false).rows.count.must_equal 0
  end

  it "inserts, updates, upserts, reads, and deletes records in a transaction using commit" do
    active_count_sql = "SELECT COUNT(*) AS count FROM accounts WHERE active = true"

    db.transaction do |tx|
      tx.read("accounts", ["account_id"], streaming: false).rows.count.must_equal 0

      tx.commit do |c|
        c.insert "accounts", default_account_rows[0]
        c.upsert "accounts", default_account_rows[1]
        c.insert "accounts", default_account_rows[2]
      end
    end

    db.transaction do |tx|
      tx.read("accounts", ["account_id"], streaming: false).rows.count.must_equal 3

      tx.execute(active_count_sql, streaming: false).rows.first[:count].must_equal 2

      activate_inactive_account = { account_id: 3, active: true }

      tx.commit do |c|
        c.upsert "accounts", activate_inactive_account
      end
    end

    db.transaction do |tx|
      tx.execute(active_count_sql, streaming: false).rows.first[:count].must_equal 3

      tx.commit do |c|
        c.delete "accounts", [1, 2, 3]
      end
    end

    db.read("accounts", ["account_id"], streaming: false).rows.count.must_equal 0
  end
end
