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

require "logging_helper"

# This test is a ruby version of gcloud-node"s logging test.

describe Gcloud::Logging, :logging do
  describe "Sinks" do
    it "creates, updates, refreshes, gets, lists, and deletes a sink" do
      skip
      pubsub_dest = "pubsub.googleapis.com/projects/#{logging.project}/topics/#{prefix}-topic"
      sink = logging.create_sink "#{prefix}-sink",
                                 destination: pubsub_dest,
                                 filter: "severity = ALERT"

      sink.name.must_equal "#{prefix}-sink"
      sink.destination.must_equal pubsub_dest
      sink.filter.must_equal "severity = ALERT"

      sink.filter = "severity >= WARNING"

      sink.save

      sink.name.must_equal "#{prefix}-sink"
      sink.destination.must_equal pubsub_dest
      sink.filter.must_equal "severity >= WARNING"

      sink.refresh!

      sink.name.must_equal "#{prefix}-sink"
      sink.destination.must_equal pubsub_dest
      sink.filter.must_equal "severity >= WARNING"

      dup_sink = logging.sink "#{prefix}-sink"

      dup_sink.name.must_equal "#{prefix}-sink"
      dup_sink.destination.must_equal pubsub_dest
      dup_sink.filter.must_equal "severity >= WARNING"

      logging.sinks.wont_be :empty?
      logging.sinks(max: 1).length.must_equal 1

      sink.delete

      logging.sink("#{prefix}-sink").must_be :nil?
    end

    it "lists sinks" do
      skip
      pubsub_dest = "pubsub.googleapis.com/projects/#{logging.project}/topics/#{prefix}-topic"
      sink = logging.create_sink "#{prefix}-list-sink",
                                 destination: pubsub_dest

      logging.sinks.wont_be :empty?
      logging.sinks(max: 1).length.must_equal 1

      sink.delete
    end
  end

  describe "Metrics" do
    it "creates, updates, refreshes, gets, lists, and deletes a metric" do
      metric = logging.create_metric "#{prefix}-metric",
                                     description: "Metric for acceptance tsets",
                                     filter: "severity = ALERT"

      metric.name.must_equal "#{prefix}-metric"
      metric.description.must_equal "Metric for acceptance tsets"
      metric.filter.must_equal "severity = ALERT"

      metric.description = "Metric for acceptance tests"
      metric.filter = "severity >= WARNING"

      metric.save

      metric.name.must_equal "#{prefix}-metric"
      metric.description.must_equal "Metric for acceptance tests"
      metric.filter.must_equal "severity >= WARNING"

      metric.refresh!

      metric.name.must_equal "#{prefix}-metric"
      metric.description.must_equal "Metric for acceptance tests"
      metric.filter.must_equal "severity >= WARNING"

      dup_metric = logging.metric "#{prefix}-metric"

      dup_metric.name.must_equal "#{prefix}-metric"
      dup_metric.description.must_equal "Metric for acceptance tests"
      dup_metric.filter.must_equal "severity >= WARNING"

      logging.metrics.wont_be :empty?
      logging.metrics(max: 1).length.must_equal 1

      metric.delete

      logging.metric("#{prefix}-metric").must_be :nil?
    end
  end

  describe "Entries" do
    let(:proto_payload) { Google::Protobuf::Any.new type_url: "example.com/Greeter/SayHello",
                                                    value: "\n\fHello world!".encode("ASCII-8BIT") }
    let(:entry1) { logging.entry.tap { |e| e.log_name = "testlog"; e.payload = "log entry 1" } }
    let(:entry2) { logging.entry.tap { |e| e.log_name = "otherlog"; e.payload = {env: :production} } }
    let(:entry3) { logging.entry.tap { |e| e.log_name = "thislog"; e.payload = proto_payload; e.severity = :WARNING } }

    let(:resource) { logging.resource "gce_instance", zone: "global", instance_id: "3" }

    it "writes and lists log entries" do
      logging.write_entries [entry1, entry2, entry3], resource: resource

      logging.entries.wont_be :empty?
      logging.entries(max: 1).length.must_equal 1
    end
  end

  describe "Ruby Logger" do
    let(:log_name) { "#{prefix}-logger" }
    let(:resource) { logging.resource "gce_instance", zone: "global", instance_id: "3" }
    let(:labels) { { env: :production } }
    let(:logger) { logging.logger log_name, resource, labels }

    it "writes to a log with add and a symbol" do
      logger.add :debug,   "Danger Will Robinson!"
      logger.add :info,    "Danger Will Robinson!"
      logger.add :warn,    "Danger Will Robinson!"
      logger.add :error,   "Danger Will Robinson!"
      logger.add :fatal,   "Danger Will Robinson!"
      logger.add :unknown, "Danger Will Robinson!"
    end

    it "writes to a log with add and a string" do
      logger.add "debug",   "Danger Will Robinson!"
      logger.add "info",    "Danger Will Robinson!"
      logger.add "warn",    "Danger Will Robinson!"
      logger.add "error",   "Danger Will Robinson!"
      logger.add "fatal",   "Danger Will Robinson!"
      logger.add "unknown", "Danger Will Robinson!"
    end

    it "writes to a log with add and a constant" do
      logger.add ::Logger::DEBUG,   "Danger Will Robinson!"
      logger.add ::Logger::INFO,    "Danger Will Robinson!"
      logger.add ::Logger::WARN,    "Danger Will Robinson!"
      logger.add ::Logger::ERROR,   "Danger Will Robinson!"
      logger.add ::Logger::FATAL,   "Danger Will Robinson!"
      logger.add ::Logger::UNKNOWN, "Danger Will Robinson!"
    end

    it "writes to a log with named functions" do
      logger.debug   "Danger Will Robinson!"
      logger.info    "Danger Will Robinson!"
      logger.warn    "Danger Will Robinson!"
      logger.error   "Danger Will Robinson!"
      logger.fatal   "Danger Will Robinson!"
      logger.unknown "Danger Will Robinson!"
    end
  end
end
