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
require "opentelemetry-sdk"

describe Google::Cloud::PubSub::Subscriber, :open_telemetry, :mock_pubsub do
  let(:topic_name) { topic_path "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_hash) { subscription_hash topic_name, sub_name }
  let(:sub_grpc) { Google::Cloud::PubSub::V1::Subscription.new(sub_hash) }
  let(:sub_path) { sub_grpc.name }
  let(:subscription) { Google::Cloud::PubSub::Subscription.from_grpc sub_grpc, pubsub.service }

  let(:rec_message_msg) { "pulled-message" }
  let(:rec_message_ack_id) { 123456789 }
  let(:attributes) { { "googclient_traceparent" => "abc123" } }
  let(:rec_message_hsh) { rec_message_hash rec_message_msg, rec_message_ack_id, attributes: attributes }
  let(:rec_msg_grpc) { Google::Cloud::PubSub::V1::ReceivedMessage.new rec_message_hsh }
  let(:client_id) { "my-client-uuid" }

  before do
    @exporter = OpenTelemetry::SDK::Trace::Export::InMemorySpanExporter.new
    span_processor = OpenTelemetry::SDK::Trace::Export::SimpleSpanProcessor.new @exporter
    OpenTelemetry::SDK.configure do |c|
      c.add_span_processor span_processor
    end
  end

  after do
    @exporter.reset
    # Remove the OpenTelemetry::SDK::Trace::TracerProvider so that tests in other files do not trace.
    OpenTelemetry.tracer_provider = OpenTelemetry::Internal::ProxyTracerProvider.new
  end

  it "can acknowledge a single message" do
    pull_res = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: [rec_msg_grpc]
    response_groups = [[pull_res]]

    stub = StreamingPullStub.new response_groups
    called = false

    subscription.service.mocked_subscriber = stub
    subscription.service.client_id = client_id

    subscriber = subscription.listen streams: 1 do |result|
      # flush the initial buffer before any callbacks are processed
      subscriber.buffer.flush! unless called

      assert_kind_of Google::Cloud::PubSub::ReceivedMessage, result
      assert_equal rec_message_msg, result.data
      assert_equal "ack-id-#{rec_message_ack_id}", result.ack_id

      result.ack!
      called = true
    end

    subscriber.on_error do |error|
      raise "Subscriber#on_error: #{error.inspect}"
    end

    subscriber.start

    subscriber_retries = 0
    while !called
      fail "total number of calls were never made" if subscriber_retries > 100
      subscriber_retries += 1
      sleep 0.01
    end

    subscriber.stop
    subscriber.wait!

    spans = @exporter.finished_spans
    _(spans.count).must_equal 2
  
    # TODO: Determine if the order below should be reversed, and how? Is there no parent relationship?
    assert_pubsub_span spans[0], "#{topic_name} process"
    _(spans[0].total_recorded_links).must_equal 1 # Link with publish span via "googclient_traceparent"
    _(spans[0].attributes).must_equal expected_span_attrs(topic_name, rec_msg_grpc.message.message_id, rec_msg_grpc.message.to_proto.bytesize, "process")

    assert_pubsub_span spans[1], "#{topic_name} receive"
    _(spans[1].total_recorded_links).must_equal 0
    _(spans[1].attributes).must_equal expected_span_attrs(topic_name, rec_msg_grpc.message.message_id, rec_msg_grpc.message.to_proto.bytesize, "receive")
  end

  def assert_pubsub_span span, expected_name
    _(span).wont_be :nil?
    _(span.name).must_equal expected_name
    _(span.status).must_be_kind_of OpenTelemetry::Trace::Status
    _(span.status).must_be :ok?
    _(span.instrumentation_library.name).must_equal "Google::Cloud::PubSub"
    _(span.instrumentation_library.version).must_equal Google::Cloud::PubSub::VERSION
    _(span.kind).must_equal OpenTelemetry::Trace::SpanKind::PRODUCER
  end

  def expected_span_attrs topic_name, msg_id, msg_size, operation
    {
      OpenTelemetry::SemanticConventions::Trace::MESSAGING_SYSTEM => "pubsub",
      OpenTelemetry::SemanticConventions::Trace::MESSAGING_DESTINATION => topic_name,
      OpenTelemetry::SemanticConventions::Trace::MESSAGING_DESTINATION_KIND => "topic",
      OpenTelemetry::SemanticConventions::Trace::MESSAGING_MESSAGE_ID => msg_id,
      OpenTelemetry::SemanticConventions::Trace::MESSAGING_MESSAGE_PAYLOAD_SIZE_BYTES => msg_size,
      OpenTelemetry::SemanticConventions::Trace::MESSAGING_OPERATION => operation,
      "pubsub.ordering_key" => ""
    }
  end
end
