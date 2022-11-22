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
  let(:schema_id) { random_schema_id }
  let(:topic_id) { random_topic_id }
  let(:subscription_id) { random_subscription_id }
  let(:avsc_file) { File.expand_path("data/us-states.avsc", __dir__) }

  after do
    @subscription.delete if @subscription
    @topic.delete if @topic
    @schema.delete if @schema
  end

  it "supports pubsub_create_schema, pubsub_get_schema, pubsub_list_schemas, pubsub_delete_schema" do
    # create_avro_schema
    assert_output "Schema projects/#{pubsub.project}/schemas/#{schema_id} created.\n" do
      create_avro_schema schema_id: schema_id, avsc_file: avsc_file
    end
    @schema = pubsub.schema schema_id
    assert @schema
    assert_equal "projects/#{pubsub.project}/schemas/#{schema_id}", @schema.name

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
      @schema = nil
    end
  end

  describe "AVRO" do
    require "avro"
    let(:avsc_definition) { File.read avsc_file }
    let(:avro_schema) { Avro::Schema.parse avsc_definition }
    let(:record) { { "name" => "Alaska", "post_abbr" => "AK" } }

    it "supports pubsub_create_topic_with_schema, pubsub_publish_avro_records with binary encoding" do
      @schema = pubsub.create_schema schema_id, :avro, avsc_definition

      # pubsub_create_topic_with_schema
      assert_output "Topic projects/#{pubsub.project}/topics/#{topic_id} created.\n" do
        create_topic_with_schema topic_id: topic_id, schema_id: schema_id, message_encoding: :binary
      end
      @topic = pubsub.topic topic_id
      assert @topic
      assert_equal "projects/#{pubsub.project}/topics/#{topic_id}", @topic.name

      # pubsub_publish_avro_records
      assert_output "Published binary-encoded AVRO message.\n" do
        publish_avro_records topic_id: topic_id, avsc_file: avsc_file
      end
    end

    it "supports pubsub_create_topic_with_schema, pubsub_publish_avro_records with JSON encoding" do
      @schema = pubsub.create_schema schema_id, :avro, avsc_definition

      # pubsub_create_topic_with_schema
      assert_output "Topic projects/#{pubsub.project}/topics/#{topic_id} created.\n" do
        create_topic_with_schema topic_id: topic_id, schema_id: schema_id, message_encoding: :json
      end
      @topic = pubsub.topic topic_id
      assert @topic
      assert_equal "projects/#{pubsub.project}/topics/#{topic_id}", @topic.name

      # pubsub_publish_avro_records
      assert_output "Published JSON-encoded AVRO message.\n" do
        publish_avro_records topic_id: topic_id, avsc_file: avsc_file
      end
    end

    it "supports pubsub_subscribe_avro_records with binary encoding" do
      @schema = pubsub.create_schema schema_id, :avro, avsc_definition
      @topic = pubsub.create_topic random_topic_id, schema_name: schema_id, message_encoding: :binary

      @subscription = @topic.subscribe random_subscription_id

      writer = Avro::IO::DatumWriter.new avro_schema
      buffer = StringIO.new
      writer.write record, Avro::IO::BinaryEncoder.new(buffer)
      @topic.publish buffer
      sleep 5

      # pubsub_subscribe_avro_records
      expect_with_retry "pubsub_subscribe_avro_records" do
        assert_output "Received a binary-encoded message:\n{\"name\"=>\"Alaska\", \"post_abbr\"=>\"AK\"}\n" do
          subscribe_avro_records subscription_id: @subscription.name, avsc_file: avsc_file
        end
      end
    end

    it "supports pubsub_subscribe_avro_records with JSON encoding" do
      @schema = pubsub.create_schema schema_id, :avro, avsc_definition
      @topic = pubsub.create_topic random_topic_id, schema_name: schema_id, message_encoding: :json

      @subscription = @topic.subscribe random_subscription_id

      @topic.publish record.to_json
      sleep 5

      # pubsub_subscribe_avro_records
      expect_with_retry "pubsub_subscribe_avro_records" do
        assert_output "Received a JSON-encoded message:\n{\"name\"=>\"Alaska\", \"post_abbr\"=>\"AK\"}\n" do
          subscribe_avro_records subscription_id: @subscription.name, avsc_file: nil
        end
      end
    end
  end

  describe "PROTOCOL_BUFFER" do
    require_relative "../utilities/us-states_pb"
    let(:proto_file) { File.expand_path("data/us-states.proto", __dir__) }
    let(:proto_definition) { File.read proto_file }

    it "supports pubsub_create_topic_with_schema, pubsub_publish_proto_messages with binary encoding" do
      @schema = pubsub.create_schema schema_id, :protocol_buffer, proto_definition

      # pubsub_create_topic_with_schema
      assert_output "Topic projects/#{pubsub.project}/topics/#{topic_id} created.\n" do
        create_topic_with_schema topic_id: topic_id, schema_id: schema_id, message_encoding: :binary
      end
      @topic = pubsub.topic topic_id
      assert @topic
      assert_equal "projects/#{pubsub.project}/topics/#{topic_id}", @topic.name

      # pubsub_publish_proto_messages
      assert_output "Published binary-encoded protobuf message.\n" do
        publish_proto_messages topic_id: topic_id
      end
    end

    it "supports pubsub_create_topic_with_schema, pubsub_publish_proto_messages with JSON encoding" do
      @schema = pubsub.create_schema schema_id, :protocol_buffer, proto_definition

      # pubsub_create_topic_with_schema
      assert_output "Topic projects/#{pubsub.project}/topics/#{topic_id} created.\n" do
        create_topic_with_schema topic_id: topic_id, schema_id: schema_id, message_encoding: :json
      end
      @topic = pubsub.topic topic_id
      assert @topic
      assert_equal "projects/#{pubsub.project}/topics/#{topic_id}", @topic.name

      # pubsub_publish_proto_messages
      assert_output "Published JSON-encoded protobuf message.\n" do
        publish_proto_messages topic_id: topic_id
      end
    end

    it "supports pubsub_subscribe_proto_messages with binary encoding" do
      @schema = pubsub.create_schema schema_id, :protocol_buffer, proto_definition
      @topic = pubsub.create_topic random_topic_id, schema_name: schema_id, message_encoding: :binary

      @subscription = @topic.subscribe random_subscription_id

      state = Utilities::StateProto.new name: "Alaska", post_abbr: "AK"
      @topic.publish Utilities::StateProto.encode(state)
      sleep 5

      # pubsub_subscribe_proto_messages
      expect_with_retry "pubsub_subscribe_proto_messages" do
        assert_output "Received a binary-encoded message:\n<Utilities::StateProto: name: \"Alaska\", post_abbr: \"AK\">\n" do
          subscribe_proto_messages subscription_id: @subscription.name
        end
      end
    end

    it "supports pubsub_subscribe_proto_messages with JSON encoding" do
      @schema = pubsub.create_schema schema_id, :protocol_buffer, proto_definition
      @topic = pubsub.create_topic random_topic_id, schema_name: schema_id, message_encoding: :json

      @subscription = @topic.subscribe random_subscription_id

      state = Utilities::StateProto.new name: "Alaska", post_abbr: "AK"
      @topic.publish Utilities::StateProto.encode_json(state)
      sleep 5

      # pubsub_subscribe_proto_messages
      expect_with_retry "pubsub_subscribe_proto_messages" do
        assert_output "Received a JSON-encoded message:\n<Utilities::StateProto: name: \"Alaska\", post_abbr: \"AK\">\n" do
          subscribe_proto_messages subscription_id: @subscription.name
        end
      end
    end
  end
end
