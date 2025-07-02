# Copyright 2022 Google LLC
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

describe Google::Cloud::PubSub::MessageListener, :stream, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_hash) { subscription_hash topic_name, sub_name }
  let(:sub_grpc) { Google::Cloud::PubSub::V1::Subscription.new(sub_hash) }
  let(:sub_path) { sub_grpc.name }
  let(:subscriber) { Google::Cloud::PubSub::Subscriber.from_grpc sub_grpc, pubsub.service }
  let(:rec_msg1_grpc) { Google::Cloud::PubSub::V1::ReceivedMessage.new \
    rec_message_hash("rec_message1-msg-goes-here", 1111) }
  let(:rec_msg2_grpc) { Google::Cloud::PubSub::V1::ReceivedMessage.new \
    rec_message_hash("rec_message2-msg-goes-here", 1112) }
  let(:rec_msg3_grpc) { Google::Cloud::PubSub::V1::ReceivedMessage.new \
    rec_message_hash("rec_message3-msg-goes-here", 1113) }


  it "should call handle error for ack on retriable error" do
    pull_res1 = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: [rec_msg1_grpc],
                                                                     subscription_properties: {
                                                                      exactly_once_delivery_enabled: true
                                                                     }   
    response_groups = [[pull_res1]]

    stub = StreamingPullStub.new response_groups
    called = false  
    def stub.acknowledge subscription:, ack_ids:
      @acknowledge_requests << [subscription, ack_ids.flatten.sort]
      begin
        raise GRPC::InvalidArgument.new "test"
      rescue => exception
        raise ::Google::Cloud::Error.from_error(exception)
      end
    end

    subscriber.service.mocked_subscription_admin = stub
    listener = subscriber.listen streams: 1 do |msg|
      msg.acknowledge!
      called = true
    end

    listener.start

    listener_retries = 0
    until called
      fail "total number of calls were never made" if listener_retries > 120
      listener_retries += 1
      sleep 0.01
    end

    sleep 5
    assert stub.acknowledge_requests.length > 1
    listener.stop
    listener.wait!
  end

  it "should call handle error for retry mod ack on retriable error" do
    pull_res1 = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: [rec_msg1_grpc],
                                                                     subscription_properties: {
                                                                      exactly_once_delivery_enabled: true
                                                                     }
    response_groups = [[pull_res1]]

    stub = StreamingPullStub.new response_groups
    called = false  
    def stub.modify_ack_deadline subscription:, ack_ids:, ack_deadline_seconds:
      if @modify_ack_deadline_requests.count == 0
        return @modify_ack_deadline_requests << [subscription, ack_ids.sort, ack_deadline_seconds]
      end
      @modify_ack_deadline_requests << [subscription, ack_ids.sort, ack_deadline_seconds]
      begin
        raise GRPC::InvalidArgument.new "test"
      rescue => exception
        raise ::Google::Cloud::Error.from_error(exception)
      end
    end

    subscriber.service.mocked_subscription_admin = stub
    listener = subscriber.listen streams: 1 do |msg|
      msg.modify_ack_deadline! 120
      called = true
    end

    listener.start

    listener_retries = 0
    until called
      fail "total number of calls were never made" if listener_retries > 120
      listener_retries += 1
      sleep 0.1
    end

    sleep 5
    assert stub.modify_ack_deadline_requests.length > 2
    listener.stop
    listener.wait!
  end

  it "should raise other errors on modack" do
    pull_res1 = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: [rec_msg1_grpc],
                                                                     subscription_properties: {
                                                                      exactly_once_delivery_enabled: true
                                                                     }   
    response_groups = [[pull_res1]]

    stub = StreamingPullStub.new response_groups
    called = false  
    errors = []
    def stub.modify_ack_deadline subscription:, ack_ids:, ack_deadline_seconds:
      if @modify_ack_deadline_requests.count == 0
        return @modify_ack_deadline_requests << [subscription, ack_ids.sort, ack_deadline_seconds]
      end
      raise StandardError.new "Test failure"
    end

    subscriber.service.mocked_subscription_admin = stub
    listener = subscriber.listen streams: 1 do |msg|
      msg.modify_ack_deadline! 120 do |result|
        assert_kind_of Google::Cloud::PubSub::AcknowledgeResult, result,  Proc.new { raise "Result kind did not match!" }
        assert_equal result.status, Google::Cloud::PubSub::AcknowledgeResult::OTHER, Proc.new { raise "Staus did not match!" }
      end

      called = true
    end

    listener.on_error do |error|
      errors << error
    end

    listener.start

    listener_retries = 0
    until called
      fail "total number of calls were never made" if listener_retries > 120
      listener_retries += 1
      sleep 0.1
    end

    sleep 5
    assert_empty errors, Proc.new { raise errors.first }
    listener.stop
    listener.wait!
  end

  it "should raise other errors on ack" do
    pull_res1 = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: [rec_msg1_grpc],
                                                                     subscription_properties: {
                                                                        exactly_once_delivery_enabled: true
                                                                     }   
    response_groups = [[pull_res1]]

    stub = StreamingPullStub.new response_groups
    called = false  
    errors = []
    def stub.acknowledge subscription:, ack_ids:
      raise StandardError.new "Test failure"
    end

    subscriber.service.mocked_subscription_admin = stub
    listener = subscriber.listen streams: 1 do |msg|
      msg.acknowledge! do |result|
        assert_kind_of Google::Cloud::PubSub::AcknowledgeResult, result,  Proc.new { raise "Result kind did not match!" }
        assert_equal result.status, Google::Cloud::PubSub::AcknowledgeResult::OTHER, Proc.new { raise "Staus did not match!" }
      end
      called = true
    end

    listener.on_error do |error|
      errors << error
    end

    listener.start

    listener_retries = 0
    until called
      fail "total number of calls were never made" if listener_retries > 120
      listener_retries += 1
      sleep 0.1
    end

    sleep 5
    assert_empty errors, Proc.new { raise errors.first }
    listener.stop
    listener.wait!
  end

  it "should raise permission errors on ack" do
    pull_res1 = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: [rec_msg1_grpc],
                                                                    subscription_properties: {
                                                                        exactly_once_delivery_enabled: true
                                                                    }   
    response_groups = [[pull_res1]]

    stub = StreamingPullStub.new response_groups
    called = false  
    errors = []
    def stub.acknowledge subscription:, ack_ids:
      raise Google::Cloud::PermissionDeniedError.new "Test failure"
    end

    subscriber.service.mocked_subscription_admin = stub
    listener = subscriber.listen streams: 1 do |msg|
      msg.acknowledge! do |result|
        assert_kind_of Google::Cloud::PubSub::AcknowledgeResult, result,  Proc.new { raise "Result kind did not match!" }
        assert_equal result.status, Google::Cloud::PubSub::AcknowledgeResult::PERMISSION_DENIED, Proc.new { raise "Staus did not match!" }
      end
      called = true
    end

    listener.on_error do |error|
        errors << error
    end

    listener.start

    listener_retries = 0
    until called
      fail "total number of calls were never made" if listener_retries > 120
      listener_retries += 1
      sleep 0.1
    end

    sleep 5
    assert_empty errors, Proc.new { raise errors.first }
    listener.stop
    listener.wait!
  end

  it "should raise permission errors on modack" do
    pull_res1 = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: [rec_msg1_grpc],
                                                                    subscription_properties: {
                                                                        exactly_once_delivery_enabled: true
                                                                    }   
    response_groups = [[pull_res1]]

    stub = StreamingPullStub.new response_groups
    called = false  
    errors = []
    def stub.modify_ack_deadline subscription:, ack_ids:, ack_deadline_seconds:
      if @modify_ack_deadline_requests.count == 0
        return @modify_ack_deadline_requests << ["ack_ids"]
      end
      raise Google::Cloud::PermissionDeniedError.new "Test failure"
    end

    subscriber.service.mocked_subscription_admin = stub
    listener = subscriber.listen streams: 1 do |msg|
      msg.modify_ack_deadline! 120 do |result|
        assert_kind_of Google::Cloud::PubSub::AcknowledgeResult, result,  Proc.new { raise "Result kind did not match!" }
        assert_equal result.status, Google::Cloud::PubSub::AcknowledgeResult::PERMISSION_DENIED, Proc.new { raise "Staus did not match!" }
      end
      called = true
    end

    listener.on_error do |error|
        errors << error
    end

    listener.start

    listener_retries = 0
    until called
      fail "total number of calls were never made" if listener_retries > 120
      listener_retries += 1
      sleep 0.1
    end

    sleep 5
    assert_empty errors, Proc.new { raise errors.first }
    listener.stop
    listener.wait!
  end

  it "should raise failed precondition errors on ack" do
    pull_res1 = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: [rec_msg1_grpc],
                                                                    subscription_properties: {
                                                                        exactly_once_delivery_enabled: true
                                                                    }   
    response_groups = [[pull_res1]]

    stub = StreamingPullStub.new response_groups
    called = false  
    errors = []
    def stub.acknowledge subscription:, ack_ids:
      raise Google::Cloud::FailedPreconditionError.new "Test failure"
    end

    subscriber.service.mocked_subscription_admin = stub
    listener = subscriber.listen streams: 1 do |msg|
      msg.acknowledge! do |result|
        assert_kind_of Google::Cloud::PubSub::AcknowledgeResult, result,  Proc.new { raise "Result kind did not match!" }
        assert_equal result.status, Google::Cloud::PubSub::AcknowledgeResult::FAILED_PRECONDITION, Proc.new { raise "Staus did not match!" }
      end
      called = true
    end

    listener.on_error do |error|
        errors << error
    end

    listener.start

    listener_retries = 0
    until called
      fail "total number of calls were never made" if listener_retries > 120
      listener_retries += 1
      sleep 0.1
    end

    sleep 5
    assert_empty errors, Proc.new { raise errors.first }
    listener.stop
    listener.wait!
  end

  it "should raise failed precondition errors on modack" do
    pull_res1 = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: [rec_msg1_grpc],
                                                                    subscription_properties: {
                                                                        exactly_once_delivery_enabled: true
                                                                    }   
    response_groups = [[pull_res1]]

    stub = StreamingPullStub.new response_groups
    called = false  
    errors = []
    def stub.modify_ack_deadline subscription:, ack_ids:, ack_deadline_seconds:
      if @modify_ack_deadline_requests.count == 0
        return @modify_ack_deadline_requests << ["ack_ids"]
      end
      raise Google::Cloud::FailedPreconditionError.new "Test failure"
    end

    subscriber.service.mocked_subscription_admin = stub
    listener = subscriber.listen streams: 1 do |msg|
      msg.modify_ack_deadline! 120 do |result|
        assert_kind_of Google::Cloud::PubSub::AcknowledgeResult, result,  Proc.new { raise "Result kind did not match!" }
        assert_equal result.status, Google::Cloud::PubSub::AcknowledgeResult::FAILED_PRECONDITION, Proc.new { raise "Staus did not match!" }
      end
      called = true
    end

    listener.on_error do |error|
      errors << error
    end

    listener.start

    listener_retries = 0
    until called
      fail "total number of calls were never made" if listener_retries > 120
      listener_retries += 1
      sleep 0.1
    end

    sleep 5
    assert_empty errors, Proc.new { raise errors.first }
    listener.stop
    listener.wait!
  end

  it "should send success on modack" do
    pull_res1 = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: [rec_msg1_grpc],
                                                                    subscription_properties: {
                                                                        exactly_once_delivery_enabled: true
                                                                    }   
    response_groups = [[pull_res1]]

    stub = StreamingPullStub.new response_groups
    called = false 
    errors = []

    subscriber.service.mocked_subscription_admin = stub
    listener = subscriber.listen streams: 1 do |msg|
      msg.modify_ack_deadline! 120 do |result|
        assert_kind_of Google::Cloud::PubSub::AcknowledgeResult, result,  Proc.new { raise "Result kind did not match!" }
        assert_equal result.status, Google::Cloud::PubSub::AcknowledgeResult::SUCCESS, Proc.new { raise "Staus did not match!" }
      end
      called = true
    end

    listener.on_error do |error|
        errors << error
    end

    listener.start

    listener_retries = 0
    until called
      fail "total number of calls were never made" if listener_retries > 120
      listener_retries += 1
      sleep 0.1
    end

    sleep 5
    assert_empty errors, Proc.new { raise errors.first }
    listener.stop
    listener.wait!
  end

  it "should send success on ack" do
    pull_res1 = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: [rec_msg1_grpc],
                                                                    subscription_properties: {
                                                                        exactly_once_delivery_enabled: true
                                                                    }   
    response_groups = [[pull_res1]]

    stub = StreamingPullStub.new response_groups
    called = false  
    errors = []

    subscriber.service.mocked_subscription_admin = stub
    listener = subscriber.listen streams: 1 do |msg|
      msg.acknowledge! do |result|
        assert_kind_of Google::Cloud::PubSub::AcknowledgeResult, result,  Proc.new { raise "Result kind did not match!" }
        assert_equal result.status, Google::Cloud::PubSub::AcknowledgeResult::SUCCESS, Proc.new { raise "Staus did not match!" }
      end
      called = true
    end

    listener.on_error do |error|
        errors << error
    end

    listener.start

    listener_retries = 0
    until called
      fail "total number of calls were never made" if listener_retries > 120
      listener_retries += 1
      sleep 0.1
    end

    sleep 5
    assert_empty errors, Proc.new { raise errors.first }
    listener.stop
    listener.wait!
  end

  it "should retry only transient failures" do
    pull_res1 = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: [rec_msg1_grpc],
                                                                     subscription_properties: {
                                                                      exactly_once_delivery_enabled: true
                                                                     }   
    pull_res2 = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: [rec_msg2_grpc],
                                                                     subscription_properties: {
                                                                      exactly_once_delivery_enabled: true
                                                                     }   
    pull_res3 = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: [rec_msg3_grpc] ,
                                                                     subscription_properties: {
                                                                      exactly_once_delivery_enabled: true
                                                                     }                                                                   
    response_groups = [[pull_res1,pull_res2,pull_res3]]

    stub = StreamingPullStub.new response_groups
    called = false  
    errors = []
    def stub.acknowledge subscription:, ack_ids:
      @acknowledge_requests << [subscription, ack_ids.flatten.sort]
      begin
        raise GRPC::InvalidArgument.new
      rescue => exception
        error = ::Google::Cloud::Error.from_error(exception)
        def error.error_metadata
          {"ack-id-1111"=>"PERMANENT_FAILURE_INVALID_ACK_ID","ack-id-1113"=>"TRANSIENT_FAILURE_INVALID_ACK_ID","ack-id-1112"=>"PERMANENT_FAILURE_INVALID_ACK_ID"}
        end
        raise error
      end
    end

    subscriber.service.mocked_subscription_admin = stub
    listener = subscriber.listen streams: 1 do |msg|
      msg.acknowledge!
      called = true
    end

    listener.on_error do |error|
      errors << error
    end

    listener.start

    listener_retries = 0
    until called
      fail "total number of calls were never made" if listener_retries > 120
      listener_retries += 1
      sleep 0.1
    end

    sleep 5
    assert_equal stub.acknowledge_requests[1][1], ["ack-id-1113"]
    listener.stop
    listener.wait!
  end

  it "should parse error_metadata to give temp and permanent errors" do
    mocked_subscription_admin = Minitest::Mock.new
    mocked_subscription_admin.expect :callback_threads, 4 
    mocked_subscription_admin.expect :callback_threads, 4 
    buffer = Google::Cloud::PubSub::MessageListener::TimedUnaryBuffer.new mocked_subscription_admin
    temp_error = buffer.send(:parse_error, 
                            OpenStruct.new(error_metadata: {"12" =>"PERMANENT_FAILURE_INVALID_ACK_ID", 
                                                            "13" => "TRANSIENT_FAILURE"}))
    assert_equal ["13"], temp_error                                                                      
  end
end
