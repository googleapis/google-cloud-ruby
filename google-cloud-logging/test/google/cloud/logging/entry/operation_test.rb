# Copyright 2016 Google LLC
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

describe Google::Cloud::Logging::Entry::Operation, :mock_logging do
  let(:operation_json) { random_operation_hash.to_json }
  let(:operation_grpc) { Google::Logging::V2::LogEntryOperation.decode_json operation_json }
  let(:operation) { Google::Cloud::Logging::Entry::Operation.from_grpc operation_grpc }

  it "has attributes" do
    operation.id.must_equal "xyz789"
    operation.producer.must_equal "MyApp.MyClass#my_method"
    operation.first.must_equal false
    operation.last.must_equal false
  end
end
