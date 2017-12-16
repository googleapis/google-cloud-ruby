# Copyright 2017 Google LLC
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
require "concurrent"

describe "Spanner Client", :transaction, :spanner do
  let(:db) { spanner_client }
  let(:columns) { [:account_id, :username, :friends, :active, :reputation, :avatar] }
  let(:fields_hash) { { account_id: :INT64, username: :STRING, friends: [:INT64], active: :BOOL, reputation: :FLOAT64, avatar: :BYTES } }
  let(:additional_account) { { account_id: 4, username: "swcloud", reputation: 99.894, active: true, friends: [1,2] } }
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
      tx.transaction_id.wont_be :nil?

      tx_results = tx.read "accounts", columns
      tx_results.must_be_kind_of Google::Cloud::Spanner::Results
      tx_results.fields.to_h.must_equal fields_hash
      tx_results.rows.zip(default_account_rows).each do |expected, actual|
        assert_accounts_equal expected, actual
      end

      reversed_update_rows = default_account_rows.map do |row|
        { account_id: row[:account_id], username: row[:username].reverse }
      end
      tx.update "accounts", reversed_update_rows
      tx.insert "accounts", additional_account
    end
    timestamp.must_be_kind_of Time

    # outside of transaction, verify the new account was added
    results = db.read "accounts", columns
    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal fields_hash
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
      tx.transaction_id.wont_be :nil?

      tx_results = tx.read "accounts", columns
      tx_results.must_be_kind_of Google::Cloud::Spanner::Results
      tx_results.fields.to_h.must_equal fields_hash
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
    timestamp.must_be :nil?

    # outside of transaction, the new account was NOT added
    results = db.read "accounts", columns
    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal fields_hash
    results.rows.zip(default_account_rows).each do |expected, actual|
      assert_accounts_equal expected, actual
    end
  end

  it "can rollback a transaction and pass on the error" do
    assert_raises ZeroDivisionError do
      db.transaction do |tx|
        tx.transaction_id.wont_be :nil?

        tx_results = tx.read "accounts", columns
        tx_results.must_be_kind_of Google::Cloud::Spanner::Results
        tx_results.fields.to_h.must_equal fields_hash
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
    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal fields_hash
    results.rows.zip(default_account_rows).each do |expected, actual|
      assert_accounts_equal expected, actual
    end
  end

  it "supports tx isolation with read and update" do
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
        end # Thread 2 commits now
        commit_latch.count_down # Let thread 1 commit now
        # puts "commit 2"
      end
    ensure
      thr_1.join
      thr_2.join
    end

    results = db.read "accounts", [:reputation], keys: 1, limit: 1
    results.rows.first[:reputation].must_equal original_val + 2
  end

  it "supports tx isolation with query and update" do
    results = db.execute query_reputation
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

    results = db.execute query_reputation
    results.rows.first[:reputation].must_equal original_val + 2
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
      tx_results = tx.execute query_reputation
      tx_val = tx_results.rows.first[:reputation]
      sleep 1 # ensure that both threads would have read same value if not read locked
      new_val = tx_val + 1
      tx.update "accounts", [{ account_id: 1, reputation: new_val }]
    end
  end

  def assert_accounts_equal expected, actual
    if actual[:account_id].nil?
      expected[:account_id].must_be :nil?
    else
      expected[:account_id].must_equal actual[:account_id]
    end

    if actual[:username].nil?
      expected[:username].must_be :nil?
    else
      expected[:username].must_equal actual[:username]
    end

    if actual[:reputation].nil?
      expected[:reputation].must_be :nil?
    else
      expected[:reputation].must_equal actual[:reputation]
    end

    if actual[:active].nil?
      expected[:active].must_be :nil?
    else
      expected[:active].must_equal actual[:active]
    end

    if expected[:avatar] && actual[:avatar]
      expected[:avatar].read.must_equal actual[:avatar].read
    end

    if actual[:friends].nil?
      expected[:friends].must_be :nil?
    else
      expected[:friends].must_equal actual[:friends]
    end
  end
end
