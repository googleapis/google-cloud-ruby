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

# require "helper"
# require "gcloud/search"
#
# Gcloud::Backoff.retries = 10
#
# # Create shared search object so we don't create new for each test
# $search = Gcloud.search
#
# # create prefix for names of datasets and tables
# require "time"
# require "securerandom"
# t = Time.now.utc.iso8601.gsub ":", "_"
# $prefix = "gcloud_ruby_acceptance_#{t}_#{SecureRandom.hex(4)}".downcase.gsub "-", "_"
#
# module Acceptance
#   ##
#   # Test class for running against a search instance.
#   # Ensures that there is an active connection for the tests to use.
#   #
#   # This class can be used with the spec DSL.
#   # To do so, add :search to describe:
#   #
#   #   describe "My search Test", :search do
#   #     it "does a thing" do
#   #       your.code.must_be :thing?
#   #     end
#   #   end
#   class SearchTest < Minitest::Test
#     attr_accessor :search
#     attr_accessor :prefix
#
#     ##
#     # Setup project based on available ENV variables
#     def setup
#       @search = $search
#       @prefix = $prefix
#
#       refute_nil @search, "You do not have an active search to run the tests."
#       refute_nil @prefix, "You do not have an search prefix to name the datasets and tables with."
#
#       super
#     end
#
#     # Add spec DSL
#     extend Minitest::Spec::DSL
#
#     # Register this spec type for when :search is used.
#     register_spec_type(self) do |desc, *addl|
#       addl.include? :search
#     end
#   end
#
#   def self.run_one_method klass, method_name, reporter
#     result = nil
#     (1..3).each do |try|
#       result = Minitest.run_one_method(klass, method_name)
#       break if (result.passed? || result.skipped?)
#       puts "Retrying #{klass}##{method_name} (#{try})"
#     end
#     reporter.record result
#   end
# end
#
# def clean_up_search_indexes
#   puts "Cleaning up search indexes and documents after tests."
#   $search.indexes(prefix: $prefix).map { |i| i.delete force: true }
# rescue => e
#   puts "Error while cleaning up search indexes and documents after tests.\n\n#{e}"
# end
#
# Minitest.after_run do
#   clean_up_search_indexes
# end
