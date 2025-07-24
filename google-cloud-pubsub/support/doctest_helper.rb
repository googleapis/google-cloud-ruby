# Copyright 2016 Google LLC
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

require "minitest/focus"
require "ostruct"

require "google/cloud/pubsub"

class File
  def self.open *args
    "task completed"
  end
end

def sleep
  "sleeping"
end

module Google
  module Cloud
    module PubSub
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
      class MessageListener
        # doctest has issues running this code, so punt on it completely
        def start
          self
        end
        def stop
          self
        end
        def wait! *_args
          self
        end
        def stop! *_args
          self
        end
      end
    end
  end
end

def mock_pubsub
  Google::Cloud::PubSub.stub_new do |*args|
    credentials = OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
    pubsub = Google::Cloud::PubSub::Project.new(Google::Cloud::PubSub::Service.new("my-project", credentials))

    pubsub.service.mocked_topic_admin = Minitest::Mock.new
    pubsub.service.mocked_subscription_admin = Minitest::Mock.new
    pubsub.service.mocked_iam = Minitest::Mock.new
    pubsub.service.mocked_schemas = Minitest::Mock.new
    if block_given?
      yield pubsub.service.mocked_topic_admin,
            pubsub.service.mocked_subscription_admin,
            pubsub.service.mocked_iam,
            pubsub.service.mocked_schemas
    end

    pubsub
  end
end

YARD::Doctest.configure do |doctest|
  # Skip all aliases, since tests would be exact duplicates
  doctest.skip "Google::Cloud::PubSub::Message#msg_id"
  doctest.skip "Google::Cloud::PubSub::Subscriber#ack"
  doctest.skip "Google::Cloud::PubSub::ReceivedMessage#nack!"
  doctest.skip "Google::Cloud::PubSub::ReceivedMessage#ignore!"


  doctest.before "Google::Cloud" do
    mock_pubsub do |mock_topic_admin, mock_subscription_admin|
      mock_topic_admin.expect :publish, OpenStruct.new(message_ids: ["1"]), [Hash]
      mock_topic_admin.expect :get_topic, topic_resp, topic: topic_path("my-topic")
    end
  end

  doctest.before "Google::Cloud::PubSub" do
    mock_pubsub do |mock_topic_admin, mock_subscription_admin|
      mock_topic_admin.expect :publish, OpenStruct.new(message_ids: ["1"]), [Hash]
      mock_topic_admin.expect :get_topic, topic_resp, topic: topic_path("my-topic")
    end
  end

  doctest.skip "Google::Cloud::PubSub::Credentials" # occasionally getting "This code example is not yet mocked"

  doctest.before "Google::Cloud::PubSub::Message" do
    mock_pubsub do |mock_topic_admin, mock_subscription_admin|
      mock_topic_admin.expect :publish, OpenStruct.new(message_ids: ["1"]), [Hash]
      mock_topic_admin.expect :get_topic, topic_resp, topic: topic_path("my-topic")
      mock_subscription_admin.expect :get_subscription, subscription_resp, subscription: subscription_path("my-topic-sub")
      mock_subscription_admin.expect :streaming_pull, [OpenStruct.new(received_messages: [Google::Cloud::PubSub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)])].to_enum, [Enumerator, Hash]
      mock_subscription_admin.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscription_admin.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscription_admin.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
    end
  end

  ##
  # Project

  doctest.before "Google::Cloud::PubSub::Project" do
    mock_pubsub do |mock_topic_admin, mock_subscription_admin|
      mock_topic_admin.expect :publish, OpenStruct.new(message_ids: ["1"]), [Hash]
      mock_topic_admin.expect :get_topic, topic_resp, topic: topic_path("my-topic")
    end
  end

  ##
  # ReceivedMessage

  doctest.before "Google::Cloud::PubSub::ReceivedMessage" do
    mock_pubsub do |mock_topic_admin, mock_subscription_admin|
      mock_subscription_admin.expect :get_subscription, subscription_resp, subscription: subscription_path("my-topic-sub")
      mock_subscription_admin.expect :streaming_pull, [OpenStruct.new(received_messages: [Google::Cloud::PubSub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)])].to_enum, [Enumerator, Hash]
      mock_subscription_admin.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscription_admin.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscription_admin.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscription_admin.expect :acknowledge, nil, ["projects/my-project/subscriptions/my-sub", ["2"], Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::ReceivedMessage#delivery_attempt" do
    mock_pubsub do |mock_topic_admin, mock_subscription_admin|
      mock_topic_admin.expect :get_topic, topic_resp, topic: topic_path("my-topic")
      mock_subscription_admin.expect :create_subscription, OpenStruct.new(name: "my-topic-sub"), name: subscription_path("my-topic-sub"),
                             topic: topic_path("my-topic"),
                             dead_letter_policy: {
                                dead_letter_topic: topic_path("my-dead-letter-topic"),
                                max_delivery_attempts: 10
                             }
      mock_subscription_admin.expect :get_subscription, subscription_resp, subscription: subscription_path("my-topic-sub")

    end
  end

  doctest.before "Google::Cloud::PubSub::ReceivedMessage#modify_ack_deadline!" do
    mock_pubsub do |mock_topic_admin, mock_subscription_admin|
      mock_subscription_admin.expect :get_subscription, subscription_resp("my-topic-sub"), subscription: subscription_path("my-topic-sub")
      mock_subscription_admin.expect :streaming_pull, [OpenStruct.new(received_messages: [Google::Cloud::PubSub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)])].to_enum, [Enumerator, Hash]
      mock_subscription_admin.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscription_admin.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscription_admin.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscription_admin.expect :modify_ack_deadline, nil, [Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::ReceivedMessage#reject!" do
    mock_pubsub do |mock_topic_admin, mock_subscription_admin|
      mock_subscription_admin.expect :get_subscription, subscription_resp, subscription: subscription_path("my-topic-sub")
      mock_subscription_admin.expect :pull, OpenStruct.new(received_messages: [Google::Cloud::PubSub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)]), [Hash]
      mock_subscription_admin.expect :streaming_pull, [OpenStruct.new(received_messages: [Google::Cloud::PubSub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)])].to_enum, [Enumerator, Hash]
      mock_subscription_admin.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscription_admin.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscription_admin.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
    end
  end

  ##
  # Subscriber

  doctest.before "Google::Cloud::PubSub::Subscriber" do
    mock_pubsub do |mock_topic_admin, mock_subscription_admin|
      mock_subscription_admin.expect :get_subscription, subscription_resp("my-topic-sub"), subscription: subscription_path("my-topic-sub")
      mock_subscription_admin.expect :streaming_pull, [OpenStruct.new(received_messages: [Google::Cloud::PubSub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)])].to_enum, [Enumerator, Hash]
      mock_subscription_admin.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscription_admin.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscription_admin.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscription_admin.expect :acknowledge, nil, [Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::Subscriber#wait_for_messages" do
    mock_pubsub do |mock_topic_admin, mock_subscription_admin|
      mock_subscription_admin.expect :get_subscription, subscription_resp("my-topic-sub"), subscription: subscription_path("my-topic-sub")
      mock_subscription_admin.expect :pull, OpenStruct.new(received_messages: [Google::Cloud::PubSub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)]),
                             subscription: subscription_path("my-topic-sub"), max_messages: 100, return_immediately: false
      mock_subscription_admin.expect :acknowledge, nil, subscription: subscription_path("my-topic-sub"), ack_ids: ["2"]
    end
  end

  doctest.before "Google::Cloud::PubSub::Subscriber#pull" do
    mock_pubsub do |mock_topic_admin, mock_subscription_admin|
      mock_subscription_admin.expect :get_subscription, subscription_resp("my-topic-sub"), subscription: subscription_path("my-topic-sub")
    end
  end


  doctest.before "Google::Cloud::PubSub::Subscriber#pull@The `immediate: false` option is now recommended to avoid adverse impacts on pull operations:" do
     mock_pubsub do |mock_topic_admin, mock_subscription_admin|
     mock_subscription_admin.expect :get_subscription, subscription_resp("my-topic-sub"), subscription: subscription_path("my-topic-sub")
     mock_subscription_admin.expect :pull, OpenStruct.new(received_messages: [Google::Cloud::PubSub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)]),
                             subscription: subscription_path("my-topic-sub"), max_messages: 100, return_immediately: false
     mock_subscription_admin.expect :acknowledge, nil, subscription: subscription_path("my-topic-sub"), ack_ids: ["2"]
    end
  end

  doctest.before "Google::Cloud::PubSub::Subscriber#pull@A maximum number of messages returned can also be specified:" do
    mock_pubsub do |mock_topic_admin, mock_subscription_admin|
      mock_subscription_admin.expect :get_subscription, subscription_resp("my-topic-sub"), subscription: subscription_path("my-topic-sub")
      mock_subscription_admin.expect :pull, OpenStruct.new(received_messages: [Google::Cloud::PubSub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)]),
                             subscription: subscription_path("my-topic-sub"), max_messages: 10, return_immediately: false
      mock_subscription_admin.expect :acknowledge, nil, subscription: subscription_path("my-topic-sub"), ack_ids: ["2"]
    end
  end

  doctest.before "Google::Cloud::PubSub::Subscriber#modify_ack_deadline" do
    mock_pubsub do |mock_topic_admin, mock_subscription_admin|
      mock_subscription_admin.expect :get_subscription, subscription_resp, subscription: subscription_path("my-topic-sub")
      mock_subscription_admin.expect :pull, OpenStruct.new(received_messages: [Google::Cloud::PubSub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)]),
                             subscription: subscription_path("my-sub"), max_messages: 100, return_immediately: false
      mock_subscription_admin.expect :modify_ack_deadline, nil, subscription: subscription_path("my-sub"), ack_ids: ["2"], ack_deadline_seconds: 120


    end
  end

  doctest.before "Google::Cloud::PubSub::Subscriber#resource?" do
    mock_pubsub do |mock_topic_admin, mock_subscription_admin|
      mock_subscription_admin.expect :get_subscription, subscription_resp, subscription: subscription_path("my-topic-sub")
    end
  end


  doctest.before "Google::Cloud::PubSub::Subscriber#reload!" do
    mock_pubsub do |mock_topic_admin, mock_subscription_admin|
      mock_subscription_admin.expect :get_subscription, subscription_resp, subscription: subscription_path("my-topic-sub")
      mock_subscription_admin.expect :get_subscription, subscription_resp, subscription: subscription_path("my-topic-sub")
    end
  end

  doctest.before "Google::Cloud::PubSub::Subscriber#listen@Ordered messages are supported using ordering_key:" do
    mock_pubsub do |mock_topic_admin, mock_subscription_admin|
      ordered_subscription_resp = subscription_resp "my-ordered-topic-sub"
      ordered_subscription_resp.enable_message_ordering = true
      mock_subscription_admin.expect :get_subscription, ordered_subscription_resp, subscription: subscription_path("my-ordered-topic-sub")
      mock_subscription_admin.expect :streaming_pull, [OpenStruct.new(received_messages: [Google::Cloud::PubSub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)])].to_enum, [Enumerator, Hash]
      mock_subscription_admin.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscription_admin.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscription_admin.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscription_admin.expect :acknowledge, nil, ["projects/my-project/subscriptions/my-ordered-topic-sub", ["2"], Hash]
    end
  end

  ##
  # MessageListener

  doctest.before "Google::Cloud::PubSub::MessageListener" do
    mock_pubsub do |mock_topic_admin, mock_subscription_admin|
      mock_subscription_admin.expect :get_subscription, subscription_resp("my-topic-sub"), subscription: subscription_path("my-topic-sub")
      mock_subscription_admin.expect :streaming_pull, [OpenStruct.new(received_messages: [Google::Cloud::PubSub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)])].to_enum, [Enumerator, Hash]
      mock_subscription_admin.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscription_admin.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscription_admin.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscription_admin.expect :acknowledge, nil, [Hash]
    end
  end

  ##
  # Publisher

  doctest.before "Google::Cloud::PubSub::Publisher" do
    mock_pubsub do |mock_topic_admin, mock_subscription_admin|
      mock_topic_admin.expect :get_topic, topic_resp, topic: topic_path("my-topic-only")
      mock_topic_admin.expect :publish, OpenStruct.new(message_ids: ["1"]), [Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::Publisher#async_publisher" do
    mock_pubsub do |mock_topic_admin, mock_subscription_admin|
      mock_topic_admin.expect :get_topic, topic_resp, topic: topic_path("my-topic")
      mock_topic_admin.expect :publish, OpenStruct.new(message_ids: ["1"]), [Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::Publisher#publish" do
    mock_pubsub do |mock_topic_admin, mock_subscription_admin|
      mock_topic_admin.expect :get_topic, topic_resp, topic: topic_path("my-topic")
      mock_topic_admin.expect :publish, OpenStruct.new(message_ids: ["1"]), [Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::Publisher#publish@Additionally, a message can be published with attributes:" do
    mock_pubsub do |mock_topic_admin, mock_subscription_admin|
      mock_topic_admin.expect :get_topic, topic_resp, topic: topic_path("my-topic")
      mock_topic_admin.expect :publish, OpenStruct.new(message_ids: ["1"]), [Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::Publisher#publish@Multiple messages can be sent at the same time using a block:" do
    mock_pubsub do |mock_topic_admin, mock_subscription_admin|
      mock_topic_admin.expect :get_topic, topic_resp, topic: topic_path("my-topic")
      messages = [
        pubsub_message("task 1 completed", { "foo" => "bar" }),
        pubsub_message("task 2 completed", { "foo" => "baz" }),
        pubsub_message("task 3 completed", { "foo" => "bif" })
      ]
      mock_topic_admin.expect :publish, OpenStruct.new(message_ids: ["1", "2", "3"]), [Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::Publisher#publish@Ordered messages are supported using ordering_key:" do
    mock_pubsub do |mock_topic_admin, mock_subscription_admin|
      mock_topic_admin.expect :get_topic, topic_resp, topic: topic_path("my-ordered-topic")
      mock_topic_admin.expect :publish, OpenStruct.new(message_ids: ["1"]), [Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::Publisher#publish_async@Ordered messages are supported using ordering_key:" do
    mock_pubsub do |mock_topic_admin, mock_subscription_admin|
      mock_topic_admin.expect :get_topic, topic_resp, topic: topic_path("my-ordered-topic")
    end
  end

  ##
  # BatchPublisher

  doctest.before "Google::Cloud::PubSub::BatchPublisher" do
    mock_pubsub do |mock_topic_admin, mock_subscription_admin|
      mock_topic_admin.expect :get_topic, topic_resp, topic: topic_path("my-topic")
      messages = [
        pubsub_message("task 1 completed", { "foo" => "bar" }),
        pubsub_message("task 2 completed", { "foo" => "baz" }),
        pubsub_message("task 3 completed", { "foo" => "bif" })
      ]
      mock_topic_admin.expect :publish, OpenStruct.new(message_ids: ["1", "2", "3"]), [Hash]
    end
  end
end

# Fixture helpers

def pubsub_message data = "task completed", attributes = {}
  Google::Cloud::PubSub::V1::PubsubMessage.new data: data, attributes: attributes, message_id: "", publish_time: nil
end

def list_topics_paged_enum
  paged_enum_struct OpenStruct.new(topics: [])
end


def token_options token
  Google::Gax::CallOptions.new(kwargs: { "google-cloud-resource-prefix" => "projects/#{project}" },
                               page_token: token)
end

def topics_hash num_topics, token = ""
  topics = num_topics.times.map do
    topic_hash("topic-#{rand 1000}")
  end
  data = { topics: topics }
  data[:next_page_token] = token unless token.nil?
  data
end

def topic_resp topic_name = "my-topic", kms_key_name: nil, persistence_regions: nil, schema_settings: nil
  topic = Google::Cloud::PubSub::V1::Topic.new name: topic_path(topic_name),
                                               kms_key_name: kms_key_name
  if persistence_regions
    topic.message_storage_policy = Google::Cloud::PubSub::V1::MessageStoragePolicy.new(
      allowed_persistence_regions: persistence_regions
    )
  end
  topic.schema_settings = Google::Cloud::PubSub::V1::SchemaSettings.new schema_settings if schema_settings
  topic
end

def topic_subscriptions_hash num_subs, token = nil
  subs = num_subs.times.map do
    subscription_path("sub-#{rand 1000}")
  end
  data = { subscriptions: subs }
  data[:next_page_token] = token unless token.nil?
  data
end

def subscriptions_hash topic_name, num_subs, token = nil
  subs = num_subs.times.map do
    subscription_hash(topic_name, "sub-#{rand 1000}")
  end
  data = { subscriptions: subs }
  data[:next_page_token] = token unless token.nil?
  data
end

def subscription_hash topic_name, sub_name,
                      deadline = 60,
                      endpoint = "http://example.com/callback",
                      labels: nil,
                      dead_letter_topic: nil,
                      max_delivery_attempts: nil
  hsh = {
    name: subscription_path(sub_name),
    topic: topic_path(topic_name),
    push_config: {
      push_endpoint: endpoint,
      oidc_token: {
        service_account_email: "user@example.com",
        audience: "client-12345"
      }
    },
    ack_deadline_seconds: deadline,
    detached: true,
    retain_acked_messages: true,
    message_retention_duration: { seconds: 600, nanos: 900000000 }, # 600.9 seconds
    labels: labels,
    retry_policy: { minimum_backoff: 5, maximum_backoff: 300 }
  }
  hsh[:dead_letter_policy] = {
    dead_letter_topic: topic_path(dead_letter_topic),
    max_delivery_attempts: max_delivery_attempts
  } if dead_letter_topic
  hsh
end

def snapshots_hash topic_name, num_snapshots, token = nil
  snapshots = num_snapshots.times.map do
    snapshot_hash(topic_name, "snapshot-#{rand 1000}")
  end
  data = { snapshots: snapshots }
  data[:next_page_token] = token unless token.nil?
  data
end

def snapshot_hash topic_name, snapshot_name, labels: nil
  time = Time.now
  timestamp = {
    seconds: time.to_i,
    nanos: time.nsec
  }
  {
    name: snapshot_path(snapshot_name),
    topic: topic_path(topic_name),
    expire_time: timestamp,
    labels: labels
  }
end

def schemas_hash num_schemas, token = nil
  schemas = num_schemas.times.map do
    schema_hash("schema-#{rand 1000}")
  end
  data = { schemas: schemas }
  data[:next_page_token] = token unless token.nil?
  data
end

def schema_hash schema_name, type: "PROTOCOL_BUFFER", definition: nil
  {
    name: schema_path(schema_name),
    type: type,
    definition: definition
  }
end

def rec_message_hash message, id = rand(1000000)
  {
    ack_id: "ack-id-#{id}",
    message: {
      data: Base64.strict_encode64(message),
      attributes: {},
      message_id: "msg-id-#{id}",
    }
  }
end

def rec_messages_hash message, id = nil
  {
    received_messages: [rec_message_hash(message, id)]
  }
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

def schema_path schema_name
  "#{project_path}/schemas/#{schema_name}"
end

def paged_enum_struct response
  OpenStruct.new response: response
end


def subscription_resp name = "my-sub", dead_letter_topic: nil, max_delivery_attempts: nil
  Google::Cloud::PubSub::V1::Subscription.new subscription_hash "my-topic", name, dead_letter_topic: dead_letter_topic, max_delivery_attempts: max_delivery_attempts
end


def list_subscriptions_resp token = "next_page_token"
  response = Google::Cloud::PubSub::V1::ListSubscriptionsResponse.new subscriptions_hash("my-topic", 3, token)
  paged_enum_struct response
end

def list_topic_subscriptions_resp token = "next_page_token"
  response = Google::Cloud::PubSub::V1::ListTopicSubscriptionsResponse.new topic_subscriptions_hash(3, token)
  paged_enum_struct response
end

def list_snapshots_resp token = "next_page_token"
  response = Google::Cloud::PubSub::V1::ListSnapshotsResponse.new snapshots_hash("my-topic", 3, token)
  paged_enum_struct response
end

def snapshot_resp snapshot_name = "my-snapshot"
  Google::Cloud::PubSub::V1::Snapshot.new snapshot_hash("my-topic", snapshot_name)
end

def list_schemas_resp token = "next_page_token"
  response = Google::Cloud::PubSub::V1::ListSchemasResponse.new schemas_hash(3, token)
  paged_enum_struct response
end

def schema_resp schema_name = "my-schema", definition: nil
  Google::Cloud::PubSub::V1::Schema.new schema_hash(schema_name, definition: definition)
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
