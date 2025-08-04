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
require_relative "../pubsub_commit_avro_schema"
require_relative "../pubsub_commit_proto_schema"
require_relative "../pubsub_create_avro_schema"
require_relative "../pubsub_create_topic_with_schema"
require_relative "../pubsub_create_proto_schema"
require_relative "../pubsub_delete_schema"
require_relative "../pubsub_delete_schema_revision"
require_relative "../pubsub_get_schema"
require_relative "../pubsub_get_schema_revision"
require_relative "../pubsub_list_schema_revisions"
require_relative "../pubsub_list_schemas"
require_relative "../pubsub_publish_avro_records"
require_relative "../pubsub_subscribe_avro_records"
require_relative "../pubsub_publish_proto_messages"
require_relative "../pubsub_subscribe_proto_messages"


describe "schemas" do
  let(:pubsub) { Google::Cloud::PubSub.new }
  let(:schema_id) { random_schema_id }
  let(:topic_id) { random_topic_id }
  let(:subscription_id) { random_subscription_id }
  let(:avsc_file) { File.expand_path "data/us-states.avsc", __dir__ }
  let(:topic_admin) { pubsub.topic_admin }
  let(:subscription_admin) { pubsub.subscription_admin }
  let(:schemas) { pubsub.schemas }
  let(:proto_file) { File.expand_path "data/us-states.proto", __dir__ }
  let(:revision_file) { File.expand_path "data/us-states-revision.proto", __dir__ }

  after do
    subscription_admin.delete_subscription subscription: @subscription.name if @subscription
    topic_admin.delete_topic topic: @topic.name if @topic
    schemas.delete_schema name: @schema.name if @schema
  end

  it "supports pubsub_create_avro_schema, pubsub_get_schema, pubsub_list_schemas, pubsub_delete_schema" do
    # create_avro_schema
    assert_output "Schema projects/#{pubsub.project}/schemas/#{schema_id} created.\n" do
      create_avro_schema schema_id: schema_id, avsc_file: avsc_file
    end
    @schema = schemas.get_schema name: pubsub.schema_path(schema_id)
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

  it "supports pubsub_create_proto_schema, pubsub_get_schema_revision, pubsub_commit_proto_schema, pubsub_delete_schema_revision" do
    # create_proto_schema
    assert_output "Schema projects/#{pubsub.project}/schemas/#{schema_id} created.\n" do
      create_proto_schema schema_id: schema_id, proto_file: proto_file
    end
    @schema = schemas.get_schema name: pubsub.schema_path(schema_id)
    assert @schema
    assert_equal "projects/#{pubsub.project}/schemas/#{schema_id}", @schema.name

    # pubsub_get_schema_revision
    assert_output "Schema projects/#{pubsub.project}/schemas/#{schema_id}@#{@schema.revision_id} retrieved.\n" do
      get_schema_revision schema_id: schema_id, revision_id: @schema.revision_id
    end

    # pubsub_commit_proto_schema
    revised_schema = nil
    out, _err = capture_io do
      revised_schema = commit_proto_schema schema_id: schema_id, proto_file: revision_file
    end
    assert_includes out, "Schema committed with revision #{revised_schema.revision_id}."

    #pubsub_delete_schema_revision
    assert_output "Schema #{schema_id}@#{revised_schema.revision_id} deleted.\n" do
      delete_schema_revision schema_id: schema_id, revision_id: revised_schema.revision_id
    end
  end

  describe "AVRO" do
    require "avro"
    let(:avsc_definition) { File.read avsc_file }
    let(:avro_schema) { Avro::Schema.parse avsc_definition }
    let(:record) { { "name" => "Alaska", "post_abbr" => "AK" } }

    before do
      schema = Google::Cloud::PubSub::V1::Schema.new name: schema_id, 
                                                     type: :AVRO,
                                                     definition: avsc_definition
      @schema = schemas.create_schema parent: pubsub.project_path,
                                      schema: schema,
                                      schema_id: schema_id
    end

    it "supports pubsub_create_topic_with_schema, pubsub_publish_avro_records with binary encoding" do
      # pubsub_create_topic_with_schema
      assert_output "Topic projects/#{pubsub.project}/topics/#{topic_id} created.\n" do
        create_topic_with_schema topic_id: topic_id, schema_id: schema_id, message_encoding: :BINARY
      end
      @topic = topic_admin.get_topic topic: pubsub.topic_path(topic_id)
      assert @topic
      assert_equal "projects/#{pubsub.project}/topics/#{topic_id}", @topic.name

      # pubsub_publish_avro_records
      assert_output "Published binary-encoded AVRO message.\n" do
        publish_avro_records topic_id: topic_id, avsc_file: avsc_file
      end
    end

    it "supports pubsub_create_topic_with_schema, pubsub_publish_avro_records with JSON encoding" do
      # pubsub_create_topic_with_schema
      assert_output "Topic projects/#{pubsub.project}/topics/#{topic_id} created.\n" do
        create_topic_with_schema topic_id: topic_id, schema_id: schema_id, message_encoding: :JSON
      end
      @topic = topic_admin.get_topic topic: pubsub.topic_path(topic_id)
      assert @topic
      assert_equal "projects/#{pubsub.project}/topics/#{topic_id}", @topic.name

      # pubsub_publish_avro_records
      assert_output "Published JSON-encoded AVRO message.\n" do
        publish_avro_records topic_id: topic_id, avsc_file: avsc_file
      end
    end

    it "supports pubsub_subscribe_avro_records with binary encoding" do
      schema_settings = Google::Cloud::PubSub::V1::SchemaSettings.new schema: pubsub.schema_path(schema_id),
                                                                      encoding: :BINARY


      @topic = topic_admin.create_topic name: pubsub.topic_path(random_topic_id),
                                        schema_settings: schema_settings

      @subscription = subscription_admin.create_subscription name: pubsub.subscription_path(random_subscription_id),
                                                             topic: @topic.name,
                                                             ack_deadline_seconds: 60

      writer = Avro::IO::DatumWriter.new avro_schema
      buffer = StringIO.new
      writer.write record, Avro::IO::BinaryEncoder.new(buffer)
      publisher = pubsub.publisher @topic.name
      publisher.publish buffer

      # pubsub_subscribe_avro_records
      expect_with_retry "pubsub_subscribe_avro_records" do
        assert_output "Received a binary-encoded message:\n{\"name\" => \"Alaska\", \"post_abbr\" => \"AK\"}\n" do
          subscribe_avro_records subscription_id: @subscription.name, avsc_file: avsc_file
        end
      end
    end

    it "supports pubsub_subscribe_avro_records with JSON encoding" do
      schema_settings = Google::Cloud::PubSub::V1::SchemaSettings.new schema: pubsub.schema_path(schema_id),
                                                                      encoding: :JSON


      @topic = topic_admin.create_topic name: pubsub.topic_path(random_topic_id),
                                        schema_settings: schema_settings

      @subscription = subscription_admin.create_subscription name: pubsub.subscription_path(random_subscription_id),
                                                             topic: @topic.name,
                                                             ack_deadline_seconds: 60

      publisher = pubsub.publisher @topic.name
      publisher.publish record.to_json

      # pubsub_subscribe_avro_records
      expect_with_retry "pubsub_subscribe_avro_records" do
        assert_output "Received a JSON-encoded message:\n{\"name\" => \"Alaska\", \"post_abbr\" => \"AK\"}\n" do
          subscribe_avro_records subscription_id: @subscription.name, avsc_file: nil
        end
      end
    end

    it "supports pubsub_commit_avro_schema & pubsub_commit_list_schema_revisions" do
      
      rev_id = @schema.revision_id

      schema1 = nil
      # pubsub_commit_avro_schema
      out, _err = capture_io do
        schema1 = commit_avro_schema schema_id: schema_id, avsc_file: avsc_file
      end
      refute_equal out, "Schema committed with revision #{rev_id}."
      assert_includes out, "Schema committed with revision"

      # pubsub_list_schema_revisions
      out, _err = capture_io do
        list_schema_revisions schema_id: schema_id
      end

      assert_includes out, schema1.revision_id
    end
  end

  describe "PROTOCOL_BUFFER" do
    require_relative "../utilities/us-states_pb"
    let(:proto_definition) { File.read proto_file }
    let(:revision_file) { File.expand_path "data/us-states-revision.proto", __dir__ }

    it "supports pubsub_create_topic_with_schema, pubsub_publish_proto_messages with binary encoding" do
      schema = Google::Cloud::PubSub::V1::Schema.new name: schema_id, 
                                                     type: :PROTOCOL_BUFFER,
                                                     definition: proto_definition
      @schema = schemas.create_schema parent: pubsub.project_path,
                                      schema: schema,
                                      schema_id: schema_id

      # pubsub_create_topic_with_schema
      assert_output "Topic projects/#{pubsub.project}/topics/#{topic_id} created.\n" do
        create_topic_with_schema topic_id: topic_id, schema_id: schema_id, message_encoding: :BINARY
      end

      @topic = topic_admin.get_topic topic: pubsub.topic_path(topic_id)
      assert @topic
      assert_equal "projects/#{pubsub.project}/topics/#{topic_id}", @topic.name

      # pubsub_publish_proto_messages
      assert_output "Published binary-encoded protobuf message.\n" do
        publish_proto_messages topic_id: topic_id
      end
    end

    it "supports pubsub_create_topic_with_schema, pubsub_publish_proto_messages with JSON encoding" do
      schema = Google::Cloud::PubSub::V1::Schema.new name: schema_id, 
                                                     type: :PROTOCOL_BUFFER,
                                                     definition: proto_definition
      @schema = schemas.create_schema parent: pubsub.project_path,
                                      schema: schema,
                                      schema_id: schema_id

      # pubsub_create_topic_with_schema
      assert_output "Topic projects/#{pubsub.project}/topics/#{topic_id} created.\n" do
        create_topic_with_schema topic_id: topic_id, schema_id: schema_id, message_encoding: :JSON
      end

      @topic = topic_admin.get_topic topic: pubsub.topic_path(topic_id)
      assert @topic
      assert_equal "projects/#{pubsub.project}/topics/#{topic_id}", @topic.name

      # pubsub_publish_proto_messages
      assert_output "Published JSON-encoded protobuf message.\n" do
        publish_proto_messages topic_id: topic_id
      end
    end

    it "supports pubsub_subscribe_proto_messages with binary encoding" do
      schema = Google::Cloud::PubSub::V1::Schema.new name: schema_id, 
                                                     type: :PROTOCOL_BUFFER,
                                                     definition: proto_definition
      @schema = schemas.create_schema parent: pubsub.project_path,
                                      schema: schema,
                                      schema_id: schema_id

      schema_settings = Google::Cloud::PubSub::V1::SchemaSettings.new schema: pubsub.schema_path(schema_id),
                                                                      encoding: :BINARY

      @topic = topic_admin.create_topic name: pubsub.topic_path(random_topic_id),
                                        schema_settings: schema_settings

      @subscription = subscription_admin.create_subscription name: pubsub.subscription_path(random_subscription_id),
                                                             topic: @topic.name

      state = Utilities::StateProto.new name: "Alaska", post_abbr: "AK"
      publisher = pubsub.publisher @topic.name
      publisher.publish Utilities::StateProto.encode(state)
      sleep 5

      # pubsub_subscribe_proto_messages
      expect_with_retry "pubsub_subscribe_proto_messages" do
        assert_output "Received a binary-encoded message:\n<Utilities::StateProto: name: \"Alaska\", post_abbr: \"AK\">\n" do
          subscribe_proto_messages subscription_id: @subscription.name
        end
      end
    end

    it "supports pubsub_subscribe_proto_messages with JSON encoding" do
      schema = Google::Cloud::PubSub::V1::Schema.new name: schema_id, 
                                                     type: :PROTOCOL_BUFFER,
                                                     definition: proto_definition
      @schema = schemas.create_schema parent: pubsub.project_path,
                                      schema: schema,
                                      schema_id: schema_id

      schema_settings = Google::Cloud::PubSub::V1::SchemaSettings.new schema: pubsub.schema_path(schema_id),
                                                                      encoding: :JSON

      @topic = topic_admin.create_topic name: pubsub.topic_path(random_topic_id),
                                        schema_settings: schema_settings

      @subscription = subscription_admin.create_subscription name: pubsub.subscription_path(random_subscription_id),
                                                             topic: @topic.name

      state = Utilities::StateProto.new name: "Alaska", post_abbr: "AK"
      publisher = pubsub.publisher @topic.name
      publisher.publish Utilities::StateProto.encode_json(state)
      sleep 5

      # pubsub_subscribe_proto_messages
      expect_with_retry "pubsub_subscribe_proto_messages" do
        assert_output "Received a JSON-encoded message:\n<Utilities::StateProto: name: \"Alaska\", post_abbr: \"AK\">\n" do
          subscribe_proto_messages subscription_id: @subscription.name
        end
      end
    end

    it "supports pubsub_commit_proto_schema & pubsub_commit_list_schema_revisions" do
      schema = Google::Cloud::PubSub::V1::Schema.new name: schema_id, 
                                                     type: :PROTOCOL_BUFFER,
                                                     definition: proto_definition
      @schema = schemas.create_schema parent: pubsub.project_path,
                                      schema: schema,
                                      schema_id: schema_id

      rev_id = @schema.revision_id

      # pubsub_commit_proto_schema
      schema1 = nil
      out, _err = capture_io do
        schema1 = commit_proto_schema schema_id: schema_id, proto_file: revision_file
      end
      refute_equal out, "Schema committed with revision #{rev_id}."
      assert_includes out, "Schema committed with revision"

      # pubsub_list_schema_revisions
      schema2 = nil
      out, _err = capture_io do
        schema2 = commit_proto_schema schema_id: schema_id, proto_file: revision_file
      end

      out, _err = capture_io do
        list_schema_revisions schema_id: schema_id
      end

      assert_includes out, schema1.revision_id
      assert_includes out, schema2.revision_id
    end
  end
end
