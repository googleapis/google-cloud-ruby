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

describe Google::Cloud::PubSub::Publisher, :publish_async, :ordered_messages, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:topic_grpc) { Google::Cloud::PubSub::V1::Topic.new(topic_hash(topic_name)) }
  let(:publisher) { Google::Cloud::PubSub::Publisher.from_grpc topic_grpc, pubsub.service, async: { interval: 10 } }
  let(:publisher_low_max_messages) do
    Google::Cloud::PubSub::Publisher.from_grpc topic_grpc, pubsub.service, async: { max_messages: 100, interval: 30 }
  end

  let(:fixture_file_path) { File.expand_path File.join __dir__, "../../../../conformance/ordered_messages.json" }
  let(:fixture) { JSON.parse File.read(fixture_file_path), symbolize_names: true }
  let(:fixture_expected_hash) { Hash[fixture[:expected].map { |exp| [exp[:key],  exp[:messages]] }] }

  it "publishes messages with ordering_key" do
    publisher.service.mocked_publisher = AsyncPublisherStub.new

    publisher.enable_message_ordering!
    assert publisher.message_ordering?

    fixture[:input].each do |msg|
      publisher.publish_async msg[:message], ordering_key: msg[:key]
    end

    _(publisher.async_publisher).must_be :started?
    _(publisher.async_publisher).wont_be :stopped?

    # force the queued messages to be published
    publisher.async_publisher.stop!

    _(publisher.async_publisher).wont_be :started?
    _(publisher.async_publisher).must_be :stopped?

    published_messages_hash = publisher.service.mocked_publisher.message_hash
    assert_equal fixture_expected_hash.keys.sort, published_messages_hash.keys.sort
    fixture_expected_hash.each do |key, messages|
      assert_equal messages.count, published_messages_hash[key].count, "Message count for #{key} is incorrect"
      assert_equal messages, published_messages_hash[key].map(&:data), "Messages for #{key} is incorrect"
    end
  end

  it "publishes messages with ordering_key and callback" do
    publisher.service.mocked_publisher = AsyncPublisherStub.new

    publisher.enable_message_ordering!
    assert publisher.message_ordering?

    fixture[:input].each do |msg|
      publisher.publish_async msg[:message], ordering_key: msg[:key] do |publish_result|
        raise publish_result.error if publish_result.failed?
      end
    end

    _(publisher.async_publisher).must_be :started?
    _(publisher.async_publisher).wont_be :stopped?

    # force the queued messages to be published
    publisher.async_publisher.stop!

    _(publisher.async_publisher).wont_be :started?
    _(publisher.async_publisher).must_be :stopped?

    published_messages_hash = publisher.service.mocked_publisher.message_hash
    assert_equal fixture_expected_hash.keys.sort, published_messages_hash.keys.sort
    fixture_expected_hash.each do |key, messages|
      assert_equal messages.count, published_messages_hash[key].count, "Message count for #{key} is incorrect"
      assert_equal messages, published_messages_hash[key].map(&:data), "Messages for #{key} is incorrect"
    end
  end

  it "publishes messages with ordering_key provided only when needed" do
    publisher.service.mocked_publisher = AsyncPublisherStub.new

    publisher.enable_message_ordering!
    assert publisher.message_ordering?

    fixture[:input].each do |msg|
      if msg[:key].empty?
        publisher.publish_async msg[:message]
      else
        publisher.publish_async msg[:message], ordering_key: msg[:key]
      end
    end

    _(publisher.async_publisher).must_be :started?
    _(publisher.async_publisher).wont_be :stopped?

    # force the queued messages to be published
    publisher.async_publisher.stop!

    _(publisher.async_publisher).wont_be :started?
    _(publisher.async_publisher).must_be :stopped?

    published_messages_hash = publisher.service.mocked_publisher.message_hash
    assert_equal fixture_expected_hash.keys.sort, published_messages_hash.keys.sort
    fixture_expected_hash.each do |key, messages|
      assert_equal messages.count, published_messages_hash[key].count, "Message count for #{key} is incorrect"
      assert_equal messages, published_messages_hash[key].map(&:data), "Messages for #{key} is incorrect"
    end
  end

  it "publishes messages with ordering_key in reverse order" do
    publisher.service.mocked_publisher = AsyncPublisherStub.new

    publisher.enable_message_ordering!
    assert publisher.message_ordering?

    fixture[:input].reverse.each do |msg|
      publisher.publish_async msg[:message], ordering_key: msg[:key]
    end

    _(publisher.async_publisher).must_be :started?
    _(publisher.async_publisher).wont_be :stopped?

    # force the queued messages to be published
    publisher.async_publisher.stop!

    _(publisher.async_publisher).wont_be :started?
    _(publisher.async_publisher).must_be :stopped?

    published_messages_hash = publisher.service.mocked_publisher.message_hash
    assert_equal fixture_expected_hash.keys.sort, published_messages_hash.keys.sort
    fixture_expected_hash.each do |key, messages|
      assert_equal messages.count, published_messages_hash[key].count, "Message count for #{key} is incorrect"
      assert_equal messages.reverse, published_messages_hash[key].map(&:data), "Messages for #{key} is incorrect"
    end
  end

  it "publishes messages with ordering_key with a low max_messages" do
    publisher_low_max_messages.service.mocked_publisher = AsyncPublisherStub.new

    publisher_low_max_messages.enable_message_ordering!
    assert publisher_low_max_messages.message_ordering?
    _(publisher_low_max_messages.async_publisher.max_messages).must_equal 100
    _(publisher_low_max_messages.async_publisher.interval).must_equal 30

    fixture[:input].each do |msg|
      publisher_low_max_messages.publish_async msg[:message], ordering_key: msg[:key]
    end

    _(publisher_low_max_messages.async_publisher).must_be :started?
    _(publisher_low_max_messages.async_publisher).wont_be :stopped?

    # force the queued messages to be published
    publisher_low_max_messages.async_publisher.stop!

    _(publisher_low_max_messages.async_publisher).wont_be :started?
    _(publisher_low_max_messages.async_publisher).must_be :stopped?

    published_messages_hash = publisher_low_max_messages.service.mocked_publisher.message_hash
    assert_equal fixture_expected_hash.keys.sort, published_messages_hash.keys.sort
    fixture_expected_hash.each do |key, messages|
      assert_equal messages.count, published_messages_hash[key].count, "Message count for #{key} is incorrect"
      assert_equal messages, published_messages_hash[key].map(&:data), "Messages for #{key} is incorrect"
    end
  end

  it "raises when ordered messages is not yet enabled" do
    refute publisher_low_max_messages.message_ordering?

    assert_raises Google::Cloud::PubSub::OrderedMessagesDisabled do
      publisher_low_max_messages.publish_async "ordered message", ordering_key: "123"
    end
  end
end
