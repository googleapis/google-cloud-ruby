# Copyright 2026 Google LLC
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

def subscribe_avro_records_with_revisions subscription_id:
  # [START pubsub_subscribe_avro_records_with_revisions]
  # subscription_id = "your-subscription-id"

  pubsub = Google::Cloud::PubSub.new
  subscriber = pubsub.subscriber subscription_id

  # Cache for the parsed Avro schemas mapped by revision ID.
  schema_cache = {}
  cache_mutex = Mutex.new

  listener = subscriber.listen do |received_message|
    schema_name = received_message.attributes["googclient_schemaname"]
    revision_id = received_message.attributes["googclient_schemarevisionid"]
    encoding = received_message.attributes["googclient_schemaencoding"]

    # Prevent concurrent threads from racing to fetch and parse the same schema.
    avro_schema = cache_mutex.synchronize { schema_cache[revision_id] }


    if avro_schema.nil?
      begin
        require "avro"
        # The resource name format is projects/{project}/schemas/{schema}@{revision}
        schema_resource = pubsub.schemas.get_schema name: "#{schema_name}@#{revision_id}"
        
        avro_schema = Avro::Schema.parse schema_resource.definition
        
        cache_mutex.synchronize { schema_cache[revision_id] = avro_schema }
      rescue StandardError => e
        puts "Could not get schema for revision #{revision_id}: #{e.message}"
        received_message.reject!
        next
      end
    end

    begin
      case encoding
      when "BINARY"
        require "avro"
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
        puts "Unknown message type; rejecting message."
        received_message.reject!
        next
      end

      received_message.acknowledge!
    rescue StandardError => e
      puts "Failed to process message: #{e.message}"
      received_message.reject!
    end
  end

  listener.start


  # Let the main thread sleep for 60 seconds so the thread for listening
  # messages does not quit
  sleep 60
  listener.stop.wait!
  # [END pubsub_subscribe_avro_records_with_revisions]
end
