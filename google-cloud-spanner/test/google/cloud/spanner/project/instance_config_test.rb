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
  it "gets an instance config" do
    config_name = "found-config"

    get_res = Google::Cloud::Spanner::Admin::Instance::V1::InstanceConfig.new instance_config_hash
    mock = Minitest::Mock.new
    mock.expect :get_instance_config, get_res, [{ name: instance_config_path(config_name) }, ::Gapic::CallOptions]
    spanner.service.mocked_instances = mock

    config = spanner.instance_config config_name

    mock.verify

    _(config.project_id).must_equal project
    _(config.instance_config_id).must_equal instance_config_hash[:name].split("/").last
    _(config.path).must_equal instance_config_hash[:name]
    _(config.name).must_equal instance_config_hash[:display_name]
    _(config.display_name).must_equal instance_config_hash[:display_name]
  end

  it "returns nil when getting an non-existent instance config" do
    not_found_config_name = "not-found-config"

    stub = Object.new
    def stub.get_instance_config *args
      gax_error = Google::Cloud::NotFoundError.new "not found"
      gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
      raise gax_error
    end
    spanner.service.mocked_instances = stub

    config = spanner.instance_config not_found_config_name
    _(config).must_be :nil?
  end
end
