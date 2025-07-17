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

def publish_avro_records topic_id:, avsc_file:
  # [START pubsub_publish_avro_records]
  # topic_id = "your-topic-id"
  # avsc_file = "path/to/an/avro/schema/file/(.avsc)/formatted/in/json"

  pubsub = Google::Cloud::Pubsub.new

  topic_admin = pubsub.topic_admin

  topic = topic_admin.get_topic topic: pubsub.topic_path(topic_id)

  encoding = topic.schema_settings.encoding

  publisher = pubsub.publisher topic_id

  record = { "name" => "Alaska", "post_abbr" => "AK" }

  case encoding
  when :BINARY
    require "avro"
    avro_schema = Avro::Schema.parse File.read(avsc_file)
    writer = Avro::IO::DatumWriter.new avro_schema
    buffer = StringIO.new
    encoder = Avro::IO::BinaryEncoder.new buffer
    writer.write record, encoder
    publisher.publish buffer
    puts "Published binary-encoded AVRO message."
  when :JSON
    require "json"
    publisher.publish record.to_json
    puts "Published JSON-encoded AVRO message."
  else
    raise "No encoding specified in #{topic.name}."
  end
  # [END pubsub_publish_avro_records]
end
