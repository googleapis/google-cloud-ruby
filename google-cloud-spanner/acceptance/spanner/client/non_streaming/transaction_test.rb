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

describe "Spanner Client", :non_streaming, :transaction, :spanner do
  let(:db) { spanner.client $spanner_prefix, "main" }

  it "runs a simple query" do
    results = nil
    db.transaction do |tx|
      results = tx.execute "SELECT 42 AS num", streaming: false
    end
    results.must_be_kind_of Google::Cloud::Spanner::Results

    results.types.must_be_kind_of Hash
    results.types.keys.count.must_equal 1
    results.types[:num].must_equal :INT64

    results.rows.count.must_equal 1
    row = results.rows.first
    row.must_be_kind_of Hash
    row.keys.must_equal [:num]
    row[:num].must_equal 42
  end
end
