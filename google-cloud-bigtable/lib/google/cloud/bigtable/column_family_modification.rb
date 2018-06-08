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
      # ColumnFamily modification
      class ColumnFamilyModification
        # @private
        # Create instance of ColumnFamilyModification
        #
        # @param type [Symbol] Modification type.
        #   Valid values are `:create`, `:update`, `:drop`.
        # @param name [String] Name of the column family
        # @param gc_rule [Google::Cloud::Bigtable::GcRule]
        #   GC Rule to be applied to column family.
        def initialize type, name, gc_rule: nil
          @type = type
          @name = name
          @gc_rule = gc_rule
        end

        # Create modification instance for create column family.
        #
        # @param name [String] Name of the column family
        # @param gc_rule [Google::Cloud::Bigtable::GcRule]
        #   GC Rule to be applied to column family.
        # @return [Google::Cloud::Bigtable::ColumnFamilyModification]

        def self.create name, gc_rule = nil
          new(:create, name, gc_rule: gc_rule)
        end

        # Create modification instance for update column family.
        #
        # @param name [String] Name of the column family
        # @param gc_rule [Google::Cloud::Bigtable::GcRule]
        #   GC Rule to be applied to column family
        # @return [Google::Cloud::Bigtable::ColumnFamilyModification]

        def self.update name, gc_rule = nil
          new(:update, name, gc_rule: gc_rule)
        end

        # Create modification instance to drop column family.
        #
        # @param name [String] Name of the column family
        # @return [Google::Cloud::Bigtable::ColumnFamilyModification]

        def self.drop name
          new(:drop, name)
        end

        # @private
        #
        # Create gRPC object for column family modification.
        #
        # @return [Google::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification]

        def to_grpc
          attrs = { id: @name }

          if @type == :drop
            attrs[:drop] = true
          else
            gc_rule = @gc_rule.grpc if @gc_rule
            attrs[@type] = Google::Bigtable::Admin::V2::ColumnFamily.new(
              gc_rule: gc_rule
            )
          end

          Google::Bigtable::Admin::V2::ModifyColumnFamiliesRequest:: \
              Modification.new(attrs)
        end
      end
    end
  end
end
