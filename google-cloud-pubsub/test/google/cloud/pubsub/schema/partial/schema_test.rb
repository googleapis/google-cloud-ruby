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

describe Google::Cloud::PubSub::Schema, :partial, :mock_pubsub do
  let(:schema_id) { "my-schema" }
  let(:type) { :AVRO }
  let(:schema_grpc) { Google::Cloud::PubSub::V1::Schema.new schema_hash(schema_id, definition: nil) }
  let(:schema) { Google::Cloud::PubSub::Schema.from_grpc schema_grpc, pubsub.service, view: :BASIC }
  let(:message_data) { { "name" => "Alaska", "post_abbr" => "AK" }.to_json }
  let(:message_data_invalid) { { "BAD_VALUE" => nil }.to_json }
  let(:message_encoding) { :JSON }

  it "knows its attributes" do
    _(schema.name).must_equal schema_path(schema_id)
    _(schema.type).must_equal type
    _(schema.definition).must_be :nil?
  end

  it "knows its view state" do
    _(schema).wont_be :reference?
    _(schema).must_be :resource?
    _(schema.resource_partial?).must_equal true
    _(schema.resource_full?).must_equal false
  end

  it "validates a message" do
    mock = Minitest::Mock.new
    res = Google::Cloud::PubSub::V1::ValidateMessageResponse.new # always empty
    mock.expect :validate_message, res, parent: project_path, name: schema_path(schema_id), schema: nil, message: message_data, encoding: message_encoding.to_s
    pubsub.service.mocked_schemas = mock

    _(schema.validate_message message_data, message_encoding).must_equal true

    mock.verify
  end

  it "validates an invalid message" do
    stub = Object.new
    def stub.validate_message *args
      raise Google::Cloud::InvalidArgumentError.new("Request contains an invalid argument.")
    end
    pubsub.service.mocked_schemas = stub

    _(schema.validate_message message_data, message_encoding).must_equal false
  end

  it "deletes itself" do
    mock = Minitest::Mock.new
    mock.expect :delete_schema, nil, name: schema_path(schema_id)
    pubsub.service.mocked_schemas = mock

    schema.delete

    mock.verify
  end

  it "reloads itself" do
    get_res = Google::Cloud::PubSub::V1::Schema.new schema_hash(schema_id, definition: nil)
    mock = Minitest::Mock.new
    mock.expect :get_schema, get_res, name: schema_path(schema_id), view: 1
    pubsub.service.mocked_schemas = mock

    schema.reload!

    _(schema).wont_be :reference?
    _(schema).must_be :resource?
    _(schema.resource_partial?).must_equal true
    _(schema.resource_full?).must_equal false

    mock.verify
  end

  it "reloads itself with view option" do
    get_res = Google::Cloud::PubSub::V1::Schema.new schema_hash(schema_id)
    mock = Minitest::Mock.new
    mock.expect :get_schema, get_res, name: schema_path(schema_id), view: 2
    pubsub.service.mocked_schemas = mock

    schema.reload! view: :full

    _(schema).wont_be :reference?
    _(schema).must_be :resource?
    _(schema).wont_be :resource_partial?
    _(schema).must_be :resource_full?

    mock.verify
  end

  it "checks if it exists without making RPC" do
    _(schema.exists?).must_equal true
  end
end
