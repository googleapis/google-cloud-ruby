# Copyright 2022 Google LLC
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

##
# Shows how to create a BigQuery subscription where messages published
# to a topic populates a BigQuery table.
#
def pubsub_create_bigquery_subscription project_id:, topic_id:, subscription_id:, bigquery_table_id:
  # [START pubsub_create_bigquery_subscription]
  # project_id = "your-project-id"
  # topic_id = "your-topic-id"
  # subscription_id = "your-subscription-id"
  # bigquery_table_id = "my-project:dataset-id.table-id"
  pubsub = Google::Cloud::PubSub.new project_id: project_id

  subscription_admin = pubsub.subscription_admin

  subscription = subscription_admin.create_subscription \
      name: pubsub.subscription_path(subscription_id),
      topic: pubsub.topic_path(topic_id),
      bigquery_config: {
        table: bigquery_table_id,
        write_metadata: true
      }

  puts "BigQuery subscription created: #{subscription_id}."
  puts "Table for subscription is: #{bigquery_table_id}"
  # [END pubsub_create_bigquery_subscription]
end
