# frozen_string_literal: true

# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


Google::Cloud::PubSub::V1::Subscriber::Client.configure do |config|
  config.channel_args ||= {}
  config.channel_args["grpc.max_send_message_length"] = -1
  config.channel_args["grpc.max_receive_message_length"] = -1
  config.channel_args["grpc.keepalive_time_ms"] = 300_000
  # Set max metadata size to 4 MB.
  config.channel_args["grpc.max_metadata_size"] = 4 * 1024 * 1024
end
