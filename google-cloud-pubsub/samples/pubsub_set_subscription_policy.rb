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

def set_subscription_policy subscription_id:, role:, service_account_email:
  # [START pubsub_set_subscription_policy]
  # subscription_id       = "your-subscription-id"
  # role                  = "roles/pubsub.subscriber"
  # service_account_email = "serviceAccount:account_name@project_name.iam.gserviceaccount.com"

  pubsub = Google::Cloud::PubSub.new

  subscription_admin = pubsub.subscription_admin

  bindings = Google::Iam::V1::Binding.new role: role, members: [service_account_email]

  pubsub.iam.set_iam_policy resource: pubsub.subscription_path(subscription_id),
                            policy: {
                              bindings: [bindings]
                            }
  # [END pubsub_set_subscription_policy]
end
