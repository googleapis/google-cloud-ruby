# Copyright 2015 Google Inc. All rights reserved.
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

require "helper"
require "gcloud/pubsub"

Gcloud::Backoff.retries = 10

# Create shared pubsub object so we don't create new for each test
$pubsub = Gcloud.pubsub

module Regression
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
  end
end

# Create buckets to be shared with all the tests
require "time"
require "securerandom"
t = Time.now.utc.iso8601.gsub ":", "-"
$topic_prefix = "gcloud-ruby-regression-#{t}-".downcase
$topic_names = 7.times.map { "#{$topic_prefix}-#{SecureRandom.hex(4)}".downcase }

def clean_up_pubsub_topics
  puts "Cleaning up pubsub topics after tests."
  $topic_names.each do |topic_name|
    if t = $pubsub.get_topic(topic_name)
      t.subscriptions.each { |s| s.delete }
      t.delete
    end
  end
rescue => e
  puts "Error while cleaning up pubsub topics after tests.\n\n#{e}"
end

Minitest.after_run do
  clean_up_pubsub_topics
end
