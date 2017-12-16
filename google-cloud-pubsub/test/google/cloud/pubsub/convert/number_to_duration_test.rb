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
require "bigdecimal"

describe Google::Cloud::Pubsub::Convert, :number_to_duration, :mock_pubsub do
  # This tests is a sanity check on the implementation of the conversion method.
  # We are testing the private method. This functionality is also covered elsewhere,
  # but it was thought that since this conversion is so important we might as well
  # also test it apart from the other tests.

  it "converts an Integer" do
    number = 42
    duration = Google::Cloud::Pubsub::Convert.number_to_duration number
    duration.must_be_kind_of Google::Protobuf::Duration
    duration.seconds.must_equal 42
    duration.nanos.must_equal 0
  end

  it "converts a negative Integer" do
    number = -42
    duration = Google::Cloud::Pubsub::Convert.number_to_duration number
    duration.must_be_kind_of Google::Protobuf::Duration
    duration.seconds.must_equal -42
    duration.nanos.must_equal 0
  end

  it "converts a Float" do
    number = 1.5
    duration = Google::Cloud::Pubsub::Convert.number_to_duration number
    duration.must_be_kind_of Google::Protobuf::Duration
    duration.seconds.must_equal 1
    duration.nanos.must_equal 500000000
  end

  it "converts a negative Float" do
    number = -1.5
    duration = Google::Cloud::Pubsub::Convert.number_to_duration number
    duration.must_be_kind_of Google::Protobuf::Duration
    duration.seconds.must_equal -1
    duration.nanos.must_equal -500000000
  end

  it "converts a BigDecimal" do
    number = BigDecimal.new "643383279502884.1971693993751058209749445923078164062"
    duration = Google::Cloud::Pubsub::Convert.number_to_duration number
    duration.must_be_kind_of Google::Protobuf::Duration
    duration.seconds.must_equal 643383279502884
    duration.nanos.must_equal 197169399
  end

  it "converts a negative BigDecimal" do
    number = BigDecimal.new "-643383279502884.1971693993751058209749445923078164062"
    duration = Google::Cloud::Pubsub::Convert.number_to_duration number
    duration.must_be_kind_of Google::Protobuf::Duration
    # This should really be -643383279502884, but BigDecimal is doing something here...
    duration.seconds.must_equal -643383279502885
    duration.nanos.must_equal -197169399
  end

  it "converts a Rational" do
    number = Rational "3.14159265358979323846264338327950288419716939937510582097"
    duration = Google::Cloud::Pubsub::Convert.number_to_duration number
    duration.must_be_kind_of Google::Protobuf::Duration
    duration.seconds.must_equal 3
    duration.nanos.must_equal 141592654
  end

  it "converts a negative Rational" do
    number = Rational "-3.14159265358979323846264338327950288419716939937510582097"
    duration = Google::Cloud::Pubsub::Convert.number_to_duration number
    duration.must_be_kind_of Google::Protobuf::Duration
    duration.seconds.must_equal -3
    duration.nanos.must_equal -141592654
  end

  it "returns nil when given nil" do
    number = nil
    duration = Google::Cloud::Pubsub::Convert.number_to_duration number
    duration.must_be :nil?
  end
end
