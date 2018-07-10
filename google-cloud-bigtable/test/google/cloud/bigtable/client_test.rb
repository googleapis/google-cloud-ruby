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

describe Google::Cloud::Bigtable::Client, :client, :mock_bigtable do
  let(:instance_id) { "test-instance-id" }

  it "create client instance" do
    client = bigtable.client(instance_id)

    client.must_be_kind_of Google::Cloud::Bigtable::Client
    client.instance_id.must_equal instance_id
    client.project_id.must_equal project_id
  end

  describe "#table" do
    let(:table_id) { "test-table" }

    it "get table instance without app profile id" do
      mock = Minitest::Mock.new
      bigtable.service.mocked_client = mock

      client = bigtable.client(instance_id)
      table = client.table(table_id)
      table.must_be_kind_of Google::Cloud::Bigtable::Client::Table
      table.path.must_equal table_path(instance_id, table_id)
      table.app_profile_id.must_be :nil?

      mock.verify
    end

    it "get table instance with app profile id" do
      app_profile_id = "test-app-profile"
      mock = Minitest::Mock.new
      bigtable.service.mocked_client = mock

      client = bigtable.client(instance_id)
      table = client.table(table_id, app_profile_id: app_profile_id)
      table.must_be_kind_of Google::Cloud::Bigtable::Client::Table
      table.path.must_equal table_path(instance_id, table_id)
      table.app_profile_id.must_equal app_profile_id

      mock.verify
    end
  end

  it "build table path" do
    table_id = "test-table"
    mock = Minitest::Mock.new
    bigtable.service.mocked_client = mock

    client = bigtable.client(instance_id)

    expected_table_path = Google::Cloud::Bigtable::V2::BigtableClient.table_path(
      project_id,
      instance_id,
      table_id
    )
    client.table_path(table_id).must_equal expected_table_path
  end
end
