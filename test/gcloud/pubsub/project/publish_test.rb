# Copyright 2015 Google Inc. All rights reserved.
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

describe Gcloud::Pubsub::Project, :publish, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:message1) { "new-message-here" }
  let(:message2) { "second-new-message" }
  let(:message3) { "third-new-message" }
  let(:msg_packed1) { [message1].pack("m") }
  let(:msg_packed2) { [message2].pack("m") }
  let(:msg_packed3) { [message3].pack("m") }

  it "publishes a message" do
    mock_connection.post "/v1/projects/#{project}/topics/#{topic_name}:publish" do |env|
      JSON.parse(env.body)["messages"].first["data"].must_equal msg_packed1
      [200, {"Content-Type"=>"application/json"},
       { messageIds: ["msg1"] }.to_json]
    end

    msg = pubsub.publish topic_name, message1
    msg.must_be_kind_of Gcloud::Pubsub::Message
    msg.message_id.must_equal "msg1"
  end

  it "publishes a message with attributes" do
    mock_connection.post "/v1/projects/#{project}/topics/#{topic_name}:publish" do |env|
      JSON.parse(env.body)["messages"].first["data"].must_equal msg_packed1
      [200, {"Content-Type"=>"application/json"},
       { messageIds: ["msg1"] }.to_json]
    end

    msg = pubsub.publish topic_name, message1, format: :text
    msg.must_be_kind_of Gcloud::Pubsub::Message
    msg.message_id.must_equal "msg1"
    msg.attributes["format"].must_equal "text"
  end

  it "publishes multiple messages with a block" do
    mock_connection.post "/v1/projects/#{project}/topics/#{topic_name}:publish" do |env|
      JSON.parse(env.body)["messages"].first["data"].must_equal msg_packed1
      JSON.parse(env.body)["messages"].last["data"].must_equal  msg_packed3
      [200, {"Content-Type"=>"application/json"},
       { messageIds: ["msg1", "msg2", "msg3"] }.to_json]
    end

    msgs = pubsub.publish topic_name do |batch|
      batch.publish message1
      batch.publish message2
      batch.publish message3, format: :none
    end
    msgs.count.must_equal 3
    msgs.each { |msg| msg.must_be_kind_of Gcloud::Pubsub::Message }
    msgs.first.message_id.must_equal "msg1"
    msgs.last.message_id.must_equal "msg3"
    msgs.last.attributes["format"].must_equal "none"
  end

  it "publishes a message to an existing topic with autocreate" do
    mock_connection.post "/v1/projects/#{project}/topics/#{topic_name}:publish" do |env|
      JSON.parse(env.body)["messages"].first["data"].must_equal msg_packed1
      [200, {"Content-Type"=>"application/json"},
       { messageIds: ["msg1"] }.to_json]
    end

    msg = pubsub.publish topic_name, message1, autocreate: true
    msg.must_be_kind_of Gcloud::Pubsub::Message
    msg.message_id.must_equal "msg1"
  end

  it "publishes a message to a non-existing topic with autocreate" do
    new_topic_name = "new-topic-#{Time.now.to_i}"

    mock_connection.post "/v1/projects/#{project}/topics/#{new_topic_name}:publish" do |env|
      JSON.parse(env.body)["messages"].first["data"].must_equal msg_packed1
      [404, {"Content-Type"=>"application/json"},
       not_found_error_json(new_topic_name)]
    end
    mock_connection.post "/v1/projects/#{project}/topics/#{new_topic_name}:publish" do |env|
      JSON.parse(env.body)["messages"].first["data"].must_equal msg_packed1
      [200, {"Content-Type"=>"application/json"},
       { messageIds: ["msg1"] }.to_json]
    end

    create_req = Google::Pubsub::V1::Topic.new(
      name: topic_path(new_topic_name)
    )
    create_res = Google::Pubsub::V1::Topic.decode_json topic_json(new_topic_name)
    mock = Minitest::Mock.new
    mock.expect :create_topic, create_res, [create_req]
    pubsub.service.mocked_publisher = mock

    msg = pubsub.publish new_topic_name, message1, autocreate: true

    mock.verify

    msg.must_be_kind_of Gcloud::Pubsub::Message
    msg.message_id.must_equal "msg1"
  end
end
