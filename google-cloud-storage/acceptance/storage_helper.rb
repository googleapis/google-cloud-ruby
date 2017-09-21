# Copyright 2014 Google Inc. All rights reserved.
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

gem "minitest"
require "minitest/autorun"
require "minitest/focus"
require "minitest/rg"
require "google/cloud/storage"
require "google/cloud/pubsub"

# Create shared storage object so we don't create new for each test
$storage = Google::Cloud.new.storage retries: 10

module Acceptance
  ##
  # Test class for running against a Storage instance.
  # Ensures that there is an active connection for the tests to use.
  #
  # This class can be used with the spec DSL.
  # To do so, add :storage to describe:
  #
  #   describe "My Storage Test", :storage do
  #     it "does a thing" do
  #       your.code.must_be :thing?
  #     end
  #   end
  class StorageTest < Minitest::Test
    attr_accessor :storage
    attr_accessor :prefix

    ##
    # Setup project based on available ENV variables
    def setup
      @storage = $storage
      @prefix = $prefix

      refute_nil @storage, "You do not have an active storage to run the tests."
      refute_nil @prefix, "You do not have a prefix to name the pubsub topics with."

      super
    end

    # Add spec DSL
    extend Minitest::Spec::DSL

    # Register this spec type for when :storage is used.
    register_spec_type(self) do |desc, *addl|
      addl.include? :storage
    end

    def try_with_backoff msg = nil, limit: 10
      count = 0
      loop do
        begin
          return yield
        rescue => e
          raise e if count >= limit
          count += 1
          puts "Retry (#{count}): #{msg}"
          sleep count
        end
      end
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
$bucket_names = 4.times.map { "gcloud-ruby-acceptance-#{t}-#{SecureRandom.hex(4)}".downcase }
$prefix = "gcloud_ruby_acceptance_#{t}_#{SecureRandom.hex(4)}".downcase.gsub "-", "_"

def clean_up_storage_buckets
  puts "Cleaning up storage buckets after tests."
  $bucket_names.each do |bucket_name|
    if b = $storage.bucket(bucket_name)
      begin
        b.files(versions: true).all do |file|
          file.delete generation: true
        end
        # Add one second delay between bucket deletes to avoid rate limiting errors
        sleep 1
        b.delete
      rescue => e
        puts "Error while cleaning up bucket #{b.name}\n\n#{e}"
      end
    end
  end
rescue => e
  puts "Error while cleaning up storage buckets after tests.\n\n#{e}"
end

Minitest.after_run do
  clean_up_storage_buckets
end
