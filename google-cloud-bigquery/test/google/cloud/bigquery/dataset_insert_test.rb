# Copyright 2015 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a link of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Google::Cloud::Bigquery::Dataset, :insert, :mock_bigquery do
  let(:dataset_id) { "my_dataset" }
  let(:dataset_gapi) { random_dataset_gapi dataset_id }
  let(:dataset) { Google::Cloud::Bigquery::Dataset.from_gapi dataset_gapi,
                                                      bigquery.service }

  let(:rows) { [{"name"=>"Heidi", "age"=>"36", "score"=>"7.65", "active"=>"true"},
                {"name"=>"Aaron", "age"=>"42", "score"=>"8.15", "active"=>"false"},
                {"name"=>"Sally", "age"=>nil, "score"=>nil, "active"=>nil}] }
  let(:insert_id) { "abc123" }
  let(:insert_rows) { rows.map do |row|
                        Google::Apis::BigqueryV2::InsertAllTableDataRequest::Row.new(
                          insert_id: insert_id,
                          json: row
                        )
                      end }

  let(:table_id) { "table_id" }
  let(:table_hash) { random_table_hash dataset_id, table_id }
  let(:table_gapi) { Google::Apis::BigqueryV2::Table.from_json table_hash.to_json }
  let(:table) { Google::Cloud::Bigquery::Table.from_gapi table_gapi, bigquery.service }

  it "raises if rows is an empty array" do
    expect { dataset.insert table_id, [] }.must_raise ArgumentError
  end

  it "can insert one row" do
    mock = Minitest::Mock.new
    insert_req = Google::Apis::BigqueryV2::InsertAllTableDataRequest.new(
      rows: [insert_rows.first], ignore_unknown_values: nil, skip_invalid_rows: nil)
    mock.expect :insert_all_table_data, success_table_insert_gapi,
                [project, dataset_id, table_id, insert_req]
    dataset.service.mocked_service = mock

    result = nil
    SecureRandom.stub :uuid, insert_id do
      result = dataset.insert table_id, rows.first
    end

    mock.verify

    result.must_be :success?
    result.insert_count.must_equal 1
    result.error_count.must_equal 0
  end

  it "can insert multiple rows" do
    mock = Minitest::Mock.new
    insert_req = Google::Apis::BigqueryV2::InsertAllTableDataRequest.new(
      rows: insert_rows, ignore_unknown_values: nil, skip_invalid_rows: nil)
    mock.expect :insert_all_table_data, success_table_insert_gapi,
                [project, dataset_id, table_id, insert_req]
    dataset.service.mocked_service = mock

    result = nil
    SecureRandom.stub :uuid, insert_id do
      result = dataset.insert table_id, rows
    end

    mock.verify

    result.must_be :success?
    result.insert_count.must_equal 3
    result.error_count.must_equal 0
  end

  it "will indicate there was a problem with the data" do
    mock = Minitest::Mock.new
    insert_req = Google::Apis::BigqueryV2::InsertAllTableDataRequest.new(
      rows: insert_rows, ignore_unknown_values: nil, skip_invalid_rows: nil)
    mock.expect :insert_all_table_data, failure_table_insert_gapi,
                [project, dataset_id, table_id, insert_req]
    dataset.service.mocked_service = mock

    result = nil
    SecureRandom.stub :uuid, insert_id do
      result = dataset.insert table_id, rows
    end

    mock.verify

    result.wont_be :success?
    result.insert_count.must_equal 2
    result.error_count.must_equal 1
    result.insert_errors.count.must_equal 1
    result.insert_errors.first.index.must_equal 0
    result.insert_errors.first.row.must_equal rows.first
    result.insert_errors.first.errors.count.must_equal 1
    result.insert_errors.first.errors.first["reason"].must_equal "r34s0n"
    result.insert_errors.first.errors.first["location"].must_equal "l0c4t10n"
    result.insert_errors.first.errors.first["debugInfo"].must_equal "d3bugInf0"
    result.insert_errors.first.errors.first["message"].must_equal "m3ss4g3"

    result.error_rows.first.must_equal rows.first

    first_row_insert_error = result.insert_error_for(rows.first)
    first_row_insert_error.index.must_equal 0
    first_row_insert_error.row.must_equal rows.first
    first_row_insert_error.errors.first["reason"].must_equal "r34s0n"
    first_row_insert_error.errors.first["location"].must_equal "l0c4t10n"
    first_row_insert_error.errors.first["debugInfo"].must_equal "d3bugInf0"
    first_row_insert_error.errors.first["message"].must_equal "m3ss4g3"

    first_row_index = result.index_for(rows.first)
    first_row_index.must_equal 0

    first_row_errors = result.errors_for(rows.first)
    first_row_errors.count.must_equal 1
    first_row_errors.first["reason"].must_equal "r34s0n"
    first_row_errors.first["location"].must_equal "l0c4t10n"
    first_row_errors.first["debugInfo"].must_equal "d3bugInf0"
    first_row_errors.first["message"].must_equal "m3ss4g3"

    last_row_insert_error = result.insert_error_for(rows.last)
    last_row_insert_error.must_be_nil

    last_row_index = result.index_for(rows.last)
    last_row_index.must_be_nil

    last_row_errors = result.errors_for(rows.last)
    last_row_errors.count.must_equal 0
  end

  it "can specify skipping invalid rows" do
    mock = Minitest::Mock.new
    insert_req = Google::Apis::BigqueryV2::InsertAllTableDataRequest.new(
      rows: insert_rows, ignore_unknown_values: nil, skip_invalid_rows: true)
    mock.expect :insert_all_table_data, success_table_insert_gapi,
                [project, dataset_id, table_id, insert_req]
    dataset.service.mocked_service = mock

    result = nil
    SecureRandom.stub :uuid, insert_id do
      result = dataset.insert table_id, rows, skip_invalid: true
    end

    mock.verify

    result.must_be :success?
    result.insert_count.must_equal 3
    result.error_count.must_equal 0
  end

  it "can specify ignoring unknown values" do
    mock = Minitest::Mock.new
    insert_req = Google::Apis::BigqueryV2::InsertAllTableDataRequest.new(
      rows: insert_rows, ignore_unknown_values: true, skip_invalid_rows: nil)
    mock.expect :insert_all_table_data, success_table_insert_gapi,
                [project, dataset_id, table_id, insert_req]
    dataset.service.mocked_service = mock

    result = nil
    SecureRandom.stub :uuid, insert_id do
      result = dataset.insert table_id, rows, ignore_unknown: true
    end

    mock.verify

    result.must_be :success?
    result.insert_count.must_equal 3
    result.error_count.must_equal 0
  end

  it "properly formats values when inserting" do
    inserting_row = {
      id: 2,
      name: "Gandalf",
      age: 1000,
      weight: 198.6,
      is_magic: true,
      scores: [100.0, 99.0, 0.001],
      spells: [
        { name: "Skydragon",
          discovered_by: "Firebreather",
          properties: [
            { name: "Flying", power: 1.0 },
            { name: "Creature", power: 1.0 },
            { name: "Explodey", power: 11.0 }
          ],
          icon: File.open("acceptance/data/kitten-test-data.json", "rb"),
          last_used: Time.parse("2015-10-31 23:59:56 UTC")
        }
      ],
      tea_time: Google::Cloud::Bigquery::Time.new("15:00:00"),
      next_vacation: Date.parse("2666-06-06"),
      favorite_time: Time.parse("2001-12-19T23:59:59 UTC").utc.to_datetime
    }
    inserted_row_gapi = Google::Apis::BigqueryV2::InsertAllTableDataRequest::Row.new(
      insert_id: insert_id,
      json: {"id"=>2, "name"=>"Gandalf", "age"=>1000, "weight"=>198.6, "is_magic"=>true, "scores"=>[100.0, 99.0, 0.001], "spells"=>[{"name"=>"Skydragon", "discovered_by"=>"Firebreather", "properties"=>[{"name"=>"Flying", "power"=>1.0}, {"name"=>"Creature", "power"=>1.0}, {"name"=>"Explodey", "power"=>11.0}], "icon"=>"eyJuYW1lIjoibWlrZSIsImJyZWVkIjoidGhlY2F0a2luZCIsImlkIjoxLCJkb2IiOjE0ODg0NzgzNjIuMjA5MDM0fQp7Im5hbWUiOiJjaHJpcyIsImJyZWVkIjoiZ29sZGVucmV0cmlldmVyPyIsImlkIjoyLCJkb2IiOjE0ODg0NzgzNjIuMjA5MDM0fQp7Im5hbWUiOiJqaiIsImJyZWVkIjoiaWRrYW55Y2F0YnJlZWRzIiwiaWQiOjMsImRvYiI6MTQ4ODQ3ODM2Mi4yMDkwMzR9Cg==", "last_used"=>"2015-10-31 23:59:56.000000+00:00"}], "tea_time"=>"15:00:00", "next_vacation"=>"2666-06-06", "favorite_time"=>"2001-12-19 23:59:59.000000"}
    )
    mock = Minitest::Mock.new
    insert_req = Google::Apis::BigqueryV2::InsertAllTableDataRequest.new(
      rows: [inserted_row_gapi], ignore_unknown_values: nil, skip_invalid_rows: nil)
    mock.expect :insert_all_table_data, success_table_insert_gapi,
                [project, dataset_id, table_id, insert_req]
    dataset.service.mocked_service = mock

    result = nil
    SecureRandom.stub :uuid, insert_id do
      result = dataset.insert table_id, [inserting_row]
    end

    mock.verify

    result.must_be :success?
    result.insert_count.must_equal 1
    result.error_count.must_equal 0
  end

  def success_table_insert_gapi
    Google::Apis::BigqueryV2::InsertAllTableDataResponse.new(
      insert_errors: []
    )
  end

  def failure_table_insert_gapi
    Google::Apis::BigqueryV2::InsertAllTableDataResponse.new(
      insert_errors: [
        Google::Apis::BigqueryV2::InsertAllTableDataResponse::InsertError.new(
          index: 0,
          errors: [
            Google::Apis::BigqueryV2::ErrorProto.new(
              reason:     "r34s0n",
              location:   "l0c4t10n",
              debug_info: "d3bugInf0",
              message:     "m3ss4g3")
          ]
        )
      ]
    )
  end
end
