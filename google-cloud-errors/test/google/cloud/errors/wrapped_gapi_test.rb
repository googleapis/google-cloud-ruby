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
require "google/apis/errors"

describe Google::Cloud::Error, :wrapped_gapi do
  def wrapped_error msg, status, body = nil, header = nil
    err = gapi_error msg, status, body, header
    begin
      begin
        raise err
      rescue => inner_err
        raise Google::Cloud::Error.from_error inner_err
      end
    rescue => e
      return e
    end
  end

  def gapi_error msg, status, body = nil, header = nil
    Google::Apis::Error.new msg, status_code: status, body: body, header: header
  end

  it "wraps InvalidArgumentError" do
    error = wrapped_error "invalid", 400, "invalid body", ["invalid headers"]
    error.must_be_kind_of Google::Cloud::InvalidArgumentError

    error.message.must_equal "invalid"
    error.status_code.must_equal 400
    error.body.must_equal "invalid body"
    error.header.must_equal ["invalid headers"]

    error.code.must_be :nil?
    error.details.must_be :nil?
    error.metadata.must_be :nil?
    error.status_details.must_be :nil?
  end

  it "wraps FailedPreconditionError" do
    skip "don't know how we differentiate this error yet"

    error = wrapped_error "precondition", 400, "precondition body", ["precondition headers"]
    error.must_be_kind_of Google::Cloud::FailedPreconditionError

    error.message.must_equal "precondition"
    error.status_code.must_equal 400
    error.body.must_equal "precondition body"
    error.header.must_equal ["precondition headers"]

    error.code.must_be :nil?
    error.details.must_be :nil?
    error.metadata.must_be :nil?
    error.status_details.must_be :nil?
  end

  it "wraps OutOfRangeError" do
    skip "don't know how we differentiate this error yet"

    error = wrapped_error "out of range", 400, "out of range body", ["out of range headers"]
    error.must_be_kind_of Google::Cloud::OutOfRangeError

    error.message.must_equal "out of range"
    error.status_code.must_equal 400
    error.body.must_equal "out of range body"
    error.header.must_equal ["out of range headers"]

    error.code.must_be :nil?
    error.details.must_be :nil?
    error.metadata.must_be :nil?
    error.status_details.must_be :nil?
  end

  it "wraps UnauthenticatedError" do
    error = wrapped_error "unauthenticated", 401, "unauthenticated body", ["unauthenticated headers"]
    error.must_be_kind_of Google::Cloud::UnauthenticatedError

    error.message.must_equal "unauthenticated"
    error.status_code.must_equal 401
    error.body.must_equal "unauthenticated body"
    error.header.must_equal ["unauthenticated headers"]

    error.code.must_be :nil?
    error.details.must_be :nil?
    error.metadata.must_be :nil?
    error.status_details.must_be :nil?
  end

  it "wraps PermissionDeniedError" do
    error = wrapped_error "denied", 403, "denied body", ["denied headers"]
    error.must_be_kind_of Google::Cloud::PermissionDeniedError

    error.message.must_equal "denied"
    error.status_code.must_equal 403
    error.body.must_equal "denied body"
    error.header.must_equal ["denied headers"]

    error.code.must_be :nil?
    error.details.must_be :nil?
    error.metadata.must_be :nil?
    error.status_details.must_be :nil?
  end

  it "wraps NotFoundError" do
    error = wrapped_error "notfound", 404, "notfound body", ["notfound headers"]
    error.must_be_kind_of Google::Cloud::NotFoundError

    error.message.must_equal "notfound"
    error.status_code.must_equal 404
    error.body.must_equal "notfound body"
    error.header.must_equal ["notfound headers"]

    error.code.must_be :nil?
    error.details.must_be :nil?
    error.metadata.must_be :nil?
    error.status_details.must_be :nil?
  end

  it "wraps AlreadyExistsError" do
    error = wrapped_error "exists", 409, "exists body", ["exists headers"]
    error.must_be_kind_of Google::Cloud::AlreadyExistsError

    error.message.must_equal "exists"
    error.status_code.must_equal 409
    error.body.must_equal "exists body"
    error.header.must_equal ["exists headers"]

    error.code.must_be :nil?
    error.details.must_be :nil?
    error.metadata.must_be :nil?
    error.status_details.must_be :nil?
  end

  it "wraps AbortedError" do
    skip "don't know how we differentiate this error yet"

    error = wrapped_error "aborted", 409, "aborted body", ["aborted headers"]
    error.must_be_kind_of Google::Cloud::AbortedError

    error.message.must_equal "aborted"
    error.status_code.must_equal 409
    error.body.must_equal "aborted body"
    error.header.must_equal ["aborted headers"]

    error.code.must_be :nil?
    error.details.must_be :nil?
    error.metadata.must_be :nil?
    error.status_details.must_be :nil?
  end

  it "wraps invalid (411) error" do
    # We don't know what to map this error case to
    error = wrapped_error "invalid", 411, "invalid body", ["invalid headers"]
    error.must_be_kind_of Google::Cloud::Error

    error.message.must_equal "invalid"
    error.status_code.must_equal 411
    error.body.must_equal "invalid body"
    error.header.must_equal ["invalid headers"]

    error.code.must_be :nil?
    error.details.must_be :nil?
    error.metadata.must_be :nil?
    error.status_details.must_be :nil?
  end

  it "wraps FailedPreconditionError" do
    error = wrapped_error "conditionNotMet", 412, "conditionNotMet body", ["conditionNotMet headers"]
    error.must_be_kind_of Google::Cloud::FailedPreconditionError

    error.message.must_equal "conditionNotMet"
    error.status_code.must_equal 412
    error.body.must_equal "conditionNotMet body"
    error.header.must_equal ["conditionNotMet headers"]

    error.code.must_be :nil?
    error.details.must_be :nil?
    error.metadata.must_be :nil?
    error.status_details.must_be :nil?
  end

  it "wraps ResourceExhaustedError" do
    error = wrapped_error "exhausted", 429, "exhausted body", ["exhausted headers"]
    error.must_be_kind_of Google::Cloud::ResourceExhaustedError

    error.message.must_equal "exhausted"
    error.status_code.must_equal 429
    error.body.must_equal "exhausted body"
    error.header.must_equal ["exhausted headers"]

    error.code.must_be :nil?
    error.details.must_be :nil?
    error.metadata.must_be :nil?
    error.status_details.must_be :nil?
  end

  it "wraps CanceledError" do
    error = wrapped_error "canceled", 499, "canceled body", ["canceled headers"]
    error.must_be_kind_of Google::Cloud::CanceledError

    error.message.must_equal "canceled"
    error.status_code.must_equal 499
    error.body.must_equal "canceled body"
    error.header.must_equal ["canceled headers"]

    error.code.must_be :nil?
    error.details.must_be :nil?
    error.metadata.must_be :nil?
    error.status_details.must_be :nil?
  end

  it "wraps InternalError" do
    error = wrapped_error "internal", 500, "internal body", ["internal headers"]
    error.must_be_kind_of Google::Cloud::InternalError

    error.message.must_equal "internal"
    error.status_code.must_equal 500
    error.body.must_equal "internal body"
    error.header.must_equal ["internal headers"]

    error.code.must_be :nil?
    error.details.must_be :nil?
    error.metadata.must_be :nil?
    error.status_details.must_be :nil?
  end

  it "wraps UnknownError" do
    skip "don't know how we differentiate this error yet"

    error = wrapped_error "unknown", 500, "unknown body", ["unknown headers"]
    error.must_be_kind_of Google::Cloud::UnknownError

    error.message.must_equal "invalid"
    error.status_code.must_equal 500
    error.body.must_equal "invalid body"
    error.header.must_equal ["invalid headers"]

    error.code.must_be :nil?
    error.details.must_be :nil?
    error.metadata.must_be :nil?
    error.status_details.must_be :nil?
  end

  it "wraps DataLossError" do
    skip "don't know how we differentiate this error yet"

    error = wrapped_error "data loss", 500, "data loss body", ["data loss headers"]
    error.must_be_kind_of Google::Cloud::DataLossError

    error.message.must_equal "data loss"
    error.status_code.must_equal 500
    error.body.must_equal "data loss body"
    error.header.must_equal ["data loss headers"]

    error.code.must_be :nil?
    error.details.must_be :nil?
    error.metadata.must_be :nil?
    error.status_details.must_be :nil?
  end

  it "wraps UnimplementedError" do
    error = wrapped_error "unimplemented", 501, "unimplemented body", ["unimplemented headers"]
    error.must_be_kind_of Google::Cloud::UnimplementedError

    error.message.must_equal "unimplemented"
    error.status_code.must_equal 501
    error.body.must_equal "unimplemented body"
    error.header.must_equal ["unimplemented headers"]

    error.code.must_be :nil?
    error.details.must_be :nil?
    error.metadata.must_be :nil?
    error.status_details.must_be :nil?
  end

  it "wraps UnavailableError" do
    error = wrapped_error "unavailable", 503, "unavailable body", ["unavailable headers"]
    error.must_be_kind_of Google::Cloud::UnavailableError

    error.message.must_equal "unavailable"
    error.status_code.must_equal 503
    error.body.must_equal "unavailable body"
    error.header.must_equal ["unavailable headers"]

    error.code.must_be :nil?
    error.details.must_be :nil?
    error.metadata.must_be :nil?
    error.status_details.must_be :nil?
  end

  it "wraps DeadlineExceededError" do
    error = wrapped_error "exceeded", 504, "exceeded body", ["exceeded headers"]
    error.must_be_kind_of Google::Cloud::DeadlineExceededError

    error.message.must_equal "exceeded"
    error.status_code.must_equal 504
    error.body.must_equal "exceeded body"
    error.header.must_equal ["exceeded headers"]

    error.code.must_be :nil?
    error.details.must_be :nil?
    error.metadata.must_be :nil?
    error.status_details.must_be :nil?
  end

  it "wraps unknown error" do
    error = wrapped_error "unknown", 999, "unknown body", ["unknown headers"]
    error.must_be_kind_of Google::Cloud::Error

    error.message.must_equal "unknown"
    error.status_code.must_equal 999
    error.body.must_equal "unknown body"
    error.header.must_equal ["unknown headers"]

    error.code.must_be :nil?
    error.details.must_be :nil?
    error.metadata.must_be :nil?
    error.status_details.must_be :nil?
  end
end
