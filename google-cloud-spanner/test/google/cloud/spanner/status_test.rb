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

describe Google::Cloud::Spanner::Status do
  let(:msg) { "The status message." }

  it "supports code 0" do
    status = from_grpc 0
    _(status.code).must_equal 0
    _(status.description).must_equal "OK"
    _(status.message).must_equal msg
    _(status.details).must_equal []
  end

  it "supports code 1" do
    status = from_grpc 1
    _(status.code).must_equal 1
    _(status.description).must_equal "CANCELLED"
    _(status.message).must_equal msg
    _(status.details).must_equal []
  end

  it "supports code 2" do
    status = from_grpc 2
    _(status.code).must_equal 2
    _(status.description).must_equal "UNKNOWN"
    _(status.message).must_equal msg
    _(status.details).must_equal []
  end

  it "supports code 3" do
    status = from_grpc 3
    _(status.code).must_equal 3
    _(status.description).must_equal "INVALID_ARGUMENT"
    _(status.message).must_equal msg
    _(status.details).must_equal []
  end

  it "supports code 4" do
    status = from_grpc 4
    _(status.code).must_equal 4
    _(status.description).must_equal "DEADLINE_EXCEEDED"
    _(status.message).must_equal msg
    _(status.details).must_equal []
  end

  it "supports code 5" do
    status = from_grpc 5
    _(status.code).must_equal 5
    _(status.description).must_equal "NOT_FOUND"
    _(status.message).must_equal msg
    _(status.details).must_equal []
  end

  it "supports code 6" do
    status = from_grpc 6
    _(status.code).must_equal 6
    _(status.description).must_equal "ALREADY_EXISTS"
    _(status.message).must_equal msg
    _(status.details).must_equal []
  end

  it "supports code 7" do
    status = from_grpc 7
    _(status.code).must_equal 7
    _(status.description).must_equal "PERMISSION_DENIED"
    _(status.message).must_equal msg
    _(status.details).must_equal []
  end

  it "supports code 8" do
    status = from_grpc 8
    _(status.code).must_equal 8
    _(status.description).must_equal "RESOURCE_EXHAUSTED"
    _(status.message).must_equal msg
    _(status.details).must_equal []
  end

  it "supports code 9" do
    status = from_grpc 9
    _(status.code).must_equal 9
    _(status.description).must_equal "FAILED_PRECONDITION"
    _(status.message).must_equal msg
    _(status.details).must_equal []
  end

  it "supports code 10" do
    status = from_grpc 10
    _(status.code).must_equal 10
    _(status.description).must_equal "ABORTED"
    _(status.message).must_equal msg
    _(status.details).must_equal []
  end

  it "supports code 11" do
    status = from_grpc 11
    _(status.code).must_equal 11
    _(status.description).must_equal "OUT_OF_RANGE"
    _(status.message).must_equal msg
    _(status.details).must_equal []
  end

  it "supports code 12" do
    status = from_grpc 12
    _(status.code).must_equal 12
    _(status.description).must_equal "UNIMPLEMENTED"
    _(status.message).must_equal msg
    _(status.details).must_equal []
  end

  it "supports code 13" do
    status = from_grpc 13
    _(status.code).must_equal 13
    _(status.description).must_equal "INTERNAL"
    _(status.message).must_equal msg
    _(status.details).must_equal []
  end

  it "supports code 14" do
    status = from_grpc 14
    _(status.code).must_equal 14
    _(status.description).must_equal "UNAVAILABLE"
    _(status.message).must_equal msg
    _(status.details).must_equal []
  end

  it "supports code 15" do
    status = from_grpc 15
    _(status.code).must_equal 15
    _(status.description).must_equal "DATA_LOSS"
    _(status.message).must_equal msg
    _(status.details).must_equal []
  end

  it "supports code 16" do
    status = from_grpc 16
    _(status.code).must_equal 16
    _(status.description).must_equal "UNAUTHENTICATED"
    _(status.message).must_equal msg
    _(status.details).must_equal []
  end

  def from_grpc code
    Google::Cloud::Spanner::Status.from_grpc grpc_status(code)
  end

  def grpc_status code
    Google::Rpc::Status.new(
      code: code,
      message: msg
    )
  end
end
