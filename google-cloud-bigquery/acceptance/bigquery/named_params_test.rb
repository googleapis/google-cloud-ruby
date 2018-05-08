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

require "bigquery_helper"

describe Google::Cloud::Bigquery, :named_params, :bigquery do
  it "queries the data with a string parameter" do
    rows = bigquery.query "SELECT @value AS value", params: { value: "hello" }

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.count.must_equal 1
    rows.first[:value].must_equal "hello"
  end

  it "queries the data with an integer parameter" do
    rows = bigquery.query "SELECT @value AS value", params: { value: 999 }

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.count.must_equal 1
    rows.first[:value].must_equal 999
  end

  it "queries the data with a float parameter" do
    rows = bigquery.query "SELECT @value AS value", params: { value: 12.0 }

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.count.must_equal 1
    rows.first[:value].must_equal 12.0
  end

  it "queries the data with a numeric parameter" do
    rows = bigquery.query "SELECT @value AS value", params: { value: BigDecimal("123456789.123456789") }

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.count.must_equal 1
    rows.first[:value].must_equal BigDecimal("123456789.123456789")
  end

  it "queries the data with a boolean parameter" do
    rows = bigquery.query "SELECT @value AS value", params: { value: false }

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.count.must_equal 1
    rows.first[:value].must_equal false
  end

  it "queries the data with a date parameter" do
    today = Date.today
    rows = bigquery.query "SELECT @value AS value", params: { value: today }

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.count.must_equal 1
    rows.first[:value].must_equal Date.today
  end

  it "queries the data with a datetime parameter" do
    now = Time.now.utc.to_datetime
    rows = bigquery.query "SELECT @value AS value", params: { value: now }

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.count.must_equal 1
    rows.first[:value].must_be_kind_of DateTime
    rows.first[:value].must_be_close_to now
    # rows.first[:value].must_equal now.to_s
  end

  it "queries the data with a timestamp parameter" do
    now = Time.now
    rows = bigquery.query "SELECT @value AS value", params: { value: now }

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.count.must_equal 1
    rows.first[:value].must_be_kind_of ::Time
    rows.first[:value].must_be_close_to now
  end

  it "queries the data with a time parameter" do
    rows = bigquery.query "SELECT @value AS value", params: { value: bigquery.time(12, 30, 0) }

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.count.must_equal 1
    rows.first[:value].must_be_kind_of Google::Cloud::Bigquery::Time
    rows.first[:value].value.must_equal "12:30:00"
  end

  it "queries the data with a bytes parameter" do
    rows = bigquery.query "SELECT @value AS value", params: { value: StringIO.new("hello world!") }

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.count.must_equal 1
    rows.first[:value].must_be_kind_of StringIO
    rows.first[:value].read.must_equal "hello world!"
  end

  it "queries the data with an array of integers parameter" do
    rows = bigquery.query "SELECT @value AS value", params: { value: [1, 2, 3, 4] }

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.count.must_equal 1
    rows.first[:value].must_equal [1, 2, 3, 4]
  end

  it "queries the data with an array of strings parameter" do
    rows = bigquery.query "SELECT @value AS value", params: { value: ["foo", "bar", "baz"] }

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.count.must_equal 1
    rows.first[:value].must_equal ["foo", "bar", "baz"]
  end

  it "queries the data with a struct parameter" do
    rows = bigquery.query "SELECT @hitchhiker.message, @hitchhiker.repeat", params: { hitchhiker: { message: "hello", repeat: 1 } }

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.count.must_equal 1
    rows.first.must_equal({ message: "hello", repeat: 1 })
  end
end
