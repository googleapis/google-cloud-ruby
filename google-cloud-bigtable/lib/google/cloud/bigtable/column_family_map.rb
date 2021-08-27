# frozen_string_literal: true

# Copyright 2019 Google LLC
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


require "google/cloud/bigtable/column_family"

module Google
  module Cloud
    module Bigtable
      ##
      # Represents a table's column families.
      #
      # See {Project#create_table}, {Instance#create_table} and
      # {Table#column_families}.
      #
      # @example
      #   require "google/cloud/bigtable"
      #
      #   bigtable = Google::Cloud::Bigtable.new
      #
      #   column_families = Google::Cloud::Bigtable::ColumnFamilyMap.new
      #
      #   column_families.add "cf1", gc_rule: Google::Cloud::Bigtable::GcRule.max_age(600)
      #   column_families.add "cf2", gc_rule: Google::Cloud::Bigtable::GcRule.max_versions(5)
      #
      # @example Create a table with a block yielding a ColumnFamilyMap.
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
      #   puts table.column_families
      #
      # @example Update column families with a block yielding a ColumnFamilyMap.
      #   require "google/cloud/bigtable"
      #
      #   bigtable = Google::Cloud::Bigtable.new
      #
      #   table = bigtable.table "my-instance", "my-table", perform_lookup: true
      #
      #   table.column_families do |cfm|
      #     cfm.add "cf4", gc_rule: Google::Cloud::Bigtable::GcRule.max_age(600)
      #     cfm.add "cf5", gc_rule: Google::Cloud::Bigtable::GcRule.max_versions(5)
      #
      #     rule_1 = Google::Cloud::Bigtable::GcRule.max_versions 3
      #     rule_2 = Google::Cloud::Bigtable::GcRule.max_age 600
      #     rule_union = Google::Cloud::Bigtable::GcRule.union rule_1, rule_2
      #     cfm.update "cf2", gc_rule: rule_union
      #
      #     cfm.delete "cf3"
      #   end
      #
      #   puts table.column_families["cf3"] #=> nil
      #
      class ColumnFamilyMap
        include Enumerable

        ##
        # Creates a new ColumnFamilyMap object.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   column_families = Google::Cloud::Bigtable::ColumnFamilyMap.new
        #
        #   column_families.add "cf1", gc_rule: Google::Cloud::Bigtable::GcRule.max_age(600)
        #   column_families.add "cf2", gc_rule: Google::Cloud::Bigtable::GcRule.max_versions(5)
        #
        # @example Create new column families using block syntax:
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   column_families = Google::Cloud::Bigtable::ColumnFamilyMap.new do |cfm|
        #     cfm.add "cf1", gc_rule: Google::Cloud::Bigtable::GcRule.max_age(600)
        #     cfm.add "cf2", gc_rule: Google::Cloud::Bigtable::GcRule.max_versions(5)
        #   end
        #
        def initialize
          @column_families = empty_map

          yield self if block_given?
        end

        ##
        # Calls the block once for each column family in the map, passing
        # the name and column family pair as parameters.
        #
        # If no block is given, an enumerator is returned instead.
        #
        # @yield [name, column_family] The name and column family pair.
        # @yieldparam [String] name the column family name.
        # @yieldparam [ColumnFamily] column_family the column family object.
        #
        # @return [Enumerator,nil] An enumerator is returned if no block is given, otherwise `nil`.
        #
        def each
          return enum_for :each unless block_given?

          @column_families.each do |name, column_family_grpc|
            column_family = ColumnFamily.from_grpc column_family_grpc, name
            yield name, column_family
          end
        end

        ##
        # Retrieves the ColumnFamily object corresponding to the `name`. If not
        # found, returns `nil`.
        #
        # @return [ColumnFamily]
        #
        def [] name
          return nil unless name? name

          ColumnFamily.from_grpc @column_families[name], name
        end

        ##
        # Returns true if the given name is present in the map.
        #
        # @return [Boolean]
        #
        def name? name
          @column_families.has_key? name
        end
        alias key? name?

        ##
        # Returns a new array populated with the names from the map.
        #
        # @return [Array<String>]
        #
        def names
          @column_families.keys
        end
        alias keys names

        ##
        # Returns the number of name and column family pairs in the map.
        #
        # @return [Integer]
        #
        def length
          @column_families.length
        end
        alias size length

        ##
        # Returns true if the map contains no name and column family pairs.
        #
        # @return [Boolean]
        #
        def empty?
          length.zero?
        end

        ##
        # Adds a new column family to the table.
        #
        # @overload add(name, gc_rule: nil)
        #   @param name [String] Column family name.
        #   @param gc_rule [Google::Cloud::Bigtable::GcRule] The garbage
        #     collection rule to be used for the column family. Optional. The
        #     service default value will be used when not specified.
        #
        # @raise [ArgumentError] if the column family name already exists.
        # @raise [FrozenError] if the column family map is frozen.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.table "my-instance", "my-table", perform_lookup: true
        #
        #   table.column_families do |column_families|
        #     column_families.add "cf4", gc_rule: Google::Cloud::Bigtable::GcRule.max_age(600)
        #     column_families.add "cf5", gc_rule: Google::Cloud::Bigtable::GcRule.max_versions(5)
        #   end
        #
        def add name, positional_gc_rule = nil, gc_rule: nil
          raise ArgumentError, "column family #{name.inspect} already exists" if @column_families.has_key? name

          gc_rule ||= positional_gc_rule
          if positional_gc_rule
            warn "The positional gc_rule argument is deprecated. Use the named gc_rule argument instead."
          end

          column_family = Google::Cloud::Bigtable::Admin::V2::ColumnFamily.new
          column_family.gc_rule = gc_rule.to_grpc if gc_rule
          @column_families[name] = column_family

          nil
        end
        alias create add

        ##
        # Updates an existing column family in the table.
        #
        # @see https://cloud.google.com/bigtable/docs/garbage-collection Garbage collection
        #
        # @param name [String] Column family name.
        # @param gc_rule [Google::Cloud::Bigtable::GcRule] The new garbage
        #   collection rule to be used for the column family. Optional. The
        #   service default value will be used when not specified.
        #
        # @raise [ArgumentError] if the column family name does not exist.
        # @raise [FrozenError] if the column family map is frozen.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.table "my-instance", "my-table", perform_lookup: true
        #
        #   table.column_families do |column_families|
        #     rule_1 = Google::Cloud::Bigtable::GcRule.max_versions 3
        #     rule_2 = Google::Cloud::Bigtable::GcRule.max_age 600
        #     rule_union = Google::Cloud::Bigtable::GcRule.union rule_1, rule_2
        #
        #     column_families.update "cf2", gc_rule: rule_union
        #   end
        #
        def update name, gc_rule: nil
          raise ArgumentError, "column family #{name.inspect} does not exist" unless @column_families.has_key? name

          column_family = Google::Cloud::Bigtable::Admin::V2::ColumnFamily.new
          column_family.gc_rule = gc_rule.to_grpc if gc_rule
          @column_families[name] = column_family

          nil
        end

        ##
        # Deletes the named column family from the table.
        #
        # @param name [String] Column family name.
        #
        # @raise [ArgumentError] if the column family name does not exist.
        # @raise [FrozenError] if the column family map is frozen.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   table = bigtable.table "my-instance", "my-table", perform_lookup: true
        #
        #   table.column_families do |column_families|
        #     column_families.delete "cf3"
        #   end
        #
        def delete name
          raise ArgumentError, "column family #{name.inspect} does not exist" unless @column_families.has_key? name

          @column_families.delete name

          nil
        end
        alias drop delete

        ##
        # @private
        # We don't need to document this method.
        #
        def freeze
          @column_families.freeze
          super
        end

        ##
        # @private
        #
        # Build column family modifications for the map.
        #
        # @param comparison_map [Google::Protobuf::Map] The map to compare the
        #   current map against for building the modification entries.
        # @return [Array<Google::Cloud::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification>]
        #
        def modifications comparison_map = nil
          comparison_map ||= empty_map

          created_modifications(comparison_map) +
            updated_modifications(comparison_map) +
            dropped_modifications(comparison_map)
        end

        ##
        # @private
        #
        # Return the Google::Protobuf::Map for the ColumnFamilyMap.
        #
        # @return [Google::Protobuf::Map]
        #
        def to_grpc
          # Always return a dup in case it was frozen.
          @column_families.dup
        end

        ##
        # @private
        #
        # Return the Hash for the ColumnFamilyMap.
        #
        # @return [Hash]
        #
        def to_grpc_hash
          Hash[to_grpc.to_a]
        end

        ##
        # @private
        #
        # Create new ColumnFamilyMap from Google::Protobuf::Map.
        #
        # @param grpc_map [Google::Protobuf::Map]
        # @return [ColumnFamilyMap]
        #
        def self.from_grpc grpc_map
          new.tap do |cfm|
            # Always dup so we don't modify the original map object.
            cfm.instance_variable_set :@column_families, grpc_map.dup
          end
        end

        protected

        ##
        # Create an empty Google::Protobuf::Map suitable for column_families.
        def empty_map
          Google::Cloud::Bigtable::Admin::V2::Table.new.column_families
        end

        ##
        # @private
        #
        # Build column family modifications for created column families.
        #
        # @param comparison_map [Google::Protobuf::Map] The map to compare the
        #   current map against for building the modification entries.
        # @return [Array<Google::Cloud::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification>]
        #
        def created_modifications comparison_map
          added_keys = @column_families.keys - comparison_map.keys

          added_keys.map do |name|
            Google::Cloud::Bigtable::Admin::V2::ModifyColumnFamiliesRequest:: \
            Modification.new(
              id:     name,
              create: @column_families[name]
            )
          end
        end

        ##
        # @private
        #
        # Build column family modifications for updated column families.
        #
        # @param comparison_map [Google::Protobuf::Map] The map to compare the
        #   current map against for building the modification entries.
        # @return [Array<Google::Cloud::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification>]
        #
        def updated_modifications comparison_map
          possibly_updated_keys = @column_families.keys & comparison_map.keys
          updated_keys = possibly_updated_keys.reject do |name|
            @column_families[name] == comparison_map[name]
          end

          updated_keys.map do |name|
            Google::Cloud::Bigtable::Admin::V2::ModifyColumnFamiliesRequest:: \
            Modification.new(
              id:     name,
              update: @column_families[name]
            )
          end
        end

        ##
        # @private
        #
        # Build column family modifications for dropped column families.
        #
        # @param comparison_map [Google::Protobuf::Map] The map to compare the
        #   current map against for building the modification entries.
        # @return [Array<Google::Cloud::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification>]
        #
        def dropped_modifications comparison_map
          dropped_keys = comparison_map.keys - @column_families.keys

          dropped_keys.map do |name|
            Google::Cloud::Bigtable::Admin::V2::ModifyColumnFamiliesRequest:: \
            Modification.new(
              id:   name,
              drop: true
            )
          end
        end
      end
    end
  end
end
