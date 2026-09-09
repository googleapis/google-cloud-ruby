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


module Google
  module Cloud
    module Bigtable
      ##
      # # Status
      #
      # Represents a logical error model from the Bigtable service, containing an
      # error code, an error message, and optional error details.
      #
      # @attr [Integer] code The status code, which should be an enum value of
      #   [google.rpc.Code](https://github.com/googleapis/googleapis/blob/master/google/rpc/code.proto).
      # @attr [String] description The human-readable description for the status code, which should be an enum value of
      #   [google.rpc.Code](https://github.com/googleapis/googleapis/blob/master/google/rpc/code.proto). For example,
      #   `INVALID_ARGUMENT`.
      # @attr [String] message A developer-facing error message, which should be in English.
      # @attr [Array<String>] details A list of messages that carry the error details.
      #
      # @example
      #   require "google/cloud/bigtable"
      #
      #   bigtable = Google::Cloud::Bigtable.new
      #
      #   table = bigtable.table "my-instance", "my-table"
      #
      #   entries = []
      #   entries << table.new_mutation_entry("row-1").set_cell("cf1", "field1", "XYZ")
      #   entries << table.new_mutation_entry("row-2").set_cell("cf1", "field1", "ABC")
      #   responses = table.mutate_rows entries
      #
      #   responses.each do |response|
      #     puts response.status.description
      #   end
      #
      class Status
        attr_reader :code
        attr_reader :description
        attr_reader :message
        attr_reader :details

        ##
        # @private Creates a Status object.
        def initialize code, description, message, details
          @code = code
          @description = description
          @message = message
          @details = details
        end

        ##
        # @private New Status from a Google::Rpc::Status object.
        def self.from_grpc grpc
          new grpc.code, description_for(grpc.code), grpc.message, grpc.details
        end

        # @private Get a descriptive symbol for a google.rpc.Code integer
        def self.description_for code
          ["OK", "CANCELLED", "UNKNOWN", "INVALID_ARGUMENT", "DEADLINE_EXCEEDED", "NOT_FOUND", "ALREADY_EXISTS",
           "PERMISSION_DENIED", "RESOURCE_EXHAUSTED", "FAILED_PRECONDITION", "ABORTED", "OUT_OF_RANGE", "UNIMPLEMENTED",
           "INTERNAL", "UNAVAILABLE", "DATA_LOSS", "UNAUTHENTICATED"][code]
        end
      end
    end
  end
end
