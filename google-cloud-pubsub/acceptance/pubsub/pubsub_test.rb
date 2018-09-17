# Copyright 2015 Google LLC
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

require "pubsub_helper"

# This test is a ruby version of gcloud-node's pubsub test.

describe Google::Cloud::Pubsub, :pubsub do
  def retrieve_topic topic_name
    pubsub.get_topic(topic_name) || pubsub.create_topic(topic_name)
  end

  def retrieve_subscription topic, subscription_name
    topic.get_subscription(subscription_name) ||
      topic.subscribe(subscription_name)
  end

  def retrieve_snapshot project, subscription, snapshot_name
    existing = project.snapshots.detect { |s| s.name.split("/").last == snapshot_name }
    existing || subscription.create_snapshot(snapshot_name)
  end

  let(:new_topic_name)  {  $topic_names[0] }
  let(:topic_names)     {  $topic_names[3..6] }
  let(:lazy_topic_name) {  $topic_names[7] }
  let(:labels) { { "foo" => "bar" } }

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
        topic.must_be_kind_of Google::Cloud::Pubsub::Topic
      end
      topics.token.must_be :nil?
    end

    it "should return a token if there are more results" do
      topic_count = pubsub.topics.count
      topics = pubsub.topics max: (topic_count - 1)
      topics.count.must_equal (topic_count - 1)
      topics.each do |topic|
        topic.must_be_kind_of Google::Cloud::Pubsub::Topic
      end
      topics.token.wont_be :nil?

      # retrieve the next list of topics
      next_topics = pubsub.topics token: topics.token
      next_topics.count.must_equal 1
      next_topics.first.must_be_kind_of Google::Cloud::Pubsub::Topic
      next_topics.token.must_be :nil?
    end

    it "should be created and deleted" do
      topic = pubsub.create_topic new_topic_name, labels: labels
      topic.must_be_kind_of Google::Cloud::Pubsub::Topic
      topic = pubsub.topic(topic.name)
      topic.wont_be :nil?
      topic.labels.must_equal labels
      topic.labels.must_be :frozen?
      topic.delete
      pubsub.topic(topic.name).must_be :nil?
    end

    it "should publish a message" do
      data = "message from me"
      msg = pubsub.topic(topic_names.first).publish data, foo: :bar

      msg.wont_be :nil?
      msg.must_be_kind_of Google::Cloud::Pubsub::Message
      msg.data.must_equal data
      msg.attributes["foo"].must_equal "bar"
    end

    it "should publish multiple messages" do
      msgs = pubsub.topic(topic_names.first).publish do |batch|
        batch.publish "first message"
        batch.publish "second message"
        batch.publish "third message", format: :text
      end

      msgs.wont_be :nil?
      msgs.count.must_equal 3
      msgs.each { |msg| msg.must_be_kind_of Google::Cloud::Pubsub::Message }
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
        subscription.must_be_kind_of Google::Cloud::Pubsub::Subscription
      end
      subscriptions.token.must_be :nil?
    end

    it "should return a token if there are more results" do
      sub_count = pubsub.subscriptions.count
      subscriptions = pubsub.subscriptions max: (sub_count - 1)
      subscriptions.count.must_equal (sub_count - 1)
      subscriptions.each do |subscription|
        subscription.must_be_kind_of Google::Cloud::Pubsub::Subscription
      end
      subscriptions.token.wont_be :nil?

      # retrieve the next list of subscriptions
      next_subs = pubsub.subscriptions token: subscriptions.token
      next_subs.count.must_equal 1
      next_subs.first.must_be_kind_of Google::Cloud::Pubsub::Subscription
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
        subscription.must_be_kind_of Google::Cloud::Pubsub::Subscription
      end
      subscriptions.token.must_be :nil?
    end

    it "should return a token if there are more results" do
      subscriptions = topic.subscriptions max: (subs.count - 1)
      subscriptions.count.must_equal (subs.count - 1)
      subscriptions.each do |subscription|
        subscription.must_be_kind_of Google::Cloud::Pubsub::Subscription
      end
      subscriptions.token.wont_be :nil?

      # retrieve the next list of subscriptions
      next_subs = topic.subscriptions token: subscriptions.token
      next_subs.count.must_equal 1
      next_subs.first.must_be_kind_of Google::Cloud::Pubsub::Subscription
      next_subs.token.must_be :nil?
    end

    it "should allow creation of a subscription with options" do
      subscription = topic.subscribe "#{$topic_prefix}-sub3", retain_acked: true, retention: 600, labels: labels
      subscription.wont_be :nil?
      subscription.must_be_kind_of Google::Cloud::Pubsub::Subscription
      assert subscription.retain_acked
      subscription.retention.must_equal 600
      subscription.labels.must_equal labels
      subscription.labels.must_be :frozen?
      subscription.labels = {}
      subscription.labels.must_be :empty?
      subscription.delete
    end

    it "should not error when asking for a non-existent subscription" do
      subscription = topic.get_subscription "non-existent-subscription"
      subscription.must_be :nil?
    end

    it "should be able to pull and ack" do
      subscription = topic.subscribe "#{$topic_prefix}-sub4"
      subscription.wont_be :nil?
      subscription.must_be_kind_of Google::Cloud::Pubsub::Subscription
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
      event.msg.published_at.wont_be :nil?
      # Acknowledge the message
      subscription.ack event.ack_id
      # Remove the subscription
      subscription.delete
    end

    it "should be able to pull same message again after ack by seeking to snapshot" do
      subscription = topic.subscribe "#{$topic_prefix}-sub5"
      subscription.wont_be :nil?
      subscription.must_be_kind_of Google::Cloud::Pubsub::Subscription

      # No messages, should be empty
      events = subscription.pull
      events.must_be :empty?
      # Publish a new message
      msg = topic.publish "hello-#{rand(1000)}"
      msg.wont_be :nil?

      snapshot = subscription.create_snapshot labels: labels

      # Check it pulls the message
      events = pull_with_retry subscription
      events.wont_be :empty?
      events.count.must_equal 1
      event = events.first
      event.wont_be :nil?
      event.msg.data.must_equal msg.data
      event.msg.published_at.wont_be :nil?
      # Acknowledge the message
      subscription.ack event.ack_id

      # No messages, should be empty
      events = subscription.pull
      events.must_be :empty?

      # Reset to the snapshot
      subscription.seek snapshot

      # Check it again pulls the message
      events = pull_with_retry subscription
      events.wont_be :empty?
      events.count.must_equal 1
      event = events.first
      event.wont_be :nil?
      event.msg.data.must_equal msg.data
      # Acknowledge the message
      subscription.ack event.ack_id
      # No messages, should be empty
      events = subscription.pull
      events.must_be :empty?

      # No messages, should be empty
      events = subscription.pull
      events.must_be :empty?

      snapshot.labels.must_equal labels
      snapshot.labels.must_be :frozen?
      snapshot.labels = {}
      snapshot.labels.must_be :empty?

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

  describe "IAM Policies and Permissions" do
    let(:topic) { retrieve_topic $topic_names[3] }
    let(:subscription) { retrieve_subscription topic, "#{$topic_prefix}-subIAM" }
    let(:service_account) { pubsub.service.credentials.client.issuer }

    it "allows policy to be updated on a topic" do
      # Check permissions first
      roles = ["pubsub.topics.getIamPolicy", "pubsub.topics.setIamPolicy"]
      permissions = topic.test_permissions roles
      skip "Don't have permissions to get/set topic's policy" unless permissions == roles

      topic.policy.must_be_kind_of Google::Cloud::Pubsub::Policy

      # We need a valid service account in order to update the policy
      service_account.wont_be :nil?
      role = "roles/pubsub.publisher"
      member = "serviceAccount:#{service_account}"
      topic.policy do |p|
        p.add role, member
        p.add role, member # duplicate member will not be added to request
      end

      role_member = topic.policy.role(role).select { |x| x == member }
      role_member.size.must_equal 1
    end

    it "allows policy to be updated on a subscription" do
      # Check permissions first
      roles = ["pubsub.subscriptions.getIamPolicy", "pubsub.subscriptions.setIamPolicy"]
      permissions = subscription.test_permissions roles
      skip "Don't have permissions to get/set subscription's policy" unless permissions == roles

      subscription.policy.must_be_kind_of Google::Cloud::Pubsub::Policy

      # We need a valid service account in order to update the policy
      service_account.wont_be :nil?
      role = "roles/pubsub.subscriber"
      member = "serviceAccount:#{service_account}"
      subscription.policy do |p|
        p.add role, member
      end

      subscription.policy.role(role).must_include member
    end

    it "allows permissions to be tested on a topic" do
      roles = ["pubsub.topics.get", "pubsub.topics.publish"]
      permissions = topic.test_permissions roles
      permissions.must_equal roles
    end

    it "allows permissions to be tested on a subscription" do
      roles = ["pubsub.subscriptions.consume", "pubsub.subscriptions.get"]
      permissions = subscription.test_permissions roles
      permissions.must_equal roles
    end
  end

  describe "Snapshots on Project" do
    let(:topic) { retrieve_topic $topic_names[4] }
    let(:subscription) { retrieve_subscription topic, "#{$topic_prefix}-subSnapshots" }

    before do
      3.times.each do |i|
        retrieve_snapshot pubsub, subscription, $snapshot_names[i]
      end
    end

    it "should list all snapshots registered to the project" do
      snapshots = pubsub.snapshots
      snapshots.each do |snapshot|
        # snapshots on project are objects...
        snapshot.must_be_kind_of Google::Cloud::Pubsub::Snapshot
      end
      snapshots.token.must_be :nil?
    end

    it "should return a token if there are more results" do
      sub_count = pubsub.snapshots.count
      snapshots = pubsub.snapshots max: (sub_count - 1)
      snapshots.count.must_equal (sub_count - 1)
      snapshots.each do |snapshot|
        snapshot.must_be_kind_of Google::Cloud::Pubsub::Snapshot
      end
      snapshots.token.wont_be :nil?

      # retrieve the next list of snapshots
      next_subs = pubsub.snapshots token: snapshots.token
      next_subs.count.must_equal 1
      next_subs.first.must_be_kind_of Google::Cloud::Pubsub::Snapshot
      next_subs.token.must_be :nil?
    end
  end
end
