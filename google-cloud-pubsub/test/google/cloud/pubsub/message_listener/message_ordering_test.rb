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

describe Google::Cloud::PubSub::MessageListener, :message_ordering, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_hash) { subscription_hash(topic_name, sub_name).merge enable_message_ordering: true }
  let(:sub_grpc) { Google::Cloud::PubSub::V1::Subscription.new(sub_hash) }
  let(:sub_path) { sub_grpc.name }
  let(:subscriber) { Google::Cloud::PubSub::Subscriber.from_grpc sub_grpc, pubsub.service }

  let(:fixture_file_path) { File.expand_path File.join __dir__, "../../../../conformance/ordered_messages.json" }
  let(:fixture) { JSON.parse File.read(fixture_file_path), symbolize_names: true }
  let(:fixture_input_count) { fixture[:input].count }
  let(:fixture_expected_hash) { Hash[fixture[:expected].map { |exp| [exp[:key],  exp[:messages]] }] }

  def pull_response_groups streams: 1
    input = fixture[:input].dup
    all_keys = input.map { |msg| msg[:key] }.uniq.shuffle
    all_keys.delete "" # randomly assign one slice all emtpy key messages
    slice_size = (all_keys.size/streams.to_f).round
    key_slices = all_keys.each_slice(slice_size).to_a

    response_groups = Array.new(streams) { [] }
    until input.empty?
      response_groups.each { |ary| ary.push [] }
      input.shift(rand(200..500)).map do |msg|
        index = key_slices.find_index { |keys| keys.include? msg[:key] }
        # empty keys get a random slice
        index = rand streams if index.nil?
        response_groups[index].last.push msg
      end
    end
    msg_count = 0
    response_groups.map do |response_group|
      response_group.reject(&:empty?).map do |messages|
        Google::Cloud::PubSub::V1::StreamingPullResponse.new(
          received_messages: messages.map do |msg|
            msg_count += 1
            Google::Cloud::PubSub::V1::ReceivedMessage.new(
              ack_id: "ack-#{msg_count}",
              message: Google::Cloud::PubSub::V1::PubsubMessage.new(
                data: msg[:message],
                message_id: "msg-#{msg_count}",
                publish_time: Google::Cloud::PubSub::Convert.time_to_timestamp(Time.now),
                ordering_key: msg[:key]
              )
            )
          end
        )
      end
    end
  end

  it "sequentially processes ordered messages using one stream" do
    stub = StreamingPullStub.new pull_response_groups streams: 1
    message_hash = Hash.new { |hash, key| hash[key] = [] }
    callback_count = 0

    subscriber.service.mocked_subscriber = stub
    listener = subscriber.listen streams: 1, inventory: 100 do |msg|
      assert_kind_of Google::Cloud::PubSub::ReceivedMessage, msg
      callback_count += 1
      message_hash[msg.ordering_key].push msg.data
      msg.ack!
    end

    listener.start

    listener_retries = 0
    previous_callback_count = 0
    until callback_count >= fixture_input_count
      if previous_callback_count == callback_count
        listener_retries += 1
      else
        listener_retries = 0
      end
      previous_callback_count = callback_count

      $PUBSUB_STATUS = "#{callback_count}|#{previous_callback_count}|#{listener_retries}"
      fail "the subscriber has stopped processing messages - #{$PUBSUB_STATUS}" if listener_retries > 500
      sleep 0.01
    end

    listener.stop
    listener.wait!

    assert_equal fixture_expected_hash.keys.sort, message_hash.keys.sort
    fixture_expected_hash.each do |key, messages|
      assert_equal messages.count, message_hash[key].count, "Message count for #{key} is incorrect"
      if key.empty?
        # These can be delivered in any order.
        assert_equal messages.sort, message_hash[key].sort, "Messages without ordering_key are incorrect"
      else
        assert_equal messages, message_hash[key], "Messages for #{key} are incorrect"
      end
    end
  end

  it "sequentially processes ordered messages using default settings" do
    stub = StreamingPullStub.new pull_response_groups streams: 4
    message_hash = Hash.new { |hash, key| hash[key] = [] }
    callback_count = 0

    subscriber.service.mocked_subscriber = stub
    listener = subscriber.listen streams: 4, inventory: 1000 do |msg|
      assert_kind_of Google::Cloud::PubSub::ReceivedMessage, msg
      callback_count += 1
      message_hash[msg.ordering_key].push msg.data
      msg.ack!
    end
    listener.start

    listener_retries = 0
    previous_callback_count = 0
    until callback_count == fixture_input_count
      if previous_callback_count == callback_count
        listener_retries += 1
      else
        listener_retries = 0
      end
      previous_callback_count = callback_count

      $PUBSUB_STATUS = "#{callback_count}|#{previous_callback_count}|#{listener_retries}"
      fail "the subscriber has stopped processing messages - #{$PUBSUB_STATUS}" if listener_retries > 250
      sleep 0.01
    end

    listener.stop
    listener.wait!

    assert_equal fixture_expected_hash.keys.sort, message_hash.keys.sort
    fixture_expected_hash.each do |key, messages|
      assert_equal messages.count, message_hash[key].count, "Message count for #{key} is incorrect"
      if key.empty?
        # These can be delivered in any order.
        assert_equal messages.sort, message_hash[key].sort, "Messages without ordering_key are incorrect"
      else
        assert_equal messages, message_hash[key], "Messages for #{key} are incorrect"
      end
    end
  end
end
