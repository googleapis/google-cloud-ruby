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
require "ostruct"

Thread.abort_on_exception = true

describe Google::Cloud::PubSub::AsyncPublisher, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:topic_name2) { "differnt-topic-name" }
  let(:message1) { "new-message-here" }
  let(:message2) { "second-new-message" }
  let(:message3) { "third-new-message" }
  let(:msg_encoded1) { message1.encode(Encoding::ASCII_8BIT) }
  let(:msg_encoded2) { message2.encode(Encoding::ASCII_8BIT) }
  let(:msg_encoded3) { message3.encode(Encoding::ASCII_8BIT) }

  it "knows its defaults" do
    publisher = Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service
    _(publisher.max_bytes).must_equal 1_000_000
    _(publisher.max_messages).must_equal 100
    _(publisher.interval).must_equal 0.01
    _(publisher.publish_threads).must_equal 2
    _(publisher.callback_threads).must_equal 4
    _(publisher.flow_control).must_be_kind_of Hash
    _(publisher.flow_control[:message_limit]).must_equal 1000
    _(publisher.flow_control[:byte_limit]).must_equal 10000000
    _(publisher.flow_control[:limit_exceeded_behavior]).must_be :nil?
  end

  it "knows its given attributes" do
    publisher = Google::Cloud::PubSub::AsyncPublisher.new(
      topic_name,
      pubsub.service,
      max_bytes: 2_000_000,
      max_messages: 200,
      interval: 0.02,
      threads: {
        publish: 3,
        callback: 5
      }
    )

    _(publisher.max_bytes).must_equal 2_000_000
    _(publisher.max_messages).must_equal 200
    _(publisher.interval).must_equal 0.02
    _(publisher.publish_threads).must_equal 3
    _(publisher.callback_threads).must_equal 5
    _(publisher.flow_control[:message_limit]).must_equal 2000
    _(publisher.flow_control[:byte_limit]).must_equal 20000000
    _(publisher.flow_control[:limit_exceeded_behavior]).must_be :nil?
  end

  it "knows given attributes and retains its defaults" do
    publisher = Google::Cloud::PubSub::AsyncPublisher.new(
      topic_name,
      pubsub.service,
      max_bytes: 2_000_000,
      threads: {
        publish: 3
      }
    )

    _(publisher.max_bytes).must_equal 2_000_000
    _(publisher.max_messages).must_equal 100
    _(publisher.interval).must_equal 0.01
    _(publisher.publish_threads).must_equal 3
    _(publisher.callback_threads).must_equal 4
    _(publisher.flow_control[:message_limit]).must_equal 1000
    _(publisher.flow_control[:byte_limit]).must_equal 20000000
    _(publisher.flow_control[:limit_exceeded_behavior]).must_be :nil?
  end

  it "publishes a message" do
    publisher = Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service, interval: 10
    messages = [
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded1)
    ]

    publisher.service.mocked_topic_admin = AsyncPublisherStub.new

    publisher.publish message1

    _(publisher).must_be :started?
    _(publisher).wont_be :stopped?

    # force the queued messages to be published
    publisher.stop!

    _(publisher).wont_be :started?
    _(publisher).must_be :stopped?

    published_messages_hash = publisher.service.mocked_topic_admin.message_hash
    expected_messages_hash = { "" => messages }
    assert_equal expected_messages_hash, published_messages_hash
  end

  it "publishes a message with attributes" do
    publisher = Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service, interval: 10
    messages = [
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded1, attributes: {"format" => "text"})
    ]

    publisher.service.mocked_topic_admin = AsyncPublisherStub.new

    publisher.publish message1, format: :text

    _(publisher).must_be :started?
    _(publisher).wont_be :stopped?

    # force the queued messages to be published
    publisher.stop!

    _(publisher).wont_be :started?
    _(publisher).must_be :stopped?

    published_messages_hash = publisher.service.mocked_topic_admin.message_hash
    expected_messages_hash = { "" => messages }
    assert_equal expected_messages_hash, published_messages_hash
  end

  it "publishes a message with a callback" do
    publisher = Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service, interval: 10
    messages = [
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded1, message_id: "msg0")
    ]
    callback_called = false

    publisher.service.mocked_topic_admin = AsyncPublisherStub.new

    publisher.publish message1 do |result|
      assert_kind_of Google::Cloud::PubSub::PublishResult, result
      callback_called = true
    end

    _(publisher).must_be :started?
    _(publisher).wont_be :stopped?

    # force the queued messages to be published
    publisher.stop!

    _(publisher).wont_be :started?
    _(publisher).must_be :stopped?

    published_messages_hash = publisher.service.mocked_topic_admin.message_hash
    expected_messages_hash = { "" => messages }
    assert_equal expected_messages_hash, published_messages_hash
    _(callback_called).must_equal true
  end

  it "publishes multiple messages" do
    publisher = Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service, interval: 10
    messages = [
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded1),
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded2),
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded3, attributes: {"format" => "none"})
    ]

    publisher.service.mocked_topic_admin = AsyncPublisherStub.new

    publisher.publish message1
    publisher.publish message2
    publisher.publish message3, format: :none

    _(publisher).must_be :started?
    _(publisher).wont_be :stopped?

    # force the queued messages to be published
    publisher.stop!

    _(publisher).wont_be :started?
    _(publisher).must_be :stopped?

    published_messages_hash = publisher.service.mocked_topic_admin.message_hash
    expected_messages_hash = { "" => messages }
    assert_equal expected_messages_hash, published_messages_hash
  end

  it "publishes multiple messages with callbacks" do
    publisher = Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service, interval: 10
    messages = [
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded1, message_id: "msg0"),
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded2, message_id: "msg1"),
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded3, attributes: {"format" => "none"}, message_id: "msg2")
    ]
    callback_count = 0

    publisher.service.mocked_topic_admin = AsyncPublisherStub.new

    publisher.publish message1 do |result|
      assert_kind_of Google::Cloud::PubSub::PublishResult, result
      callback_count += 1
    end
    publisher.publish message2 do |result|
      assert_kind_of Google::Cloud::PubSub::PublishResult, result
      callback_count += 1
    end
    publisher.publish message3, format: :none do |result|
      assert_kind_of Google::Cloud::PubSub::PublishResult, result
      callback_count += 1
    end

    _(publisher).must_be :started?
    _(publisher).wont_be :stopped?

    # force the queued messages to be published
    publisher.stop!

    _(publisher).wont_be :started?
    _(publisher).must_be :stopped?

    published_messages_hash = publisher.service.mocked_topic_admin.message_hash
    expected_messages_hash = { "" => messages }
    assert_equal expected_messages_hash, published_messages_hash
    _(callback_count).must_equal 3
  end

  it "publishes multiple batches when message count limit is reached" do
    # break messages up into batches of 10
    publisher = Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service, max_messages: 10, interval: 10
    messages = [
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded1, message_id: "msg0")
    ]
    callback_count = 0

    publisher.service.mocked_topic_admin = AsyncPublisherStub.new

    30.times do |count|
      publisher.publish message1 do |msg|
        callback_count += 1
      end
    end

    _(publisher).must_be :started?
    _(publisher).wont_be :stopped?

    # force the queued messages to be published
    publisher.stop!

    _(publisher).wont_be :started?
    _(publisher).must_be :stopped?

    expected_messages = Array.new(3) do
      Array.new(10) do |count|
        Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded1, message_id: "msg#{count}")
      end
    end

    assert_equal expected_messages, publisher.service.mocked_topic_admin.messages
    _(callback_count).must_equal 30
  end

  it "publishes multiple batches when message size limit is reached" do
    # 250 is slightly bigger than 10 messages, and less than 11.
    publisher = Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service, max_bytes: 250, interval: 10
    messages = [
      Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded1, message_id: "msg0")
    ]
    callback_count = 0

    publisher.service.mocked_topic_admin = AsyncPublisherStub.new

    30.times do
      publisher.publish message1 do |msg|
        callback_count += 1
      end
    end

    _(publisher).must_be :started?
    _(publisher).wont_be :stopped?

    # force the queued messages to be published
    publisher.stop!

    _(publisher).wont_be :started?
    _(publisher).must_be :stopped?

    expected_messages = Array.new(3) do
      Array.new(10) do |count|
        Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded1, message_id: "msg#{count}")
      end
    end

    assert_equal expected_messages.map(&:count), publisher.service.mocked_topic_admin.messages.map(&:count)
    assert_equal expected_messages, publisher.service.mocked_topic_admin.messages
    _(callback_count).must_equal 30
  end

  it "publishes when message size is greater than the limit" do
    skip "this test is problematic on CI"
    # second message will force a separate batch
    publisher = Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service, max_bytes: 100
    big_msg_data = SecureRandom.random_bytes 120
    callback_count = 0

    publisher.service.mocked_topic_admin = AsyncPublisherStub.new

    publisher.publish message1 do |msg|
      callback_count += 1
    end
    publisher.publish big_msg_data do |msg|
      callback_count += 1
    end

    _(publisher).must_be :started?
    _(publisher).wont_be :stopped?

    # force the queued messages to be published
    publisher.stop!

    _(publisher).wont_be :started?
    _(publisher).must_be :stopped?

    expected_messages = [
      [Google::Cloud::PubSub::V1::PubsubMessage.new(data: msg_encoded1, message_id: "msg0")],
      [Google::Cloud::PubSub::V1::PubsubMessage.new(data: big_msg_data, message_id: "msg1")]
    ]
    assert_equal publisher.service.mocked_topic_admin.messages, expected_messages
    _(callback_count).must_equal 2
  end

  it "publishes multiple messages with flow control message_limit" do
    flow_control = {
      message_limit: 2,
      byte_limit: 10000000,
      limit_exceeded_behavior: :error
    }
    publisher = Google::Cloud::PubSub::AsyncPublisher.new topic_name,
                                                          pubsub.service,
                                                          interval: 10,
                                                          flow_control: flow_control

    publisher.service.mocked_topic_admin = AsyncPublisherStub.new

    _(publisher.flow_controller.outstanding_messages).must_equal 0

    publisher.publish "a"
    _(publisher.flow_controller.outstanding_messages).must_equal 1

    publisher.publish "b"
    _(publisher.flow_controller.outstanding_messages).must_equal 2 # Limit

    callback_called = true
    expect do
      publisher.publish "c" do |result|
        assert_kind_of Google::Cloud::PubSub::FlowControlLimitError, result.error
        callback_called = true
      end
    end.must_raise Google::Cloud::PubSub::FlowControlLimitError
    _(callback_called).must_equal true

    # force the queued messages to be published
    publisher.stop!

    _(publisher.flow_controller.outstanding_messages).must_equal 0

    published_messages_hash = publisher.service.mocked_topic_admin.message_hash
    assert_equal ["a","b"], published_messages_hash[""].map(&:data)
  end

  it "publishes multiple messages with flow control byte_limit" do
    flow_control = {
      message_limit: 1000,
      byte_limit: 3 * 2,
      limit_exceeded_behavior: :error
    }
    publisher = Google::Cloud::PubSub::AsyncPublisher.new topic_name,
                                                          pubsub.service,
                                                          interval: 10,
                                                          flow_control: flow_control

    publisher.service.mocked_topic_admin = AsyncPublisherStub.new

    _(publisher.flow_controller.outstanding_bytes).must_equal 0

    publisher.publish "a"
    _(publisher.flow_controller.outstanding_bytes).must_equal 3

    publisher.publish "b"
    _(publisher.flow_controller.outstanding_bytes).must_equal 3 * 2 # Limit

    callback_called = true
    expect do
      publisher.publish "c" do |result|
        assert_kind_of Google::Cloud::PubSub::FlowControlLimitError, result.error
        callback_called = true
      end
    end.must_raise Google::Cloud::PubSub::FlowControlLimitError

    # force the queued messages to be published
    publisher.stop!

    _(publisher.flow_controller.outstanding_bytes).must_equal 0

    published_messages_hash = publisher.service.mocked_topic_admin.message_hash
    assert_equal ["a","b"], published_messages_hash[""].map(&:data)
    _(callback_called).must_equal true
  end

  it "passes compress true to service when compress enabled and size above default threshold" do
    publisher = Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service, compress: true
    mocked_topic_admin = Minitest::Mock.new
    expected_request = {topic: "projects/test/topics/#{topic_name}", messages: ["data"]}
    expected_option = ::Gapic::CallOptions.new metadata: { "grpc-internal-encoding-request": "gzip" }
    actual_request = nil
    actual_option = nil
    mocked_topic_admin.expect :publish_internal, nil do |request, option|
      actual_request = request
      actual_option = option
    end
    publisher.service.mocked_topic_admin = mocked_topic_admin
    batch = OpenStruct.new( "rebalance!" => [OpenStruct.new(:msg => "data")], 
                            "total_message_bytes" => 241,
                            "ordering_key" => [],
                            "items" => [OpenStruct.new(:msg => "data")])
    publisher.send(:publish_batch_sync, topic_name, batch)
    mocked_topic_admin.verify
    assert_equal actual_option, expected_option
    assert_equal actual_request, expected_request
  end

  it "passes compress true to service when compress enabled and size equal default threshold" do
    publisher = Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service, compress: true
    mocked_topic_admin = Minitest::Mock.new
    expected_request = {topic: "projects/test/topics/#{topic_name}", messages: ["data"]}
    expected_option = ::Gapic::CallOptions.new metadata: { "grpc-internal-encoding-request": "gzip" }
    actual_request = nil
    actual_option = nil
    mocked_topic_admin.expect :publish_internal, nil do |request, option|
      actual_request = request
      actual_option = option
    end
    publisher.service.mocked_topic_admin = mocked_topic_admin
    batch = OpenStruct.new( "rebalance!" => [OpenStruct.new(:msg => "data")], 
                            "total_message_bytes" => 240,
                            "ordering_key" => [],
                            "items" => [OpenStruct.new(:msg => "data")])
    publisher.send(:publish_batch_sync, topic_name, batch)
    mocked_topic_admin.verify
    assert_equal actual_option, expected_option
    assert_equal actual_request, expected_request
  end

  it "passes compress false to service when compress enabled and size below default threshold" do
    publisher = Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service, compress: true
    mocked_topic_admin = Minitest::Mock.new
    publisher.service.mocked_topic_admin = mocked_topic_admin
    expected_request = {topic: "projects/test/topics/#{topic_name}", messages: ["data"]}
    actual_request = nil
    actual_option = "test"
    mocked_topic_admin.expect :publish_internal, nil do |request, option|
      actual_request = request
      actual_option = option
    end
    batch = OpenStruct.new( "rebalance!" => [OpenStruct.new(:msg => "data")], 
                            "total_message_bytes" => 25,
                            "ordering_key" => [],
                            "items" => [OpenStruct.new(:msg => "data")])
    publisher.send(:publish_batch_sync, topic_name, batch)
    mocked_topic_admin.verify
    assert_nil actual_option
    assert_equal actual_request, expected_request
  end

  it "passes compress true to service when compress enabled and size above given threshold" do
    publisher = Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service, compress: true, compression_bytes_threshold: 150
    mocked_topic_admin = Minitest::Mock.new
    publisher.service.mocked_topic_admin = mocked_topic_admin
    expected_request = {topic: "projects/test/topics/#{topic_name}", messages: ["data"]}
    expected_option = ::Gapic::CallOptions.new metadata: { "grpc-internal-encoding-request": "gzip" }
    actual_request = nil
    actual_option = nil
    mocked_topic_admin.expect :publish_internal, nil do |request, option|
      actual_request = request
      actual_option = option
    end
    batch = OpenStruct.new( "rebalance!" => [OpenStruct.new(:msg => "data")], 
                            "total_message_bytes" => 151,
                            "ordering_key" => [],
                            "items" => [OpenStruct.new(:msg => "data")])
    publisher.send(:publish_batch_sync, topic_name, batch)
    mocked_topic_admin.verify
    assert_equal actual_option, expected_option
    assert_equal actual_request, expected_request
  end

  it "passes compress true to service when compress enabled and size equal given threshold" do
    publisher = Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service, compress: true, compression_bytes_threshold: 150
    mocked_topic_admin = Minitest::Mock.new
    publisher.service.mocked_topic_admin = mocked_topic_admin
    expected_request = {topic: "projects/test/topics/#{topic_name}", messages: ["data"]}
    expected_option = ::Gapic::CallOptions.new metadata: { "grpc-internal-encoding-request": "gzip" }
    actual_request = nil
    actual_option = nil
    mocked_topic_admin.expect :publish_internal, nil do |request, option|
      actual_request = request
      actual_option = option
    end
    batch = OpenStruct.new( "rebalance!" => [OpenStruct.new(:msg => "data")], 
                            "total_message_bytes" => 150,
                            "ordering_key" => [],
                            "items" => [OpenStruct.new(:msg => "data")])
    publisher.send(:publish_batch_sync, topic_name, batch)
    mocked_topic_admin.verify
    assert_equal actual_option, expected_option
    assert_equal actual_request, expected_request
  end

  it "passes compress false to service when compress enabled and size below given threshold" do
    publisher = Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service, compress: true, compression_bytes_threshold: 150
    mocked_topic_admin = Minitest::Mock.new
    publisher.service.mocked_topic_admin = mocked_topic_admin
    expected_request = {topic: "projects/test/topics/#{topic_name}", messages: ["data"]}
    actual_request = nil
    actual_option = "test"
    mocked_topic_admin.expect :publish_internal, nil do |request, option|
      actual_request = request
      actual_option = option
    end
    batch = OpenStruct.new( "rebalance!" => [OpenStruct.new(:msg => "data")], 
                            "total_message_bytes" => 149,
                            "ordering_key" => [],
                            "items" => [OpenStruct.new(:msg => "data")])
    publisher.send(:publish_batch_sync, topic_name, batch)
    mocked_topic_admin.verify
    assert_nil actual_option
    assert_equal actual_request, expected_request
  end

  it "passes compress false to service when compress disabled" do
    publisher = Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service
    mocked_topic_admin = Minitest::Mock.new
    expected_request = {topic: "projects/test/topics/#{topic_name}", messages: ["data"]}
    actual_request = nil
    actual_option = "test"
    mocked_topic_admin.expect :publish_internal, nil do |request, option|
      actual_request = request
      actual_option = option
    end
    publisher.service.mocked_topic_admin = mocked_topic_admin
    batch = OpenStruct.new( "rebalance!" => [OpenStruct.new(:msg => "data")], 
                            "total_message_bytes" => 300,
                            "ordering_key" => [],
                            "items" => [OpenStruct.new(:msg => "data")])
    publisher.send(:publish_batch_sync, topic_name, batch)
    mocked_topic_admin.verify
    assert_nil actual_option
    assert_equal actual_request, expected_request
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
