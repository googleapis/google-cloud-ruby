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

describe "Spanner Client", :transaction, :spanner do
  let(:db) { spanner_client }
  let(:columns) { [:account_id, :username, :friends, :active, :reputation, :avatar] }
  let(:fields_hash) { { account_id: :INT64, username: :STRING, friends: [:INT64], active: :BOOL, reputation: :FLOAT64, avatar: :BYTES } }
  let(:additional_account) { { account_id: 4, username: "swcloud", reputation: 99.894, active: true, friends: [1,2] } }

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
    db.transaction do |tx|
      tx.transaction_id.wont_be :nil?

      tx_results = tx.read "accounts", columns
      tx_results.must_be_kind_of Google::Cloud::Spanner::Results
      tx_results.fields.to_h.must_equal fields_hash
      tx_results.rows.zip(default_account_rows).each do |expected, actual|
        assert_accounts_equal expected, actual
      end

      tx.insert "accounts", additional_account
    end

    # outside of transaction, verify the new account was added
    results = db.read "accounts", columns
    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal fields_hash
    results.rows.zip(default_account_rows + [additional_account]).each do |expected, actual|
      assert_accounts_equal expected, actual
    end
  end

  it "modifies accounts and verifies data with queries" do
    db.transaction do |tx|
      tx.transaction_id.wont_be :nil?

      tx_results = tx.execute "SELECT * FROM accounts"
      tx_results.must_be_kind_of Google::Cloud::Spanner::Results
      tx_results.fields.to_h.must_equal fields_hash
      tx_results.rows.zip(default_account_rows).each do |expected, actual|
        assert_accounts_equal expected, actual
      end

      tx.insert "accounts", additional_account
    end

    # outside of transaction, verify the new account was added
    results = db.execute "SELECT * FROM accounts ORDER BY account_id"
    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal fields_hash
    results.rows.zip(default_account_rows + [additional_account]).each do |expected, actual|
      assert_accounts_equal expected, actual
    end
  end

  it "can rollback a transaction" do
    db.transaction do |tx|
      tx.transaction_id.wont_be :nil?

      tx_results = tx.read "accounts", columns
      tx_results.must_be_kind_of Google::Cloud::Spanner::Results
      tx_results.fields.to_h.must_equal fields_hash
      tx_results.rows.zip(default_account_rows).each do |expected, actual|
        assert_accounts_equal expected, actual
      end

      tx.rollback

      tx.insert "accounts", additional_account
    end

    # outside of transaction, the new account was NOT added
    results = db.read "accounts", columns
    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal fields_hash
    results.rows.zip(default_account_rows).each do |expected, actual|
      assert_accounts_equal expected, actual
    end
  end

  it "unhandled errors will rollback the transaction" do
    assert_raises ZeroDivisionError do
      db.transaction do |tx|
        tx.transaction_id.wont_be :nil?

        tx_results = tx.read "accounts", columns
        tx_results.must_be_kind_of Google::Cloud::Spanner::Results
        tx_results.fields.to_h.must_equal fields_hash
        tx_results.rows.zip(default_account_rows).each do |expected, actual|
          assert_accounts_equal expected, actual
        end

        1 / 0

        tx.insert "accounts", additional_account
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

  def assert_accounts_equal expected, actual
    expected[:account_id].must_equal actual[:account_id]
    expected[:username].must_equal actual[:username]
    expected[:reputation].must_equal actual[:reputation]
    expected[:active].must_equal actual[:active]
    if expected[:avatar] && actual[:avatar]
      expected[:avatar].read.must_equal actual[:avatar].read
    end
    expected[:friends].must_equal actual[:friends]
  end
end
