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

require "simplecov"

gem "minitest"
require "minitest/autorun"
require "minitest/focus"
require "minitest/rg"
require "ostruct"
require "json"
require "base64"
require "google/cloud/pubsub"
require "grpc"

class StreamingPullStub
  attr_reader :requests, :responses, :acknowledge_requests, :modify_ack_deadline_requests

  def initialize response_groups
    @requests = []
    @acknowledge_requests = []
    @modify_ack_deadline_requests = []
    @responses = response_groups.map do |responses|
      RaisableEnumeratorQueue.new.tap do |q|
        responses.each do |response|
          q.push response
        end
      end
    end
  end

  ###
  # @param request [::Gapic::StreamInput, ::Enumerable<::Google::Cloud::PubSub::V1::StreamingPullRequest, ::Hash>]
  #   An enumerable of {::Google::Cloud::PubSub::V1::StreamingPullRequest} instances.
  # @param options [::Gapic::CallOptions, ::Hash]
  #   Overrides the default settings for this call, e.g, timeout, retries, etc. Optional.
  #
  def streaming_pull request, options = nil
    @requests << request
    @responses.shift.each
  end

  def acknowledge subscription:, ack_ids:
    @acknowledge_requests << [subscription, ack_ids.flatten.sort]
  end

  def modify_ack_deadline subscription:, ack_ids:, ack_deadline_seconds:
    @modify_ack_deadline_requests << [subscription, ack_ids.sort, ack_deadline_seconds]
  end

  class RaisableEnumeratorQueue
    def initialize sentinel = nil
      @queue    = Queue.new
      @sentinel = sentinel
    end

    def push obj
      @queue.push obj
    end

    def each
      return enum_for(:each) unless block_given?

      loop do
        obj = @queue.pop
        # This is the only way to raise and have it be handled by the steam thread
        raise obj if obj.is_a? StandardError
        break if obj.equal? @sentinel
        yield obj
      end
    end
  end
end

class AsyncPublisherStub
  attr_reader :messages

  def initialize
    @messages = []
  end

  def publish topic:, messages:
    @messages << messages
    message_ids = Array.new(messages.count) { |i| "msg#{i}" }
    Google::Cloud::PubSub::V1::PublishResponse.new({ message_ids: message_ids })
  end

  def message_hash
    message_hash = Hash.new { |hash, key| hash[key] = [] }
    @messages.flatten.each_with_object(message_hash) do |msg, hash|
      hash[msg.ordering_key] << msg
    end
  end
end

class MockPubsub < Minitest::Spec
  let(:project) { "test" }
  let(:credentials) { OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {})) }
  let(:pubsub) { Google::Cloud::PubSub::Project.new(Google::Cloud::PubSub::Service.new(project, credentials)) }

  def topics_hash num_topics, token = ""
    topics = num_topics.times.map do
      topic_hash("topic-#{rand 1000}")
    end
    data = { topics: topics }
    data[:next_page_token] = token unless token.nil?
    data
  end

  def topic_hash topic_name, labels: nil, kms_key_name: nil, persistence_regions: nil
    hash = { name: topic_path(topic_name), labels: labels, kms_key_name: kms_key_name }
    if persistence_regions
      hash[:message_storage_policy] = { allowed_persistence_regions: persistence_regions }
    end
    hash
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
                        filter: nil,
                        dead_letter_topic: nil,
                        max_delivery_attempts: nil,
                        retry_minimum_backoff: nil,
                        retry_maximum_backoff: nil,
                        detached: false
    raise "dead_letter_topic is required" if max_delivery_attempts && !dead_letter_topic
    hsh = { name: subscription_path(sub_name),
      topic: topic_path(topic_name),
      push_config: {
        push_endpoint: endpoint,
        oidc_token: {
          service_account_email: "user@example.com",
          audience: "client-12345"
        }
      },
      ack_deadline_seconds: deadline,
      retain_acked_messages: true,
      message_retention_duration: { seconds: 600, nanos: 900000000 }, # 600.9 seconds
      filter: filter,
      labels: labels,
      expiration_policy: { ttl: { seconds: 172800, nanos: 0 } }, # 2 days
      detached: detached
    }
    hsh[:dead_letter_policy] = {
      dead_letter_topic: dead_letter_topic,
      max_delivery_attempts: max_delivery_attempts
    } if dead_letter_topic
    hsh[:retry_policy] = {
      minimum_backoff: retry_minimum_backoff,
      maximum_backoff: retry_maximum_backoff
    } if retry_minimum_backoff || retry_maximum_backoff
    hsh
  end

  def create_subscription_args sub_name,
                               topic_name,
                               push_config: nil,
                               ack_deadline_seconds: nil,
                               retain_acked_messages: false,
                               message_retention_duration: nil,
                               labels: nil,
                               enable_message_ordering: nil,
                               filter: nil,
                               dead_letter_policy: nil,
                               retry_policy: nil
    [
      name: subscription_path(sub_name),
      topic: topic_path(topic_name),
      push_config: push_config,
      ack_deadline_seconds: ack_deadline_seconds,
      retain_acked_messages: retain_acked_messages,
      message_retention_duration: message_retention_duration,
      labels: labels,
      enable_message_ordering: enable_message_ordering,
      filter: filter,
      dead_letter_policy: dead_letter_policy,
      retry_policy: retry_policy
    ]
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
    { name: snapshot_path(snapshot_name),
      topic: topic_path(topic_name),
      expire_time: timestamp,
      labels: labels
    }
  end

  def rec_message_hash message, id = rand(1000000), delivery_attempt: 10
    {
      ack_id: "ack-id-#{id}",
      delivery_attempt: delivery_attempt,
      message: {
        data: message,
        attributes: {},
        message_id: "msg-id-#{id}"
      }
    }
  end

  def rec_messages_hash message, id = nil
    {
      received_messages: [rec_message_hash(message, id)]
    }
  end

  def project_path
    "projects/#{project}"
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
    OpenStruct.new response: response
  end

  # Register this spec type for when :storage is used.
  register_spec_type(self) do |desc, *addl|
    addl.include? :mock_pubsub
  end
end
