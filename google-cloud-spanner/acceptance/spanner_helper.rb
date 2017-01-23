# Copyright 2017 Google Inc. All rights reserved.
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
require "google/cloud/spanner"

# Create shared spanner object so we don't create new for each test
$spanner = Google::Cloud::Spanner.new

module Acceptance
  ##
  # Test class for running against a Spanner instance.
  # Ensures that there is an active connection for the tests to use.
  #
  # This class can be used with the spec DSL.
  # To do so, add :spanner to describe:
  #
  #   describe "My Spanner Test", :spanner do
  #     it "does a thing" do
  #       your.code.must_be :thing?
  #     end
  #   end
  class SpannerTest < Minitest::Test
    attr_accessor :spanner

    ##
    # Setup project based on available ENV variables
    def setup
      @spanner = $spanner

      refute_nil @spanner, "You do not have an active spanner to run the tests."

      super
    end

    # Add spec DSL
    extend Minitest::Spec::DSL

    # Register this spec type for when :spanner is used.
    register_spec_type(self) do |desc, *addl|
      addl.include? :spanner
    end

    # def self.run_one_method klass, method_name, reporter
    #   result = nil
    #   (1..3).each do |try|
    #     result = Minitest.run_one_method(klass, method_name)
    #     break if (result.passed? || result.skipped?)
    #     puts "Retrying #{klass}##{method_name} (#{try})"
    #   end
    #   reporter.record result
    # end
  end
end

# Create buckets to be shared with all the tests
require "date"
require "securerandom"
# prefix is already 22 characters, can only add 7 additional characters
$spanner_prefix = "gcruby-#{Date.today.strftime "%y%m%d"}-#{SecureRandom.hex(4)}"

# Setup main instance and database for the tests
job = $spanner.create_instance $spanner_prefix, name: $spanner_prefix, config: "regional-us-central1", nodes: 1
job.wait_until_done!
# job2 = job.instance.create_database "main"
# job2.wait_until_done!

def clean_up_spanner_objects
  puts "Cleaning up instances and databases after spanner tests."
  $spanner.instances.all.select { |i| i.instance_id.start_with? $spanner_prefix }.each do |instance|
    instance.databases.all.each &:drop
    instance.delete
  end
rescue => e
  puts "Error while cleaning up instances and databases after spanner tests.\n\n#{e}"
end

Minitest.after_run do
  clean_up_spanner_objects
end
