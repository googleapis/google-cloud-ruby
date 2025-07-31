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

def create_topic_with_azure_event_hubs_ingestion topic_id:,
                                                 resource_group:,
                                                 namespace:,
                                                 event_hub:,
                                                 client_id:,
                                                 tenant_id:,
                                                 subscription_id:,
                                                 gcp_service_account:
  # [START pubsub_create_topic_with_azure_event_hubs_ingestion]
  # topic_id = "your-topic-id"
  # resource_group = "resource-group"
  # namespace = "namespace"
  # event_hub = "event-hub"
  # client_id = "11111111-1111-1111-1111-11111111111"
  # tenant_id = "22222222-2222-2222-2222-222222222222"
  # subscription_id = "33333333-3333-3333-3333-333333333333"
  # gcp_service_account = "service-account@project.iam.gserviceaccount.com"
  pubsub = Google::Cloud::Pubsub.new

  topic_admin = pubsub.topic_admin

  topic = topic_admin.create_topic name: pubsub.topic_path(topic_id),
                                   ingestion_data_source_settings: {
                                     azure_event_hubs: {
                                       resource_group: resource_group,
                                       namespace: namespace,
                                       event_hub: event_hub,
                                       client_id: client_id,
                                       tenant_id: tenant_id,
                                       subscription_id: subscription_id,
                                       gcp_service_account: gcp_service_account
                                     }
                                   }

  puts "Topic with Azure Event Hubs Ingestion #{topic.name} created."
  # [END pubsub_create_topic_with_azure_event_hubs_ingestion]
end
