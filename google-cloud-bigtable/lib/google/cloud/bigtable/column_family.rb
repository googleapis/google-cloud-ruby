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
      ##
      # # ColumnFamily
      #
      # A set of columns within a table that share a common configuration.
      #
      # @example
      #   require "google/cloud/bigtable"
      #
      #   bigtable = Google::Cloud::Bigtable.new
      #
      #   instance = bigtable.instance "my-instance"
      #   table = instance.table "my-table"
      #
      #   column_family = table.column_families["cf2"]
      #   puts column_family.gc_rule
      #
      class ColumnFamily
        ##
        # Name of the column family.
        # @return [String]
        attr_reader :name

        ##
        # The garbage collection rule to be used for the column family.
        # Optional. The service default value will be used when not specified.
        #
        # @see https://cloud.google.com/bigtable/docs/garbage-collection Garbage collection
        #
        # @return [Google::Cloud::Bigtable::GcRule, nil]
        #
        attr_accessor :gc_rule

        # @private
        def initialize name, gc_rule: nil
          @name = name
          @gc_rule = gc_rule
        end

        # @private
        #
        # Create a new ColumnFamily instance from a {Google::Cloud::Bigtable::Admin::V2::ColumnFamily}.
        #
        # @param grpc [Google::Cloud::Bigtable::Admin::V2::ColumnFamily]
        # @param name [String] Column family name
        # @return [Google::Cloud::Bigtable::ColumnFamily]
        #
        def self.from_grpc grpc, name
          new(name).tap do |cf|
            cf.gc_rule = GcRule.from_grpc grpc.gc_rule if grpc.gc_rule
          end
        end
      end
    end
  end
end
