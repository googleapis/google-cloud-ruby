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


module Google
  module Cloud
    module Bigtable
      ##
      # # GcRule
      #
      # A rule or rules for determining which cells to delete during garbage
      # collection.
      #
      # Garbage collection (GC) executes opportunistically in the background,
      # so it is possible for reads to return a cell even if it matches the
      # active GC expression for its column family.
      #
      # @see https://cloud.google.com/bigtable/docs/garbage-collection Garbage collection
      #
      # GC Rule types:
      #   * `max_num_versions` - A garbage-collection rule that explicitly
      #     states the maximum number of cells to keep for all columns in a
      #     column family.
      #   * `max_age` - A garbage-collection rule based on the timestamp for
      #     each cell. With this type of garbage-collection rule, you set the
      #     time to live (TTL) for data. Cloud Bigtable looks at each column
      #     family during garbage collection and removes any cells that have
      #     expired.
      #   * `union` - A union garbage-collection policy will remove all data
      #     matching *any* of a set of given rules.
      #   * `intersection` - An intersection garbage-collection policy will
      #     remove all data matching *all* of a set of given rules.
      #
      # @example Create a table with column families.
      #   require "google/cloud/bigtable"
      #
      #   bigtable = Google::Cloud::Bigtable.new
      #
      #   table = bigtable.create_table "my-instance", "my-table" do |cfm|
      #     cfm.add "cf1", gc_rule: Google::Cloud::Bigtable::GcRule.max_versions(5)
      #     cfm.add "cf2", gc_rule: Google::Cloud::Bigtable::GcRule.max_age(600)
      #
      #     gc_rule = Google::Cloud::Bigtable::GcRule.union(
      #       Google::Cloud::Bigtable::GcRule.max_age(1800),
      #       Google::Cloud::Bigtable::GcRule.max_versions(3)
      #     )
      #     cfm.add "cf3", gc_rule: gc_rule
      #   end
      #
      #   puts table.column_families["cf1"].gc_rule.max_versions
      #   puts table.column_families["cf2"].gc_rule.max_age
      #   puts table.column_families["cf3"].gc_rule.union
      #
      class GcRule
        # @private
        # Creates a new GC Rule instance.
        #
        # @param grpc [Google::Cloud::Bigtable::Admin::V2::GcRule | nil]
        #
        def initialize grpc = nil
          @grpc = grpc || Google::Cloud::Bigtable::Admin::V2::GcRule.new
        end

        ##
        # Sets a garbage-collection rule that explicitly states the maximum
        # number of cells to keep for all columns in a column family.
        #
        # @param versions [Integer]
        #
        def max_versions= versions
          @grpc.max_num_versions = versions
        end

        ##
        # Gets the garbage-collection rule that explicitly states the maximum
        # number of cells to keep for all columns in a column family.
        #
        # @return [Integer, nil]
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.create_table "my-instance", "my-table" do |cfm|
        #     cfm.add "cf1", gc_rule: Google::Cloud::Bigtable::GcRule.max_versions(5)
        #   end
        #
        #   puts table.column_families["cf1"].gc_rule.max_versions
        #
        def max_versions
          @grpc.max_num_versions
        end

        ##
        # Sets a garbage-collection rule based on the timestamp for each cell.
        # With this type of garbage-collection rule, you set the time to live
        # (TTL) for data. Cloud Bigtable looks at each column family during
        # garbage collection and removes any cells that have expired.
        #
        # @param age [Numeric] Max age in seconds. Values must be at least one
        #   millisecond, and will be truncated to microsecond granularity.
        #
        def max_age= age
          @grpc.max_age = Convert.number_to_duration age
        end

        ##
        # Gets the garbage-collection rule based on the timestamp for each cell.
        # With this type of garbage-collection rule, you set the time to live
        # (TTL) for data. Cloud Bigtable looks at each column family during
        # garbage collection and removes any cells that have expired.
        #
        # @return [Numeric, nil] Max age in seconds.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.create_table "my-instance", "my-table" do |cfm|
        #     cfm.add "cf1", gc_rule: Google::Cloud::Bigtable::GcRule.max_age(600)
        #   end
        #
        #   puts table.column_families["cf1"].gc_rule.max_age
        #
        def max_age
          Convert.duration_to_number @grpc.max_age
        end

        ##
        # Sets the intersection rules collection for this GcRule.
        #
        # @param rules [Array<Google::Cloud::Bigtable::GcRule>]
        #   List of GcRule with nested rules.
        #
        def intersection= rules
          @grpc.intersection = Google::Cloud::Bigtable::Admin::V2::GcRule::Intersection.new rules: rules.map(&:to_grpc)
        end

        ##
        #
        # Gets the intersection rules collection for this GcRule.
        #
        # @return [Array<Google::Cloud::Bigtable::GcRule>, nil]
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.create_table "my-instance", "my-table" do |cfm|
        #     gc_rule = Google::Cloud::Bigtable::GcRule.intersection(
        #       Google::Cloud::Bigtable::GcRule.max_age(1800),
        #       Google::Cloud::Bigtable::GcRule.max_versions(3)
        #     )
        #     cfm.add "cf1", gc_rule: gc_rule
        #   end
        #
        #   puts table.column_families["cf1"].gc_rule.intersection
        #
        def intersection
          return nil unless @grpc.intersection
          @grpc.intersection.rules.map do |gc_rule_grpc|
            self.class.from_grpc gc_rule_grpc
          end
        end

        ##
        # Sets the union rules collection for this GcRule. A union
        # garbage-collection policy will remove all data matching *any* of its
        # set of given rules.
        #
        # @param rules [Array<Google::Cloud::Bigtable::GcRule>]
        #   List of GcRule with nested rules.
        #
        def union= rules
          @grpc.union = Google::Cloud::Bigtable::Admin::V2::GcRule::Union.new rules: rules.map(&:to_grpc)
        end

        ##
        # Gets the union rules collection for this GcRule. A union
        # garbage-collection policy will remove all data matching *any* of its
        # set of given rules.
        #
        # @return [Array<Google::Cloud::Bigtable::GcRule>, nil]
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.create_table "my-instance", "my-table" do |cfm|
        #     gc_rule = Google::Cloud::Bigtable::GcRule.union(
        #       Google::Cloud::Bigtable::GcRule.max_age(1800),
        #       Google::Cloud::Bigtable::GcRule.max_versions(3)
        #     )
        #     cfm.add "cf1", gc_rule: gc_rule
        #   end
        #
        #   puts table.column_families["cf1"].gc_rule.union
        #
        def union
          return nil unless @grpc.union
          @grpc.union.rules.map do |gc_rule_grpc|
            self.class.from_grpc gc_rule_grpc
          end
        end

        ##
        # Creates a GcRule instance with max number of versions.
        #
        # @param versions [Integer] Max number of versions
        # @return [Google::Cloud::Bigtable::GcRule]
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.create_table "my-instance", "my-table" do |cfm|
        #     cfm.add "cf1", gc_rule: Google::Cloud::Bigtable::GcRule.max_versions(5)
        #   end
        #
        def self.max_versions versions
          new.tap do |gc_rule|
            gc_rule.max_versions = versions
          end
        end

        ##
        # Creates a GcRule instance with max age.
        #
        # @param age [Integer] Max age in seconds.
        # @return [Google::Cloud::Bigtable::GcRule]
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.create_table "my-instance", "my-table" do |cfm|
        #     cfm.add "cf1", gc_rule: Google::Cloud::Bigtable::GcRule.max_age(600)
        #   end
        #
        def self.max_age age
          new.tap do |gc_rule|
            gc_rule.max_age = age
          end
        end

        ##
        # Creates a union GcRule instance.
        #
        # @param rules [Google::Cloud::Bigtable::GcRule, Array<Google::Cloud::Bigtable::GcRule>]
        #   List of GcRule with nested rules.
        # @return [Google::Cloud::Bigtable::GcRule]
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.create_table "my-instance", "my-table" do |cfm|
        #     gc_rule = Google::Cloud::Bigtable::GcRule.union(
        #       Google::Cloud::Bigtable::GcRule.max_age(1800),
        #       Google::Cloud::Bigtable::GcRule.max_versions(3)
        #     )
        #     cfm.add "cf1", gc_rule: gc_rule
        #   end
        #
        def self.union *rules
          new.tap do |gc_rule|
            gc_rule.union = rules
          end
        end

        ##
        # Creates a intersection GCRule instance.
        #
        # @param rules [Google::Cloud::Bigtable::GcRule, Array<Google::Cloud::Bigtable::GcRule>]
        #   List of GcRule with nested rules.
        # @return [Google::Cloud::Bigtable::GcRule]
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.create_table "my-instance", "my-table" do |cfm|
        #     gc_rule = Google::Cloud::Bigtable::GcRule.intersection(
        #       Google::Cloud::Bigtable::GcRule.max_age(1800),
        #       Google::Cloud::Bigtable::GcRule.max_versions(3)
        #     )
        #     cfm.add "cf1", gc_rule: gc_rule
        #   end
        #
        def self.intersection *rules
          new.tap do |gc_rule|
            gc_rule.intersection = rules
          end
        end

        # @private
        # Get gRPC instance of GC Rule
        # @return [Google::Cloud::Bigtable::Admin::V2::GcRule]
        def to_grpc
          @grpc
        end

        # @private
        #
        # Creates a new GcRule instance from a
        # Google::Cloud::Bigtable::Admin::V2::GcRule.
        # @param grpc [Google::Cloud::Bigtable::Admin::V2::GcRule]
        # @return [Google::Cloud::Bigtable::GcRule]
        def self.from_grpc grpc
          new grpc
        end
      end
    end
  end
end
