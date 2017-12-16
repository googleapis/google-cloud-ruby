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

describe "Spanner Client", :snapshot, :spanner do
  let(:db) { spanner_client }
  let(:columns) { [:account_id, :username, :friends, :active, :reputation, :avatar] }
  let(:fields_hash) { { account_id: :INT64, username: :STRING, friends: [:INT64], active: :BOOL, reputation: :FLOAT64, avatar: :BYTES } }

  before do
    @setup_timestamp = db.commit do |c|
      c.delete "accounts"
      c.insert "accounts", default_account_rows
    end
  end

  after do
    db.delete "accounts"
  end

  it "runs a query" do
    results = nil
    db.snapshot do |snp|
      snp.transaction_id.wont_be :nil?
      snp.timestamp.wont_be :nil?
      snp.timestamp.must_be_close_to Time.now, 3 # within 3 seconds?

      results = snp.execute "SELECT * FROM accounts"
    end

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal fields_hash
    results.rows.zip(default_account_rows).each do |expected, actual|
      assert_accounts_equal expected, actual
    end
  end

  it "runs a read" do
    results = nil
    db.snapshot do |snp|
      snp.transaction_id.wont_be :nil?
      snp.timestamp.wont_be :nil?
      snp.timestamp.must_be_close_to Time.now, 3 # within 3 seconds?

      results = snp.read "accounts", columns
    end

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal fields_hash
    results.rows.zip(default_account_rows).each do |expected, actual|
      assert_accounts_equal expected, actual
    end
  end

  it "runs a query with strong option" do
    results = nil
    db.snapshot strong: true do |snp|
      snp.transaction_id.wont_be :nil?
      snp.timestamp.wont_be :nil?
      snp.timestamp.must_be_close_to Time.now, 3 # within 3 seconds?

      results = snp.execute "SELECT * FROM accounts"
    end

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal fields_hash
    results.rows.zip(default_account_rows).each do |expected, actual|
      assert_accounts_equal expected, actual
    end
  end

  it "runs a read with strong option" do
    results = nil
    db.snapshot strong: true do |snp|
      snp.transaction_id.wont_be :nil?
      snp.timestamp.wont_be :nil?
      snp.timestamp.must_be_close_to Time.now, 3 # within 3 seconds?

      results = snp.read "accounts", columns
    end

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal fields_hash
    results.rows.zip(default_account_rows).each do |expected, actual|
      assert_accounts_equal expected, actual
    end
  end

  it "runs a query with timestamp option" do
    results = nil
    db.snapshot timestamp: @setup_timestamp do |snp|
      snp.transaction_id.wont_be :nil?
      snp.timestamp.wont_be :nil?
      snp.timestamp.must_be_close_to Time.now, 3 # within 3 seconds?

      results = snp.execute "SELECT * FROM accounts"
    end

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal fields_hash
    results.rows.zip(default_account_rows).each do |expected, actual|
      assert_accounts_equal expected, actual
    end
  end

  it "runs a read with timestamp option" do
    results = nil
    db.snapshot timestamp: @setup_timestamp do |snp|
      snp.transaction_id.wont_be :nil?
      snp.timestamp.wont_be :nil?
      snp.timestamp.must_be_close_to Time.now, 3 # within 3 seconds?

      results = snp.read "accounts", columns
    end

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal fields_hash
    results.rows.zip(default_account_rows).each do |expected, actual|
      assert_accounts_equal expected, actual
    end
  end

  it "runs a query with staleness option" do
    results = nil
    db.snapshot staleness: 0.0001 do |snp|
      snp.transaction_id.wont_be :nil?
      snp.timestamp.wont_be :nil?
      snp.timestamp.must_be_close_to Time.now, 3 # within 3 seconds?

      results = snp.execute "SELECT * FROM accounts"
    end

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal fields_hash
    results.rows.zip(default_account_rows).each do |expected, actual|
      assert_accounts_equal expected, actual
    end
  end

  it "runs a read with staleness option" do
    results = nil
    db.snapshot staleness: 0.0001 do |snp|
      snp.transaction_id.wont_be :nil?
      snp.timestamp.wont_be :nil?
      snp.timestamp.must_be_close_to Time.now, 3 # within 3 seconds?

      results = snp.read "accounts", columns
    end

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal fields_hash
    results.rows.zip(default_account_rows).each do |expected, actual|
      assert_accounts_equal expected, actual
    end
  end

  it "strong reads are consistent even when updates happen" do
    first_row = default_account_rows.first
    sample_row = { account_id: first_row[:account_id], username: first_row[:username] }
    modified_row = { account_id: first_row[:account_id], username: first_row[:username].reverse }

    db.snapshot strong: true do |snp|
      snp.transaction_id.wont_be :nil?
      snp.timestamp.wont_be :nil?
      snp.timestamp.must_be_close_to Time.now, 3 # within 3 seconds?

      results = snp.read "accounts", [:account_id, :username], keys: sample_row[:account_id]
      # verify we got the row we were expecting
      results.rows.first.to_h.must_equal sample_row

      # outside of the snapshot, update the row!
      db.update "accounts", modified_row

      results2 = snp.read "accounts", [:account_id, :username], keys: modified_row[:account_id]
      # verify we got the previous row, not the modified row
      results2.rows.first.to_h.must_equal sample_row
    end
  end

  it "strong queries are consistent even when updates happen" do
    first_row = default_account_rows.first
    sample_row = { account_id: first_row[:account_id], username: first_row[:username] }
    modified_row = { account_id: first_row[:account_id], username: first_row[:username].reverse }

    db.snapshot strong: true do |snp|
      snp.transaction_id.wont_be :nil?
      snp.timestamp.wont_be :nil?
      snp.timestamp.must_be_close_to Time.now, 3 # within 3 seconds?

      results = snp.execute "SELECT account_id, username FROM accounts WHERE account_id = @id", params: { id: sample_row[:account_id] }
      # verify we got the row we were expecting
      results.rows.first.to_h.must_equal sample_row

      # outside of the snapshot, update the row!
      db.update "accounts", modified_row

      results2 = snp.execute "SELECT account_id, username FROM accounts WHERE account_id = @id", params: { id: modified_row[:account_id] }
      # verify we got the previous row, not the modified row
      results2.rows.first.to_h.must_equal sample_row
    end
  end

  it "timestamp reads are consistent even when updates happen" do
    first_row = default_account_rows.first
    sample_row = { account_id: first_row[:account_id], username: first_row[:username] }
    modified_row = { account_id: first_row[:account_id], username: first_row[:username].reverse }

    db.snapshot timestamp: @setup_timestamp do |snp|
      snp.transaction_id.wont_be :nil?
      snp.timestamp.wont_be :nil?
      snp.timestamp.must_be_close_to Time.now, 3 # within 3 seconds?

      results = snp.read "accounts", [:account_id, :username], keys: sample_row[:account_id]
      # verify we got the row we were expecting
      results.rows.first.to_h.must_equal sample_row

      # outside of the snapshot, update the row!
      db.update "accounts", modified_row

      results2 = snp.read "accounts", [:account_id, :username], keys: modified_row[:account_id]
      # verify we got the previous row, not the modified row
      results2.rows.first.to_h.must_equal sample_row
    end
  end

  it "timestamp queries are consistent even when updates happen" do
    first_row = default_account_rows.first
    sample_row = { account_id: first_row[:account_id], username: first_row[:username] }
    modified_row = { account_id: first_row[:account_id], username: first_row[:username].reverse }

    db.snapshot timestamp: @setup_timestamp do |snp|
      snp.transaction_id.wont_be :nil?
      snp.timestamp.wont_be :nil?
      snp.timestamp.must_be_close_to Time.now, 3 # within 3 seconds?

      results = snp.execute "SELECT account_id, username FROM accounts WHERE account_id = @id", params: { id: sample_row[:account_id] }
      # verify we got the row we were expecting
      results.rows.first.to_h.must_equal sample_row

      # outside of the snapshot, update the row!
      db.update "accounts", modified_row

      results2 = snp.execute "SELECT account_id, username FROM accounts WHERE account_id = @id", params: { id: modified_row[:account_id] }
      # verify we got the previous row, not the modified row
      results2.rows.first.to_h.must_equal sample_row
    end
  end

  it "staleness reads are consistent even when updates happen" do
    first_row = default_account_rows.first
    sample_row = { account_id: first_row[:account_id], username: first_row[:username] }
    modified_row = { account_id: first_row[:account_id], username: first_row[:username].reverse }

    db.snapshot staleness: 0.01 do |snp|
      snp.transaction_id.wont_be :nil?
      snp.timestamp.wont_be :nil?
      snp.timestamp.must_be_close_to Time.now, 3 # within 3 seconds?

      results = snp.read "accounts", [:account_id, :username], keys: sample_row[:account_id]
      # verify we got the row we were expecting
      results.rows.first.to_h.must_equal sample_row

      # outside of the snapshot, update the row!
      db.update "accounts", modified_row

      results2 = snp.read "accounts", [:account_id, :username], keys: modified_row[:account_id]
      # verify we got the previous row, not the modified row
      results2.rows.first.to_h.must_equal sample_row
    end
  end

  it "staleness queries are consistent even when updates happen" do
    first_row = default_account_rows.first
    sample_row = { account_id: first_row[:account_id], username: first_row[:username] }
    modified_row = { account_id: first_row[:account_id], username: first_row[:username].reverse }

    db.snapshot staleness: 0.01 do |snp|
      snp.transaction_id.wont_be :nil?
      snp.timestamp.wont_be :nil?
      snp.timestamp.must_be_close_to Time.now, 3 # within 3 seconds?

      results = snp.execute "SELECT account_id, username FROM accounts WHERE account_id = @id", params: { id: sample_row[:account_id] }
      # verify we got the row we were expecting
      results.rows.first.to_h.must_equal sample_row

      # outside of the snapshot, update the row!
      db.update "accounts", modified_row

      results2 = snp.execute "SELECT account_id, username FROM accounts WHERE account_id = @id", params: { id: modified_row[:account_id] }
      # verify we got the previous row, not the modified row
      results2.rows.first.to_h.must_equal sample_row
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
