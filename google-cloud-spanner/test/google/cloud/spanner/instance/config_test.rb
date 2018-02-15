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

describe Google::Cloud::Spanner::Instance, :config, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:instance_json) { instance_hash(name: instance_id).to_json }
  let(:instance_grpc) { Google::Spanner::Admin::Instance::V1::Instance.decode_json instance_json }
  let(:instance) { Google::Cloud::Spanner::Instance.from_grpc instance_grpc, spanner.service }
  let(:instance_config_json) { instance_config_hash.to_json }

  it "gets an instance config object" do
    get_res = Google::Spanner::Admin::Instance::V1::InstanceConfig.decode_json instance_config_json
    mock = Minitest::Mock.new
    mock.expect :get_instance_config, get_res, [instance_grpc.config]
    spanner.service.mocked_instances = mock

    config = instance.config

    mock.verify

    config.must_be_kind_of Google::Cloud::Spanner::Instance::Config
    config.project_id.must_equal project
    config.instance_config_id.must_equal instance_config_hash[:name].split("/").last
    config.path.must_equal instance_config_hash[:name]
    config.name.must_equal instance_config_hash[:displayName]
    config.display_name.must_equal instance_config_hash[:displayName]
  end
end
