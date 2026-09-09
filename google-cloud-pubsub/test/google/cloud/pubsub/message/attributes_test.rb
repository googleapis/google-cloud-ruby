# Copyright 2015 Google LLC
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

require "helper"
require "base64"

describe Google::Cloud::PubSub::Message, :attributes do
  let(:message_hash) do
    {
      data: "hello world",
      attributes: { "foo" => "FOO", "bar" => "BAR" }
    }
  end
  let(:message_grpc)  { Google::Cloud::PubSub::V1::PubsubMessage.new message_hash }
  let(:message_obj)  { Google::Cloud::PubSub::Message.from_grpc message_grpc }

  it "has attributes as a Hash even when being a Google API object" do
    _(message_obj.attributes["foo"]).must_equal "FOO"
    _(message_obj.attributes.keys).must_include "bar"
    _(message_obj.attributes).must_be_kind_of Hash
  end
end
