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

require "pubsub_helper"

# This test is a ruby version of gcloud-node's pubsub test.

describe Gcloud::Pubsub, :pubsub do
  def retrieve_topic topic_name
    pubsub.topic(topic_name) || pubsub.create_topic(topic_name)
  end

  let(:new_topic_name) {  $topic_names.first }
  let(:topic_names)    {  $topic_names.last 3 }

  before do
    # create all topics
    topic_names.each do |topic_name|
      retrieve_topic topic_name
    end
  end

  describe "Topic", :pubsub do
    it "should be listed" do
      topics = pubsub.topics
      topics.each do |topic|
        topic.must_be_kind_of Gcloud::Pubsub::Topic
      end
      topics.token.must_be :nil?
    end

    it "should return a token if there are more results" do
      topic_count = pubsub.topics.count
      topics = pubsub.topics max: (topic_count - 1)
      topics.count.must_equal (topic_count - 1)
      topics.each do |topic|
        topic.must_be_kind_of Gcloud::Pubsub::Topic
      end
      topics.token.wont_be :nil?

      # retrieve the next list of topics
      next_topics = pubsub.topics token: topics.token
      next_topics.count.must_equal 1
      next_topics.first.must_be_kind_of Gcloud::Pubsub::Topic
      next_topics.token.must_be :nil?
    end

    it "should be created" do
      topic = pubsub.create_topic new_topic_name
      topic.must_be_kind_of Gcloud::Pubsub::Topic
      topic.wont_be :nil?
      topic.delete
    end

    it "should publish a message" do
      msg_id = pubsub.topic(topic_names.first).publish "message from me"
      msg_id.wont_be :nil?
    end

    it "should publish multiple messages" do
      skip
      msg_ids = pubsub.topic(topic_names.first).publish "first message",
                                                        "second message",
                                                        "third message"
      msg_ids.wont_be :nil?
      msg_ids.count.must_equal 3
    end

    it "should be deleted" do
      old_topics_count = pubsub.topics.count
      pubsub.topics.first.delete
      pubsub.topics.count.must_equal (old_topics_count - 1)
    end
  end

  describe "Subscription" do
    def retrieve_subscription topic, subscription_name
      topic.subscription(subscription_name) ||
      topic.create_subscription(subscription_name)
    end

    let(:topic) { retrieve_topic $topic_names[1] }
    let(:subs) { [ { name: "#{$topic_prefix}-sub1",
                     options: { deadline: 30 } },
                   { name: "#{$topic_prefix}-sub2",
                     options: { deadline: 60 } }
                 ] }

    before do
      subs.each do |sub|
        retrieve_subscription topic, sub[:name]
      end
    end

    it "should list all subscriptions registered to the topic" do
      subscriptions = topic.subscriptions
      subscriptions.count.must_equal subs.count
      subscriptions.each do |subscription|
        # subscriptions on topic are strings...
        subscription.must_be_kind_of String
      end
      subscriptions.token.must_be :nil?
    end

    it "should return a token if there are more results" do
      skip
      subscriptions = topic.subscriptions max: (subs.count - 1)
      subscriptions.count.must_equal (subs.count - 1)
      subscriptions.each do |subscription|
        subscription.must_be_kind_of Gcloud::Pubsub::Subscription
      end
      subscriptions.token.wont_be :nil?

      # retrieve the next list of subscriptions
      next_subs = topic.subscriptions token: subscriptions.token
      next_subs.count.must_equal 1
      next_subs.first.must_be_kind_of Gcloud::Pubsub::Subscription
      next_subs.token.must_be :nil?
    end

    it "should allow creation of a subscription" do
      # subscription = topic.create_subscription "new-subscription"
      subscription = topic.subscribe "#{$topic_prefix}-sub3"
      subscription.wont_be :nil?
      subscription.must_be_kind_of Gcloud::Pubsub::Subscription
      subscription.delete
    end

    it "should not error when asking for a non-existent subscription" do
      subscription = topic.subscription "non-existent-subscription"
      subscription.must_be :nil?
    end

    it "should be able to pull and ack" do
      subscription = topic.subscribe "#{$topic_prefix}-sub4"
      subscription.wont_be :nil?
      subscription.must_be_kind_of Gcloud::Pubsub::Subscription
      # No events, should be empty
      events = subscription.pull
      events.must_be :empty?
      # Publish a new message
      msg = topic.publish "hello"
      msg.wont_be :nil?
      # Check it received the published message
      events = subscription.pull
      events.wont_be :empty?
      events.count.must_equal 1
      event = events.first
      event.wont_be :nil?
      event.msg.data.must_equal msg.data
      # Acknowledge the message
      subscription.ack event.ack_id
      # Remove the subscription
      subscription.delete
    end
  end
end
