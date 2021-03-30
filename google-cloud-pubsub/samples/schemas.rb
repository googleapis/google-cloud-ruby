# Copyright 2021 Google, Inc
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

require "google/cloud/pubsub"

def create_avro_schema schema_id:, avsc_file:
  # [START pubsub_create_avro_schema]
  # schema_id = "your-schema-id"
  # avsc_file = "path/to/an/avro/schema/file/(.avsc)/formatted/in/json"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  definition = File.read avsc_file
  schema = pubsub.create_schema schema_id, :avro, definition

  puts "Schema #{schema.name} created."
  # [END pubsub_create_avro_schema]
end

def create_proto_schema schema_id:, proto_file:
  # [START pubsub_create_proto_schema]
  # schema_id = "your-schema-id"
  # proto_file = "path/to/a/proto/file/(.proto)/formatted/in/protocol/buffers"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  definition = File.read proto_file
  schema = pubsub.create_schema schema_id, :protocol_buffer, definition

  puts "Schema #{schema.name} created."
  # [END pubsub_create_proto_schema]
end

def get_schema schema_id:
  # [START pubsub_get_schema]
  # schema_id = "your-schema-id"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  schema = pubsub.schema schema_id

  puts "Schema #{schema.name} retrieved."
  # [END pubsub_get_schema]
end

def list_schemas
  # [START pubsub_list_schemas]
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  schemas = pubsub.schemas

  puts "Schemas in project:"
  schemas.each do |schema|
    puts schema.name
  end
  # [END pubsub_list_schemas]
end

def delete_schema schema_id:
  # [START pubsub_delete_schema]
  # schema_id = "your-schema-id"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  schema = pubsub.schema schema_id
  schema.delete

  puts "Schema #{schema_id} deleted."
  # [END pubsub_delete_schema]
end

def create_topic_with_schema topic_id:, schema_id:, message_encoding:
  # [START pubsub_create_topic_with_schema]
  # topic_id = "your-topic-id"
  # schema_id = "your-schema-id"
  # Choose either BINARY or JSON as valid message encoding in this topic.
  # message_encoding = :binary
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  topic = pubsub.create_topic topic_id, schema_name: schema_id, message_encoding: message_encoding

  puts "Topic #{topic.name} created."
  # [END pubsub_create_topic_with_schema]
end

def publish_avro_records topic_id:, avsc_file:
  # [START pubsub_publish_avro_records]
  # topic_id = "your-topic-id"
  # avsc_file = "path/to/an/avro/schema/file/(.avsc)/formatted/in/json"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  topic = pubsub.topic topic_id

  record = { "name" => "Alaska", "post_abbr" => "AK" }

  if topic.message_encoding_binary?
    require "avro"
    avro_schema = Avro::Schema.parse File.read(avsc_file)
    writer = Avro::IO::DatumWriter.new avro_schema
    buffer = StringIO.new
    encoder = Avro::IO::BinaryEncoder.new buffer
    writer.write record, encoder
    topic.publish buffer
    puts "Published binary-encoded AVRO message."
  elsif topic.message_encoding_json?
    require "json"
    topic.publish record.to_json
    puts "Published JSON-encoded AVRO message."
  else
    raise "No encoding specified in #{topic.name}."
  end
  # [END pubsub_publish_avro_records]
end

def publish_proto_messages topic_id:
  # [START pubsub_publish_proto_messages]
  # topic_id = "your-topic-id"
  require "google/cloud/pubsub"
  require_relative "utilities/us-states_pb"

  pubsub = Google::Cloud::Pubsub.new

  topic = pubsub.topic topic_id

  state = Utilities::StateProto.new name: "Alaska", post_abbr: "AK"

  if topic.message_encoding_binary?
    topic.publish Utilities::StateProto.encode(state)
    puts "Published binary-encoded protobuf message."
  elsif topic.message_encoding_json?
    topic.publish Utilities::StateProto.encode_json(state)
    puts "Published JSON-encoded protobuf message."
  else
    raise "No encoding specified in #{topic.name}."
  end
  # [END pubsub_publish_proto_messages]
end

def subscribe_avro_records subscription_id:, avsc_file:
  # [START pubsub_subscribe_avro_records]
  # subscription_id = "your-subscription-id"
  # avsc_file = "path/to/an/avro/schema/file/(.avsc)/formatted/in/json"
  require "google/cloud/pubsub"

  pubsub = Google::Cloud::Pubsub.new

  subscription = pubsub.subscription subscription_id

  subscriber = subscription.listen do |received_message|
    encoding = received_message.attributes["googclient_schemaencoding"]
    case encoding
    when "BINARY"
      require "avro"
      avro_schema = Avro::Schema.parse File.read(avsc_file)
      buffer = StringIO.new received_message.data
      decoder = Avro::IO::BinaryDecoder.new buffer
      reader = Avro::IO::DatumReader.new avro_schema
      message_data = reader.read decoder
      puts "Received a binary-encoded message:\n#{message_data}"
    when "JSON"
      require "json"
      message_data = JSON.parse received_message.data
      puts "Received a JSON-encoded message:\n#{message_data}"
    else
      "Received a message with no encoding:\n#{received_message.message_id}"
    end
    received_message.acknowledge!
  end

  subscriber.start
  # Let the main thread sleep for 60 seconds so the thread for listening
  # messages does not quit
  sleep 60
  subscriber.stop.wait!
  # [END pubsub_subscribe_avro_records]
end

def subscribe_proto_messages subscription_id:
  # [START pubsub_subscribe_proto_messages]
  # subscription_id = "your-subscription-id"
  require "google/cloud/pubsub"
  require_relative "utilities/us-states_pb"

  pubsub = Google::Cloud::Pubsub.new

  subscription = pubsub.subscription subscription_id

  subscriber = subscription.listen do |received_message|
    encoding = received_message.attributes["googclient_schemaencoding"]
    case encoding
    when "BINARY"
      state = Utilities::StateProto.decode received_message.data
      puts "Received a binary-encoded message:\n#{state}"
    when "JSON"
      require "json"
      state = Utilities::StateProto.decode_json received_message.data
      puts "Received a JSON-encoded message:\n#{state}"
    else
      "Received a message with no encoding:\n#{received_message.message_id}"
    end
    received_message.acknowledge!
  end

  subscriber.start
  # Let the main thread sleep for 60 seconds so the thread for listening
  # messages does not quit
  sleep 60
  subscriber.stop.wait!
  # [END pubsub_subscribe_proto_messages]
end

if $PROGRAM_NAME == __FILE__
  case ARGV.shift
  when "create_avro_schema"
    create_avro_schema schema_id: ARGV.shift, avsc_file: ARGV.shift
  when "create_proto_schema"
    create_proto_schema schema_id: ARGV.shift, proto_file: ARGV.shift
  when "get_schema"
    get_schema schema_id: ARGV.shift
  when "list_schemas"
    list_schemas
  when "delete_schema"
    delete_schema schema_id: ARGV.shift
  when "create_topic_with_schema"
    create_topic_with_schema topic_id: ARGV.shift, schema_id: ARGV.shift, message_encoding: ARGV.shift
  when "publish_avro_records"
    publish_avro_records topic_id: ARGV.shift, avsc_file: ARGV.shift
  when "publish_proto_messages"
    publish_proto_messages topic_id: ARGV.shift
  when "subscribe_avro_records"
    subscribe_avro_records subscription_id: ARGV.shift, avsc_file: ARGV.shift
  when "subscribe_proto_messages"
    subscribe_proto_messages subscription_id: ARGV.shift
  else
    puts <<~USAGE
      Usage: bundle exec ruby schemas.rb [command] [arguments]

      Commands:
        create_avro_schema       <schema_id> <avsc_file>                   Create an AVRO schema
        create_proto_schema      <schema_id> <proto_file>                  Create a protobuf schema
        get_schema               <schema_id>                               Get a schema
        list_schemas                                                       List schemas in a project
        delete_schema            <schema_id>                               Delete a schema
        create_topic_with_schema <topic_id> <schema_id> <message_encoding> Create a topic with a schema
        publish_avro_records     <topic_id> <avsc_file>                    Publish an AVRO message
        publish_proto_messages   <topic_id>                                Publish a protobuf message
        subscribe_avro_records   <subscription_id> <avsc_file>             Receive an AVRO message
        subscribe_proto_messages <subscription_id>                         Receive a protobuf message
    USAGE
  end
end
