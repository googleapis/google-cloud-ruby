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
    _(error).must_be_kind_of Google::Cloud::InvalidArgumentError

    _(error.message).must_equal "invalid"
    _(error.status_code).must_equal 400
    _(error.body).must_equal "invalid body"
    _(error.header).must_equal ["invalid headers"]

    _(error.code).must_be :nil?
    _(error.details).must_be :nil?
    _(error.metadata).must_be :nil?
    _(error.status_details).must_be :nil?
  end

  it "wraps FailedPreconditionError" do
    skip "don't know how we differentiate this error yet"

    error = wrapped_error "precondition", 400, "precondition body", ["precondition headers"]
    _(error).must_be_kind_of Google::Cloud::FailedPreconditionError

    _(error.message).must_equal "precondition"
    _(error.status_code).must_equal 400
    _(error.body).must_equal "precondition body"
    _(error.header).must_equal ["precondition headers"]

    _(error.code).must_be :nil?
    _(error.details).must_be :nil?
    _(error.metadata).must_be :nil?
    _(error.status_details).must_be :nil?
  end

  it "wraps OutOfRangeError" do
    skip "don't know how we differentiate this error yet"

    error = wrapped_error "out of range", 400, "out of range body", ["out of range headers"]
    _(error).must_be_kind_of Google::Cloud::OutOfRangeError

    _(error.message).must_equal "out of range"
    _(error.status_code).must_equal 400
    _(error.body).must_equal "out of range body"
    _(error.header).must_equal ["out of range headers"]

    _(error.code).must_be :nil?
    _(error.details).must_be :nil?
    _(error.metadata).must_be :nil?
    _(error.status_details).must_be :nil?
  end

  it "wraps UnauthenticatedError" do
    error = wrapped_error "unauthenticated", 401, "unauthenticated body", ["unauthenticated headers"]
    _(error).must_be_kind_of Google::Cloud::UnauthenticatedError

    _(error.message).must_equal "unauthenticated"
    _(error.status_code).must_equal 401
    _(error.body).must_equal "unauthenticated body"
    _(error.header).must_equal ["unauthenticated headers"]

    _(error.code).must_be :nil?
    _(error.details).must_be :nil?
    _(error.metadata).must_be :nil?
    _(error.status_details).must_be :nil?
  end

  it "wraps PermissionDeniedError" do
    error = wrapped_error "denied", 403, "denied body", ["denied headers"]
    _(error).must_be_kind_of Google::Cloud::PermissionDeniedError

    _(error.message).must_equal "denied"
    _(error.status_code).must_equal 403
    _(error.body).must_equal "denied body"
    _(error.header).must_equal ["denied headers"]

    _(error.code).must_be :nil?
    _(error.details).must_be :nil?
    _(error.metadata).must_be :nil?
    _(error.status_details).must_be :nil?
  end

  it "wraps NotFoundError" do
    error = wrapped_error "notfound", 404, "notfound body", ["notfound headers"]
    _(error).must_be_kind_of Google::Cloud::NotFoundError

    _(error.message).must_equal "notfound"
    _(error.status_code).must_equal 404
    _(error.body).must_equal "notfound body"
    _(error.header).must_equal ["notfound headers"]

    _(error.code).must_be :nil?
    _(error.details).must_be :nil?
    _(error.metadata).must_be :nil?
    _(error.status_details).must_be :nil?
  end

  it "wraps AlreadyExistsError" do
    error = wrapped_error "exists", 409, "exists body", ["exists headers"]
    _(error).must_be_kind_of Google::Cloud::AlreadyExistsError

    _(error.message).must_equal "exists"
    _(error.status_code).must_equal 409
    _(error.body).must_equal "exists body"
    _(error.header).must_equal ["exists headers"]

    _(error.code).must_be :nil?
    _(error.details).must_be :nil?
    _(error.metadata).must_be :nil?
    _(error.status_details).must_be :nil?
  end

  it "wraps AbortedError" do
    skip "don't know how we differentiate this error yet"

    error = wrapped_error "aborted", 409, "aborted body", ["aborted headers"]
    _(error).must_be_kind_of Google::Cloud::AbortedError

    _(error.message).must_equal "aborted"
    _(error.status_code).must_equal 409
    _(error.body).must_equal "aborted body"
    _(error.header).must_equal ["aborted headers"]

    _(error.code).must_be :nil?
    _(error.details).must_be :nil?
    _(error.metadata).must_be :nil?
    _(error.status_details).must_be :nil?
  end

  it "wraps invalid (411) error" do
    # We don't know what to map this error case to
    error = wrapped_error "invalid", 411, "invalid body", ["invalid headers"]
    _(error).must_be_kind_of Google::Cloud::Error

    _(error.message).must_equal "invalid"
    _(error.status_code).must_equal 411
    _(error.body).must_equal "invalid body"
    _(error.header).must_equal ["invalid headers"]

    _(error.code).must_be :nil?
    _(error.details).must_be :nil?
    _(error.metadata).must_be :nil?
    _(error.status_details).must_be :nil?
  end

  it "wraps FailedPreconditionError" do
    error = wrapped_error "conditionNotMet", 412, "conditionNotMet body", ["conditionNotMet headers"]
    _(error).must_be_kind_of Google::Cloud::FailedPreconditionError

    _(error.message).must_equal "conditionNotMet"
    _(error.status_code).must_equal 412
    _(error.body).must_equal "conditionNotMet body"
    _(error.header).must_equal ["conditionNotMet headers"]

    _(error.code).must_be :nil?
    _(error.details).must_be :nil?
    _(error.metadata).must_be :nil?
    _(error.status_details).must_be :nil?
  end

  it "wraps ResourceExhaustedError" do
    error = wrapped_error "exhausted", 429, "exhausted body", ["exhausted headers"]
    _(error).must_be_kind_of Google::Cloud::ResourceExhaustedError

    _(error.message).must_equal "exhausted"
    _(error.status_code).must_equal 429
    _(error.body).must_equal "exhausted body"
    _(error.header).must_equal ["exhausted headers"]

    _(error.code).must_be :nil?
    _(error.details).must_be :nil?
    _(error.metadata).must_be :nil?
    _(error.status_details).must_be :nil?
  end

  it "wraps CanceledError" do
    error = wrapped_error "canceled", 499, "canceled body", ["canceled headers"]
    _(error).must_be_kind_of Google::Cloud::CanceledError

    _(error.message).must_equal "canceled"
    _(error.status_code).must_equal 499
    _(error.body).must_equal "canceled body"
    _(error.header).must_equal ["canceled headers"]

    _(error.code).must_be :nil?
    _(error.details).must_be :nil?
    _(error.metadata).must_be :nil?
    _(error.status_details).must_be :nil?
  end

  it "wraps InternalError" do
    error = wrapped_error "internal", 500, "internal body", ["internal headers"]
    _(error).must_be_kind_of Google::Cloud::InternalError

    _(error.message).must_equal "internal"
    _(error.status_code).must_equal 500
    _(error.body).must_equal "internal body"
    _(error.header).must_equal ["internal headers"]

    _(error.code).must_be :nil?
    _(error.details).must_be :nil?
    _(error.metadata).must_be :nil?
    _(error.status_details).must_be :nil?
  end

  it "wraps UnknownError" do
    skip "don't know how we differentiate this error yet"

    error = wrapped_error "unknown", 500, "unknown body", ["unknown headers"]
    _(error).must_be_kind_of Google::Cloud::UnknownError

    _(error.message).must_equal "invalid"
    _(error.status_code).must_equal 500
    _(error.body).must_equal "invalid body"
    _(error.header).must_equal ["invalid headers"]

    _(error.code).must_be :nil?
    _(error.details).must_be :nil?
    _(error.metadata).must_be :nil?
    _(error.status_details).must_be :nil?
  end

  it "wraps DataLossError" do
    skip "don't know how we differentiate this error yet"

    error = wrapped_error "data loss", 500, "data loss body", ["data loss headers"]
    _(error).must_be_kind_of Google::Cloud::DataLossError

    _(error.message).must_equal "data loss"
    _(error.status_code).must_equal 500
    _(error.body).must_equal "data loss body"
    _(error.header).must_equal ["data loss headers"]

    _(error.code).must_be :nil?
    _(error.details).must_be :nil?
    _(error.metadata).must_be :nil?
    _(error.status_details).must_be :nil?
  end

  it "wraps UnimplementedError" do
    error = wrapped_error "unimplemented", 501, "unimplemented body", ["unimplemented headers"]
    _(error).must_be_kind_of Google::Cloud::UnimplementedError

    _(error.message).must_equal "unimplemented"
    _(error.status_code).must_equal 501
    _(error.body).must_equal "unimplemented body"
    _(error.header).must_equal ["unimplemented headers"]

    _(error.code).must_be :nil?
    _(error.details).must_be :nil?
    _(error.metadata).must_be :nil?
    _(error.status_details).must_be :nil?
  end

  it "wraps UnavailableError" do
    error = wrapped_error "unavailable", 503, "unavailable body", ["unavailable headers"]
    _(error).must_be_kind_of Google::Cloud::UnavailableError

    _(error.message).must_equal "unavailable"
    _(error.status_code).must_equal 503
    _(error.body).must_equal "unavailable body"
    _(error.header).must_equal ["unavailable headers"]

    _(error.code).must_be :nil?
    _(error.details).must_be :nil?
    _(error.metadata).must_be :nil?
    _(error.status_details).must_be :nil?
  end

  it "wraps DeadlineExceededError" do
    error = wrapped_error "exceeded", 504, "exceeded body", ["exceeded headers"]
    _(error).must_be_kind_of Google::Cloud::DeadlineExceededError

    _(error.message).must_equal "exceeded"
    _(error.status_code).must_equal 504
    _(error.body).must_equal "exceeded body"
    _(error.header).must_equal ["exceeded headers"]

    _(error.code).must_be :nil?
    _(error.details).must_be :nil?
    _(error.metadata).must_be :nil?
    _(error.status_details).must_be :nil?
  end

  it "wraps unknown error" do
    error = wrapped_error "unknown", 999, "unknown body", ["unknown headers"]
    _(error).must_be_kind_of Google::Cloud::Error

    _(error.message).must_equal "unknown"
    _(error.status_code).must_equal 999
    _(error.body).must_equal "unknown body"
    _(error.header).must_equal ["unknown headers"]

    _(error.code).must_be :nil?
    _(error.details).must_be :nil?
    _(error.metadata).must_be :nil?
    _(error.status_details).must_be :nil?
  end
end
