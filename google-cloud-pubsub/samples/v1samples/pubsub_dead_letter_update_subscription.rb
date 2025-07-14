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

def dead_letter_update_subscription subscription_id:
  # [START pubsub_old_version_dead_letter_update_subscription]
  # subscription_id       = "your-subscription-id"
  # role                  = "roles/pubsub.publisher"
  # service_account_email = "serviceAccount:account_name@project_name.iam.gserviceaccount.com"

  pubsub = Google::Cloud::Pubsub.new

  subscription = pubsub.subscription subscription_id
  subscription.dead_letter_max_delivery_attempts = 20
  puts "Max delivery attempts is now #{subscription.dead_letter_max_delivery_attempts}."
  # [END pubsub_old_version_dead_letter_update_subscription]
end
