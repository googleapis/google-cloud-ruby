# Copyright 2017 Google Inc. All rights reserved.
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

describe Google::Cloud::Pubsub::Publisher, :mock_pubsub do
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

    publisher = Google::Cloud::Pubsub::Publisher.new pubsub.service
    publisher.start

    publisher.publish topic_name, message1

    publisher.queue.wont_be :empty?
    publisher.queue.keys.must_equal [topic_path(topic_name)]
    publisher.queue[topic_path(topic_name)].messages.must_equal messages
    publisher.queue[topic_path(topic_name)].callbacks.must_equal [nil]

    publisher.must_be :started?
    publisher.wont_be :stopped?

    # force the queued messages to be published
    publisher.stop
    publisher.wait

    publisher.wont_be :started?
    publisher.must_be :stopped?

    # shut down the thread pool to ensure all the tasks are completed
    publisher.thread_pool.shutdown
    publisher.thread_pool.wait_for_termination

    publisher.queue.must_be :empty?

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

    publisher = Google::Cloud::Pubsub::Publisher.new pubsub.service
    publisher.start

    publisher.publish topic_name, message1, format: :text

    publisher.queue.wont_be :empty?
    publisher.queue.keys.must_equal [topic_path(topic_name)]
    publisher.queue[topic_path(topic_name)].messages.must_equal messages
    publisher.queue[topic_path(topic_name)].callbacks.must_equal [nil]

    publisher.must_be :started?
    publisher.wont_be :stopped?

    # force the queued messages to be published
    publisher.stop
    publisher.wait

    publisher.wont_be :started?
    publisher.must_be :stopped?

    # shut down the thread pool to ensure all the tasks are completed
    publisher.thread_pool.shutdown
    publisher.thread_pool.wait_for_termination

    publisher.queue.must_be :empty?

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

    publisher = Google::Cloud::Pubsub::Publisher.new pubsub.service
    publisher.start

    callback_called = false

    publisher.publish topic_name, message1 do |result|
      assert_kind_of Google::Cloud::Pubsub::PublishResult, result
      callback_called = true
    end

    publisher.queue.wont_be :empty?
    publisher.queue.keys.must_equal [topic_path(topic_name)]
    publisher.queue[topic_path(topic_name)].messages.must_equal messages
    publisher.queue[topic_path(topic_name)].callbacks.count.must_equal 1
    publisher.queue[topic_path(topic_name)].callbacks.each do |block|
      block.must_be_kind_of Proc
    end

    publisher.must_be :started?
    publisher.wont_be :stopped?

    # force the queued messages to be published
    publisher.stop
    publisher.wait

    publisher.wont_be :started?
    publisher.must_be :stopped?

    # shut down the thread pool to ensure all the tasks are completed
    publisher.thread_pool.shutdown
    publisher.thread_pool.wait_for_termination

    publisher.queue.must_be :empty?
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

    publisher = Google::Cloud::Pubsub::Publisher.new pubsub.service
    publisher.start

    publisher.publish topic_name, message1
    publisher.publish topic_name, message2
    publisher.publish topic_name, message3, format: :none

    publisher.queue.wont_be :empty?
    publisher.queue.keys.must_equal [topic_path(topic_name)]
    publisher.queue[topic_path(topic_name)].messages.must_equal messages
    publisher.queue[topic_path(topic_name)].callbacks.must_equal [nil, nil, nil]

    publisher.must_be :started?
    publisher.wont_be :stopped?

    # force the queued messages to be published
    publisher.stop
    publisher.wait

    publisher.wont_be :started?
    publisher.must_be :stopped?

    # shut down the thread pool to ensure all the tasks are completed
    publisher.thread_pool.shutdown
    publisher.thread_pool.wait_for_termination

    publisher.queue.must_be :empty?

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

    publisher = Google::Cloud::Pubsub::Publisher.new pubsub.service
    publisher.start

    callback_count = 0

    publisher.publish topic_name, message1 do |result|
      assert_kind_of Google::Cloud::Pubsub::PublishResult, result
      callback_count += 1
    end
    publisher.publish topic_name, message2 do |result|
      assert_kind_of Google::Cloud::Pubsub::PublishResult, result
      callback_count += 1
    end
    publisher.publish topic_name, message3, format: :none do |result|
      assert_kind_of Google::Cloud::Pubsub::PublishResult, result
      callback_count += 1
    end

    publisher.queue.wont_be :empty?
    publisher.queue.keys.must_equal [topic_path(topic_name)]
    publisher.queue[topic_path(topic_name)].messages.must_equal messages
    publisher.queue[topic_path(topic_name)].callbacks.count.must_equal 3
    publisher.queue[topic_path(topic_name)].callbacks.each do |block|
      block.must_be_kind_of Proc
    end

    publisher.must_be :started?
    publisher.wont_be :stopped?

    # force the queued messages to be published
    publisher.stop
    publisher.wait

    publisher.wont_be :started?
    publisher.must_be :stopped?

    # shut down the thread pool to ensure all the tasks are completed
    publisher.thread_pool.shutdown
    publisher.thread_pool.wait_for_termination

    publisher.queue.must_be :empty?
    callback_count.must_equal 3

    mock.verify
  end

  it "publishes multiple messages to different topics" do
    messages1 = [
      Google::Pubsub::V1::PubsubMessage.new(data: msg_encoded1),
      Google::Pubsub::V1::PubsubMessage.new(data: msg_encoded2)
    ]
    messages2 = [
      Google::Pubsub::V1::PubsubMessage.new(data: msg_encoded3, attributes: {"format" => "none"})
    ]
    publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: ["msg1", "msg2", "msg3"] }.to_json)
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [topic_path(topic_name), messages1, options: default_options]
    mock.expect :publish, publish_res, [topic_path(topic_name2), messages2, options: default_options]
    pubsub.service.mocked_publisher = mock

    publisher = Google::Cloud::Pubsub::Publisher.new pubsub.service
    publisher.start

    publisher.publish topic_name, message1
    publisher.publish topic_name, message2
    publisher.publish topic_name2, message3, format: :none

    publisher.queue.wont_be :empty?
    publisher.queue.keys.must_equal [topic_path(topic_name), topic_path(topic_name2)]
    publisher.queue[topic_path(topic_name)].messages.must_equal messages1
    publisher.queue[topic_path(topic_name)].callbacks.must_equal [nil, nil]
    publisher.queue[topic_path(topic_name2)].messages.must_equal messages2
    publisher.queue[topic_path(topic_name2)].callbacks.must_equal [nil]

    publisher.must_be :started?
    publisher.wont_be :stopped?

    # force the queued messages to be published
    publisher.stop
    publisher.wait

    publisher.wont_be :started?
    publisher.must_be :stopped?

    # shut down the thread pool to ensure all the tasks are completed
    publisher.thread_pool.shutdown
    publisher.thread_pool.wait_for_termination

    publisher.queue.must_be :empty?

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

    publisher = Google::Cloud::Pubsub::Publisher.new pubsub.service, max_messages: 10
    # Don't start the timer so we don't interfere with the limit calculations

    30.times do
      publisher.publish topic_name, message1
    end

    publisher.queue.wont_be :empty?
    publisher.queue.keys.must_equal [topic_path(topic_name)]
    publisher.queue[topic_path(topic_name)].messages.must_equal messages
    publisher.queue[topic_path(topic_name)].callbacks.must_equal [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]

    # flush the 3rd batch
    publisher.flush

    # shut down the thread pool to ensure all the tasks are completed
    publisher.thread_pool.shutdown
    publisher.thread_pool.wait_for_termination

    publisher.queue.must_be :empty?

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
    publisher = Google::Cloud::Pubsub::Publisher.new pubsub.service, max_bytes: 190
    # Don't start the timer so we don't interfere with the limit calculations

    30.times do
      publisher.publish topic_name, message1
    end

    publisher.queue.wont_be :empty?
    publisher.queue.keys.must_equal [topic_path(topic_name)]
    publisher.queue[topic_path(topic_name)].messages.must_equal messages
    publisher.queue[topic_path(topic_name)].callbacks.must_equal [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]

    # flush the 3rd batch
    publisher.flush

    # shut down the thread pool to ensure all the tasks are completed
    publisher.thread_pool.shutdown
    publisher.thread_pool.wait_for_termination

    publisher.queue.must_be :empty?

    mock.verify
  end
end
