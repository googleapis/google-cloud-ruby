# Copyright 2023 Google, Inc
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

def test_subscription_permissions subscription_id:
  # [START pubsub_test_subscription_permissions]
  # subscription_id = "your-subscription-id"

  pubsub = Google::Cloud::PubSub.new
  subscription_admin = pubsub.subscription_admin
  permissions = ["pubsub.subscriptions.consume", "pubsub.subscriptions.update"]

  response = pubsub.iam.test_iam_permissions \
    resource: pubsub.subscription_path(subscription_id),
    permissions: permissions

  puts "Permission to consume" \
   if response.permissions.include? "pubsub.subscriptions.consume"
  puts "Permission to update" \
   if response.permissions.include? "pubsub.subscriptions.update"
  # [END pubsub_test_subscription_permissions]
end
