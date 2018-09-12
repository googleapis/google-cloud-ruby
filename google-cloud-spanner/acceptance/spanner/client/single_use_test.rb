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

describe "Spanner Client", :single_use, :spanner do
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

  it "runs a query with strong option" do
    results = db.execute_sql "SELECT * FROM accounts", single_use: { strong: true }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal fields_hash
    results.rows.zip(default_account_rows).each do |expected, actual|
      assert_accounts_equal expected, actual
    end

    results.timestamp.wont_be :nil?
    results.timestamp.must_be_close_to @setup_timestamp, 3 # within 3 seconds?
  end

  it "runs a read with strong option" do
    results = db.read "accounts", columns, single_use: { strong: true }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal fields_hash
    results.rows.zip(default_account_rows).each do |expected, actual|
      assert_accounts_equal expected, actual
    end

    results.timestamp.wont_be :nil?
    results.timestamp.must_be_close_to @setup_timestamp, 3 # within 3 seconds?
  end

  it "runs a query with timestamp option" do
    results = db.execute_sql "SELECT * FROM accounts", single_use: { timestamp: @setup_timestamp }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal fields_hash
    results.rows.zip(default_account_rows).each do |expected, actual|
      assert_accounts_equal expected, actual
    end

    results.timestamp.wont_be :nil?
    results.timestamp.must_be_close_to @setup_timestamp, 1
  end

  it "runs a read with timestamp option" do
    results = db.read "accounts", columns, single_use: { timestamp: @setup_timestamp }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal fields_hash
    results.rows.zip(default_account_rows).each do |expected, actual|
      assert_accounts_equal expected, actual
    end

    results.timestamp.wont_be :nil?
    results.timestamp.must_be_close_to @setup_timestamp, 1
  end

  it "runs a query with staleness option" do
    results = db.execute_sql "SELECT * FROM accounts", single_use: { staleness: 0.0001 }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal fields_hash
    results.rows.zip(default_account_rows).each do |expected, actual|
      assert_accounts_equal expected, actual
    end

    results.timestamp.wont_be :nil?
    results.timestamp.must_be_close_to @setup_timestamp, 3 # within 3 seconds?
  end

  it "runs a read with staleness option" do
    results = db.read "accounts", columns, single_use: { staleness: 0.0001 }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal fields_hash
    results.rows.zip(default_account_rows).each do |expected, actual|
      assert_accounts_equal expected, actual
    end

    results.timestamp.wont_be :nil?
    results.timestamp.must_be_close_to @setup_timestamp, 3 # within 3 seconds?
  end

  it "runs a query with bounded_timestamp option" do
    results = db.execute_sql "SELECT * FROM accounts", single_use: { bounded_timestamp: @setup_timestamp }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal fields_hash
    results.rows.zip(default_account_rows).each do |expected, actual|
      assert_accounts_equal expected, actual
    end

    results.timestamp.wont_be :nil?
    results.timestamp.must_be_close_to @setup_timestamp, 3 # within 3 seconds?
  end

  it "runs a read with bounded_timestamp option" do
    results = db.read "accounts", columns, single_use: { bounded_timestamp: @setup_timestamp }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal fields_hash
    results.rows.zip(default_account_rows).each do |expected, actual|
      assert_accounts_equal expected, actual
    end

    results.timestamp.wont_be :nil?
    results.timestamp.must_be_close_to @setup_timestamp, 3 # within 3 seconds?
  end

  it "runs a query with bounded_staleness option" do
    results = db.execute_sql "SELECT * FROM accounts", single_use: { bounded_staleness: 0.0001 }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal fields_hash
    results.rows.zip(default_account_rows).each do |expected, actual|
      assert_accounts_equal expected, actual
    end

    results.timestamp.wont_be :nil?
    results.timestamp.must_be_close_to @setup_timestamp, 3 # within 3 seconds?
  end

  it "runs a read with bounded_staleness option" do
    results = db.read "accounts", columns, single_use: { bounded_staleness: 0.0001 }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal fields_hash
    results.rows.zip(default_account_rows).each do |expected, actual|
      assert_accounts_equal expected, actual
    end

    results.timestamp.wont_be :nil?
    results.timestamp.must_be_close_to @setup_timestamp, 3 # within 3 seconds?
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
