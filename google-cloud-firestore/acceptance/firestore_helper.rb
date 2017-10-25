# Copyright 2017, Google Inc. All rights reserved.
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
require "google/cloud/firestore"

# Create shared firestore object so we don't create new for each test
$firestore = Google::Cloud.firestore

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
    attr_accessor :firestore, :storage

    ##
    # Setup project based on available ENV variables
    def setup
      @firestore = $firestore

      refute_nil @firestore, "You do not have an active firestore to run the tests."

      super
    end

    # Add spec DSL
    extend Minitest::Spec::DSL

    # Register this spec type for when :firestore is used.
    register_spec_type(self) do |desc, *addl|
      addl.include? :firestore
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
$firestore_prefix = "gcloud-firestore-acceptance-#{t}-#{SecureRandom.hex(4)}".downcase

def clean_up_firestore
  # Nothing do do yet...
rescue => e
  puts "Error while cleaning up after firestore tests.\n\n#{e}"
end

Minitest.after_run do
  clean_up_firestore
end
