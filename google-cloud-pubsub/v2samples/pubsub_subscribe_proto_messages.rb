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
require_relative "utilities/us-states_pb"

def subscribe_proto_messages subscription_id:
  # [START pubsub_old_version_subscribe_proto_messages]
  # subscription_id = "your-subscription-id"

  pubsub = Google::Cloud::Pubsub.new

  subscription = pubsub.subscription subscription_id

  subscriber = subscription.listen do |received_message|
    encoding = received_message.attributes["googclient_schemaencoding"]
    case encoding
    when "BINARY"
      state = Utilities::StateProto.decode received_message.data
      puts "Received a binary-encoded message:\n#{state}"
    when "JSON"
      require "json"
      state = Utilities::StateProto.decode_json received_message.data
      puts "Received a JSON-encoded message:\n#{state}"
    else
      "Received a message with no encoding:\n#{received_message.message_id}"
    end
    received_message.acknowledge!
  end

  subscriber.start
  # Let the main thread sleep for 60 seconds so the thread for listening
  # messages does not quit
  sleep 60
  subscriber.stop.wait!
  # [END pubsub_old_version_subscribe_proto_messages]
end
