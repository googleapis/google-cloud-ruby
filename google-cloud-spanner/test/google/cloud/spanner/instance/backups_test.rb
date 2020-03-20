# Copyright 2020 Google LLC
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

describe Google::Cloud::Spanner::Instance, :backups, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:instance_grpc) { Google::Spanner::Admin::Instance::V1::Instance.new instance_hash(name: instance_id) }
  let(:instance) { Google::Cloud::Spanner::Instance.from_grpc instance_grpc, spanner.service }
  let(:first_page) do
    h = backups_hash instance_id: instance_id
    h[:next_page_token] = "next_page_token"
    Google::Spanner::Admin::Database::V1::ListBackupsResponse.new h
  end
  let(:second_page) do
    h = backups_hash instance_id: instance_id
    h[:next_page_token] = "second_page_token"
    Google::Spanner::Admin::Database::V1::ListBackupsResponse.new h
  end
  let(:last_page) do
    h = backups_hash instance_id: instance_id
    h[:backups].pop
    Google::Spanner::Admin::Database::V1::ListBackupsResponse.new h
  end
  let(:next_page_options) { Google::Gax::CallOptions.new page_token: "next_page_token" }

  it "lists backups" do
    get_res =  MockPagedEnumerable.new([first_page])
    mock = Minitest::Mock.new
    mock.expect :list_backups, get_res, [instance_path(instance_id), nil, page_size: nil]
    instance.service.mocked_databases = mock

    backups = instance.backups

    mock.verify

    backups.size.must_equal 3
  end

  it "paginates backups with page size" do
    get_res =  MockPagedEnumerable.new([first_page])
    mock = Minitest::Mock.new
    mock.expect :list_backups, get_res, [instance_path(instance_id), nil, page_size: 3]
    instance.service.mocked_databases = mock

    backups = instance.backups page_size: 3

    mock.verify

    backups.size.must_equal 3
  end

  it "paginates backups with next? and next" do
    get_res =  MockPagedEnumerable.new([first_page, last_page])
    mock = Minitest::Mock.new
    mock.expect :list_backups, get_res, [instance_path(instance_id), nil, page_size: nil]
    instance.service.mocked_databases = mock

    list = instance.backups

    mock.verify

    list.size.must_equal 3
    list.next?.must_equal true
    list.next.size.must_equal 2
    list.next?.must_equal false
  end

  it "paginates backups with next? and next and page size" do
    get_res =  MockPagedEnumerable.new([first_page, last_page])
    mock = Minitest::Mock.new
    mock.expect :list_backups, get_res, [instance_path(instance_id), nil, page_size: 3]
    instance.service.mocked_databases = mock

    list = instance.backups page_size: 3

    mock.verify

    list.size.must_equal 3
    list.next?.must_equal true
    list.next.size.must_equal 2
    list.next?.must_equal false
  end

  it "paginates backups with all" do
    get_res =  MockPagedEnumerable.new([first_page, last_page])
    mock = Minitest::Mock.new
    mock.expect :list_backups, get_res, [instance_path(instance_id), nil, page_size: nil]
    instance.service.mocked_databases = mock

    backups = instance.backups.all.to_a

    mock.verify

    backups.size.must_equal 5
  end

  it "paginates backups with all and page size" do
    get_res =  MockPagedEnumerable.new([first_page, last_page])
    mock = Minitest::Mock.new
    mock.expect :list_backups, get_res, [instance_path(instance_id), nil, page_size: 3]
    instance.service.mocked_databases = mock

    backups = instance.backups(page_size: 3).all.to_a

    mock.verify

    backups.size.must_equal 5
  end

  it "iterates backups with all using Enumerator" do
    get_res =  MockPagedEnumerable.new([first_page, last_page])
    mock = Minitest::Mock.new
    mock.expect :list_backups, get_res, [instance_path(instance_id), nil, page_size: nil]
    instance.service.mocked_databases = mock

    backups = instance.backups.all.take(5)

    mock.verify

    backups.size.must_equal 5
  end

  it "paginates backups with filter" do
    get_res =  MockPagedEnumerable.new([first_page])
    mock = Minitest::Mock.new
    mock.expect :list_backups, get_res, [instance_path(instance_id), "name:db1", page_size: nil]
    instance.service.mocked_databases = mock

    backups = instance.backups filter: "name:db1"

    mock.verify

    backups.size.must_equal 3
  end

  it "paginates backups with filter and page size" do
    get_res =  MockPagedEnumerable.new([first_page])
    mock = Minitest::Mock.new
    mock.expect :list_backups, get_res, [instance_path(instance_id), "name:db1", page_size: 3]
    instance.service.mocked_databases = mock

    backups = instance.backups filter: "name:db1", page_size: 3

    mock.verify

    backups.size.must_equal 3
  end
end
