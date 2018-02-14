# frozen_string_literal: true

require_relative "test_helper"
require "google/cloud/bigtable/table_admin_client"

class TableAdminTestError < StandardError
  def initialize(operation_name)
    super("Custom test error for \
Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient##{operation_name}")
  end
end

def stub_table_admin_grpc service_name, mock_method
  mock_stub = MockGrpcClientStub.new(service_name, mock_method)
  # Mock auth layer
  mock_credentials = MockBigtableAdminCredentials.new(service_name.to_s)

  Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
    Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
      yield
    end
  end
end

describe Google::Cloud::Bigtable::TableAdminClient do
  # Class aliases
  Bigtable = Google::Cloud::Bigtable unless Object.const_defined?("Bigtable")
  BigtableTableAdminClient =
    Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient

  before do
    @project_id = "test-project-id"
    @instance_id = "test-instance-id"
    @instance_path = BigtableTableAdminClient.instance_path(
      @project_id,
      @instance_id
    )
    @client = Google::Cloud.bigtable(
      project_id: @project_id,
      instance_id: @instance_id,
      client_type: :table
    )
  end

  describe 'create_table' do
    it 'invokes create_table without error' do
      table = {}
      table_id = "table_1"
      expected_response = { name: table_id }
      expected_response = Google::Gax::to_proto(expected_response, Bigtable::Table)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::CreateTableRequest, request)
        assert_equal(@instance_path, request.parent)
        assert_equal(table_id, request.table_id)
        assert_equal(Google::Gax::to_proto(table, Bigtable::Table), request.table)
        expected_response
      end

      stub_table_admin_grpc(:create_table, mock_method) do
        req_table = Bigtable::Table.new(name: table_id)
        response = @client.create_table(req_table)
        assert_equal(expected_response, response)
      end
    end

    it 'invokes create_table with error' do
      custom_error = TableAdminTestError.new "create_table"
      table_id = 'table_2'
      table = {}

      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::CreateTableRequest, request)
        assert_equal(@instance_path, request.parent)
        assert_equal(table_id, request.table_id)
        assert_equal(Google::Gax::to_proto(table, Bigtable::Table), request.table)
        raise custom_error
      end

      stub_table_admin_grpc(:create_table, mock_method) do
        req_table = Bigtable::Table.new(name: table_id)
        err = assert_raises Google::Gax::GaxError do
          @client.create_table(req_table)
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
        assert_equal(@instance_path, request.parent)
        expected_response
      end

      stub_table_admin_grpc(:list_tables, mock_method) do
        response = @client.tables
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
        assert_equal(@instance_path, request.parent)
        raise custom_error
      end

      stub_table_admin_grpc(:list_tables, mock_method) do
        err = assert_raises Google::Gax::GaxError do
          @client.tables
        end

        # Verify the GaxError wrapped the custom error that was raised.
        assert_match(custom_error.message, err.message)
      end
    end
  end

  describe 'get_table' do
    before do
      @table_id = "table-3"
      @table_path = BigtableTableAdminClient.table_path(@project_id, @instance_id, @table_id)
    end

    it 'invokes get_table without error' do
      expected_response = { name: @table_id }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::Table)

      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::GetTableRequest, request)
        assert_equal(@table_path, request.name)
        expected_response
      end

      stub_table_admin_grpc(:get_table, mock_method) do
        response = @client.table(@table_id)
        assert_equal(expected_response, response)
      end
    end

    it 'invokes get_table with error' do
      custom_error = TableAdminTestError.new "get_table"

      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::GetTableRequest, request)
        assert_equal(@table_path, request.name)
        raise custom_error
      end

      stub_table_admin_grpc(:get_table, mock_method) do
        err = assert_raises Google::Gax::GaxError do
          @client.table(@table_id)
        end

        assert_match(custom_error.message, err.message)
      end
    end
  end

  describe 'delete_table' do
    before do
      @table_id = "table-4"
      @table_path = BigtableTableAdminClient.table_path(@project_id, @instance_id, @table_id)
    end

    it 'invokes delete_table without error' do
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::DeleteTableRequest, request)
        assert_equal(@table_path, request.name)
        nil
      end

      stub_table_admin_grpc(:delete_table, mock_method) do
        response = @client.delete_table(@table_id)
        assert_nil(response)
      end
    end

    it 'invokes delete_table with error' do
      custom_error = TableAdminTestError.new "delete_table"

      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::DeleteTableRequest, request)
        assert_equal(@table_path, request.name)
        raise custom_error
      end

      stub_table_admin_grpc(:delete_table, mock_method) do
        err = assert_raises Google::Gax::GaxError do
          @client.delete_table(@table_id)
        end

        assert_match(custom_error.message, err.message)
      end
    end
  end

  describe 'modify_column_families' do
    before do
      @table_id = "table-5"
      @table_path = BigtableTableAdminClient.table_path(@project_id, @instance_id, @table_id)
    end

    it 'invokes modify_column_families without error' do
      modifications = [
        Bigtable::ColumnFamilyModification.new({
          id: 'cf1',
          create: Bigtable::ColumnFamily.new(gc_rule: { max_num_versions: 1 })
        }),
        Bigtable::ColumnFamilyModification.new({
          id: 'cf2',
          drop: true
        })
      ]

      # Create expected grpc response
      expected_response = { name: @table_id }
      expected_response = Google::Gax::to_proto(expected_response, Bigtable::Table)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::ModifyColumnFamiliesRequest, request)
        assert_equal(@table_path, request.name)
        modifications = modifications.map do |req|
          Google::Gax::to_proto(req, Google::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification)
        end
        assert_equal(modifications, request.modifications)
        expected_response
      end

      stub_table_admin_grpc(:modify_column_families, mock_method) do
        response = @client.modify_column_families(@table_id, modifications)
        assert_equal(expected_response, response)
      end
    end

    it 'invokes modify_column_families with error' do
      custom_error = TableAdminTestError.new "modify_column_families"
      modifications = []

      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::ModifyColumnFamiliesRequest, request)
        assert_equal(@table_path, request.name)
        modifications = modifications.map do |req|
          Google::Gax::to_proto(req, Google::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification)
        end
        assert_equal(modifications, request.modifications)
        raise custom_error
      end

      stub_table_admin_grpc(:modify_column_families, mock_method) do
        err = assert_raises Google::Gax::GaxError do
          @client.modify_column_families(@table_id  , modifications)
        end

        assert_match(custom_error.message, err.message)
      end
    end
  end

  describe 'drop_row_range' do
    before do
      @table_id = "table-6"
      @table_path = BigtableTableAdminClient.table_path(@project_id, @instance_id, @table_id)
    end

    it 'invokes drop_row_range without error' do
      row_key_prefix = "user"

      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::DropRowRangeRequest, request)
        assert_equal(@table_path, request.name)
        assert_equal(row_key_prefix, request.row_key_prefix)
        nil
      end

      stub_table_admin_grpc(:drop_row_range, mock_method) do
        response = @client.drop_row_range(@table_id, row_key_prefix: row_key_prefix)
        assert_nil(response)
      end
    end

    it 'invokes drop_row_range with error' do
      custom_error = TableAdminTestError.new "drop_row_range"
      delete_all_data_from_table = true

      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::DropRowRangeRequest, request)
        assert_equal(@table_path, request.name)
        assert_equal(delete_all_data_from_table,request.delete_all_data_from_table)
        raise custom_error
      end

      stub_table_admin_grpc(:drop_row_range, mock_method) do
        err = assert_raises Google::Gax::GaxError do
          @client.drop_row_range(@table_id, delete_all_data_from_table: true)
        end

        assert_match(custom_error.message, err.message)
      end
    end
  end
end
