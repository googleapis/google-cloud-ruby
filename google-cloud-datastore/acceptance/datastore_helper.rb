# Copyright 2014 Google LLC
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
require "google/cloud/datastore"
require "securerandom"

# Create shared dataset object so we don't create new for each test
$dataset = Google::Cloud.new.datastore

module Acceptance
  ##
  # Test class for running against a Datastore instance.
  # Ensures that there is an active connection for the tests to use.
  # Can be used to run tests against a hosted datastore or emulator.
  #
  # This class can be used with the spec DSL.
  # To do so, add :datastore to describe:
  #
  #   describe "My Datastore Test", :datastore do
  #     it "does a thing" do
  #       your.code.must_be :thing?
  #     end
  #   end
  class DatastoreTest < Minitest::Test
    attr_accessor :dataset

    ##
    # Setup project based on available ENV variables
    def setup
      @dataset = $dataset

      refute_nil @dataset, "You do not have an active dataset to run the tests."

      super
    end

    # Add spec DSL
    extend Minitest::Spec::DSL

    # Register this spec type for when :datastore is used.
    register_spec_type(self) do |desc, *addl|
      addl.include? :datastore
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
  end
end
