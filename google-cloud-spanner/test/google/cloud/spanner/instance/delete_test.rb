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

describe Google::Cloud::Spanner::Instance, :delete, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:instance_grpc) { Google::Cloud::Spanner::Admin::Instance::V1::Instance.new instance_hash(name: instance_id) }
  let(:instance) { Google::Cloud::Spanner::Instance.from_grpc instance_grpc, spanner.service }

  it "can delete itself" do
    mock = Minitest::Mock.new
    mock.expect :delete_instance, nil, [{ name: instance_grpc.name }, ::Gapic::CallOptions]
    spanner.service.mocked_instances = mock

    instance.delete

    mock.verify
  end
end
