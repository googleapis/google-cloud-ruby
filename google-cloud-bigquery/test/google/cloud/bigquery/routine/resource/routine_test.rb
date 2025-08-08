# Copyright 2020 Google LLC
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
require "json"
require "uri"

describe Google::Cloud::Bigquery::Routine, :resource, :mock_bigquery do
  let(:dataset) { "my_dataset" }
  let(:routine_id) { "my_routine" }
  let(:etag) { "etag123456789" }
  let(:routine_type) { "SCALAR_FUNCTION" }
  let(:now) { ::Time.now }
  let(:language) { "SQL" }
  let(:return_type) { Google::Cloud::Bigquery::StandardSql::DataType.new type_kind: "INT64" }
  let(:imported_libraries) { ["gs://cloud-samples-data/bigquery/udfs/max-value.js"] }
  let(:body) { "x * 3" }
  let(:description) { "This is my routine" }
  let(:determinism_level) { "DETERMINISTIC" }
  let(:new_routine_type) { "PROCEDURE" }
  let(:new_language) { "JAVASCRIPT" }
  let(:new_arguments_gapi) do
    [
      Google::Apis::BigqueryV2::Argument.new(
        data_type: Google::Apis::BigqueryV2::StandardSqlDataType.new(type_kind: "INT64"),
        name: "x"
      ),
      Google::Apis::BigqueryV2::Argument.new(
        data_type: Google::Apis::BigqueryV2::StandardSqlDataType.new(type_kind: "STRING"),
        name: "y"
      ),
      Google::Apis::BigqueryV2::Argument.new(
        data_type: Google::Apis::BigqueryV2::StandardSqlDataType.new(type_kind: "BOOL"),
        name: "z"
      )
    ]
  end
  let(:new_arguments) do
    [
      Google::Cloud::Bigquery::Argument.new(
        data_type: Google::Cloud::Bigquery::StandardSql::DataType.new(type_kind: "INT64"),
        name: "x"
      ),
      Google::Cloud::Bigquery::Argument.new(
        data_type: Google::Cloud::Bigquery::StandardSql::DataType.new(type_kind: "STRING"),
        name: "y"
      ),
      Google::Cloud::Bigquery::Argument.new(
        data_type: Google::Cloud::Bigquery::StandardSql::DataType.new(type_kind: "BOOL"),
        name: "z"
      )
    ]
  end
  let(:new_return_type) { Google::Cloud::Bigquery::StandardSql::DataType.new type_kind: "STRING" }
  let(:new_imported_libraries) { ["gs://cloud-samples-data/bigquery/udfs/max-value-2.js"] }
  let(:new_body) { "x * 4" }
  let(:new_description) { "This is my updated routine" }
  let(:new_determinism_level) { "NOT_DETERMINISTIC" }
  let(:new_data_governance_type) { "DATA_MASKING" }
  let(:routine_hash) { random_routine_hash dataset, routine_id, determinism_level: determinism_level }
  let(:routine_gapi) { Google::Apis::BigqueryV2::Routine.from_json routine_hash.to_json }
  let(:routine) { Google::Cloud::Bigquery::Routine.from_gapi routine_gapi, bigquery.service }

  it "knows its attributes" do
    _(routine.routine_id).must_equal routine_id
    _(routine.dataset_id).must_equal dataset
    _(routine.project_id).must_equal project
    # routine_ref is private
    _(routine.routine_ref).must_be_kind_of Google::Apis::BigqueryV2::RoutineReference
    _(routine.routine_ref.routine_id).must_equal routine_id
    _(routine.routine_ref.dataset_id).must_equal dataset
    _(routine.routine_ref.project_id).must_equal project

    _(routine.etag).must_equal etag
    _(routine.routine_type).must_equal "SCALAR_FUNCTION"
    _(routine.procedure?).must_equal false
    _(routine.scalar_function?).must_equal true
    _(routine.created_at).must_be_close_to now, 1
    _(routine.modified_at).must_be_close_to now, 1
    _(routine.language).must_equal "SQL"
    _(routine.javascript?).must_equal false
    _(routine.sql?).must_equal true

    _(routine.arguments).must_be_kind_of Array
    _(routine.arguments).must_be :frozen?
    _(routine.arguments.size).must_equal 2
    _(routine.arguments[0]).must_be_kind_of Google::Cloud::Bigquery::Argument
    _(routine.arguments[0].name).must_equal "arr"
    _(routine.arguments[0].argument_kind).must_equal "FIXED_TYPE"
    _(routine.arguments[0].fixed_type?).must_equal true
    _(routine.arguments[0].any_type?).must_equal false
    _(routine.arguments[0].mode).must_equal "IN"
    _(routine.arguments[0].in?).must_equal true
    _(routine.arguments[0].out?).must_equal false
    _(routine.arguments[0].inout?).must_equal false
    _(routine.arguments[0].data_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(routine.arguments[0].data_type.type_kind).must_equal "ARRAY"
    _(routine.arguments[0].data_type.array_element_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(routine.arguments[0].data_type.array_element_type.type_kind).must_equal "STRUCT"
    _(routine.arguments[0].data_type.array_element_type.struct_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::StructType
    _(routine.arguments[0].data_type.array_element_type.struct_type.fields).must_be_kind_of Array
    _(routine.arguments[0].data_type.array_element_type.struct_type.fields).must_be :frozen?
    _(routine.arguments[0].data_type.array_element_type.struct_type.fields.size).must_equal 2
    _(routine.arguments[0].data_type.array_element_type.struct_type.fields[0]).must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    _(routine.arguments[0].data_type.array_element_type.struct_type.fields[0].name).must_equal "my-struct-name"
    _(routine.arguments[0].data_type.array_element_type.struct_type.fields[0].type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(routine.arguments[0].data_type.array_element_type.struct_type.fields[0].type.type_kind).must_equal "STRING"
    _(routine.arguments[0].data_type.array_element_type.struct_type.fields[1].name).must_equal "my-struct-val"
    _(routine.arguments[0].data_type.array_element_type.struct_type.fields[1].type.type_kind).must_equal "INT64"
    _(routine.arguments[1].name).must_equal "out"
    _(routine.arguments[1].argument_kind).must_equal "ANY_TYPE"
    _(routine.arguments[1].fixed_type?).must_equal false
    _(routine.arguments[1].any_type?).must_equal true
    _(routine.arguments[1].mode).must_equal "OUT"
    _(routine.arguments[1].in?).must_equal false
    _(routine.arguments[1].out?).must_equal true
    _(routine.arguments[1].inout?).must_equal false
    _(routine.arguments[1].data_type.type_kind).must_equal "STRING"

    _(routine.return_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(routine.return_type.type_kind).must_equal "INT64"

    _(routine.imported_libraries).must_equal ["gs://cloud-samples-data/bigquery/udfs/max-value.js"]
    _(routine.imported_libraries).must_be :frozen?
    _(routine.body).must_equal "x * 3"
    _(routine.description).must_equal description
    _(routine.determinism_level).must_equal determinism_level
    _(routine.determinism_level_deterministic?).must_equal true
    _(routine.determinism_level_not_deterministic?).must_equal false
    _(routine.data_governance_type).must_be_nil
  end

  it "can test its existence" do
    _(routine.exists?).must_equal true
  end

  it "can test its existence with force to load resource" do
    mock = Minitest::Mock.new
    mock.expect :get_routine, routine_gapi, [routine.project_id, routine.dataset_id, routine.routine_id]
    routine.service.mocked_service = mock

    _(routine.exists?(force: true)).must_equal true

    mock.verify
  end

  it "can delete itself" do
    mock = Minitest::Mock.new
    mock.expect :delete_routine, nil, [project, dataset, routine_id]
    routine.service.mocked_service = mock

    _(routine.delete).must_equal true

    _(routine.exists?).must_equal false

    mock.verify
  end

  it "can reload itself" do
    new_description = "New description of the routine."

    mock = Minitest::Mock.new
    routine_hash = random_routine_hash dataset, routine_id, description: new_description
    mock.expect :get_routine, Google::Apis::BigqueryV2::Routine.from_json(routine_hash.to_json),
      [project, dataset, routine_id]
    routine.service.mocked_service = mock

    _(routine.description).must_equal description
    routine.reload!

    mock.verify

    _(routine.description).must_equal new_description
  end

  it "updates its routine_type" do
    _(routine.routine_type).must_equal routine_type

    mock = Minitest::Mock.new
    updated_routine_gapi = routine_gapi.dup
    updated_routine_gapi.routine_type = new_routine_type
    mock.expect :update_routine, updated_routine_gapi,
      [project, dataset, routine_id, updated_routine_gapi], options: { header: { "If-Match" => etag } }
    routine.service.mocked_service = mock

    routine.routine_type = new_routine_type

    mock.verify

    _(routine.routine_type).must_equal new_routine_type
  end

  it "updates its language" do
    _(routine.language).must_equal language

    mock = Minitest::Mock.new
    updated_routine_gapi = routine_gapi.dup
    updated_routine_gapi.language = new_language
    mock.expect :update_routine, updated_routine_gapi,
      [project, dataset, routine_id, updated_routine_gapi], options: { header: { "If-Match" => etag } }
    routine.service.mocked_service = mock

    routine.language = new_language

    mock.verify

    _(routine.language).must_equal new_language
  end

  it "updates its arguments" do
    _(routine.arguments.size).must_equal routine_gapi.arguments.size

    mock = Minitest::Mock.new
    updated_routine_gapi = routine_gapi.dup
    updated_routine_gapi.arguments = new_arguments_gapi
    mock.expect :update_routine, updated_routine_gapi,
      [project, dataset, routine_id, updated_routine_gapi], options: { header: { "If-Match" => etag } }
    routine.service.mocked_service = mock

    routine.arguments = new_arguments

    mock.verify

    _(routine.arguments.size).must_equal new_arguments.size
  end

  it "updates its return_type" do
    _(routine.return_type.type_kind).must_equal return_type.type_kind

    mock = Minitest::Mock.new
    updated_routine_gapi = routine_gapi.dup
    updated_routine_gapi.return_type = Google::Apis::BigqueryV2::StandardSqlDataType.new type_kind: "STRING"
    mock.expect :update_routine, updated_routine_gapi,
      [project, dataset, routine_id, updated_routine_gapi], options: { header: { "If-Match" => etag } }
    routine.service.mocked_service = mock

    routine.return_type = new_return_type

    mock.verify

    _(routine.return_type.type_kind).must_equal new_return_type.type_kind
  end

  it "updates its return_type with a string" do
    _(routine.return_type.type_kind).must_equal return_type.type_kind

    mock = Minitest::Mock.new
    updated_routine_gapi = routine_gapi.dup
    updated_routine_gapi.return_type = Google::Apis::BigqueryV2::StandardSqlDataType.new type_kind: "STRING"
    mock.expect :update_routine, updated_routine_gapi,
      [project, dataset, routine_id, updated_routine_gapi], options: { header: { "If-Match" => etag } }
    routine.service.mocked_service = mock

    routine.return_type = "STRING"

    mock.verify

    _(routine.return_type.type_kind).must_equal new_return_type.type_kind
  end

  it "updates its return_type to nil" do
    _(routine.return_type.type_kind).must_equal return_type.type_kind

    mock = Minitest::Mock.new
    updated_routine_gapi = routine_gapi.dup
    updated_routine_gapi.return_type = nil
    mock.expect :update_routine, updated_routine_gapi,
      [project, dataset, routine_id, updated_routine_gapi], options: { header: { "If-Match" => etag } }
    routine.service.mocked_service = mock

    routine.return_type = nil

    mock.verify

    _(routine.return_type).must_be :nil?
  end
  
  it "updates its imported_libraries" do
    _(routine.imported_libraries).must_equal imported_libraries

    mock = Minitest::Mock.new
    updated_routine_gapi = routine_gapi.dup
    updated_routine_gapi.imported_libraries = new_imported_libraries
    mock.expect :update_routine, updated_routine_gapi,
      [project, dataset, routine_id, updated_routine_gapi], options: { header: { "If-Match" => etag } }
    routine.service.mocked_service = mock

    routine.imported_libraries = new_imported_libraries

    mock.verify

    _(routine.imported_libraries).must_equal new_imported_libraries
  end
  
  it "updates its body" do
    _(routine.body).must_equal body

    mock = Minitest::Mock.new
    updated_routine_gapi = routine_gapi.dup
    updated_routine_gapi.definition_body = new_body
    mock.expect :update_routine, updated_routine_gapi,
      [project, dataset, routine_id, updated_routine_gapi], options: { header: { "If-Match" => etag } }
    routine.service.mocked_service = mock

    routine.body = new_body

    mock.verify

    _(routine.body).must_equal new_body
  end

  it "updates its description" do
    _(routine.description).must_equal description

    mock = Minitest::Mock.new
    updated_routine_gapi = routine_gapi.dup
    updated_routine_gapi.description = new_description
    mock.expect :update_routine, updated_routine_gapi,
      [project, dataset, routine_id, updated_routine_gapi], options: { header: { "If-Match" => etag } }
    routine.service.mocked_service = mock

    routine.description = new_description

    mock.verify

    _(routine.description).must_equal new_description
  end

  it "updates its determinism_level" do
    _(routine.determinism_level).must_equal determinism_level
    _(routine.determinism_level_deterministic?).must_equal true
    _(routine.determinism_level_not_deterministic?).must_equal false

    mock = Minitest::Mock.new
    updated_routine_gapi = routine_gapi.dup
    updated_routine_gapi.determinism_level = new_determinism_level
    mock.expect :update_routine, updated_routine_gapi,
      [project, dataset, routine_id, updated_routine_gapi], options: { header: { "If-Match" => etag } }
    routine.service.mocked_service = mock

    routine.determinism_level = new_determinism_level

    mock.verify

    _(routine.determinism_level).must_equal new_determinism_level
    _(routine.determinism_level_deterministic?).must_equal false
    _(routine.determinism_level_not_deterministic?).must_equal true
  end

  it "updates its data_governance_type" do
    _(routine.data_governance_type).must_be_nil
    mock = Minitest::Mock.new
    updated_routine_gapi = routine_gapi.dup
    updated_routine_gapi.data_governance_type = new_data_governance_type
    mock.expect :update_routine, updated_routine_gapi,
      [project, dataset, routine_id, updated_routine_gapi], options: { header: { "If-Match" => etag } }
    routine.service.mocked_service = mock

    routine.data_governance_type = new_data_governance_type

    mock.verify

    _(routine.data_governance_type).must_equal new_data_governance_type
  end


  it "updates its attributes in a block" do
    _(routine.description).must_equal description
    _(routine.determinism_level).must_equal determinism_level
    _(routine.determinism_level_deterministic?).must_equal true
    _(routine.determinism_level_not_deterministic?).must_equal false

    mock = Minitest::Mock.new
    updated_routine_gapi = routine_gapi.dup
    updated_routine_gapi.routine_type = new_routine_type
    updated_routine_gapi.language = new_language
    updated_routine_gapi.arguments = new_arguments_gapi
    updated_routine_gapi.return_type = Google::Apis::BigqueryV2::StandardSqlDataType.new type_kind: "STRING"
    updated_routine_gapi.imported_libraries = new_imported_libraries
    updated_routine_gapi.definition_body = new_body
    updated_routine_gapi.description = new_description
    updated_routine_gapi.determinism_level = new_determinism_level
    updated_routine_gapi.data_governance_type = new_data_governance_type
    mock.expect :update_routine, updated_routine_gapi,
      [project, dataset, routine_id, updated_routine_gapi], options: { header: { "If-Match" => etag } }
    routine.service.mocked_service = mock

    routine.update do |r|
      r.routine_type = new_routine_type
      r.language = new_language
      r.arguments = new_arguments
      r.return_type = new_return_type
      r.imported_libraries = new_imported_libraries
      r.body = new_body
      r.description = new_description
      r.determinism_level = new_determinism_level
      r.data_governance_type = new_data_governance_type
    end

    mock.verify

    _(routine.routine_type).must_equal new_routine_type
    _(routine.language).must_equal new_language
    _(routine.arguments.size).must_equal new_arguments.size
    _(routine.return_type.type_kind).must_equal new_return_type.type_kind
    _(routine.imported_libraries).must_equal new_imported_libraries
    _(routine.body).must_equal new_body
    _(routine.description).must_equal new_description
    _(routine.determinism_level).must_equal new_determinism_level
    _(routine.determinism_level_deterministic?).must_equal false
    _(routine.determinism_level_not_deterministic?).must_equal true
    _(routine.data_governance_type).must_equal new_data_governance_type
  end

  it "skips update when no updates are made in a block" do
    routine.update do |r|
    end
  end

  it "raises from unsupported methods called on the updater" do
    routine.update do |r|
      expect { r.update }.must_raise RuntimeError
      expect { r.delete }.must_raise RuntimeError
      expect { r.reload! }.must_raise RuntimeError
      expect { r.refresh! }.must_raise RuntimeError
    end
  end
end
