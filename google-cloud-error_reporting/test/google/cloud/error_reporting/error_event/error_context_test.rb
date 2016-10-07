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

describe Google::Cloud::ErrorReporting::ErrorEvent::ErrorContext, :mock_error_reporting do
  let(:error_context_json) { random_error_context_hash.to_json}
  let(:error_context_grpc) {
    Google::Devtools::Clouderrorreporting::V1beta1::ErrorContext.decode_json error_context_json
  }
  let(:error_context) {
    Google::Cloud::ErrorReporting::ErrorEvent::ErrorContext.from_grpc error_context_grpc
  }

  it "has_attributes" do
    error_context.user.must_equal "testerson"
    error_context.http_request_context.must_be_kind_of(
      Google::Cloud::ErrorReporting::ErrorEvent::HttpRequestContext
    )
    error_context.source_location.must_be_kind_of(
      Google::Cloud::ErrorReporting::ErrorEvent::SourceLocation
    )
  end

  it "to_grpc returns a different grpc object with same attributes" do
    new_error_context_grpc = error_context.to_grpc

    new_error_context_grpc.must_equal error_context_grpc
    assert !new_error_context_grpc.equal?(error_context_grpc)
  end
end
