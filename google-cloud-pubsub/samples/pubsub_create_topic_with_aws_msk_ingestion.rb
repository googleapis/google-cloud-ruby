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

def create_topic_with_aws_msk_ingestion topic_id:,
                                        cluster_arn:,
                                        msk_topic:,
                                        aws_role_arn:,
                                        gcp_service_account:
  # [START pubsub_create_topic_with_aws_msk_ingestion]
  # topic_id = "your-topic-id"
  # cluster_arn =
  # "arn:aws:kafka:us-east-1:111111111111:cluster/cluster-name/11111111-1111-1"
  # msk_topic = "msk-topic-name"
  # aws_role_arn = "arn:aws:iam::111111111111:role/role-name"
  # gcp_service_account = "service-account@project.iam.gserviceaccount.com"

  pubsub = Google::Cloud::Pubsub.new
  topic_admin = pubsub.topic_admin

  topic = topic_admin.create_topic name: pubsub.topic_path(topic_id),
                                   ingestion_data_source_settings: {
                                     aws_msk: {
                                       cluster_arn: cluster_arn,
                                       topic: msk_topic,
                                       aws_role_arn: aws_role_arn,
                                       gcp_service_account: gcp_service_account
                                     }
                                   }

  puts "Topic with Aws MSK Ingestion #{topic.name} created."
  # [END pubsub_create_topic_with_aws_msk_ingestion]
end
