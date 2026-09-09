# Copyright 2024 Google LLC
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
require "google/cloud/errors"
require "grpc/errors"
require "google/gax/errors"
require "google/rpc/status_pb"

# These test confirm that REST exceptions corresponding to various HTTP status codes
# are correctly wrapped
describe Google::Cloud::Error, :rest_errors do
  it "identifies CanceledError" do
    mapped_error = wrapped_rest_error gapic_rest_error(status_code: 499)
    _(mapped_error).must_be_kind_of Google::Cloud::CanceledError
  end

  it "identifies InvalidArgumentError" do
    mapped_error = wrapped_rest_error gapic_rest_error(status_code: 400)
    _(mapped_error).must_be_kind_of Google::Cloud::InvalidArgumentError
  end

  it "identifies DeadlineExceededError" do
    mapped_error = wrapped_rest_error gapic_rest_error(status_code: 504)
    _(mapped_error).must_be_kind_of Google::Cloud::DeadlineExceededError
  end

  it "identifies NotFoundError" do
    mapped_error = wrapped_rest_error gapic_rest_error(status_code: 404)
    _(mapped_error).must_be_kind_of Google::Cloud::NotFoundError
  end

  it "identifies AlreadyExistsError" do
    mapped_error = wrapped_rest_error gapic_rest_error(status_code: 409)
    _(mapped_error).must_be_kind_of Google::Cloud::AlreadyExistsError
  end

  it "identifies PermissionDeniedError" do
    mapped_error = wrapped_rest_error gapic_rest_error(status_code: 403)
    _(mapped_error).must_be_kind_of Google::Cloud::PermissionDeniedError
  end

  it "identifies ResourceExhaustedError" do
    mapped_error = wrapped_rest_error gapic_rest_error(status_code: 429)
    _(mapped_error).must_be_kind_of Google::Cloud::ResourceExhaustedError
  end

  it "identifies FailedPreconditionError" do
    mapped_error = wrapped_rest_error gapic_rest_error(status_code: 412)
    _(mapped_error).must_be_kind_of Google::Cloud::FailedPreconditionError
  end

  it "identifies UnimplementedError" do
    mapped_error = wrapped_rest_error gapic_rest_error(status_code: 501)
    _(mapped_error).must_be_kind_of Google::Cloud::UnimplementedError
  end

  it "identifies InternalError" do
    mapped_error = wrapped_rest_error gapic_rest_error(status_code: 500)
    _(mapped_error).must_be_kind_of Google::Cloud::InternalError
  end

  it "identifies UnavailableError" do
    mapped_error = wrapped_rest_error gapic_rest_error(status_code: 503)
    _(mapped_error).must_be_kind_of Google::Cloud::UnavailableError
  end

  it "identifies unknown error" do
    # We don't know what to map this error case to
    mapped_error = wrapped_rest_error gapic_rest_error(status_code: 0)
    _(mapped_error).must_be_kind_of Google::Cloud::Error
  end
end
