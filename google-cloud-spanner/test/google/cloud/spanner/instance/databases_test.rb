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

describe Google::Cloud::Spanner::Instance, :databases, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:instance_grpc) { Google::Cloud::Spanner::Admin::Instance::V1::Instance.new instance_hash(name: instance_id) }
  let(:instance) { Google::Cloud::Spanner::Instance.from_grpc instance_grpc, spanner.service }
  let(:first_page) do
    h = databases_hash instance_id: instance_id
    h[:next_page_token] = "next_page_token"
    response = Google::Cloud::Spanner::Admin::Database::V1::ListDatabasesResponse.new h
    paged_enum_struct response
  end
  let(:second_page) do
    h = databases_hash instance_id: instance_id
    h[:next_page_token] = "second_page_token"
    response = Google::Cloud::Spanner::Admin::Database::V1::ListDatabasesResponse.new h
    paged_enum_struct response
  end
  let(:last_page) do
    h = databases_hash instance_id: instance_id
    h[:databases].pop
    response = Google::Cloud::Spanner::Admin::Database::V1::ListDatabasesResponse.new h
    paged_enum_struct response
  end
  let(:next_page_options) { "next_page_token" }

  it "lists databases" do
    mock = Minitest::Mock.new
    mock.expect :list_databases, first_page, [{ parent: instance_path(instance_id), page_size: nil, page_token: nil }, ::Gapic::CallOptions]
    instance.service.mocked_databases = mock

    databases = instance.databases

    mock.verify

    _(databases.size).must_equal 3
  end

  it "paginates databases" do
    mock = Minitest::Mock.new
    mock.expect :list_databases, first_page, [{ parent: instance_path(instance_id), page_size: nil, page_token: nil }, ::Gapic::CallOptions]
    mock.expect :list_databases, last_page, [{ parent: instance_path(instance_id), page_size: nil, page_token: next_page_options }, ::Gapic::CallOptions]
    instance.service.mocked_databases = mock

    first_databases = instance.databases
    second_databases = instance.databases token: first_databases.token

    mock.verify

    _(first_databases.size).must_equal 3
    token = first_databases.token
    _(token).wont_be :nil?
    _(token).must_equal "next_page_token"

    _(second_databases.size).must_equal 2
    _(second_databases.token).must_be :nil?
  end

  it "paginates databases with max set" do
    mock = Minitest::Mock.new
    mock.expect :list_databases, first_page, [{ parent: instance_path(instance_id), page_size: 3, page_token: nil }, ::Gapic::CallOptions]
    instance.service.mocked_databases = mock

    databases = instance.databases max: 3

    mock.verify

    _(databases.size).must_equal 3
    token = databases.token
    _(token).wont_be :nil?
    _(token).must_equal "next_page_token"
  end

  it "paginates databases with next? and next" do
    mock = Minitest::Mock.new
    mock.expect :list_databases, first_page, [{ parent: instance_path(instance_id), page_size: nil, page_token: nil }, ::Gapic::CallOptions]
    mock.expect :list_databases, last_page, [{ parent: instance_path(instance_id), page_size: nil, page_token: next_page_options }, ::Gapic::CallOptions]
    instance.service.mocked_databases = mock

    first_databases = instance.databases
    second_databases = first_databases.next

    mock.verify

    _(first_databases.size).must_equal 3
    _(first_databases.next?).must_equal true

    _(second_databases.size).must_equal 2
    _(second_databases.next?).must_equal false
  end

  it "paginates databases with next? and next and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_databases, first_page, [{ parent: instance_path(instance_id), page_size: 3, page_token: nil }, ::Gapic::CallOptions]
    mock.expect :list_databases, last_page, [{ parent: instance_path(instance_id), page_size: 3, page_token: next_page_options }, ::Gapic::CallOptions]
    instance.service.mocked_databases = mock

    first_databases = instance.databases max: 3
    second_databases = first_databases.next

    mock.verify

    _(first_databases.size).must_equal 3
    _(first_databases.next?).must_equal true

    _(second_databases.size).must_equal 2
    _(second_databases.next?).must_equal false
  end

  it "paginates databases with all" do
    mock = Minitest::Mock.new
    mock.expect :list_databases, first_page, [{ parent: instance_path(instance_id), page_size: nil, page_token: nil }, ::Gapic::CallOptions]
    mock.expect :list_databases, last_page, [{ parent: instance_path(instance_id), page_size: nil, page_token: next_page_options }, ::Gapic::CallOptions]
    instance.service.mocked_databases = mock

    databases = instance.databases.all.to_a

    mock.verify

    _(databases.size).must_equal 5
  end

  it "paginates databases with all and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_databases, first_page, [{ parent: instance_path(instance_id), page_size: 3, page_token: nil }, ::Gapic::CallOptions]
    mock.expect :list_databases, last_page, [{ parent: instance_path(instance_id), page_size: 3, page_token: next_page_options }, ::Gapic::CallOptions]
    instance.service.mocked_databases = mock

    databases = instance.databases(max: 3).all.to_a

    mock.verify

    _(databases.size).must_equal 5
  end

  it "iterates databases with all using Enumerator" do
    mock = Minitest::Mock.new
    mock.expect :list_databases, first_page, [{ parent: instance_path(instance_id), page_size: nil, page_token: nil }, ::Gapic::CallOptions]
    mock.expect :list_databases, second_page, [{ parent: instance_path(instance_id), page_size: nil, page_token: next_page_options }, ::Gapic::CallOptions]
    instance.service.mocked_databases = mock

    databases = instance.databases.all.take(5)

    mock.verify

    _(databases.size).must_equal 5
  end

  it "iterates databases with all and request_limit set" do
    mock = Minitest::Mock.new
    mock.expect :list_databases, first_page, [{ parent: instance_path(instance_id), page_size: nil, page_token: nil }, ::Gapic::CallOptions]
    mock.expect :list_databases, second_page, [{ parent: instance_path(instance_id), page_size: nil, page_token: next_page_options }, ::Gapic::CallOptions]
    instance.service.mocked_databases = mock

    databases = instance.databases.all(request_limit: 1).to_a

    mock.verify

    _(databases.size).must_equal 6
  end
end
