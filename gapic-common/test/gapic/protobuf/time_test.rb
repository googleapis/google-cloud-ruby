# Copyright 2019 Google LLC
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

require "test_helper"
require "google/protobuf/any_pb"
require "google/protobuf/timestamp_pb"
require "stringio"

class ProtobufTimeTest < Minitest::Spec
  SECONDS = 271_828_182
  NANOS = 845_904_523
  A_TIME = Time.at SECONDS + NANOS * 10**-9
  A_TIMESTAMP =
    Google::Protobuf::Timestamp.new seconds: SECONDS, nanos: NANOS

  it "converts time to timestamp" do
    _(Gapic::Protobuf.time_to_timestamp(A_TIME)).must_equal A_TIMESTAMP
  end

  it "converts timestamp to time" do
    _(Gapic::Protobuf.timestamp_to_time(A_TIMESTAMP)).must_equal A_TIME
  end

  it "is an identity when conversion is a round trip" do
    _(
      Gapic::Protobuf.timestamp_to_time(Gapic::Protobuf.time_to_timestamp(A_TIME))
    ).must_equal A_TIME
    _(
      Gapic::Protobuf.time_to_timestamp(
        Gapic::Protobuf.timestamp_to_time(A_TIMESTAMP)
      )
    ).must_equal A_TIMESTAMP
  end
end
