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

def create_subscription_with_smt topic_id:, subscription_id:
  # [START pubsub_create_subscription_with_smt]
  # topic_id        = "your-topic-id"
  # subscription_id = "your-subscription-id"

  pubsub = Google::Cloud::PubSub.new
  subscription_admin = pubsub.subscription_admin

  # UDF that removes the 'ssn' field, if present
  code = "function redactSSN(message, metadata) {\n" \
         "  const data = JSON.parse(message.data);\n" \
         "  delete data['ssn'];\n" \
         "  message.data = JSON.stringify(data);\n" \
         "  return message;\n" \
         "}"

  subscription = subscription_admin.create_subscription(
    name: pubsub.subscription_path(subscription_id),
    topic: pubsub.topic_path(topic_id),
    message_transforms: [
      {
        javascript_udf: {
          function_name: "redactSSN",
          code: code
        }
      }
    ]
  )

  puts "Created subscription with SMT: #{subscription.name}"
  # [END pubsub_create_subscription_with_smt]
end
