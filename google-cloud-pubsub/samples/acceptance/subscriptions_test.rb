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
require_relative "../subscriptions.rb"
require_relative "../pubsub_create_subscription_with_filter.rb"
require_relative "../pubsub_subscriber_exactly_once_delivery.rb"
require_relative "../pubsub_create_subscription_with_exactly_once_delivery.rb"

describe "subscriptions" do
  let(:pubsub) { Google::Cloud::Pubsub.new }
  let(:endpoint) { "https://#{pubsub.project}.appspot.com/push" }
  let(:role) { "roles/pubsub.subscriber" }
  let(:service_account_email) { "serviceAccount:kokoro@#{pubsub.project}.iam.gserviceaccount.com" }

  before :all do
    @topic = pubsub.create_topic random_topic_id
  end

  after :all do
    @topic.delete
  end

  before do
    @subscription = @topic.subscribe random_subscription_id
  end

  after do
    @subscription.delete if @subscription
    @subscription = nil
  end

  it "supports pubsub_update_push_configuration, pubsub_list_subscriptions, pubsub_set_subscription_policy, pubsub_get_subscription_policy, " \
     "pubsub_test_subscription_permissions, pubsub_detach_subscription, pubsub_delete_subscription" do
    # pubsub_update_push_configuration
    assert_output "Push endpoint updated.\n" do
      update_push_configuration subscription_id: @subscription.name, new_endpoint: endpoint
    end
    @subscription = @topic.subscription @subscription.name
    assert @subscription
    assert_equal endpoint, @subscription.endpoint
    assert @subscription.push_config
    assert_equal endpoint, @subscription.push_config.endpoint

    # pubsub_list_subscriptions
    out, _err = capture_io do
      list_subscriptions
    end
    assert_includes out, "Subscriptions:"
    assert_includes out, "projects/#{pubsub.project}/subscriptions/"

    # pubsub_set_subscription_policy
    set_subscription_policy subscription_id: @subscription.name, role: role, service_account_email: service_account_email
    @subscription.reload!
    assert_equal [service_account_email], @subscription.policy.roles[role]

    # pubsub_get_subscription_policy
    assert_output "Subscription policy:\n#{@subscription.policy.roles}\n" do
      get_subscription_policy subscription_id: @subscription.name
    end

    # pubsub_test_subscription_permissions
    assert_output "Permission to consume\nPermission to update\n" do
      test_subscription_permissions subscription_id: @subscription.name
    end

    # pubsub_detach_subscription
    assert_output "Subscription is detached.\n" do
      detach_subscription subscription_id: @subscription.name
    end

    # pubsub_delete_subscription
    assert_output "Subscription #{@subscription.name} deleted.\n" do
      delete_subscription subscription_id: @subscription.name
    end
    @subscription = @topic.subscription @subscription.name
    refute @subscription
  end

  it "supports pubsub_subscriber_sync_pull" do
    @topic.publish "This is a test message."
    sleep 5

    # pubsub_subscriber_sync_pull
    expect_with_retry "pubsub_subscriber_sync_pull" do
      assert_output "Message pulled: This is a test message.\n" do
        pull_messages subscription_id: @subscription.name
      end
    end
  end

  it "supports pubsub_subscriber_async_pull_with_ack_response" do
    project_id = pubsub.project
    topic_id = @topic.name
    subscription_id = random_subscription_id

    @topic.subscribe subscription_id, enable_exactly_once_delivery: true

    @topic.publish "This is a test message."
    sleep 5

    expect_with_retry "pubsub_subscriber_async_pull_with_ack_response" do
      out, _err = capture_io do
        PubsubSubscriberExactlyOnceDelivery.new.subscriber_exactly_once_delivery project_id: project_id,
                                                                                 topic_id: topic_id,
                                                                                 subscription_id: subscription_id
      end

      assert_includes out, "Received message: This is a test message."
      assert_includes out, "Acknowledge result's status:"
    end
  end

  it "supports pubsub_subscriber_async_pull, pubsub_quickstart_subscriber" do
    @topic.publish "This is a test message."
    sleep 5

    # pubsub_subscriber_async_pull
    # pubsub_quickstart_subscriber
    expect_with_retry "pubsub_subscriber_async_pull" do
      assert_output "Received message: This is a test message.\n" do
        listen_for_messages subscription_id: @subscription.name
      end
    end
  end

  it "supports pubsub_subscriber_async_pull_custom_attributes" do
    @topic.publish "This is a test message.", origin: "ruby-sample"
    sleep 5

    # pubsub_subscriber_async_pull_custom_attributes
    expect_with_retry "pubsub_subscriber_async_pull_custom_attributes" do
      out, _err = capture_io do
        listen_for_messages_with_custom_attributes subscription_id: @subscription.name
      end
      assert_includes out, "Received message: This is a test message."
      assert_includes out, "Attributes:"
      assert_includes out, "origin: ruby-sample"
    end
  end

  it "supports pubsub_subscriber_flow_settings" do
    @topic.publish "This is a test message."
    sleep 5

    # pubsub_subscriber_flow_settings
    expect_with_retry "pubsub_subscriber_flow_settings" do
      assert_output "Received message: This is a test message.\n" do
        listen_for_messages_with_flow_control subscription_id: @subscription.name
      end
    end
  end

  it "supports pubsub_subscriber_concurrency_control" do
    @topic.publish "This is a test message."
    sleep 5

    # pubsub_subscriber_concurrency_control
    expect_with_retry "pubsub_subscriber_concurrency_control" do
      assert_output "Received message: This is a test message.\n" do
        listen_for_messages_with_concurrency_control subscription_id: @subscription.name
      end
    end
  end

  it "supports pubsub_subscriber_sync_pull_with_lease" do
    @topic.publish "This is a test message."
    sleep 5

    # # pubsub_subscriber_sync_pull_with_lease
    expect_with_retry "pubsub_subscriber_sync_pull_with_lease" do
      out, _err = capture_io do
        subscriber_sync_pull_with_lease subscription_id: @subscription.name
        sleep 20 # Allow enough time for output from non-blocking worker to be captured.
      end
      assert_includes out, "Reset ack deadline for \"This is a test message.\" for 30 seconds."
      assert_includes out, "Finished processing \"This is a test message.\"."
      assert_includes out, "Done."
    end
  end

  it "supports creating subscription with filter" do
    project_id = pubsub.project
    topic_id = @topic.name
    subscription_id = random_subscription_id
    filter = "attributes.author=\"unknown\""

    assert_output "Created subscription with filtering enabled: #{subscription_id}\n" do     
      PubsubCreateSubscriptionWithFilter.new.create_subscription_with_filter project_id: project_id,
                                                                             topic_id: topic_id,
                                                                             subscription_id: subscription_id,
                                                                             filter: filter
    end
  end 

  it "supports creating subscription with exactly once delivery enabled" do
    project_id = pubsub.project
    topic_id = @topic.name
    subscription_id = random_subscription_id

    assert_output "Created subscription with exactly once delivery enabled: #{subscription_id}\n" do     
      PubsubCreateSubscriptionWithExactlyOnceDelivery.new.create_subscription_with_exactly_once_delivery(
        project_id: project_id,
        topic_id: topic_id,
        subscription_id: subscription_id
      )
    end
  end 
end
