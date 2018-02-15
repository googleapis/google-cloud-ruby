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
require "google/cloud/logging"

# Create shared logging object so we don't create new for each test
$logging = Google::Cloud::Logging.new

# create prefix for names of datasets and tables
require "time"
require "securerandom"
t = Time.now.utc.iso8601.gsub ":", "_"
$prefix = "gcloud_ruby_acceptance_#{t}_#{SecureRandom.hex(4)}".downcase.gsub "-", "_"

module Acceptance
  ##
  # Test class for running against a logging instance.
  # Ensures that there is an active connection for the tests to use.
  #
  # This class can be used with the spec DSL.
  # To do so, add :logging to describe:
  #
  #   describe "My logging Test", :logging do
  #     it "does a thing" do
  #       your.code.must_be :thing?
  #     end
  #   end
  class LoggingTest < Minitest::Test
    attr_accessor :logging
    attr_accessor :prefix

    ##
    # Setup project based on available ENV variables
    def setup
      @logging = $logging
      @prefix = $prefix

      refute_nil @logging, "You do not have an active logging to run the tests."
      refute_nil @prefix, "You do not have an logging prefix to name the sinks with."

      super
    end

    # Add spec DSL
    extend Minitest::Spec::DSL

    # Register this spec type for when :logging is used.
    register_spec_type(self) do |desc, *addl|
      addl.include? :logging
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

def clean_up_logging_sinks_metrics
  puts "Cleaning up logging logs, sinks, and metrics after tests."
  $logging.logs.select { |l| l.include? $prefix }.each { |l| $logging.delete_log l }
  # $logging.sinks.select { |s| s.name.start_with? $prefix }.map &:delete
  $logging.metrics.select { |m| m.name.start_with? $prefix }.map &:delete
rescue => e
  puts "Error while cleaning up logging logs, sinks, and metrics after tests.\n\n#{e}"
end

Minitest.after_run do
  clean_up_logging_sinks_metrics
end
