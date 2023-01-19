# Copyright 2017 Google LLC
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

require "simplecov"

gem "minitest"
require "minitest/autorun"
require "minitest/focus"
require "minitest/rg"
require "google/cloud/firestore"

# Create shared firestore object so we don't create new for each test
$firestore = Google::Cloud.firestore

if ENV["FIRESTORE_MULTI_DB_DATABASE"]
  $firestore_2 = Google::Cloud::Firestore.new project_id: ENV["GCLOUD_TEST_PROJECT"], keyfile: ENV["GOOGLE_APPLICATION_CREDENTIALS"], database_id: ENV["FIRESTORE_MULTI_DB_DATABASE"]
end

module Acceptance
  ##
  # Test class for running against a Firestore instance.
  # Ensures that there is an active connection for the tests to use.
  #
  # This class can be used with the spec DSL.
  # To do so, add :firestore to describe:
  #
  #   describe "My Firestore Test", :firestore do
  #     it "does a thing" do
  #       your.code.must_be :thing?
  #     end
  #   end
  class FirestoreTest < Minitest::Test
    attr_accessor :firestore
    attr_accessor :firestore_2

    ##
    # Setup project based on available ENV variables
    def setup
      @firestore = $firestore
      @firestore_2 = $firestore_2

      refute_nil @firestore, "You do not have an active firestore to run the tests."

      super
    end

    def root_path
      $firestore_prefix
    end

    def root_col
      @firestore.col root_path
    end

    # Add spec DSL
    extend Minitest::Spec::DSL

    # Register this spec type for when :firestore is used.
    register_spec_type(self) do |desc, *addl|
      addl.include? :firestore_acceptance
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
$firestore_prefix = "gcloud-#{t}-#{SecureRandom.hex(4)}".downcase

def clean_up_firestore
  puts "Cleaning up documents and collections after firestore tests."

  $firestore.batch do |b|
    $firestore.col($firestore_prefix).select($firestore.document_id).all_descendants.run.each_slice(500).with_index do |slice, index|
      $firestore.batch do |b|
        slice.each do |doc|
          b.delete doc
        end
      end
      puts "Deleted batch #{index+1} of #{slice.count} documents"
    end
  end
rescue => e
  puts "Error while cleaning up after firestore tests.\n\n#{e}"
end

Minitest.after_run do
  clean_up_firestore
  unless $firestore_2
    puts "The multiple database tests were not run. These tests require a secondary " \
       "database which is not configured. To enable, ensure that the following " \
       "is present in the environment: \n" \
       "FIRESTORE_MULTI_DB_DATABASE"
  end
end
