# Copyright 2023 Google LLC
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

describe Google::Cloud::PubSub::BatchPublisher, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }  

  it "passes compress true to service when compress enabled and size above default threshold" do
    publisher = Google::Cloud::PubSub::BatchPublisher.new "d"*241, nil, nil, {}, compress: true
    mocked_topic_admin = Minitest::Mock.new
    expected_request = {topic: "projects/test/topics/#{topic_name}", 
                        messages: [Google::Cloud::PubSub::V1::PubsubMessage.new(data:"d"*241)]}
    expected_option = ::Gapic::CallOptions.new metadata: { "grpc-internal-encoding-request": "gzip" }
    publish_res = Google::Cloud::PubSub::V1::PublishResponse.new({ message_ids: ["msg1"] })
    mocked_topic_admin.expect :publish_internal, publish_res do |actual_request, actual_option|
        actual_request == expected_request && actual_option == expected_option
    end
    service = pubsub.service
    service.mocked_topic_admin = mocked_topic_admin
    publisher.publish_batch_messages topic_name, service
    mocked_topic_admin.verify
  end
  
  it "passes compress false to service when compress enabled and size equal default threshold" do
    publisher = Google::Cloud::PubSub::BatchPublisher.new "d"*238, nil, nil, {}, compress: true
    mocked_topic_admin = Minitest::Mock.new
    expected_request = {topic: "projects/test/topics/#{topic_name}", 
                        messages: [Google::Cloud::PubSub::V1::PubsubMessage.new(data:"d"*238)]}
    expected_option = ::Gapic::CallOptions.new metadata: { "grpc-internal-encoding-request": "gzip" }
    publish_res = Google::Cloud::PubSub::V1::PublishResponse.new({ message_ids: ["msg1"] })
    mocked_topic_admin.expect :publish_internal, publish_res do |actual_request, actual_option|
        actual_request == expected_request && actual_option == expected_option
    end
    service = pubsub.service
    service.mocked_topic_admin = mocked_topic_admin
    publisher.publish_batch_messages topic_name, service
    mocked_topic_admin.verify
  end
    
  it "passes compress false to service when compress enabled and size below default threshold" do
    publisher = Google::Cloud::PubSub::BatchPublisher.new "data", nil, nil, {}, compress: true
    mocked_topic_admin = Minitest::Mock.new
    expected_request = {topic: "projects/test/topics/#{topic_name}", 
                        messages: [Google::Cloud::PubSub::V1::PubsubMessage.new(data:"data")]}
    publish_res = Google::Cloud::PubSub::V1::PublishResponse.new({ message_ids: ["msg1"] })
    mocked_topic_admin.expect :publish_internal, publish_res do |actual_request, actual_option|
        actual_request == expected_request && actual_option.nil?
    end
    service = pubsub.service
    service.mocked_topic_admin = mocked_topic_admin
    publisher.publish_batch_messages topic_name, service
    mocked_topic_admin.verify
  end
    
  it "passes compress true to service when compress enabled and size above given threshold" do
    publisher = Google::Cloud::PubSub::BatchPublisher.new "d"*141, nil, nil, {}, compress: true, compression_bytes_threshold: 140
    mocked_topic_admin = Minitest::Mock.new
    expected_request = {topic: "projects/test/topics/#{topic_name}", 
                        messages: [Google::Cloud::PubSub::V1::PubsubMessage.new(data:"d"*141)]}
    expected_option = ::Gapic::CallOptions.new metadata: { "grpc-internal-encoding-request": "gzip" }
    publish_res = Google::Cloud::PubSub::V1::PublishResponse.new({ message_ids: ["msg1"] })
    mocked_topic_admin.expect :publish_internal, publish_res do |actual_request, actual_option|
        actual_request == expected_request && actual_option == expected_option
    end
    service = pubsub.service
    service.mocked_topic_admin = mocked_topic_admin
    publisher.publish_batch_messages topic_name, service
    mocked_topic_admin.verify
  end
    
  it "passes compress true to service when compress enabled and size equal given threshold" do
    publisher = Google::Cloud::PubSub::BatchPublisher.new "d"*138, nil, nil, {}, compress: true, compression_bytes_threshold: 140
    mocked_topic_admin = Minitest::Mock.new
    expected_request = {topic: "projects/test/topics/#{topic_name}", 
                        messages: [Google::Cloud::PubSub::V1::PubsubMessage.new(data:"d"*138)]}
    expected_option = ::Gapic::CallOptions.new metadata: { "grpc-internal-encoding-request": "gzip" }
    publish_res = Google::Cloud::PubSub::V1::PublishResponse.new({ message_ids: ["msg1"] })
    mocked_topic_admin.expect :publish_internal, publish_res do |actual_request, actual_option|
        actual_request == expected_request && actual_option == expected_option
    end
    service = pubsub.service
    service.mocked_topic_admin = mocked_topic_admin
    publisher.publish_batch_messages topic_name, service
    mocked_topic_admin.verify
  end
    
  it "passes compress false to service when compress enabled and size below given threshold" do
    publisher = Google::Cloud::PubSub::BatchPublisher.new "data", nil, nil, {}, compress: true, compression_bytes_threshold: 140
    mocked_topic_admin = Minitest::Mock.new
    expected_request = {topic: "projects/test/topics/#{topic_name}", 
                        messages: [Google::Cloud::PubSub::V1::PubsubMessage.new(data:"data")]}
    publish_res = Google::Cloud::PubSub::V1::PublishResponse.new({ message_ids: ["msg1"] })
    mocked_topic_admin.expect :publish_internal, publish_res do |actual_request, actual_option|
        actual_request == expected_request && actual_option.nil?
    end
    service = pubsub.service
    service.mocked_topic_admin = mocked_topic_admin
    publisher.publish_batch_messages topic_name, service
    mocked_topic_admin.verify
  end
    
  it "passes compress false to service when compress disabled" do
    publisher = Google::Cloud::PubSub::BatchPublisher.new "d"*241, nil, nil, {}
    mocked_topic_admin = Minitest::Mock.new
    expected_request = {topic: "projects/test/topics/#{topic_name}", 
                        messages: [Google::Cloud::PubSub::V1::PubsubMessage.new(data:"d"*241)]}
    publish_res = Google::Cloud::PubSub::V1::PublishResponse.new({ message_ids: ["msg1"] })
    mocked_topic_admin.expect :publish_internal, publish_res do |actual_request, actual_option|
        actual_request == expected_request && actual_option.nil?
    end
    service = pubsub.service
    service.mocked_topic_admin = mocked_topic_admin
    publisher.publish_batch_messages topic_name, service
    mocked_topic_admin.verify
  end  
end
