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

describe Google::Cloud::Bigquery, :positional_params, :bigquery do
  it "queries the data with a string parameter" do
    rows = bigquery.query "SELECT ? AS value", params: ["hello"]

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.fields.count.must_equal 1
    rows.fields.first.name.must_equal "value"
    rows.fields.first.must_be :string?
    rows.count.must_equal 1
    rows.first[:value].must_equal "hello"
  end

  it "queries the data with a nil parameter and string type" do
    rows = bigquery.query "SELECT ? AS value", params: [nil], types: [:STRING]

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.fields.count.must_equal 1
    rows.fields.first.name.must_equal "value"
    rows.fields.first.must_be :string?
    rows.count.must_equal 1
    rows.first[:value].must_be_nil
  end

  it "queries the data with an integer parameter" do
    rows = bigquery.query "SELECT ? AS value", params: [999]

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.fields.count.must_equal 1
    rows.fields.first.name.must_equal "value"
    rows.fields.first.must_be :integer?
    rows.count.must_equal 1
    rows.first[:value].must_equal 999
  end

  it "queries the data with a nil parameter and integer type" do
    rows = bigquery.query "SELECT ? AS value", params: [nil], types: [:INT64]

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.fields.count.must_equal 1
    rows.fields.first.name.must_equal "value"
    rows.fields.first.must_be :integer?
    rows.count.must_equal 1
    rows.first[:value].must_be_nil
  end

  it "queries the data with a float parameter" do
    rows = bigquery.query "SELECT ? AS value", params: [12.0]

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.fields.count.must_equal 1
    rows.fields.first.name.must_equal "value"
    rows.fields.first.must_be :float?
    rows.count.must_equal 1
    rows.first[:value].must_equal 12.0
  end

  it "queries the data with a nil parameter and float type" do
    rows = bigquery.query "SELECT ? AS value", params: [nil], types: [:FLOAT64]

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.fields.count.must_equal 1
    rows.fields.first.name.must_equal "value"
    rows.fields.first.must_be :float?
    rows.count.must_equal 1
    rows.first[:value].must_be_nil
  end

  it "queries the data with a numeric parameter" do
    rows = bigquery.query "SELECT ? AS value", params: [BigDecimal("123456789.123456789")]

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.fields.count.must_equal 1
    rows.fields.first.name.must_equal "value"
    rows.fields.first.must_be :numeric?
    rows.count.must_equal 1
    rows.first[:value].must_equal BigDecimal("123456789.123456789")
  end

  it "queries the data with a nil parameter and numeric type" do
    rows = bigquery.query "SELECT ? AS value", params: [nil], types: [:NUMERIC]

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.fields.count.must_equal 1
    rows.fields.first.name.must_equal "value"
    rows.fields.first.must_be :numeric?
    rows.count.must_equal 1
    rows.first[:value].must_be_nil
  end

  it "queries the data with a boolean parameter" do
    rows = bigquery.query "SELECT ? AS value", params: [false]

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.fields.count.must_equal 1
    rows.fields.first.name.must_equal "value"
    rows.fields.first.must_be :boolean?
    rows.count.must_equal 1
    rows.first[:value].must_equal false
  end

  it "queries the data with a nil parameter and boolean type" do
    rows = bigquery.query "SELECT ? AS value", params: [nil], types: [:BOOL]

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.fields.count.must_equal 1
    rows.fields.first.name.must_equal "value"
    rows.fields.first.must_be :boolean?
    rows.count.must_equal 1
    rows.first[:value].must_be_nil
  end

  it "queries the data with a date parameter" do
    today = Date.today
    rows = bigquery.query "SELECT ? AS value", params: [today]

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.fields.count.must_equal 1
    rows.fields.first.name.must_equal "value"
    rows.fields.first.must_be :date?
    rows.count.must_equal 1
    rows.first[:value].must_equal Date.today
  end

  it "queries the data with a nil parameter and boolean type" do
    rows = bigquery.query "SELECT ? AS value", params: [nil], types: [:DATE]

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.fields.count.must_equal 1
    rows.fields.first.name.must_equal "value"
    rows.fields.first.must_be :date?
    rows.count.must_equal 1
    rows.first[:value].must_be_nil
  end

  it "queries the data with a datetime parameter" do
    now = Time.now.utc.to_datetime
    rows = bigquery.query "SELECT ? AS value", params: [now]

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.fields.count.must_equal 1
    rows.fields.first.name.must_equal "value"
    rows.fields.first.must_be :datetime?
    rows.count.must_equal 1
    rows.first[:value].must_be_kind_of DateTime
    rows.first[:value].must_be_close_to now
    # rows.first[:value].must_equal now.to_s
  end

  it "queries the data with a nil parameter and boolean type" do
    rows = bigquery.query "SELECT ? AS value", params: [nil], types: [:DATETIME]

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.fields.count.must_equal 1
    rows.fields.first.name.must_equal "value"
    rows.fields.first.must_be :datetime?
    rows.count.must_equal 1
    rows.first[:value].must_be_nil
  end

  it "queries the data with a timestamp parameter" do
    now = Time.now
    rows = bigquery.query "SELECT ? AS value", params: [now]

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.fields.count.must_equal 1
    rows.fields.first.name.must_equal "value"
    rows.fields.first.must_be :timestamp?
    rows.count.must_equal 1
    rows.first[:value].must_be_kind_of ::Time
    rows.first[:value].must_be_close_to now
  end

  it "queries the data with a nil parameter and boolean type" do
    rows = bigquery.query "SELECT ? AS value", params: [nil], types: [:TIMESTAMP]

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.fields.count.must_equal 1
    rows.fields.first.name.must_equal "value"
    rows.fields.first.must_be :timestamp?
    rows.count.must_equal 1
    rows.first[:value].must_be_nil
  end

  it "queries the data with a time parameter" do
    rows = bigquery.query "SELECT ? AS value", params: [bigquery.time(12, 30, 0)]

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.fields.count.must_equal 1
    rows.fields.first.name.must_equal "value"
    rows.fields.first.must_be :time?
    rows.count.must_equal 1
    rows.first[:value].must_be_kind_of Google::Cloud::Bigquery::Time
    rows.first[:value].value.must_equal "12:30:00"
  end

  it "queries the data with a nil parameter and boolean type" do
    rows = bigquery.query "SELECT ? AS value", params: [nil], types: [:TIME]

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.fields.count.must_equal 1
    rows.fields.first.name.must_equal "value"
    rows.fields.first.must_be :time?
    rows.count.must_equal 1
    rows.first[:value].must_be_nil
  end

  it "queries the data with a bytes parameter" do
    rows = bigquery.query "SELECT ? AS value", params: [StringIO.new("hello world!")]

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.fields.count.must_equal 1
    rows.fields.first.name.must_equal "value"
    rows.fields.first.must_be :bytes?
    rows.count.must_equal 1
    rows.first[:value].must_be_kind_of StringIO
    rows.first[:value].read.must_equal "hello world!"
  end

  it "queries the data with a nil parameter and boolean type" do
    rows = bigquery.query "SELECT ? AS value", params: [nil], types: [:BYTES]

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.fields.count.must_equal 1
    rows.fields.first.name.must_equal "value"
    rows.fields.first.must_be :bytes?
    rows.count.must_equal 1
    rows.first[:value].must_be_nil
  end

  it "queries the data with an array of integers parameter" do
    rows = bigquery.query "SELECT ? AS value", params: [[1, 2, 3, 4]]

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.fields.count.must_equal 1
    rows.fields.first.name.must_equal "value"
    rows.fields.first.must_be :integer?
    rows.fields.first.must_be :repeated?
    rows.count.must_equal 1
    rows.first[:value].must_equal [1, 2, 3, 4]
  end

  it "queries the data with an array of strings parameter" do
    rows = bigquery.query "SELECT ? AS value", params: [["foo", "bar", "baz"]]

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.count.must_equal 1
    rows.first[:value].must_equal ["foo", "bar", "baz"]
  end

  it "queries the data with an empty array of integers and type" do
    rows = bigquery.query "SELECT ? AS value", params: [[]], types: [[:INT64]]

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.fields.count.must_equal 1
    rows.fields.first.name.must_equal "value"
    rows.fields.first.must_be :integer?
    rows.fields.first.must_be :repeated?
    rows.count.must_equal 1
    rows.first[:value].must_equal []
  end

  it "queries the data with a nil parameter and ARRAY type" do
    rows = bigquery.query "SELECT ? AS value", params: [nil], types: [[:INT64]]

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.fields.count.must_equal 1
    rows.fields.first.name.must_equal "value"
    rows.fields.first.must_be :integer?
    rows.fields.first.must_be :repeated?
    rows.count.must_equal 1
    # rows.first[:value].must_be_nil
    rows.first[:value].must_equal []
  end

  it "queries the data with a struct parameter" do
    rows = bigquery.query "SELECT ? AS value", params: [{ message: "hello", repeat: 1 }]

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.fields.count.must_equal 1
    rows.fields.first.name.must_equal "value"
    rows.fields.first.must_be :record?
    rows.fields.first.fields.count.must_equal 2
    rows.fields.first.fields.first.name.must_equal "message"
    rows.fields.first.fields.first.must_be :string?
    rows.fields.first.fields.last.name.must_equal "repeat"
    rows.fields.first.fields.last.must_be :integer?
    rows.count.must_equal 1
    rows.first[:value].must_equal({ message: "hello", repeat: 1 })
  end

  it "queries the data with a empty parameter and STRUCT type" do
    rows = bigquery.query "SELECT ? AS value", params: [{}], types: [{ message: :STRING, repeat: :INT64 }]

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.fields.count.must_equal 1
    rows.fields.first.name.must_equal "value"
    rows.fields.first.must_be :record?
    rows.fields.first.fields.count.must_equal 2
    rows.fields.first.fields.first.name.must_equal "message"
    rows.fields.first.fields.first.must_be :string?
    rows.fields.first.fields.last.name.must_equal "repeat"
    rows.fields.first.fields.last.must_be :integer?
    rows.count.must_equal 1
    # rows.first[:value].must_equal({})
    rows.first[:value].must_be_nil
  end

  it "queries the data with a nil parameter and STRUCT type" do
    rows = bigquery.query "SELECT ? AS value", params: [nil], types: [{ message: :STRING, repeat: :INT64 }]

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.fields.count.must_equal 1
    rows.fields.first.name.must_equal "value"
    rows.fields.first.must_be :record?
    rows.fields.first.fields.count.must_equal 2
    rows.fields.first.fields.first.name.must_equal "message"
    rows.fields.first.fields.first.must_be :string?
    rows.fields.first.fields.last.name.must_equal "repeat"
    rows.fields.first.fields.last.must_be :integer?
    rows.count.must_equal 1
    rows.first[:value].must_be_nil
  end
end
