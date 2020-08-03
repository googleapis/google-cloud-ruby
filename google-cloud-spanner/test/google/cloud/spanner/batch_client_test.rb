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

describe Google::Cloud::Spanner::BatchClient, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:session_id) { "session123" }
  let(:session_grpc) { Google::Cloud::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id) }
  let(:session) { Google::Cloud::Spanner::Session.from_grpc session_grpc, spanner.service }
  let(:transaction_id) { "tx789" }
  let(:timestamp) { Google::Protobuf::Timestamp.new seconds: 1412262083, nanos: 45123456 }
  let(:timestamp_time) { Google::Cloud::Spanner::Convert.timestamp_to_time timestamp }
  let(:transaction_grpc) { Google::Cloud::Spanner::V1::Transaction.new id: transaction_id, read_timestamp: timestamp }
  let(:batch_tx_hash) { { session: Base64.strict_encode64(session_grpc.to_proto), transaction: Base64.strict_encode64(transaction_grpc.to_proto) } }
  let(:snp_opts) { Google::Cloud::Spanner::V1::TransactionOptions::ReadOnly.new return_read_timestamp: true }
  let(:tx_opts) { Google::Cloud::Spanner::V1::TransactionOptions.new read_only: snp_opts }
  let(:default_options) { { metadata: { "google-cloud-resource-prefix" => database_path(instance_id, database_id) } } }
  let(:batch_client) { spanner.batch_client instance_id, database_id }

  let(:labels) { { "env" => "production" } }
  let(:batch_client_labels) { spanner.batch_client instance_id, database_id, labels: labels }

  it "knows its project_id" do
    _(batch_client.project_id).must_equal project
  end

  it "holds a reference to project" do
    _(batch_client.project).must_equal spanner
  end

  it "knows its instance_id" do
    _(batch_client.instance_id).must_equal instance_id
  end

  it "retrieves the instance" do
    get_res = Google::Cloud::Spanner::Admin::Instance::V1::Instance.new instance_hash(name: instance_id)
    mock = Minitest::Mock.new
    mock.expect :get_instance, get_res, [{ name: instance_path(instance_id) }, nil]
    spanner.service.mocked_instances = mock

    instance = spanner.instance instance_id

    mock.verify

    _(instance.project_id).must_equal project
    _(instance.instance_id).must_equal instance_id
    _(instance.path).must_equal instance_path(instance_id)
  end

  it "knows its database_id" do
    _(batch_client.database_id).must_equal database_id
  end

  it "retrieves the database" do
    get_res = Google::Cloud::Spanner::Admin::Database::V1::Database.new database_hash(instance_id: instance_id, database_id: database_id)
    mock = Minitest::Mock.new
    mock.expect :get_database, get_res, [{ name: database_path(instance_id, database_id) }, nil]
    spanner.service.mocked_databases = mock

    database = batch_client.database

    mock.verify

    _(database.project_id).must_equal project
    _(database.instance_id).must_equal instance_id
    _(database.database_id).must_equal database_id
    _(database.path).must_equal database_path(instance_id, database_id)
  end

  it "creates a batch_snapshot" do
    mock = Minitest::Mock.new
    mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
    mock.expect :begin_transaction, transaction_grpc, [{ session: session_grpc.name, options: tx_opts }, default_options]
    spanner.service.mocked_service = mock

    batch_snapshot = batch_client.batch_snapshot

    mock.verify

    _(batch_snapshot.transaction_id).must_equal transaction_id
    _(batch_snapshot.timestamp).must_equal timestamp_time
    _(batch_snapshot.session.path).must_equal session.path
  end

  it "creates a batch_snapshot with session labels" do
    mock = Minitest::Mock.new
    session_labels_grpc = Google::Cloud::Spanner::V1::Session.new labels: labels
    session_labels_resp_grpc = Google::Cloud::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id), labels: labels
    mock.expect :create_session, session_labels_resp_grpc, [{ database: database_path(instance_id, database_id), session: session_labels_grpc }, default_options]
    mock.expect :begin_transaction, transaction_grpc, [{ session: session_grpc.name, options: tx_opts }, default_options]
    spanner.service.mocked_service = mock

    batch_snapshot = batch_client_labels.batch_snapshot

    mock.verify

    _(batch_snapshot.transaction_id).must_equal transaction_id
    _(batch_snapshot.timestamp).must_equal timestamp_time
    _(batch_snapshot.session.path).must_equal session.path
  end

  describe :strong do
    let(:snp_opts) { Google::Cloud::Spanner::V1::TransactionOptions::ReadOnly.new strong: true, return_read_timestamp: true }

    it "creates a batch_snapshot with strong timestamp bound" do
      mock = Minitest::Mock.new
      mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
      mock.expect :begin_transaction, transaction_grpc, [{ session: session_grpc.name, options: tx_opts }, default_options]
      spanner.service.mocked_service = mock

      batch_snapshot = batch_client.batch_snapshot strong: true

      mock.verify

      _(batch_snapshot.transaction_id).must_equal transaction_id
      _(batch_snapshot.timestamp).must_equal timestamp_time
      _(batch_snapshot.session.path).must_equal session.path
    end
  end

  describe :timestamp do
    let(:snapshot_time) { Time.now }
    let(:snapshot_datetime) { snapshot_time.to_datetime }
    let(:snapshot_timestamp) { Google::Cloud::Spanner::Convert.time_to_timestamp snapshot_time }
    let(:snp_opts) { Google::Cloud::Spanner::V1::TransactionOptions::ReadOnly.new read_timestamp: snapshot_timestamp, return_read_timestamp: true }

    it "creates a batch_snapshot with timestamp option (Time)" do
      mock = Minitest::Mock.new
      mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
      mock.expect :begin_transaction, transaction_grpc, [{ session: session_grpc.name, options: tx_opts }, default_options]
      spanner.service.mocked_service = mock

      batch_snapshot = batch_client.batch_snapshot timestamp: snapshot_time

      mock.verify

      _(batch_snapshot.transaction_id).must_equal transaction_id
      _(batch_snapshot.timestamp).must_equal timestamp_time
      _(batch_snapshot.session.path).must_equal session.path
    end

    it "creates a batch_snapshot with read_timestamp option (Time)" do
      mock = Minitest::Mock.new
      mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
      mock.expect :begin_transaction, transaction_grpc, [{ session: session_grpc.name, options: tx_opts }, default_options]
      spanner.service.mocked_service = mock

      batch_snapshot = batch_client.batch_snapshot read_timestamp: snapshot_time

      mock.verify

      _(batch_snapshot.transaction_id).must_equal transaction_id
      _(batch_snapshot.timestamp).must_equal timestamp_time
      _(batch_snapshot.session.path).must_equal session.path
    end

    it "creates a batch_snapshot with timestamp option (DateTime)" do
      mock = Minitest::Mock.new
      mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
      mock.expect :begin_transaction, transaction_grpc, [{ session: session_grpc.name, options: tx_opts }, default_options]
      spanner.service.mocked_service = mock

      batch_snapshot = batch_client.batch_snapshot timestamp: snapshot_datetime

      mock.verify

      _(batch_snapshot.transaction_id).must_equal transaction_id
      _(batch_snapshot.timestamp).must_equal timestamp_time
      _(batch_snapshot.session.path).must_equal session.path
    end

    it "creates a batch_snapshot with read_timestamp option (DateTime)" do
      mock = Minitest::Mock.new
      mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
      mock.expect :begin_transaction, transaction_grpc, [{ session: session_grpc.name, options: tx_opts }, default_options]
      spanner.service.mocked_service = mock

      batch_snapshot = batch_client.batch_snapshot read_timestamp: snapshot_datetime

      mock.verify

      _(batch_snapshot.transaction_id).must_equal transaction_id
      _(batch_snapshot.timestamp).must_equal timestamp_time
      _(batch_snapshot.session.path).must_equal session.path
    end
  end

  describe :staleness do
    let(:snapshot_staleness) { 60 }
    let(:duration_staleness) { Google::Cloud::Spanner::Convert.number_to_duration snapshot_staleness }
    let(:snp_opts) { Google::Cloud::Spanner::V1::TransactionOptions::ReadOnly.new exact_staleness: duration_staleness, return_read_timestamp: true }

    it "creates a batch_snapshot with the staleness option" do
      mock = Minitest::Mock.new
      mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
      mock.expect :begin_transaction, transaction_grpc, [{ session: session_grpc.name, options: tx_opts }, default_options]
      spanner.service.mocked_service = mock

      batch_snapshot = batch_client.batch_snapshot staleness: snapshot_staleness

      mock.verify

      _(batch_snapshot.transaction_id).must_equal transaction_id
      _(batch_snapshot.timestamp).must_equal timestamp_time
      _(batch_snapshot.session.path).must_equal session.path
    end

    it "creates a batch_snapshot with the exact_staleness option" do
      mock = Minitest::Mock.new
      mock.expect :create_session, session_grpc, [{ database: database_path(instance_id, database_id), session: nil }, default_options]
      mock.expect :begin_transaction, transaction_grpc, [{ session: session_grpc.name, options: tx_opts }, default_options]
      spanner.service.mocked_service = mock

      batch_snapshot = batch_client.batch_snapshot exact_staleness: snapshot_staleness

      mock.verify

      _(batch_snapshot.transaction_id).must_equal transaction_id
      _(batch_snapshot.timestamp).must_equal timestamp_time
      _(batch_snapshot.session.path).must_equal session.path
    end
  end

  it "loads a batch_snapshot (hash)" do
    batch_snapshot = batch_client.load_batch_snapshot batch_tx_hash

    _(batch_snapshot.transaction_id).must_equal transaction_id
    _(batch_snapshot.timestamp).must_equal timestamp_time
    _(batch_snapshot.session.path).must_equal session.path
  end

  it "loads a batch_snapshot (json)" do
    batch_snapshot = batch_client.load_batch_snapshot batch_tx_hash

    _(batch_snapshot.transaction_id).must_equal transaction_id
    _(batch_snapshot.timestamp).must_equal timestamp_time
    _(batch_snapshot.session.path).must_equal session.path
  end

  it "creates an inclusive range" do
    range = batch_client.range 1, 100

    _(range.begin).must_equal 1
    _(range.end).must_equal 100

    _(range).wont_be :exclude_begin?
    _(range).wont_be :exclude_end?
  end

  it "creates an exclusive range" do
    range = batch_client.range 1, 100, exclude_begin: true, exclude_end: true

    _(range.begin).must_equal 1
    _(range.end).must_equal 100

    _(range).must_be :exclude_begin?
    _(range).must_be :exclude_end?
  end

  it "creates a range that excludes beginning" do
    range = batch_client.range 1, 100, exclude_begin: true

    _(range.begin).must_equal 1
    _(range.end).must_equal 100

    _(range).must_be :exclude_begin?
    _(range).wont_be :exclude_end?
  end

  it "creates a range that excludes ending" do
    range = batch_client.range 1, 100, exclude_end: true

    _(range.begin).must_equal 1
    _(range.end).must_equal 100

    _(range).wont_be :exclude_begin?
    _(range).must_be :exclude_end?
  end
end
