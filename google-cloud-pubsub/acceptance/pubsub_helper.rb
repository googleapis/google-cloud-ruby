# Copyright 2015 Google LLC
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
require "minitest/reporters"
require "minitest/rg"
require "google/cloud/pubsub"

# Generate JUnit format test reports
Minitest::Reporters.use! [Minitest::Reporters::JUnitReporter.new]

# Create shared pubsub object so we don't create new for each test
$pubsub = Google::Cloud.new.pubsub

module Acceptance
  ##
  # Test class for running against a PubSub instance.
  # Ensures that there is an active connection for the tests to use.
  #
  # This class can be used with the spec DSL.
  # To do so, add :pubsub to describe:
  #
  #   describe "My PubSub Test", :pubsub do
  #     it "does a thing" do
  #       your.code.must_be :thing?
  #     end
  #   end
  class PubsubTest < Minitest::Test
    attr_accessor :pubsub

    ##
    # Setup project based on available ENV variables
    def setup
      @pubsub = $pubsub

      refute_nil @pubsub, "You do not have an active pubsub to run the tests."

      super
    end

    # Add spec DSL
    extend Minitest::Spec::DSL

    # Register this spec type for when :pubsub is used.
    register_spec_type(self) do |desc, *addl|
      addl.include? :pubsub
    end

    def self.run_one_method klass, method_name, reporter
      result = nil
      reporter.prerecord klass, method_name
      (1..3).each do |try|
        result = Minitest.run_one_method(klass, method_name)
        break if (result.passed? || result.skipped?)
        puts "Retrying #{klass}##{method_name} (#{try})"
      end
      reporter.record result
    end
  end
end

# Create buckets to be shared with all the tests
require "time"
require "securerandom"
t = Time.now.utc.iso8601.gsub ":", "-"
$topic_prefix = "gcloud-ruby-acceptance-#{t}-#{SecureRandom.hex(4)}".downcase
$topic_names = 8.times.map { "#{$topic_prefix}-#{SecureRandom.hex(4)}".downcase }
$snapshot_prefix = "gcloud-ruby-acceptance-#{t}-snapshot-#{SecureRandom.hex(4)}".downcase
$snapshot_names = 3.times.map { "#{$snapshot_prefix}-#{SecureRandom.hex(4)}".downcase }

def clean_up_pubsub_topics
  puts "Cleaning up pubsub topics after tests."
  $pubsub.topics.all do |topic|
    if topic.name.include? $topic_prefix
      topic.subscriptions.each(&:delete)
      topic.delete
    end
  end
rescue => e
  puts "Error while cleaning up pubsub topics after tests.\n\n#{e}"
end

def clean_up_pubsub_snapshots
  puts "Cleaning up pubsub snapshots after tests."
  $pubsub.snapshots.all do |snapshot|
    if snapshot.name.include? $snapshot_prefix
      snapshot.delete
    end
  end
rescue => e
  puts "Error while cleaning up pubsub snapshots after tests.\n\n#{e}"
end

Minitest.after_run do
  clean_up_pubsub_topics
  clean_up_pubsub_snapshots
end
