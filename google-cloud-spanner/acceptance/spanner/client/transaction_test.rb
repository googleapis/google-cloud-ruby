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
require "concurrent"

describe "Spanner Client", :transaction, :spanner do
  let(:db) { spanner_client }
  let(:columns) { [:account_id, :username, :friends, :active, :reputation, :avatar] }
  let :fields_hash do
    { account_id: :INT64, username: :STRING, friends: [:INT64], active: :BOOL, reputation: :FLOAT64, avatar: :BYTES }
  end
  let(:additional_account) { { account_id: 4, username: "swcloud", reputation: 99.894, active: true, friends: [1, 2] } }
  let(:query_reputation) { "SELECT reputation FROM accounts WHERE account_id = 1 LIMIT 1" }

  before do
    db.commit do |c|
      c.delete "accounts"
      c.insert "accounts", default_account_rows
    end
  end

  after do
    db.delete "accounts"
  end

  it "modifies accounts and verifies data with reads" do
    timestamp = db.transaction do |tx|
      _(tx.transaction_id).wont_be :nil?

      tx_results = tx.read "accounts", columns
      _(tx_results).must_be_kind_of Google::Cloud::Spanner::Results
      _(tx_results.fields.to_h).must_equal fields_hash
      tx_results.rows.zip(default_account_rows).each do |expected, actual|
        assert_accounts_equal expected, actual
      end

      reversed_update_rows = default_account_rows.map do |row|
        { account_id: row[:account_id], username: row[:username].reverse }
      end
      tx.update "accounts", reversed_update_rows
      tx.insert "accounts", additional_account
    end
    _(timestamp).must_be_kind_of Time

    # outside of transaction, verify the new account was added
    results = db.read "accounts", columns
    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields.to_h).must_equal fields_hash
    # new data fixtures to match updated rows
    reversed_account_rows = default_account_rows.map do |row|
      row[:username] = row[:username].reverse
      row
    end
    results.rows.zip(reversed_account_rows + [additional_account]).each do |expected, actual|
      assert_accounts_equal expected, actual
    end
  end

  it "can rollback a transaction without passing on using Rollback" do
    timestamp = db.transaction do |tx|
      _(tx.transaction_id).wont_be :nil?

      tx_results = tx.read "accounts", columns
      _(tx_results).must_be_kind_of Google::Cloud::Spanner::Results
      _(tx_results.fields.to_h).must_equal fields_hash
      tx_results.rows.zip(default_account_rows).each do |expected, actual|
        assert_accounts_equal expected, actual
      end

      reversed_account_rows = default_account_rows.map do |row|
        { id: row[:id], username: row[:username].reverse }
      end
      tx.upsert "accounts", reversed_account_rows
      tx.insert "accounts", additional_account

      raise Google::Cloud::Spanner::Rollback
    end
    _(timestamp).must_be :nil?

    # outside of transaction, the new account was NOT added
    results = db.read "accounts", columns
    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields.to_h).must_equal fields_hash
    results.rows.zip(default_account_rows).each do |expected, actual|
      assert_accounts_equal expected, actual
    end
  end

  it "can rollback a transaction and pass on the error" do
    assert_raises ZeroDivisionError do
      db.transaction do |tx|
        _(tx.transaction_id).wont_be :nil?

        tx_results = tx.read "accounts", columns
        _(tx_results).must_be_kind_of Google::Cloud::Spanner::Results
        _(tx_results.fields.to_h).must_equal fields_hash
        tx_results.rows.zip(default_account_rows).each do |expected, actual|
          assert_accounts_equal expected, actual
        end

        reversed_account_rows = default_account_rows.map do |row|
          { id: row[:id], username: row[:username].reverse }
        end
        tx.upsert "accounts", reversed_account_rows
        tx.insert "accounts", additional_account

        1 / 0
      end
    end

    # outside of transaction, the new account was NOT added
    results = db.read "accounts", columns
    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields.to_h).must_equal fields_hash
    results.rows.zip(default_account_rows).each do |expected, actual|
      assert_accounts_equal expected, actual
    end
  end

  it "supports tx isolation with read and update" do
    skip "The emulator only supports one transaction at a time" if emulator_enabled?

    results = db.read "accounts", [:reputation], keys: 1, limit: 1
    original_val = results.rows.first[:reputation]
    begin
      read_latch = Concurrent::CountDownLatch.new 1
      commit_latch = Concurrent::CountDownLatch.new 1
      thr_1 = Thread.new do
        db.transaction do |tx|
          tx_results = tx.read "accounts", [:reputation], keys: 1, limit: 1
          tx_val = tx_results.rows.first[:reputation]
          # puts "read 1: #{tx_val}"
          read_latch.count_down # Let thread 2 read now
          commit_latch.wait # Let thread 2 read second but write and commit first
          new_val = tx_val + 1
          tx.update "accounts", [{ account_id: 1, reputation: new_val }]
          # puts "write 1"
        end
        # puts "commit 1"
      end
      thr_2 = Thread.new do
        db.transaction do |tx|
          read_latch.wait # Let thread 1 read first
          tx_results = tx.read "accounts", [:reputation], keys: 1, limit: 1
          tx_val = tx_results.rows.first[:reputation]
          # puts "read 2: #{tx_val}"
          new_val = tx_val + 1
          tx.update "accounts", [{ account_id: 1, reputation: new_val }]
          # puts "write 2"
        end
        commit_latch.count_down # Let thread 1 commit now
        # puts "commit 2"
      end
    ensure
      thr_1.join
      thr_2.join
    end

    results = db.read "accounts", [:reputation], keys: 1, limit: 1
    _(results.rows.first[:reputation]).must_equal original_val + 2
  end

  it "supports tx isolation with query and update" do
    results = db.execute_sql query_reputation
    original_val = results.rows.first[:reputation]
    begin
      thr_1 = Thread.new do
        query_and_update db
      end
      thr_2 = Thread.new do
        query_and_update db
      end
    ensure
      thr_1.join
      thr_2.join
    end

    results = db.execute_sql query_reputation
    _(results.rows.first[:reputation]).must_equal original_val + 2
  end

  it "execute transaction with tagging options" do
    timestamp = db.transaction request_options: { tag: "Tag-1" } do |tx|
      tx.execute_query "SELECT * from accounts", request_options: { tag: "Tag-1-1" }
      tx.batch_update request_options: { tag: "Tag-1-2" } do |b|
        b.batch_update(
          "UPDATE accounts SET username = 'Charlie' WHERE account_id = 1"
        )
      end

      tx.read "accounts", columns, request_options: { tag: "Tag-1-3" }
      tx.insert "accounts", additional_account
    end

    _(timestamp).must_be_kind_of Time
  end

  it "can execute sql with query options" do
    query_options = { optimizer_version: "3", optimizer_statistics_package: "latest" }
    db.transaction do |tx|
      tx_results = tx.execute_sql query_reputation, query_options: query_options
      _(tx_results.rows.first[:reputation]).must_equal 63.5
    end
  end

  it "execute transaction and return commit stats" do
    skip if emulator_enabled?

    commit_options = { return_commit_stats: true }
    commit_resp = db.transaction commit_options: commit_options do |tx|
      _(tx.transaction_id).wont_be :nil?

      tx.insert "accounts", additional_account
    end

    assert_commit_response commit_resp, commit_options
  end

  describe "request options" do
    it "execute transaction with priority options" do
      timestamp = db.transaction request_options: { priority: :PRIORITY_MEDIUM } do |tx|
        tx_results = tx.read "accounts", columns
        _(tx_results.rows.count).must_equal default_account_rows.length
        tx.insert "accounts", additional_account
      end
      _(timestamp).must_be_kind_of Time
    end

    it "execute query with priority options" do
      timestamp = db.transaction do |tx|
        tx_results = tx.execute_sql query_reputation,
                                    request_options: { priority: :PRIORITY_MEDIUM }
        _(tx_results.rows.count).must_be :>, 0
      end
      _(timestamp).must_be_kind_of Time
    end
  end

  def read_and_update db
    db.transaction do |tx|
      tx_results = tx.read "accounts", [:reputation], keys: 1, limit: 1
      tx_val = tx_results.rows.first[:reputation]
      sleep 1 # ensure that both threads would have read same value if not read locked
      new_val = tx_val + 1
      tx.update "accounts", [{ account_id: 1, reputation: new_val }]
    end
  end

  def query_and_update db
    db.transaction do |tx|
      tx_results = tx.execute_sql query_reputation
      tx_val = tx_results.rows.first[:reputation]
      sleep 1 # ensure that both threads would have read same value if not read locked
      new_val = tx_val + 1
      tx.update "accounts", [{ account_id: 1, reputation: new_val }]
    end
  end

  def assert_accounts_equal expected, actual
    if actual[:account_id].nil?
      _(expected[:account_id]).must_be :nil?
    else
      _(expected[:account_id]).must_equal actual[:account_id]
    end

    if actual[:username].nil?
      _(expected[:username]).must_be :nil?
    else
      _(expected[:username]).must_equal actual[:username]
    end

    if actual[:reputation].nil?
      _(expected[:reputation]).must_be :nil?
    else
      _(expected[:reputation]).must_equal actual[:reputation]
    end

    if actual[:active].nil?
      _(expected[:active]).must_be :nil?
    else
      _(expected[:active]).must_equal actual[:active]
    end

    if expected[:avatar] && actual[:avatar]
      _(expected[:avatar].read).must_equal actual[:avatar].read
    end

    if actual[:friends].nil?
      _(expected[:friends]).must_be :nil?
    else
      _(expected[:friends]).must_equal actual[:friends]
    end
  end
end
