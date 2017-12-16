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

describe Google::Cloud::Spanner::Project, :instance_configs, :mock_spanner do
  let(:first_page) do
    h = instance_configs_hash
    h[:nextPageToken] = "next_page_token"
    response = Google::Spanner::Admin::Instance::V1::ListInstanceConfigsResponse.decode_json h.to_json
    paged_enum_struct response

  end
  let(:second_page) do
    h = instance_configs_hash
    h[:nextPageToken] = "second_page_token"
    response = Google::Spanner::Admin::Instance::V1::ListInstanceConfigsResponse.decode_json h.to_json
    paged_enum_struct response
  end
  let(:last_page) do
    h = instance_configs_hash
    h[:instanceConfigs].pop
    response = Google::Spanner::Admin::Instance::V1::ListInstanceConfigsResponse.decode_json h.to_json
    paged_enum_struct response
  end
  let(:next_page_options) { Google::Gax::CallOptions.new page_token: "next_page_token" }

  it "lists configs" do
    mock = Minitest::Mock.new
    mock.expect :list_instance_configs, first_page, [project_path, page_size: nil, options: nil]
    spanner.service.mocked_instances = mock

    configs = spanner.instance_configs

    mock.verify

    configs.size.must_equal 3
  end

  it "paginates configs" do
    mock = Minitest::Mock.new
    mock.expect :list_instance_configs, first_page, [project_path, page_size: nil, options: nil]
    mock.expect :list_instance_configs, last_page, [project_path, page_size: nil, options: next_page_options]
    spanner.service.mocked_instances = mock

    first_configs = spanner.instance_configs
    second_configs = spanner.instance_configs token: first_configs.token

    mock.verify

    first_configs.size.must_equal 3
    token = first_configs.token
    token.wont_be :nil?
    token.must_equal "next_page_token"

    second_configs.size.must_equal 2
    second_configs.token.must_be :nil?
  end

  it "paginates configs with max set" do
    mock = Minitest::Mock.new
    mock.expect :list_instance_configs, first_page, [project_path, page_size: 3, options: nil]
    spanner.service.mocked_instances = mock

    configs = spanner.instance_configs max: 3

    mock.verify

    configs.size.must_equal 3
    token = configs.token
    token.wont_be :nil?
    token.must_equal "next_page_token"
  end

  it "paginates configs with next? and next" do
    mock = Minitest::Mock.new
    mock.expect :list_instance_configs, first_page, [project_path, page_size: nil, options: nil]
    mock.expect :list_instance_configs, last_page, [project_path, page_size: nil, options: next_page_options]
    spanner.service.mocked_instances = mock

    first_configs = spanner.instance_configs
    second_configs = first_configs.next

    mock.verify

    first_configs.size.must_equal 3
    first_configs.next?.must_equal true

    second_configs.size.must_equal 2
    second_configs.next?.must_equal false
  end

  it "paginates configs with next? and next and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_instance_configs, first_page, [project_path, page_size: 3, options: nil]
    mock.expect :list_instance_configs, last_page, [project_path, page_size: 3, options: next_page_options]
    spanner.service.mocked_instances = mock

    first_configs = spanner.instance_configs max: 3
    second_configs = first_configs.next

    mock.verify

    first_configs.size.must_equal 3
    first_configs.next?.must_equal true

    second_configs.size.must_equal 2
    second_configs.next?.must_equal false
  end

  it "paginates configs with all" do
    mock = Minitest::Mock.new
    mock.expect :list_instance_configs, first_page, [project_path, page_size: nil, options: nil]
    mock.expect :list_instance_configs, last_page, [project_path, page_size: nil, options: next_page_options]
    spanner.service.mocked_instances = mock

    configs = spanner.instance_configs.all.to_a

    mock.verify

    configs.size.must_equal 5
  end

  it "paginates configs with all and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_instance_configs, first_page, [project_path, page_size: 3, options: nil]
    mock.expect :list_instance_configs, last_page, [project_path, page_size: 3, options: next_page_options]
    spanner.service.mocked_instances = mock

    configs = spanner.instance_configs(max: 3).all.to_a

    mock.verify

    configs.size.must_equal 5
  end

  it "iterates configs with all using Enumerator" do
    mock = Minitest::Mock.new
    mock.expect :list_instance_configs, first_page, [project_path, page_size: nil, options: nil]
    mock.expect :list_instance_configs, second_page, [project_path, page_size: nil, options: next_page_options]
    spanner.service.mocked_instances = mock

    configs = spanner.instance_configs.all.take(5)

    mock.verify

    configs.size.must_equal 5
  end

  it "iterates configs with all and request_limit set" do
    mock = Minitest::Mock.new
    mock.expect :list_instance_configs, first_page, [project_path, page_size: nil, options: nil]
    mock.expect :list_instance_configs, second_page, [project_path, page_size: nil, options: next_page_options]
    spanner.service.mocked_instances = mock

    configs = spanner.instance_configs.all(request_limit: 1).to_a

    mock.verify

    configs.size.must_equal 6
  end
end
