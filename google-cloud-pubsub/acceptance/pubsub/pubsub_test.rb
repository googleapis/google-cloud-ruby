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

describe Google::Cloud::PubSub, :pubsub do
  def retrieve_topic topic_name
    topic_path = pubsub.service.topic_path topic_name
    topic = $topic_admin.get_topic(topic: topic_path) rescue $topic_admin.create_topic(name: topic_path)
    topic
  end

  def retrieve_subscription topic, subscription_name, enable_message_ordering: false
    subscription_path = pubsub.service.subscription_path subscription_name
    subscription = $subscription_admin.get_subscription(subscription: subscription_path) \
      rescue $subscription_admin.create_subscription(name: subscription_path, topic: topic.name, enable_message_ordering: enable_message_ordering)
  end

  def retrieve_snapshot subscription, snapshot_name
    snapshot_path = pubsub.service.snapshot_path snapshot_name
    snapshot = $subscription_admin.get_snapshot snapshot: snapshot_path \
      rescue $subscription_admin.create_snapshot name: snapshot_path, subscription: subscription.name
  end

  let(:new_topic_name)  {  $topic_names[0] }
  let(:topic_names)     {  $topic_names[3..6] }
  let(:reference_topic_name) { $topic_names[7] }
  let(:dead_letter_topic_name) { $topic_names[8] }
  let(:dead_letter_topic_name_2) { $topic_names[9] }
  let(:labels) { { "foo" => "bar" } }
  let(:topic_retention) { 50 * 60 }
  let(:new_topic_retention) { 11 * 60 }
  let(:subscription_retention) { 10 * 60 }
  let(:filter) { "attributes.event_type = \"1\"" }

  before do
    # create all topics
    topic_names.each do |topic_name|
      retrieve_topic topic_name
    end
  end

  it "should raise when endpoint is not the Pub/Sub service" do
    skip("https://github.com/googleapis/google-cloud-ruby/issues/18275")
    pubsub_invalid_endpoint = Google::Cloud::PubSub.new endpoint: "example.com"
    expect { pubsub_invalid_endpoint.topics }.must_raise Google::Cloud::UnimplementedError
  end

  describe "Topic", :pubsub do
    it "should be listed" do
      topics = $topic_admin.list_topics(project: pubsub.service.project_path)
      topics.each do |topic|
        _(topic).must_be_kind_of Google::Cloud::PubSub::V1::Topic
      end
    end

    it "should be created, updated and deleted" do
      topic_path = pubsub.service.topic_path new_topic_name
      retention_duration = Google::Cloud::PubSub::Convert.number_to_duration topic_retention
      topic = $topic_admin.create_topic name: topic_path, labels: labels,
                                        message_retention_duration: retention_duration

      _(topic).must_be_kind_of Google::Cloud::PubSub::V1::Topic
      _(topic.labels.to_h).must_equal labels
      _(topic.message_retention_duration).must_equal retention_duration


      new_retention_duration = Google::Cloud::PubSub::Convert.number_to_duration new_topic_retention
      topic.message_retention_duration = new_retention_duration
      mask = Google::Protobuf::FieldMask.new paths: ["message_retention_duration"]
      $topic_admin.update_topic topic: topic, update_mask: mask

      # Reload topic after update
      topic = $topic_admin.get_topic topic: topic_path
      _(topic.message_retention_duration).must_equal new_retention_duration

      $topic_admin.delete_topic topic: topic.name
    end

    it "should publish a message" do
      data = "message from me"
      publisher = pubsub.publisher(topic_names.first)
      msg = publisher.publish data, foo: :bar

      _(msg).wont_be :nil?
      _(msg).must_be_kind_of Google::Cloud::PubSub::Message
      _(msg.data).must_equal data
      _(msg.attributes["foo"]).must_equal "bar"
    end

    it "should publish multiple messages" do
      publisher = pubsub.publisher(topic_names.first)
      msgs = publisher.publish do |batch|
        batch.publish "first message"
        batch.publish "second message"
        batch.publish "third message", format: :text
      end

      _(msgs).wont_be :nil?
      _(msgs.count).must_equal 3
      msgs.each { |msg| _(msg).must_be_kind_of Google::Cloud::PubSub::Message }
    end

    it "should publish messages with ordering_key" do
      #topic = $topic_admin.create_topic
      topic = retrieve_topic "#{$topic_prefix}-omt2-#{SecureRandom.hex(2)}"
      sub = retrieve_subscription topic, "#{$topic_prefix}-oms2-#{SecureRandom.hex(2)}", enable_message_ordering: true

      #sub = topic.subscribe "#{$topic_prefix}-oms2-#{SecureRandom.hex(2)}", message_ordering: true
      assert sub.enable_message_ordering

      publisher = pubsub.publisher topic.name

      publisher.publish "ordered message 0", ordering_key: "my_key"
      publisher.publish do |batch|
        batch.publish "ordered message 1", ordering_key: "my_key"
        batch.publish "ordered message 2", ordering_key: "my_key"
        batch.publish "ordered message 3", ordering_key: "my_key"
      end

      subscriber = pubsub.subscriber sub.name
      received_messages = []
      listener = subscriber.listen do |msg|
        received_messages.push msg.data
        # Acknowledge the message
        msg.ack!
      end
      listener.on_error do |error|
        fail error.inspect
      end
      listener.start

      counter = 0
      deadline = 300 # 5 min
      while received_messages.count < 4 &&  counter < deadline
        sleep 1
        counter += 1
      end

      listener.stop
      listener.wait!
      # Remove the subscription
      $subscription_admin.delete_subscription(subscription: pubsub.service.subscription_path(sub.name))

      _(received_messages).must_equal ["ordered message 0", "ordered message 1", "ordered message 2", "ordered message 3"]
    end
  end

  describe "Subscriptions on Project" do
    let(:topic) { retrieve_topic $topic_names[2] }

    before do
      3.times.each do |i|
        retrieve_subscription topic, "#{$topic_prefix}-sub-0#{i}"
      end
    end

    it "should list all subscriptions registered to the project" do
      $subscription_admin.list_subscriptions(project: pubsub.service.project_path).each do |subscription|
        # subscriptions on project are objects...
        _(subscription).must_be_kind_of Google::Cloud::PubSub::V1::Subscription
      end
    end
  end

  describe "Subscription on Topic" do
    let(:topic) { retrieve_topic $topic_names[1] }
    let(:subs) { [ { name: "#{$topic_prefix}-sub1",
                     options: { deadline: 30 } },
                   { name: "#{$topic_prefix}-sub2",
                     options: { deadline: 60 } }
                 ] }
    let(:retry_minimum_backoff) { 12.123 }
    let(:retry_maximum_backoff) { 123.321 }
    let(:retry_policy) do
      Google::Cloud::PubSub::V1::RetryPolicy.new(
          minimum_backoff: Google::Cloud::PubSub::Convert.number_to_duration(retry_minimum_backoff),
          maximum_backoff: Google::Cloud::PubSub::Convert.number_to_duration(retry_maximum_backoff)
      )
    end

    before do
      subs.each do |sub|
        retrieve_subscription topic, sub[:name]
      end
    end

    it "should list all subscriptions registered to the topic" do
      response = $topic_admin.list_topic_subscriptions(topic: topic.name)
      response.subscriptions.each do |subscription|
        _(subscription).must_be_kind_of String
      end
    end

    it "should create, update, detach and delete a subscription" do
      subscription_path = pubsub.service.subscription_path "testdetachsubsxyz-#{$topic_prefix}-sub-detach" 
      retention_duration = Google::Cloud::PubSub::Convert.number_to_duration subscription_retention

      subscription = $subscription_admin.create_subscription name: subscription_path, topic: topic.name, retain_acked_messages: true, 
                                              message_retention_duration: retention_duration, labels: labels,
                                              filter: filter, retry_policy: retry_policy
                                              
                                              
      _(subscription).wont_be :nil?
      _(subscription).must_be_kind_of Google::Cloud::PubSub::V1::Subscription
      assert subscription.retain_acked_messages
      _(subscription.message_retention_duration).must_equal retention_duration
      _(subscription.labels.to_h).must_equal labels
      _(subscription.filter).must_equal filter
      _(subscription.retry_policy).must_equal retry_policy
      _(subscription.detached).must_equal false

      # update
      subscription.retry_policy = nil
      mask = Google::Protobuf::FieldMask.new paths: ["retry_policy"]

      $subscription_admin.update_subscription subscription: subscription, update_mask: mask

      # Reload subscription after update
      subscription = $subscription_admin.get_subscription subscription: subscription.name
      _(subscription.retry_policy).must_be :nil?

      # detach
      $topic_admin.detach_subscription subscription: subscription.name

      # Per #6493, it can take 120 sec+ for the detachment to propagate. In the interim, the detached state is undefined.
      sleep 120
      subscription = $subscription_admin.get_subscription subscription: subscription.name
      _(subscription.detached).must_equal true

      # delete
    $subscription_admin.delete_subscription subscription: subscription.name
    end

    it "should be able to pull and ack" do
      begin
        subscription = retrieve_subscription topic, "#{$topic_prefix}-sub4"
        _(subscription).wont_be :nil?
        _(subscription).must_be_kind_of Google::Cloud::PubSub::V1::Subscription
        _(subscription.retry_policy).must_be :nil?
        # No messages, should be empty
        subscriber = pubsub.subscriber subscription.name
        received_messages = subscriber.pull
        _(received_messages).must_be :empty?
        # Publish a new message
        publisher = pubsub.publisher topic.name
        msg = publisher.publish "hello"
        _(msg).wont_be :nil?
        # Check it received the published message
        wait_for_condition description: "subscription pull" do
          received_messages = subscriber.pull immediate: false
          received_messages.any?
        end
        _(received_messages).wont_be :empty?
        _(received_messages.count).must_equal 1
        received_message = received_messages.first
        _(received_message).wont_be :nil?
        _(received_message.delivery_attempt).must_be :nil?
        _(received_message.msg.data).must_equal msg.data
        _(received_message.msg.published_at).wont_be :nil?
        # Acknowledge the message
        subscriber.ack received_message.ack_id
      ensure
        # Remove the subscription
        $subscription_admin.delete_subscription(subscription: subscription.name)
      end
    end

    it "should be able to pull same message again after ack by seeking to snapshot" do
      begin
        subscription = retrieve_subscription topic, "#{$topic_prefix}-sub5"
        _(subscription).wont_be :nil?
        _(subscription).must_be_kind_of Google::Cloud::PubSub::V1::Subscription

        # No messages, should be empty
        subscriber = pubsub.subscriber subscription.name
        received_messages = subscriber.pull
        _(received_messages).must_be :empty?
        # Publish a new message
        publisher = pubsub.publisher topic.name
        msg = publisher.publish "hello-#{rand(1000)}"
        _(msg).wont_be :nil?

        snapshot = $subscription_admin.create_snapshot name: nil, subscription: subscription.name, labels: labels


        # Check it pulls the message
        wait_for_condition description: "subscriber pull" do
          received_messages = subscriber.pull immediate: false
          received_messages.any?
        end
        _(received_messages).wont_be :empty?
        _(received_messages.count).must_equal 1
        received_message = received_messages.first
        _(received_message).wont_be :nil?
        _(received_message.delivery_attempt).must_be :nil?
        _(received_message.msg.data).must_equal msg.data
        _(received_message.msg.published_at).wont_be :nil?
        # Acknowledge the message
        subscriber.ack received_message.ack_id

        # No messages, should be empty
        received_messages = subscriber.pull
        _(received_messages).must_be :empty?

        # Reset to the snapshot
        $subscription_admin.seek subscription: subscription.name, snapshot: snapshot.name

        # Check it again pulls the message
        wait_for_condition description: "subscriber pull" do
          received_messages = subscriber.pull immediate: false
          received_messages.any?
        end
        _(received_messages.count).must_equal 1
        received_message = received_messages.first
        _(received_message).wont_be :nil?
        _(received_message.delivery_attempt).must_be :nil?
        _(received_message.msg.data).must_equal msg.data
        # Acknowledge the message
        subscriber.ack received_message.ack_id
        # No messages, should be empty
        received_messages = subscriber.pull
        _(received_messages).must_be :empty?

        # No messages, should be empty
        received_messages = subscriber.pull
        _(received_messages).must_be :empty?
        _(snapshot.labels.to_h).must_equal labels
      ensure
        # Remove the subscription
        $subscription_admin.delete_subscription(subscription: subscription.name)
      end
    end

    it "creates a push subscription with push_config" do
      subscription_path = pubsub.service.subscription_path "#{$topic_prefix}-sub-endpoint"
      push_config = Google::Cloud::PubSub::V1::PushConfig.new push_endpoint: "https://pub-sub.test.com/pubsub"
      subscription = $subscription_admin.create_subscription name: subscription_path, topic: topic.name, push_config: push_config

      _(subscription).must_be_kind_of Google::Cloud::PubSub::V1::Subscription
      _(subscription.push_config.push_endpoint).must_equal "https://pub-sub.test.com/pubsub"
    end

    if $project_number
      it "should be able to direct messages to a dead letter topic" do
        dead_letter_subscription_2 = nil
        begin
          dead_letter_topic = retrieve_topic dead_letter_topic_name
          subscription_path = pubsub.service.subscription_path "#{$topic_prefix}-dead-letter-sub1"
          dead_letter_subscription = $subscription_admin.create_subscription name: subscription_path, topic: dead_letter_topic.name

          # Dead Letter Queue (DLQ) testing requires IAM bindings to the Cloud Pub/Sub service account that is
          # automatically created and managed by the service team in a private project.
          service_account_email = "serviceAccount:service-#{$project_number}@gcp-sa-pubsub.iam.gserviceaccount.com"

          dead_letter_topic.policy { |p| p.add "roles/pubsub.publisher", service_account_email }
          dead_letter_subscription.policy { |p| p.add "roles/pubsub.subscriber", service_account_email }

          # create
          subscription = topic.subscribe "#{$topic_prefix}-sub6", dead_letter_topic: dead_letter_topic, dead_letter_max_delivery_attempts: 6
          _(subscription.dead_letter_topic.name).must_equal dead_letter_topic.name
          _(subscription.dead_letter_max_delivery_attempts).must_equal 6

          # Publish a new message
          msg = topic.publish "dead-letter-#{rand(1000)}"
          _(msg).wont_be :nil?

          # Nack the message
          (1..7).each do |i|
            received_messages = []
            wait_for_condition description: "subscription pull" do
              received_messages = subscription.pull immediate: false
              received_messages.any?
            end
            _(received_messages.count).must_equal 1
            received_message = received_messages.first
            _(received_message.msg.data).must_equal msg.data
            _(received_message.delivery_attempt).must_be :>, 0
            received_message.nack!
          end

          # Check the dead letter subscription pulls the message
          received_messages = []
          wait_for_condition description: "subscription pull" do
            received_messages = subscription.pull immediate: false
            received_messages.any?
          end
          _(received_messages).wont_be :empty?
          _(received_messages.count).must_equal 1
          received_message = received_messages.first
          _(received_message).wont_be :nil?
          _(received_message.msg.data).must_equal msg.data
          _(received_message.delivery_attempt).must_be :>, 0

          # update
          dead_letter_topic_2 = retrieve_topic dead_letter_topic_name_2
          dead_letter_subscription_2 = dead_letter_topic_2.subscribe "#{$topic_prefix}-dead-letter-sub2"
          subscription.dead_letter_topic = dead_letter_topic_2
          _(subscription.dead_letter_topic.name).must_equal dead_letter_topic_2.name
          _(subscription.dead_letter_max_delivery_attempts).must_equal 6

          subscription.dead_letter_max_delivery_attempts = 5
          _(subscription.dead_letter_topic.name).must_equal dead_letter_topic_2.name
          _(subscription.dead_letter_max_delivery_attempts).must_equal 5

          # delete
          removed = subscription.remove_dead_letter_policy
          _(removed).must_equal true
          _(subscription.dead_letter_topic).must_be :nil?
          _(subscription.dead_letter_max_delivery_attempts).must_be :nil?

        ensure
          # cleanup
          subscription.delete if subscription
          dead_letter_subscription.delete if dead_letter_subscription
          dead_letter_subscription_2.delete if dead_letter_subscription_2
        end
      end
    end
  end

  describe "Snapshots on Project" do
    let(:topic) { retrieve_topic $topic_names[4] }
    let(:subscription) { retrieve_subscription topic, "#{$topic_prefix}-subSnapshots" }

    before do
      3.times.each do |i|
        retrieve_snapshot subscription, $snapshot_names[i]
      end
    end

    it "should list all snapshots registered to the project" do
      $subscription_admin.list_snapshots(project: @pubsub.service.project_path).each do |snapshot|
        _(snapshot).must_be_kind_of Google::Cloud::PubSub::V1::Snapshot
      end
    end
  end
end
