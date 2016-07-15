# Copyright 2016 Google Inc. All rights reserved.
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
require "gcloud/errors"
require "grpc/errors"

describe Gcloud::Error, :grpc do
  it "identifies CanceledError" do
    mapped_error = Gcloud::Error.from_error GRPC::BadStatus.new(1, "cancelled")
    mapped_error.must_be_kind_of Gcloud::CanceledError
  end

  it "identifies UnknownError" do
    mapped_error = Gcloud::Error.from_error GRPC::BadStatus.new(2, "unknown")
    mapped_error.must_be_kind_of Gcloud::UnknownError
  end

  it "identifies InvalidArgumentError" do
    mapped_error = Gcloud::Error.from_error GRPC::BadStatus.new(3, "invalid")
    mapped_error.must_be_kind_of Gcloud::InvalidArgumentError
  end

  it "identifies DeadlineExceededError" do
    mapped_error = Gcloud::Error.from_error GRPC::BadStatus.new(4, "exceeded")
    mapped_error.must_be_kind_of Gcloud::DeadlineExceededError
  end

  it "identifies NotFoundError" do
    mapped_error = Gcloud::Error.from_error GRPC::BadStatus.new(5, "not found")
    mapped_error.must_be_kind_of Gcloud::NotFoundError
  end

  it "identifies AlreadyExistsError" do
    mapped_error = Gcloud::Error.from_error GRPC::BadStatus.new(6, "exists")
    mapped_error.must_be_kind_of Gcloud::AlreadyExistsError
  end

  it "identifies PermissionDeniedError" do
    mapped_error = Gcloud::Error.from_error GRPC::BadStatus.new(7, "denied")
    mapped_error.must_be_kind_of Gcloud::PermissionDeniedError
  end

  it "identifies ResourceExhaustedError" do
    mapped_error = Gcloud::Error.from_error GRPC::BadStatus.new(8, "exhausted")
    mapped_error.must_be_kind_of Gcloud::ResourceExhaustedError
  end

  it "identifies FailedPreconditionError" do
    mapped_error = Gcloud::Error.from_error GRPC::BadStatus.new(9, "precondition")
    mapped_error.must_be_kind_of Gcloud::FailedPreconditionError
  end

  it "identifies AbortedError" do
    mapped_error = Gcloud::Error.from_error GRPC::BadStatus.new(10, "aborted")
    mapped_error.must_be_kind_of Gcloud::AbortedError
  end

  it "identifies OutOfRangeError" do
    mapped_error = Gcloud::Error.from_error GRPC::BadStatus.new(11, "out of range")
    mapped_error.must_be_kind_of Gcloud::OutOfRangeError
  end

  it "identifies UnimplementedError" do
    mapped_error = Gcloud::Error.from_error GRPC::BadStatus.new(12, "unimplemented")
    mapped_error.must_be_kind_of Gcloud::UnimplementedError
  end

  it "identifies InternalError" do
    mapped_error = Gcloud::Error.from_error GRPC::BadStatus.new(13, "InternalError")
    mapped_error.must_be_kind_of Gcloud::InternalError
  end

  it "identifies UnavailableError" do
    mapped_error = Gcloud::Error.from_error GRPC::BadStatus.new(14, "unavailable")
    mapped_error.must_be_kind_of Gcloud::UnavailableError
  end

  it "identifies DataLossError" do
    mapped_error = Gcloud::Error.from_error GRPC::BadStatus.new(15, "data loss")
    mapped_error.must_be_kind_of Gcloud::DataLossError
  end

  it "identifies UnauthenticatedError" do
    mapped_error = Gcloud::Error.from_error GRPC::BadStatus.new(16, "unauthenticated")
    mapped_error.must_be_kind_of Gcloud::UnauthenticatedError
  end

  it "identifies unknown error" do
    # We don't know what to map this error case to
    mapped_error = Gcloud::Error.from_error GRPC::BadStatus.new(0, "unknown")
    mapped_error.must_be_kind_of Gcloud::Error

    mapped_error = Gcloud::Error.from_error GRPC::BadStatus.new(17, "unknown")
    mapped_error.must_be_kind_of Gcloud::Error
  end
end
