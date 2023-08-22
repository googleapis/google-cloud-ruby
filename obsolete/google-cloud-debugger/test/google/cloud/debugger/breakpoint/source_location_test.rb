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

describe Google::Cloud::Debugger::Breakpoint::SourceLocation, :mock_debugger do
  let(:source_location_hash) { random_source_location_hash }
  let(:source_location_grpc) {
    Google::Cloud::Debugger::V2::SourceLocation.new source_location_hash
  }
  let(:source_loc) {
    Google::Cloud::Debugger::Breakpoint::SourceLocation.from_grpc source_location_grpc
  }

  it "knows its attributes" do
    _(source_loc.path).must_equal "my_app/my_class.rb"
    _(source_loc.line).must_equal 321
  end

  it "converts to grpc" do
    grpc = source_loc.to_grpc
    _(grpc.path).must_equal source_location_grpc.path
    _(grpc.line).must_equal source_location_grpc.line
  end
 end
