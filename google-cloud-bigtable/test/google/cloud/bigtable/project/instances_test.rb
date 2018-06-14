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

describe Google::Cloud::Bigtable::Project, :tables, :mock_bigtable do
  let(:first_page) do
    h = instances_hash
    h[:next_page_token] = "next_page_token"
    h[:failed_locations] = []
    Google::Bigtable::Admin::V2::ListInstancesResponse.new(h)
  end
  let(:second_page) do
    h = instances_hash(start_id: 10)
    h[:next_page_token] = "second_page_token"
    h[:failed_locations] = []
    Google::Bigtable::Admin::V2::ListInstancesResponse.new(h)
  end

  let(:last_page) do
    h = instances_hash(start_id: 20)
    h[:instances].pop
    h[:failed_locations] = []
    Google::Bigtable::Admin::V2::ListInstancesResponse.new(h)
  end

  it "list instances" do
    mock = Minitest::Mock.new
    mock.expect :list_instances, first_page, [ project_path, page_token: nil ]
    bigtable.service.mocked_instances = mock

    instances = bigtable.instances

    mock.verify

    instances.size.must_equal 3
  end

  it "paginates instances" do
    mock = Minitest::Mock.new
    mock.expect :list_instances, first_page, [project_path, page_token: nil]
    mock.expect :list_instances, last_page, [project_path, page_token: "next_page_token"]
    bigtable.service.mocked_instances = mock

    first_instances = bigtable.instances
    second_instances = bigtable.instances(token: first_page.next_page_token)

    mock.verify

    first_instances.size.must_equal 3
    token = first_instances.token
    token.wont_be :nil?
    token.must_equal "next_page_token"

    second_instances.size.must_equal 2
    second_instances.token.must_be :nil?
  end

  it "paginates instances with next? and next" do
    mock = Minitest::Mock.new
    mock.expect :list_instances, first_page, [project_path, page_token: nil]
    mock.expect :list_instances, last_page, [project_path, page_token: "next_page_token"]
    bigtable.service.mocked_instances = mock

    first_instances = bigtable.instances
    second_instances = first_instances.next

    mock.verify

    first_instances.size.must_equal 3
    first_instances.next?.must_equal true

    second_instances.size.must_equal 2
    second_instances.next?.must_equal false
  end

  it "paginates instances with all" do
    mock = Minitest::Mock.new
    mock.expect :list_instances, first_page, [project_path, page_token: nil]
    mock.expect :list_instances, last_page, [project_path, page_token: "next_page_token"]
    bigtable.service.mocked_instances = mock

    instances = bigtable.instances.all.to_a

    mock.verify

    instances.size.must_equal 5
  end

  it "iterates instances with all using Enumerator" do
    mock = Minitest::Mock.new
    mock.expect :list_instances, first_page, [project_path, page_token: nil]
    mock.expect :list_instances, last_page, [project_path, page_token: "next_page_token"]
    bigtable.service.mocked_instances = mock

    instances = bigtable.instances.all.take(5)

    mock.verify

    instances.size.must_equal 5
  end
end
