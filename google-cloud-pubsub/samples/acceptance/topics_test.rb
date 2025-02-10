# Copyright 2021 Google LLC
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

require_relative "helper"
require_relative "../pubsub_create_pull_subscription.rb"
require_relative "../pubsub_create_push_subscription.rb"
require_relative "../pubsub_create_topic.rb"
require_relative "../pubsub_create_topic_with_cloud_storage_ingestion.rb"
require_relative "../pubsub_dead_letter_create_subscription.rb"
require_relative "../pubsub_dead_letter_delivery_attempt.rb"
require_relative "../pubsub_dead_letter_remove.rb"
require_relative "../pubsub_dead_letter_update_subscription.rb"
require_relative "../pubsub_delete_topic.rb"
require_relative "../pubsub_enable_subscription_ordering.rb"
require_relative "../pubsub_list_topic_subscriptions.rb"
require_relative "../pubsub_list_topics.rb"
require_relative "../pubsub_publish.rb"
require_relative "../pubsub_publish_custom_attributes.rb"
require_relative "../pubsub_publish_with_ordering_keys.rb"
require_relative "../pubsub_publisher_batch_settings.rb"
require_relative "../pubsub_publisher_concurrency_control.rb"
require_relative "../pubsub_publisher_flow_control.rb"
require_relative "../pubsub_quickstart_publisher.rb"
require_relative "../pubsub_resume_publish_with_ordering_keys.rb"
require_relative "../pubsub_set_topic_policy.rb"
require_relative "../pubsub_test_topic_permissions.rb"

describe "topics" do
  let(:pubsub) { Google::Cloud::Pubsub.new }
  let(:role) { "roles/pubsub.publisher" }
  let(:service_account_email) { "serviceAccount:kokoro@#{pubsub.project}.iam.gserviceaccount.com" }
  let(:topic_id) { random_topic_id }
  let(:cloud_storage_ingestion_topic_id) { random_topic_id }
  let(:cloud_storage_bucket) { "pubsub-ruby-sample-bucket" }
  let(:subscription_id) { random_subscription_id }
  let(:dead_letter_topic_id) { random_topic_id }

  after do
    @subscription.delete if @subscription
    @topic.delete if @topic
    @cloud_storage_ingestion_topic.delete if @cloud_storage_ingestion_topic
  end

  it "supports pubsub_create_topic, pubsub_create_topic_with_cloud_storage_ingestion, pubsub_list_topics, pubsub_set_topic_policy, pubsub_get_topic_policy, pubsub_test_topic_permissions, pubsub_delete_topic" do
    # pubsub_create_topic
    assert_output "Topic projects/#{pubsub.project}/topics/#{topic_id} created.\n" do
      create_topic topic_id: topic_id
    end
    topic = pubsub.topic topic_id
    assert topic
    assert_equal "projects/#{pubsub.project}/topics/#{topic_id}", topic.name

    # pubsub_create_topic_with_cloud_storage_ingestion
    # This test requires the existence of GCS bucket gs://pubsub-ruby-sample-bucket in `pubsub.project` with the P4SA for `pubsub.project` having the "storage.admin" role on the GCS bucket.
    assert_output "Topic projects/#{pubsub.project}/topics/#{cloud_storage_ingestion_topic_id} with Cloud Storage ingestion settings created.\n" do
      create_topic_with_cloud_storage_ingestion topic_id: cloud_storage_ingestion_topic_id,
                                                bucket: cloud_storage_bucket,
                                                input_format: "text",
                                                text_delimiter: ",",
                                                match_glob: "**.txt",
                                                minimum_object_create_time: "1970-01-01T00:00:01Z"
    end
    cloud_storage_ingestion_topic = pubsub.topic cloud_storage_ingestion_topic_id
    assert cloud_storage_ingestion_topic
    assert_equal "projects/#{pubsub.project}/topics/#{cloud_storage_ingestion_topic_id}", cloud_storage_ingestion_topic.name

    # pubsub_list_topics
    out, _err = capture_io do
      list_topics
    end
    assert_includes out, "Topics in project:"
    assert_includes out, "projects/#{pubsub.project}/topics/"

    # pubsub_set_topic_policy
    set_topic_policy topic_id: topic.name, role: role, service_account_email: service_account_email
    topic.reload!
    assert_equal [service_account_email], topic.policy.roles[role]

    # pubsub_get_topic_policy
    assert_output "Topic policy:\n#{topic.policy.roles}\n" do
      get_topic_policy topic_id: topic_id
    end

    # pubsub_test_topic_permissions
    assert_output "Permission to attach subscription\nPermission to publish\nPermission to update\n" do
      test_topic_permissions topic_id: topic_id
    end

    # pubsub_delete_topic
    assert_output "Topic #{topic_id} deleted.\n" do
      delete_topic topic_id: topic_id
    end
    topic = pubsub.topic topic_id
    refute topic
  end

  it "supports pubsub_create_pull_subscription, pubsub_list_topic_subscriptions, pubsub_quickstart_publisher, pubsub_subscriber_sync_pull" do
    #setup
    @topic = pubsub.create_topic topic_id

    # pubsub_create_pull_subscription
    assert_output "Pull subscription #{subscription_id} created.\n" do
      create_pull_subscription topic_id: topic_id, subscription_id: subscription_id
    end
    @subscription = @topic.subscription subscription_id
    assert @subscription
    assert_equal "projects/#{pubsub.project}/subscriptions/#{subscription_id}", @subscription.name

    # pubsub_list_topic_subscriptions
    assert_output "Subscriptions in topic #{@topic.name}:\n#{@subscription.name}\n" do
      list_topic_subscriptions topic_id: topic_id
    end

    # pubsub_quickstart_publisher
    assert_output "Message published.\n" do
      publish_message topic_id: topic_id
    end

    # pubsub_subscriber_sync_pull
    expect_with_retry "pubsub_subscriber_sync_pull" do
      assert_output "Message pulled: This is a test message.\n" do
        pull_messages subscription_id: subscription_id
      end
    end
  end

  it "supports pubsub_enable_subscription_ordering, pubsub_publish_with_ordering_keys, pubsub_resume_publish_with_ordering_keys" do
    #setup
    @topic = pubsub.create_topic topic_id

    # pubsub_enable_subscription_ordering
    assert_output "Pull subscription #{subscription_id} created with message ordering.\n" do
      enable_subscription_ordering topic_id: topic_id, subscription_id: subscription_id
    end
    @subscription = @topic.subscription subscription_id
    assert @subscription
    assert_equal "projects/#{pubsub.project}/subscriptions/#{subscription_id}", @subscription.name
    assert @subscription.message_ordering?

    # pubsub_publish_with_ordering_keys
    assert_output "Messages published with ordering key.\n" do
      publish_ordered_messages topic_id: topic_id
    end

    messages = []
    expect_with_retry "pubsub_publish_with_ordering_keys" do
      @subscription.pull(immediate: false, max: 20).each do |message|
        messages << message
        message.acknowledge!
      end
      assert_equal 10, messages.length
    end
    received_time_counter = Hash.new 0
    messages.each_with_index do |message, i|
      assert_equal "ordering-key", message.ordering_key
      assert_equal "This is message \##{i}.", message.data
      received_time_counter[message.publish_time] += 1
    end
    assert_equal 1, received_time_counter.length

    # pubsub_resume_publish_with_ordering_keys
    out, _err = capture_io do
      publish_resume_publish topic_id: topic_id
    end
    assert_includes out, "Message \#0 successfully published."
    assert_includes out, "Message \#9 successfully published."

    messages = []
    expect_with_retry "pubsub_resume_publish_with_ordering_keys" do
      @subscription.pull(immediate: false, max: 20).each do |message|
        messages << message
        message.acknowledge!
      end
      assert_equal 10, messages.length
    end
    received_time_counter = Hash.new 0
    messages.each_with_index do |message, i|
      assert_equal "ordering-key", message.ordering_key
      assert_equal "This is message \##{i}.", message.data
      received_time_counter[message.publish_time] += 1
    end
    assert_equal 1, received_time_counter.length
  end

  it "supports pubsub_create_push_subscription" do
    #setup
    @topic = pubsub.create_topic topic_id
    endpoint = "https://#{pubsub.project}.appspot.com/push"

    # pubsub_create_pull_subscription
    assert_output "Push subscription #{subscription_id} created.\n" do
      create_push_subscription topic_id: topic_id, subscription_id: subscription_id, endpoint: endpoint
    end
    @subscription = @topic.subscription subscription_id
    assert @subscription
    assert_equal "projects/#{pubsub.project}/subscriptions/#{subscription_id}", @subscription.name
    assert_equal endpoint, @subscription.endpoint
    assert @subscription.push_config
    assert_equal endpoint, @subscription.push_config.endpoint
  end

  it "supports pubsub_dead_letter_create_subscription, pubsub_dead_letter_update_subscription, pubsub_dead_letter_delivery_attempt" do
    #setup
    @topic = pubsub.create_topic topic_id
    @dead_letter_topic = pubsub.create_topic dead_letter_topic_id

    begin
      # pubsub_dead_letter_create_subscription
      out, _err = capture_io do
        dead_letter_create_subscription topic_id: topic_id,
                                        subscription_id: subscription_id,
                                        dead_letter_topic_id: dead_letter_topic_id
      end
      assert_includes out, "Created subscription #{subscription_id} with dead letter topic #{dead_letter_topic_id}."

      @subscription = @topic.subscription subscription_id
      assert @subscription
      assert_equal "projects/#{pubsub.project}/subscriptions/#{subscription_id}", @subscription.name
      assert @subscription.dead_letter_topic
      assert_equal "projects/#{pubsub.project}/topics/#{dead_letter_topic_id}", @subscription.dead_letter_topic.name
      assert_equal 10, @subscription.dead_letter_max_delivery_attempts

      # pubsub_dead_letter_update_subscription
      assert_output "Max delivery attempts is now 20.\n" do
        dead_letter_update_subscription subscription_id: subscription_id
      end
      @subscription.reload!
      assert @subscription.dead_letter_topic
      assert_equal "projects/#{pubsub.project}/topics/#{dead_letter_topic_id}", @subscription.dead_letter_topic.name
      assert_equal 20, @subscription.dead_letter_max_delivery_attempts

      @topic.publish "This is a dead letter topic test message."
      # pubsub_dead_letter_delivery_attempt
      expect_with_retry "pubsub_dead_letter_delivery_attempt" do
        out, _err = capture_io do
          dead_letter_delivery_attempt subscription_id: subscription_id
        end
        assert_includes out, "Received message: This is a dead letter topic test message."
        assert_includes out, "Delivery Attempt: 1"
      end

      # pubsub_dead_letter_remove
      assert_output "Removed dead letter topic from #{subscription_id} subscription.\n" do
        dead_letter_remove subscription_id: subscription_id
      end
      @subscription.reload!
      refute @subscription.dead_letter_topic
      refute @subscription.dead_letter_max_delivery_attempts
    ensure
      @dead_letter_topic.delete
    end
  end

  it "supports pubsub_publish" do
    #setup
    @topic = pubsub.create_topic topic_id
    @subscription = @topic.subscribe random_subscription_id

    # pubsub_publish
    assert_output "Message published asynchronously.\n" do
      publish_message_async topic_id: topic_id
    end

    messages = []
    expect_with_retry "pubsub_publish" do
      @subscription.pull(immediate: false, max: 1).each do |message|
        messages << message
        message.acknowledge!
      end
      assert_equal 1, messages.length
      assert_equal "This is a test message.", messages[0].data
    end
  end

  it "supports pubsub_publisher_with_compression" do
    #setup
    sample = SampleLoader.load "pubsub_publisher_with_compression.rb"
    @topic = pubsub.create_topic topic_id
    @subscription = @topic.subscribe random_subscription_id

    # pubsub_publisher_with_compression
    assert_output /Published a compressed message of message ID:/ do
      sample.run project_id: pubsub.project, topic_id: topic_id
    end

    messages = []
    expect_with_retry "pubsub_publisher_with_compression" do
      @subscription.pull(immediate: false, max: 1).each do |message|
        messages << message
        message.acknowledge!
      end
      assert_equal 1, messages.length
      assert_equal "This is a test message.", messages[0].data
    end
  end

  it "supports pubsub_publish_custom_attributes" do
    #setup
    @topic = pubsub.create_topic topic_id
    @subscription = @topic.subscribe random_subscription_id

    # pubsub_publish_custom_attributes
    assert_output "Message with custom attributes published asynchronously.\n" do
      publish_message_async_with_custom_attributes topic_id: topic_id
    end

    messages = []
    expect_with_retry "pubsub_publish_custom_attributes" do
      @subscription.pull(immediate: false, max: 1).each do |message|
        messages << message
        message.acknowledge!
      end
      assert_equal 1, messages.length
      assert_equal "This is a test message.", messages[0].data
      assert_equal 2, messages[0].attributes.size
      assert_equal "ruby-sample", messages[0].attributes["origin"]
      assert_equal "gcp", messages[0].attributes["username"]
    end
  end

  it "supports pubsub_publisher_batch_settings" do
    #setup
    @topic = pubsub.create_topic topic_id
    @subscription = @topic.subscribe random_subscription_id

    # pubsub_publisher_batch_settings
    assert_output "Messages published asynchronously in batch.\n" do
      publish_messages_async_with_batch_settings topic_id: topic_id
    end

    messages = []
    expect_with_retry "pubsub_publisher_batch_settings" do
      @subscription.pull(immediate: false, max: 20).each do |message|
        messages << message
        message.acknowledge!
      end
      assert_equal 10, messages.length
    end
    received_time_counter = Hash.new 0
    messages.each do |message|
      received_time_counter[message.publish_time] += 1
    end
    assert_equal 1, received_time_counter.length
  end

  it "supports pubsub_publisher_concurrency_control" do
    #setup
    @topic = pubsub.create_topic topic_id
    @subscription = @topic.subscribe random_subscription_id

    # pubsub_publisher_concurrency_control
    assert_output "Message published asynchronously.\n" do
      publish_messages_async_with_concurrency_control topic_id: topic_id
    end

    messages = []
    expect_with_retry "pubsub_publisher_concurrency_control" do
      @subscription.pull(immediate: false, max: 1).each do |message|
        messages << message
        message.acknowledge!
      end
      assert_equal 1, messages.length
      assert_equal "This is a test message.", messages[0].data
    end
  end

  it "supports pubsub_publisher_flow_control" do
    #setup
    @topic = pubsub.create_topic topic_id
    @subscription = @topic.subscribe random_subscription_id

    # pubsub_publisher_flow_control
    assert_output "Published messages with flow control settings to #{topic_id}.\n" do
      publish_messages_async_with_flow_control topic_id: topic_id
    end
  end

  it "supports publish_with_error_handler" do
    #setup
    @topic = pubsub.create_topic topic_id
    @subscription = @topic.subscribe random_subscription_id

    # publish_with_error_handler
    assert_output "Message published asynchronously.\n" do
      publish_message_async topic_id: topic_id
    end

    messages = []
    expect_with_retry "pubsub_publish" do
      @subscription.pull(immediate: false, max: 1).each do |message|
        messages << message
        message.acknowledge!
      end
      assert_equal 1, messages.length
      assert_equal "This is a test message.", messages[0].data
    end
  end

  # Pub/Sub calls may not respond immediately.
  # Wrap expectations that may require multiple attempts with this method.
  def expect_with_retry(sample_name, attempts: 5)
    @attempt_number ||= 0
    yield
    @attempt_number = nil
  rescue Minitest::Assertion => e
    @attempt_number += 1
    puts "failed attempt #{@attempt_number} for #{sample_name}"
    sleep @attempt_number * @attempt_number
    retry if @attempt_number < attempts
    @attempt_number = nil
    raise e
  end
end
