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

require "google/cloud/spanner"
require "google/cloud/spanner/admin/database"

require "data/fixtures"

# define SecureRandom.int64
require "securerandom"
# SecureRandom.int64 generates a random signed 64-bit integer.
#
# The result will be an integer between the values -9,223,372,036,854,775,808
# and 9,223,372,036,854,775,807.
def SecureRandom.int64
  random_bytes(8).unpack1("q")
end

def emulator_enabled?
  ENV["SPANNER_EMULATOR_HOST"]
end

def make_params dialect, value
  key = dialect == :gsql ? :value : :p1
  { key => value }
end

# Create shared spanner object so we don't create new for each test
$spanner = Google::Cloud::Spanner.new
$spanner_db_admin = Google::Cloud::Spanner::Admin::Database.database_admin

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
    attr_accessor :spanner_client
    attr_accessor :spanner_pg_client

    ##
    # Setup project based on available ENV variables
    def setup
      @spanner = $spanner

      refute_nil @spanner, "You do not have an active spanner to run the tests."

      @spanner_client = $spanner_client

      refute_nil @spanner_client, "You do not have an active client to run the tests."

      @spanner_pg_client = $spanner_pg_client

      super
    end

    # Add spec DSL
    extend Minitest::Spec::DSL

    # Register this spec type for when :spanner is used.
    register_spec_type self do |_desc, *addl|
      addl.include? :spanner
    end

    # def self.run_one_method klass, method_name, reporter
    #   result = nil
    #   reporter.prerecord klass, method_name
    #   (1..3).each do |try|
    #     result = Minitest.run_one_method(klass, method_name)
    #     break if (result.passed? || result.skipped?)
    #     puts "Retrying #{klass}##{method_name} (#{try})"
    #   end
    #   reporter.record result
    # end

    include Fixtures

    def assert_commit_response resp, commit_options = {}
      _(resp.timestamp).must_be_kind_of Time

      if commit_options[:return_commit_stats]
        _(resp.stats).must_be_kind_of Google::Cloud::Spanner::CommitResponse::CommitStats
        _(resp.stats.mutation_count).must_be :>, 0
      else
        _(resp.stats).must_be :nil?
      end
    end
  end
end

# Create buckets to be shared with all the tests
require "date"
$spanner_instance_id = "google-cloud-ruby-tests"
# $spanner_database_id is already 22 characters, can only add 7 additional characters
$spanner_database_id = "gcruby-#{Date.today.strftime '%y%m%d'}-#{SecureRandom.hex 4}"
$spanner_pg_database_id = "gcruby-pg-#{Date.today.strftime '%y%m%d'}-#{SecureRandom.hex 4}"

# Setup main instance and database for the tests
fixture = Object.new
fixture.extend Acceptance::Fixtures

instance = $spanner.instance $spanner_instance_id

instance ||= begin
  inst_job = $spanner.create_instance $spanner_instance_id, name: "google-cloud-ruby-tests",
config: "regional-us-central1", nodes: 1
  inst_job.wait_until_done!
  raise GRPC::BadStatus.new(inst_job.error.code, inst_job.error.message) if inst_job.error?
  inst_job.instance
end

db_job = instance.create_database $spanner_database_id, statements: fixture.schema_ddl_statements
db_job.wait_until_done!
raise GRPC::BadStatus.new(db_job.error.code, db_job.error.message) if db_job.error?

unless emulator_enabled?
  instance_path = $spanner_db_admin.instance_path project: $spanner.project_id, instance: $spanner_instance_id
  db_job = $spanner_db_admin.create_database parent: instance_path,
                                             create_statement: "CREATE DATABASE \"#{$spanner_pg_database_id}\"",
                                             database_dialect: :POSTGRESQL
  db_job.wait_until_done!
  raise GRPC::BadStatus.new(db_job.error.code, db_job.error.message) if db_job.error?
  db_path = $spanner_db_admin.database_path project: $spanner.project_id,
                                            instance: $spanner_instance_id,
                                            database: $spanner_pg_database_id

  db_job = $spanner_db_admin.update_database_ddl database: db_path, statements: fixture.schema_pg_ddl_statements
  db_job.wait_until_done!
  raise GRPC::BadStatus.new(db_job.error.code, db_job.error.message) if db_job.error?
end

# Create one client for all tests, to minimize resource usage
$spanner_client = $spanner.client $spanner_instance_id, $spanner_database_id
$spanner_pg_client = $spanner.client $spanner_instance_id, $spanner_pg_database_id unless emulator_enabled?

def clean_up_spanner_objects
  puts "Cleaning up instances and databases after spanner tests."
  $spanner.instance($spanner_instance_id).database($spanner_database_id).drop
  $spanner.instance($spanner_instance_id).database($spanner_pg_database_id).drop unless emulator_enabled?

  puts "Closing the Spanner Client."
  $spanner_client.close
  $spanner_pg_client.close unless emulator_enabled?

  puts "Cleaning up instances databases and backups after spanner tests."
  instance = $spanner.instance $spanner_instance_id

  # Delete test database backups.
  unless emulator_enabled?
    instance.backups(filter: "name:#{$spanner_database_id}").all.each(&:delete)
  end

  # Delete test restored database.
  restored_db = instance.database "restore-#{$spanner_database_id}"
  restored_db&.drop
rescue StandardError => e
  puts "Error while cleaning up instances and databases after spanner tests.\n\n#{e}"
end

Minitest.after_run do
  clean_up_spanner_objects
end
