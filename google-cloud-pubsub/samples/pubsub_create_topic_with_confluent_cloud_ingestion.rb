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

def create_topic_with_confluent_cloud_ingestion topic_id:, bootstrap_server:, cluster_id:, confluent_topic:,
                                                identity_pool_id:, gcp_service_account:
  # [START pubsub_create_topic_with_confluent_cloud_ingestion]
  # topic_id = "your-topic-id"
  # bootstrap_server = "bootstrap-server-id.us-south1.gcp.confluent.cloud:9092"
  # cluster_id = "cluster-id"
  # confluent_topic = "confluent-topic-name"
  # identity_pool_id = "identity-pool-id"
  # gcp_service_account = "service-account@project.iam.gserviceaccount.com"
  pubsub = Google::Cloud::Pubsub.new

  topic_admin = pubsub.topic_admin

  topic = topic_admin.create_topic name: pubsub.topic_path(topic_id),
                                   ingestion_data_source_settings: {
                                     confluent_cloud: {
                                       bootstrap_server: bootstrap_server,
                                       cluster_id: cluster_id,
                                       topic: confluent_topic,
                                       identity_pool_id: identity_pool_id,
                                       gcp_service_account: gcp_service_account
                                     }
                                   }

  puts "Topic with Confluent Cloud Ingestion #{topic.name} created."
  # [END pubsub_create_topic_with_confluent_cloud_ingestion]
end
