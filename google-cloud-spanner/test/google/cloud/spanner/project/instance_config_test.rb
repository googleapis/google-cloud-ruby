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

describe Google::Cloud::Spanner::Project, :instance_config, :mock_spanner do
  let(:instance_config_json) { instance_config_hash.to_json }

  it "gets an instance config" do
    config_name = "found-config"


    get_res = Google::Spanner::Admin::Instance::V1::InstanceConfig.decode_json instance_config_json
    mock = Minitest::Mock.new
    mock.expect :get_instance_config, get_res, [instance_config_path(config_name)]
    spanner.service.mocked_instances = mock

    config = spanner.instance_config config_name

    mock.verify

    config.project_id.must_equal project
    config.instance_config_id.must_equal instance_config_hash[:name].split("/").last
    config.path.must_equal instance_config_hash[:name]
    config.name.must_equal instance_config_hash[:displayName]
    config.display_name.must_equal instance_config_hash[:displayName]
  end

  it "returns nil when getting an non-existent instance config" do
    not_found_config_name = "not-found-config"

    stub = Object.new
    def stub.get_instance_config *args
      gax_error = Google::Gax::GaxError.new "not found"
      gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
      raise gax_error
    end
    spanner.service.mocked_instances = stub

    config = spanner.instance_config not_found_config_name
    config.must_be :nil?
  end
end
