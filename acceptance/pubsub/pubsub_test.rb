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
    pubsub.get_topic(topic_name) || pubsub.create_topic(topic_name)
  end

  def retrieve_subscription topic, subscription_name
    topic.get_subscription(subscription_name) ||
    topic.subscribe(subscription_name)
  end

  let(:new_topic_name)  {  $topic_names[0] }
  let(:topic_names)     {  $topic_names[3..5] }
  let(:lazy_topic_name) {  $topic_names[6] }

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
      msg = pubsub.topic(topic_names.first).publish "message from me"
      msg.wont_be :nil?
      msg.must_be_kind_of Gcloud::Pubsub::Message
    end

    it "should publish multiple messages" do
      msgs = pubsub.topic(topic_names.first).publish do |batch|
        batch.publish "first message"
        batch.publish "second message"
        batch.publish "third message", format: :text
      end

      msgs.wont_be :nil?
      msgs.count.must_equal 3
      msgs.each { |msg| msg.must_be_kind_of Gcloud::Pubsub::Message }
    end

    it "should be deleted" do
      old_topics_count = pubsub.topics.count
      pubsub.topics.first.delete
      pubsub.topics.count.must_equal (old_topics_count - 1)
    end

    describe :lazy do
      it "gets a lazy topic object that can create itself" do
        lazy_topic = pubsub.topic lazy_topic_name
        lazy_topic.must_be :lazy?
        lazy_topic.must_be :autocreate?
        lazy_topic.wont_be :exists?
        lazy_topic.publish "this will create the topic"
        lazy_topic.must_be :exists?
      end
    end
  end

  describe "Subscriptions on Project" do
    let(:topic) { retrieve_topic $topic_names[2] }

    before do
      3.times.each do |i|
        retrieve_subscription topic, "#{$topic_prefix}-sub-0#{i}"
      end
    end

    it "should list all subscriptions registered to the topic" do
      subscriptions = pubsub.subscriptions
      subscriptions.each do |subscription|
        # subscriptions on project are objects...
        subscription.must_be_kind_of Gcloud::Pubsub::Subscription
      end
      subscriptions.token.must_be :nil?
    end

    it "should return a token if there are more results" do
      sub_count = pubsub.subscriptions.count
      subscriptions = pubsub.subscriptions max: (sub_count - 1)
      subscriptions.count.must_equal (sub_count - 1)
      subscriptions.each do |subscription|
        subscription.must_be_kind_of Gcloud::Pubsub::Subscription
      end
      subscriptions.token.wont_be :nil?

      # retrieve the next list of subscriptions
      next_subs = pubsub.subscriptions token: subscriptions.token
      next_subs.count.must_equal 1
      next_subs.first.must_be_kind_of Gcloud::Pubsub::Subscription
      next_subs.token.must_be :nil?
    end
  end

  describe "Subscription on Topic" do
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
        subscription.must_be_kind_of Gcloud::Pubsub::Subscription
      end
      subscriptions.token.must_be :nil?
    end

    it "should return a token if there are more results" do
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
      subscription = topic.subscribe "#{$topic_prefix}-sub3"
      subscription.wont_be :nil?
      subscription.must_be_kind_of Gcloud::Pubsub::Subscription
      subscription.delete
    end

    it "should not error when asking for a non-existent subscription" do
      subscription = topic.get_subscription "non-existent-subscription"
      subscription.must_be :nil?
    end

    it "should be able to pull and ack" do
      subscription = topic.subscribe "#{$topic_prefix}-sub4"
      subscription.wont_be :nil?
      subscription.must_be_kind_of Gcloud::Pubsub::Subscription
      # No messages, should be empty
      events = subscription.pull
      events.must_be :empty?
      # Publish a new message
      msg = topic.publish "hello"
      msg.wont_be :nil?
      # Check it received the published message
      events = pull_with_retry subscription
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

    def pull_with_retry sub
      events = []
      retries = 0
      while retries <= 5 do
        events = sub.pull
        break if events.any?
        retries += 1
        puts "the subscription does not have the message yet. sleeping for #{retries*retries} second(s) and retrying."
        sleep retries*retries
      end
      events
    end
  end

  describe "Policies" do
    let(:topic) { retrieve_topic $topic_names[1] }
    let(:subs) { [ { name: "#{$topic_prefix}-sub1",
                     options: { deadline: 30 } },
                   { name: "#{$topic_prefix}-sub2",
                     options: { deadline: 60 } }
                 ] }
    let(:service_account) { pubsub.connection.credentials.client.issuer }

    before do
      subs.each do |sub|
        retrieve_subscription topic, sub[:name]
      end
    end

    it "allows policy to be set on a topic" do
      topic.policy.must_be_kind_of Hash

      role = {"role"=>"roles/pubsub.subscriber", "members"=>["serviceAccount:#{service_account}"]}
      tp = topic.policy.dup
      tp["bindings"] ||= []
      tp["bindings"] << role
      topic.policy = tp

      topic.policy(force: true)["bindings"].must_include role
    end

    it "allows policy to be set on a subscription" do
      sub = topic.subscription "#{$topic_prefix}-sub1"
      sub.policy.must_be_kind_of Hash

      role = {"role"=>"roles/pubsub.subscriber", "members"=>["serviceAccount:#{service_account}"]}
      sp = sub.policy.dup
      sp["bindings"] ||= []
      sp["bindings"] << role
      sub.policy = sp

      sub.policy(force: true)["bindings"].must_include role
    end
  end
end
