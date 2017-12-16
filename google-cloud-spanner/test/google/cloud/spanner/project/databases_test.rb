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

describe Google::Cloud::Spanner::Project, :databases, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:first_page) do
    h = databases_hash instance_id: instance_id
    h[:nextPageToken] = "next_page_token"
    response = Google::Spanner::Admin::Database::V1::ListDatabasesResponse.decode_json h.to_json
    paged_enum_struct response

  end
  let(:second_page) do
    h = databases_hash instance_id: instance_id
    h[:nextPageToken] = "second_page_token"
    response = Google::Spanner::Admin::Database::V1::ListDatabasesResponse.decode_json h.to_json
    paged_enum_struct response
  end
  let(:last_page) do
    h = databases_hash instance_id: instance_id
    h[:databases].pop
    response = Google::Spanner::Admin::Database::V1::ListDatabasesResponse.decode_json h.to_json
    paged_enum_struct response
  end
  let(:next_page_options) { Google::Gax::CallOptions.new page_token: "next_page_token" }

  it "lists databases" do
    mock = Minitest::Mock.new
    mock.expect :list_databases, first_page, [instance_path(instance_id), page_size: nil, options: nil]
    spanner.service.mocked_databases = mock

    databases = spanner.databases instance_id

    mock.verify

    databases.size.must_equal 3
  end

  it "paginates databases" do
    mock = Minitest::Mock.new
    mock.expect :list_databases, first_page, [instance_path(instance_id), page_size: nil, options: nil]
    mock.expect :list_databases, last_page, [instance_path(instance_id), page_size: nil, options: next_page_options]
    spanner.service.mocked_databases = mock

    first_databases = spanner.databases instance_id
    second_databases = spanner.databases instance_id, token: first_databases.token

    mock.verify

    first_databases.size.must_equal 3
    token = first_databases.token
    token.wont_be :nil?
    token.must_equal "next_page_token"

    second_databases.size.must_equal 2
    second_databases.token.must_be :nil?
  end

  it "paginates databases with max set" do
    mock = Minitest::Mock.new
    mock.expect :list_databases, first_page, [instance_path(instance_id), page_size: 3, options: nil]
    spanner.service.mocked_databases = mock

    databases = spanner.databases instance_id, max: 3

    mock.verify

    databases.size.must_equal 3
    token = databases.token
    token.wont_be :nil?
    token.must_equal "next_page_token"
  end

  it "paginates databases with next? and next" do
    mock = Minitest::Mock.new
    mock.expect :list_databases, first_page, [instance_path(instance_id), page_size: nil, options: nil]
    mock.expect :list_databases, last_page, [instance_path(instance_id), page_size: nil, options: next_page_options]
    spanner.service.mocked_databases = mock

    first_databases = spanner.databases instance_id
    second_databases = first_databases.next

    mock.verify

    first_databases.size.must_equal 3
    first_databases.next?.must_equal true

    second_databases.size.must_equal 2
    second_databases.next?.must_equal false
  end

  it "paginates databases with next? and next and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_databases, first_page, [instance_path(instance_id), page_size: 3, options: nil]
    mock.expect :list_databases, last_page, [instance_path(instance_id), page_size: 3, options: next_page_options]
    spanner.service.mocked_databases = mock

    first_databases = spanner.databases instance_id, max: 3
    second_databases = first_databases.next

    mock.verify

    first_databases.size.must_equal 3
    first_databases.next?.must_equal true

    second_databases.size.must_equal 2
    second_databases.next?.must_equal false
  end

  it "paginates databases with all" do
    mock = Minitest::Mock.new
    mock.expect :list_databases, first_page, [instance_path(instance_id), page_size: nil, options: nil]
    mock.expect :list_databases, last_page, [instance_path(instance_id), page_size: nil, options: next_page_options]
    spanner.service.mocked_databases = mock

    databases = spanner.databases(instance_id).all.to_a

    mock.verify

    databases.size.must_equal 5
  end

  it "paginates databases with all and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_databases, first_page, [instance_path(instance_id), page_size: 3, options: nil]
    mock.expect :list_databases, last_page, [instance_path(instance_id), page_size: 3, options: next_page_options]
    spanner.service.mocked_databases = mock

    databases = spanner.databases(instance_id, max: 3).all.to_a

    mock.verify

    databases.size.must_equal 5
  end

  it "iterates databases with all using Enumerator" do
    mock = Minitest::Mock.new
    mock.expect :list_databases, first_page, [instance_path(instance_id), page_size: nil, options: nil]
    mock.expect :list_databases, second_page, [instance_path(instance_id), page_size: nil, options: next_page_options]
    spanner.service.mocked_databases = mock

    databases = spanner.databases(instance_id).all.take(5)

    mock.verify

    databases.size.must_equal 5
  end

  it "iterates databases with all and request_limit set" do
    mock = Minitest::Mock.new
    mock.expect :list_databases, first_page, [instance_path(instance_id), page_size: nil, options: nil]
    mock.expect :list_databases, second_page, [instance_path(instance_id), page_size: nil, options: next_page_options]
    spanner.service.mocked_databases = mock

    databases = spanner.databases(instance_id).all(request_limit: 1).to_a

    mock.verify

    databases.size.must_equal 6
  end
end
