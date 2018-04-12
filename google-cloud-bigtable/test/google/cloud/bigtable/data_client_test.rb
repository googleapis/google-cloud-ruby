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


require "test_helper"

describe Google::Cloud::Bigtable::DataClient do
  it "returns table opration object" do
    mock_method = proc {}
    mock_stub = MockBigtablGrpcClientStub.new("read_rows", mock_method)
    mock_credentials = MockBigtableCredentials.new("read_rows")

    Google::Bigtable::V2::Bigtable::Stub.stub(:new, mock_stub) do
      Google::Cloud::Bigtable::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud.bigtable(
          project_id: "project-id",
          instance_id: "instance-id",
          client_type: :data
        )
        table = client.table("table-id")

        assert_instance_of(Google::Cloud::Bigtable::TableDataOperations, table)
        assert_equal(
          table.instance_variable_get("@table_path"),
          Google::Cloud::Bigtable::V2::BigtableClient.table_path(
            "project-id",
            "instance-id",
            "table-id"
          )
        )
      end
    end
  end
end
