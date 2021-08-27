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

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.fields.count).must_equal 1
    _(rows.fields.first.name).must_equal "value"
    _(rows.fields.first).must_be :string?
    _(rows.count).must_equal 1
    _(rows.first[:value]).must_equal "hello"
  end

  it "queries the data with a nil parameter and string type" do
    rows = bigquery.query "SELECT @value AS value", params: { value: nil }, types: { value: :STRING }

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.fields.count).must_equal 1
    _(rows.fields.first.name).must_equal "value"
    _(rows.fields.first).must_be :string?
    _(rows.count).must_equal 1
    _(rows.first[:value]).must_be_nil
  end

  it "queries the data with an integer parameter" do
    rows = bigquery.query "SELECT @value AS value", params: { value: 999 }

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.fields.count).must_equal 1
    _(rows.fields.first.name).must_equal "value"
    _(rows.fields.first).must_be :integer?
    _(rows.count).must_equal 1
    _(rows.first[:value]).must_equal 999
  end

  it "queries the data with a nil parameter and integer type" do
    rows = bigquery.query "SELECT @value AS value", params: { value: nil }, types: { value: :INT64 }

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.fields.count).must_equal 1
    _(rows.fields.first.name).must_equal "value"
    _(rows.fields.first).must_be :integer?
    _(rows.count).must_equal 1
    _(rows.first[:value]).must_be_nil
  end

  it "queries the data with a float parameter" do
    rows = bigquery.query "SELECT @value AS value", params: { value: 12.0 }

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.fields.count).must_equal 1
    _(rows.fields.first.name).must_equal "value"
    _(rows.fields.first).must_be :float?
    _(rows.count).must_equal 1
    _(rows.first[:value]).must_equal 12.0
  end

  it "queries the data with a nil parameter and float type" do
    rows = bigquery.query "SELECT @value AS value", params: { value: nil }, types: { value: :FLOAT64 }

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.fields.count).must_equal 1
    _(rows.fields.first.name).must_equal "value"
    _(rows.fields.first).must_be :float?
    _(rows.count).must_equal 1
    _(rows.first[:value]).must_be_nil
  end

  it "queries the data with a numeric parameter" do
    rows = bigquery.query "SELECT @value AS value", params: { value: BigDecimal("123456789.123456789") }

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.fields.count).must_equal 1
    _(rows.fields.first.name).must_equal "value"
    _(rows.fields.first).must_be :numeric?
    _(rows.count).must_equal 1
    _(rows.first[:value]).must_equal BigDecimal("123456789.123456789")
  end

  it "queries the data with a rounded numeric parameter" do
    rows = bigquery.query "SELECT @value AS value", params: { value: BigDecimal("123456789.1234567891") }

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.fields.count).must_equal 1
    _(rows.fields.first.name).must_equal "value"
    _(rows.fields.first).must_be :numeric?
    _(rows.count).must_equal 1
    _(rows.first[:value]).must_equal BigDecimal("123456789.123456789")
  end

  it "queries the data with a nil parameter and numeric type" do
    rows = bigquery.query "SELECT @value AS value", params: { value: nil }, types: { value: :NUMERIC }

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.fields.count).must_equal 1
    _(rows.fields.first.name).must_equal "value"
    _(rows.fields.first).must_be :numeric?
    _(rows.count).must_equal 1
    _(rows.first[:value]).must_be_nil
  end

  it "queries the data with a bignumeric parameter and bignumeric type" do
    rows = bigquery.query "SELECT @value AS value", 
                          params: { value: BigDecimal("123456789.1234567891") },
                          types: { value: :BIGNUMERIC }

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.fields.count).must_equal 1
    _(rows.fields.first.name).must_equal "value"
    _(rows.fields.first).must_be :bignumeric?
    _(rows.count).must_equal 1
    _(rows.first[:value]).must_equal BigDecimal("123456789.1234567891")
  end

  it "queries the data with a nil parameter and bignumeric type" do
    rows = bigquery.query "SELECT @value AS value", params: { value: nil }, types: { value: :BIGNUMERIC }

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.fields.count).must_equal 1
    _(rows.fields.first.name).must_equal "value"
    _(rows.fields.first).must_be :bignumeric?
    _(rows.count).must_equal 1
    _(rows.first[:value]).must_be_nil
  end

  it "queries the data with a boolean parameter" do
    rows = bigquery.query "SELECT @value AS value", params: { value: false }

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.fields.count).must_equal 1
    _(rows.fields.first.name).must_equal "value"
    _(rows.fields.first).must_be :boolean?
    _(rows.count).must_equal 1
    _(rows.first[:value]).must_equal false
  end

  it "queries the data with a nil parameter and boolean type" do
    rows = bigquery.query "SELECT @value AS value", params: { value: nil }, types: { value: :BOOL }

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.fields.count).must_equal 1
    _(rows.fields.first.name).must_equal "value"
    _(rows.fields.first).must_be :boolean?
    _(rows.count).must_equal 1
    _(rows.first[:value]).must_be_nil
  end

  it "queries the data with a date parameter" do
    today = Date.today
    rows = bigquery.query "SELECT @value AS value", params: { value: today }

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.fields.count).must_equal 1
    _(rows.fields.first.name).must_equal "value"
    _(rows.fields.first).must_be :date?
    _(rows.count).must_equal 1
    _(rows.first[:value]).must_equal Date.today
  end

  it "queries the data with a nil parameter and boolean type" do
    rows = bigquery.query "SELECT @value AS value", params: { value: nil }, types: { value: :DATE }

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.fields.count).must_equal 1
    _(rows.fields.first.name).must_equal "value"
    _(rows.fields.first).must_be :date?
    _(rows.count).must_equal 1
    _(rows.first[:value]).must_be_nil
  end

  it "queries the data with a datetime parameter" do
    now = Time.now.utc.to_datetime
    rows = bigquery.query "SELECT @value AS value", params: { value: now }

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.fields.count).must_equal 1
    _(rows.fields.first.name).must_equal "value"
    _(rows.fields.first).must_be :datetime?
    _(rows.count).must_equal 1
    _(rows.first[:value]).must_be_kind_of DateTime
    _(rows.first[:value]).must_be_close_to now
    # rows.first[:value].must_equal now.to_s
  end

  it "queries the data with a nil parameter and datetime type" do
    rows = bigquery.query "SELECT @value AS value", params: { value: nil }, types: { value: :DATETIME }

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.fields.count).must_equal 1
    _(rows.fields.first.name).must_equal "value"
    _(rows.fields.first).must_be :datetime?
    _(rows.count).must_equal 1
    _(rows.first[:value]).must_be_nil
  end

  it "queries the data with a WKT geography parameter and geography type" do
    rows = bigquery.query "SELECT @value AS value", 
                          params: { value: "POINT(-122.335503 47.625536)" },
                          types: { value: :GEOGRAPHY }

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.fields.count).must_equal 1
    _(rows.fields.first.name).must_equal "value"
    _(rows.fields.first).must_be :geography?
    _(rows.count).must_equal 1
    _(rows.first[:value]).must_equal "POINT(-122.335503 47.625536)"
  end

  it "queries the data with a nil parameter and geography type" do
    rows = bigquery.query "SELECT @value AS value", params: { value: nil }, types: { value: :GEOGRAPHY }

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.fields.count).must_equal 1
    _(rows.fields.first.name).must_equal "value"
    _(rows.fields.first).must_be :geography?
    _(rows.count).must_equal 1
    _(rows.first[:value]).must_be_nil
  end

  it "queries the data with a timestamp parameter" do
    now = Time.now
    rows = bigquery.query "SELECT @value AS value", params: { value: now }

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.fields.count).must_equal 1
    _(rows.fields.first.name).must_equal "value"
    _(rows.fields.first).must_be :timestamp?
    _(rows.count).must_equal 1
    _(rows.first[:value]).must_be_kind_of ::Time
    _(rows.first[:value]).must_be_close_to now
  end

  it "queries the data with a nil parameter and boolean type" do
    rows = bigquery.query "SELECT @value AS value", params: { value: nil }, types: { value: :TIMESTAMP }

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.fields.count).must_equal 1
    _(rows.fields.first.name).must_equal "value"
    _(rows.fields.first).must_be :timestamp?
    _(rows.count).must_equal 1
    _(rows.first[:value]).must_be_nil
  end

  it "queries the data with a time parameter" do
    rows = bigquery.query "SELECT @value AS value", params: { value: bigquery.time(12, 30, 0) }

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.fields.count).must_equal 1
    _(rows.fields.first.name).must_equal "value"
    _(rows.fields.first).must_be :time?
    _(rows.count).must_equal 1
    _(rows.first[:value]).must_be_kind_of Google::Cloud::Bigquery::Time
    _(rows.first[:value].value).must_equal "12:30:00"
  end

  it "queries the data with a nil parameter and boolean type" do
    rows = bigquery.query "SELECT @value AS value", params: { value: nil }, types: { value: :TIME }

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.fields.count).must_equal 1
    _(rows.fields.first.name).must_equal "value"
    _(rows.fields.first).must_be :time?
    _(rows.count).must_equal 1
    _(rows.first[:value]).must_be_nil
  end

  it "queries the data with a bytes parameter" do
    rows = bigquery.query "SELECT @value AS value", params: { value: StringIO.new("hello world!") }

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.fields.count).must_equal 1
    _(rows.fields.first.name).must_equal "value"
    _(rows.fields.first).must_be :bytes?
    _(rows.count).must_equal 1
    _(rows.first[:value]).must_be_kind_of StringIO
    _(rows.first[:value].read).must_equal "hello world!"
  end

  it "queries the data with a nil parameter and boolean type" do
    rows = bigquery.query "SELECT @value AS value", params: { value: nil }, types: { value: :BYTES }

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.fields.count).must_equal 1
    _(rows.fields.first.name).must_equal "value"
    _(rows.fields.first).must_be :bytes?
    _(rows.count).must_equal 1
    _(rows.first[:value]).must_be_nil
  end

  it "queries the data with an array of integers parameter" do
    rows = bigquery.query "SELECT @value AS value", params: { value: [1, 2, 3, 4] }

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.fields.count).must_equal 1
    _(rows.fields.first.name).must_equal "value"
    _(rows.fields.first).must_be :integer?
    _(rows.fields.first).must_be :repeated?
    _(rows.count).must_equal 1
    _(rows.first[:value]).must_equal [1, 2, 3, 4]
  end

  it "queries the data with an array of strings parameter" do
    rows = bigquery.query "SELECT @value AS value", params: { value: ["foo", "bar", "baz"] }

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.count).must_equal 1
    _(rows.first[:value]).must_equal ["foo", "bar", "baz"]
  end

  it "queries the data with an empty array of integers and type" do
    rows = bigquery.query "SELECT @value AS value", params: { value: [] }, types: { value: [:INT64] }

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.fields.count).must_equal 1
    _(rows.fields.first.name).must_equal "value"
    _(rows.fields.first).must_be :integer?
    _(rows.fields.first).must_be :repeated?
    _(rows.count).must_equal 1
    _(rows.first[:value]).must_equal []
  end

  it "queries the data with a nil parameter and ARRAY type" do
    rows = bigquery.query "SELECT @value AS value", params: { value: nil }, types: { value: [:INT64] }

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.fields.count).must_equal 1
    _(rows.fields.first.name).must_equal "value"
    _(rows.fields.first).must_be :integer?
    _(rows.fields.first).must_be :repeated?
    _(rows.count).must_equal 1
    # rows.first[:value].must_be_nil
    _(rows.first[:value]).must_equal []
  end

  it "queries the data with a converted string to integer in an array parameter" do
    rows = bigquery.query "SELECT @value AS value", params: { value: ["1"] }, types: { value: [:INT64] }

    _(rows.fields.count).must_equal 1
    _(rows.fields.first.name).must_equal "value"
    _(rows.fields.first).must_be :repeated?
    _(rows.fields.first).must_be :integer?
    _(rows.count).must_equal 1
    _(rows.first[:value]).must_equal [1]
  end

  it "queries the data with a struct parameter" do
    rows = bigquery.query "SELECT @value AS value", params: { value: { message: "hello", repeat: 1 } }

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.fields.count).must_equal 1
    _(rows.fields.first.name).must_equal "value"
    _(rows.fields.first).must_be :record?
    _(rows.fields.first.fields.count).must_equal 2
    _(rows.fields.first.fields.first.name).must_equal "message"
    _(rows.fields.first.fields.first).must_be :string?
    _(rows.fields.first.fields.last.name).must_equal "repeat"
    _(rows.fields.first.fields.last).must_be :integer?
    _(rows.count).must_equal 1
    _(rows.first[:value]).must_equal({ message: "hello", repeat: 1 })
  end

  it "queries the data with a empty parameter and STRUCT type" do
    rows = bigquery.query "SELECT @value AS value", params: { value: {} }, types: { value: { message: :STRING, repeat: :INT64 } }

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.fields.count).must_equal 1
    _(rows.fields.first.name).must_equal "value"
    _(rows.fields.first).must_be :record?
    _(rows.fields.first.fields.count).must_equal 2
    _(rows.fields.first.fields.first.name).must_equal "message"
    _(rows.fields.first.fields.first).must_be :string?
    _(rows.fields.first.fields.last.name).must_equal "repeat"
    _(rows.fields.first.fields.last).must_be :integer?
    _(rows.count).must_equal 1
    # rows.first[:value].must_equal({})
    _(rows.first[:value]).must_be_nil
  end

  it "queries the data with a nil parameter and STRUCT type" do
    rows = bigquery.query "SELECT @value AS value", params: { value: nil }, types: { value: { message: :STRING, repeat: :INT64 } }

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.fields.count).must_equal 1
    _(rows.fields.first.name).must_equal "value"
    _(rows.fields.first).must_be :record?
    _(rows.fields.first.fields.count).must_equal 2
    _(rows.fields.first.fields.first.name).must_equal "message"
    _(rows.fields.first.fields.first).must_be :string?
    _(rows.fields.first.fields.last.name).must_equal "repeat"
    _(rows.fields.first.fields.last).must_be :integer?
    _(rows.count).must_equal 1
    _(rows.first[:value]).must_be_nil
  end

  it "queries the data with nested nil in a struct parameter" do
    rows = bigquery.query "SELECT @value AS value", params: { value: { message: nil, repeat: 1 } }, types: { value: { message: :STRING, repeat: :INT64 } }

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.fields.count).must_equal 1
    _(rows.fields.first.name).must_equal "value"
    _(rows.fields.first).must_be :record?
    _(rows.fields.first.fields.count).must_equal 2
    _(rows.fields.first.fields.first.name).must_equal "message"
    _(rows.fields.first.fields.first).must_be :string?
    _(rows.fields.first.fields.last.name).must_equal "repeat"
    _(rows.fields.first.fields.last).must_be :integer?
    _(rows.count).must_equal 1
    _(rows.first[:value]).must_equal({ message: nil, repeat: 1 })
  end

  it "queries the data with a converted string to integer in a struct parameter" do
    rows = bigquery.query "SELECT @value AS value", params: { value: { message: "hello", repeat: "1" } }, types: { value: { message: :STRING, repeat: :INT64 } }

    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.fields.count).must_equal 1
    _(rows.fields.first.name).must_equal "value"
    _(rows.fields.first).must_be :record?
    _(rows.fields.first.fields.count).must_equal 2
    _(rows.fields.first.fields.first.name).must_equal "message"
    _(rows.fields.first.fields.first).must_be :string?
    _(rows.fields.first.fields.last.name).must_equal "repeat"
    _(rows.fields.first.fields.last).must_be :integer?
    _(rows.count).must_equal 1
    _(rows.first[:value]).must_equal({ message: "hello", repeat: 1 })
  end
end
