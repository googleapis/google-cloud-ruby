# Copyright 2021 Google LLC
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

require "google/cloud/spanner/admin/instance"
require "spanner_helper"

describe "Spanner Instances Client", :spanner do
  let(:instance_id) { "#{$spanner_instance_id}-crud" }
  let(:client) { Google::Cloud::Spanner::Admin::Instance.instance_admin project_id: spanner.project }
  let(:project_path) { client.project_path project: spanner.project }
  let(:instance_path) { client.instance_path project: spanner.project, instance: instance_id }

  after do
    client.delete_instance name: instance_path
  end

  it "creates, gets, updates, and deletes an instance" do
    instance_config_path = client.instance_config_path project: spanner.project, instance_config: "regional-asia-south1"

    instance = Google::Cloud::Spanner::Admin::Instance::V1::Instance.new name: instance_path,
                                                                         config: instance_config_path,
                                                                         display_name: instance_id,
                                                                         node_count: 1

    request = Google::Cloud::Spanner::Admin::Instance::V1::CreateInstanceRequest.new parent: project_path,
                                                                                     instance_id: instance_id,
                                                                                     instance: instance                   

    job = client.create_instance request
    _(job).wont_be :done? unless emulator_enabled?
    job.wait_until_done!

    _(job).must_be :done?
    raise Google::Cloud::Error.from_error(job.error) if job.error?
    instance = job.results
    _(instance).wont_be :nil?
    _(instance).must_be_kind_of Google::Cloud::Spanner::Admin::Instance::V1::Instance
    _(instance.name).must_equal instance_path
    _(instance.config).must_equal instance_config_path

    instance = client.get_instance name: instance_path
    _(instance).must_be_kind_of Google::Cloud::Spanner::Admin::Instance::V1::Instance

    # skipping the update instance test as it's not supported by emulator right now.
    # update display_name of the instance
    # instance.display_name = "#{instance.display_name}-updated"
    # request = Google::Cloud::Spanner::Admin::Instance::V1::UpdateInstanceRequest.new instance: instance,
    #                                                                                  field_mask: { paths: ["display_name"] }

    # job2 = client.update_instance request

    # _(job2).wont_be :done? unless emulator_enabled?
    # job2.wait_until_done!

    # _(job2).must_be :done?

    client.delete_instance name: instance_path
    assert_raises Google::Cloud::NotFoundError do
      client.get_instance name: instance_path
    end
  end

  it "lists instances" do
    all_instances = client.list_instances parent: project_path

    _(all_instances.response).wont_be :nil?
    all_instances.each do |instance|
      _(instance).must_be_kind_of Google::Cloud::Spanner::Admin::Instance::V1::Instance
    end
  end
end