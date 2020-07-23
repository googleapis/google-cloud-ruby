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

require "helper"

describe Google::Cloud::Spanner::Snapshot, :range, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:session_id) { "session123" }
  let(:session_grpc) { Google::Cloud::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id) }
  let(:session) { Google::Cloud::Spanner::Session.from_grpc session_grpc, spanner.service }
  let(:transaction_id) { "tx789" }
  let(:transaction_grpc) { Google::Cloud::Spanner::V1::Transaction.new id: transaction_id }
  let(:snapshot) { Google::Cloud::Spanner::Snapshot.from_grpc transaction_grpc, session }

  it "creates an inclusive range" do
    range = snapshot.range 1, 100

    _(range.begin).must_equal 1
    _(range.end).must_equal 100

    _(range).wont_be :exclude_begin?
    _(range).wont_be :exclude_end?
  end

  it "creates an exclusive range" do
    range = snapshot.range 1, 100, exclude_begin: true, exclude_end: true

    _(range.begin).must_equal 1
    _(range.end).must_equal 100

    _(range).must_be :exclude_begin?
    _(range).must_be :exclude_end?
  end

  it "creates a range that excludes beginning" do
    range = snapshot.range 1, 100, exclude_begin: true

    _(range.begin).must_equal 1
    _(range.end).must_equal 100

    _(range).must_be :exclude_begin?
    _(range).wont_be :exclude_end?
  end

  it "creates a range that excludes ending" do
    range = snapshot.range 1, 100, exclude_end: true

    _(range.begin).must_equal 1
    _(range.end).must_equal 100

    _(range).wont_be :exclude_begin?
    _(range).must_be :exclude_end?
  end
end
