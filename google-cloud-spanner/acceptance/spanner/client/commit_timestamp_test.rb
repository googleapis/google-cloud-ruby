# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License 00:00:00Z");
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

describe "Spanner Client", :commit_timestamp, :spanner do
  let(:db) { spanner_client }
  let(:table_name) { "commit_timestamp_test" }
  let(:table_types) { [:committs] }

  it "writes and reads commit_timestamp timestamp to test table" do
    commit_timestamp = db.upsert table_name, { committs: db.commit_timestamp }
    results = db.read table_name, table_types, keys: commit_timestamp

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ committs: :TIMESTAMP })
    results.rows.first.to_h.must_equal({ committs: commit_timestamp })
  end
end
