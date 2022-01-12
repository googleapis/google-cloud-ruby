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
require "gapic/grpc"
require "google/rpc/error_details_pb"
require "google/protobuf/timestamp_pb"

class GrpcBadStatusStatusDetailsTest < Minitest::Test
  def test_deserializes_known_type
    expected_error = Google::Rpc::DebugInfo.new detail: "shoes are untied"

    any = Google::Protobuf::Any.pack expected_error
    status = Google::Rpc::Status.new details: [any]
    encoded = Google::Rpc::Status.encode status
    metadata = {
      "grpc-status-details-bin" => encoded
    }
    error = GRPC::BadStatus.new 1, "", metadata

    assert_equal [expected_error], error.status_details
  end

  def test_wont_deserialize_unknown_type
    expected_error = Random.new.bytes 8

    any = Google::Protobuf::Any.new(
      type_url: "unknown-type", value: expected_error
    )
    status = Google::Rpc::Status.new details: [any]
    encoded = Google::Rpc::Status.encode status
    metadata = {
      "grpc-status-details-bin" => encoded
    }
    error = GRPC::BadStatus.new 1, "", metadata

    assert_equal [any], error.status_details
  end

  def test_wont_deserialize_bad_value
    any = Google::Protobuf::Any.new(
      type_url: "type.googleapis.com/google.rpc.DebugInfo",
      value: Random.new.bytes(16)
    )

    status = Google::Rpc::Status.new details: [any]
    encoded = Google::Rpc::Status.encode status
    metadata = {
      "grpc-status-details-bin" => encoded
    }
    error = GRPC::BadStatus.new 1, "", metadata

    assert_equal [any], error.status_details
  end

  def test_deserialize_bad_type_to_empty_object
    timestamp = Google::Protobuf::Timestamp.new seconds: Time.now.to_i, nanos: Time.now.nsec

    any = Google::Protobuf::Any.pack(timestamp)
    assert_equal "type.googleapis.com/google.protobuf.Timestamp", any.type_url
    # Set the type_url to a bad value
    any.type_url = "type.googleapis.com/google.rpc.DebugInfo"

    status = Google::Rpc::Status.new details: [any]
    encoded = Google::Rpc::Status.encode status
    metadata = {
      "grpc-status-details-bin" => encoded
    }
    error = GRPC::BadStatus.new 1, "", metadata

    assert_equal [Google::Rpc::DebugInfo.new], error.status_details
  end
end
