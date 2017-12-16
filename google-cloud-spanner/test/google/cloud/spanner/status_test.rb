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
    status.code.must_equal 0
    status.description.must_equal "OK"
    status.message.must_equal msg
    status.details.must_equal []
  end

  it "supports code 1" do
    status = from_grpc 1
    status.code.must_equal 1
    status.description.must_equal "CANCELLED"
    status.message.must_equal msg
    status.details.must_equal []
  end

  it "supports code 2" do
    status = from_grpc 2
    status.code.must_equal 2
    status.description.must_equal "UNKNOWN"
    status.message.must_equal msg
    status.details.must_equal []
  end

  it "supports code 3" do
    status = from_grpc 3
    status.code.must_equal 3
    status.description.must_equal "INVALID_ARGUMENT"
    status.message.must_equal msg
    status.details.must_equal []
  end

  it "supports code 4" do
    status = from_grpc 4
    status.code.must_equal 4
    status.description.must_equal "DEADLINE_EXCEEDED"
    status.message.must_equal msg
    status.details.must_equal []
  end

  it "supports code 5" do
    status = from_grpc 5
    status.code.must_equal 5
    status.description.must_equal "NOT_FOUND"
    status.message.must_equal msg
    status.details.must_equal []
  end

  it "supports code 6" do
    status = from_grpc 6
    status.code.must_equal 6
    status.description.must_equal "ALREADY_EXISTS"
    status.message.must_equal msg
    status.details.must_equal []
  end

  it "supports code 7" do
    status = from_grpc 7
    status.code.must_equal 7
    status.description.must_equal "PERMISSION_DENIED"
    status.message.must_equal msg
    status.details.must_equal []
  end

  it "supports code 8" do
    status = from_grpc 8
    status.code.must_equal 8
    status.description.must_equal "RESOURCE_EXHAUSTED"
    status.message.must_equal msg
    status.details.must_equal []
  end

  it "supports code 9" do
    status = from_grpc 9
    status.code.must_equal 9
    status.description.must_equal "FAILED_PRECONDITION"
    status.message.must_equal msg
    status.details.must_equal []
  end

  it "supports code 10" do
    status = from_grpc 10
    status.code.must_equal 10
    status.description.must_equal "ABORTED"
    status.message.must_equal msg
    status.details.must_equal []
  end

  it "supports code 11" do
    status = from_grpc 11
    status.code.must_equal 11
    status.description.must_equal "OUT_OF_RANGE"
    status.message.must_equal msg
    status.details.must_equal []
  end

  it "supports code 12" do
    status = from_grpc 12
    status.code.must_equal 12
    status.description.must_equal "UNIMPLEMENTED"
    status.message.must_equal msg
    status.details.must_equal []
  end

  it "supports code 13" do
    status = from_grpc 13
    status.code.must_equal 13
    status.description.must_equal "INTERNAL"
    status.message.must_equal msg
    status.details.must_equal []
  end

  it "supports code 14" do
    status = from_grpc 14
    status.code.must_equal 14
    status.description.must_equal "UNAVAILABLE"
    status.message.must_equal msg
    status.details.must_equal []
  end

  it "supports code 15" do
    status = from_grpc 15
    status.code.must_equal 15
    status.description.must_equal "DATA_LOSS"
    status.message.must_equal msg
    status.details.must_equal []
  end

  it "supports code 16" do
    status = from_grpc 16
    status.code.must_equal 16
    status.description.must_equal "UNAUTHENTICATED"
    status.message.must_equal msg
    status.details.must_equal []
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
