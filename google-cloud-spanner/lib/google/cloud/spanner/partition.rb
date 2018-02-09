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


require "json"
require "base64"

module Google
  module Cloud
    module Spanner
      ##
      # # Partition
      #
      # Defines the segments of data to be read in a batch read/query context. A
      # Partition instance can be serialized and used across several different
      # machines or processes.
      #
      # See {BatchSnapshot#partition_read}, {BatchSnapshot#partition_query}, and
      # {BatchSnapshot#execute_partition}.
      #
      # @example
      #   require "google/cloud/spanner"
      #
      #   spanner = Google::Cloud::Spanner.new
      #
      #   batch_client = spanner.batch_client "my-instance", "my-database"
      #
      #   batch_snapshot = batch_client.batch_snapshot
      #   partitions = batch_snapshot.partition_read "users", [:id, :name]
      #
      #   partition = partitions.first
      #
      #   results = batch_snapshot.execute_partition partition
      #
      class Partition
        # @ private
        attr_reader :execute, :read

        ##
        # @private Creates a Partition object.
        def initialize; end

        ##
        # Whether the partition was created for an execute/query operation.
        # @return [Boolean]
        def execute?
          !@execute.nil?
        end

        ##
        # Whether the partition was created for a read operation.
        # @return [Boolean]
        def read?
          !@read.nil?
        end

        ##
        # @private
        # Whether the partition does not have an execute or read operation.
        # @return [Boolean]
        def empty?
          @execute.nil? && @read.nil?
        end

        ##
        # @private
        # Converts the the batch partition object to a Hash ready for
        # serialization.
        #
        # @return [Hash] A hash containing a representation of the batch
        #   partition object.
        #
        def to_h
          {}.tap do |h|
            h[:execute] = Base64.strict_encode64(@execute.to_proto) if @execute
            h[:read] = Base64.strict_encode64(@read.to_proto) if @read
          end
        end

        ##
        # Serializes the batch partition object so it can be recreated on
        # another process. See {Partition.load} and
        # {BatchClient#load_partition}.
        #
        # @return [String] The serialized representation of the batch partition.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   batch_client = spanner.batch_client "my-instance", "my-database"
        #
        #   batch_snapshot = batch_client.batch_snapshot
        #
        #   partitions = batch_snapshot.partition_read "users", [:id, :name]
        #
        #   partition = partitions.first
        #
        #   serialized_snapshot = batch_snapshot.dump
        #   serialized_partition = partition.dump
        #
        #   # In a separate process
        #   new_batch_snapshot = batch_client.load_batch_snapshot \
        #     serialized_snapshot
        #
        #   new_partition = batch_client.load_partition \
        #     serialized_partition
        #
        #   results = new_batch_snapshot.execute_partition \
        #     new_partition
        #
        def dump
          JSON.dump to_h
        end
        alias serialize dump

        ##
        # Returns a {Partition} from a serialized representation.
        #
        # @param [String] data The serialized representation of an existing
        #   batch partition. See {Partition#dump}.
        #
        # @return [Google::Cloud::Spanner::Partition]
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   batch_client = spanner.batch_client "my-instance", "my-database"
        #
        #   batch_snapshot = batch_client.batch_snapshot
        #
        #   partitions = batch_snapshot.partition_read "users", [:id, :name]
        #
        #   partition = partitions.first
        #
        #   serialized_snapshot = batch_snapshot.dump
        #   serialized_partition = partition.dump
        #
        #   # In a separate process
        #   new_batch_snapshot = batch_client.load_batch_snapshot \
        #     serialized_snapshot
        #
        #   new_partition = Google::Cloud::Spanner::Partition.load \
        #     serialized_partition
        #
        #   results = new_batch_snapshot.execute_partition \
        #     new_partition
        #
        def self.load data
          data = JSON.parse data, symbolize_names: true unless data.is_a? Hash

          # TODO: raise if hash[:execute].nil? && hash[:read].nil?
          new.tap do |p|
            if data[:execute]
              execute_grpc = Google::Spanner::V1::ExecuteSqlRequest.decode \
                Base64.decode64(data[:execute])
              p.instance_variable_set :@execute, execute_grpc
            end
            if data[:read]
              read_grpc = Google::Spanner::V1::ReadRequest.decode \
                Base64.decode64(data[:read])
              p.instance_variable_set :@read, read_grpc
            end
          end
        end

        # @private
        def inspect
          status = "empty"
          status = "execute" if execute?
          status = "read" if read?
          "#<#{self.class.name} #{status}>"
        end

        ##
        # @private New Partition from a Google::Spanner::V1::ExecuteSqlRequest
        # object.
        def self.from_execute_grpc grpc
          new.tap do |p|
            p.instance_variable_set :@execute, grpc
          end
        end

        ##
        # @private New Partition from a Google::Spanner::V1::ReadRequest object.
        def self.from_read_grpc grpc
          new.tap do |p|
            p.instance_variable_set :@read, grpc
          end
        end
      end
    end
  end
end
