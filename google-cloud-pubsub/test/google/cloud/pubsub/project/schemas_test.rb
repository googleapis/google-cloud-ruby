# Copyright 2021 Google LLC
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

describe Google::Cloud::PubSub::Project, :schemas, :mock_pubsub do
  let(:schemas_with_token) do
    response = Google::Cloud::PubSub::V1::ListSchemasResponse.new schemas_hash(3, "next_page_token")
    paged_enum_struct response
  end
  let(:schemas_without_token) do
    response = Google::Cloud::PubSub::V1::ListSchemasResponse.new schemas_hash(2)
    paged_enum_struct response
  end
  let(:schemas_with_token_2) do
    response = Google::Cloud::PubSub::V1::ListSchemasResponse.new schemas_hash(3, "second_page_token")
    paged_enum_struct response
  end
  let(:type) { "AVRO" }
  let(:definition) { "AVRO schema definition" }
focus
  it "creates a schema" do
    new_schema_name = "new-schema-#{Time.now.to_i}"

    create_req = Google::Cloud::PubSub::V1::Schema.new type: type, definition: definition
    create_res = Google::Cloud::PubSub::V1::Schema.new schema_hash(new_schema_name)
    mock = Minitest::Mock.new
    mock.expect :create_schema, create_res, [parent: project_path, schema: create_req, schema_id: new_schema_name]
    pubsub.service.mocked_schemas = mock

    schema = pubsub.create_schema new_schema_name, type, definition

    mock.verify

    _(schema.name).must_equal schema_path(new_schema_name)
    _(schema.type).must_equal type
    _(schema.definition).must_equal definition
  end

  it "creates a schema with fully-qualified schema path" do
    new_schema_path = "projects/other-project/schemas/new-schema-#{Time.now.to_i}"

    create_res = Google::Cloud::PubSub::V1::Schema.new schema_hash(new_schema_path)
    mock = Minitest::Mock.new
    mock.expect :create_schema, create_res, [name: new_schema_path, labels: nil, kms_key_name: nil, message_storage_policy: nil]
    pubsub.service.mocked_schemas = mock

    schema = pubsub.create_schema new_schema_path, type, definition

    mock.verify

    _(schema.name).must_equal new_schema_path
  end

  it "creates a schema with new_schema_alias" do
    new_schema_name = "new-schema-#{Time.now.to_i}"

    create_res = Google::Cloud::PubSub::V1::Schema.new schema_hash(new_schema_name)
    mock = Minitest::Mock.new
    mock.expect :create_schema, create_res, [name: schema_path(new_schema_name), labels: nil, kms_key_name: nil, message_storage_policy: nil]
    pubsub.service.mocked_schemas = mock

    schema = pubsub.new_schema new_schema_name, type, definition

    mock.verify

    _(schema.name).must_equal schema_path(new_schema_name)
    _(schema.type).must_equal type
    _(schema.definition).must_equal definition
  end

  it "gets a schema" do
    schema_name = "found-schema"

    get_res = Google::Cloud::PubSub::V1::Schema.new schema_hash(schema_name)
    mock = Minitest::Mock.new
    mock.expect :get_schema, get_res, [name: schema_path(schema_name), view: 1]
    pubsub.service.mocked_schemas = mock

    schema = pubsub.schema schema_name

    mock.verify

    _(schema.name).must_equal schema_path(schema_name)
    _(schema).wont_be :reference?
    _(schema).must_be :resource?
  end

  it "gets a schema with fully-qualified schema path" do
    schema_full_path = "projects/other-project/schemas/found-schema"

    get_res = Google::Cloud::PubSub::V1::Schema.new schema_hash(schema_full_path)
    mock = Minitest::Mock.new
    mock.expect :get_schema, get_res, [name: schema_path(schema_full_path), view: 1]
    pubsub.service.mocked_schemas = mock

    schema = pubsub.schema schema_full_path

    mock.verify

    _(schema.name).must_equal schema_full_path
  end

  it "gets a schema with get_schema alias" do
    schema_name = "found-schema"

    get_res = Google::Cloud::PubSub::V1::Schema.new schema_hash(schema_name)
    mock = Minitest::Mock.new
    mock.expect :get_schema, get_res, [name: schema_path(schema_name), view: 1]
    pubsub.service.mocked_schemas = mock

    schema = pubsub.get_schema schema_name

    mock.verify

    _(schema.name).must_equal schema_path(schema_name)
    _(schema).wont_be :reference?
    _(schema).must_be :resource?
  end

  it "gets a schema with find_schema alias" do
    schema_name = "found-schema"

    get_res = Google::Cloud::PubSub::V1::Schema.new schema_hash(schema_name)
    mock = Minitest::Mock.new
    mock.expect :get_schema, get_res, [name: schema_path(schema_name), view: 1]
    pubsub.service.mocked_schemas = mock

    schema = pubsub.find_schema schema_name

    mock.verify

    _(schema.name).must_equal schema_path(schema_name)
    _(schema).wont_be :reference?
    _(schema).must_be :resource?
  end

  it "returns nil when getting an non-existent schema" do
    not_found_schema_name = "not-found-schema"

    stub = Object.new
    def stub.get_schema *args
      raise Google::Cloud::NotFoundError.new("not found")
    end
    pubsub.service.mocked_schemas = stub

    schema = pubsub.find_schema not_found_schema_name
    _(schema).must_be :nil?
  end

  it "gets a schema with skip_lookup option" do
    schema_name = "found-schema"
    # No HTTP mock needed, since the lookup is not made

    schema = pubsub.find_schema schema_name, skip_lookup: true
    _(schema.name).must_equal schema_path(schema_name)
    _(schema).must_be :reference?
    _(schema).wont_be :resource?
  end

  it "lists schemas" do
    mock = Minitest::Mock.new
    mock.expect :list_schemas, schemas_with_token, [parent: "projects/#{project}", view: 1, page_size: nil, page_token: nil]
    pubsub.service.mocked_schemas = mock

    schemas = pubsub.schemas

    mock.verify

    _(schemas.size).must_equal 3
  end

  it "lists schemas with find_schemas alias" do
    mock = Minitest::Mock.new
    mock.expect :list_schemas, schemas_with_token, [parent: "projects/#{project}", view: 1, page_size: nil, page_token: nil]
    pubsub.service.mocked_schemas = mock

    schemas = pubsub.find_schemas

    mock.verify

    _(schemas.size).must_equal 3
  end

  it "lists schemas with list_schemas alias" do
    mock = Minitest::Mock.new
    mock.expect :list_schemas, schemas_with_token, [parent: "projects/#{project}", view: 1, page_size: nil, page_token: nil]
    pubsub.service.mocked_schemas = mock

    schemas = pubsub.list_schemas

    mock.verify

    _(schemas.size).must_equal 3
  end

  it "paginates schemas" do
    mock = Minitest::Mock.new
    mock.expect :list_schemas, schemas_with_token, [parent: "projects/#{project}", view: 1, page_size: nil, page_token: nil]
    mock.expect :list_schemas, schemas_without_token, [parent: "projects/#{project}", view: 1, page_size: nil, page_token: "next_page_token"]
    pubsub.service.mocked_schemas = mock

    first_schemas = pubsub.schemas
    second_schemas = pubsub.schemas token: first_schemas.token

    mock.verify

    _(first_schemas.size).must_equal 3
    token = first_schemas.token
    _(token).wont_be :nil?
    _(token).must_equal "next_page_token"

    _(second_schemas.size).must_equal 2
    _(second_schemas.token).must_be :nil?
  end

  it "paginates schemas with max set" do
    mock = Minitest::Mock.new
    mock.expect :list_schemas, schemas_with_token, [parent: "projects/#{project}", view: 1, page_size: 3, page_token: nil]
    pubsub.service.mocked_schemas = mock

    schemas = pubsub.schemas max: 3

    mock.verify

    _(schemas.size).must_equal 3
    token = schemas.token
    _(token).wont_be :nil?
    _(token).must_equal "next_page_token"
  end

  it "paginates schemas with next? and next" do
    mock = Minitest::Mock.new
    mock.expect :list_schemas, schemas_with_token, [parent: "projects/#{project}", view: 1, page_size: nil, page_token: nil]
    mock.expect :list_schemas, schemas_without_token, [parent: "projects/#{project}", view: 1, page_size: nil, page_token: "next_page_token"]
    pubsub.service.mocked_schemas = mock

    first_schemas = pubsub.schemas
    second_schemas = first_schemas.next

    mock.verify

    _(first_schemas.size).must_equal 3
    _(first_schemas.next?).must_equal true

    _(second_schemas.size).must_equal 2
    _(second_schemas.next?).must_equal false
  end

  it "paginates schemas with next? and next and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_schemas, schemas_with_token, [parent: "projects/#{project}", view: 1, page_size: 3, page_token: nil]
    mock.expect :list_schemas, schemas_without_token, [parent: "projects/#{project}", view: 1, page_size: 3, page_token: "next_page_token"]
    pubsub.service.mocked_schemas = mock

    first_schemas = pubsub.schemas max: 3
    second_schemas = first_schemas.next

    mock.verify

    _(first_schemas.size).must_equal 3
    _(first_schemas.next?).must_equal true

    _(second_schemas.size).must_equal 2
    _(second_schemas.next?).must_equal false
  end

  it "paginates schemas with all" do
    mock = Minitest::Mock.new
    mock.expect :list_schemas, schemas_with_token, [parent: "projects/#{project}", view: 1, page_size: nil, page_token: nil]
    mock.expect :list_schemas, schemas_without_token, [parent: "projects/#{project}", view: 1, page_size: nil, page_token: "next_page_token"]
    pubsub.service.mocked_schemas = mock

    schemas = pubsub.schemas.all.to_a

    mock.verify

    _(schemas.size).must_equal 5
  end

  it "paginates schemas with all and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_schemas, schemas_with_token, [parent: "projects/#{project}", view: 1, page_size: 3, page_token: nil]
    mock.expect :list_schemas, schemas_without_token, [parent: "projects/#{project}", view: 1, page_size: 3, page_token: "next_page_token"]
    pubsub.service.mocked_schemas = mock

    schemas = pubsub.schemas(max: 3).all.to_a

    mock.verify

    _(schemas.size).must_equal 5
  end

  it "iterates schemas with all using Enumerator" do
    mock = Minitest::Mock.new
    mock.expect :list_schemas, schemas_with_token, [parent: "projects/#{project}", view: 1, page_size: nil, page_token: nil]
    mock.expect :list_schemas, schemas_with_token_2, [parent: "projects/#{project}", view: 1, page_size: nil, page_token: "next_page_token"]
    pubsub.service.mocked_schemas = mock

    schemas = pubsub.schemas.all.take(5)

    mock.verify

    _(schemas.size).must_equal 5
  end

  it "iterates schemas with all and request_limit set" do
    mock = Minitest::Mock.new
    mock.expect :list_schemas, schemas_with_token, [parent: "projects/#{project}", view: 1, page_size: nil, page_token: nil]
    mock.expect :list_schemas, schemas_with_token_2, [parent: "projects/#{project}", view: 1, page_size: nil, page_token: "next_page_token"]
    pubsub.service.mocked_schemas = mock

    schemas = pubsub.schemas.all(request_limit: 1).to_a

    mock.verify

    _(schemas.size).must_equal 6
  end

  it "paginates schemas without max set" do
    mock = Minitest::Mock.new
    mock.expect :list_schemas, schemas_with_token, [parent: "projects/#{project}", view: 1, page_size: nil, page_token: nil]
    pubsub.service.mocked_schemas = mock

    schemas = pubsub.schemas

    mock.verify

    _(schemas.size).must_equal 3
    token = schemas.token
    _(token).wont_be :nil?
    _(token).must_equal "next_page_token"
  end
end
