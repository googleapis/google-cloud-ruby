# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0  the "License";
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
require "google/cloud/errors"
require "grpc/errors"
require "google/gax/errors"
require "google/rpc/status_pb"

describe Google::Cloud::Error, :wrapped_gax do
  ##
  # Construct a new Google::Rpc::Status object and return its binary encoding
  #
  # @param extended_details [Boolean] 
  #    Whether to encode multiple error details. Default is one DebugInfo message.
  def encoded_protobuf extended_details: false
    status = google_rpc_status extended_details: extended_details
    Google::Rpc::Status.encode status
  end

  def wrapped_error status, msg, metadata = {}
    err = grpc_error status, msg, metadata
    begin
      begin
        begin
          raise err
        rescue => inner_err
          raise Google::Gax::GaxError.new(inner_err.message)
        end
      rescue => gax_err
        raise Google::Cloud::Error.from_error gax_err.cause
      end
    rescue => e
      return e
    end
  end

  def grpc_error status, msg, metadata = {}
    GRPC::BadStatus.new status, msg, metadata
  end

  # This test confirms that a whole array of any-wrapped detail messages
  # containing various messages from the `google/rpc/error_details.proto`
  # will be correctly deserialized and surfaced to the end-user
  # in the `status_details` field
  it "contains multiple detail messages" do
    error = wrapped_error 1, "cancelled", { "foo" => "bar", "grpc-status-details-bin" => encoded_protobuf(extended_details: true) }
    di = error.status_details.find {|entry| entry.is_a?(Google::Rpc::DebugInfo)} 
    _(di).must_equal debug_info

    lm = error.status_details.find {|entry| entry.is_a?(Google::Rpc::LocalizedMessage)} 
    _(lm).must_equal localized_message

    help_detail = error.status_details.find {|entry| entry.is_a?(Google::Rpc::Help)} 
    _(help_detail).must_equal help
  end

  it "wraps CanceledError" do
    error = wrapped_error 1, "cancelled", { "foo" => "bar", "grpc-status-details-bin" => encoded_protobuf }
    _(error).must_be_kind_of Google::Cloud::CanceledError

    _(error.message).must_equal "1:cancelled"
    _(error.code).must_equal 1
    _(error.details).must_equal "cancelled"
    _(error.metadata["foo"]).must_equal "bar"
    _(error.status_details).must_equal [debug_info]

    _(error.status_code).must_be :nil?
    _(error.body).must_be :nil?
    _(error.header).must_be :nil?
  end

  it "wraps UnknownError" do
    error = wrapped_error 2, "unknown", { "foo" => "bar", "grpc-status-details-bin" => encoded_protobuf }
    _(error).must_be_kind_of Google::Cloud::UnknownError

    _(error.message).must_equal "2:unknown"
    _(error.code).must_equal 2
    _(error.details).must_equal "unknown"
    _(error.metadata["foo"]).must_equal "bar"
    _(error.status_details).must_equal [debug_info]

    _(error.status_code).must_be :nil?
    _(error.body).must_be :nil?
    _(error.header).must_be :nil?
  end

  it "wraps InvalidArgumentError" do
    error = wrapped_error 3, "invalid", { "foo" => "bar", "grpc-status-details-bin" => encoded_protobuf }
    _(error).must_be_kind_of Google::Cloud::InvalidArgumentError

    _(error.message).must_equal "3:invalid"
    _(error.code).must_equal 3
    _(error.details).must_equal "invalid"
    _(error.metadata["foo"]).must_equal "bar"
    _(error.status_details).must_equal [debug_info]

    _(error.status_code).must_be :nil?
    _(error.body).must_be :nil?
    _(error.header).must_be :nil?
  end

  it "wraps DeadlineExceededError" do
    error = wrapped_error 4, "exceeded", { "foo" => "bar", "grpc-status-details-bin" => encoded_protobuf }
    _(error).must_be_kind_of Google::Cloud::DeadlineExceededError

    _(error.message).must_equal "4:exceeded"
    _(error.code).must_equal 4
    _(error.details).must_equal "exceeded"
    _(error.metadata["foo"]).must_equal "bar"
    _(error.status_details).must_equal [debug_info]

    _(error.status_code).must_be :nil?
    _(error.body).must_be :nil?
    _(error.header).must_be :nil?
  end

  it "wraps NotFoundError" do
    error = wrapped_error 5, "not found", { "foo" => "bar", "grpc-status-details-bin" => encoded_protobuf }
    _(error).must_be_kind_of Google::Cloud::NotFoundError

    _(error.message).must_equal "5:not found"
    _(error.code).must_equal 5
    _(error.details).must_equal "not found"
    _(error.metadata["foo"]).must_equal "bar"
    _(error.status_details).must_equal [debug_info]

    _(error.status_code).must_be :nil?
    _(error.body).must_be :nil?
    _(error.header).must_be :nil?
  end

  it "wraps AlreadyExistsError" do
    error = wrapped_error 6, "exists", { "foo" => "bar", "grpc-status-details-bin" => encoded_protobuf }
    _(error).must_be_kind_of Google::Cloud::AlreadyExistsError

    _(error.message).must_equal "6:exists"
    _(error.code).must_equal 6
    _(error.details).must_equal "exists"
    _(error.metadata["foo"]).must_equal "bar"
    _(error.status_details).must_equal [debug_info]

    _(error.status_code).must_be :nil?
    _(error.body).must_be :nil?
    _(error.header).must_be :nil?
  end

  it "wraps PermissionDeniedError" do
    error = wrapped_error 7, "denied", { "foo" => "bar", "grpc-status-details-bin" => encoded_protobuf }
    _(error).must_be_kind_of Google::Cloud::PermissionDeniedError

    _(error.message).must_equal "7:denied"
    _(error.code).must_equal 7
    _(error.details).must_equal "denied"
    _(error.metadata["foo"]).must_equal "bar"
    _(error.status_details).must_equal [debug_info]

    _(error.status_code).must_be :nil?
    _(error.body).must_be :nil?
    _(error.header).must_be :nil?
  end

  it "wraps ResourceExhaustedError" do
    error = wrapped_error 8, "exhausted", { "foo" => "bar", "grpc-status-details-bin" => encoded_protobuf }
    _(error).must_be_kind_of Google::Cloud::ResourceExhaustedError

    _(error.message).must_equal "8:exhausted"
    _(error.code).must_equal 8
    _(error.details).must_equal "exhausted"
    _(error.metadata["foo"]).must_equal "bar"
    _(error.status_details).must_equal [debug_info]

    _(error.status_code).must_be :nil?
    _(error.body).must_be :nil?
    _(error.header).must_be :nil?
  end

  it "wraps FailedPreconditionError" do
    error = wrapped_error 9, "precondition", { "foo" => "bar", "grpc-status-details-bin" => encoded_protobuf }
    _(error).must_be_kind_of Google::Cloud::FailedPreconditionError

    _(error.message).must_equal "9:precondition"
    _(error.code).must_equal 9
    _(error.details).must_equal "precondition"
    _(error.metadata["foo"]).must_equal "bar"
    _(error.status_details).must_equal [debug_info]

    _(error.status_code).must_be :nil?
    _(error.body).must_be :nil?
    _(error.header).must_be :nil?
  end

  it "wraps AbortedError" do
    error = wrapped_error 10, "aborted", { "foo" => "bar", "grpc-status-details-bin" => encoded_protobuf }
    _(error).must_be_kind_of Google::Cloud::AbortedError

    _(error.message).must_equal "10:aborted"
    _(error.code).must_equal 10
    _(error.details).must_equal "aborted"
    _(error.metadata["foo"]).must_equal "bar"
    _(error.status_details).must_equal [debug_info]

    _(error.status_code).must_be :nil?
    _(error.body).must_be :nil?
    _(error.header).must_be :nil?
  end

  it "wraps OutOfRangeError" do
    error = wrapped_error 11, "out of range", { "foo" => "bar", "grpc-status-details-bin" => encoded_protobuf }
    _(error).must_be_kind_of Google::Cloud::OutOfRangeError

    _(error.message).must_equal "11:out of range"
    _(error.code).must_equal 11
    _(error.details).must_equal "out of range"
    _(error.metadata["foo"]).must_equal "bar"
    _(error.status_details).must_equal [debug_info]

    _(error.status_code).must_be :nil?
    _(error.body).must_be :nil?
    _(error.header).must_be :nil?
  end

  it "wraps UnimplementedError" do
    error = wrapped_error 12, "unimplemented", { "foo" => "bar", "grpc-status-details-bin" => encoded_protobuf }
    _(error).must_be_kind_of Google::Cloud::UnimplementedError

    _(error.message).must_equal "12:unimplemented"
    _(error.code).must_equal 12
    _(error.details).must_equal "unimplemented"
    _(error.metadata["foo"]).must_equal "bar"
    _(error.status_details).must_equal [debug_info]

    _(error.status_code).must_be :nil?
    _(error.body).must_be :nil?
    _(error.header).must_be :nil?
  end

  it "wraps InternalError" do
    error = wrapped_error 13, "internal", { "foo" => "bar", "grpc-status-details-bin" => encoded_protobuf }
    _(error).must_be_kind_of Google::Cloud::InternalError

    _(error.message).must_equal "13:internal"
    _(error.code).must_equal 13
    _(error.details).must_equal "internal"
    _(error.metadata["foo"]).must_equal "bar"
    _(error.status_details).must_equal [debug_info]

    _(error.status_code).must_be :nil?
    _(error.body).must_be :nil?
    _(error.header).must_be :nil?
  end

  it "wraps UnavailableError" do
    error = wrapped_error 14, "unavailable", { "foo" => "bar", "grpc-status-details-bin" => encoded_protobuf }
    _(error).must_be_kind_of Google::Cloud::UnavailableError

    _(error.message).must_equal "14:unavailable"
    _(error.code).must_equal 14
    _(error.details).must_equal "unavailable"
    _(error.metadata["foo"]).must_equal "bar"
    _(error.status_details).must_equal [debug_info]

    _(error.status_code).must_be :nil?
    _(error.body).must_be :nil?
    _(error.header).must_be :nil?
  end

  it "wraps DataLossError" do
    error = wrapped_error 15, "data loss", { "foo" => "bar", "grpc-status-details-bin" => encoded_protobuf }
    _(error).must_be_kind_of Google::Cloud::DataLossError

    _(error.message).must_equal "15:data loss"
    _(error.code).must_equal 15
    _(error.details).must_equal "data loss"
    _(error.metadata["foo"]).must_equal "bar"
    _(error.status_details).must_equal [debug_info]

    _(error.status_code).must_be :nil?
    _(error.body).must_be :nil?
    _(error.header).must_be :nil?
  end

  it "wraps UnauthenticatedError" do
    error = wrapped_error 16, "unauthenticated", { "foo" => "bar", "grpc-status-details-bin" => encoded_protobuf }
    _(error).must_be_kind_of Google::Cloud::UnauthenticatedError

    _(error.message).must_equal "16:unauthenticated"
    _(error.code).must_equal 16
    _(error.details).must_equal "unauthenticated"
    _(error.metadata["foo"]).must_equal "bar"
    _(error.status_details).must_equal [debug_info]

    _(error.status_code).must_be :nil?
    _(error.body).must_be :nil?
    _(error.header).must_be :nil?
  end

  it "wraps unknown error (0)" do
    # We don't know what to map this error case to
    error = wrapped_error 0, "unknown", { "foo" => "bar", "grpc-status-details-bin" => encoded_protobuf }
    _(error).must_be_kind_of Google::Cloud::Error

    _(error.message).must_equal "0:unknown"
    _(error.code).must_equal 0
    _(error.details).must_equal "unknown"
    _(error.metadata["foo"]).must_equal "bar"
    _(error.status_details).must_equal [debug_info]

    _(error.status_code).must_be :nil?
    _(error.body).must_be :nil?
    _(error.header).must_be :nil?
  end

  it "wraps unknown error (17)" do
    error = wrapped_error 17, "unknown", { "foo" => "bar", "grpc-status-details-bin" => encoded_protobuf }
    _(error).must_be_kind_of Google::Cloud::Error

    _(error.message).must_equal "17:unknown"
    _(error.code).must_equal 17
    _(error.details).must_equal "unknown"
    _(error.metadata["foo"]).must_equal "bar"
    _(error.status_details).must_equal [debug_info]

    _(error.status_code).must_be :nil?
    _(error.body).must_be :nil?
    _(error.header).must_be :nil?
  end
end
