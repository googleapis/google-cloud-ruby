
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

require "simplecov"

gem "minitest"
require "minitest/autorun"
require "minitest/spec"
require "minitest/focus"
require "minitest/rg"
require "google/cloud/bigtable"
require "securerandom"

# Generate JUnit format test reports
if ENV["GCLOUD_TEST_GENERATE_XML_REPORT"]
  require "minitest/reporters"
  Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new, Minitest::Reporters::JUnitReporter.new]
end

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
      @instance ||= bigtable.instance(bigtable_instance_id)
    end

    def bigtable_instance_2
      @instance_2 ||= @bigtable.instance(bigtable_instance_id_2)
    end

    def bigtable_read_table
      bigtable.table(bigtable_instance_id, $bigtable_read_table_id)
    end

    def bigtable_mutation_table
      bigtable.table(bigtable_instance_id, $bigtable_mutation_table_id)
    end

    def random_str
      SecureRandom.hex(4)
    end

    def create_table table_id, row_count: nil
      create_test_table(bigtable_instance_id, table_id, row_count: row_count)
    end

    def add_table_to_cleanup_list table_id
      $table_list_for_cleanup << table_id
    end

    # Add spec DSL
    extend Minitest::Spec::DSL

    # Register this spec type for when client instance is used.
    register_spec_type(self) do |_desc, *addl|
      addl.include? :bigtable
    end
  end
end

# Find or create instance
def create_test_instance instance_id, cluster_id, cluster_location
  instance = $bigtable.instance(instance_id)

  if instance.nil?
    p "=> Creating instance #{instance_id} in zone #{cluster_location}."

    job = $bigtable.create_instance(
      instance_id,
      display_name: "Ruby Acceptance Test",
      labels: { env: "test" }
    ) do |clusters|
      clusters.add(cluster_id, cluster_location, nodes: 3)
    end

    job.wait_until_done!

    raise GRPC::BadStatus.new(job.error.code, job.error.message) if job.error?

    instance = job.instance
  end

  loop do
    # Wait until instance ready
    if instance.ready?
      p "=> '#{instance.instance_id}' instance is ready."
      break
    else
      sleep(5)
      instance.reload!
    end
  end

  instance
end

$table_list_for_cleanup = []

def create_test_table instance_id, table_id, row_count: nil, cleanup: true
  table = $bigtable.create_table(instance_id, table_id) do |cfs|
    cfs.add('cf', gc_rule: Google::Cloud::Bigtable::GcRule.max_versions(1))
  end

  $table_list_for_cleanup << table_id if cleanup

  return table unless row_count

  entries = row_count.times.map do |i|
    entry = table.new_mutation_entry("test-#{i+1}")
    entry.set_cell("cf", "field1", "value-#{i+1}")
    entry.set_cell("cf", "field2", i+1)
    entry
  end

  table.mutate_rows(entries)
  table
end

def clean_up_bigtable_objects instance_id, table_ids = []
  p "=> Deleting acceptance test tables from instance #{instance_id}."

  begin
    table_ids.each do |table_id|
      $bigtable.delete_table(instance_id, table_id)
    end
  rescue StandardError => e
    puts "Error while cleaning up #{instance_id} instance tables.\n\n#{e}"
  end
end

require "date"
require "securerandom"

def bigtable_instance_id
  "google-cloud-ruby-tests"
end

def bigtable_instance_id_2
  "google-cloud-ruby-tests-2"
end

def bigtable_cluster_location
  "us-east1-b"
end

def bigtable_cluster_location_2
  "us-east1-c"
end

def bigtable_cluster_id
  "#{bigtable_instance_id}-clstr"
end

def bigtable_cluster_id_2
  "#{bigtable_instance_id}-clstr2"
end

def bigtable_kms_key
  # Allow overriding the KMS key used for tests via an environment variable. These keys are public, but access may be
  # restricted when tests are run from a VPC project.
  ENV["BIGTABLE_TEST_KMS_KEY"] || "projects/helical-zone-771/locations/us-east1/keyRings/bigtable-test/cryptoKeys/bigtable-test-1"
end

create_test_instance(
  bigtable_instance_id,
  bigtable_cluster_id,
  bigtable_cluster_location
)

create_test_instance(
  bigtable_instance_id_2,
  bigtable_cluster_id_2,
  bigtable_cluster_location
)

$bigtable_read_table_id = "r-#{Date.today.strftime "%y%m%d"}-#{SecureRandom.hex(2)}"
$bigtable_mutation_table_id = "r-#{Date.today.strftime "%y%m%d"}-#{SecureRandom.hex(2)}"

create_test_table(bigtable_instance_id, $bigtable_read_table_id, row_count: 5)
create_test_table(bigtable_instance_id, $bigtable_mutation_table_id)

Minitest.after_run do
  clean_up_bigtable_objects(bigtable_instance_id, $table_list_for_cleanup)
end
