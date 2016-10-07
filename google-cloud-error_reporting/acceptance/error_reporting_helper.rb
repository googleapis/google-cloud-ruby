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


gem "minitest"
require "minitest/autorun"
require "minitest/rg"
require "google/cloud/error_reporting"

# Create shared error_reporting object so we don't create new for each test
$error_reporting = Google::Cloud.new.error_reporting retries: 10

# create prefix for names of datasets and tables
require "time"
require "securerandom"
t = Time.now.utc.iso8601.gsub ":", "_"
$prefix = "google-cloud_ruby_acceptance_#{t}_#{SecureRandom.hex(4)}".downcase.gsub "-", "_"

module Acceptance
  ##
  # Test class for running against a error_reporting instance.
  # Ensures that there is an active connection for the tests to use.
  #
  # This class can be used with the spec DSL.
  # To do so, add :error_reporting to describe:
  #
  #   describe "My error_reporting Test", :error_reporting do
  #     it "does a thing" do
  #       your.code.must_be :thing?
  #     end
  #   end
  class ErrorReportingTest < Minitest::Test
    attr_accessor :error_reporting
    attr_accessor :prefix

    ##
    # Setup project based on available ENV variables
    def setup
      @error_reporting = $error_reporting
      @prefix = $prefix

      refute_nil @error_reporting, "You do not have an active error_reporting to run the tests."
      refute_nil @prefix, "You do not have an error_reporting prefix to name the sinks with."

      super
    end

    # Add spec DSL
    extend Minitest::Spec::DSL

    # Register this spec type for when :error_reporting is used.
    register_spec_type(self) do |desc, *addl|
      addl.include? :error_reporting
    end
  end

  def self.run_one_method klass, method_name, reporter
    result = nil
    (1..3).each do |try|
      result = Minitest.run_one_method(klass, method_name)
      break if (result.passed? || result.skipped?)
      puts "Retrying #{klass}##{method_name} (#{try})"
    end
    reporter.record result
  end
end