# frozen_string_literal: true

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

describe Google::Cloud::Bigtable::Project, :instance, :mock_bigtable do
  it "gets an instance" do
    instance_id = "found-instance"

    get_res = Google::Cloud::Bigtable::Admin::V2::Instance.new(
      instance_hash(
        name: instance_id,
        display_name: "Test instance",
        state: :READY,
        type: :PRODUCTION
      )
    )

    mock = Minitest::Mock.new
    mock.expect :get_instance, get_res, [name: instance_path(instance_id)]
    bigtable.service.mocked_instances = mock
    instance = bigtable.instance(instance_id)

    mock.verify

    _(instance.project_id).must_equal project_id
    _(instance.instance_id).must_equal instance_id
    _(instance.path).must_equal instance_path(instance_id)
    _(instance.display_name).must_equal "Test instance"
    _(instance.state).must_equal :READY
    _(instance.ready?).must_equal true
    _(instance.type).must_equal :PRODUCTION
    _(instance.production?).must_equal true
  end

  it "returns nil when getting an non-existent instance" do
    not_found_instance_id = "not-found-instance"

    stub = Object.new
    def stub.get_instance *args
      raise Google::Cloud::NotFoundError.new("not found")
    end

    bigtable.service.mocked_instances = stub

    instance = bigtable.instance(not_found_instance_id)
    _(instance).must_be :nil?
  end
end
