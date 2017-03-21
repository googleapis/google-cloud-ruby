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

describe "Spanner Client", :streaming, :params, :spanner do
  let(:db) { spanner_client }

  it "queries and returns a string parameter" do
    results = db.execute "SELECT @value AS value", params: { value: "hello" }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.types[:value].must_equal :STRING
    results.rows.first[:value].must_equal "hello"
  end

  it "queries and returns an integer parameter" do
    results = db.execute "SELECT @value AS value", params: { value: 999 }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.types[:value].must_equal :INT64
    results.rows.first[:value].must_equal 999
  end

  it "queries and returns a float parameter" do
    results = db.execute "SELECT @value AS value", params: { value: 12.0 }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.types[:value].must_equal :FLOAT64
    results.rows.first[:value].must_equal 12.0
  end

  it "queries and returns a float parameter (Infinity)" do
    results = db.execute "SELECT @value AS value", params: { value: Float::INFINITY }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.types[:value].must_equal :FLOAT64
    results.rows.first[:value].must_equal Float::INFINITY
  end

  it "queries and returns a float parameter (-Infinity)" do
    results = db.execute "SELECT @value AS value", params: { value: -Float::INFINITY }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.types[:value].must_equal :FLOAT64
    results.rows.first[:value].must_equal -Float::INFINITY
  end

  it "queries and returns a float parameter (-NaN)" do
    results = db.execute "SELECT @value AS value", params: { value: Float::NAN }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.types[:value].must_equal :FLOAT64
    returned_value = results.rows.first[:value]
    returned_value.must_be_kind_of Float
    returned_value.must_be :nan?
  end

  it "queries and returns a boolean parameter" do
    results = db.execute "SELECT @value AS value", params: { value: false }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.types[:value].must_equal :BOOL
    results.rows.first[:value].must_equal false
  end

  it "queries and returns a date parameter" do
    today = Date.today
    results = db.execute "SELECT @value AS value", params: { value: today }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.types[:value].must_equal :DATE
    results.rows.first[:value].must_equal Date.today
  end

  it "queries and returns a datetime parameter" do
    now = Time.now.utc
    results = db.execute "SELECT @value AS value", params: { value: now.to_datetime }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.types[:value].must_equal :TIMESTAMP
    results.rows.first[:value].must_equal now
  end

  it "queries and returns a timestamp parameter" do
    now = Time.now
    results = db.execute "SELECT @value AS value", params: { value: now }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.types[:value].must_equal :TIMESTAMP
    results.rows.first[:value].must_equal now
  end

  it "queries and returns a bytes parameter" do
    results = db.execute "SELECT @value AS value", params: { value: StringIO.new("hello world!") }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.types[:value].must_equal :BYTES
    returned_value = results.rows.first[:value]
    returned_value.must_be_kind_of StringIO
    returned_value.read.must_equal "hello world!"
  end

  it "queries a string parameter and returns bytes" do
    results = db.execute "SELECT CAST(@value AS BYTES) AS value", params: { value: "hello world!" }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.types[:value].must_equal :BYTES
    returned_value = results.rows.first[:value]
    returned_value.must_be_kind_of StringIO
    returned_value.read.must_equal "hello world!"
  end

  it "queries a bytes parameter and returns string" do
    results = db.execute "SELECT CAST(@value AS STRING) AS value", params: { value: StringIO.new("hello world!") }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.types[:value].must_equal :STRING
    results.rows.first[:value].must_equal "hello world!"
  end

  it "queries and returns an array of integers parameter" do
    results = db.execute "SELECT @value AS value", params: { value: [1, 2, 3, 4] }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.types[:value].must_equal [:INT64]
    results.rows.first[:value].must_equal [1, 2, 3, 4]
  end

  it "queries and returns an array of strings parameter" do
    results = db.execute "SELECT @value AS value", params: { value: ["foo", "bar", "baz"] }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.types[:value].must_equal [:STRING]
    results.rows.first[:value].must_equal ["foo", "bar", "baz"]
  end

  it "queries and returns a struct parameter" do
    skip "Returning a STRUCT is not supported"
    # Unsupported query shape: A struct value cannot be returned as a column value.

    results = db.execute "SELECT @value AS value", params: { value: { message: "hello", repeat: 1 } }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.types[:value].must_equal :STRUCT
    results.rows.first[:value].must_equal({ message: "hello", repeat: 1 })
  end

  it "queries a struct parameter and returns string and integer" do
    skip "Sending a STRUCT was working, but now returns an error"

    results = db.execute "SELECT @value.message AS message, @value.repeat AS repeat", params: { value: { message: "hello", repeat: 1 } }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.types[:message].must_equal :STRING
    results.types[:repeat].must_equal :INT64
    returned_row = results.rows.first
    returned_row[:message].must_equal "hello"
    returned_row[:repeat].must_equal 1
  end
end
