# Copyright 2015 Google LLC
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

require "helper"
require "base64"

describe Google::Cloud::Pubsub::Message, :attributes do
  let(:message_hash) do
    {
      "data" => Base64.strict_encode64("hello world"),
      "attributes" => { "foo" => "FOO", "bar" => "BAR" }
    }
  end
  let(:message_json)  { message_hash.to_json }
  let(:message_grpc)  { Google::Pubsub::V1::PubsubMessage.decode_json message_json }
  let(:message_obj)  { Google::Cloud::Pubsub::Message.from_grpc message_grpc }

  it "has attributes as a Hash even when being a Google API object" do
    message_obj.attributes["foo"].must_equal "FOO"
    message_obj.attributes.keys.must_include "bar"
    message_obj.attributes.must_be_kind_of Hash
  end
end
