# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative "helper"
require_relative "../schemas.rb"
require_relative "../subscriptions.rb"

describe "schemas" do
  let(:pubsub) { Google::Cloud::Pubsub.new }

  describe "AVRO" do
    let(:schema_id) { random_schema_id }
    let(:avsc_file) { File.expand_path("data/us-states.avsc", __dir__) }

    it "supports pubsub_create_schema, pubsub_get_schema, pubsub_list_schemas, pubsub_delete_schema for AVRO" do
      # create_avro_schema
      assert_output "Schema projects/#{pubsub.project}/schemas/#{schema_id} created.\n" do
        create_avro_schema schema_id: schema_id, avsc_file: avsc_file
      end
      schema = pubsub.schema schema_id
      assert schema
      assert_equal "projects/#{pubsub.project}/schemas/#{schema_id}", schema.name

      # pubsub_get_schema
      assert_output "Schema projects/#{pubsub.project}/schemas/#{schema_id} retrieved.\n" do
        get_schema schema_id: schema_id
      end

      # pubsub_list_schemas
      out, _err = capture_io do
        list_schemas
      end
      assert_includes out, "Schemas in project:"
      assert_includes out, "projects/#{pubsub.project}/schemas/"

      # pubsub_delete_schema
      assert_output "Schema #{schema_id} deleted.\n" do
        delete_schema schema_id: schema_id
      end
      schema = pubsub.schema schema_id
      refute schema
    end
  end

  describe "PROTOCOL_BUFFER" do
    let(:schema_id) { random_schema_id }
    let(:proto_file) { File.expand_path("data/us-states.proto", __dir__) }

    it "supports pubsub_create_schema, pubsub_get_schema, pubsub_list_schemas, pubsub_delete_schema for protobuf" do
      # create_proto_schema
      assert_output "Schema projects/#{pubsub.project}/schemas/#{schema_id} created.\n" do
        create_proto_schema schema_id: schema_id, proto_file: proto_file
      end
      schema = pubsub.schema schema_id
      assert schema
      assert_equal "projects/#{pubsub.project}/schemas/#{schema_id}", schema.name

      # pubsub_get_schema
      assert_output "Schema projects/#{pubsub.project}/schemas/#{schema_id} retrieved.\n" do
        get_schema schema_id: schema_id
      end

      # pubsub_list_schemas
      out, _err = capture_io do
        list_schemas
      end
      assert_includes out, "Schemas in project:"
      assert_includes out, "projects/#{pubsub.project}/schemas/"

      # pubsub_delete_schema
      assert_output "Schema #{schema_id} deleted.\n" do
        delete_schema schema_id: schema_id
      end
      schema = pubsub.schema schema_id
      refute schema
    end
  end
end
