# Copyright 2017 Google LLC
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

Thread.abort_on_exception = true

describe Google::Cloud::Bigquery::Dataset, :insert_async, :mock_bigquery do
  let(:dataset_id) { "my_dataset" }
  let(:dataset_hash) { random_dataset_hash dataset_id }
  let(:dataset_gapi) { Google::Apis::BigqueryV2::Dataset.from_json dataset_hash.to_json }
  let(:dataset) { Google::Cloud::Bigquery::Dataset.from_gapi dataset_gapi, bigquery.service }

  let(:table_id) { "my_table" }
  let(:table_hash) { random_table_hash dataset_id, table_id }
  let(:table_gapi) { Google::Apis::BigqueryV2::Table.from_json table_hash.to_json }

  let(:rows) { [{"name"=>"Heidi", "age"=>"36", "score"=>"7.65", "active"=>"true"},
                {"name"=>"Aaron", "age"=>"42", "score"=>"8.15", "active"=>"false"},
                {"name"=>"Sally", "age"=>nil, "score"=>nil, "active"=>nil}] }
  let(:insert_id) { "abc123" }
  let(:insert_rows) { rows.map do |row|
                        {
                          insertId: insert_id,
                          json: row
                        }
                      end }
  let(:insert_ids) { ["a1", "b2", "c3"] }
  let(:rows_with_user_insert_ids) { rows.each_with_index.map do |row, i|
                                      {
                                          insertId: insert_ids[i],
                                          json: row
                                      }
                                    end }
  let(:success_table_insert_gapi) { Google::Apis::BigqueryV2::InsertAllTableDataResponse.new insert_errors: [] }

  it "inserts one row" do
    mock = Minitest::Mock.new
    insert_req = {
      rows: [insert_rows.first], ignoreUnknownValues: nil, skipInvalidRows: nil
    }.to_json
    mock.expect :get_table, table_gapi, [project, dataset_id, table_id]
    mock.expect :insert_all_table_data, success_table_insert_gapi,
      [project, dataset_id, table_id, insert_req, options: { skip_serialization: true }]
    dataset.service.mocked_service = mock

    inserter = dataset.insert_async table_id

    SecureRandom.stub :uuid, insert_id do
      inserter.insert rows.first

      inserter.batch.rows.must_equal [rows.first]

      inserter.must_be :started?
      inserter.wont_be :stopped?

      # force the queued rows to be inserted
      inserter.flush
      inserter.stop.wait!

      inserter.wont_be :started?
      inserter.must_be :stopped?

      inserter.batch.must_be :nil?
    end

    mock.verify
  end

  describe "dataset reference" do
    let(:dataset) {Google::Cloud::Bigquery::Dataset.new_reference project, dataset_id, bigquery.service }

    it "inserts one row" do
      mock = Minitest::Mock.new
      insert_req = {
        rows: [insert_rows.first], ignoreUnknownValues: nil, skipInvalidRows: nil
      }.to_json
      mock.expect :get_table, table_gapi, [project, dataset_id, table_id]
      mock.expect :insert_all_table_data, success_table_insert_gapi,
        [project, dataset_id, table_id, insert_req, options: { skip_serialization: true }]
      dataset.service.mocked_service = mock

      inserter = dataset.insert_async table_id

      SecureRandom.stub :uuid, insert_id do
        inserter.insert rows.first

        inserter.batch.rows.must_equal [rows.first]

        inserter.must_be :started?
        inserter.wont_be :stopped?

        # force the queued rows to be inserted
        inserter.flush
        inserter.stop.wait!

        inserter.wont_be :started?
        inserter.must_be :stopped?

        inserter.batch.must_be :nil?
      end

      mock.verify
    end
  end

  it "inserts three rows at the same time" do
    mock = Minitest::Mock.new
    insert_req = {
      rows: insert_rows, ignoreUnknownValues: nil, skipInvalidRows: nil
    }.to_json
    mock.expect :get_table, table_gapi, [project, dataset_id, table_id]
    mock.expect :insert_all_table_data, success_table_insert_gapi,
      [project, dataset_id, table_id, insert_req, options: { skip_serialization: true }]
    dataset.service.mocked_service = mock

    inserter = dataset.insert_async table_id

    SecureRandom.stub :uuid, insert_id do
      inserter.insert rows

      inserter.batch.rows.must_equal rows

      inserter.must_be :started?
      inserter.wont_be :stopped?

      # force the queued rows to be inserted
      inserter.flush
      inserter.stop.wait!

      inserter.wont_be :started?
      inserter.must_be :stopped?

      inserter.batch.must_be :nil?
    end

    mock.verify
  end

  it "inserts three rows one at a time" do
    mock = Minitest::Mock.new
    insert_req = {
      rows: insert_rows, ignoreUnknownValues: nil, skipInvalidRows: nil
    }.to_json
    mock.expect :get_table, table_gapi, [project, dataset_id, table_id]
    mock.expect :insert_all_table_data, success_table_insert_gapi,
      [project, dataset_id, table_id, insert_req, options: { skip_serialization: true }]
    dataset.service.mocked_service = mock

    inserter = dataset.insert_async table_id

    SecureRandom.stub :uuid, insert_id do
      rows.each do |row|
        inserter.insert row
      end

      inserter.batch.rows.must_equal rows

      inserter.must_be :started?
      inserter.wont_be :stopped?

      # force the queued rows to be inserted
      inserter.flush
      inserter.stop.wait!

      inserter.wont_be :started?
      inserter.must_be :stopped?

      inserter.batch.must_be :nil?
    end

    mock.verify
  end

  it "inserts rows with a callback" do
    mock = Minitest::Mock.new
    insert_req = {
      rows: insert_rows, ignoreUnknownValues: nil, skipInvalidRows: nil
    }.to_json
    mock.expect :get_table, table_gapi, [project, dataset_id, table_id]
    mock.expect :insert_all_table_data, success_table_insert_gapi,
      [project, dataset_id, table_id, insert_req, options: { skip_serialization: true }]
    dataset.service.mocked_service = mock

    callback_called = false
    insert_result = nil

    inserter = dataset.insert_async table_id do |result|
        insert_result = result
        callback_called = true
      end

    SecureRandom.stub :uuid, insert_id do
      inserter.insert rows

      inserter.batch.rows.must_equal rows

      inserter.must_be :started?
      inserter.wont_be :stopped?

      # force the queued rows to be inserted
      inserter.flush
      wait_until { callback_called == true }
      inserter.stop.wait!

      inserter.wont_be :started?
      inserter.must_be :stopped?

      inserter.batch.must_be :nil?
    end

    insert_result.wont_be_nil
    insert_result.must_be_kind_of Google::Cloud::Bigquery::Table::AsyncInserter::Result
    insert_result.wont_be :error?
    insert_result.error.must_be_nil
    insert_result.must_be :success?
    insert_result.insert_response.wont_be_nil
    insert_result.insert_count.must_equal 3
    insert_result.error_count.must_equal 0
    insert_result.insert_errors.must_be_kind_of Array
    insert_result.insert_errors.must_be :empty?
    insert_result.error_rows.must_be_kind_of Array
    insert_result.error_rows.must_be :empty?

    mock.verify
  end

  it "inserts multiple batches when row byte size limit is reached" do
    mock = Minitest::Mock.new
    mock.expect :get_table, table_gapi, [project, dataset_id, table_id]
    # It makes two requests, but we can't control what order they occur.
    # So only specify that two requests are made.
    mock.expect :insert_all_table_data, success_table_insert_gapi,
      [project, dataset_id, table_id, String, Hash]
    mock.expect :insert_all_table_data, success_table_insert_gapi,
      [project, dataset_id, table_id, String, Hash]
    dataset.service.mocked_service = mock

    callbacks = 0

    inserter = dataset.insert_async table_id, max_bytes: 150 do |response|
      callbacks += 1
    end

    SecureRandom.stub :uuid, insert_id do
      inserter.insert rows

      inserter.batch.rows.must_equal [rows.last]

      inserter.must_be :started?
      inserter.wont_be :stopped?

      # force the queued rows to be inserted
      inserter.flush
      wait_until { callbacks == 2 }
      inserter.stop.wait!

      inserter.wont_be :started?
      inserter.must_be :stopped?

      inserter.batch.must_be :nil?
    end

    mock.verify
  end

  it "inserts multiple batches when row count limit is reached" do
    mock = Minitest::Mock.new
    mock.expect :get_table, table_gapi, [project, dataset_id, table_id]
    # It makes two requests, but we can't control what order they occur.
    # So only specify that two requests are made.
    mock.expect :insert_all_table_data, success_table_insert_gapi,
      [project, dataset_id, table_id, String, Hash]
    mock.expect :insert_all_table_data, success_table_insert_gapi,
      [project, dataset_id, table_id, String, Hash]
    dataset.service.mocked_service = mock

    callbacks = 0

    inserter = dataset.insert_async table_id, max_rows: 2 do |response|
      callbacks += 1
    end

    SecureRandom.stub :uuid, insert_id do
      inserter.insert rows

      inserter.batch.rows.must_equal [rows.last]

      inserter.must_be :started?
      inserter.wont_be :stopped?

      # force the queued rows to be inserted
      inserter.flush
      wait_until { callbacks == 2 }
      inserter.stop.wait!

      inserter.wont_be :started?
      inserter.must_be :stopped?

      inserter.batch.must_be :nil?
    end

    mock.verify
  end

  it "inserts three rows at the same time with the insert_ids option" do
    mock = Minitest::Mock.new
    insert_req = {
        rows: rows_with_user_insert_ids, ignoreUnknownValues: nil, skipInvalidRows: nil
    }.to_json
    mock.expect :get_table, table_gapi, [project, dataset_id, table_id]
    mock.expect :insert_all_table_data, success_table_insert_gapi,
                [project, dataset_id, table_id, insert_req, options: { skip_serialization: true }]
    dataset.service.mocked_service = mock

    inserter = dataset.insert_async table_id

    inserter.insert rows, insert_ids: insert_ids

    inserter.batch.rows.must_equal rows

    inserter.must_be :started?
    inserter.wont_be :stopped?

    # force the queued rows to be inserted
    inserter.flush
    inserter.stop.wait!

    inserter.wont_be :started?
    inserter.must_be :stopped?

    inserter.batch.must_be :nil?

    mock.verify
  end

  it "inserts three rows one at a time with the insert_ids option" do
    mock = Minitest::Mock.new
    insert_req = {
        rows: rows_with_user_insert_ids, ignoreUnknownValues: nil, skipInvalidRows: nil
    }.to_json
    mock.expect :get_table, table_gapi, [project, dataset_id, table_id]
    mock.expect :insert_all_table_data, success_table_insert_gapi,
                [project, dataset_id, table_id, insert_req, options: { skip_serialization: true }]
    dataset.service.mocked_service = mock

    inserter = dataset.insert_async table_id

    rows.zip(insert_ids).each do |row, insert_id|
      inserter.insert row, insert_ids: insert_id
    end

    inserter.batch.rows.must_equal rows

    inserter.must_be :started?
    inserter.wont_be :stopped?

    # force the queued rows to be inserted
    inserter.flush
    inserter.stop.wait!

    inserter.wont_be :started?
    inserter.must_be :stopped?

    inserter.batch.must_be :nil?

    mock.verify
  end

  it "raises if the insert_ids option is provided but size does not match rows" do
    insert_ids.pop # Remove one of the insert_ids to cause error.
    mock = Minitest::Mock.new
    mock.expect :get_table, table_gapi, [project, dataset_id, table_id]
    dataset.service.mocked_service = mock

    inserter = dataset.insert_async table_id

    expect { inserter.insert rows, insert_ids: insert_ids }.must_raise ArgumentError

    inserter.batch.must_be :nil?

    inserter.must_be :started?
    inserter.wont_be :stopped?

    # force the queued rows to be inserted
    inserter.flush
    inserter.stop.wait!

    inserter.wont_be :started?
    inserter.must_be :stopped?

    mock.verify
  end

  def wait_until delay: 0.01, max: 100, output: nil, msg: "criteria not met", &block
    attempts = 0
    while !block.call
      return if attempts >= max
      # fail msg if attempts >= max
      attempts += 1
      puts "Retrying #{attempts} out of #{max}." if output
      sleep delay
    end
  end
end
