# Copyright 2019 Google LLC
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

describe Google::Cloud::Spanner::ClientServiceProxy, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:session_id) { "session123" }
  let(:session_name) { session_path(instance_id, database_id, session_id) }
  let(:client_service_proxy) {
    Google::Cloud::Spanner::ClientServiceProxy.new \
      spanner, instance_id, enable_resource_based_routing: true
  }
  let(:instance_endpoint_uri) { "test.host.com" }
  let(:get_instance_req) {
    [
      instance_path(instance_id),
      field_mask: Google::Protobuf::FieldMask.new(paths: ["endpoint_uris"])
    ]
  }
  let(:get_insance_res){
    Google::Spanner::Admin::Instance::V1::Instance.new \
      name: instance_path(instance_id), endpoint_uris: [instance_endpoint_uri]
  }
  let(:statement){
    Google::Spanner::V1::ExecuteBatchDmlRequest::Statement.new \
      sql: "UPDATE users SET age = @age",
      params: Google::Protobuf::Struct.new(fields:
        { "age" => Google::Protobuf::Value.new(string_value: "29") }
      ),
      param_types: { "age" => Google::Spanner::V1::Type.new(code: :INT64) }
  }
  let(:tx_selector) {
    Google::Spanner::V1::TransactionSelector.new id: "tx123"
  }

  it "knows the identifiers" do
    client_service_proxy.must_be_kind_of Google::Cloud::Spanner::Service
    client_service_proxy.instance_variable_get("@project").must_equal spanner
    client_service_proxy.instance_variable_get("@instance_id").must_equal instance_id
    client_service_proxy.instance_variable_get("@enable_resource_based_routing").must_equal true
  end

  describe "api calls" do
    before :each do
      @mock = Minitest::Mock.new
      @mock.expect :get_instance, get_insance_res, [
        instance_path(instance_id),
        field_mask: Google::Protobuf::FieldMask.new(paths: ["endpoint_uris"])
      ]
      spanner.service.mocked_instances = @mock
    end

    it "add endpoint uri to get_session" do
      api_call_stub = proc do |session_name, endpoint_uri: nil|
        session_name.must_equal session_path(instance_id, database_id, session_id)
        endpoint_uri.must_equal instance_endpoint_uri
      end

      spanner.service.stub :get_session, api_call_stub do
        client_service_proxy.get_session session_name
      end

      @mock.verify
    end

    it "add endpoint uri to create_session" do
      api_call_stub = proc do |database_name, labels: nil, endpoint_uri: nil|
        database_name.must_equal database_path(instance_id, database_id)
        labels.must_equal ["test-session"]
        endpoint_uri.must_equal instance_endpoint_uri
      end

      spanner.service.stub :create_session, api_call_stub do
        client_service_proxy.create_session \
          database_path(instance_id, database_id), labels: ["test-session"]
      end

      @mock.verify
    end

    it "add endpoint uri to batch_create_sessions" do
      api_call_stub = proc do |database_name, session_count, labels: nil, endpoint_uri: nil|
        database_name.must_equal database_path(instance_id, database_id)
        session_count.must_equal 5
        labels.must_equal ["test-session"]
        endpoint_uri.must_equal instance_endpoint_uri
      end

      spanner.service.stub :batch_create_sessions, api_call_stub do
        client_service_proxy.batch_create_sessions \
          database_path(instance_id, database_id), 5, labels: ["test-session"]
      end

      @mock.verify
    end

    it "add endpoint uri to delete_session" do
      api_call_stub = proc do |session_name, endpoint_uri: nil|
        session_name.must_equal session_path(instance_id, database_id, session_id)
        endpoint_uri.must_equal instance_endpoint_uri
      end

      spanner.service.stub :delete_session, api_call_stub do
        client_service_proxy.delete_session session_name
      end

      @mock.verify
    end

    it "add endpoint uri to execute_streaming_sql" do
      api_call_stub = proc do |session_name, sql, transaction: nil,
          params: nil, types: nil, resume_token: nil, partition_token: nil,
          seqno: nil, endpoint_uri: nil|
        session_name.must_equal session_path(instance_id, database_id, session_id)
        sql.must_equal statement.sql
        transaction.must_equal tx_selector
        params.must_equal statement.params
        types.must_equal statement.param_types
        resume_token.must_equal "test-resume-token"
        partition_token.must_equal "test-partition-token"
        seqno.must_equal 1
        endpoint_uri.must_equal instance_endpoint_uri
      end

      spanner.service.stub :execute_streaming_sql, api_call_stub do
        client_service_proxy.execute_streaming_sql \
          session_name,
          statement.sql,
          transaction: tx_selector,
          params: statement.params,
          types: statement.param_types,
          resume_token: "test-resume-token",
          partition_token: "test-partition-token",
          seqno: 1
      end

      @mock.verify
    end

    it "add endpoint uri to execute_batch_dml" do
      api_call_stub = proc do |session_name, transaction, statements, seqno, endpoint_uri: nil|
        session_name.must_equal session_path(instance_id, database_id, session_id)
        transaction.must_equal tx_selector
        statements.must_equal [statement]
        seqno.must_equal 1
        endpoint_uri.must_equal instance_endpoint_uri
      end

      spanner.service.stub :execute_batch_dml, api_call_stub do
        client_service_proxy.execute_batch_dml \
          session_name, tx_selector, [statement], 1
      end

      @mock.verify
    end

    it "add endpoint uri to streaming_read_table" do
      api_call_stub = proc do |session_name, table_name, columns,
          keys: nil, index: nil, transaction: nil, limit: nil, resume_token: nil,
          partition_token: nil, endpoint_uri: nil|
        session_name.must_equal session_path(instance_id, database_id, session_id)
        table_name.must_equal "users"
        columns.must_equal ["id", "name"]
        keys.must_equal Google::Spanner::V1::KeySet.new(all: true)
        index.must_equal "id"
        transaction.must_equal tx_selector
        limit.must_equal 100
        resume_token.must_equal "test-resume-token"
        partition_token.must_equal "test-partition-token"
        endpoint_uri.must_equal instance_endpoint_uri
      end

      spanner.service.stub :streaming_read_table, api_call_stub do
        client_service_proxy.streaming_read_table \
          session_name, "users", ["id", "name"],
          keys: Google::Spanner::V1::KeySet.new(all: true),
          index: "id",
          transaction: tx_selector,
          limit: 100,
          resume_token: "test-resume-token",
          partition_token: "test-partition-token"
      end

      @mock.verify
    end

    it "add endpoint uri to partition_read" do
      api_call_stub = proc do |session_name, table_name, columns, transaction,
          keys: nil, index: nil, partition_size_bytes: nil, max_partitions: nil,
          endpoint_uri: nil|
        session_name.must_equal session_path(instance_id, database_id, session_id)
        table_name.must_equal "users"
        columns.must_equal ["id", "name"]
        transaction.must_equal tx_selector
        keys.must_equal Google::Spanner::V1::KeySet.new(all: true)
        index.must_equal "id"
        partition_size_bytes.must_equal 1024
        max_partitions.must_equal 3
        endpoint_uri.must_equal instance_endpoint_uri
      end

      spanner.service.stub :partition_read, api_call_stub do
        client_service_proxy.partition_read \
          session_name, "users", ["id", "name"], tx_selector,
          keys: Google::Spanner::V1::KeySet.new(all: true),
          index: "id",
          partition_size_bytes: 1024,
          max_partitions: 3
      end

      @mock.verify
    end

    it "add endpoint uri to partition_query" do
      api_call_stub = proc do |session_name, sql, transaction, params: nil,
          types: nil, partition_size_bytes: nil, max_partitions: nil,
          endpoint_uri: nil|
        session_name.must_equal session_path(instance_id, database_id, session_id)
        sql.must_equal statement.sql
        transaction.must_equal tx_selector
        params.must_equal statement.params
        types.must_equal statement.param_types
        partition_size_bytes.must_equal 2048
        max_partitions.must_equal 5
        endpoint_uri.must_equal instance_endpoint_uri
      end

      spanner.service.stub :partition_query, api_call_stub do
        client_service_proxy.partition_query \
          session_name, statement.sql, tx_selector,
          params: statement.params,
          types: statement.param_types,
          partition_size_bytes: 2048,
          max_partitions: 5
      end

      @mock.verify
    end

    it "add endpoint uri to begin_transaction" do
      api_call_stub = proc do |session_name, endpoint_uri: nil|
        session_name.must_equal session_path(instance_id, database_id, session_id)
        endpoint_uri.must_equal instance_endpoint_uri
      end

      spanner.service.stub :begin_transaction, api_call_stub do
        client_service_proxy.begin_transaction session_name
      end

      @mock.verify
    end

    it "add endpoint uri to commit" do
      req_mutations = [
        Google::Spanner::V1::Mutation.new(
          update: Google::Spanner::V1::Mutation::Write.new(
            table: "users", columns: %w(id name active),
            values: [Google::Cloud::Spanner::Convert.object_to_grpc_value([1, "Charlie", false]).list_value]
          )
        )
      ]
      api_call_stub = proc do |session_name, mutations, transaction_id: nil, endpoint_uri: nil|
        session_name.must_equal session_path(instance_id, database_id, session_id)
        mutations.must_equal req_mutations
        transaction_id.must_equal "txn123"
        endpoint_uri.must_equal instance_endpoint_uri
      end

      spanner.service.stub :commit, api_call_stub do
        client_service_proxy.commit session_name, req_mutations, transaction_id: "txn123"
      end

      @mock.verify
    end

    focus
    it "add endpoint uri to rollback" do
      api_call_stub = proc do |session_name, transaction_id, endpoint_uri: nil|
        session_name.must_equal session_path(instance_id, database_id, session_id)
        transaction_id.must_equal "txn123"
        endpoint_uri.must_equal instance_endpoint_uri
      end

      spanner.service.stub :rollback, api_call_stub do
        client_service_proxy.rollback session_name, "txn123"
      end

      @mock.verify
    end

    focus
    it "add endpoint uri to create_snapshot" do
      timestamp = Time.now
      api_call_stub = proc do |session_name, strong: nil, timestamp: nil,
          staleness: nil, endpoint_uri: nil|
        session_name.must_equal session_path(instance_id, database_id, session_id)
        strong.must_equal true
        timestamp.must_equal timestamp
        staleness.must_equal 30
        endpoint_uri.must_equal instance_endpoint_uri
      end

      spanner.service.stub :create_snapshot, api_call_stub do
        client_service_proxy.create_snapshot \
          session_name,
          strong: true,
          timestamp: timestamp,
          staleness: 30
      end

      @mock.verify
    end

    it "add endpoint uri to create_pdml" do
      api_call_stub = proc do |session_name, endpoint_uri: nil|
        session_name.must_equal session_path(instance_id, database_id, session_id)
        endpoint_uri.must_equal instance_endpoint_uri
      end

      spanner.service.stub :create_pdml, api_call_stub do
        client_service_proxy.create_pdml session_name
      end

      @mock.verify
    end
  end
end
