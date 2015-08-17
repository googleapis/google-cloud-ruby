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

describe Gcloud::Pubsub::Topic, :publish, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:topic) { Gcloud::Pubsub::Topic.from_gapi JSON.parse(topic_json(topic_name)),
                                                pubsub.connection }
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

    msg = topic.publish message1
    msg.must_be_kind_of Gcloud::Pubsub::Message
    msg.message_id.must_equal "msg1"
  end

  it "publishes a message with attributes" do
    mock_connection.post "/v1/projects/#{project}/topics/#{topic_name}:publish" do |env|
      JSON.parse(env.body)["messages"].first["data"].must_equal msg_packed1
      [200, {"Content-Type"=>"application/json"},
       { messageIds: ["msg1"] }.to_json]
    end

    msg = topic.publish message1, format: :text
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

    msgs = topic.publish do |batch|
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

  describe "lazy topic that exists" do
    describe "created with autocreate" do
      let(:topic) { Gcloud::Pubsub::Topic.new_lazy topic_name,
                                                   pubsub.connection,
                                                   autocreate: true }

      it "publishes a message" do
        mock_connection.post "/v1/projects/#{project}/topics/#{topic_name}:publish" do |env|
          JSON.parse(env.body)["messages"].first["data"].must_equal msg_packed1
          [200, {"Content-Type"=>"application/json"},
           { messageIds: ["msg1"] }.to_json]
        end

        msg = topic.publish message1
        msg.must_be_kind_of Gcloud::Pubsub::Message
        msg.message_id.must_equal "msg1"
      end

      it "publishes a message with attributes" do
        mock_connection.post "/v1/projects/#{project}/topics/#{topic_name}:publish" do |env|
          JSON.parse(env.body)["messages"].first["data"].must_equal msg_packed1
          [200, {"Content-Type"=>"application/json"},
           { messageIds: ["msg1"] }.to_json]
        end

        msg = topic.publish message1, format: :text
        msg.must_be_kind_of Gcloud::Pubsub::Message
        msg.message_id.must_equal "msg1"
        msg.attributes["format"].must_equal "text"
      end

      it "publishes multiple messages with a block" do
        mock_connection.post "/v1/projects/#{project}/topics/#{topic_name}:publish" do |env|
          JSON.parse(env.body)["messages"].first["data"].must_equal msg_packed1
          [200, {"Content-Type"=>"application/json"},
           { messageIds: ["msg1", "msg2", "msg3"] }.to_json]
        end

        msgs = topic.publish do |batch|
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
    end

    describe "created without autocomplete" do
      let(:topic) { Gcloud::Pubsub::Topic.new_lazy topic_name,
                                                   pubsub.connection,
                                                   autocreate: false }

      it "publishes a message" do
        mock_connection.post "/v1/projects/#{project}/topics/#{topic_name}:publish" do |env|
          JSON.parse(env.body)["messages"].first["data"].must_equal msg_packed1
          [200, {"Content-Type"=>"application/json"},
           { messageIds: ["msg1"] }.to_json]
        end

        msg = topic.publish message1
        msg.must_be_kind_of Gcloud::Pubsub::Message
        msg.message_id.must_equal "msg1"
      end

      it "publishes a message with attributes" do
        mock_connection.post "/v1/projects/#{project}/topics/#{topic_name}:publish" do |env|
          JSON.parse(env.body)["messages"].first["data"].must_equal msg_packed1
          [200, {"Content-Type"=>"application/json"},
           { messageIds: ["msg1"] }.to_json]
        end

        msg = topic.publish message1, format: :text
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

        msgs = topic.publish do |batch|
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
    end
  end

  describe "lazy topic that does not exist" do
    describe "created with autocreate" do
      let(:topic) { Gcloud::Pubsub::Topic.new_lazy topic_name,
                                                   pubsub.connection,
                                                   autocreate: true }

      it "publishes a message" do
        #first, failed attempt to publish
        mock_connection.post "/v1/projects/#{project}/topics/#{topic_name}:publish" do |env|
          [404, {"Content-Type"=>"application/json"},
           not_found_error_json(topic_name)]
        end
        # second, successful attempt to create topic
        mock_connection.put "/v1/projects/#{project}/topics/#{topic_name}" do |env|
          [200, {"Content-Type"=>"application/json"},
           topic_json(topic_name)]
        end
        # third, successful attempt to publish
        mock_connection.post "/v1/projects/#{project}/topics/#{topic_name}:publish" do |env|
          JSON.parse(env.body)["messages"].first["data"].must_equal msg_packed1
          [200, {"Content-Type"=>"application/json"},
           { messageIds: ["msg1"] }.to_json]
        end

        msg = topic.publish message1
        msg.must_be_kind_of Gcloud::Pubsub::Message
        msg.message_id.must_equal "msg1"
      end

      it "publishes a message with attributes" do
        #first, failed attempt to publish
        mock_connection.post "/v1/projects/#{project}/topics/#{topic_name}:publish" do |env|
          [404, {"Content-Type"=>"application/json"},
           not_found_error_json(topic_name)]
        end
        # second, successful attempt to create topic
        mock_connection.put "/v1/projects/#{project}/topics/#{topic_name}" do |env|
          [200, {"Content-Type"=>"application/json"},
           topic_json(topic_name)]
        end
        # third, successful attempt to publish
        mock_connection.post "/v1/projects/#{project}/topics/#{topic_name}:publish" do |env|
          JSON.parse(env.body)["messages"].first["data"].must_equal msg_packed1
          [200, {"Content-Type"=>"application/json"},
           { messageIds: ["msg1"] }.to_json]
        end

        msg = topic.publish message1, format: :text
        msg.must_be_kind_of Gcloud::Pubsub::Message
        msg.message_id.must_equal "msg1"
        msg.attributes["format"].must_equal "text"
      end

      it "publishes multiple messages with a block" do
        #first, failed attempt to publish
        mock_connection.post "/v1/projects/#{project}/topics/#{topic_name}:publish" do |env|
          [404, {"Content-Type"=>"application/json"},
           not_found_error_json(topic_name)]
        end
        # second, successful attempt to create topic
        mock_connection.put "/v1/projects/#{project}/topics/#{topic_name}" do |env|
          [200, {"Content-Type"=>"application/json"},
           topic_json(topic_name)]
        end
        # third, successful attempt to publish
        mock_connection.post "/v1/projects/#{project}/topics/#{topic_name}:publish" do |env|
          JSON.parse(env.body)["messages"].first["data"].must_equal msg_packed1
          JSON.parse(env.body)["messages"].last["data"].must_equal  msg_packed3
          [200, {"Content-Type"=>"application/json"},
           { messageIds: ["msg1", "msg2", "msg3"] }.to_json]
        end

        msgs = topic.publish do |batch|
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
    end

    describe "created without autocomplete" do
      let(:topic) { Gcloud::Pubsub::Topic.new_lazy topic_name,
                                                   pubsub.connection,
                                                   autocreate: false }

      it "publishes a message" do
        mock_connection.post "/v1/projects/#{project}/topics/#{topic_name}:publish" do |env|
          [404, {"Content-Type"=>"application/json"},
           not_found_error_json(topic_name)]
        end

        expect do
          topic.publish message1
        end.must_raise Gcloud::Pubsub::NotFoundError
      end

      it "publishes a message with attributes" do
        mock_connection.post "/v1/projects/#{project}/topics/#{topic_name}:publish" do |env|
          [404, {"Content-Type"=>"application/json"},
           not_found_error_json(topic_name)]
        end

        expect do
          topic.publish message1, format: :text
        end.must_raise Gcloud::Pubsub::NotFoundError
      end

      it "publishes multiple messages with a block" do
        mock_connection.post "/v1/projects/#{project}/topics/#{topic_name}:publish" do |env|
          [404, {"Content-Type"=>"application/json"},
           not_found_error_json(topic_name)]
        end

        expect do
          topic.publish do |batch|
            batch.publish message1
            batch.publish message2
            batch.publish message3, format: :none
          end
        end.must_raise Gcloud::Pubsub::NotFoundError
      end
    end
  end
end
