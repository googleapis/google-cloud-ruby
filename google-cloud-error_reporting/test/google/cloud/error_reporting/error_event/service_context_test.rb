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

describe Google::Cloud::ErrorReporting::ErrorEvent::ServiceContext, :mock_error_reporting do
  let(:service_context_json) { random_service_context_hash.to_json}
  let(:service_context_grpc) {
    Google::Devtools::Clouderrorreporting::V1beta1::ServiceContext.decode_json(
      service_context_json
    )
  }
  let(:service_context) {
    Google::Cloud::ErrorReporting::ErrorEvent::ServiceContext.from_grpc(
      service_context_grpc
    )
  }

  it "has_attributes" do
    service_context.service.must_equal "default"
    service_context.version.must_equal "v1"
  end

  it "to_grpc returns a different grpc object with same attributes" do
    new_service_context_grpc = service_context.to_grpc

    new_service_context_grpc.must_equal service_context_grpc
    assert !new_service_context_grpc.equal?(service_context_grpc)
  end
end
