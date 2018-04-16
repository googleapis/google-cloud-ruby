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
require "google/cloud/bigtable/table_admin_client"

class TableAdminTestError < StandardError
  def initialize(operation_name)
    super("Custom test error for \
Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient##{operation_name}")
  end
end

def stub_table_admin_grpc service_name, mock_method
  mock_stub = MockBigtablGrpcClientStub.new(service_name, mock_method)
  # Mock auth layer
  mock_credentials = MockBigtableAdminCredentials.new(service_name.to_s)

  Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
    Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
      yield
    end
  end
end

describe Google::Cloud::Bigtable::TableAdminClient do
  Bigtable = Google::Cloud::Bigtable unless Object.const_defined?("Bigtable")
  BigtableTableAdminClient =
    Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient

  let(:project_id) { "test-project-id" }
  let(:instance_id) { "test-instance-id" }
  let(:cluster_id) { "test-cluster-id"}
  let(:table_id) { "test-table" }
  let(:snapshot_id) { "test-snapshot-id"}
  let(:instance_path) {
    Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.instance_path(
      project_id,
      instance_id
    )
  }
  let(:table_path) {
    Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.table_path(
      project_id,
      instance_id,
      table_id
    )
  }
  let(:cluster_path){
    Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.cluster_path(
      project_id,
      instance_id,
      cluster_id
    )
  }
  let(:snapshot_path){
    Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.snapshot_path(
      project_id,
      instance_id,
      cluster_id,
      snapshot_id
    )
  }
  let(:client) {
    Google::Cloud::Bigtable::TableAdminClient.new(
      project_id,
      instance_id
    )
  }

  describe 'create_table' do
    it 'invokes create_table without error' do
      table = {}
      table_id = "table_1"
      expected_response = { name: table_id }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::Table)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::CreateTableRequest, request)
        assert_equal(instance_path , request.parent)
        assert_equal(table_id, request.table_id)
        assert_equal(Google::Gax::to_proto(table, Google::Bigtable::Admin::V2::Table), request.table)
        OpenStruct.new(execute: expected_response)
      end

      stub_table_admin_grpc(:create_table, mock_method) do
        req_table = Google::Bigtable::Admin::V2::Table.new(name: table_id)
        response = client.create_table(req_table)
        assert_equal(expected_response, response)
      end
    end

    it 'invokes create_table with error' do
      custom_error = TableAdminTestError.new "create_table"
      table_id = 'table_2'
      table = {}

      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::CreateTableRequest, request)
        assert_equal(instance_path , request.parent)
        assert_equal(table_id, request.table_id)
        assert_equal(Google::Gax::to_proto(table, Google::Bigtable::Admin::V2::Table), request.table)
        raise custom_error
      end

      stub_table_admin_grpc(:create_table, mock_method) do
        req_table = Google::Bigtable::Admin::V2::Table.new(name: table_id)
        err = assert_raises Google::Gax::GaxError do
          client .create_table(req_table)
        end

        assert_match(custom_error.message, err.message)
      end
    end
  end

  describe 'list_tables' do
    it 'invokes list_tables without error' do
      next_page_token = ""
      tables_element = {}
      tables = [tables_element]
      expected_response = { next_page_token: next_page_token, tables: tables }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::ListTablesResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::ListTablesRequest, request)
        assert_equal(instance_path , request.parent)
        OpenStruct.new(execute: expected_response)
      end

      stub_table_admin_grpc(:list_tables, mock_method) do
        response = client .tables
        assert(response.instance_of?(Google::Gax::PagedEnumerable))
        assert_equal(expected_response, response.page.response)
        assert_nil(response.next_page)
        assert_equal(expected_response.tables.to_a, response.to_a)
      end
    end

    it 'invokes list_tables with error' do
      custom_error = TableAdminTestError.new "list_tables"

      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::ListTablesRequest, request)
        assert_equal(instance_path , request.parent)
        raise custom_error
      end

      stub_table_admin_grpc(:list_tables, mock_method) do
        err = assert_raises Google::Gax::GaxError do
          client .tables
        end

        # Verify the GaxError wrapped the custom error that was raised.
        assert_match(custom_error.message, err.message)
      end
    end
  end

  describe 'get_table' do
    it 'invokes get_table without error' do
      expected_response = { name: table_id  }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::Table)

      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::GetTableRequest, request)
        assert_equal(table_path , request.name)
        OpenStruct.new(execute: expected_response)
      end

      stub_table_admin_grpc(:get_table, mock_method) do
        response = client .table(table_id )
        assert_equal(expected_response, response)
      end
    end

    it 'invokes get_table with error' do
      custom_error = TableAdminTestError.new "get_table"

      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::GetTableRequest, request)
        assert_equal(table_path , request.name)
        raise custom_error
      end

      stub_table_admin_grpc(:get_table, mock_method) do
        err = assert_raises Google::Gax::GaxError do
          client .table(table_id )
        end

        assert_match(custom_error.message, err.message)
      end
    end
  end

  describe 'delete_table' do
    it 'invokes delete_table without error' do
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::DeleteTableRequest, request)
        assert_equal(table_path , request.name)
        OpenStruct.new(execute: nil)
      end

      stub_table_admin_grpc(:delete_table, mock_method) do
        response = client .delete_table(table_id )
        assert_nil(response)
      end
    end

    it 'invokes delete_table with error' do
      custom_error = TableAdminTestError.new "delete_table"

      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::DeleteTableRequest, request)
        assert_equal(table_path , request.name)
        raise custom_error
      end

      stub_table_admin_grpc(:delete_table, mock_method) do
        err = assert_raises Google::Gax::GaxError do
          client .delete_table(table_id )
        end

        assert_match(custom_error.message, err.message)
      end
    end
  end

  describe 'modify_column_families' do
    it 'invokes modify_column_families without error' do
      modifications = [
        { id: "cf1", create: { gc_rule: { max_num_versions: 3 } } },
        { id: "cf2", drop: true }
      ]

      # Create expected grpc response
      expected_response = { name: table_id  }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::Table)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::ModifyColumnFamiliesRequest, request)
        assert_equal(table_path , request.name)
        modifications = modifications.map do |req|
          Google::Gax::to_proto(req, Google::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification)
        end
        assert_equal(modifications, request.modifications)
        OpenStruct.new(execute: expected_response)
      end

      stub_table_admin_grpc(:modify_column_families, mock_method) do
        response = client .modify_column_families(table_id , modifications)
        assert_equal(expected_response, response)
      end
    end

    it 'invokes modify_column_families with error' do
      custom_error = TableAdminTestError.new "modify_column_families"
      modifications = []

      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::ModifyColumnFamiliesRequest, request)
        assert_equal(table_path , request.name)
        modifications = modifications.map do |req|
          Google::Gax::to_proto(req, Google::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification)
        end
        assert_equal(modifications, request.modifications)
        raise custom_error
      end

      stub_table_admin_grpc(:modify_column_families, mock_method) do
        err = assert_raises Google::Gax::GaxError do
          client .modify_column_families(table_id   , modifications)
        end

        assert_match(custom_error.message, err.message)
      end
    end
  end

  describe 'drop_row_range' do
    it 'invokes drop_row_range without error' do
      row_key_prefix = "user"

      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::DropRowRangeRequest, request)
        assert_equal(table_path , request.name)
        assert_equal(row_key_prefix, request.row_key_prefix)
        OpenStruct.new(execute: nil)
      end

      stub_table_admin_grpc(:drop_row_range, mock_method) do
        response = client .drop_row_range(table_id , row_key_prefix: row_key_prefix)
        assert_nil(response)
      end
    end

    it 'invokes drop_row_range with error' do
      custom_error = TableAdminTestError.new "drop_row_range"
      delete_all_data_from_table = true

      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::DropRowRangeRequest, request)
        assert_equal(table_path , request.name)
        assert_equal(delete_all_data_from_table,request.delete_all_data_from_table)
        raise custom_error
      end

      stub_table_admin_grpc(:drop_row_range, mock_method) do
        err = assert_raises Google::Gax::GaxError do
          client .drop_row_range(table_id , delete_all_data_from_table: true)
        end

        assert_match(custom_error.message, err.message)
      end
    end
  end

  describe 'create_snapshot' do

    it 'invokes create_snapshot without error' do
      description = "Create snapshot test"
      ttl = 1800

      expected_response = { name: snapshot_id, done: true }
      expected_response = Google::Gax::to_proto(expected_response, Google::Longrunning::Operation)

      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::SnapshotTableRequest, request)
        assert_equal(table_path, request.name)
        assert_equal(cluster_path, request.cluster)
        assert_equal(snapshot_id, request.snapshot_id)
        assert_equal(description, request.description)
        assert_equal(Google::Protobuf::Duration.new(seconds: ttl), request.ttl)
        OpenStruct.new(execute: expected_response)
      end

      stub_table_admin_grpc(:snapshot_table, mock_method) do
        response = client.create_snapshot(
          table_id,
          cluster_id,
          snapshot_id,
          description,
          ttl: ttl
        )
        assert_equal(expected_response, response)
      end
    end

    it 'invokes snapshot_table with error' do
      custom_error = TableAdminTestError.new "snapshot_table"
      description = "Create snapshot test"

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::SnapshotTableRequest, request)
        assert_equal(table_path, request.name)
        assert_equal(cluster_path, request.cluster)
        assert_equal(snapshot_id, request.snapshot_id)
        assert_equal(description, request.description)
        assert_nil(request.ttl)
        raise custom_error
      end

      stub_table_admin_grpc(:snapshot_table, mock_method) do
        err = assert_raises Google::Gax::GaxError do
          client.create_snapshot(
            table_id,
            cluster_id,
            snapshot_id,
            description
          )
        end
        assert_match(custom_error.message, err.message)
      end
    end
  end

  describe 'get snapshot' do
    it 'invokes get snapshot without error' do
      expected_response = {
        name: snapshot_id,
        data_size_bytes: 1000000,
        description: "snapshot description"
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::Snapshot)

      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::GetSnapshotRequest, request)
        assert_equal(snapshot_path, request.name)
        OpenStruct.new(execute: expected_response)
      end

      stub_table_admin_grpc(:get_snapshot, mock_method) do
        response = client.snapshot(snapshot_id, cluster_id)
        assert_equal(expected_response, response)
      end
    end

    it 'invokes get snapshot with error' do
      custom_error = TableAdminTestError.new "get_snapshot"
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::GetSnapshotRequest, request)
        assert_equal(snapshot_path, request.name)
        raise custom_error
      end

      stub_table_admin_grpc(:get_snapshot, mock_method) do
        err = assert_raises Google::Gax::GaxError do
          client.snapshot(snapshot_id, cluster_id)
        end

        assert_match(custom_error.message, err.message)
      end
    end
  end

  describe 'list snapshots' do
    it 'invokes list snapshots without error' do
      next_page_token = ""
      snapshots_element = Google::Bigtable::Admin::V2::Snapshot.new(
        name: snapshot_id,
        data_size_bytes: 1000000,
        description: "snapshot description"
      )
      snapshots = [snapshots_element]
      expected_response = { next_page_token: next_page_token, snapshots: snapshots }
      expected_response = Google::Gax::to_proto(
        expected_response,
        Google::Bigtable::Admin::V2::ListSnapshotsResponse
      )

      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::ListSnapshotsRequest, request)
        assert_equal(cluster_path, request.parent)
        OpenStruct.new(execute: expected_response)
      end

      stub_table_admin_grpc(:list_snapshots, mock_method) do
        response = client.snapshots(cluster_id)

        assert(response.instance_of?(Google::Gax::PagedEnumerable))
        assert_equal(expected_response, response.page.response)
        assert_nil(response.next_page)
        assert_equal(expected_response.snapshots.to_a, response.to_a)
      end
    end

    it 'invokes list snapshots with error' do
      custom_error = TableAdminTestError.new "list_snapshots"

      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::ListSnapshotsRequest, request)
        assert_equal(cluster_path, request.parent)
        raise custom_error
      end

      stub_table_admin_grpc(:list_snapshots, mock_method) do
        err = assert_raises Google::Gax::GaxError do
          client.snapshots(cluster_id)
        end

        assert_match(custom_error.message, err.message)
      end
    end
  end

  describe 'delete_snapshot' do
    it 'invokes delete_snapshot without error' do
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::DeleteSnapshotRequest, request)
        assert_equal(snapshot_path, request.name)
        OpenStruct.new(execute: true)
      end

      stub_table_admin_grpc(:delete_snapshot, mock_method) do
        response = client.delete_snapshot(
          cluster_id,
          snapshot_id
        )
        assert_equal(true, response)
      end
    end

    it 'invokes delete_snapshot with error' do
      custom_error = TableAdminTestError.new("delete_snapshot")

      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::DeleteSnapshotRequest, request)
        assert_equal(snapshot_path, request.name)
        raise custom_error
      end

      stub_table_admin_grpc(:delete_snapshot, mock_method) do
        err = assert_raises Google::Gax::GaxError do
          client.delete_snapshot(cluster_id, snapshot_id)
        end

        assert_match(custom_error.message, err.message)
      end
    end
  end

  describe 'create_table_from_snapshot' do
    it 'invokes create_table_from_snapshot without error' do
      new_table_id = table_id
      source_snapshot = snapshot_id

      expected_response = { name: new_table_id }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::Table)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/create_table_from_snapshot_test',
        done: true,
        response: result
      )

      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::CreateTableFromSnapshotRequest, request)
        assert_equal(instance_path, request.parent)
        assert_equal(new_table_id, request.table_id)
        assert_equal(snapshot_path, request.source_snapshot)
        OpenStruct.new(execute: operation)
      end

      stub_table_admin_grpc(:create_table_from_snapshot, mock_method) do
        response = client.create_table_from_snapshot(
          new_table_id,
          cluster_id,
          source_snapshot
        )

        assert_equal(expected_response, response.response)
      end
    end

    it 'invokes create_table_from_snapshot and returns an operation error.' do
      new_table_id = table_id
      source_snapshot = snapshot_id
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient#create_table_from_snapshot.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/create_table_from_snapshot_test',
        done: true,
        error: operation_error
      )

      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::CreateTableFromSnapshotRequest, request)
        assert_equal(instance_path, request.parent)
        assert_equal(new_table_id, request.table_id)
        assert_equal(snapshot_path, request.source_snapshot)
        OpenStruct.new(execute: operation)
      end

      stub_table_admin_grpc(:create_table_from_snapshot, mock_method) do
        response = client.create_table_from_snapshot(
          new_table_id,
          cluster_id,
          source_snapshot
        )
        assert(response.error?)
        assert_equal(operation_error, response.error)
      end
    end

    it 'invokes create_table_from_snapshot with error' do
      custom_error = TableAdminTestError.new "create_table_from_snapshot"
      new_table_id = table_id
      source_snapshot = snapshot_id

      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::CreateTableFromSnapshotRequest, request)
        assert_equal(instance_path, request.parent)
        assert_equal(new_table_id, request.table_id)
        assert_equal(snapshot_path, request.source_snapshot)
        raise custom_error
      end

      stub_table_admin_grpc(:create_table_from_snapshot, mock_method) do
        err = assert_raises Google::Gax::GaxError do
          client.create_table_from_snapshot(
            new_table_id,
            cluster_id,
            source_snapshot
          )
        end

        assert_match(custom_error.message, err.message)
      end
    end
  end
end
