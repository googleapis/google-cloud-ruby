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
  let(:instance_grpc) { Google::Cloud::Spanner::Admin::Instance::V1::Instance.new instance_hash(name: instance_id) }
  let(:instance) { Google::Cloud::Spanner::Instance.from_grpc instance_grpc, spanner.service }

  it "gets an instance config object" do
    get_res = Google::Cloud::Spanner::Admin::Instance::V1::InstanceConfig.new instance_config_hash
    mock = Minitest::Mock.new
    mock.expect :get_instance_config, get_res, [name: instance_grpc.config]
    spanner.service.mocked_instances = mock

    config = instance.config

    mock.verify

    _(config).must_be_kind_of Google::Cloud::Spanner::Instance::Config
    _(config.project_id).must_equal project
    _(config.instance_config_id).must_equal instance_config_hash[:name].split("/").last
    _(config.path).must_equal instance_config_hash[:name]
    _(config.name).must_equal instance_config_hash[:display_name]
    _(config.display_name).must_equal instance_config_hash[:display_name]
  end
end
