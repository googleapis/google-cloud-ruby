# Copyright 2016 Google LLC
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
require "google/cloud/errors"
require "google/apis/errors"

describe Google::Cloud::Error, :gapi do
  def gapi_error msg, status, body = nil, header = nil
    Google::Apis::Error.new msg, status_code: status, body: body, header: header
  end

  it "identifies InvalidArgumentError" do
    mapped_error = Google::Cloud::Error.from_error gapi_error("invalid", 400)
    mapped_error.must_be_kind_of Google::Cloud::InvalidArgumentError
  end

  it "identifies FailedPreconditionError" do
    skip "don't know how we differentiate this error yet"
    mapped_error = Google::Cloud::Error.from_error gapi_error("precondition", 400)
    mapped_error.must_be_kind_of Google::Cloud::FailedPreconditionError
  end

  it "identifies OutOfRangeError" do
    skip "don't know how we differentiate this error yet"
    mapped_error = Google::Cloud::Error.from_error gapi_error("out of range", 400)
    mapped_error.must_be_kind_of Google::Cloud::OutOfRangeError
  end

  it "identifies UnauthenticatedError" do
    mapped_error = Google::Cloud::Error.from_error gapi_error("unauthenticated", 401)
    mapped_error.must_be_kind_of Google::Cloud::UnauthenticatedError
  end

  it "identifies PermissionDeniedError" do
    mapped_error = Google::Cloud::Error.from_error gapi_error("denied", 403)
    mapped_error.must_be_kind_of Google::Cloud::PermissionDeniedError
  end

  it "identifies NotFoundError" do
    mapped_error = Google::Cloud::Error.from_error gapi_error("notfound", 404)
    mapped_error.must_be_kind_of Google::Cloud::NotFoundError
  end

  it "identifies AlreadyExistsError" do
    mapped_error = Google::Cloud::Error.from_error gapi_error("exists", 409)
    mapped_error.must_be_kind_of Google::Cloud::AlreadyExistsError
  end

  it "identifies AbortedError" do
    skip "don't know how we differentiate this error yet"
    mapped_error = Google::Cloud::Error.from_error gapi_error("aborted", 409)
    mapped_error.must_be_kind_of Google::Cloud::AbortedError
  end

  it "identifies invalid (411) error" do
    # We don't know what to map this error case to
    mapped_error = Google::Cloud::Error.from_error gapi_error("invalid", 411)
    mapped_error.must_be_kind_of Google::Cloud::Error
  end

  it "identifies FailedPreconditionError" do
    mapped_error = Google::Cloud::Error.from_error gapi_error("conditionNotMet", 412)
    mapped_error.must_be_kind_of Google::Cloud::FailedPreconditionError
  end

  it "identifies ResourceExhaustedError" do
    mapped_error = Google::Cloud::Error.from_error gapi_error("exhausted", 429)
    mapped_error.must_be_kind_of Google::Cloud::ResourceExhaustedError
  end

  it "identifies CanceledError" do
    mapped_error = Google::Cloud::Error.from_error gapi_error("canceled", 499)
    mapped_error.must_be_kind_of Google::Cloud::CanceledError
  end

  it "identifies InternalError" do
    mapped_error = Google::Cloud::Error.from_error gapi_error("internal", 500)
    mapped_error.must_be_kind_of Google::Cloud::InternalError
  end

  it "identifies UnknownError" do
    skip "don't know how we differentiate this error yet"
    mapped_error = Google::Cloud::Error.from_error gapi_error("unknown", 500)
    mapped_error.must_be_kind_of Google::Cloud::UnknownError
  end

  it "identifies DataLossError" do
    skip "don't know how we differentiate this error yet"
    mapped_error = Google::Cloud::Error.from_error gapi_error("data loss", 500)
    mapped_error.must_be_kind_of Google::Cloud::DataLossError
  end

  it "identifies UnimplementedError" do
    mapped_error = Google::Cloud::Error.from_error gapi_error("unimplemented", 501)
    mapped_error.must_be_kind_of Google::Cloud::UnimplementedError
  end

  it "identifies UnavailableError" do
    mapped_error = Google::Cloud::Error.from_error gapi_error("unavailable", 503)
    mapped_error.must_be_kind_of Google::Cloud::UnavailableError
  end

  it "identifies DeadlineExceededError" do
    mapped_error = Google::Cloud::Error.from_error gapi_error("exceeded", 504)
    mapped_error.must_be_kind_of Google::Cloud::DeadlineExceededError
  end

  it "identifies unknown error" do
    mapped_error = Google::Cloud::Error.from_error gapi_error("unknown", 999)
    mapped_error.must_be_kind_of Google::Cloud::Error
  end
end
