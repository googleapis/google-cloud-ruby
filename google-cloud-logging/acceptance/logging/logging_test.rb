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

require "logging_helper"
require "logger"

# This test is a ruby version of gcloud-node's logging test.

describe Google::Cloud::Logging, :logging do
  describe "Sinks" do
    it "creates, updates, refreshes, gets, lists, and deletes a sink" do
      pubsub_dest = "pubsub.googleapis.com/projects/#{logging.project}/topics/#{prefix}-topic"
      sink = logging.create_sink "#{prefix}-sink",
                                 pubsub_dest,
                                 filter: "severity = ALERT"

      _(sink.name).must_equal "#{prefix}-sink"
      _(sink.destination).must_equal pubsub_dest
      _(sink.filter).must_equal "severity = ALERT"

      sink.filter = "severity >= WARNING"

      sink.save

      _(sink.name).must_equal "#{prefix}-sink"
      _(sink.destination).must_equal pubsub_dest
      _(sink.filter).must_equal "severity >= WARNING"

      sink.refresh!

      _(sink.name).must_equal "#{prefix}-sink"
      _(sink.destination).must_equal pubsub_dest
      _(sink.filter).must_equal "severity >= WARNING"

      dup_sink = logging.sink "#{prefix}-sink"

      _(dup_sink.name).must_equal "#{prefix}-sink"
      _(dup_sink.destination).must_equal pubsub_dest
      _(dup_sink.filter).must_equal "severity >= WARNING"

      _(logging.sinks).wont_be :empty?
      _(logging.sinks(max: 1).length).must_equal 1

      sink.delete

      _(logging.sink("#{prefix}-sink")).must_be :nil?
    end

    it "lists sinks" do
      pubsub_dest = "pubsub.googleapis.com/projects/#{logging.project}/topics/#{prefix}-topic"
      sink = logging.create_sink "#{prefix}-list-sink", pubsub_dest

      _(logging.sinks).wont_be :empty?
      _(logging.sinks(max: 1).length).must_equal 1

      sink.delete
    end
  end

  describe "Metrics" do
    it "creates, updates, refreshes, gets, lists, and deletes a metric" do
      metric = logging.create_metric "#{prefix}-metric",
                                     "severity = ALERT",
                                     description: "Metric for acceptance tsets"

      _(metric.name).must_equal "#{prefix}-metric"
      _(metric.description).must_equal "Metric for acceptance tsets"
      _(metric.filter).must_equal "severity = ALERT"

      metric.description = "Metric for acceptance tests"
      metric.filter = "severity >= WARNING"

      metric.save

      _(metric.name).must_equal "#{prefix}-metric"
      _(metric.description).must_equal "Metric for acceptance tests"
      _(metric.filter).must_equal "severity >= WARNING"

      metric.refresh!

      _(metric.name).must_equal "#{prefix}-metric"
      _(metric.description).must_equal "Metric for acceptance tests"
      _(metric.filter).must_equal "severity >= WARNING"

      dup_metric = logging.metric "#{prefix}-metric"

      _(dup_metric.name).must_equal "#{prefix}-metric"
      _(dup_metric.description).must_equal "Metric for acceptance tests"
      _(dup_metric.filter).must_equal "severity >= WARNING"

      _(logging.metrics).wont_be :empty?
      _(logging.metrics(max: 1).length).must_equal 1

      metric.delete

      _(logging.metric("#{prefix}-metric")).must_be :nil?
    end
  end

  describe "Entries" do
    # Reinstate `entry3` and `proto_payload` to this test if possible. The
    # presence of the protobuf payload resulted in the following error beginning
    # around 6/27/2016: "3:LogEntry payload is too deply nested". Using a
    # different logging resource may resolve this issue.
    # let(:proto_payload) { Google::Protobuf::Any.new type_url: "example.com/Greeter/SayHello",
    #                                                 value: "\n\fHello world!".encode("ASCII-8BIT") }
    let(:entry1) { logging.entry.tap { |e| e.log_name = "#{prefix}-testlog"; e.payload = "log entry 1" } }
    let(:entry2) { logging.entry.tap { |e| e.log_name = "#{prefix}-otherlog"; e.payload = {env: :production} } }
    #let(:entry3) { logging.entry.tap { |e| e.log_name = "#{prefix}-thislog"; e.payload = proto_payload; e.severity = :WARNING } }

    let(:resource) { logging.resource "gce_instance", zone: "global", instance_id: "3" }

    it "writes entries and lists entries and logs" do
      skip "Logging has changed and this test is no longer reliable"
      # logging.write_entries [entry1, entry2, entry3], resource: resource
      logging.write_entries [entry1, entry2], resource: resource

      delay = 1
      entries = nil
      while delay < 5
        entries = logging.entries
        break unless entries.empty?
        sleep delay
        delay += 1
      end
      _(entries).wont_be_empty
      _(logging.entries(max: 1).length).must_equal 1

      _(logging.logs).wont_be :empty?
      _(logging.logs(max: 1).length).must_equal 1
    end
  end

  describe "Ruby Blocking Logger" do
    let(:log_name) { "#{prefix}-logger" }
    let(:resource) { logging.resource "gce_instance", zone: "global", instance_id: "3" }
    let(:labels) { { env: :production } }

    before do
      @sleep = 2
    end

    it "writes to a log with add and a symbol" do
      logger = Google::Cloud::Logging::Logger.new logging,
                                                  "#{log_name}-symbol",
                                                  resource,
                                                  labels

      logger.add :debug,   "Danger Will Robinson (:debug)!"
      logger.add :info,    "Danger Will Robinson (:info)!"
      logger.add :warn,    "Danger Will Robinson (:warn)!"
      logger.add :error,   "Danger Will Robinson (:error)!"
      logger.add :fatal,   "Danger Will Robinson (:fatal)!"
      logger.add :unknown, "Danger Will Robinson (:unknown)!"

      skip "Removed due to inconsistent failure by the service to retrieve written_entries. Reinstate when service stabilizes."
      written_entries = entries_via_backoff("symbol").map &:payload

      _(written_entries).must_include "Danger Will Robinson (:debug)!"
      _(written_entries).must_include "Danger Will Robinson (:info)!"
      _(written_entries).must_include "Danger Will Robinson (:warn)!"
      _(written_entries).must_include "Danger Will Robinson (:error)!"
      _(written_entries).must_include "Danger Will Robinson (:fatal)!"
      _(written_entries).must_include "Danger Will Robinson (:unknown)!"
    end

    it "writes to a log with add and a string" do
      logger = Google::Cloud::Logging::Logger.new logging,
                                                  "#{log_name}-string",
                                                  resource,
                                                  labels

      logger.add "debug",   "Danger Will Robinson ('debug')!"
      logger.add "info",    "Danger Will Robinson ('info')!"
      logger.add "warn",    "Danger Will Robinson ('warn')!"
      logger.add "error",   "Danger Will Robinson ('error')!"
      logger.add "fatal",   "Danger Will Robinson ('fatal')!"
      logger.add "unknown", "Danger Will Robinson ('unknown')!"

      skip "Removed due to inconsistent failure by the service to retrieve written_entries. Reinstate when service stabilizes."
      written_entries = entries_via_backoff("string").map &:payload

      _(written_entries).must_include "Danger Will Robinson ('debug')!"
      _(written_entries).must_include "Danger Will Robinson ('info')!"
      _(written_entries).must_include "Danger Will Robinson ('warn')!"
      _(written_entries).must_include "Danger Will Robinson ('error')!"
      _(written_entries).must_include "Danger Will Robinson ('fatal')!"
      _(written_entries).must_include "Danger Will Robinson ('unknown')!"
    end

    it "writes to a log with add and a constant" do
      logger = Google::Cloud::Logging::Logger.new logging,
                                                  "#{log_name}-constant",
                                                  resource,
                                                  labels

      logger.add ::Logger::DEBUG,   "Danger Will Robinson (DEBUG)!"
      logger.add ::Logger::INFO,    "Danger Will Robinson (INFO)!"
      logger.add ::Logger::WARN,    "Danger Will Robinson (WARN)!"
      logger.add ::Logger::ERROR,   "Danger Will Robinson (ERROR)!"
      logger.add ::Logger::FATAL,   "Danger Will Robinson (FATAL)!"
      logger.add ::Logger::UNKNOWN, "Danger Will Robinson (UNKNOWN)!"

      skip "Removed due to inconsistent failure by the service to retrieve written_entries. Reinstate when service stabilizes."
      written_entries = entries_via_backoff("constant").map &:payload

      _(written_entries).must_include "Danger Will Robinson (DEBUG)!"
      _(written_entries).must_include "Danger Will Robinson (INFO)!"
      _(written_entries).must_include "Danger Will Robinson (WARN)!"
      _(written_entries).must_include "Danger Will Robinson (ERROR)!"
      _(written_entries).must_include "Danger Will Robinson (FATAL)!"
      _(written_entries).must_include "Danger Will Robinson (UNKNOWN)!"
    end

    it "writes to a log with named functions" do
      logger = Google::Cloud::Logging::Logger.new logging,
                                                  "#{log_name}-method",
                                                  resource,
                                                  labels

      logger.debug   "Danger Will Robinson (debug)!"
      logger.info    "Danger Will Robinson (info)!"
      logger.warn    "Danger Will Robinson (warn)!"
      logger.error   "Danger Will Robinson (error)!"
      logger.fatal   "Danger Will Robinson (fatal)!"
      logger.unknown "Danger Will Robinson (unknown)!"

      skip "Removed due to inconsistent failure by the service to retrieve written_entries. Reinstate when service stabilizes."
      written_entries = entries_via_backoff("method").map &:payload

      _(written_entries).must_include "Danger Will Robinson (debug)!"
      _(written_entries).must_include "Danger Will Robinson (info)!"
      _(written_entries).must_include "Danger Will Robinson (warn)!"
      _(written_entries).must_include "Danger Will Robinson (error)!"
      _(written_entries).must_include "Danger Will Robinson (fatal)!"
      _(written_entries).must_include "Danger Will Robinson (unknown)!"
    end

    def entries_via_backoff type
      filter = "resource.type = \"gce_instance\" AND " +
        "log_name = \"projects/#{logging.project}/logs/#{log_name}-#{type}\""
      entries = logging.entries filter: filter
      if entries.count < 6 && @sleep < 10
        @sleep += 1
        puts "sleeping for #{@sleep} seconds to and retry pulling #{type} log entries"
        sleep @sleep
        return entries_via_backoff type
      end
      entries
    end
  end

  describe "Ruby Async Logger" do
    let(:log_name) { "#{prefix}-logger" }
    let(:resource) { logging.resource "gce_instance", zone: "global", instance_id: "3" }
    let(:labels) { { env: :production } }

    before do
      @sleep = 2
    end

    it "writes to a log with add and a symbol" do
      async = logging.async_writer
      logger = async.logger "#{log_name}-symbol", resource, labels

      logger.add :debug,   "Danger Will Robinson (:debug)!"
      logger.add :info,    "Danger Will Robinson (:info)!"
      logger.add :warn,    "Danger Will Robinson (:warn)!"
      logger.add :error,   "Danger Will Robinson (:error)!"
      logger.add :fatal,   "Danger Will Robinson (:fatal)!"
      logger.add :unknown, "Danger Will Robinson (:unknown)!"

      async.stop! 10

      skip "Removed due to inconsistent failure by the service to retrieve written_entries. Reinstate when service stabilizes."
      written_entries = entries_via_backoff("symbol").map &:payload

      _(written_entries).must_include "Danger Will Robinson (:debug)!"
      _(written_entries).must_include "Danger Will Robinson (:info)!"
      _(written_entries).must_include "Danger Will Robinson (:warn)!"
      _(written_entries).must_include "Danger Will Robinson (:error)!"
      _(written_entries).must_include "Danger Will Robinson (:fatal)!"
      _(written_entries).must_include "Danger Will Robinson (:unknown)!"
    end

    it "writes to a log with add and a string" do
      async = logging.async_writer
      logger = async.logger "#{log_name}-string", resource, labels

      logger.add "debug",   "Danger Will Robinson ('debug')!"
      logger.add "info",    "Danger Will Robinson ('info')!"
      logger.add "warn",    "Danger Will Robinson ('warn')!"
      logger.add "error",   "Danger Will Robinson ('error')!"
      logger.add "fatal",   "Danger Will Robinson ('fatal')!"
      logger.add "unknown", "Danger Will Robinson ('unknown')!"

      async.stop! 10

      skip "Removed due to inconsistent failure by the service to retrieve written_entries. Reinstate when service stabilizes."
      written_entries = entries_via_backoff("string").map &:payload

      _(written_entries).must_include "Danger Will Robinson ('debug')!"
      _(written_entries).must_include "Danger Will Robinson ('info')!"
      _(written_entries).must_include "Danger Will Robinson ('warn')!"
      _(written_entries).must_include "Danger Will Robinson ('error')!"
      _(written_entries).must_include "Danger Will Robinson ('fatal')!"
      _(written_entries).must_include "Danger Will Robinson ('unknown')!"
    end

    it "writes to a log with add and a constant" do
      async = logging.async_writer
      logger = async.logger "#{log_name}-constant", resource, labels

      logger.add ::Logger::DEBUG,   "Danger Will Robinson (DEBUG)!"
      logger.add ::Logger::INFO,    "Danger Will Robinson (INFO)!"
      logger.add ::Logger::WARN,    "Danger Will Robinson (WARN)!"
      logger.add ::Logger::ERROR,   "Danger Will Robinson (ERROR)!"
      logger.add ::Logger::FATAL,   "Danger Will Robinson (FATAL)!"
      logger.add ::Logger::UNKNOWN, "Danger Will Robinson (UNKNOWN)!"

      async.stop! 10

      skip "Removed due to inconsistent failure by the service to retrieve written_entries. Reinstate when service stabilizes."
      written_entries = entries_via_backoff("constant").map &:payload

      _(written_entries).must_include "Danger Will Robinson (DEBUG)!"
      _(written_entries).must_include "Danger Will Robinson (INFO)!"
      _(written_entries).must_include "Danger Will Robinson (WARN)!"
      _(written_entries).must_include "Danger Will Robinson (ERROR)!"
      _(written_entries).must_include "Danger Will Robinson (FATAL)!"
      _(written_entries).must_include "Danger Will Robinson (UNKNOWN)!"
    end

    it "writes to a log with named functions" do
      async = logging.async_writer
      logger = async.logger "#{log_name}-method", resource, labels

      logger.debug   "Danger Will Robinson (debug)!"
      logger.info    "Danger Will Robinson (info)!"
      logger.warn    "Danger Will Robinson (warn)!"
      logger.error   "Danger Will Robinson (error)!"
      logger.fatal   "Danger Will Robinson (fatal)!"
      logger.unknown "Danger Will Robinson (unknown)!"

      async.stop! 10

      skip "Removed due to inconsistent failure by the service to retrieve written_entries. Reinstate when service stabilizes."
      written_entries = entries_via_backoff("method").map &:payload

      _(written_entries).must_include "Danger Will Robinson (debug)!"
      _(written_entries).must_include "Danger Will Robinson (info)!"
      _(written_entries).must_include "Danger Will Robinson (warn)!"
      _(written_entries).must_include "Danger Will Robinson (error)!"
      _(written_entries).must_include "Danger Will Robinson (fatal)!"
      _(written_entries).must_include "Danger Will Robinson (unknown)!"
    end

    def entries_via_backoff type
      filter = "resource.type = \"gce_instance\" AND " +
        "log_name = \"projects/#{logging.project}/logs/#{log_name}-#{type}\""
      entries = logging.entries filter: filter
      if entries.count < 6 && @sleep < 10
        @sleep += 1
        puts "sleeping for #{@sleep} seconds to and retry pulling #{type} log entries"
        sleep @sleep
        return entries_via_backoff type
      end
      entries
    end
  end
end
