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

Thread.abort_on_exception = true

describe Google::Cloud::Pubsub::AsyncPublisher, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:topic_name2) { "differnt-topic-name" }
  let(:message1) { "new-message-here" }
  let(:message2) { "second-new-message" }
  let(:message3) { "third-new-message" }
  let(:msg_encoded1) { message1.encode("ASCII-8BIT") }
  let(:msg_encoded2) { message2.encode("ASCII-8BIT") }
  let(:msg_encoded3) { message3.encode("ASCII-8BIT") }

  it "publishes a message" do
    messages = [
      Google::Pubsub::V1::PubsubMessage.new(data: msg_encoded1)
    ]
    publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: ["msg1"] }.to_json)
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [topic_path(topic_name), messages, options: default_options]
    pubsub.service.mocked_publisher = mock

    publisher = Google::Cloud::Pubsub::AsyncPublisher.new topic_name, pubsub.service, interval: 10

    publisher.publish message1

    publisher.batch.messages.must_equal messages
    publisher.batch.callbacks.must_equal [nil]

    publisher.must_be :started?
    publisher.wont_be :stopped?

    # force the queued messages to be published
    publisher.stop.wait!

    publisher.wont_be :started?
    publisher.must_be :stopped?

    publisher.batch.must_be :nil?

    mock.verify
  end

  it "publishes a message with attributes" do
    messages = [
      Google::Pubsub::V1::PubsubMessage.new(data: msg_encoded1, attributes: {"format" => "text"})
    ]
    publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: ["msg1"] }.to_json)
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [topic_path(topic_name), messages, options: default_options]
    pubsub.service.mocked_publisher = mock

    publisher = Google::Cloud::Pubsub::AsyncPublisher.new topic_name, pubsub.service, interval: 10

    publisher.publish message1, format: :text

    publisher.batch.messages.must_equal messages
    publisher.batch.callbacks.must_equal [nil]

    publisher.must_be :started?
    publisher.wont_be :stopped?

    # force the queued messages to be published
    publisher.stop.wait!

    publisher.wont_be :started?
    publisher.must_be :stopped?

    publisher.batch.must_be :nil?

    mock.verify
  end

  it "publishes a message with a callback" do
    messages = [
      Google::Pubsub::V1::PubsubMessage.new(data: msg_encoded1)
    ]
    publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: ["msg1"] }.to_json)
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [topic_path(topic_name), messages, options: default_options]
    pubsub.service.mocked_publisher = mock

    publisher = Google::Cloud::Pubsub::AsyncPublisher.new topic_name, pubsub.service, interval: 10

    callback_called = false

    publisher.publish message1 do |result|
      assert_kind_of Google::Cloud::Pubsub::PublishResult, result
      callback_called = true
    end

    publisher.batch.messages.must_equal messages
    publisher.batch.callbacks.count.must_equal 1
    publisher.batch.callbacks.each do |block|
      block.must_be_kind_of Proc
    end

    publisher.must_be :started?
    publisher.wont_be :stopped?

    # force the queued messages to be published
    publisher.stop.wait!

    publisher.wont_be :started?
    publisher.must_be :stopped?

    publisher.batch.must_be :nil?
    callback_called.must_equal true

    mock.verify
  end

  it "publishes multiple messages" do
    messages = [
      Google::Pubsub::V1::PubsubMessage.new(data: msg_encoded1),
      Google::Pubsub::V1::PubsubMessage.new(data: msg_encoded2),
      Google::Pubsub::V1::PubsubMessage.new(data: msg_encoded3, attributes: {"format" => "none"})
    ]
    publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: ["msg1", "msg2", "msg3"] }.to_json)
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [topic_path(topic_name), messages, options: default_options]
    pubsub.service.mocked_publisher = mock

    publisher = Google::Cloud::Pubsub::AsyncPublisher.new topic_name, pubsub.service, interval: 10

    publisher.publish message1
    publisher.publish message2
    publisher.publish message3, format: :none

    publisher.batch.messages.must_equal messages
    publisher.batch.callbacks.must_equal [nil, nil, nil]

    publisher.must_be :started?
    publisher.wont_be :stopped?

    # force the queued messages to be published
    publisher.stop.wait!

    publisher.wont_be :started?
    publisher.must_be :stopped?

    publisher.batch.must_be :nil?

    mock.verify
  end

  it "publishes multiple messages with callbacks" do
    messages = [
      Google::Pubsub::V1::PubsubMessage.new(data: msg_encoded1),
      Google::Pubsub::V1::PubsubMessage.new(data: msg_encoded2),
      Google::Pubsub::V1::PubsubMessage.new(data: msg_encoded3, attributes: {"format" => "none"})
    ]
    publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: ["msg1", "msg2", "msg3"] }.to_json)
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [topic_path(topic_name), messages, options: default_options]
    pubsub.service.mocked_publisher = mock

    publisher = Google::Cloud::Pubsub::AsyncPublisher.new topic_name, pubsub.service, interval: 10

    callback_count = 0

    publisher.publish message1 do |result|
      assert_kind_of Google::Cloud::Pubsub::PublishResult, result
      callback_count += 1
    end
    publisher.publish message2 do |result|
      assert_kind_of Google::Cloud::Pubsub::PublishResult, result
      callback_count += 1
    end
    publisher.publish message3, format: :none do |result|
      assert_kind_of Google::Cloud::Pubsub::PublishResult, result
      callback_count += 1
    end

    publisher.batch.messages.must_equal messages
    publisher.batch.callbacks.count.must_equal 3
    publisher.batch.callbacks.each do |block|
      block.must_be_kind_of Proc
    end

    publisher.must_be :started?
    publisher.wont_be :stopped?

    # force the queued messages to be published
    publisher.stop.wait!

    publisher.wont_be :started?
    publisher.must_be :stopped?

    publisher.batch.must_be :nil?
    callback_count.must_equal 3

    mock.verify
  end

  it "publishes multiple batches when message count limit is reached" do
    messages = 10.times.map do
      Google::Pubsub::V1::PubsubMessage.new(data: msg_encoded1)
    end
    message_ids = 10.times.map do |i|
      "msg#{i}"
    end
    publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: message_ids }.to_json)
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [topic_path(topic_name), messages, options: default_options]
    mock.expect :publish, publish_res, [topic_path(topic_name), messages, options: default_options]
    mock.expect :publish, publish_res, [topic_path(topic_name), messages, options: default_options]
    pubsub.service.mocked_publisher = mock

    publisher = Google::Cloud::Pubsub::AsyncPublisher.new topic_name, pubsub.service, max_messages: 10, interval: 10

    callbacks = 0

    30.times do
      publisher.publish message1 do |msg|
        callbacks += 1
      end
    end

    # batch was published immediately when ready
    publisher.batch.must_be :nil?

    publisher.must_be :started?
    publisher.wont_be :stopped?

    # force the queued messages to be published
    wait_until { callbacks == 30 }

    publisher.stop.wait!

    publisher.wont_be :started?
    publisher.must_be :stopped?

    publisher.batch.must_be :nil?

    callbacks.must_equal 30

    mock.verify
  end

  it "publishes multiple batches when message size limit is reached" do
    messages = 10.times.map do
      Google::Pubsub::V1::PubsubMessage.new(data: msg_encoded1)
    end
    message_ids = 10.times.map do |i|
      "msg#{i}"
    end
    publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: message_ids }.to_json)
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [topic_path(topic_name), messages, options: default_options]
    mock.expect :publish, publish_res, [topic_path(topic_name), messages, options: default_options]
    mock.expect :publish, publish_res, [topic_path(topic_name), messages, options: default_options]
    pubsub.service.mocked_publisher = mock

    # 190 is bigger than 10 messages, but less than 11.
    publisher = Google::Cloud::Pubsub::AsyncPublisher.new topic_name, pubsub.service, max_bytes: 250, interval: 10

    callbacks = 0

    30.times do
      publisher.publish message1 do |msg|
        callbacks += 1
      end
    end

    # messages in the batch are:
    publisher.batch.messages.must_equal messages
    publisher.batch.callbacks.count.must_equal 10

    publisher.must_be :started?
    publisher.wont_be :stopped?

    # force the queued messages to be published
    publisher.flush
    wait_until { callbacks == 30 }

    publisher.stop.wait!

    publisher.wont_be :started?
    publisher.must_be :stopped?

    publisher.batch.must_be :nil?

    callbacks.must_equal 30

    mock.verify
  end

  it "publishes when message size is greater than the limit" do
    skip "this test is problematic on CI"
    message = Google::Pubsub::V1::PubsubMessage.new(data: msg_encoded1)
    message_id = "msg1"
    big_msg_data = SecureRandom.random_bytes 120
    big_message = Google::Pubsub::V1::PubsubMessage.new(data: big_msg_data)
    big_message_id = "msg999"

    publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: [message_id] }.to_json)
    big_publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: [big_message_id] }.to_json)
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [topic_path(topic_name), [message], options: default_options]
    mock.expect :publish, big_publish_res, [topic_path(topic_name), [big_message], options: default_options]
    pubsub.service.mocked_publisher = mock

    # 190 is bigger than 10 messages, but less than 11.
    publisher = Google::Cloud::Pubsub::AsyncPublisher.new topic_name, pubsub.service, max_bytes: 100

    callbacks = 0

    publisher.publish message1 do |msg|
      callbacks += 1
    end
    publisher.publish big_msg_data do |msg|
      callbacks += 1
    end

    # Batch is nil because the second message published immediately
    publisher.batch.must_be :nil?

    publisher.must_be :started?
    publisher.wont_be :stopped?

    wait_until { callbacks == 2 }

    publisher.stop.wait!

    publisher.wont_be :started?
    publisher.must_be :stopped?

    publisher.batch.must_be :nil?

    callbacks.must_equal 2

    mock.verify
  end

  def wait_until delay: 0.01, max: 10, output: nil, msg: "criteria not met", &block
    attempts = 0
    while !block.call
      fail msg if attempts >= max
      attempts += 1
      puts "Retrying #{attempts} out of #{max}." if output
      sleep delay
    end
  end
end
