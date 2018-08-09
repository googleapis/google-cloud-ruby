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

gem "minitest"
require "minitest/autorun"
require "minitest/focus"
require "minitest/rg"
require "ostruct"
require "json"
require "base64"
require "google/cloud/pubsub"
require "grpc"

##
# Monkey-Patch CallOptions to support Mocks
class Google::Gax::CallOptions
  ##
  # Minitest Mock depends on === to match same-value objects.
  # By default, CallOptions objects do not match with ===.
  # Therefore, we must add this capability.
  def === other
    return false unless other.is_a? Google::Gax::CallOptions
    timeout === other.timeout &&
      retry_options === other.retry_options &&
      page_token === other.page_token &&
      kwargs === other.kwargs
  end
  def == other
    return false unless other.is_a? Google::Gax::CallOptions
    timeout == other.timeout &&
      retry_options == other.retry_options &&
      page_token == other.page_token &&
      kwargs == other.kwargs
  end
end

class StreamingPullStub
  attr_reader :requests, :responses

  def initialize response_groups
    @requests = []
    @responses = response_groups.map do |responses|
      RaisableEnumeratorQueue.new.tap do |q|
        responses.each do |response|
          q.push response
        end
      end
    end
  end

  def streaming_pull request_enum, options: nil
    @requests << request_enum
    @responses.shift.each
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

class MockPubsub < Minitest::Spec
  let(:project) { "test" }
  let(:default_options) { Google::Gax::CallOptions.new(kwargs: { "google-cloud-resource-prefix" => "projects/#{project}" }) }
  let(:credentials) { OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {})) }
  let(:pubsub) { Google::Cloud::Pubsub::Project.new(Google::Cloud::Pubsub::Service.new(project, credentials)) }

  def token_options token
    Google::Gax::CallOptions.new(kwargs: { "google-cloud-resource-prefix" => "projects/#{project}" },
                                 page_token: token)
  end

  def topics_json num_topics, token = ""
    topics = num_topics.times.map do
      JSON.parse(topic_json("topic-#{rand 1000}"))
    end
    data = { "topics" => topics }
    data["next_page_token"] = token unless token.nil?
    data.to_json
  end

  def topic_json topic_name
    { "name" => topic_path(topic_name) }.to_json
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
      "retain_acked_messages" => true,
      "message_retention_duration" => {"seconds" => 600, "nanos" => 900000000} # 600.9 seconds
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
    OpenStruct.new page: OpenStruct.new(response: response)
  end

  # Register this spec type for when :storage is used.
  register_spec_type(self) do |desc, *addl|
    addl.include? :mock_pubsub
  end
end
