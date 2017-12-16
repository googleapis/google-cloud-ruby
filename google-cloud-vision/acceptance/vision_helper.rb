# Copyright 2016 Google LLC
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
require "google/cloud/vision"

# Create shared vision object so we don't create new for each test
$vision = Google::Cloud::Vision.new

require "google/cloud/storage"

# Create shared storage object so we don't create new for each test
$storage = Google::Cloud::Storage.new retries: 10

module Acceptance
  ##
  # Test class for running against a Vision instance.
  # Ensures that there is an active connection for the tests to use.
  #
  # This class can be used with the spec DSL.
  # To do so, add :vision to describe:
  #
  #   describe "My Vision Test", :vision do
  #     it "does a thing" do
  #       your.code.must_be :thing?
  #     end
  #   end
  class VisionTest < Minitest::Test
    attr_accessor :vision, :storage

    ##
    # Setup project based on available ENV variables
    def setup
      @vision = $vision

      refute_nil @vision, "You do not have an active vision to run the tests."

      @storage = $storage

      refute_nil @storage, "You do not have an active storage to run the tests."

      super
    end

    # Add spec DSL
    extend Minitest::Spec::DSL

    # Register this spec type for when :vision is used.
    register_spec_type(self) do |desc, *addl|
      addl.include? :vision
    end

    def assert_array_in_delta exp, act, msg = nil
      assert_kind_of Array, exp
      assert_kind_of Array, act
      assert_equal exp.length, act.length, "Arrays being compared must be the same length"
      exp.zip(act).each do |exp_val, act_val|
        assert_in_delta exp_val, act_val
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
$vision_prefix = "gcloud-vision-acceptance-#{t}-#{SecureRandom.hex(4)}".downcase

def clean_up_vision_storage_objects
  puts "Cleaning up storage buckets after vision tests."
  if b = $storage.bucket($vision_prefix)
    b.files.all(&:delete)
    b.delete
  end
rescue => e
  puts "Error while cleaning up storage buckets after vision tests.\n\n#{e}"
end

Minitest.after_run do
  clean_up_vision_storage_objects
end

module MiniTest::Expectations
  infect_an_assertion :assert_array_in_delta, :must_be_close_to_array
end
