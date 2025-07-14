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

def update_push_configuration subscription_id:, new_endpoint:
  # [START pubsub_update_push_configuration]
  # subscription_id   = "your-subscription-id"
  # new_endpoint      = "Endpoint where your app receives messages""

  pubsub = Google::Cloud::Pubsub.new

  subscription          = pubsub.subscription subscription_id
  subscription.endpoint = new_endpoint

  puts "Push endpoint updated."
  # [END pubsub_update_push_configuration]
end
