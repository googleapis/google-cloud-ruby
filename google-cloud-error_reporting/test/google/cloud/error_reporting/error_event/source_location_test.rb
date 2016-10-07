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

describe Google::Cloud::ErrorReporting::ErrorEvent::SourceLocation, :mock_error_reporting do
  let(:source_location_json) { random_source_location_hash.to_json}
  let(:source_location_grpc) {
    Google::Devtools::Clouderrorreporting::V1beta1::SourceLocation.decode_json(
      source_location_json
    )
  }
  let(:source_location) {
    Google::Cloud::ErrorReporting::ErrorEvent::SourceLocation.from_grpc(
      source_location_grpc
    )
  }

  it "has_attributes" do
    source_location.file_path.must_equal "/path/to/file.txt"
    source_location.line_number.must_equal 5
    source_location.function_name.must_equal "testee"
  end

  it "to_grpc returns a different grpc object with same attributes" do
    new_source_location_grpc = source_location.to_grpc

    new_source_location_grpc.must_equal source_location_grpc
    assert !new_source_location_grpc.equal?(source_location_grpc)
  end
end