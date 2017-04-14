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

describe "Spanner Client", :streaming, :snapshot, :spanner do
  let(:db) { spanner.client $spanner_prefix, "main" }

  before do
    db.transaction do |tx|
      existing_ids = tx.read("accounts", ["account_id"]).rows.map { |row| row[:account_id] }
      tx.delete "accounts", existing_ids
    end
    db.insert "accounts", default_account_rows
  end

  after do
    db.transaction do |tx|
      existing_ids = tx.read("accounts", ["account_id"]).rows.map { |row| row[:account_id] }
      tx.delete "accounts", existing_ids
    end
  end

  it "runs a query" do
    results = nil
    db.snapshot do |snp|
      results = snp.execute "SELECT * FROM accounts"
    end
    results.must_be_kind_of Google::Cloud::Spanner::Results

    results.types.must_equal({:account_id=>:INT64, :username=>:STRING, :friends=>[:INT64], :active=>:BOOL, :reputation=>:FLOAT64, :avatar=>:BYTES})

    results.rows.zip(default_account_rows).each do |expected, actual|
      assert_accounts_equal expected, actual
    end
  end

  it "runs a read" do
    results = nil
    db.snapshot do |snp|
      results = snp.read "accounts", [:account_id, :username, :friends, :active, :reputation, :avatar]
    end
    results.must_be_kind_of Google::Cloud::Spanner::Results

    results.types.must_equal({:account_id=>:INT64, :username=>:STRING, :friends=>[:INT64], :active=>:BOOL, :reputation=>:FLOAT64, :avatar=>:BYTES})

    results.rows.zip(default_account_rows).each do |expected, actual|
      assert_accounts_equal expected, actual
    end
  end

  it "runs a query with strong option" do
    results = nil
    db.snapshot strong: true do |snp|
      results = snp.execute "SELECT * FROM accounts"
    end
    results.must_be_kind_of Google::Cloud::Spanner::Results

    results.types.must_equal({:account_id=>:INT64, :username=>:STRING, :friends=>[:INT64], :active=>:BOOL, :reputation=>:FLOAT64, :avatar=>:BYTES})

    results.rows.zip(default_account_rows).each do |expected, actual|
      assert_accounts_equal expected, actual
    end
  end

  it "runs a read with strong option" do
    results = nil
    db.snapshot strong: true do |snp|
      results = snp.read "accounts", [:account_id, :username, :friends, :active, :reputation, :avatar]
    end
    results.must_be_kind_of Google::Cloud::Spanner::Results

    results.types.must_equal({:account_id=>:INT64, :username=>:STRING, :friends=>[:INT64], :active=>:BOOL, :reputation=>:FLOAT64, :avatar=>:BYTES})

    results.rows.zip(default_account_rows).each do |expected, actual|
      assert_accounts_equal expected, actual
    end
  end

  it "runs a query with timestamp option" do
    results = nil
    sleep 1
    db.snapshot timestamp: (Time.now - 1) do |snp|
      results = snp.execute "SELECT * FROM accounts"
    end
    results.must_be_kind_of Google::Cloud::Spanner::Results

    results.types.must_equal({:account_id=>:INT64, :username=>:STRING, :friends=>[:INT64], :active=>:BOOL, :reputation=>:FLOAT64, :avatar=>:BYTES})

    results.rows.zip(default_account_rows).each do |expected, actual|
      assert_accounts_equal expected, actual
    end
  end

  it "runs a read with timestamp option" do
    results = nil
    sleep 1
    db.snapshot timestamp: (Time.now - 1) do |snp|
      results = snp.read "accounts", [:account_id, :username, :friends, :active, :reputation, :avatar]
    end
    results.must_be_kind_of Google::Cloud::Spanner::Results

    results.types.must_equal({:account_id=>:INT64, :username=>:STRING, :friends=>[:INT64], :active=>:BOOL, :reputation=>:FLOAT64, :avatar=>:BYTES})

    results.rows.zip(default_account_rows).each do |expected, actual|
      assert_accounts_equal expected, actual
    end
  end

  it "runs a query with staleness option" do
    results = nil
    sleep 1
    db.snapshot staleness: 1 do |snp|
      results = snp.execute "SELECT * FROM accounts"
    end
    results.must_be_kind_of Google::Cloud::Spanner::Results

    results.types.must_equal({:account_id=>:INT64, :username=>:STRING, :friends=>[:INT64], :active=>:BOOL, :reputation=>:FLOAT64, :avatar=>:BYTES})

    results.rows.zip(default_account_rows).each do |expected, actual|
      assert_accounts_equal expected, actual
    end
  end

  it "runs a read with staleness option" do
    results = nil
    sleep 1
    db.snapshot staleness: 1 do |snp|
      results = snp.read "accounts", [:account_id, :username, :friends, :active, :reputation, :avatar]
    end
    results.must_be_kind_of Google::Cloud::Spanner::Results

    results.types.must_equal({:account_id=>:INT64, :username=>:STRING, :friends=>[:INT64], :active=>:BOOL, :reputation=>:FLOAT64, :avatar=>:BYTES})

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
