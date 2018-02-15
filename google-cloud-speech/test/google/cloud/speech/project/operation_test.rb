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

describe Google::Cloud::Speech::Project, :operation, :mock_speech do
  let(:op_json) { "{\"name\":\"1234567890\",\"metadata\":{\"typeUrl\":\"type.googleapis.com/google.cloud.speech.V1.AsyncRecognizeMetadata\",\"value\":\"CFQSDAi6jKS/BRCwkLafARoMCIeZpL8FEKjRqswC\"}}" }
  let(:op_grpc) { Google::Longrunning::Operation.decode_json op_json }

  it "retieves an operation by its id" do
    mock = Minitest::Mock.new
    mock.expect :get_operation, op_grpc, ["1234567890"]

    speech.service.mocked_ops = mock
    op = speech.operation "1234567890"
    mock.verify

    op.must_be_kind_of Google::Cloud::Speech::Operation
    op.id.must_equal "1234567890"
    op.wont_be :done?
  end

end
