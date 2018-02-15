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

describe Google::Cloud::Bigquery, :legacy_query_types, :bigquery do

  it "queries a string value" do
    rows = bigquery.query "SELECT 'hello' AS value", legacy_sql: true

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.count.must_equal 1
    rows.first[:value].must_equal "hello"
  end

  it "queries an integer value" do
    rows = bigquery.query "SELECT 999 AS value", legacy_sql: true

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.count.must_equal 1
    rows.first[:value].must_equal 999
  end

  it "queries a float value" do
    rows = bigquery.query "SELECT 12.0 AS value", legacy_sql: true

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.count.must_equal 1
    rows.first[:value].must_equal 12.0
  end

  it "queries a boolean value" do
    rows = bigquery.query "SELECT false AS value", legacy_sql: true

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.count.must_equal 1
    rows.first[:value].must_equal false
  end

  it "queries a date value" do
    rows = bigquery.query "SELECT CAST(CURRENT_DATE() AS DATE) AS value", legacy_sql: true

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.count.must_equal 1
    rows.first[:value].must_be_kind_of Date
  end

  it "queries a datetime value" do
    skip "Legacy SQL doesn't have a DATETIME type."
  end

  it "queries a timestamp value" do
    rows = bigquery.query "SELECT CAST(CURRENT_TIMESTAMP() AS TIMESTAMP) AS value", legacy_sql: true

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.count.must_equal 1
    rows.first[:value].must_be_kind_of ::Time
  end

  it "queries a time value" do
    rows = bigquery.query "SELECT CAST(CURRENT_TIME() AS TIME) AS value", legacy_sql: true

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.count.must_equal 1
    rows.first[:value].must_be_kind_of Google::Cloud::Bigquery::Time
  end

  it "queries a bytes value" do
    rows = bigquery.query "SELECT CAST('hello' AS BYTES) AS value", legacy_sql: true

    rows.class.must_equal Google::Cloud::Bigquery::Data
    rows.count.must_equal 1
    rows.first[:value].must_be_kind_of StringIO
    rows.first[:value].read.must_equal "hello"
  end
end
