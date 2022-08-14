# Copyright 2015 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a link of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
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
  let(:rows_without_insert_ids) { rows.map { |row| { json: row } } }

  let(:table_id) { "table_id" }
  let(:table_hash) { random_table_hash dataset_id, table_id }
  let(:table_gapi) { Google::Apis::BigqueryV2::Table.from_json table_hash.to_json }
  let(:table) { Google::Cloud::Bigquery::Table.from_gapi table_gapi, bigquery.service }

  it "raises if rows is an empty array" do
    expect { dataset.insert table_id, [] }.must_raise ArgumentError
  end

  it "can insert one row" do
    mock = Minitest::Mock.new
    insert_req = {
      rows: [insert_rows.first], ignoreUnknownValues: nil, skipInvalidRows: nil
    }.to_json
    mock.expect :insert_all_table_data, success_table_insert_gapi,
                [project, dataset_id, table_id, insert_req], options: { skip_serialization: true }
    dataset.service.mocked_service = mock

    result = nil
    SecureRandom.stub :uuid, insert_id do
      result = dataset.insert table_id, rows.first
    end

    mock.verify

    _(result).must_be :success?
    _(result.insert_count).must_equal 1
    _(result.error_count).must_equal 0
  end

  describe "dataset reference" do
    let(:dataset) {Google::Cloud::Bigquery::Dataset.new_reference project, dataset_id, bigquery.service }

    it "can insert one row" do
      mock = Minitest::Mock.new
      insert_req = {
        rows: [insert_rows.first], ignoreUnknownValues: nil, skipInvalidRows: nil
      }.to_json
      mock.expect :insert_all_table_data, success_table_insert_gapi,
                  [project, dataset_id, table_id, insert_req], options: { skip_serialization: true }
      dataset.service.mocked_service = mock

      result = nil
      SecureRandom.stub :uuid, insert_id do
        result = dataset.insert table_id, rows.first
      end

      mock.verify

      _(result).must_be :success?
      _(result.insert_count).must_equal 1
      _(result.error_count).must_equal 0
    end
  end

  it "can insert multiple rows" do
    mock = Minitest::Mock.new
    insert_req = {
      rows: insert_rows, ignoreUnknownValues: nil, skipInvalidRows: nil
    }.to_json
    mock.expect :insert_all_table_data, success_table_insert_gapi,
                [project, dataset_id, table_id, insert_req], options: { skip_serialization: true }
    dataset.service.mocked_service = mock

    result = nil
    SecureRandom.stub :uuid, insert_id do
      result = dataset.insert table_id, rows
    end

    mock.verify

    _(result).must_be :success?
    _(result.insert_count).must_equal 3
    _(result.error_count).must_equal 0
  end

  it "will indicate there was a problem with the data" do
    mock = Minitest::Mock.new
    insert_req = {
      rows: insert_rows, ignoreUnknownValues: nil, skipInvalidRows: nil
    }.to_json
    mock.expect :insert_all_table_data, failure_table_insert_gapi,
                [project, dataset_id, table_id, insert_req], options: { skip_serialization: true }
    dataset.service.mocked_service = mock

    result = nil
    SecureRandom.stub :uuid, insert_id do
      result = dataset.insert table_id, rows
    end

    mock.verify

    _(result).wont_be :success?
    _(result.insert_count).must_equal 2
    _(result.error_count).must_equal 1
    _(result.insert_errors.count).must_equal 1
    _(result.insert_errors.first.index).must_equal 0
    _(result.insert_errors.first.row).must_equal rows.first
    _(result.insert_errors.first.errors.count).must_equal 1
    _(result.insert_errors.first.errors.first["reason"]).must_equal "r34s0n"
    _(result.insert_errors.first.errors.first["location"]).must_equal "l0c4t10n"
    _(result.insert_errors.first.errors.first["debugInfo"]).must_equal "d3bugInf0"
    _(result.insert_errors.first.errors.first["message"]).must_equal "m3ss4g3"

    _(result.error_rows.first).must_equal rows.first

    first_row_insert_error = result.insert_error_for(rows.first)
    _(first_row_insert_error.index).must_equal 0
    _(first_row_insert_error.row).must_equal rows.first
    _(first_row_insert_error.errors.first["reason"]).must_equal "r34s0n"
    _(first_row_insert_error.errors.first["location"]).must_equal "l0c4t10n"
    _(first_row_insert_error.errors.first["debugInfo"]).must_equal "d3bugInf0"
    _(first_row_insert_error.errors.first["message"]).must_equal "m3ss4g3"

    first_row_index = result.index_for(rows.first)
    _(first_row_index).must_equal 0

    first_row_errors = result.errors_for(rows.first)
    _(first_row_errors.count).must_equal 1
    _(first_row_errors.first["reason"]).must_equal "r34s0n"
    _(first_row_errors.first["location"]).must_equal "l0c4t10n"
    _(first_row_errors.first["debugInfo"]).must_equal "d3bugInf0"
    _(first_row_errors.first["message"]).must_equal "m3ss4g3"

    last_row_insert_error = result.insert_error_for(rows.last)
    _(last_row_insert_error).must_be_nil

    last_row_index = result.index_for(rows.last)
    _(last_row_index).must_be_nil

    last_row_errors = result.errors_for(rows.last)
    _(last_row_errors.count).must_equal 0
  end

  it "can specify skipping invalid rows" do
    mock = Minitest::Mock.new
    insert_req = {
      rows: insert_rows, ignoreUnknownValues: nil, skipInvalidRows: true
    }.to_json
    mock.expect :insert_all_table_data, success_table_insert_gapi,
                [project, dataset_id, table_id, insert_req], options: { skip_serialization: true }
    dataset.service.mocked_service = mock

    result = nil
    SecureRandom.stub :uuid, insert_id do
      result = dataset.insert table_id, rows, skip_invalid: true
    end

    mock.verify

    _(result).must_be :success?
    _(result.insert_count).must_equal 3
    _(result.error_count).must_equal 0
  end

  it "can specify ignoring unknown values" do
    mock = Minitest::Mock.new
    insert_req = {
      rows: insert_rows, ignoreUnknownValues: true, skipInvalidRows: nil
    }.to_json
    mock.expect :insert_all_table_data, success_table_insert_gapi,
                [project, dataset_id, table_id, insert_req], options: { skip_serialization: true }
    dataset.service.mocked_service = mock

    result = nil
    SecureRandom.stub :uuid, insert_id do
      result = dataset.insert table_id, rows, ignore_unknown: true
    end

    mock.verify

    _(result).must_be :success?
    _(result.insert_count).must_equal 3
    _(result.error_count).must_equal 0
  end

  it "properly formats values when inserting" do
    string_numeric = "123456798.987654321"
    string_bignumeric = "123456798.98765432100001"
    inserting_row = {
      id: 2,
      name: "Gandalf",
      age: 1000,
      weight: 198.6,
      is_magic: true,
      scores: [100.0, BigDecimal(string_numeric), string_bignumeric], # BigDecimal BIGNUMERIC would be rounded!
      spells: [
        { name: "Skydragon",
          discovered_by: "Firebreather",
          properties: [
            { name: "Flying", power: 1.0 },
            { name: "Creature", power: BigDecimal(string_numeric) },
            { name: "Explodey", power: string_bignumeric } # BigDecimal would be rounded, use String instead!
          ],
          icon: File.open("acceptance/data/kitten-test-data.json", "rb"),
          last_used: Time.parse("2015-10-31 23:59:56 UTC")
        }
      ],
      tea_time: Google::Cloud::Bigquery::Time.new("15:00:00"),
      next_vacation: Date.parse("2666-06-06"),
      favorite_time: Time.parse("2001-12-19T23:59:59 UTC").utc.to_datetime,
      my_numeric: BigDecimal(string_numeric),
      my_bignumeric: string_bignumeric, # BigDecimal would be rounded, use String instead!
      my_rounded_bignumeric: BigDecimal(string_bignumeric)
    }
    inserted_row_hash = {
      insertId: insert_id,
      json: {
        "id"=>2,
        "name"=>"Gandalf",
        "age"=>1000,
        "weight"=>198.6,
        "is_magic"=>true,
        "scores"=>[100.0, string_numeric, string_bignumeric],
        "spells"=>[
          {
            "name"=>"Skydragon",
            "discovered_by"=>"Firebreather",
            "properties"=>[
              {
                "name"=>"Flying",
                "power"=>1.0
              },
              {
                "name"=>"Creature",
                "power"=>string_numeric
              },
              {
                "name"=>"Explodey",
                "power"=>string_bignumeric
              }
            ],
            "icon"=>Google::Cloud::Bigquery::Convert.to_json_value(File.open("acceptance/data/kitten-test-data.json", "rb")),
            "last_used"=>"2015-10-31 23:59:56.000000+00:00"
          }
        ],
        "tea_time"=>"15:00:00",
        "next_vacation"=>"2666-06-06",
        "favorite_time"=>"2001-12-19 23:59:59.000000",
        "my_numeric"=>string_numeric,
        "my_bignumeric"=>string_bignumeric,
        "my_rounded_bignumeric"=>string_numeric
      }
    }
    mock = Minitest::Mock.new
    insert_req = {
      rows: [inserted_row_hash], ignoreUnknownValues: nil, skipInvalidRows: nil
    }.to_json
    mock.expect :insert_all_table_data, success_table_insert_gapi,
                [project, dataset_id, table_id, insert_req], options: { skip_serialization: true }
    dataset.service.mocked_service = mock

    result = nil
    SecureRandom.stub :uuid, insert_id do
      result = dataset.insert table_id, [inserting_row]
    end

    mock.verify

    _(result).must_be :success?
    _(result.insert_count).must_equal 1
    _(result.error_count).must_equal 0
  end

  it "can specify insert_ids" do
    mock = Minitest::Mock.new
    insert_req = {
        rows: rows_with_user_insert_ids, ignoreUnknownValues: nil, skipInvalidRows: nil
    }.to_json
    mock.expect :insert_all_table_data, success_table_insert_gapi,
                [project, dataset_id, table_id, insert_req], options: { skip_serialization: true }
    dataset.service.mocked_service = mock

    result = dataset.insert table_id, rows, insert_ids: insert_ids

    mock.verify

    _(result).must_be :success?
    _(result.insert_count).must_equal 3
    _(result.error_count).must_equal 0
  end

  it "raises if the insert_ids option is provided but size does not match rows" do
    insert_ids.pop # Remove one of the insert_ids to cause error.

    expect { dataset.insert table_id, rows, insert_ids: insert_ids }.must_raise ArgumentError
  end

  it "can skip insert_ids" do
    mock = Minitest::Mock.new
    insert_req = {
        rows: rows_without_insert_ids, ignoreUnknownValues: nil, skipInvalidRows: nil
    }.to_json
    mock.expect :insert_all_table_data, success_table_insert_gapi,
                [project, dataset_id, table_id, insert_req], options: { skip_serialization: true }
    dataset.service.mocked_service = mock

    result = dataset.insert table_id, rows, insert_ids: :skip

    mock.verify

    _(result).must_be :success?
    _(result.insert_count).must_equal 3
    _(result.error_count).must_equal 0
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
