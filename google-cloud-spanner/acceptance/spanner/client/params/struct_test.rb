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

describe "Spanner Client", :params, :struct, :spanner do
  let(:db) { spanner_client }

  it "queries and returns a struct parameter" do
    skip "Sending a STRUCT was working, but now returns an error"

    results = db.execute "SELECT ARRAY(@value) AS value", params: { value: { message: "hello", repeat: 1 } }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ value: [{ message: :STRING, repeat: :INT64 }] })
    results.rows.first.to_h.must_equal({ value: [{ message: "hello", repeat: 1 }] })
  end

  it "queries a struct parameter and returns string and integer" do
    skip "Sending a STRUCT was working, but now returns an error"

    results = db.execute "SELECT @value.message AS message, @value.repeat AS repeat", params: { value: { message: "hello", repeat: 1 } }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ message: :STRING, repeat: :INT64 })
    results.rows.first.to_h.must_equal({ message: "hello", repeat: 1 })
  end

  it "queries and returns a struct array" do
    struct_sql = "SELECT ARRAY(SELECT AS STRUCT message, repeat FROM (SELECT 'hello' AS message, 1 AS repeat UNION ALL SELECT 'hola' AS message, 2 AS repeat))"
    results = db.execute struct_sql

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ 0 => [{ message: :STRING, repeat: :INT64 }] })
    results.rows.first.to_h.must_equal({ 0 => [{ message: "hello", repeat: 1 }, { message: "hola", repeat: 2 }] })
  end

  it "queries and returns an empty struct array" do
    struct_sql = "SELECT ARRAY(SELECT AS STRUCT * FROM (SELECT 'empty', 0) WHERE 0 = 1)"
    results = db.execute struct_sql

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ 0 => [{ 0 => :STRING, 1 => :INT64 }] })
    results.rows.first.to_h.must_equal({ 0 => [] })
  end

end
