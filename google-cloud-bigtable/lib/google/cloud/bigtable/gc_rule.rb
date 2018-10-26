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
      # # GcRule
      #
      # Rule for determining which cells to delete during garbage collection.
      # Garbage collection (GC) executes opportunistically in the background,
      # so it's possible for reads to return a cell even if it matches the active
      # GC expression for its family.
      #
      # NOTE: GC Rule can hold only one type at a time.
      # GC Rule types:
      #   * `max_num_versions` - Delete all cells in a column except the most recent N
      #   * `max_age` - Delete cells in a column older than the given age.
      #   * `union` - Delete cells that would be deleted by every nested rule.
      #       It can have mutiple chainable GC Rules.
      #   * `intersection` - Delete cells that would be deleted by any nested rule.
      #       It can have multiple chainable GC Rules.
      #
      # @example Create GC rule instance with max version.
      #
      #  gc_rule = Google::Cloud::Bigtable::GcRule.max_versions(3)
      #
      #  # Change max verions
      #  gc_rule.max_versions = 5
      #
      # @example Create GC rule instance with max age.
      #
      #  gc_rule = Google::Cloud::Bigtable::GcRule.max_age(3)
      #
      #  # Change max age
      #  gc_rule.max_age = 600 # 10 minutes
      #
      # @example Create GC rule instance with union.
      #
      #  max_age_gc_rule = Google::Cloud::Bigtable::GcRule.max_age(180)
      #  union_gc_rule = Google::Cloud::Bigtable::GcRule.union(max_age_gc_rule)
      #
      #  # Change union GC rule
      #  gc_rule.union = Google::Cloud::Bigtable::GcRule.max_age(600)
      #
      # @example Create GC rule instance with intersection.
      #
      #  max_versions_gc_rule = Google::Cloud::Bigtable::GcRule.max_versions(3)
      #  gc_rule = Google::Cloud::Bigtable::GcRule.intersection(max_versions_gc_rule)
      #
      #  # Change intersection GC rule
      #  gc_rule.intersection = Google::Cloud::Bigtable::GcRule.max_age(600)
      #
      class GcRule
        # @private
        # Creates a new GC Rule instance.
        #
        # @param grpc [Google::Bigtable::Admin::V2::GcRule | nil]
        #
        def initialize grpc = nil
          @grpc = grpc || Google::Bigtable::Admin::V2::GcRule.new
        end

        # Delete all cells in a column except the most recent N.
        #
        # @param versions [Integer]
        #
        def max_versions= versions
          @grpc.max_num_versions = versions
        end

        # Get max versions.
        #
        # @return [Integer, nil]
        #
        def max_versions
          @grpc.max_num_versions
        end

        # Delete cells in a column older than the given age.
        # Values must be at least one millisecond, and will be truncated to
        # microsecond granularity.
        #
        # @param age [Integer] age in seconds
        #
        def max_age= age
          @grpc.max_age = Convert.number_to_duration(age)
        end

        # Max age in seconds, if max age is set.
        #
        # @return [Integer, nil] Max age in seconds.
        #
        def max_age
          @grpc.max_age.seconds if @grpc.max_age
        end

        # Delete cells that would be deleted by every nested rule.
        #
        # @param rules [Array<Google::Cloud::Bigtable::GcRule>]
        #   List of GcRule with nested rules.
        #
        def intersection= rules
          @grpc.intersection = \
            Google::Bigtable::Admin::V2::GcRule::Intersection.new(
              rules: rules.map(&:to_grpc)
            )
        end

        # Get intersection GC rules
        #
        # @return [Google::Bigtable::Admin::V2::GcRule::Intersection, nil]
        #
        def intersection
          @grpc.intersection
        end

        # Delete cells that would be deleted by any nested rule.
        #
        # @param rules [Array<Google::Cloud::Bigtable::GcRule>]
        #   List of GcRule with nested rules.
        #
        def union= rules
          @grpc.union = Google::Bigtable::Admin::V2::GcRule::Union.new(
            rules: rules.map(&:to_grpc)
          )
        end

        # Get union GC rules
        #
        # @return [Google::Bigtable::Admin::V2::GcRule::Union, nil]
        #
        def union
          @grpc.union
        end

        # Create GcRule instance with max number of versions.
        #
        # @param versions [Integer] Max number of versions
        # @return [Google::Bigtable::Admin::V2::GcRule]
        #
        def self.max_versions versions
          new.tap do |gc_rule|
            gc_rule.max_versions = versions
          end
        end

        # Create GcRule instance with max age.
        #
        # @param age [Integer] Max age in seconds.
        # @return [Google::Bigtable::Admin::V2::GcRule]
        #
        def self.max_age age
          new.tap do |gc_rule|
            gc_rule.max_age = age
          end
        end

        # Create union GcRule instance.
        #
        # @param rules [Google::Cloud::Bigtable::GcRule, Array<Google::Cloud::Bigtable::GcRule>]
        #   List of GcRule with nested rules.
        # @return [Google::Bigtable::Admin::V2::GcRule]
        #
        def self.union *rules
          new.tap do |gc_rule|
            gc_rule.union = rules
          end
        end

        # Create intersection GCRule instance.
        #
        # @param rules [Google::Cloud::Bigtable::GcRule, Array<Google::Cloud::Bigtable::GcRule>]
        #   List of GcRule with nested rules.
        # @return [Google::Bigtable::Admin::V2::GcRule]
        #
        def self.intersection *rules
          new.tap do |gc_rule|
            gc_rule.intersection = rules
          end
        end

        # @private
        # Get gRPC instance of GC Rule
        # @return [Google::Bigtable::Admin::V2::GcRule]
        def to_grpc
          @grpc
        end

        # @private
        #
        # Creates a new GcRule instance from a
        # Google::Bigtable::Admin::V2::GcRule.
        # @param grpc [Google::Bigtable::Admin::V2::GcRule]
        # @return [Google::Cloud::Bigtable::GcRule]
        def self.from_grpc grpc
          new(grpc)
        end
      end
    end
  end
end
