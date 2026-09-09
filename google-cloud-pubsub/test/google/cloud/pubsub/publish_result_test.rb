# Copyright 2017 Google LLC
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

describe Google::Cloud::PubSub::PublishResult, :mock_pubsub do
  let(:data) { "msg-goes-here" }
  let(:attributes) { { "foo" => "FOO", "bar" => "BAR" } }
  let(:msg) { Google::Cloud::PubSub::Message.new data, attributes }
  let(:result) { Google::Cloud::PubSub::PublishResult.new msg }

  it "knows attributes" do
    _(result.data).must_equal data
    _(result.message.data).must_equal data
    _(result.msg.data).must_equal data

    _(result.attributes.keys.sort).must_equal   attributes.keys.sort
    _(result.attributes.values.sort).must_equal attributes.values.sort
    _(result.message.attributes.keys.sort).must_equal   attributes.keys.sort
    _(result.message.attributes.values.sort).must_equal attributes.values.sort
    _(result.msg.attributes.keys.sort).must_equal   attributes.keys.sort
    _(result.msg.attributes.values.sort).must_equal attributes.values.sort

    _(result.message_id).must_be :empty?
    _(result.message.message_id).must_be :empty?
    _(result.msg.message_id).must_be :empty?

    _(result.published_at).must_be :nil?
    _(result.message.published_at).must_be :nil?
    _(result.msg.published_at).must_be :nil?

    _(result.publish_time).must_be :nil?
    _(result.message.publish_time).must_be :nil?
    _(result.msg.publish_time).must_be :nil?

    _(result.message).must_equal msg
    _(result.msg).must_equal msg

    _(result.error).must_be :nil?

    _(result).must_be :succeeded?
    _(result).wont_be :failed?
  end

  describe "with error" do
    let(:error) { StandardError.new "something happened" }
    let(:result) { Google::Cloud::PubSub::PublishResult.new msg, error }

    it "knows attributes" do
      _(result.data).must_equal data
      _(result.message.data).must_equal data
      _(result.msg.data).must_equal data

      _(result.attributes.keys.sort).must_equal   attributes.keys.sort
      _(result.attributes.values.sort).must_equal attributes.values.sort
      _(result.message.attributes.keys.sort).must_equal   attributes.keys.sort
      _(result.message.attributes.values.sort).must_equal attributes.values.sort
      _(result.msg.attributes.keys.sort).must_equal   attributes.keys.sort
      _(result.msg.attributes.values.sort).must_equal attributes.values.sort

      _(result.message_id).must_be :empty?
      _(result.message.message_id).must_be :empty?
      _(result.msg.message_id).must_be :empty?

      _(result.published_at).must_be :nil?
      _(result.message.published_at).must_be :nil?
      _(result.msg.published_at).must_be :nil?

      _(result.publish_time).must_be :nil?
      _(result.message.publish_time).must_be :nil?
      _(result.msg.publish_time).must_be :nil?

      _(result.message).must_equal msg
      _(result.msg).must_equal msg

      _(result.error).must_equal error

      _(result).wont_be :succeeded?
      _(result).must_be :failed?
    end
  end
end
