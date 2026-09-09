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


Google::Cloud::Bigtable::V2::Bigtable::Client.configure do |config|
  config.channel_args ||= {}
  config.channel_args["grpc.max_send_message_length"] = -1
  config.channel_args["grpc.max_receive_message_length"] = -1
  config.channel_args["grpc.keepalive_time_ms"] = 30_000 # Sets 30s as Google Frontends allows keepalive pings at 30s
  config.channel_args["grpc.keepalive_timeout_ms"] = 10_000 # Conservative timeout at 10s
end
