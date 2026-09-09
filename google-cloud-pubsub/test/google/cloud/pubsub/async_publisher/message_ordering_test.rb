# Copyright 2019 Google LLC
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

describe Google::Cloud::PubSub::AsyncPublisher, :message_ordering, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:fixture_file_path) { File.expand_path File.join __dir__, "../../../../conformance/ordered_messages.json" }
  let(:fixture) { JSON.parse File.read(fixture_file_path), symbolize_names: true }
  let(:fixture_expected_hash) { Hash[fixture[:expected].map { |exp| [exp[:key],  exp[:messages]] }] }

  it "publishes messages with ordering_key" do
    pubsub.service.mocked_topic_admin = AsyncPublisherStub.new

    publisher = Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service, interval: 30
    publisher.enable_message_ordering!
    assert publisher.message_ordering?

    fixture[:input].each do |msg|
      publisher.publish msg[:message], ordering_key: msg[:key]
    end

    _(publisher).must_be :started?
    _(publisher).wont_be :stopped?

    # force the queued messages to be published
    publisher.stop!

    _(publisher).wont_be :started?
    _(publisher).must_be :stopped?

    published_messages_hash = pubsub.service.mocked_topic_admin.message_hash
    assert_equal fixture_expected_hash.keys.sort, published_messages_hash.keys.sort
    fixture_expected_hash.each do |key, messages|
      assert_equal messages.count, published_messages_hash[key].count, "Message count for #{key} is incorrect"
      assert_equal messages, published_messages_hash[key].map(&:data), "Messages for #{key} is incorrect"
    end
  end

  it "publishes messages with ordering_key and callback" do
    pubsub.service.mocked_topic_admin = AsyncPublisherStub.new

    publisher = Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service, interval: 30
    publisher.enable_message_ordering!
    assert publisher.message_ordering?

    fixture[:input].each do |msg|
      publisher.publish msg[:message], ordering_key: msg[:key] do |publish_result|
        raise publish_result.error if publish_result.failed?
      end
    end

    _(publisher).must_be :started?
    _(publisher).wont_be :stopped?

    # force the queued messages to be published
    publisher.stop!

    _(publisher).wont_be :started?
    _(publisher).must_be :stopped?

    published_messages_hash = pubsub.service.mocked_topic_admin.message_hash
    assert_equal fixture_expected_hash.keys.sort, published_messages_hash.keys.sort
    fixture_expected_hash.each do |key, messages|
      assert_equal messages.count, published_messages_hash[key].count, "Message count for #{key} is incorrect"
      assert_equal messages, published_messages_hash[key].map(&:data), "Messages for #{key} is incorrect"
    end
  end

  it "publishes messages with ordering_key provided only when needed" do
    pubsub.service.mocked_topic_admin = AsyncPublisherStub.new

    publisher = Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service, interval: 30
    publisher.enable_message_ordering!
    assert publisher.message_ordering?

    fixture[:input].each do |msg|
      if msg[:key].empty?
        publisher.publish msg[:message]
      else
        publisher.publish msg[:message], ordering_key: msg[:key]
      end
    end

    _(publisher).must_be :started?
    _(publisher).wont_be :stopped?

    # force the queued messages to be published
    publisher.stop!

    _(publisher).wont_be :started?
    _(publisher).must_be :stopped?

    published_messages_hash = pubsub.service.mocked_topic_admin.message_hash
    assert_equal fixture_expected_hash.keys.sort, published_messages_hash.keys.sort
    fixture_expected_hash.each do |key, messages|
      assert_equal messages.count, published_messages_hash[key].count, "Message count for #{key} is incorrect"
      assert_equal messages, published_messages_hash[key].map(&:data), "Messages for #{key} is incorrect"
    end
  end

  it "publishes messages with ordering_key in reverse order" do
    pubsub.service.mocked_topic_admin = AsyncPublisherStub.new

    publisher = Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service, interval: 30
    publisher.enable_message_ordering!
    assert publisher.message_ordering?

    fixture[:input].reverse.each do |msg|
      publisher.publish msg[:message], ordering_key: msg[:key]
    end

    _(publisher).must_be :started?
    _(publisher).wont_be :stopped?

    # force the queued messages to be published
    publisher.stop!

    _(publisher).wont_be :started?
    _(publisher).must_be :stopped?

    published_messages_hash = pubsub.service.mocked_topic_admin.message_hash
    assert_equal fixture_expected_hash.keys.sort, published_messages_hash.keys.sort
    fixture_expected_hash.each do |key, messages|
      assert_equal messages.count, published_messages_hash[key].count, "Message count for #{key} is incorrect"
      assert_equal messages.reverse, published_messages_hash[key].map(&:data), "Messages for #{key} is incorrect"
    end
  end

  it "publishes messages with ordering_key with a low max_messages" do
    pubsub.service.mocked_topic_admin = AsyncPublisherStub.new

    publisher = Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service, interval: 30, max_messages: 100
    publisher.enable_message_ordering!
    assert publisher.message_ordering?

    fixture[:input].each do |msg|
      publisher.publish msg[:message], ordering_key: msg[:key]
    end

    _(publisher).must_be :started?
    _(publisher).wont_be :stopped?

    # force the queued messages to be published
    publisher.stop!

    _(publisher).wont_be :started?
    _(publisher).must_be :stopped?

    published_messages_hash = pubsub.service.mocked_topic_admin.message_hash
    assert_equal fixture_expected_hash.keys.sort, published_messages_hash.keys.sort
    fixture_expected_hash.each do |key, messages|
      assert_equal messages.count, published_messages_hash[key].count, "Message count for #{key} is incorrect"
      assert_equal messages, published_messages_hash[key].map(&:data), "Messages for #{key} is incorrect"
    end
  end

  it "raises when ordered messages is not yet enabled" do
    publisher = Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service
    refute publisher.message_ordering?

    assert_raises Google::Cloud::PubSub::OrderedMessagesDisabled do
      publisher.publish "ordered message", ordering_key: "123"
    end
  end

  it "publishes messages with ordering_key and flow_controller" do
    pubsub.service.mocked_topic_admin = AsyncPublisherStub.new

    flow_control = {
      message_limit: 1000,
      byte_limit: 7 * 3,
      limit_exceeded_behavior: :error
    }
    publisher = Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service, interval: 30, flow_control: flow_control
    publisher.enable_message_ordering!

    _(publisher.flow_controller.outstanding_bytes).must_equal 0

    # Create batch for ordering key.
    publisher.publish "a", ordering_key: "k1" # Acquires flow controller permit for 7 bytes.
    _(publisher.flow_controller.outstanding_bytes).must_equal 7

    # 25 is too many bytes, cancels batch for ordering key, releases the flow controller permit for "a".
    flow_callback_called = true
    expect do
      publisher.publish "bbbbbbbbbbbbbbbbbbb", ordering_key: "k1" do |result|
        assert_kind_of Google::Cloud::PubSub::FlowControlLimitError, result.error
        flow_callback_called = true
      end
    end.must_raise Google::Cloud::PubSub::FlowControlLimitError
    _(publisher.flow_controller.outstanding_bytes).must_equal 0
    _(flow_callback_called).must_equal true

    # Acquires flow controller permit for 7 bytes, but batch for ordering key is still cancelled.
    # The raise also releases the flow controller permit for "c".
    ordering_callback_called = true
    err = expect do
      publisher.publish "c", ordering_key: "k1" do |result|
        assert_kind_of Google::Cloud::PubSub::OrderingKeyError, result.error
        ordering_callback_called = true
      end
    end.must_raise Google::Cloud::PubSub::OrderingKeyError
    _(err.message).must_equal "Can't publish message using k1."
    _(publisher.flow_controller.outstanding_bytes).must_equal 0
    _(ordering_callback_called).must_equal true

    # Reset the batch and try again.
    publisher.resume_publish "k1"

    publisher.publish "a", ordering_key: "k1" # Acquires flow controller permit for 7 bytes.
    publisher.publish "b", ordering_key: "k1" # Acquires flow controller permit for 7 bytes.
    publisher.publish "c", ordering_key: "k1" # Acquires flow controller permit for 7 bytes.

    _(publisher.flow_controller.outstanding_bytes).must_equal 7 * 3

    # force the queued messages to be published
    publisher.stop!

    _(publisher.flow_controller.outstanding_bytes).must_equal 0

    published_messages_hash = pubsub.service.mocked_topic_admin.message_hash
    assert_equal ["a","b","c"], published_messages_hash["k1"].map(&:data)
  end
end
