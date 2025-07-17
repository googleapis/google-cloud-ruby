# Copyright 2023 Google, Inc
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

def subscribe_avro_records subscription_id:, avsc_file:
  # [START pubsub_subscribe_avro_records]
  # subscription_id = "your-subscription-id"
  # avsc_file = "path/to/an/avro/schema/file/(.avsc)/formatted/in/json"

  pubsub = Google::Cloud::PubSub.new

  subscriber = pubsub.subscriber subscription_id

  listener = subscriber.listen do |received_message|
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

  listener.start
  # Let the main thread sleep for 60 seconds so the thread for listening
  # messages does not quit
  sleep 60
  listener.stop.wait!
  # [END pubsub_subscribe_avro_records]
end
