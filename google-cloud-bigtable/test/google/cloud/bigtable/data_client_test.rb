# frozen_string_literal: true

require "test_helper"

describe Google::Cloud::Bigtable::DataClient do
  it "returns table opration object" do
    mock_method = proc {}
    mock_stub = MockGrpcClientStub.new("read_rows", mock_method)
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
          table.table_path,
          Google::Cloud::Bigtable::V2::BigtableClient.table_path("project-id", "instance-id", "table-id")
        )
      end
    end
  end
end
