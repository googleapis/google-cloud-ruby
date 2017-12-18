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
require "google/cloud/speech"

# Create shared speech object so we don't create new for each test
$speech = Google::Cloud.speech

require "google/cloud/storage"

# Create shared storage object so we don't create new for each test
$storage = Google::Cloud.new.storage retries: 10

module Acceptance
  ##
  # Test class for running against a Vision instance.
  # Ensures that there is an active connection for the tests to use.
  #
  # This class can be used with the spec DSL.
  # To do so, add :speech to describe:
  #
  #   describe "My Vision Test", :speech do
  #     it "does a thing" do
  #       your.code.must_be :thing?
  #     end
  #   end
  class SpeechTest < Minitest::Test
    attr_accessor :speech, :storage

    ##
    # Setup project based on available ENV variables
    def setup
      @speech = $speech

      refute_nil @speech, "You do not have an active speech to run the tests."

      @storage = $storage

      refute_nil @storage, "You do not have an active storage to run the tests."

      super
    end

    # Add spec DSL
    extend Minitest::Spec::DSL

    # Register this spec type for when :speech is used.
    register_spec_type(self) do |desc, *addl|
      addl.include? :speech
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
$speech_prefix = "gcloud-speech-acceptance-#{t}-#{SecureRandom.hex(4)}".downcase

def clean_up_speech_storage_objects
  puts "Cleaning up storage buckets after speech tests."
  if b = $storage.bucket($speech_prefix)
    b.files.all(&:delete)
    b.delete
  end
rescue => e
  puts "Error while cleaning up storage buckets after speech tests.\n\n#{e}"
end

Minitest.after_run do
  clean_up_speech_storage_objects
end
