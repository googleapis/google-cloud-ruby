# Copyright 2024 Google, Inc
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

# rubocop:disable Metrics/MethodLength

def create_topic_with_cloud_storage_ingestion topic_id:,
                                              bucket:,
                                              input_format:,
                                              text_delimiter:,
                                              match_glob:,
                                              minimum_object_create_time:
  # [START pubsub_create_topic_with_cloud_storage_ingestion]
  # project_id = "your-project-id"
  # topic_id = "your-topic-id"
  # bucket = "your-bucket"
  # input_format = "text"  (can be one of "text", "avro", "pubsub_avro")
  # text_delimiter = "\n"
  # match_glob = "**.txt"
  # minimum_object_create_time = "YYYY-MM-DDThh:mm:ssZ"

  pubsub = Google::Cloud::Pubsub.new
  cloud_storage_settings = Google::Cloud::PubSub::V1::IngestionDataSourceSettings::CloudStorage.new(
    bucket: bucket,
    match_glob: match_glob
  )
  case input_format
  when "text"
    cloud_storage_settings.text_format =
      Google::Cloud::PubSub::V1::IngestionDataSourceSettings::CloudStorage::TextFormat.new(
        delimiter: text_delimiter
      )
  when "avro"
    cloud_storage_settings.avro_format =
      Google::Cloud::PubSub::V1::IngestionDataSourceSettings::CloudStorage::AvroFormat.new
  when "pubsub_avro"
    cloud_storage_settings.pubsub_avro_format =
      Google::Cloud::PubSub::V1::IngestionDataSourceSettings::CloudStorage::PubSubAvroFormat.new
  else
    puts "Invalid input format: #{input_format}; must be in ('text', 'avro', 'pubsub_avro')"
    return
  end
  unless minimum_object_create_time.empty?
    cloud_storage_settings.minimum_object_create_time = Time.parse minimum_object_create_time
  end
  ingestion_data_source_settings = Google::Cloud::PubSub::V1::IngestionDataSourceSettings.new(
    cloud_storage: cloud_storage_settings
  )
  topic = pubsub.create_topic topic_id, ingestion_data_source_settings: ingestion_data_source_settings
  puts "Topic #{topic.name} with Cloud Storage ingestion settings created."
  # [END pubsub_create_topic_with_cloud_storage_ingestion]
end

# rubocop:enable Metrics/MethodLength
