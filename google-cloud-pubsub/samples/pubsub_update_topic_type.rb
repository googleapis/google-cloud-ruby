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

def update_topic_type topic_id:,
                      stream_arn:,
                      consumer_arn:,
                      aws_role_arn:,
                      gcp_service_account:
  # [START pubsub_update_topic_type]
  # topic_id = "your-topic-id"
  # stream_arn = "arn:aws:kinesis:us-west-2:111111111111:stream/stream-name"
  # consumer_arn =
  # "arn:aws:kinesis:us-west-2:111111111111:stream/x/consumer/y:1111111111"
  # aws_role_arn = "arn:aws:iam::111111111111:role/role-name"
  # gcp_service_account = "service-account@project.iam.gserviceaccount.com"

  pubsub = Google::Cloud::Pubsub.new
  topic_admin = pubsub.topic_admin

  ingestion_data_source_settings =
    Google::Cloud::PubSub::V1::IngestionDataSourceSettings.new \
      aws_kinesis: {
        stream_arn: stream_arn,
        consumer_arn: consumer_arn,
        aws_role_arn: aws_role_arn,
        gcp_service_account: gcp_service_account
      }
  topic = topic_admin.get_topic topic: pubsub.topic_path(topic_id)
  topic.ingestion_data_source_settings = ingestion_data_source_settings

  topic = topic_admin.update_topic topic: topic,
                                   update_mask: {
                                     paths: ["ingestion_data_source_settings"]
                                   }

  puts "Topic #{topic.name} updated."
  # [END pubsub_update_topic_type]
end
