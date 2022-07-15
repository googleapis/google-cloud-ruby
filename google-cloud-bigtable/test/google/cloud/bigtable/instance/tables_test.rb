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

describe Google::Cloud::Bigtable::Instance, :tables, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:instance_grpc){
    Google::Cloud::Bigtable::Admin::V2::Instance.new(name: instance_path(instance_id))
  }
  let(:instance) {
    Google::Cloud::Bigtable::Instance.from_grpc(instance_grpc, bigtable.service)
  }
  let(:first_page) do
    h = tables_hash(instance_id)
    h[:next_page_token] = "next_page_token"
    Google::Cloud::Bigtable::Admin::V2::ListTablesResponse.new(h)
  end
  let(:second_page) do
    h = tables_hash(instance_id, start_id: 10)
    h[:next_page_token] = "second_page_token"
    Google::Cloud::Bigtable::Admin::V2::ListTablesResponse.new(h)
  end
  let(:last_page) do
    h = tables_hash(instance_id, start_id: 20)
    h[:tables].pop
    Google::Cloud::Bigtable::Admin::V2::ListTablesResponse.new(h)
  end

  it "list tables" do
    get_res =  MockPagedEnumerable.new([first_page])
    mock = Minitest::Mock.new
    mock.expect :list_tables, get_res, parent: instance_path(instance_id), view: nil
    bigtable.service.mocked_tables = mock

    tables = instance.tables

    mock.verify

    _(tables.size).must_equal 3
  end

  it "paginates tables with next? and next" do
    get_res =  MockPagedEnumerable.new([first_page, last_page])
    mock = Minitest::Mock.new
    mock.expect :list_tables, get_res, parent: instance_path(instance_id), view: nil
    bigtable.service.mocked_tables = mock

    list = instance.tables

    mock.verify

    _(list.size).must_equal 3
    _(list.next?).must_equal true
    _(list.next.size).must_equal 2
    _(list.next?).must_equal false
  end

  it "paginates tables with all" do
    get_res =  MockPagedEnumerable.new([first_page, last_page])
    mock = Minitest::Mock.new
    mock.expect :list_tables, get_res, parent: instance_path(instance_id), view: nil
    bigtable.service.mocked_tables = mock

    tables = instance.tables.all.to_a

    mock.verify

    _(tables.size).must_equal 5
  end

  it "iterates tables with all using Enumerator" do
    get_res =  MockPagedEnumerable.new([first_page, last_page])
    mock = Minitest::Mock.new
    mock.expect :list_tables, get_res, parent: instance_path(instance_id), view: nil
    bigtable.service.mocked_tables = mock

    tables = instance.tables.all.take(5)

    mock.verify

    _(tables.size).must_equal 5
  end
end
