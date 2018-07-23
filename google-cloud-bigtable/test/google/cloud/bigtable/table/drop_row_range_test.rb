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

describe Google::Cloud::Bigtable::Table, :drop_rows, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:table_id) { "test-table" }
  let(:cluster_states) { clusters_state_grpc }
  let(:column_families) { column_families_grpc }
  let(:table_grpc) do
    Google::Bigtable::Admin::V2::Table.new(
      table_hash(
        name: table_path(instance_id, table_id),
        cluster_states: cluster_states,
        column_families: column_families,
        granularity: :MILLIS
      )
    )
  end
  let(:table) do
    Google::Cloud::Bigtable::Table.from_grpc(table_grpc, bigtable.service)
  end

  describe "drop_row_range" do
    it "drop rows using row key prefix" do
      mock = Minitest::Mock.new
      mock.expect :drop_row_range, true, [
        table_path(instance_id, table_id),
        row_key_prefix: "user",
        delete_all_data_from_table: nil,
        options: nil
      ]
      bigtable.service.mocked_tables = mock

      result = table.drop_row_range(row_key_prefix: "user")
      result.must_equal true
      mock.verify
    end

    it "drop rows all data rows" do
      mock = Minitest::Mock.new
      mock.expect :drop_row_range, true, [
        table_path(instance_id, table_id),
        row_key_prefix: nil,
        delete_all_data_from_table: true,
        options: nil
      ]
      bigtable.service.mocked_tables = mock

      result = table.drop_row_range(delete_all_data: true)
      result.must_equal true
      mock.verify
    end

    it "drop rows all data rows with timeout option" do
      timeout_secs = 10
      stub = OpenStruct.new(
        expected_table_path: table_path(instance_id, table_id),
        expected_timeout: timeout_secs * 1000
      )

      def stub.drop_row_range parent, args
        parent.must_equal expected_table_path
        args[:row_key_prefix].must_be :nil?
        args[:delete_all_data_from_table].must_equal true

        retry_timeout = args[:options].retry_options.backoff_settings.initial_rpc_timeout_millis
        retry_timeout.must_equal expected_timeout
        nil
      end
      bigtable.service.mocked_tables = stub

      result = table.drop_row_range(delete_all_data: true, timeout: timeout_secs)
      result.must_equal true
    end
  end

  describe "delete_all_rows" do
    it "delete all rows" do
      mock = Minitest::Mock.new
      mock.expect :drop_row_range, true, [
        table_path(instance_id, table_id),
        row_key_prefix: nil,
        delete_all_data_from_table: true,
        options: nil
      ]
      bigtable.service.mocked_tables = mock

      result = table.delete_all_rows
      result.must_equal true
      mock.verify
    end

    it "drop rows all rows with timeout" do
      timeout_secs = 10
      stub = OpenStruct.new(
        expected_table_path: table_path(instance_id, table_id),
        expected_timeout: timeout_secs * 1000
      )

      def stub.drop_row_range parent, args
        parent.must_equal expected_table_path
        args[:row_key_prefix].must_be :nil?
        args[:delete_all_data_from_table].must_equal true

        retry_timeout = args[:options].retry_options.backoff_settings.initial_rpc_timeout_millis
        retry_timeout.must_equal expected_timeout
        nil
      end
      bigtable.service.mocked_tables = stub

      result = table.delete_all_rows(timeout: timeout_secs)
      result.must_equal true
    end
  end

  describe "delete_rows_by_prefix" do
    it "delete rows by prefix" do
      mock = Minitest::Mock.new
      mock.expect :drop_row_range, true, [
        table_path(instance_id, table_id),
        row_key_prefix: "user",
        delete_all_data_from_table: nil,
        options: nil
      ]
      bigtable.service.mocked_tables = mock

      result = table.delete_rows_by_prefix("user")
      result.must_equal true
      mock.verify
    end

    it "delete rows by prefix with timeout" do
      timeout_secs = 10
      stub = OpenStruct.new(
        expected_table_path: table_path(instance_id, table_id),
        expected_timeout: timeout_secs * 1000
      )

      def stub.drop_row_range parent, args
        parent.must_equal expected_table_path
        args[:row_key_prefix].must_equal "user"
        args[:delete_all_data_from_table].must_be :nil?

        retry_timeout = args[:options].retry_options.backoff_settings.initial_rpc_timeout_millis
        retry_timeout.must_equal expected_timeout
        nil
      end
      bigtable.service.mocked_tables = stub

      result = table.delete_rows_by_prefix("user", timeout: timeout_secs)
      result.must_equal true
    end
  end
end
