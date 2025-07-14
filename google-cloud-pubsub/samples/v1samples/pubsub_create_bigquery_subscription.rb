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

# [START pubsub_create_bigquery_subscription]
require "google/cloud/pubsub"

##
# Shows how to create a BigQuery subscription where messages published
# to a topic populates a BigQuery table.
#
# @param project_id [String]
# Your Google Cloud project (e.g. "my-project")
# @param topic_id [String]
# Your topic name (e.g. "my-secret")
# @param subscription_id [String]
# ID for new subscription to be created (e.g. "my-subscription")
# @param bigquery_table_id [String]
# ID of bigquery table (e.g "my-project:dataset-id.table-id")
#
def pubsub_create_bigquery_subscription project_id:, topic_id:, subscription_id:, bigquery_table_id:
  pubsub = Google::Cloud::Pubsub.new project_id: project_id
  topic = pubsub.topic topic_id
  subscription = topic.subscribe subscription_id,
                                 bigquery_config: {
                                   table: bigquery_table_id,
                                   write_metadata: true
                                 }
  puts "BigQuery subscription created: #{subscription_id}."
  puts "Table for subscription is: #{bigquery_table_id}"
end
# [END pubsub_create_bigquery_subscription]
