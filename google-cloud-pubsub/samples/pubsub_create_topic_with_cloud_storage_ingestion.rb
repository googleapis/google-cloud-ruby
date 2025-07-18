# Copyright 2025 Google LLC
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

def create_topic_with_cloud_storage_ingestion topic_id:, bucket:, input_format:, text_delimiter:, match_glob:,
                                              minimum_object_create_time:
  # [START pubsub_create_topic_with_cloud_storage_ingestion]
  # topic_id = "your-topic-id"
  # bucket = "your-bucket-id"
  # input_format = "text"
  # text_delimiter = "\n"
  # match_glob = "**.txt"
  # minimum_object_create_time = Google::Protobuf::Timestamp.new
  pubsub = Google::Cloud::Pubsub.new

  topic_admin = pubsub.topic_admin

  cloud_storage =
    Google::Cloud::PubSub::V1::IngestionDataSourceSettings::CloudStorage.new bucket: bucket,
                                                                             minimum_object_create_time:
                                                                             minimum_object_create_time

  case input_format
  when "text"
    cloud_storage.text_format =
      Google::Cloud::PubSub::V1::IngestionDataSourceSettings::CloudStorage::TextFormat.new delimiter: text_delimiter
  when "avro"
    cloud_storage.avro_format = Google::Cloud::PubSub::V1::IngestionDataSourceSettings::CloudStorage::AvroFormat.new
  when "pubsub_avro"
    cloud_storage.pubsub_avro_format = Google::Cloud::PubSub::V1::IngestionDataSourceSettings::CloudStorage::PubSubAvroFormat.new
  else
    raise "input_format must be in ('text', 'avro', 'pubsub_avro'); got value: #{input_format}"
  end

  if !match_glob.nil? && !match_glob.empty?
    cloud_storage.match_glob = match_glob
  end

  topic = topic_admin.create_topic name: pubsub.topic_path(topic_id),
                                   ingestion_data_source_settings: {
                                     cloud_storage: cloud_storage
                                   }

  puts "Topic with Cloud Storage Ingestion #{topic.name} created."
  # [END pubsub_create_topic_with_cloud_storage_ingestion]
end
