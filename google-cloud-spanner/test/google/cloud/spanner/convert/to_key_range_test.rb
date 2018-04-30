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

describe Google::Cloud::Spanner::Convert, :to_key_range, :mock_spanner do
  # This tests is a sanity check on the implementation of the conversion method.
  # We are testing the private method. This functionality is also covered elsewhere,
  # but it was thought that since this conversion is so important we might as well
  # also test it apart from the other tests.

  it "creates an inclusive Spanner::Range" do
    range = Google::Cloud::Spanner::Range.new 1, 100
    key_range = Google::Cloud::Spanner::Convert.to_key_range range

    key_range.must_be_kind_of Google::Spanner::V1::KeyRange
    key_range.start_closed.must_equal Google::Cloud::Spanner::Convert.object_to_grpc_value([1]).list_value
    key_range.start_open.must_be :nil?
    key_range.end_closed.must_equal Google::Cloud::Spanner::Convert.object_to_grpc_value([100]).list_value
    key_range.end_open.must_be :nil?
  end

  it "creates an exclusive Spanner::Range" do
    range = Google::Cloud::Spanner::Range.new 1, 100, exclude_begin: true, exclude_end: true
    key_range = Google::Cloud::Spanner::Convert.to_key_range range

    key_range.must_be_kind_of Google::Spanner::V1::KeyRange
    key_range.start_closed.must_be :nil?
    key_range.start_open.must_equal Google::Cloud::Spanner::Convert.object_to_grpc_value([1]).list_value
    key_range.end_closed.must_be :nil?
    key_range.end_open.must_equal Google::Cloud::Spanner::Convert.object_to_grpc_value([100]).list_value
  end

  it "creates a Spanner::Range that excludes beginning" do
    range = Google::Cloud::Spanner::Range.new 1, 100, exclude_begin: true
    key_range = Google::Cloud::Spanner::Convert.to_key_range range

    key_range.must_be_kind_of Google::Spanner::V1::KeyRange
    key_range.start_closed.must_be :nil?
    key_range.start_open.must_equal Google::Cloud::Spanner::Convert.object_to_grpc_value([1]).list_value
    key_range.end_closed.must_equal Google::Cloud::Spanner::Convert.object_to_grpc_value([100]).list_value
    key_range.end_open.must_be :nil?
  end

  it "creates a Spanner::Range that excludes ending" do
    range = Google::Cloud::Spanner::Range.new 1, 100, exclude_end: true
    key_range = Google::Cloud::Spanner::Convert.to_key_range range

    key_range.must_be_kind_of Google::Spanner::V1::KeyRange
    key_range.start_closed.must_equal Google::Cloud::Spanner::Convert.object_to_grpc_value([1]).list_value
    key_range.start_open.must_be :nil?
    key_range.end_closed.must_be :nil?
    key_range.end_open.must_equal Google::Cloud::Spanner::Convert.object_to_grpc_value([100]).list_value
  end

  it "creates an inclusive Range" do
    range = 1..100
    key_range = Google::Cloud::Spanner::Convert.to_key_range range

    key_range.must_be_kind_of Google::Spanner::V1::KeyRange
    key_range.start_closed.must_equal Google::Cloud::Spanner::Convert.object_to_grpc_value([1]).list_value
    key_range.start_open.must_be :nil?
    key_range.end_closed.must_equal Google::Cloud::Spanner::Convert.object_to_grpc_value([100]).list_value
    key_range.end_open.must_be :nil?
  end

  it "creates a Range that excludes ending" do
    range = 1...100
    key_range = Google::Cloud::Spanner::Convert.to_key_range range

    key_range.must_be_kind_of Google::Spanner::V1::KeyRange
    key_range.start_closed.must_equal Google::Cloud::Spanner::Convert.object_to_grpc_value([1]).list_value
    key_range.start_open.must_be :nil?
    key_range.end_closed.must_be :nil?
    key_range.end_open.must_equal Google::Cloud::Spanner::Convert.object_to_grpc_value([100]).list_value
  end
end
