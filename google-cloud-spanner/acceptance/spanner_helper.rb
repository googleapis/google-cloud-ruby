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

# define SecureRandom.int64
require "securerandom"
# SecureRandom.int64 generates a random signed 64-bit integer.
#
# The result will be an integer between the values -9,223,372,036,854,775,808
# and 9,223,372,036,854,775,807.
def SecureRandom.int64
  random_bytes(8).unpack("q")[0]
end

def emulator_enabled?
  ENV["SPANNER_EMULATOR_HOST"]
end

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
    attr_accessor :spanner, :spanner_client

    ##
    # Setup project based on available ENV variables
    def setup
      @spanner = $spanner

      refute_nil @spanner, "You do not have an active spanner to run the tests."

      @spanner_client = $spanner_client

      refute_nil @spanner_client, "You do not have an active client to run the tests."

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
    #   reporter.prerecord klass, method_name
    #   (1..3).each do |try|
    #     result = Minitest.run_one_method(klass, method_name)
    #     break if (result.passed? || result.skipped?)
    #     puts "Retrying #{klass}##{method_name} (#{try})"
    #   end
    #   reporter.record result
    # end

    module Fixtures
      def stuffs_ddl_statement
        if emulator_enabled?
          <<-STUFFS
            CREATE TABLE stuffs (
              id INT64 NOT NULL,
              int INT64,
              float FLOAT64,
              bool BOOL,
              string STRING(MAX),
              byte BYTES(MAX),
              date DATE,
              timestamp TIMESTAMP OPTIONS (allow_commit_timestamp=true),
              ints ARRAY<INT64>,
              floats ARRAY<FLOAT64>,
              bools ARRAY<BOOL>,
              strings ARRAY<STRING(MAX)>,
              bytes ARRAY<BYTES(MAX)>,
              dates ARRAY<DATE>,
              timestamps ARRAY<TIMESTAMP>
            ) PRIMARY KEY (id)
          STUFFS
        else
          <<-STUFFS
            CREATE TABLE stuffs (
              id INT64 NOT NULL,
              int INT64,
              float FLOAT64,
              bool BOOL,
              string STRING(MAX),
              byte BYTES(MAX),
              date DATE,
              timestamp TIMESTAMP OPTIONS (allow_commit_timestamp=true),
              numeric NUMERIC,
              json JSON,
              ints ARRAY<INT64>,
              floats ARRAY<FLOAT64>,
              bools ARRAY<BOOL>,
              strings ARRAY<STRING(MAX)>,
              bytes ARRAY<BYTES(MAX)>,
              dates ARRAY<DATE>,
              timestamps ARRAY<TIMESTAMP>,
              numerics ARRAY<NUMERIC>,
              json_array ARRAY<JSON>
            ) PRIMARY KEY (id)
          STUFFS
        end
      end

      def stuffs_index_statement
        "CREATE INDEX IsStuffsIdPrime ON stuffs(bool, id)"
      end

      def commit_timestamp_test_ddl_statement
        <<-TEST
          CREATE TABLE commit_timestamp_test(committs TIMESTAMP OPTIONS (allow_commit_timestamp=true)) PRIMARY KEY (committs)
        TEST
      end

      def accounts_ddl_statement
        <<-ACCOUNTS
          CREATE TABLE accounts (
            account_id INT64 NOT NULL,
            username STRING(32),
            friends ARRAY<INT64>,
            active BOOL NOT NULL,
            reputation FLOAT64,
            avatar BYTES(8192)
          ) PRIMARY KEY (account_id)
        ACCOUNTS
      end

      def lists_ddl_statement
        <<-LISTS
          CREATE TABLE task_lists (
            account_id INT64 NOT NULL,
            task_list_id INT64 NOT NULL,
            description STRING(1024) NOT NULL
          ) PRIMARY KEY (account_id, task_list_id),
            INTERLEAVE IN PARENT accounts ON DELETE CASCADE
        LISTS
      end

      def items_ddl_statement
        <<-ITEMS
          CREATE TABLE task_items (
            account_id INT64 NOT NULL,
            task_list_id INT64 NOT NULL,
            task_item_id INT64 NOT NULL,
            description STRING(1024) NOT NULL,
            active BOOL NOT NULL,
            priority INT64 NOT NULL,
            due_date DATE,
            created_at TIMESTAMP,
            updated_at TIMESTAMP
          ) PRIMARY KEY (account_id, task_list_id, task_item_id),
            INTERLEAVE IN PARENT task_lists ON DELETE CASCADE
        ITEMS
      end

      def numeric_pk_ddl_statement
        return

        <<-BOXES
          CREATE TABLE boxes (
            id NUMERIC NOT NULL,
            name STRING(256) NOT NULL,
          ) PRIMARY KEY (id)
        BOXES
      end

      def numeric_composite_pk_ddl_statement
        return

        <<-BOX_ITEMS
          CREATE TABLE box_items (
            id INT64 NOT NULL,
            box_id NUMERIC NOT NULL,
            name STRING(256) NOT NULL
          ) PRIMARY KEY (id, box_id)
        BOX_ITEMS
      end

      def schema_ddl_statements
        [
          stuffs_ddl_statement,
          stuffs_index_statement,
          accounts_ddl_statement,
          lists_ddl_statement,
          items_ddl_statement,
          commit_timestamp_test_ddl_statement,
          numeric_pk_ddl_statement,
          numeric_composite_pk_ddl_statement
        ].compact
      end

      def stuffs_table_types
        { id: :INT64,
          int: :INT64,
          float: :FLOAT64,
          bool: :BOOL,
          string: :STRING,
          byte: :BYTES,
          date: :DATE,
          timestamp: :TIMESTAMP,
          json: :JSON,
          ints: [:INT64],
          floats: [:FLOAT64],
          bools: [:BOOL],
          strings: [:STRING],
          bytes: [:BYTES],
          dates: [:DATE],
          timestamps: [:TIMESTAMP],
          jsons: [:JSON]
        }
      end

      def stuffs_random_row id = SecureRandom.int64
        { id: id,
          int: rand(0..1000),
          float: rand(0.0..100.0),
          bool: [true, false].sample,
          string: SecureRandom.hex(16),
          byte: File.open("acceptance/data/face.jpg", "rb"),
          date: Date.today + rand(-100..100),
          timestamp: Time.now + rand(-60*60*24.0..60*60*24.0),
          json: { venue: "Yellow Lake", rating: 10 },
          ints: rand(2..10).times.map { rand(0..1000) },
          floats: rand(2..10).times.map { rand(0.0..100.0) },
          bools: rand(2..10).times.map { [true, false].sample },
          strings: rand(2..10).times.map { SecureRandom.hex(16) },
          bytes: [File.open("acceptance/data/face.jpg", "rb"),
                  File.open("acceptance/data/landmark.jpg", "rb"),
                  File.open("acceptance/data/logo.jpg", "rb")],
          dates: rand(2..10).times.map { Date.today + rand(-100..100) },
          timestamps: rand(2..10).times.map { Time.now + rand(-60*60*24.0..60*60*24.0) },
          json_array: [{ venue: "Green Lake", rating: 8 }, { venue: "Blue Lake", rating: 9 }]
        }
      end

      def default_account_rows
        [
          {
            account_id: 1,
            username: "blowmage",
            reputation: 63.5,
            active: true,
            avatar: File.open("acceptance/data/logo.jpg", "rb"),
            friends: [2]
          }, {
            account_id: 2,
            username: "quartzmo",
            reputation: 87.9,
            active: true,
            avatar: StringIO.new("iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAAAXNSR0IArs4c6QAAABxpRE9UAAAAAgAAAAAAAAAgAAAAKAAAACAAAAAgAAABxj2CfowAAAGSSURBVHgB7Jc9TsNAEIX3JDkCPUV6KlpKFHEGlD4nyA04ACUXQKTgCEipUnKGNEbP0otentayicZ24SlWs7tjO/N9u/5J2b2+NUtuZcnwYE8BuQPyGZAPwXwLLPk5kG+BJa9+fgfkh1B+CeancL4F8i2Q/wWm/S/w+XFoTseftn0dvhu0OXfhpM+AGvzcEiYVAFisPqE9zrETJhHAlXfg2lglMK9z0f3RBfB+ZyRUV3x+erzsEIjjOBqc1xtNAIrvguybV3A9lkVHxlEE6GrrPb/ZvAySwlUnfCmlPQ+R8JCExvGtcRQBLFwj4FGkznX1VYDKPG/f2/MjwCksXACgdNUxJjwK9xwl4JihOwTFR0kIF+CABEPRnvsvPFctMoYKqAFSAFaMwB4pp3Y+bodIYL9WmIAaIOHxo7W8wiHvAjTvhUeNwwSgeAeAABbqOewC5hBdwFD4+9+7puzXV9fS6/b1wwT4tsaYAhwOOQdUQch5vgZCeAhAv3ZM31yYAAUgvApQQQ6n5w6FB/RVe1jdJOAPAAD//1eMQwoAAAGQSURBVO1UMU4DQQy8X9AgWopIUINEkS4VlJQo4gvwAV7AD3gEH4iSgidESpWSXyyZExP5lr0c7K5PsXBhec/2+jzjuWtent9CLdtu1mG5+gjz+WNr7IsY7eH+tvO+xfuqk4vz7CH91edFaF5v9nb6dBKm13edvrL+0Lk5lMzJkQDeJSkkgHF6mR8CHwMHCQR/NAQQGD0BAlwK4FCefQiefq+A2Vn29tG7igLAfmwcnJu/nJy3BMQkMN9HEPr8AL3bfBv7Bp+7/SoExMDjZwKEJwmyhnnmQIQEBIlz2x0iKoAvJkAC6TsTIH6MqRrEWUMSZF2zAwqT4Eu/e6pzFAIkmNSZ4OFT+VYBIIF//UqbJwnF/4DU0GwOn8r/JQYCpPGufEfJuZiA37ycQw/5uFeqPq4pfR6FADmkBCXjfWdZj3NfXW58dAJyB9W65wRoMWulryvAyqa05nQFaDFrpa8rwMqmtOZ0BWgxa6WvK8DKprTmdAVoMWulryvAyqa05nQFaDFrpa8rwMqmtOb89wr4AtQ4aPoL6yVpAAAAAElFTkSuQmCC"),
            friends: [1]
          }, {
            account_id: 3,
            username: "-inactive-",
            active: false
          }
        ]
      end

      def default_list_rows
      end

      def default_item_rows
      end
    end

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
require "securerandom"
$spanner_instance_id = "google-cloud-ruby-tests"
# $spanner_database_id is already 22 characters, can only add 7 additional characters
$spanner_database_id = "gcruby-#{Date.today.strftime "%y%m%d"}-#{SecureRandom.hex(4)}"

# Setup main instance and database for the tests
fixture = Object.new
fixture.extend Acceptance::SpannerTest::Fixtures

instance = $spanner.instance $spanner_instance_id

instance ||= begin
  inst_job = $spanner.create_instance $spanner_instance_id, name: "google-cloud-ruby-tests", config: "regional-us-central1", nodes: 1
  inst_job.wait_until_done!
  fail GRPC::BadStatus.new(inst_job.error.code, inst_job.error.message) if inst_job.error?
  inst_job.instance
end

db_job = instance.create_database $spanner_database_id, statements: fixture.schema_ddl_statements
db_job.wait_until_done!
fail GRPC::BadStatus.new(db_job.error.code, db_job.error.message) if db_job.error?

# Create one client for all tests, to minimize resource usage
$spanner_client = $spanner.client $spanner_instance_id, $spanner_database_id

def clean_up_spanner_objects
  puts "Cleaning up instances and databases after spanner tests."
  $spanner.instance($spanner_instance_id).database($spanner_database_id).drop

  puts "Closing the Spanner Client."
  $spanner_client.close

  puts "Cleaning up instances databases and backups after spanner tests."
  instance = $spanner.instance($spanner_instance_id)

  # Delete test database backups.
  unless emulator_enabled?
    instance.backups(filter: "name:#{$spanner_database_id}").all.each do |backup|
      backup.delete
    end
  end

  # Delete test restored database.
  restored_db = instance.database("restore-#{$spanner_database_id}")
  restored_db.drop if restored_db
rescue => e
  puts "Error while cleaning up instances and databases after spanner tests.\n\n#{e}"
end

Minitest.after_run do
  clean_up_spanner_objects
end
