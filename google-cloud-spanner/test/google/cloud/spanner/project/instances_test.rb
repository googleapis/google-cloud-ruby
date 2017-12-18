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

describe Google::Cloud::Spanner::Project, :instances, :mock_spanner do
  let(:first_page) do
    h = instances_hash
    h[:nextPageToken] = "next_page_token"
    response = Google::Spanner::Admin::Instance::V1::ListInstancesResponse.decode_json h.to_json
    paged_enum_struct response

  end
  let(:second_page) do
    h = instances_hash
    h[:nextPageToken] = "second_page_token"
    response = Google::Spanner::Admin::Instance::V1::ListInstancesResponse.decode_json h.to_json
    paged_enum_struct response
  end
  let(:last_page) do
    h = instances_hash
    h[:instances].pop
    response = Google::Spanner::Admin::Instance::V1::ListInstancesResponse.decode_json h.to_json
    paged_enum_struct response
  end
  let(:next_page_options) { Google::Gax::CallOptions.new page_token: "next_page_token" }

  it "lists instances" do
    mock = Minitest::Mock.new
    mock.expect :list_instances, first_page, [project_path, page_size: nil, options: nil]
    spanner.service.mocked_instances = mock

    instances = spanner.instances

    mock.verify

    instances.size.must_equal 3
  end

  it "paginates instances" do
    mock = Minitest::Mock.new
    mock.expect :list_instances, first_page, [project_path, page_size: nil, options: nil]
    mock.expect :list_instances, last_page, [project_path, page_size: nil, options: next_page_options]
    spanner.service.mocked_instances = mock

    first_instances = spanner.instances
    second_instances = spanner.instances token: first_instances.token

    mock.verify

    first_instances.size.must_equal 3
    token = first_instances.token
    token.wont_be :nil?
    token.must_equal "next_page_token"

    second_instances.size.must_equal 2
    second_instances.token.must_be :nil?
  end

  it "paginates instances with max set" do
    mock = Minitest::Mock.new
    mock.expect :list_instances, first_page, [project_path, page_size: 3, options: nil]
    spanner.service.mocked_instances = mock

    instances = spanner.instances max: 3

    mock.verify

    instances.size.must_equal 3
    token = instances.token
    token.wont_be :nil?
    token.must_equal "next_page_token"
  end

  it "paginates instances with next? and next" do
    mock = Minitest::Mock.new
    mock.expect :list_instances, first_page, [project_path, page_size: nil, options: nil]
    mock.expect :list_instances, last_page, [project_path, page_size: nil, options: next_page_options]
    spanner.service.mocked_instances = mock

    first_instances = spanner.instances
    second_instances = first_instances.next

    mock.verify

    first_instances.size.must_equal 3
    first_instances.next?.must_equal true

    second_instances.size.must_equal 2
    second_instances.next?.must_equal false
  end

  it "paginates instances with next? and next and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_instances, first_page, [project_path, page_size: 3, options: nil]
    mock.expect :list_instances, last_page, [project_path, page_size: 3, options: next_page_options]
    spanner.service.mocked_instances = mock

    first_instances = spanner.instances max: 3
    second_instances = first_instances.next

    mock.verify

    first_instances.size.must_equal 3
    first_instances.next?.must_equal true

    second_instances.size.must_equal 2
    second_instances.next?.must_equal false
  end

  it "paginates instances with all" do
    mock = Minitest::Mock.new
    mock.expect :list_instances, first_page, [project_path, page_size: nil, options: nil]
    mock.expect :list_instances, last_page, [project_path, page_size: nil, options: next_page_options]
    spanner.service.mocked_instances = mock

    instances = spanner.instances.all.to_a

    mock.verify

    instances.size.must_equal 5
  end

  it "paginates instances with all and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_instances, first_page, [project_path, page_size: 3, options: nil]
    mock.expect :list_instances, last_page, [project_path, page_size: 3, options: next_page_options]
    spanner.service.mocked_instances = mock

    instances = spanner.instances(max: 3).all.to_a

    mock.verify

    instances.size.must_equal 5
  end

  it "iterates instances with all using Enumerator" do
    mock = Minitest::Mock.new
    mock.expect :list_instances, first_page, [project_path, page_size: nil, options: nil]
    mock.expect :list_instances, second_page, [project_path, page_size: nil, options: next_page_options]
    spanner.service.mocked_instances = mock

    instances = spanner.instances.all.take(5)

    mock.verify

    instances.size.must_equal 5
  end

  it "iterates instances with all and request_limit set" do
    mock = Minitest::Mock.new
    mock.expect :list_instances, first_page, [project_path, page_size: nil, options: nil]
    mock.expect :list_instances, second_page, [project_path, page_size: nil, options: next_page_options]
    spanner.service.mocked_instances = mock

    instances = spanner.instances.all(request_limit: 1).to_a

    mock.verify

    instances.size.must_equal 6
  end
end
