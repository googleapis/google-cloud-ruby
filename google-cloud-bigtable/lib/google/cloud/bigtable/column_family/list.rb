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


require "delegate"

module Google
  module Cloud
    module Bigtable
      class ColumnFamily
        # ColumnFamily::List is a special case Array with additional
        # values.
        class List < DelegateClass(::Array)
          # @private
          # The gRPC Service object.
          attr_accessor :service

          # @private
          # Table id
          attr_accessor :table_id

          # @private
          # Instance id
          attr_accessor :instance_id

          # @private
          #
          # Create a new ColumnFamily::List with an array of
          # ColumnFamily instances.
          #
          # @param arr [Array<Google::Cloud::Bigtable::ColumnFamily>]
          #
          def initialize arr = []
            super(arr)
          end

          # Find column family by name
          # @param name [String] Column family name
          def find_by_name name
            find { |cf| cf.name == name }
          end

          # Create column family.
          #
          # @param name [String] Name of the column family
          # @param gc_rule [Google::Cloud::Bigtable::GcRule]
          #
          # @example
          #   require "google/cloud/bigtable"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #
          #   instance = bigtable.instance("my-instance")
          #   table = instance.table("my-table")
          #
          #   gc_rule = Google::Cloud::Bigtable::GcRule.max_versions(5)
          #   column_family = table.column_families.create("cf", gc_rule: gc_rule)
          #
          def create name, gc_rule: nil
            cf = ColumnFamily.new(service, name: name)
            cf.instance_id = instance_id
            cf.table_id = table_id
            cf.gc_rule = gc_rule if gc_rule
            cf.create
          end

          # @private
          #
          # New ColumnFamily::List from an array of
          # Google::Bigtable::Admin::V2::ColumnFamily object.
          #
          # @return [Google::Cloud::Bigtable::ColumnFamily::List]
          #
          def self.from_grpc \
              grpc,
              service,
              instance_id: nil,
              table_id: nil
            column_families = List.new(grpc.map do |name, cf|
              ColumnFamily.from_grpc(
                cf,
                service,
                name: name,
                instance_id: instance_id,
                table_id: table_id
              )
            end)
            column_families.service = service
            column_families.table_id = table_id
            column_families.instance_id = instance_id
            column_families
          end

          protected

          # Raise an error unless an active service is available.
          def ensure_service!
            raise "Must have active connection" unless service
          end
        end
      end
    end
  end
end
