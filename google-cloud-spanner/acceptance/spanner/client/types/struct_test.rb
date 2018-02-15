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

describe "Spanner Client", :types, :struct, :spanner do
  let(:db) { spanner_client }

  it "queries a nested struct" do
    nested_sql = "SELECT ARRAY(SELECT AS STRUCT C1, C2 " \
      "FROM (SELECT 'a' AS C1, 1 AS C2 UNION ALL SELECT 'b' AS C1, 2 AS C2) " \
      "ORDER BY C1 ASC)"
    results = db.execute nested_sql

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ 0 => [{ C1: :STRING, C2: :INT64 }] })
    results.rows.first.to_h.must_equal({ 0 => [{ C1: "a", C2: 1 }, { C1: "b", C2: 2 }] })
  end

  it "queries an empty struct" do
    empty_sql = "SELECT ARRAY(SELECT AS STRUCT * FROM (SELECT 'a', 1) WHERE 0 = 1)"
    results = db.execute empty_sql

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ 0 => [{ 0 => :STRING, 1 => :INT64 }] })
    results.rows.first.to_h.must_equal({ 0 => [] })
  end
end
