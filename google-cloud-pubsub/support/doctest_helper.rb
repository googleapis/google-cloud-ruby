# Copyright 2016 Google Inc. All rights reserved.
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

require "google/cloud/pubsub"

class File
  def self.open *args
    "task completed"
  end
end

module Google
  module Cloud
    module Pubsub
      def self.stub_new
        define_singleton_method :new do |*args|
          yield *args
        end
      end
      # Create default unmocked methods that will raise if ever called
      def self.new *args
        raise "This code example is not yet mocked"
      end
      class Credentials
        # Override the default constructor
        def self.new *args
          OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
        end
      end
    end
  end
end

def mock_pubsub
  Google::Cloud::Pubsub.stub_new do |*args|
    credentials = OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
    pubsub = Google::Cloud::Pubsub::Project.new(Google::Cloud::Pubsub::Service.new("my-project", credentials))

    pubsub.service.mocked_publisher = Minitest::Mock.new
    pubsub.service.mocked_subscriber = Minitest::Mock.new
    if block_given?
      yield pubsub.service.mocked_publisher, pubsub.service.mocked_subscriber
    end

    pubsub
  end
end

YARD::Doctest.configure do |doctest|
  ##
  # SKIP
  #

  # Skip all GAPIC for now
  doctest.skip "Google::Cloud::Pubsub::V1"

  # Skip all aliases, since tests would be exact duplicates
  doctest.skip "Google::Cloud::Pubsub::Message#msg_id"
  doctest.skip "Google::Cloud::Pubsub::Project#get_topic"
  doctest.skip "Google::Cloud::Pubsub::Project#find_topic"
  doctest.skip "Google::Cloud::Pubsub::Project#new_topic"
  doctest.skip "Google::Cloud::Pubsub::Project#find_topics"
  doctest.skip "Google::Cloud::Pubsub::Project#list_topics"
  doctest.skip "Google::Cloud::Pubsub::Project#create_subscription"
  doctest.skip "Google::Cloud::Pubsub::Project#new_subscription"
  doctest.skip "Google::Cloud::Pubsub::Project#get_subscription"
  doctest.skip "Google::Cloud::Pubsub::Project#find_subscription"
  doctest.skip "Google::Cloud::Pubsub::Project#find_subscriptions"
  doctest.skip "Google::Cloud::Pubsub::Project#list_subscriptions"
  doctest.skip "Google::Cloud::Pubsub::Project#find_snapshots"
  doctest.skip "Google::Cloud::Pubsub::Project#list_snapshots"
  doctest.skip "Google::Cloud::Pubsub::Subscription#ack"
  doctest.skip "Google::Cloud::Pubsub::Subscription#new_snapshot"
  doctest.skip "Google::Cloud::Pubsub::Topic#create_subscription"
  doctest.skip "Google::Cloud::Pubsub::Topic#new_subscription"
  doctest.skip "Google::Cloud::Pubsub::Topic#get_subscription"
  doctest.skip "Google::Cloud::Pubsub::Topic#find_subscription"
  doctest.skip "Google::Cloud::Pubsub::Topic#find_subscriptions"
  doctest.skip "Google::Cloud::Pubsub::Topic#list_subscriptions"

  doctest.before "Google::Cloud.pubsub" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :publish, OpenStruct.new(message_ids: ["1"]), ["projects/my-project/topics/my-topic", [pubsub_message], Hash]
    end
  end

  doctest.before "Google::Cloud#pubsub" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :publish, OpenStruct.new(message_ids: ["1"]), ["projects/my-project/topics/my-topic", [pubsub_message], Hash]
    end
  end

  doctest.before "Google::Cloud::Pubsub" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :publish, OpenStruct.new(message_ids: ["1"]), ["projects/my-project/topics/my-topic", [pubsub_message], Hash]
    end
  end

  doctest.skip "Google::Cloud::Pubsub::Credentials" # occasionally getting "This code example is not yet mocked"

  doctest.before "Google::Cloud::Pubsub::Message" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :publish, OpenStruct.new(message_ids: ["1"]), ["projects/my-project/topics/my-topic", [pubsub_message], Hash]
      mock_subscriber.expect :get_subscription, subscription_resp, ["projects/my-project/subscriptions/my-topic-sub", Hash]
      mock_subscriber.expect :pull, OpenStruct.new(received_messages: [OpenStruct.new(message: pubsub_message)]), ["projects/my-project/subscriptions/my-sub", 100, Hash]
    end
  end

  # Policy

  doctest.before "Google::Cloud::Pubsub::Policy" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :get_iam_policy, policy_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :set_iam_policy, policy_resp, ["projects/my-project/topics/my-topic", Google::Iam::V1::Policy, Hash]
    end
  end

  ##
  # Project

  doctest.before "Google::Cloud::Pubsub::Project" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :publish, OpenStruct.new(message_ids: ["1"]), ["projects/my-project/topics/my-topic", [pubsub_message("task completed")], Hash]
    end
  end

  doctest.before "Google::Cloud::Pubsub::Project#topic" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/existing-topic", Hash]
    end
  end

  doctest.before "Google::Cloud::Pubsub::Project#topic@By default `nil` will be returned if topic does not exist." do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/non-existing-topic", Hash]
    end
  end

  doctest.before "Google::Cloud::Pubsub::Project#topic@Create topic in a different project with the `project` flag." do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/another-topic", Hash]
    end
  end

  doctest.before "Google::Cloud::Pubsub::Project#topic@Configuring AsyncPublisher to increase concurrent callbacks:" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :publish, OpenStruct.new(message_ids: ["1"]), ["projects/my-project/topics/my-topic", [pubsub_message("task completed")], Hash]
    end
  end

  doctest.before "Google::Cloud::Pubsub::Project#create_topic" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :create_topic, nil, ["projects/my-project/topics/my-topic", Hash]
    end
  end

  doctest.before "Google::Cloud::Pubsub::Project#topics" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :list_topics, list_topics_paged_enum, ["projects/my-project", Hash]
    end
  end

  doctest.before "Google::Cloud::Pubsub::Project#subscription" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp, ["projects/my-project/subscriptions/my-sub", Hash]
    end
  end

  doctest.before "Google::Cloud::Pubsub::Project#subscriptions" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :list_subscriptions, list_subscriptions_resp, ["projects/my-project", Hash]
      mock_subscriber.expect :list_subscriptions, list_subscriptions_resp(nil), ["projects/my-project", Hash]
    end
  end

  doctest.before "Google::Cloud::Pubsub::Project#snapshots" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :list_snapshots, list_snapshots_resp, ["projects/my-project", Hash]
      mock_subscriber.expect :list_snapshots, list_snapshots_resp(nil), ["projects/my-project", Hash]
    end
  end

  ##
  # ReceivedMessage

  doctest.before "Google::Cloud::Pubsub::ReceivedMessage" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp, ["projects/my-project/subscriptions/my-topic-sub", Hash]
      mock_subscriber.expect :pull, OpenStruct.new(received_messages: [Google::Pubsub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)]), ["projects/my-project/subscriptions/my-sub", 100, Hash]
      mock_subscriber.expect :acknowledge, nil, ["projects/my-project/subscriptions/my-sub", ["2"], Hash]
    end
  end

  doctest.before "Google::Cloud::Pubsub::ReceivedMessage#delay!" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp, ["projects/my-project/subscriptions/my-topic-sub", Hash]
      mock_subscriber.expect :pull, OpenStruct.new(received_messages: [Google::Pubsub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)]), ["projects/my-project/subscriptions/my-sub", 100, Hash]
      mock_subscriber.expect :modify_ack_deadline, nil, ["projects/my-project/subscriptions/my-sub", ["2"], 120, Hash]
    end
  end
  doctest.before "Google::Cloud::Pubsub::ReceivedMessage#modify_ack_deadline!" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp, ["projects/my-project/subscriptions/my-topic-sub", Hash]
      mock_subscriber.expect :pull, OpenStruct.new(received_messages: [Google::Pubsub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)]), ["projects/my-project/subscriptions/my-sub", 100, Hash]
      mock_subscriber.expect :modify_ack_deadline, nil, ["projects/my-project/subscriptions/my-sub", ["2"], 120, Hash]
    end
  end

  doctest.before "Google::Cloud::Pubsub::ReceivedMessage#reject!" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp, ["projects/my-project/subscriptions/my-topic-sub", Hash]
      mock_subscriber.expect :pull, OpenStruct.new(received_messages: [Google::Pubsub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)]), ["projects/my-project/subscriptions/my-sub", 100, Hash]
      mock_subscriber.expect :modify_ack_deadline, nil, ["projects/my-project/subscriptions/my-sub", ["2"], 0, Hash]
    end
  end
  doctest.before "Google::Cloud::Pubsub::ReceivedMessage#nack!" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp, ["projects/my-project/subscriptions/my-topic-sub", Hash]
      mock_subscriber.expect :pull, OpenStruct.new(received_messages: [Google::Pubsub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)]), ["projects/my-project/subscriptions/my-sub", 100, Hash]
      mock_subscriber.expect :modify_ack_deadline, nil, ["projects/my-project/subscriptions/my-sub", ["2"], 0, Hash]
    end
  end
  doctest.before "Google::Cloud::Pubsub::ReceivedMessage#ignore!" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp, ["projects/my-project/subscriptions/my-topic-sub", Hash]
      mock_subscriber.expect :pull, OpenStruct.new(received_messages: [Google::Pubsub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)]), ["projects/my-project/subscriptions/my-sub", 100, Hash]
      mock_subscriber.expect :modify_ack_deadline, nil, ["projects/my-project/subscriptions/my-sub", ["2"], 0, Hash]
    end
  end

  ##
  # Snapshot

  doctest.before "Google::Cloud::Pubsub::Snapshot" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp, ["projects/my-project/subscriptions/my-sub", Hash]
      mock_subscriber.expect :create_snapshot, snapshot_resp, ["projects/my-project/snapshots/my-snapshot", "projects/my-project/subscriptions/my-sub", Hash]
    end
  end

  doctest.before "Google::Cloud::Pubsub::Snapshot#delete" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :list_snapshots, list_snapshots_resp, ["projects/my-project", Hash]
      mock_subscriber.expect :delete_snapshot, nil, [String, Hash]
      mock_subscriber.expect :delete_snapshot, nil, [String, Hash]
      mock_subscriber.expect :delete_snapshot, nil, [String, Hash]
    end
  end

  ##
  # Snapshot::List

  doctest.before "Google::Cloud::Pubsub::Snapshot::List" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :list_snapshots, list_snapshots_resp, ["projects/my-project", Hash]
      mock_subscriber.expect :list_snapshots, list_snapshots_resp(nil), ["projects/my-project", Hash]
    end
  end


  ##
  # Subscription

  doctest.before "Google::Cloud::Pubsub::Subscription" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp("my-topic-sub"), ["projects/my-project/subscriptions/my-topic-sub", Hash]
      mock_subscriber.expect :pull, OpenStruct.new(received_messages: [Google::Pubsub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)]), ["projects/my-project/subscriptions/my-topic-sub", 100, Hash]
      mock_subscriber.expect :acknowledge, nil, ["projects/my-project/subscriptions/my-topic-sub", ["2"], Hash]
    end
  end

  doctest.before "Google::Cloud::Pubsub::Subscription#delay" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp("my-topic-sub"), ["projects/my-project/subscriptions/my-topic-sub", Hash]
      mock_subscriber.expect :pull, OpenStruct.new(received_messages: [Google::Pubsub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)]), ["projects/my-project/subscriptions/my-topic-sub", 100, Hash]
      mock_subscriber.expect :modify_ack_deadline, nil, ["projects/my-project/subscriptions/my-topic-sub", ["2"], 120, Hash]
    end
  end
  doctest.before "Google::Cloud::Pubsub::Subscription#modify_ack_deadline" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp("my-topic-sub"), ["projects/my-project/subscriptions/my-topic-sub", Hash]
      mock_subscriber.expect :pull, OpenStruct.new(received_messages: [Google::Pubsub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)]), ["projects/my-project/subscriptions/my-topic-sub", 100, Hash]
      mock_subscriber.expect :modify_ack_deadline, nil, ["projects/my-project/subscriptions/my-topic-sub", ["2"], 120, Hash]
    end
  end

  doctest.before "Google::Cloud::Pubsub::Subscription#delete" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp("my-topic-sub"), ["projects/my-project/subscriptions/my-topic-sub", Hash]
      mock_subscriber.expect :delete_subscription, subscription_resp, ["projects/my-project/subscriptions/my-topic-sub", Hash]
    end
  end

  doctest.before "Google::Cloud::Pubsub::Subscription#policy" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp("my-subscription"), ["projects/my-project/subscriptions/my-subscription", Hash]
      mock_subscriber.expect :get_iam_policy, policy_resp, ["projects/my-project/subscriptions/my-subscription", Hash]
      mock_subscriber.expect :set_iam_policy, policy_resp, ["projects/my-project/subscriptions/my-subscription", Google::Iam::V1::Policy, Hash]
    end
  end

  doctest.before "Google::Cloud::Pubsub::Subscription#pull@A maximum number of messages returned can also be specified:" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp("my-topic-sub"), ["projects/my-project/subscriptions/my-topic-sub", Hash]
      mock_subscriber.expect :pull, OpenStruct.new(received_messages: [Google::Pubsub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)]), ["projects/my-project/subscriptions/my-topic-sub", 10, Hash]
      mock_subscriber.expect :acknowledge, nil, ["projects/my-project/subscriptions/my-topic-sub", ["2"], Hash]
    end
  end

  doctest.before "Google::Cloud::Pubsub::Subscription#test_permissions" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp("my-subscription"), ["projects/my-project/subscriptions/my-subscription", Hash]
      mock_subscriber.expect :get_iam_policy, policy_resp, ["projects/my-project/subscriptions/my-subscription", Hash]
      mock_subscriber.expect :test_iam_permissions, subscription_permissions_resp, ["projects/my-project/subscriptions/my-subscription", ["pubsub.subscriptions.get", "pubsub.subscriptions.consume"], Hash]
    end
  end

  doctest.before "Google::Cloud::Pubsub::Subscription#topic" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp("my-topic-sub"), ["projects/my-project/subscriptions/my-topic-sub", Hash]
      mock_subscriber.expect :pull, OpenStruct.new(received_messages: [Google::Pubsub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)]), ["projects/my-project/subscriptions/my-topic-sub", 100, Hash]
      mock_subscriber.expect :acknowledge, nil, ["projects/my-project/subscriptions/my-topic-sub", ["2"], Hash]
    end
  end

  doctest.before "Google::Cloud::Pubsub::Subscription#create_snapshot" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp, ["projects/my-project/subscriptions/my-sub", Hash]
      mock_subscriber.expect :create_snapshot, snapshot_resp, ["projects/my-project/snapshots/my-snapshot", "projects/my-project/subscriptions/my-sub", Hash]
    end
  end

  doctest.before "Google::Cloud::Pubsub::Subscription#create_snapshot@Without providing a name:" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp, ["projects/my-project/subscriptions/my-sub", Hash]
      mock_subscriber.expect :create_snapshot, snapshot_resp("gcr-analysis-..."), [nil, "projects/my-project/subscriptions/my-sub", Hash]
    end
  end

  doctest.before "Google::Cloud::Pubsub::Subscription#seek" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp("my-sub"), ["projects/my-project/subscriptions/my-sub", Hash]
      mock_subscriber.expect :create_snapshot, snapshot_resp("gcr-analysis-..."), [nil, "projects/my-project/subscriptions/my-sub", Hash]
      mock_subscriber.expect :pull, OpenStruct.new(received_messages: [Google::Pubsub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)]), ["projects/my-project/subscriptions/my-sub", 100, Hash]
      mock_subscriber.expect :acknowledge, nil, ["projects/my-project/subscriptions/my-sub", ["2"], Hash]
      mock_subscriber.expect :seek, nil, ["projects/my-project/subscriptions/my-sub", Hash]
    end
  end

  ##
  # Subscription::List

  doctest.before "Google::Cloud::Pubsub::Subscription::List" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :list_subscriptions, list_subscriptions_resp, ["projects/my-project", Hash]
      mock_subscriber.expect :list_subscriptions, list_subscriptions_resp(nil), ["projects/my-project", Hash]
    end
  end

  ##
  # Subscriber

  doctest.before "Google::Cloud::Pubsub::Subscriber" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp("my-topic-sub"), ["projects/my-project/subscriptions/my-topic-sub", Hash]
      mock_subscriber.expect :pull, OpenStruct.new(received_messages: [Google::Pubsub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)]), ["projects/my-project/subscriptions/my-topic-sub", 100, Hash]
      mock_subscriber.expect :acknowledge, nil, ["projects/my-project/subscriptions/my-topic-sub", ["2"], Hash]
    end
  end

  ##
  # Topic

  doctest.before "Google::Cloud::Pubsub::Topic" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :publish, OpenStruct.new(message_ids: ["1"]), ["projects/my-project/topics/my-topic", [pubsub_message("task completed")], Hash]
    end
  end

  doctest.before "Google::Cloud::Pubsub::Topic#delete" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :delete_topic, nil, ["projects/my-project/topics/my-topic", Hash]
    end
  end

  doctest.before "Google::Cloud::Pubsub::Topic#policy" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :get_iam_policy, policy_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :set_iam_policy, policy_resp, ["projects/my-project/topics/my-topic", Google::Iam::V1::Policy, Hash]
    end
  end

  doctest.before "Google::Cloud::Pubsub::Topic#policy@Use `force` to retrieve the latest policy from the service:" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :get_iam_policy, policy_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :get_iam_policy, policy_resp, ["projects/my-project/topics/my-topic", Hash]
    end
  end

  doctest.before "Google::Cloud::Pubsub::Topic#publish" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :publish, OpenStruct.new(message_ids: ["1"]), ["projects/my-project/topics/my-topic", [pubsub_message("task completed")], Hash]
    end
  end

  doctest.before "Google::Cloud::Pubsub::Topic#publish@Additionally, a message can be published with attributes:" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :publish, OpenStruct.new(message_ids: ["1"]), ["projects/my-project/topics/my-topic", [pubsub_message("task completed", {"foo"=>"bar", "this"=>"that"})], Hash]
    end
  end

  doctest.before "Google::Cloud::Pubsub::Topic#publish@Multiple messages can be sent at the same time using a block:" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      messages = [
        pubsub_message("task 1 completed", { "foo" => "bar" }),
        pubsub_message("task 2 completed", { "foo" => "baz" }),
        pubsub_message("task 3 completed", { "foo" => "bif" })
      ]
      mock_publisher.expect :publish, OpenStruct.new(message_ids: ["1", "2", "3"]), ["projects/my-project/topics/my-topic", messages, Hash]
    end
  end

  doctest.before "Google::Cloud::Pubsub::Topic#subscribe" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_subscriber.expect :create_subscription, OpenStruct.new(name: "my-topic-sub"), ["projects/my-project/subscriptions/my-topic-sub", "projects/my-project/topics/my-topic", Hash]
    end
  end

  doctest.before "Google::Cloud::Pubsub::Topic#subscription" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_subscriber.expect :get_subscription, subscription_resp("my-topic-sub"), ["projects/my-project/subscriptions/my-topic-sub", Hash]
    end
  end

  doctest.before "Google::Cloud::Pubsub::Topic#subscriptions" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :list_topic_subscriptions, list_subscriptions_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :list_topic_subscriptions, list_subscriptions_resp(nil), ["projects/my-project/topics/my-topic", Hash]
    end
  end

  doctest.before "Google::Cloud::Pubsub::Topic#test_permissions" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :get_iam_policy, policy_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :test_iam_permissions, topic_permissions_resp, ["projects/my-project/topics/my-topic", ["pubsub.topics.get", "pubsub.topics.publish"], Hash]
    end
  end

  ##
  # Topic::List

  doctest.before "Google::Cloud::Pubsub::Topic::List" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :list_topics, list_topics_paged_enum, ["projects/my-project", Hash]
    end
  end

  ##
  # BatchPublisher

  doctest.before "Google::Cloud::Pubsub::BatchPublisher" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      messages = [
        pubsub_message("task 1 completed", { "foo" => "bar" }),
        pubsub_message("task 2 completed", { "foo" => "baz" }),
        pubsub_message("task 3 completed", { "foo" => "bif" })
      ]
      mock_publisher.expect :publish, OpenStruct.new(message_ids: ["1", "2", "3"]), ["projects/my-project/topics/my-topic", messages, Hash]
    end
  end


end

# Fixture helpers

def pubsub_message data = "task completed", attributes = {}
  Google::Pubsub::V1::PubsubMessage.new data: data, attributes: attributes, message_id: "", publish_time: nil
end

def list_topics_paged_enum
  OpenStruct.new(page: OpenStruct.new(response: OpenStruct.new(topics: [])))
end


def token_options token
  Google::Gax::CallOptions.new(kwargs: { "google-cloud-resource-prefix" => "projects/#{project}" },
                               page_token: token)
end

def topics_json num_topics, token = ""
  topics = num_topics.times.map do
    topic_resp "topic-#{rand 1000}"
  end
  data = { "topics" => topics }
  data["next_page_token"] = token unless token.nil?
  data.to_json
end

def topic_resp topic_name = "my-topic"
  Google::Pubsub::V1::Topic.new name: topic_path(topic_name)
end

def topic_subscriptions_json num_subs, token = nil
  subs = num_subs.times.map do
    subscription_path("sub-#{rand 1000}")
  end
  data = { "subscriptions" => subs }
  data["next_page_token"] = token unless token.nil?
  data.to_json
end

def subscriptions_json topic_name, num_subs, token = nil
  subs = num_subs.times.map do
    JSON.parse(subscription_json(topic_name, "sub-#{rand 1000}"))
  end
  data = { "subscriptions" => subs }
  data["next_page_token"] = token unless token.nil?
  data.to_json
end

def subscription_json topic_name, sub_name,
                      deadline = 60,
                      endpoint = "http://example.com/callback"
  { "name" => subscription_path(sub_name),
    "topic" => topic_path(topic_name),
    "push_config" => { "push_endpoint" => endpoint },
    "ack_deadline_seconds" => deadline,
  }.to_json
end

def snapshots_json topic_name, num_snapshots, token = nil
  snapshots = num_snapshots.times.map do
    JSON.parse(snapshot_json(topic_name, "snapshot-#{rand 1000}"))
  end
  data = { "snapshots" => snapshots }
  data["next_page_token"] = token unless token.nil?
  data.to_json
end

def snapshot_json topic_name, snapshot_name
  time = Time.now
  timestamp = {
    "seconds" => time.to_i,
    "nanos" => time.nsec
  }
  { "name" => snapshot_path(snapshot_name),
    "topic" => topic_path(topic_name),
    "expire_time" => timestamp
  }.to_json
end

def rec_message_json message, id = rand(1000000)
  {
    "ack_id" => "ack-id-#{id}",
    "message" => {
      "data" => Base64.strict_encode64(message),
      "attributes" => {},
      "message_id" => "msg-id-#{id}",
    }
  }.to_json
end

def rec_messages_json message, id = nil
  {
    "received_messages" => [
      JSON.parse(rec_message_json(message, id))
    ]
  }.to_json
end

def project_path
  "projects/my-project"
end

def topic_path topic_name
  "#{project_path}/topics/#{topic_name}"
end

def subscription_path subscription_name
  "#{project_path}/subscriptions/#{subscription_name}"
end

def snapshot_path snapshot_name
  "#{project_path}/snapshots/#{snapshot_name}"
end

def paged_enum_struct response
  OpenStruct.new page: OpenStruct.new(response: response)
end


def subscription_resp name = "my-sub"
  Google::Pubsub::V1::Subscription.decode_json subscription_json "my-topic", name
end


def list_subscriptions_resp token = "next_page_token"
  response = Google::Pubsub::V1::ListSubscriptionsResponse.decode_json subscriptions_json("my-topic", 3, token)
  paged_enum_struct response
end

def list_snapshots_resp token = "next_page_token"
  response = Google::Pubsub::V1::ListSnapshotsResponse.decode_json snapshots_json("my-topic", 3, token)
  paged_enum_struct response
end

def snapshot_resp snapshot_name = "my-snapshot"
  Google::Pubsub::V1::Snapshot.decode_json snapshot_json("my-topic", snapshot_name)
end

def policy_resp
  Google::Iam::V1::Policy.new(
    bindings: [
      Google::Iam::V1::Binding.new(
        role: "roles/storage.objectViewer",
        members: [
          "user:viewer@example.com"
        ]
      )
    ]
  )
end

def subscription_permissions_resp
  Google::Iam::V1::TestIamPermissionsResponse.new(
    permissions: ["pubsub.subscriptions.get"]
  )
end

def topic_permissions_resp
  Google::Iam::V1::TestIamPermissionsResponse.new(
    permissions: ["pubsub.topics.get"]
  )
end
