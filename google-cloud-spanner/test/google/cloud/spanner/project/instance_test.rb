# Copyright 2016 Google LLC
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

describe Google::Cloud::Spanner::Project, :instance, :mock_spanner do
  it "gets an instance" do
    instance_id = "found-instance"

    get_res = Google::Spanner::Admin::Instance::V1::Instance.decode_json instance_hash(name: instance_id).to_json
    mock = Minitest::Mock.new
    mock.expect :get_instance, get_res, [instance_path(instance_id)]
    spanner.service.mocked_instances = mock

    instance = spanner.instance instance_id

    mock.verify

    instance.project_id.must_equal project
    instance.instance_id.must_equal instance_id
    instance.path.must_equal instance_path(instance_id)
    instance.name.must_equal instance_id.split("-").map(&:capitalize).join(" ")
    instance.display_name.must_equal instance_id.split("-").map(&:capitalize).join(" ")
  end

  it "returns nil when getting an non-existent instance" do
    not_found_instance_id = "not-found-instance"

    stub = Object.new
    def stub.get_instance *args
      gax_error = Google::Gax::GaxError.new "not found"
      gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
      raise gax_error
    end
    spanner.service.mocked_instances = stub

    instance = spanner.instance not_found_instance_id
    instance.must_be :nil?
  end
end
