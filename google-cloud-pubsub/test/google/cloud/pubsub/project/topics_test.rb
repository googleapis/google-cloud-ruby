# Copyright 2021 Google LLC
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

require "helper"

describe Google::Cloud::PubSub::Project, :topics, :mock_pubsub do
  let(:topics_with_token) do
    response = Google::Cloud::PubSub::V1::ListTopicsResponse.new topics_hash(3, "next_page_token")
    paged_enum_struct response
  end
  let(:topics_without_token) do
    response = Google::Cloud::PubSub::V1::ListTopicsResponse.new topics_hash(2)
    paged_enum_struct response
  end
  let(:topics_with_token_2) do
    response = Google::Cloud::PubSub::V1::ListTopicsResponse.new topics_hash(3, "second_page_token")
    paged_enum_struct response
  end
  let(:labels) { { "foo" => "bar" } }
  let(:kms_key) { "projects/a/locations/b/keyRings/c/cryptoKeys/d" }
  let(:persistence_regions) { ["us-west1", "us-west2"] }
  let(:schema_name) { "my-schema" }
  let(:message_encoding) { :JSON }
  let(:retention) { 600 }
  let(:async) do
    {
      max_bytes: 2_000_000,
      max_messages: 200,
      interval: 0.02,
      threads: {
        publish: 3,
        callback: 5
      },
      flow_control: {
        message_limit: 4_000,
        byte_limit: 40_000_000,
        limit_exceeded_behavior: :block
      }
    }
  end

  it "creates a topic" do
    new_topic_name = "new-topic-#{Time.now.to_i}"

    create_res = Google::Cloud::PubSub::V1::Topic.new topic_hash(new_topic_name)
    mock = Minitest::Mock.new
    mock.expect :create_topic, create_res, [name: topic_path(new_topic_name), labels: nil, kms_key_name: nil, message_storage_policy: nil, schema_settings: nil, message_retention_duration: nil]
    pubsub.service.mocked_publisher = mock

    topic = pubsub.create_topic new_topic_name

    mock.verify

    _(topic.name).must_equal topic_path(new_topic_name)
    _(topic.labels).must_be :empty?
    _(topic.labels).must_be :frozen?
    _(topic.kms_key).must_be :empty?
    _(topic.persistence_regions).must_be :empty?
    _(topic.schema_name).must_be :nil?
    _(topic.message_encoding).must_be :nil?
    _(topic.message_encoding_json?).must_equal false
    _(topic.message_encoding_binary?).must_equal false
    _(topic.retention).must_be :nil?
  end

  it "creates a topic with fully-qualified topic path" do
    new_topic_path = "projects/other-project/topics/new-topic-#{Time.now.to_i}"

    create_res = Google::Cloud::PubSub::V1::Topic.new topic_hash(new_topic_path)
    mock = Minitest::Mock.new
    mock.expect :create_topic, create_res, [name: new_topic_path, labels: nil, kms_key_name: nil, message_storage_policy: nil, schema_settings: nil, message_retention_duration: nil]
    pubsub.service.mocked_publisher = mock

    topic = pubsub.create_topic new_topic_path

    mock.verify

    _(topic.name).must_equal new_topic_path
  end

  it "creates a topic with new_topic_alias" do
    new_topic_name = "new-topic-#{Time.now.to_i}"

    create_res = Google::Cloud::PubSub::V1::Topic.new topic_hash(new_topic_name)
    mock = Minitest::Mock.new
    mock.expect :create_topic, create_res, [name: topic_path(new_topic_name), labels: nil, kms_key_name: nil, message_storage_policy: nil, schema_settings: nil, message_retention_duration: nil]
    pubsub.service.mocked_publisher = mock

    topic = pubsub.new_topic new_topic_name

    mock.verify

    _(topic.name).must_equal topic_path(new_topic_name)
    _(topic.labels).must_be :empty?
    _(topic.labels).must_be :frozen?
    _(topic.kms_key).must_be :empty?
    _(topic.persistence_regions).must_be :empty?
    _(topic.schema_name).must_be :nil?
    _(topic.message_encoding).must_be :nil?
    _(topic.message_encoding_json?).must_equal false
    _(topic.message_encoding_binary?).must_equal false
    _(topic.retention).must_be :nil?
  end

  it "creates a topic with labels" do
    new_topic_name = "new-topic-#{Time.now.to_i}"

    create_res = Google::Cloud::PubSub::V1::Topic.new topic_hash(new_topic_name, labels: labels)
    mock = Minitest::Mock.new
    mock.expect :create_topic, create_res, [name: topic_path(new_topic_name), labels: labels, kms_key_name: nil, message_storage_policy: nil, schema_settings: nil, message_retention_duration: nil]
    pubsub.service.mocked_publisher = mock

    topic = pubsub.create_topic new_topic_name, labels: labels

    mock.verify

    _(topic.name).must_equal topic_path(new_topic_name)
    _(topic.labels).must_equal labels
    _(topic.labels).must_be :frozen?
    _(topic.kms_key).must_be :empty?
    _(topic.persistence_regions).must_be :empty?
    _(topic.schema_name).must_be :nil?
    _(topic.message_encoding).must_be :nil?
    _(topic.message_encoding_json?).must_equal false
    _(topic.message_encoding_binary?).must_equal false
    _(topic.retention).must_be :nil?
  end

  it "creates a topic with kms_key" do
    new_topic_name = "new-topic-#{Time.now.to_i}"

    create_res = Google::Cloud::PubSub::V1::Topic.new topic_hash(new_topic_name, kms_key_name: kms_key)
    mock = Minitest::Mock.new
    mock.expect :create_topic, create_res, [name: topic_path(new_topic_name), labels: nil, kms_key_name: kms_key, message_storage_policy: nil, schema_settings: nil, message_retention_duration: nil]
    pubsub.service.mocked_publisher = mock

    topic = pubsub.create_topic new_topic_name, kms_key: kms_key

    mock.verify

    _(topic.name).must_equal topic_path(new_topic_name)
    _(topic.labels).must_be :empty?
    _(topic.labels).must_be :frozen?
    _(topic.kms_key).must_equal kms_key
    _(topic.persistence_regions).must_be :empty?
    _(topic.schema_name).must_be :nil?
    _(topic.message_encoding).must_be :nil?
    _(topic.message_encoding_json?).must_equal false
    _(topic.message_encoding_binary?).must_equal false
    _(topic.retention).must_be :nil?
  end

  it "creates a topic with persistence_regions" do
    new_topic_name = "new-topic-#{Time.now.to_i}"

    create_res = Google::Cloud::PubSub::V1::Topic.new topic_hash(new_topic_name, persistence_regions: persistence_regions)
    mock = Minitest::Mock.new
    message_storage_policy = Google::Cloud::PubSub::V1::MessageStoragePolicy.new allowed_persistence_regions: persistence_regions
    mock.expect :create_topic, create_res, [name: topic_path(new_topic_name), labels: nil, kms_key_name: nil, message_storage_policy: message_storage_policy, schema_settings: nil, message_retention_duration: nil]
    pubsub.service.mocked_publisher = mock

    topic = pubsub.create_topic new_topic_name, persistence_regions: persistence_regions

    mock.verify

    _(topic.name).must_equal topic_path(new_topic_name)
    _(topic.labels).must_be :empty?
    _(topic.labels).must_be :frozen?
    _(topic.kms_key).must_be :empty?
    _(topic.persistence_regions).must_equal persistence_regions
    _(topic.schema_name).must_be :nil?
    _(topic.message_encoding).must_be :nil?
    _(topic.message_encoding_json?).must_equal false
    _(topic.message_encoding_binary?).must_equal false
    _(topic.retention).must_be :nil?
  end

  it "creates a topic with schema_name and message_encoding" do
    new_topic_name = "new-topic-#{Time.now.to_i}"

    schema_settings = Google::Cloud::PubSub::V1::SchemaSettings.new schema: schema_path(schema_name), encoding: message_encoding
    create_res = Google::Cloud::PubSub::V1::Topic.new topic_hash(new_topic_name)
    create_res.schema_settings = schema_settings
    mock = Minitest::Mock.new
    mock.expect :create_topic, create_res, [name: topic_path(new_topic_name), labels: nil, kms_key_name: nil, message_storage_policy: nil, schema_settings: schema_settings, message_retention_duration: nil]
    pubsub.service.mocked_publisher = mock

    topic = pubsub.create_topic new_topic_name, schema_name: schema_name, message_encoding: message_encoding

    mock.verify

    _(topic.name).must_equal topic_path(new_topic_name)
    _(topic.labels).must_be :empty?
    _(topic.labels).must_be :frozen?
    _(topic.kms_key).must_be :empty?
    _(topic.schema_name).must_equal schema_path(schema_name)
    _(topic.message_encoding).must_equal message_encoding
    _(topic.retention).must_be :nil?
  end

  it "creates a topic with retention" do
    new_topic_name = "new-topic-#{Time.now.to_i}"

    duration = Google::Protobuf::Duration.new seconds: retention, nanos: 0
    create_res = Google::Cloud::PubSub::V1::Topic.new topic_hash(new_topic_name)
    create_res.message_retention_duration = duration
    mock = Minitest::Mock.new
    mock.expect :create_topic, create_res, [name: topic_path(new_topic_name), labels: nil, kms_key_name: nil, message_storage_policy: nil, schema_settings: nil, message_retention_duration: duration]
    pubsub.service.mocked_publisher = mock

    topic = pubsub.create_topic new_topic_name, retention: retention

    mock.verify

    _(topic.name).must_equal topic_path(new_topic_name)
    _(topic.labels).must_be :empty?
    _(topic.labels).must_be :frozen?
    _(topic.kms_key).must_be :empty?
    _(topic.persistence_regions).must_be :empty?
    _(topic.schema_name).must_be :nil?
    _(topic.message_encoding).must_be :nil?
    _(topic.message_encoding_json?).must_equal false
    _(topic.message_encoding_binary?).must_equal false
    _(topic.retention).must_equal retention
  end

  it "creates a topic with async option" do
    new_topic_name = "new-topic-#{Time.now.to_i}"

    create_res = Google::Cloud::PubSub::V1::Topic.new topic_hash(new_topic_name)
    mock = Minitest::Mock.new
    mock.expect :create_topic, create_res, [name: topic_path(new_topic_name), labels: nil, kms_key_name: nil, message_storage_policy: nil, schema_settings: nil, message_retention_duration: nil]
    pubsub.service.mocked_publisher = mock

    topic = pubsub.create_topic new_topic_name, async: async
    topic.enable_message_ordering! # Create the AsyncPublisher

    mock.verify

    _(topic.async_publisher.topic_name).must_equal topic_path(new_topic_name)
    _(topic.async_publisher.max_bytes).must_equal async[:max_bytes]
    _(topic.async_publisher.max_messages).must_equal async[:max_messages]
    _(topic.async_publisher.interval).must_equal async[:interval]
    _(topic.async_publisher.publish_threads).must_equal async[:threads][:publish]
    _(topic.async_publisher.callback_threads).must_equal async[:threads][:callback]
    _(topic.async_publisher.flow_control).must_equal async[:flow_control]
  end

  it "raises when creating a topic with schema_name but without message_encoding" do
    err = expect do
      topic = pubsub.create_topic "new-topic", schema_name: schema_name
    end.must_raise ArgumentError
    _(err.message).must_equal "Schema settings must include both schema_name and message_encoding."
  end

  it "raises when creating a topic without schema_name but with message_encoding" do
    err = expect do
      topic = pubsub.create_topic "new-topic", message_encoding: message_encoding
    end.must_raise ArgumentError
    _(err.message).must_equal "Schema settings must include both schema_name and message_encoding."
  end

  it "gets a topic" do
    topic_name = "found-topic"

    get_res = Google::Cloud::PubSub::V1::Topic.new topic_hash(topic_name)
    mock = Minitest::Mock.new
    mock.expect :get_topic, get_res, [topic: topic_path(topic_name)]
    pubsub.service.mocked_publisher = mock

    topic = pubsub.topic topic_name

    mock.verify

    _(topic.name).must_equal topic_path(topic_name)
    _(topic).wont_be :reference?
    _(topic).must_be :resource?
  end

  it "gets a topic with fully-qualified topic path" do
    topic_full_path = "projects/other-project/topics/found-topic"

    get_res = Google::Cloud::PubSub::V1::Topic.new topic_hash(topic_full_path)
    mock = Minitest::Mock.new
    mock.expect :get_topic, get_res, [topic: topic_path(topic_full_path)]
    pubsub.service.mocked_publisher = mock

    topic = pubsub.topic topic_full_path

    mock.verify

    _(topic.name).must_equal topic_full_path
  end

  it "gets a topic with get_topic alias" do
    topic_name = "found-topic"

    get_res = Google::Cloud::PubSub::V1::Topic.new topic_hash(topic_name)
    mock = Minitest::Mock.new
    mock.expect :get_topic, get_res, [topic: topic_path(topic_name)]
    pubsub.service.mocked_publisher = mock

    topic = pubsub.get_topic topic_name

    mock.verify

    _(topic.name).must_equal topic_path(topic_name)
    _(topic).wont_be :reference?
    _(topic).must_be :resource?
  end

  it "gets a topic with find_topic alias" do
    topic_name = "found-topic"

    get_res = Google::Cloud::PubSub::V1::Topic.new topic_hash(topic_name)
    mock = Minitest::Mock.new
    mock.expect :get_topic, get_res, [topic: topic_path(topic_name)]
    pubsub.service.mocked_publisher = mock

    topic = pubsub.find_topic topic_name

    mock.verify

    _(topic.name).must_equal topic_path(topic_name)
    _(topic).wont_be :reference?
    _(topic).must_be :resource?
  end

  it "returns nil when getting an non-existent topic" do
    not_found_topic_name = "not-found-topic"

    stub = Object.new
    def stub.get_topic *args
      raise Google::Cloud::NotFoundError.new("not found")
    end
    pubsub.service.mocked_publisher = stub

    topic = pubsub.find_topic not_found_topic_name
    _(topic).must_be :nil?
  end

  it "gets a topic with skip_lookup option" do
    topic_name = "found-topic"
    # No HTTP mock needed, since the lookup is not made

    topic = pubsub.find_topic topic_name, skip_lookup: true
    _(topic.name).must_equal topic_path(topic_name)
    _(topic).must_be :reference?
    _(topic).wont_be :resource?
  end

  it "gets a topic with project option" do
    topic_name = "found-topic"
    topic_full_path = "projects/custom/topics/found-topic"

    get_res = Google::Cloud::PubSub::V1::Topic.new topic_hash(topic_full_path)
    mock = Minitest::Mock.new
    mock.expect :get_topic, get_res, [topic: topic_full_path]
    pubsub.service.mocked_publisher = mock

    topic = pubsub.find_topic topic_name, project: "custom"
    _(topic.name).must_equal topic_full_path
    _(topic).wont_be :reference?
    _(topic).must_be :resource?
  end

  it "gets a topic with skip_lookup and project options" do
    topic_name = "found-topic"
    # No HTTP mock needed, since the lookup is not made

    topic = pubsub.find_topic topic_name, skip_lookup: true, project: "custom"
    _(topic.name).must_equal "projects/custom/topics/found-topic"
    _(topic).must_be :reference?
    _(topic).wont_be :resource?
  end

  it "gets a topic with async option" do
    topic_name = "found-topic"

    get_res = Google::Cloud::PubSub::V1::Topic.new topic_hash(topic_name)
    mock = Minitest::Mock.new
    mock.expect :get_topic, get_res, [topic: topic_path(topic_name)]
    pubsub.service.mocked_publisher = mock

    topic = pubsub.topic topic_name, async: async
    topic.enable_message_ordering! # Create the AsyncPublisher

    mock.verify

    _(topic.async_publisher.topic_name).must_equal topic_path(topic_name)
    _(topic.async_publisher.max_bytes).must_equal async[:max_bytes]
    _(topic.async_publisher.max_messages).must_equal async[:max_messages]
    _(topic.async_publisher.interval).must_equal async[:interval]
    _(topic.async_publisher.publish_threads).must_equal async[:threads][:publish]
    _(topic.async_publisher.callback_threads).must_equal async[:threads][:callback]
    _(topic.async_publisher.flow_control).must_equal async[:flow_control]
  end

  it "lists topics" do
    mock = Minitest::Mock.new
    mock.expect :list_topics, topics_with_token, [project: "projects/#{project}", page_size: nil, page_token: nil]
    pubsub.service.mocked_publisher = mock

    topics = pubsub.topics

    mock.verify

    _(topics.size).must_equal 3
  end

  it "lists topics with find_topics alias" do
    mock = Minitest::Mock.new
    mock.expect :list_topics, topics_with_token, [project: "projects/#{project}", page_size: nil, page_token: nil]
    pubsub.service.mocked_publisher = mock

    topics = pubsub.find_topics

    mock.verify

    _(topics.size).must_equal 3
  end

  it "lists topics with list_topics alias" do
    mock = Minitest::Mock.new
    mock.expect :list_topics, topics_with_token, [project: "projects/#{project}", page_size: nil, page_token: nil]
    pubsub.service.mocked_publisher = mock

    topics = pubsub.list_topics

    mock.verify

    _(topics.size).must_equal 3
  end

  it "paginates topics" do
    mock = Minitest::Mock.new
    mock.expect :list_topics, topics_with_token, [project: "projects/#{project}", page_size: nil, page_token: nil]
    mock.expect :list_topics, topics_without_token, [project: "projects/#{project}", page_size: nil, page_token: "next_page_token"]
    pubsub.service.mocked_publisher = mock

    first_topics = pubsub.topics
    second_topics = pubsub.topics token: first_topics.token

    mock.verify

    _(first_topics.size).must_equal 3
    token = first_topics.token
    _(token).wont_be :nil?
    _(token).must_equal "next_page_token"

    _(second_topics.size).must_equal 2
    _(second_topics.token).must_be :nil?
  end

  it "paginates topics with max set" do
    mock = Minitest::Mock.new
    mock.expect :list_topics, topics_with_token, [project: "projects/#{project}", page_size: 3, page_token: nil]
    pubsub.service.mocked_publisher = mock

    topics = pubsub.topics max: 3

    mock.verify

    _(topics.size).must_equal 3
    token = topics.token
    _(token).wont_be :nil?
    _(token).must_equal "next_page_token"
  end

  it "paginates topics with next? and next" do
    mock = Minitest::Mock.new
    mock.expect :list_topics, topics_with_token, [project: "projects/#{project}", page_size: nil, page_token: nil]
    mock.expect :list_topics, topics_without_token, [project: "projects/#{project}", page_size: nil, page_token: "next_page_token"]
    pubsub.service.mocked_publisher = mock

    first_topics = pubsub.topics
    second_topics = first_topics.next

    mock.verify

    _(first_topics.size).must_equal 3
    _(first_topics.next?).must_equal true

    _(second_topics.size).must_equal 2
    _(second_topics.next?).must_equal false
  end

  it "paginates topics with next? and next and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_topics, topics_with_token, [project: "projects/#{project}", page_size: 3, page_token: nil]
    mock.expect :list_topics, topics_without_token, [project: "projects/#{project}", page_size: 3, page_token: "next_page_token"]
    pubsub.service.mocked_publisher = mock

    first_topics = pubsub.topics max: 3
    second_topics = first_topics.next

    mock.verify

    _(first_topics.size).must_equal 3
    _(first_topics.next?).must_equal true

    _(second_topics.size).must_equal 2
    _(second_topics.next?).must_equal false
  end

  it "paginates topics with all" do
    mock = Minitest::Mock.new
    mock.expect :list_topics, topics_with_token, [project: "projects/#{project}", page_size: nil, page_token: nil]
    mock.expect :list_topics, topics_without_token, [project: "projects/#{project}", page_size: nil, page_token: "next_page_token"]
    pubsub.service.mocked_publisher = mock

    topics = pubsub.topics.all.to_a

    mock.verify

    _(topics.size).must_equal 5
  end

  it "paginates topics with all and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_topics, topics_with_token, [project: "projects/#{project}", page_size: 3, page_token: nil]
    mock.expect :list_topics, topics_without_token, [project: "projects/#{project}", page_size: 3, page_token: "next_page_token"]
    pubsub.service.mocked_publisher = mock

    topics = pubsub.topics(max: 3).all.to_a

    mock.verify

    _(topics.size).must_equal 5
  end

  it "iterates topics with all using Enumerator" do
    mock = Minitest::Mock.new
    mock.expect :list_topics, topics_with_token, [project: "projects/#{project}", page_size: nil, page_token: nil]
    mock.expect :list_topics, topics_with_token_2, [project: "projects/#{project}", page_size: nil, page_token: "next_page_token"]
    pubsub.service.mocked_publisher = mock

    topics = pubsub.topics.all.take(5)

    mock.verify

    _(topics.size).must_equal 5
  end

  it "iterates topics with all and request_limit set" do
    mock = Minitest::Mock.new
    mock.expect :list_topics, topics_with_token, [project: "projects/#{project}", page_size: nil, page_token: nil]
    mock.expect :list_topics, topics_with_token_2, [project: "projects/#{project}", page_size: nil, page_token: "next_page_token"]
    pubsub.service.mocked_publisher = mock

    topics = pubsub.topics.all(request_limit: 1).to_a

    mock.verify

    _(topics.size).must_equal 6
  end

  it "paginates topics without max set" do
    mock = Minitest::Mock.new
    mock.expect :list_topics, topics_with_token, [project: "projects/#{project}", page_size: nil, page_token: nil]
    pubsub.service.mocked_publisher = mock

    topics = pubsub.topics

    mock.verify

    _(topics.size).must_equal 3
    token = topics.token
    _(token).wont_be :nil?
    _(token).must_equal "next_page_token"
  end
end
