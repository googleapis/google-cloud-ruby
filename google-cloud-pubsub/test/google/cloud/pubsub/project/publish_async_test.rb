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

describe Google::Cloud::Pubsub::Project, :publish_async, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:topic) { Google::Cloud::Pubsub::Topic.from_grpc Google::Pubsub::V1::Topic.decode_json(topic_json(topic_name)),
                                                       pubsub.service }

  it "publishes a message" do
    messages = [
      Google::Pubsub::V1::PubsubMessage.new(data: "async-message".encode("ASCII-8BIT"))
    ]
    publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: ["msg1"] }.to_json)
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [topic_path(topic_name), messages, options: default_options]
    pubsub.service.mocked_publisher = mock

    pubsub.publish_async topic_name, "async-message"

    pubsub.service.async_publisher.queue.wont_be :empty?
    pubsub.service.async_publisher.queue.keys.must_equal [topic_path(topic_name)]
    pubsub.service.async_publisher.queue[topic_path(topic_name)].messages.must_equal messages
    pubsub.service.async_publisher.queue[topic_path(topic_name)].callbacks.count.must_equal 1
    pubsub.service.async_publisher.queue[topic_path(topic_name)].callbacks.must_equal [nil]

    pubsub.service.async_publisher.must_be :started?
    pubsub.service.async_publisher.wont_be :stopped?

    # force the queued messages to be published
    pubsub.service.async_publisher.stop
    pubsub.service.async_publisher.wait

    pubsub.service.async_publisher.wont_be :started?
    pubsub.service.async_publisher.must_be :stopped?

    # shut down the thread pool to ensure all the tasks are completed
    pubsub.service.async_publisher.thread_pool.shutdown
    pubsub.service.async_publisher.thread_pool.wait_for_termination

    pubsub.service.async_publisher.queue.must_be :empty?

    mock.verify
  end

  it "publishes a message with a callback" do
    messages = [
      Google::Pubsub::V1::PubsubMessage.new(data: "async-message".encode("ASCII-8BIT"))
    ]
    publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: ["msg1"] }.to_json)
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [topic_path(topic_name), messages, options: default_options]
    pubsub.service.mocked_publisher = mock

    callback_called = false

    pubsub.publish_async topic_name, "async-message" do |result|
      assert_kind_of Google::Cloud::Pubsub::PublishResult, result
      assert result.succeeded?
      assert_equal "msg1", result.msg_id
      callback_called = true
    end

    pubsub.service.async_publisher.queue.wont_be :empty?
    pubsub.service.async_publisher.queue.keys.must_equal [topic_path(topic_name)]
    pubsub.service.async_publisher.queue[topic_path(topic_name)].messages.must_equal messages
    pubsub.service.async_publisher.queue[topic_path(topic_name)].callbacks.count.must_equal 1
    pubsub.service.async_publisher.queue[topic_path(topic_name)].callbacks.each do |block|
      block.must_be_kind_of Proc
    end

    pubsub.service.async_publisher.must_be :started?
    pubsub.service.async_publisher.wont_be :stopped?

    # force the queued messages to be published
    pubsub.service.async_publisher.stop
    pubsub.service.async_publisher.wait

    pubsub.service.async_publisher.wont_be :started?
    pubsub.service.async_publisher.must_be :stopped?

    # shut down the thread pool to ensure all the tasks are completed
    pubsub.service.async_publisher.thread_pool.shutdown
    pubsub.service.async_publisher.thread_pool.wait_for_termination

    pubsub.service.async_publisher.queue.must_be :empty?
    callback_called.must_equal true

    mock.verify
  end

  it "publishes a message with multibyte characters" do
    messages = [
      Google::Pubsub::V1::PubsubMessage.new(data: "\xE3\x81\x82".force_encoding("ASCII-8BIT"))
    ]
    publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: ["msg1"] }.to_json)
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [topic_path(topic_name), messages, options: default_options]
    pubsub.service.mocked_publisher = mock

    callback_called = false

    pubsub.publish_async topic_name, "あ" do |result|
      assert_kind_of Google::Cloud::Pubsub::PublishResult, result
      assert result.succeeded?
      assert_equal "msg1", result.msg_id
      assert_equal "\xE3\x81\x82".force_encoding("ASCII-8BIT"), result.data
      callback_called = true
    end

    pubsub.service.async_publisher.queue.wont_be :empty?
    pubsub.service.async_publisher.queue.keys.must_equal [topic_path(topic_name)]
    pubsub.service.async_publisher.queue[topic_path(topic_name)].messages.must_equal messages
    pubsub.service.async_publisher.queue[topic_path(topic_name)].callbacks.count.must_equal 1
    pubsub.service.async_publisher.queue[topic_path(topic_name)].callbacks.each do |block|
      block.must_be_kind_of Proc
    end

    pubsub.service.async_publisher.must_be :started?
    pubsub.service.async_publisher.wont_be :stopped?

    # force the queued messages to be published
    pubsub.service.async_publisher.stop
    pubsub.service.async_publisher.wait

    pubsub.service.async_publisher.wont_be :started?
    pubsub.service.async_publisher.must_be :stopped?

    # shut down the thread pool to ensure all the tasks are completed
    pubsub.service.async_publisher.thread_pool.shutdown
    pubsub.service.async_publisher.thread_pool.wait_for_termination

    pubsub.service.async_publisher.queue.must_be :empty?
    callback_called.must_equal true

    mock.verify
  end

  it "publishes a message using an IO-ish object" do
    messages = [
      Google::Pubsub::V1::PubsubMessage.new(data: "\xE3\x81\x82".force_encoding("ASCII-8BIT"))
    ]
    publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: ["msg1"] }.to_json)
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [topic_path(topic_name), messages, options: default_options]
    pubsub.service.mocked_publisher = mock

    callback_called = false

    Tempfile.open ["message", "txt"] do |tmpfile|
      tmpfile.binmode
      tmpfile.write "あ"
      tmpfile.rewind

      pubsub.publish_async topic_name, tmpfile do |result|
        assert_kind_of Google::Cloud::Pubsub::PublishResult, result
        assert result.succeeded?
        assert_equal "msg1", result.msg_id
        assert_equal "\xE3\x81\x82".force_encoding("ASCII-8BIT"), result.data
        callback_called = true
      end
    end

    pubsub.service.async_publisher.queue.wont_be :empty?
    pubsub.service.async_publisher.queue.keys.must_equal [topic_path(topic_name)]
    pubsub.service.async_publisher.queue[topic_path(topic_name)].messages.must_equal messages
    pubsub.service.async_publisher.queue[topic_path(topic_name)].callbacks.count.must_equal 1
    pubsub.service.async_publisher.queue[topic_path(topic_name)].callbacks.each do |block|
      block.must_be_kind_of Proc
    end

    pubsub.service.async_publisher.must_be :started?
    pubsub.service.async_publisher.wont_be :stopped?

    # force the queued messages to be published
    pubsub.service.async_publisher.stop
    pubsub.service.async_publisher.wait

    pubsub.service.async_publisher.wont_be :started?
    pubsub.service.async_publisher.must_be :stopped?

    # shut down the thread pool to ensure all the tasks are completed
    pubsub.service.async_publisher.thread_pool.shutdown
    pubsub.service.async_publisher.thread_pool.wait_for_termination

    pubsub.service.async_publisher.queue.must_be :empty?
    callback_called.must_equal true

    mock.verify
  end

  it "publishes a message with attributes" do
    messages = [
      Google::Pubsub::V1::PubsubMessage.new(data: "async-message".encode("ASCII-8BIT"), attributes: {"format" => "text"})
    ]
    publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: ["msg1"] }.to_json)
    mock = Minitest::Mock.new
    mock.expect :publish, publish_res, [topic_path(topic_name), messages, options: default_options]
    pubsub.service.mocked_publisher = mock

    callback_called = false

    pubsub.publish_async topic_name, "async-message", format: :text do |result|
      assert_kind_of Google::Cloud::Pubsub::PublishResult, result
      assert result.succeeded?
      assert_equal "msg1", result.msg_id
      assert_equal "async-message".force_encoding("ASCII-8BIT"), result.data
      assert_equal "text", result.attributes["format"]
      callback_called = true
    end

    pubsub.service.async_publisher.queue.wont_be :empty?
    pubsub.service.async_publisher.queue.keys.must_equal [topic_path(topic_name)]
    pubsub.service.async_publisher.queue[topic_path(topic_name)].messages.must_equal messages
    pubsub.service.async_publisher.queue[topic_path(topic_name)].callbacks.count.must_equal 1
    pubsub.service.async_publisher.queue[topic_path(topic_name)].callbacks.each do |block|
      block.must_be_kind_of Proc
    end

    pubsub.service.async_publisher.must_be :started?
    pubsub.service.async_publisher.wont_be :stopped?

    # force the queued messages to be published
    pubsub.service.async_publisher.stop
    pubsub.service.async_publisher.wait

    pubsub.service.async_publisher.wont_be :started?
    pubsub.service.async_publisher.must_be :stopped?

    # shut down the thread pool to ensure all the tasks are completed
    pubsub.service.async_publisher.thread_pool.shutdown
    pubsub.service.async_publisher.thread_pool.wait_for_termination

    pubsub.service.async_publisher.queue.must_be :empty?
    callback_called.must_equal true

    mock.verify
  end

  describe "lazy topic that exists" do
    let(:topic) { Google::Cloud::Pubsub::Topic.new_lazy topic_name,
                                                 pubsub.service,
                                                 autocreate: false }

    it "publishes a message" do
      messages = [
        Google::Pubsub::V1::PubsubMessage.new(data: "async-message".encode("ASCII-8BIT"))
      ]
      publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: ["msg1"] }.to_json)
      mock = Minitest::Mock.new
      mock.expect :publish, publish_res, [topic_path(topic_name), messages, options: default_options]
      pubsub.service.mocked_publisher = mock

      pubsub.publish_async topic_name, "async-message"

      pubsub.service.async_publisher.queue.wont_be :empty?
      pubsub.service.async_publisher.queue.keys.must_equal [topic_path(topic_name)]
      pubsub.service.async_publisher.queue[topic_path(topic_name)].messages.must_equal messages
      pubsub.service.async_publisher.queue[topic_path(topic_name)].callbacks.count.must_equal 1
      pubsub.service.async_publisher.queue[topic_path(topic_name)].callbacks.must_equal [nil]

      pubsub.service.async_publisher.must_be :started?
      pubsub.service.async_publisher.wont_be :stopped?

      # force the queued messages to be published
      pubsub.service.async_publisher.stop
      pubsub.service.async_publisher.wait

      pubsub.service.async_publisher.wont_be :started?
      pubsub.service.async_publisher.must_be :stopped?

      # shut down the thread pool to ensure all the tasks are completed
      pubsub.service.async_publisher.thread_pool.shutdown
      pubsub.service.async_publisher.thread_pool.wait_for_termination

      pubsub.service.async_publisher.queue.must_be :empty?

      mock.verify
    end

    it "publishes a message with attributes" do
      messages = [
        Google::Pubsub::V1::PubsubMessage.new(data: "async-message".encode("ASCII-8BIT"), attributes: { "format" => "text" })
      ]
      publish_res = Google::Pubsub::V1::PublishResponse.decode_json({ message_ids: ["msg1"] }.to_json)
      mock = Minitest::Mock.new
      mock.expect :publish, publish_res, [topic_path(topic_name), messages, options: default_options]
      pubsub.service.mocked_publisher = mock

      callback_called = false

      pubsub.publish_async topic_name, "async-message", format: :text do |result|
        assert_kind_of Google::Cloud::Pubsub::PublishResult, result
        assert result.succeeded?
        assert_equal "msg1", result.msg_id
        assert_equal "async-message".force_encoding("ASCII-8BIT"), result.data
        assert_equal "text", result.attributes["format"]
        callback_called = true
      end

      pubsub.service.async_publisher.queue.wont_be :empty?
      pubsub.service.async_publisher.queue.keys.must_equal [topic_path(topic_name)]
      pubsub.service.async_publisher.queue[topic_path(topic_name)].messages.must_equal messages
      pubsub.service.async_publisher.queue[topic_path(topic_name)].callbacks.count.must_equal 1
      pubsub.service.async_publisher.queue[topic_path(topic_name)].callbacks.each do |block|
        block.must_be_kind_of Proc
      end

      pubsub.service.async_publisher.must_be :started?
      pubsub.service.async_publisher.wont_be :stopped?

      # force the queued messages to be published
      pubsub.service.async_publisher.stop
      pubsub.service.async_publisher.wait

      pubsub.service.async_publisher.wont_be :started?
      pubsub.service.async_publisher.must_be :stopped?

      # shut down the thread pool to ensure all the tasks are completed
      pubsub.service.async_publisher.thread_pool.shutdown
      pubsub.service.async_publisher.thread_pool.wait_for_termination

      pubsub.service.async_publisher.queue.must_be :empty?
      callback_called.must_equal true

      mock.verify
    end
  end

  describe "lazy topic that does not exist" do
    let(:topic) { Google::Cloud::Pubsub::Topic.new_lazy topic_name,
                                                 pubsub.service,
                                                 autocreate: false }
    let(:gax_error) do
      Google::Gax::GaxError.new("not found").tap do |e|
        e.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
      end
    end

    it "publishes a message" do
      messages = [
        Google::Pubsub::V1::PubsubMessage.new(data: "async-message".encode("ASCII-8BIT"))
      ]

      stub = Object.new
      def stub.publish *args
        err = Google::Gax::GaxError.new("not found").tap do |e|
          e.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
        end
        raise err
      end
      pubsub.service.mocked_publisher = stub

      callback_called = false

      pubsub.publish_async topic_name, "async-message" do |result|
        assert_kind_of Google::Cloud::Pubsub::PublishResult, result
        refute result.succeeded?
        assert result.failed?
        assert_equal "async-message".force_encoding("ASCII-8BIT"), result.data
        assert_kind_of Google::Cloud::NotFoundError, result.error
        callback_called = true
      end

      pubsub.service.async_publisher.queue.wont_be :empty?
      pubsub.service.async_publisher.queue.keys.must_equal [topic_path(topic_name)]
      pubsub.service.async_publisher.queue[topic_path(topic_name)].messages.must_equal messages
      pubsub.service.async_publisher.queue[topic_path(topic_name)].callbacks.count.must_equal 1
      pubsub.service.async_publisher.queue[topic_path(topic_name)].callbacks.each do |block|
        block.must_be_kind_of Proc
      end

      pubsub.service.async_publisher.must_be :started?
      pubsub.service.async_publisher.wont_be :stopped?

      # force the queued messages to be published
      pubsub.service.async_publisher.stop
      pubsub.service.async_publisher.wait

      pubsub.service.async_publisher.wont_be :started?
      pubsub.service.async_publisher.must_be :stopped?

      # shut down the thread pool to ensure all the tasks are completed
      pubsub.service.async_publisher.thread_pool.shutdown
      pubsub.service.async_publisher.thread_pool.wait_for_termination

      pubsub.service.async_publisher.queue.must_be :empty?
      callback_called.must_equal true
    end
  end
end
