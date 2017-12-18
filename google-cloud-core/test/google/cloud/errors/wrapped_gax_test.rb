# Copyright 2017 Google LLC
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

describe Google::Cloud::Error, :wrapped_gax do
  def debug_info
    Google::Rpc::DebugInfo.new detail: "lolz"
  end
  def encoded_protobuf
    any = Google::Protobuf::Any.new
    any.pack debug_info

    status = Google::Rpc::Status.new details: [any]

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

  it "wraps CanceledError" do
    error = wrapped_error 1, "cancelled", { "foo" => "bar", "grpc-status-details-bin" => encoded_protobuf }
    error.must_be_kind_of Google::Cloud::CanceledError

    error.message.must_equal "1:cancelled"
    error.code.must_equal 1
    error.details.must_equal "cancelled"
    error.metadata["foo"].must_equal "bar"
    error.status_details.must_equal [debug_info]

    error.status_code.must_be :nil?
    error.body.must_be :nil?
    error.header.must_be :nil?
  end

  it "wraps UnknownError" do
    error = wrapped_error 2, "unknown", { "foo" => "bar", "grpc-status-details-bin" => encoded_protobuf }
    error.must_be_kind_of Google::Cloud::UnknownError

    error.message.must_equal "2:unknown"
    error.code.must_equal 2
    error.details.must_equal "unknown"
    error.metadata["foo"].must_equal "bar"
    error.status_details.must_equal [debug_info]

    error.status_code.must_be :nil?
    error.body.must_be :nil?
    error.header.must_be :nil?
  end

  it "wraps InvalidArgumentError" do
    error = wrapped_error 3, "invalid", { "foo" => "bar", "grpc-status-details-bin" => encoded_protobuf }
    error.must_be_kind_of Google::Cloud::InvalidArgumentError

    error.message.must_equal "3:invalid"
    error.code.must_equal 3
    error.details.must_equal "invalid"
    error.metadata["foo"].must_equal "bar"
    error.status_details.must_equal [debug_info]

    error.status_code.must_be :nil?
    error.body.must_be :nil?
    error.header.must_be :nil?
  end

  it "wraps DeadlineExceededError" do
    error = wrapped_error 4, "exceeded", { "foo" => "bar", "grpc-status-details-bin" => encoded_protobuf }
    error.must_be_kind_of Google::Cloud::DeadlineExceededError

    error.message.must_equal "4:exceeded"
    error.code.must_equal 4
    error.details.must_equal "exceeded"
    error.metadata["foo"].must_equal "bar"
    error.status_details.must_equal [debug_info]

    error.status_code.must_be :nil?
    error.body.must_be :nil?
    error.header.must_be :nil?
  end

  it "wraps NotFoundError" do
    error = wrapped_error 5, "not found", { "foo" => "bar", "grpc-status-details-bin" => encoded_protobuf }
    error.must_be_kind_of Google::Cloud::NotFoundError

    error.message.must_equal "5:not found"
    error.code.must_equal 5
    error.details.must_equal "not found"
    error.metadata["foo"].must_equal "bar"
    error.status_details.must_equal [debug_info]

    error.status_code.must_be :nil?
    error.body.must_be :nil?
    error.header.must_be :nil?
  end

  it "wraps AlreadyExistsError" do
    error = wrapped_error 6, "exists", { "foo" => "bar", "grpc-status-details-bin" => encoded_protobuf }
    error.must_be_kind_of Google::Cloud::AlreadyExistsError

    error.message.must_equal "6:exists"
    error.code.must_equal 6
    error.details.must_equal "exists"
    error.metadata["foo"].must_equal "bar"
    error.status_details.must_equal [debug_info]

    error.status_code.must_be :nil?
    error.body.must_be :nil?
    error.header.must_be :nil?
  end

  it "wraps PermissionDeniedError" do
    error = wrapped_error 7, "denied", { "foo" => "bar", "grpc-status-details-bin" => encoded_protobuf }
    error.must_be_kind_of Google::Cloud::PermissionDeniedError

    error.message.must_equal "7:denied"
    error.code.must_equal 7
    error.details.must_equal "denied"
    error.metadata["foo"].must_equal "bar"
    error.status_details.must_equal [debug_info]

    error.status_code.must_be :nil?
    error.body.must_be :nil?
    error.header.must_be :nil?
  end

  it "wraps ResourceExhaustedError" do
    error = wrapped_error 8, "exhausted", { "foo" => "bar", "grpc-status-details-bin" => encoded_protobuf }
    error.must_be_kind_of Google::Cloud::ResourceExhaustedError

    error.message.must_equal "8:exhausted"
    error.code.must_equal 8
    error.details.must_equal "exhausted"
    error.metadata["foo"].must_equal "bar"
    error.status_details.must_equal [debug_info]

    error.status_code.must_be :nil?
    error.body.must_be :nil?
    error.header.must_be :nil?
  end

  it "wraps FailedPreconditionError" do
    error = wrapped_error 9, "precondition", { "foo" => "bar", "grpc-status-details-bin" => encoded_protobuf }
    error.must_be_kind_of Google::Cloud::FailedPreconditionError

    error.message.must_equal "9:precondition"
    error.code.must_equal 9
    error.details.must_equal "precondition"
    error.metadata["foo"].must_equal "bar"
    error.status_details.must_equal [debug_info]

    error.status_code.must_be :nil?
    error.body.must_be :nil?
    error.header.must_be :nil?
  end

  it "wraps AbortedError" do
    error = wrapped_error 10, "aborted", { "foo" => "bar", "grpc-status-details-bin" => encoded_protobuf }
    error.must_be_kind_of Google::Cloud::AbortedError

    error.message.must_equal "10:aborted"
    error.code.must_equal 10
    error.details.must_equal "aborted"
    error.metadata["foo"].must_equal "bar"
    error.status_details.must_equal [debug_info]

    error.status_code.must_be :nil?
    error.body.must_be :nil?
    error.header.must_be :nil?
  end

  it "wraps OutOfRangeError" do
    error = wrapped_error 11, "out of range", { "foo" => "bar", "grpc-status-details-bin" => encoded_protobuf }
    error.must_be_kind_of Google::Cloud::OutOfRangeError

    error.message.must_equal "11:out of range"
    error.code.must_equal 11
    error.details.must_equal "out of range"
    error.metadata["foo"].must_equal "bar"
    error.status_details.must_equal [debug_info]

    error.status_code.must_be :nil?
    error.body.must_be :nil?
    error.header.must_be :nil?
  end

  it "wraps UnimplementedError" do
    error = wrapped_error 12, "unimplemented", { "foo" => "bar", "grpc-status-details-bin" => encoded_protobuf }
    error.must_be_kind_of Google::Cloud::UnimplementedError

    error.message.must_equal "12:unimplemented"
    error.code.must_equal 12
    error.details.must_equal "unimplemented"
    error.metadata["foo"].must_equal "bar"
    error.status_details.must_equal [debug_info]

    error.status_code.must_be :nil?
    error.body.must_be :nil?
    error.header.must_be :nil?
  end

  it "wraps InternalError" do
    error = wrapped_error 13, "internal", { "foo" => "bar", "grpc-status-details-bin" => encoded_protobuf }
    error.must_be_kind_of Google::Cloud::InternalError

    error.message.must_equal "13:internal"
    error.code.must_equal 13
    error.details.must_equal "internal"
    error.metadata["foo"].must_equal "bar"
    error.status_details.must_equal [debug_info]

    error.status_code.must_be :nil?
    error.body.must_be :nil?
    error.header.must_be :nil?
  end

  it "wraps UnavailableError" do
    error = wrapped_error 14, "unavailable", { "foo" => "bar", "grpc-status-details-bin" => encoded_protobuf }
    error.must_be_kind_of Google::Cloud::UnavailableError

    error.message.must_equal "14:unavailable"
    error.code.must_equal 14
    error.details.must_equal "unavailable"
    error.metadata["foo"].must_equal "bar"
    error.status_details.must_equal [debug_info]

    error.status_code.must_be :nil?
    error.body.must_be :nil?
    error.header.must_be :nil?
  end

  it "wraps DataLossError" do
    error = wrapped_error 15, "data loss", { "foo" => "bar", "grpc-status-details-bin" => encoded_protobuf }
    error.must_be_kind_of Google::Cloud::DataLossError

    error.message.must_equal "15:data loss"
    error.code.must_equal 15
    error.details.must_equal "data loss"
    error.metadata["foo"].must_equal "bar"
    error.status_details.must_equal [debug_info]

    error.status_code.must_be :nil?
    error.body.must_be :nil?
    error.header.must_be :nil?
  end

  it "wraps UnauthenticatedError" do
    error = wrapped_error 16, "unauthenticated", { "foo" => "bar", "grpc-status-details-bin" => encoded_protobuf }
    error.must_be_kind_of Google::Cloud::UnauthenticatedError

    error.message.must_equal "16:unauthenticated"
    error.code.must_equal 16
    error.details.must_equal "unauthenticated"
    error.metadata["foo"].must_equal "bar"
    error.status_details.must_equal [debug_info]

    error.status_code.must_be :nil?
    error.body.must_be :nil?
    error.header.must_be :nil?
  end

  it "wraps unknown error (0)" do
    # We don't know what to map this error case to
    error = wrapped_error 0, "unknown", { "foo" => "bar", "grpc-status-details-bin" => encoded_protobuf }
    error.must_be_kind_of Google::Cloud::Error

    error.message.must_equal "0:unknown"
    error.code.must_equal 0
    error.details.must_equal "unknown"
    error.metadata["foo"].must_equal "bar"
    error.status_details.must_equal [debug_info]

    error.status_code.must_be :nil?
    error.body.must_be :nil?
    error.header.must_be :nil?
  end

  it "wraps unknown error (17)" do
    error = wrapped_error 17, "unknown", { "foo" => "bar", "grpc-status-details-bin" => encoded_protobuf }
    error.must_be_kind_of Google::Cloud::Error

    error.message.must_equal "17:unknown"
    error.code.must_equal 17
    error.details.must_equal "unknown"
    error.metadata["foo"].must_equal "bar"
    error.status_details.must_equal [debug_info]

    error.status_code.must_be :nil?
    error.body.must_be :nil?
    error.header.must_be :nil?
  end
end
