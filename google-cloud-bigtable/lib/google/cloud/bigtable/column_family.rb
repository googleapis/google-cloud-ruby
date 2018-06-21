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


require "google/cloud/bigtable/gc_rule"

module Google
  module Cloud
    module Bigtable
      # # ColumnFamily
      #
      # A set of columns within a table which share a common configuration.
      #
      # @example
      #   require "google/cloud/bigtable"
      #
      #   bigtable = Google::Cloud::Bigtable.new
      #
      #   instance = bigtable.instance("my-instance")
      #   table = instance.table("my-table")
      #
      #   # Create
      #   gc_rule = Google::Cloud::Bigtable::GcRule.max_versions(5)
      #   column_family = table.column_families.create("cf1", gc_rule: gc_rule)
      #
      #   # Update
      #   column_family = table.column_families.find_by_name("cf2")
      #   column_family.gc_rule = Google::Cloud::Bigtable::GcRule.max_age(600)
      #   column_family.update
      #
      #   # Delete
      #   column_family = table.column_families.find_by_name("cf3")
      #   column_family.delete
      #
      class ColumnFamily
        # @private
        # The gRPC Service object.
        attr_accessor :service

        # @private
        attr_accessor :instance_id

        # @private
        attr_accessor :table_id

        # Column family name
        attr_reader :name

        # @private
        #
        # Create instance of ColumnFamily
        # @param service [Google::Cloud::Bigtable::Service]
        # @param grpc [Google::Bigtable::Admin::V2::ColumnFamily]
        # @param name [String] Name of the column family
        #
        def initialize service, grpc: nil, name: nil
          @service = service
          @grpc = grpc || Google::Bigtable::Admin::V2::ColumnFamily.new
          @name = name
        end

        # Set GC rule
        #
        # @param rule [Google::Cloud::Bigtable::GcRule]
        #
        def gc_rule= rule
          @grpc.gc_rule = rule.to_grpc
        end

        # Get GC rule
        #
        # @return [Google::Cloud::Bigtable::GcRule]
        #
        def gc_rule
          GcRule.from_grpc(@grpc.gc_rule) if @grpc.gc_rule
        end

        # Create column family.
        #
        # @return [Google::Cloud::Bigtable::ColumnFamily]
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #   table = instance.table("my-table")
        #
        #   gc_rule = Google::Cloud::Bigtable::GcRule.max_versions(3)
        #   cf = table.column_family("cf", gc_rule)
        #   cf.create
        #
        def create
          modify_column_family(self.class.create_modification(name, gc_rule))
        end

        # Update column family.
        #
        # @return [Google::Cloud::Bigtable::ColumnFamily]
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #   table = instance.table("my-table")
        #
        #   column_family = table.column_families.find {|cf| cf.name == "cf" }
        #   column_family.gc_rule = Google::Cloud::Bigtable::GcRule.max_age(600)
        #   column_family.save
        #
        def save
          modify_column_family(self.class.update_modification(name, gc_rule))
        end
        alias update save

        # Permanently delete column family from table.
        #
        # @return [Google::Cloud::Bigtable::Table]
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #   table = instance.table("my-table")
        #
        #   column_family = table.column_families.find {|cf| cf.name == "cf" }
        #   column_family.delete
        #
        def delete
          modify_column_family(self.class.drop_modification(name)).nil?
        end

        # Create gPRC instance to create column family modification
        #
        # @param name [String] Column family name
        # @param gc_rule [Google::Cloud::Bigtable::GcRule] GC Rule
        # @return [Google::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification]
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   Google::Cloud::Bigtable::ColumnFamilyModification.create(
        #     "cf1", Google::Cloud::Bigtable::GcRule.max_age(600))
        #   )
        #
        def self.create_modification name, gc_rule
          column_modification_grpc(:create, name, gc_rule)
        end

        def self.update_modification name, gc_rule
          column_modification_grpc(:update, name, gc_rule)
        end

        def self.drop_modification name
          column_modification_grpc(:drop, name)
        end

        # @private
        #
        # Creates a new ColumnFamily instance from a
        # Google::Bigtable::Admin::V2::ColumnFamily.
        #
        # @param grpc [Google::Bigtable::Admin::V2::ColumnFamily]
        # @param service [Google::Cloud::Bigtable::Service]
        # @param name [String] Column family name
        # @param instance_id [String]
        # @param table_id [String]
        # @return [Google::Cloud::Bigtable::ColumnFamily]
        #
        def self.from_grpc \
            grpc,
            service,
            name: nil,
            instance_id: nil,
            table_id: nil
          new(service, grpc: grpc, name: name).tap do |cf|
            cf.table_id = table_id
            cf.instance_id = instance_id
          end
        end

        # @private
        #
        # Create column family modification gRPC instance.
        #
        # @param type [Symbol] Type of modification.
        #   Valid values are `:create`, `:update`, `drop`
        # @param family_name [String] Column family name
        # @param gc_rule [Google::Cloud::Bigtable::GcRule]
        #   Required for only create and update modification type.
        # @return [Google::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification]
        #
        def self.column_modification_grpc type, family_name, gc_rule = nil
          attrs = { id: family_name }

          attrs[type] = if type == :drop
                          true
                        else
                          Google::Bigtable::Admin::V2::ColumnFamily.new(
                            gc_rule: gc_rule.to_grpc
                          )
                        end

          Google::Bigtable::Admin::V2::ModifyColumnFamiliesRequest:: \
              Modification.new(attrs)
        end

        protected

        # @private
        #
        # Create/Update/Delete column_family.
        #
        # @param modification [Google::Cloud::Bigtable::ColumnFamilyModification]
        # @return [Google::Cloud::Bigtable::ColumnFamily]
        #
        def modify_column_family modification
          ensure_service!
          table = Table.modify_column_families(
            service,
            instance_id,
            table_id,
            modification
          )
          table.column_families.find { |cf| cf.name == name }
        end

        # @private
        #
        # Raise an error unless an active connection to the service is
        # available.
        #
        def ensure_service!
          raise "Must have active connection to service" unless service
        end
      end
    end
  end
end
