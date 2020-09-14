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

describe Google::Cloud::PubSub::Topic, :publish_async, :ordered_messages, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:topic) { Google::Cloud::PubSub::Topic.from_grpc Google::Cloud::PubSub::V1::Topic.new(topic_hash(topic_name)), pubsub.service, async: { interval: 10 } }

  let(:fixture_file_path) { File.expand_path File.join __dir__, "../../../../conformance/ordered_messages.json" }
  let(:fixture) { JSON.parse File.read(fixture_file_path), symbolize_names: true }
  let(:fixture_expected_hash) { Hash[fixture[:expected].map { |exp| [exp[:key],  exp[:messages]] }] }

  it "publishes messages with ordering_key" do
    topic.service.mocked_publisher = AsyncPublisherStub.new

    topic.enable_message_ordering!
    assert topic.message_ordering?

    fixture[:input].each do |msg|
      topic.publish_async msg[:message], ordering_key: msg[:key]
    end

    _(topic.async_publisher).must_be :started?
    _(topic.async_publisher).wont_be :stopped?

    # force the queued messages to be published
    topic.async_publisher.stop!

    _(topic.async_publisher).wont_be :started?
    _(topic.async_publisher).must_be :stopped?

    published_messages_hash = topic.service.mocked_publisher.message_hash
    assert_equal fixture_expected_hash.keys.sort, published_messages_hash.keys.sort
    fixture_expected_hash.each do |key, messages|
      assert_equal messages.count, published_messages_hash[key].count, "Message count for #{key} is incorrect"
      assert_equal messages, published_messages_hash[key].map(&:data), "Messages for #{key} is incorrect"
    end
  end

  it "publishes messages with ordering_key and callback" do
    topic.service.mocked_publisher = AsyncPublisherStub.new

    topic.enable_message_ordering!
    assert topic.message_ordering?

    fixture[:input].each do |msg|
      topic.publish_async msg[:message], ordering_key: msg[:key] do |publish_result|
        raise publish_result.error if publish_result.failed?
      end
    end

    _(topic.async_publisher).must_be :started?
    _(topic.async_publisher).wont_be :stopped?

    # force the queued messages to be published
    topic.async_publisher.stop!

    _(topic.async_publisher).wont_be :started?
    _(topic.async_publisher).must_be :stopped?

    published_messages_hash = topic.service.mocked_publisher.message_hash
    assert_equal fixture_expected_hash.keys.sort, published_messages_hash.keys.sort
    fixture_expected_hash.each do |key, messages|
      assert_equal messages.count, published_messages_hash[key].count, "Message count for #{key} is incorrect"
      assert_equal messages, published_messages_hash[key].map(&:data), "Messages for #{key} is incorrect"
    end
  end

  it "publishes messages with ordering_key provided only when needed" do
    topic.service.mocked_publisher = AsyncPublisherStub.new

    topic.enable_message_ordering!
    assert topic.message_ordering?

    fixture[:input].each do |msg|
      if msg[:key].empty?
        topic.publish_async msg[:message]
      else
        topic.publish_async msg[:message], ordering_key: msg[:key]
      end
    end

    _(topic.async_publisher).must_be :started?
    _(topic.async_publisher).wont_be :stopped?

    # force the queued messages to be published
    topic.async_publisher.stop!

    _(topic.async_publisher).wont_be :started?
    _(topic.async_publisher).must_be :stopped?

    published_messages_hash = topic.service.mocked_publisher.message_hash
    assert_equal fixture_expected_hash.keys.sort, published_messages_hash.keys.sort
    fixture_expected_hash.each do |key, messages|
      assert_equal messages.count, published_messages_hash[key].count, "Message count for #{key} is incorrect"
      assert_equal messages, published_messages_hash[key].map(&:data), "Messages for #{key} is incorrect"
    end
  end

  it "publishes messages with ordering_key in reverse order" do
    topic.service.mocked_publisher = AsyncPublisherStub.new

    topic.enable_message_ordering!
    assert topic.message_ordering?

    fixture[:input].reverse.each do |msg|
      topic.publish_async msg[:message], ordering_key: msg[:key]
    end

    _(topic.async_publisher).must_be :started?
    _(topic.async_publisher).wont_be :stopped?

    # force the queued messages to be published
    topic.async_publisher.stop!

    _(topic.async_publisher).wont_be :started?
    _(topic.async_publisher).must_be :stopped?

    published_messages_hash = topic.service.mocked_publisher.message_hash
    assert_equal fixture_expected_hash.keys.sort, published_messages_hash.keys.sort
    fixture_expected_hash.each do |key, messages|
      assert_equal messages.count, published_messages_hash[key].count, "Message count for #{key} is incorrect"
      assert_equal messages.reverse, published_messages_hash[key].map(&:data), "Messages for #{key} is incorrect"
    end
  end

  it "publishes messages with ordering_key with a low max_messages" do
    topic.service.mocked_publisher = AsyncPublisherStub.new

    topic.enable_message_ordering!
    assert topic.message_ordering?

    fixture[:input].each do |msg|
      topic.publish_async msg[:message], ordering_key: msg[:key]
    end

    _(topic.async_publisher).must_be :started?
    _(topic.async_publisher).wont_be :stopped?

    # force the queued messages to be published
    topic.async_publisher.stop!

    _(topic.async_publisher).wont_be :started?
    _(topic.async_publisher).must_be :stopped?

    published_messages_hash = topic.service.mocked_publisher.message_hash
    assert_equal fixture_expected_hash.keys.sort, published_messages_hash.keys.sort
    fixture_expected_hash.each do |key, messages|
      assert_equal messages.count, published_messages_hash[key].count, "Message count for #{key} is incorrect"
      assert_equal messages, published_messages_hash[key].map(&:data), "Messages for #{key} is incorrect"
    end
  end

  it "raises when ordered messages is not yet enabled" do
    refute topic.message_ordering?

    assert_raises Google::Cloud::PubSub::OrderedMessagesDisabled do
      topic.publish_async "ordered message", ordering_key: "123"
    end
  end
end
