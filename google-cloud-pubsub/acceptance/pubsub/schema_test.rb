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

require "pubsub_helper"
require "avro"

# This test is a ruby version of gcloud-node's pubsub test.

describe Google::Cloud::PubSub::V1::Schema, :pubsub do
  let(:topic_name) { $topic_names[10] }
  let(:topic_name_2) { $topic_names[11] }
  let(:schema_name) { $schema_names[0] }
  let :definition_hash do
    {
      "type" => "record",
      "name" => "State",
      "namespace" => "utilities",
      "doc" => "A list of states in the United States of America.",
      "fields" => [
        {
          "name" => "name",
          "type" => "string",
          "doc" => "The common name of the state."
        },
        {
          "name" => "post_abbr",
          "type" => "string",
          "doc" => "The postal code abbreviation of the state."
        }
      ]
    }
  end
  let(:definition) { definition_hash.to_json }
  let(:message_data) { { "name" => "Alaska", "post_abbr" => "AK" } }
  let(:bad_value) { { "BAD_VALUE" => nil } }

  it "should validate, create, list, get, validate message, create topic, publish binary message, receive binary message, and delete a schema" do
    skip("https://github.com/googleapis/google-cloud-ruby/issues/20925")
    # validate schema
    _(pubsub.valid_schema? :avro, definition).must_equal true
    _(pubsub.valid_schema? :TYPE_UNSPECIFIED, definition).must_equal false
    _(pubsub.valid_schema? :avro, nil).must_equal false
    _(pubsub.valid_schema? :avro, bad_value.to_json).must_equal false

    # create
    schema = pubsub.create_schema schema_name, :avro, definition
    _(schema).must_be_kind_of Google::Cloud::PubSub::Schema
    _(schema.name).must_equal "projects/#{pubsub.project_id}/schemas/#{schema_name}"
    _(schema.type).must_equal :AVRO
    _(schema.definition).must_equal definition

    # list
    schemas = pubsub.schemas
    _(schemas).wont_be :empty?
    schema = schemas.first
    _(schema).must_be_kind_of Google::Cloud::PubSub::Schema
    _(schema.name).wont_be :nil?
    _(schema.type).wont_be :nil?
    _(schema.definition).wont_be :nil?

    # get
    schema = pubsub.schema schema_name
    _(schema).must_be_kind_of Google::Cloud::PubSub::Schema
    _(schema.name).must_equal "projects/#{pubsub.project_id}/schemas/#{schema_name}"
    _(schema.type).must_equal :AVRO
    _(schema.definition).must_equal definition

    # validate message
    _(schema.validate_message message_data.to_json, :json).must_equal true
    _(schema.validate_message bad_value.to_json, :json).must_equal false

    # create topic with schema
    topic = pubsub.create_topic topic_name, schema_name: schema_name, message_encoding: :binary
    _(topic.schema_name).must_equal "projects/#{pubsub.project_id}/schemas/#{schema_name}"
    _(topic.message_encoding).must_equal :BINARY
    _(topic.message_encoding_json?).must_equal false
    _(topic.message_encoding_binary?).must_equal true

    topic = pubsub.topic topic.name
    _(topic.schema_name).must_equal "projects/#{pubsub.project_id}/schemas/#{schema_name}"
    _(topic.message_encoding).must_equal :BINARY
    _(topic.message_encoding_json?).must_equal false
    _(topic.message_encoding_binary?).must_equal true

    begin
      subscription = topic.subscribe "#{$topic_prefix}-sub-avro-1"
      _(subscription).must_be_kind_of Google::Cloud::PubSub::Subscription
      # No messages, should be empty
      received_messages = subscription.pull
      _(received_messages).must_be :empty?

      # Encode and publish a message
      avro_schema = Avro::Schema.parse definition
      writer = Avro::IO::DatumWriter.new avro_schema
      buffer = StringIO.new
      encoder = Avro::IO::BinaryEncoder.new buffer
      writer.write message_data, encoder
      msg = topic.publish buffer
      _(msg).wont_be :nil?

      # Check it received the published message
      wait_for_condition description: "subscription pull" do
        received_messages = subscription.pull immediate: false
        received_messages.any?
      end
      _(received_messages.count).must_equal 1
      received_message = received_messages.first
      _(received_message.data).must_equal msg.data
      # Acknowledge the message
      subscription.ack received_message.ack_id

      # Decode the message data
      buffer = StringIO.new received_message.data
      decoder = Avro::IO::BinaryDecoder.new buffer
      reader = Avro::IO::DatumReader.new avro_schema
      decoded_message_data = reader.read decoder
      _(decoded_message_data).must_be_kind_of Hash
      _(decoded_message_data).must_equal message_data
    ensure
      # Remove the subscription
      subscription.delete
    end

    # delete
    schema.delete

    wait_for_condition description: "schema delete" do
      schema = pubsub.schema schema_name, view: :basic
      schema.nil?
    end
    _(schema).must_be :nil?
  end
end
