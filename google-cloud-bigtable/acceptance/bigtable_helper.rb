
# frozen_string_literal: true

# Copyright 2018 Google LLC
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
require "minitest/spec"
require "minitest/focus"
require "minitest/rg"
require "google/cloud/bigtable"
require "securerandom"

# Create shared bigtable object so we don't create new for each test
$bigtable = Google::Cloud.new.bigtable

module Acceptance
  # Test class for running against a Bigtable instance.
  # Ensures that there is an active connection for the tests to use.
  #
  # This class can be used with the spec DSL.
  # To do so, add :bigtable to describe:
  #
  #   describe "My Bigtable Test", :bigtable do
  #     it "does a thing" do
  #       your.code.must_be :thing?
  #     end
  #   end
  #
  class BigtableTest < Minitest::Test
    attr_accessor :bigtable

    # Setup project based on available ENV variables
    def setup
      @bigtable = $bigtable
      refute_nil @bigtable, "You do not have an active bigtable to run the tests."
      super
    end

    def bigtable_instance
      @bigtable.instance($bigtable_instance_id)
    end

    def bigtable_cluster_id
      $bigtable_cluster_id
    end

    def bigtable_instance_id
      $bigtable_instance_id
    end

    def bigtable_cluster_location
      $bigtable_cluster_location
    end

    def random_str
      SecureRandom.hex(4)
    end

    # Add spec DSL
    extend Minitest::Spec::DSL

    # Register this spec type for when client instance is used.
    register_spec_type(self) do |_desc, *addl|
      addl.include? :bigtable
    end
  end
end

# Create instance
def create_test_instance instance_id, cluster_id, cluster_location
  p "=> Creating instance #{instance_id}."

  job = $bigtable.create_instance(
   instance_id,
   display_name: "Ruby Acceptance Test",
   labels: { "env": "test"},
  ) do |clusters|
    clusters.add(cluster_id, cluster_location, nodes: 3)
  end

  job.wait_until_done!

  fail GRPC::BadStatus.new(job.error.code, job.error.message) if job.error?

  instance = job.instance

  loop do
    instance.reload!

    # Wait until instance ready
    if instance.ready?
      p "=> '#{instance.instance_id}' instance is ready."
      break
    else
      sleep(5)
    end
  end

  instance
end

def clean_up_bigtable_objects instance_id
  instance = $bigtable.instance(instance_id)

  p "=> Deleting acceptance test instance #{instance_id}."
  begin
    instance.delete
  rescue StandardError => e
    puts "Error while cleaning up #{instance.instance_id} instance.\n\n#{e}"
  end
end

# Test instance
$bigtable_instance_id = "google-cloud-ruby-tests"
$bigtable_cluster_location = "us-east1-b"
$bigtable_cluster_id = "test-cluster"

create_test_instance(
  $bigtable_instance_id,
  $bigtable_cluster_id,
  $bigtable_cluster_location
)

Minitest.after_run do
  clean_up_bigtable_objects($bigtable_instance_id)
end
