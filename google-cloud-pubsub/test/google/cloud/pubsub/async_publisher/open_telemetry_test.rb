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

describe Google::Cloud::PubSub::AsyncPublisher, :open_telemetry, :mock_pubsub do
  let(:topic_name) { topic_path "topic-name-goes-here" }
  let(:data) { "async-message".encode(Encoding::ASCII_8BIT) }
  let(:ordering_key) { "foo" }
  let(:msg) { Google::Cloud::PubSub::V1::PubsubMessage.new data: data, ordering_key: ordering_key }
  let(:expected_messages_hash) { { ordering_key => [msg] } }

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

  it "publishes a message with open telemetry tracing" do
    pubsub.service.mocked_publisher = AsyncPublisherStub.new

    publisher = Google::Cloud::PubSub::AsyncPublisher.new topic_name, pubsub.service, interval: 30
    publisher.enable_message_ordering!

    publisher.publish "async-message", ordering_key: ordering_key

    _(publisher).must_be :started?
    _(publisher).wont_be :stopped?

    # force the queued messages to be published
    publisher.stop!

    _(publisher).wont_be :started?
    _(publisher).must_be :stopped?

    actual_msg = pubsub.service.mocked_publisher.message_hash[ordering_key].first
    _(actual_msg.data).must_equal data
    _(actual_msg.ordering_key).must_equal ordering_key

    spans = @exporter.finished_spans
    _(spans.count).must_equal 3

    # TODO: Determine if the order below should be reversed, and how? Is there no parent relationship?
    assert_pubsub_span spans[0], "#{topic_name} add to batch", expected_span_attrs(topic_name, msg.to_proto.bytesize, ordering_key)
    assert_pubsub_span spans[1], "#{topic_name} publish RPC", expected_span_attrs(topic_name, actual_msg.to_proto.bytesize, ordering_key)
    assert_pubsub_span spans[2], "#{topic_name} send", expected_span_attrs(topic_name, actual_msg.to_proto.bytesize, ordering_key)
  end

  def assert_pubsub_span span, expected_name, expected_attrs
    _(span).wont_be :nil?
    _(span.name).must_equal expected_name
    _(span.status).must_be_kind_of OpenTelemetry::Trace::Status
    _(span.status).must_be :ok?
    _(span.instrumentation_library.name).must_equal "Google::Cloud::PubSub"
    _(span.instrumentation_library.version).must_equal Google::Cloud::PubSub::VERSION
    _(span.attributes).must_equal expected_attrs
    _(span.kind).must_equal OpenTelemetry::Trace::SpanKind::PRODUCER
  end

  def expected_span_attrs topic_name, msg_size, ordering_key
    {
      "messaging.system" => "pubsub",
      "messaging.destination" => topic_name,
      "messaging.destination_kind" => "topic",
      "messaging.message_id" => "",
      "messaging.message_payload_size_bytes" => msg_size,
      "pubsub.ordering_key" => ordering_key
    }
  end
end
