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
  let(:routine_hash) { random_routine_hash dataset, routine_id }
  let(:routine_gapi) { Google::Apis::BigqueryV2::Routine.from_json routine_hash.to_json }
  let(:routine) { Google::Cloud::Bigquery::Routine.from_gapi routine_gapi, bigquery.service }

  it "knows its attributes" do
    routine.routine_id.must_equal routine_id
    routine.dataset_id.must_equal dataset
    routine.project_id.must_equal project
    # routine_ref is private
    routine.routine_ref.must_be_kind_of Google::Apis::BigqueryV2::RoutineReference
    routine.routine_ref.routine_id.must_equal routine_id
    routine.routine_ref.dataset_id.must_equal dataset
    routine.routine_ref.project_id.must_equal project

    routine.etag.must_equal etag
    routine.routine_type.must_equal "SCALAR_FUNCTION"
    routine.procedure?.must_equal false
    routine.scalar_function?.must_equal true
    routine.created_at.must_be_close_to now, 1
    routine.modified_at.must_be_close_to now, 1
    routine.language.must_equal "SQL"
    routine.javascript?.must_equal false
    routine.sql?.must_equal true

    routine.arguments.must_be_kind_of Array
    routine.arguments.must_be :frozen?
    routine.arguments.size.must_equal 2
    routine.arguments[0].must_be_kind_of Google::Cloud::Bigquery::Argument
    routine.arguments[0].name.must_equal "arr"
    routine.arguments[0].argument_kind.must_equal "FIXED_TYPE"
    routine.arguments[0].mode.must_equal "IN"
    routine.arguments[0].data_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    routine.arguments[0].data_type.type_kind.must_equal "ARRAY"
    routine.arguments[0].data_type.array_element_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    routine.arguments[0].data_type.array_element_type.type_kind.must_equal "STRUCT"
    routine.arguments[0].data_type.array_element_type.struct_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::StructType
    routine.arguments[0].data_type.array_element_type.struct_type.fields.must_be_kind_of Array
    routine.arguments[0].data_type.array_element_type.struct_type.fields.must_be :frozen?
    routine.arguments[0].data_type.array_element_type.struct_type.fields.size.must_equal 2
    routine.arguments[0].data_type.array_element_type.struct_type.fields[0].must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    routine.arguments[0].data_type.array_element_type.struct_type.fields[0].name.must_equal "my-struct-name"
    routine.arguments[0].data_type.array_element_type.struct_type.fields[0].type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    routine.arguments[0].data_type.array_element_type.struct_type.fields[0].type.type_kind.must_equal "STRING"
    routine.arguments[0].data_type.array_element_type.struct_type.fields[1].name.must_equal "my-struct-val"
    routine.arguments[0].data_type.array_element_type.struct_type.fields[1].type.type_kind.must_equal "INT64"
    routine.arguments[1].name.must_equal "out"
    routine.arguments[1].argument_kind.must_equal "ANY_TYPE"
    routine.arguments[1].mode.must_equal "OUT"
    routine.arguments[1].data_type.type_kind.must_equal "STRING"

    routine.return_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    routine.return_type.type_kind.must_equal "INT64"

    routine.imported_libraries.must_equal ["gs://cloud-samples-data/bigquery/udfs/max-value.js"]
    routine.imported_libraries.must_be :frozen?
    routine.body.must_equal "x * 3"
    routine.description.must_equal description
  end

  it "can test its existence" do
    routine.exists?.must_equal true
  end

  it "can test its existence with force to load resource" do
    mock = Minitest::Mock.new
    mock.expect :get_routine, routine_gapi, [routine.project_id, routine.dataset_id, routine.routine_id]
    routine.service.mocked_service = mock

    routine.exists?(force: true).must_equal true

    mock.verify
  end

  it "can delete itself" do
    mock = Minitest::Mock.new
    mock.expect :delete_routine, nil, [project, dataset, routine_id]
    routine.service.mocked_service = mock

    routine.delete.must_equal true

    routine.exists?.must_equal false

    mock.verify
  end

  it "can reload itself" do
    new_description = "New description of the routine."

    mock = Minitest::Mock.new
    routine_hash = random_routine_hash dataset, routine_id, description: new_description
    mock.expect :get_routine, Google::Apis::BigqueryV2::Routine.from_json(routine_hash.to_json),
      [project, dataset, routine_id]
    routine.service.mocked_service = mock

    routine.description.must_equal description
    routine.reload!

    mock.verify

    routine.description.must_equal new_description
  end

  it "updates its routine_type" do
    routine.routine_type.must_equal routine_type

    mock = Minitest::Mock.new
    updated_routine_gapi = routine_gapi.dup
    updated_routine_gapi.routine_type = new_routine_type
    mock.expect :update_routine, updated_routine_gapi,
      [project, dataset, routine_id, updated_routine_gapi, options: { header: { "If-Match" => etag } }]
    routine.service.mocked_service = mock

    routine.routine_type = new_routine_type

    mock.verify

    routine.routine_type.must_equal new_routine_type
  end

  it "updates its language" do
    routine.language.must_equal language

    mock = Minitest::Mock.new
    updated_routine_gapi = routine_gapi.dup
    updated_routine_gapi.language = new_language
    mock.expect :update_routine, updated_routine_gapi,
      [project, dataset, routine_id, updated_routine_gapi, options: { header: { "If-Match" => etag } }]
    routine.service.mocked_service = mock

    routine.language = new_language

    mock.verify

    routine.language.must_equal new_language
  end

  it "updates its arguments" do
    routine.arguments.size.must_equal routine_gapi.arguments.size

    mock = Minitest::Mock.new
    updated_routine_gapi = routine_gapi.dup
    updated_routine_gapi.arguments = new_arguments_gapi
    mock.expect :update_routine, updated_routine_gapi,
      [project, dataset, routine_id, updated_routine_gapi, options: { header: { "If-Match" => etag } }]
    routine.service.mocked_service = mock

    routine.arguments = new_arguments

    mock.verify

    routine.arguments.size.must_equal new_arguments.size
  end

  it "updates its return_type" do
    routine.return_type.type_kind.must_equal return_type.type_kind

    mock = Minitest::Mock.new
    updated_routine_gapi = routine_gapi.dup
    updated_routine_gapi.return_type = Google::Apis::BigqueryV2::StandardSqlDataType.new type_kind: "STRING"
    mock.expect :update_routine, updated_routine_gapi,
      [project, dataset, routine_id, updated_routine_gapi, options: { header: { "If-Match" => etag } }]
    routine.service.mocked_service = mock

    routine.return_type = new_return_type

    mock.verify

    routine.return_type.type_kind.must_equal new_return_type.type_kind
  end

  it "updates its return_type with a string" do
    routine.return_type.type_kind.must_equal return_type.type_kind

    mock = Minitest::Mock.new
    updated_routine_gapi = routine_gapi.dup
    updated_routine_gapi.return_type = Google::Apis::BigqueryV2::StandardSqlDataType.new type_kind: "STRING"
    mock.expect :update_routine, updated_routine_gapi,
      [project, dataset, routine_id, updated_routine_gapi, options: { header: { "If-Match" => etag } }]
    routine.service.mocked_service = mock

    routine.return_type = "STRING"

    mock.verify

    routine.return_type.type_kind.must_equal new_return_type.type_kind
  end

  it "updates its return_type to nil" do
    routine.return_type.type_kind.must_equal return_type.type_kind

    mock = Minitest::Mock.new
    updated_routine_gapi = routine_gapi.dup
    updated_routine_gapi.return_type = nil
    mock.expect :update_routine, updated_routine_gapi,
      [project, dataset, routine_id, updated_routine_gapi, options: { header: { "If-Match" => etag } }]
    routine.service.mocked_service = mock

    routine.return_type = nil

    mock.verify

    routine.return_type.must_be :nil?
  end
  
  it "updates its imported_libraries" do
    routine.imported_libraries.must_equal imported_libraries

    mock = Minitest::Mock.new
    updated_routine_gapi = routine_gapi.dup
    updated_routine_gapi.imported_libraries = new_imported_libraries
    mock.expect :update_routine, updated_routine_gapi,
      [project, dataset, routine_id, updated_routine_gapi, options: { header: { "If-Match" => etag } }]
    routine.service.mocked_service = mock

    routine.imported_libraries = new_imported_libraries

    mock.verify

    routine.imported_libraries.must_equal new_imported_libraries
  end
  
  it "updates its body" do
    routine.body.must_equal body

    mock = Minitest::Mock.new
    updated_routine_gapi = routine_gapi.dup
    updated_routine_gapi.definition_body = new_body
    mock.expect :update_routine, updated_routine_gapi,
      [project, dataset, routine_id, updated_routine_gapi, options: { header: { "If-Match" => etag } }]
    routine.service.mocked_service = mock

    routine.body = new_body

    mock.verify

    routine.body.must_equal new_body
  end

  it "updates its description" do
    routine.description.must_equal description

    mock = Minitest::Mock.new
    updated_routine_gapi = routine_gapi.dup
    updated_routine_gapi.description = new_description
    mock.expect :update_routine, updated_routine_gapi,
      [project, dataset, routine_id, updated_routine_gapi, options: { header: { "If-Match" => etag } }]
    routine.service.mocked_service = mock

    routine.description = new_description

    mock.verify

    routine.description.must_equal new_description
  end

  it "updates its attributes in a block" do
    routine.description.must_equal description

    mock = Minitest::Mock.new
    updated_routine_gapi = routine_gapi.dup
    updated_routine_gapi.routine_type = new_routine_type
    updated_routine_gapi.language = new_language
    updated_routine_gapi.arguments = new_arguments_gapi
    updated_routine_gapi.return_type = Google::Apis::BigqueryV2::StandardSqlDataType.new type_kind: "STRING"
    updated_routine_gapi.imported_libraries = new_imported_libraries
    updated_routine_gapi.definition_body = new_body
    updated_routine_gapi.description = new_description
    mock.expect :update_routine, updated_routine_gapi,
      [project, dataset, routine_id, updated_routine_gapi, options: { header: { "If-Match" => etag } }]
    routine.service.mocked_service = mock

    routine.update do |r|
      r.routine_type = new_routine_type
      r.language = new_language
      r.arguments = new_arguments
      r.return_type = new_return_type
      r.imported_libraries = new_imported_libraries
      r.body = new_body
      r.description = new_description
    end

    mock.verify

    routine.routine_type.must_equal new_routine_type
    routine.language.must_equal new_language
    routine.arguments.size.must_equal new_arguments.size
    routine.return_type.type_kind.must_equal new_return_type.type_kind
    routine.imported_libraries.must_equal new_imported_libraries
    routine.body.must_equal new_body
    routine.description.must_equal new_description
  end

  it "skips update when no updates are made in a block" do
    routine.update do |r|
    end
  end
end
