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

def create_topic_with_kinesis_ingestion topic_id:, stream_arn:, consumer_arn:, aws_role_arn:, gcp_service_account:
  # [START pubsub_create_topic_with_kinesis_ingestion]
  # topic_id = "your-topic-id"
  # stream_arn = "arn:aws:kinesis:us-west-2:111111111111:stream/stream-name"
  # consumer_arn = "arn:aws:kinesis:us-west-2:111111111111:stream/stream-name/consumer/consumer-1:1111111111"
  # aws_role_arn = "arn:aws:iam::111111111111:role/role-name"
  # gcp_service_account = "service-account@project.iam.gserviceaccount.com"
  pubsub = Google::Cloud::Pubsub.new

  topic_admin = pubsub.topic_admin

  topic = topic_admin.create_topic name: pubsub.topic_path(topic_id),
                                   ingestion_data_source_settings: {
                                     aws_kinesis: {
                                       stream_arn: stream_arn,
                                       consumer_arn: consumer_arn,
                                       aws_role_arn: aws_role_arn,
                                       gcp_service_account: gcp_service_account
                                     }
                                   }

  puts "Topic with Kinesis Ingestion #{topic.name} created."
  # [END pubsub_create_topic_with_kinesis_ingestion]
end
