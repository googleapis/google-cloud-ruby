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

require "helper"

describe Google::Cloud::Pubsub::Convert, :duration_to_number, :mock_pubsub do
  # This tests is a sanity check on the implementation of the conversion method.
  # We are testing the private method. This functionality is also covered elsewhere,
  # but it was thought that since this conversion is so important we might as well
  # also test it apart from the other tests.

  it "converts an integer" do
    duration = Google::Protobuf::Duration.new seconds: 42, nanos: 0
    number = Google::Cloud::Pubsub::Convert.duration_to_number duration
    number.must_equal 42
  end

  it "converts a negative integer" do
    duration = Google::Protobuf::Duration.new seconds: -42, nanos: 0
    number = Google::Cloud::Pubsub::Convert.duration_to_number duration
    number.must_equal -42
  end

  it "converts a small number" do
    duration = Google::Protobuf::Duration.new seconds: 1, nanos: 500000000
    number = Google::Cloud::Pubsub::Convert.duration_to_number duration
    number.must_equal 1.5
  end

  it "converts a negative small number" do
    duration = Google::Protobuf::Duration.new seconds: -1, nanos: -500000000
    number = Google::Cloud::Pubsub::Convert.duration_to_number duration
    number.must_equal -1.5
  end

  it "converts a big number" do
    duration = Google::Protobuf::Duration.new seconds: 643383279502884, nanos: 197169399
    number = Google::Cloud::Pubsub::Convert.duration_to_number duration
    number.must_equal 643383279502884.197169399
  end

  it "converts a negative big number" do
    duration = Google::Protobuf::Duration.new seconds: -643383279502884, nanos: -197169399
    number = Google::Cloud::Pubsub::Convert.duration_to_number duration
    number.must_equal -643383279502884.197169399
  end

  it "converts pi" do
    duration = Google::Protobuf::Duration.new seconds: 3, nanos: 141592654
    number = Google::Cloud::Pubsub::Convert.duration_to_number duration
    number.must_equal 3.141592654
  end

  it "converts a negative pi" do
    duration = Google::Protobuf::Duration.new seconds: -3, nanos: -141592654
    number = Google::Cloud::Pubsub::Convert.duration_to_number duration
    number.must_equal -3.141592654
  end

  it "returns nil when given nil" do
    duration = nil
    number = Google::Cloud::Pubsub::Convert.duration_to_number duration
    number.must_be :nil?
  end
end
