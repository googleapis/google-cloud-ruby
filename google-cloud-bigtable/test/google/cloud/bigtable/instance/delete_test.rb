# Copyright 2018 Google LLC
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

describe Google::Cloud::Bigtable::Instance, :delete, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:instance_grpc){
    Google::Bigtable::Admin::V2::Instance.new(
      instance_hash(
        name: instance_id,
        display_name: "Test instance",
        state: :READY,
        type: :DEVELOPMENT,
        labels: { "env" => "test"}
      )
    )
  }
  let(:instance) {
    Google::Cloud::Bigtable::Instance.from_grpc(instance_grpc, bigtable.service)
  }

  it "can delete itself" do
    mock = Minitest::Mock.new
    mock.expect :delete_instance, true, [instance_grpc.name]
    bigtable.service.mocked_instances = mock

    result = instance.delete
    result.must_equal true
    mock.verify
  end
end
