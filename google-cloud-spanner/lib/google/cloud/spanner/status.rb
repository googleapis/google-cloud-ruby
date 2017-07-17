# Copyright 2016 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require "google/cloud/spanner/errors"

module Google
  module Cloud
    module Spanner
      ##
      # # Status
      #
      # Represents a logical error model from the Spanner service, containing an
      # error code, an error message, and optional error details.
      #
      # @attr [Symbol] code The status code, which should be an enum value of
      #   [google.rpc.Code](https://github.com/googleapis/googleapis/blob/master/google/rpc/code.proto).
      #   For example, `:INVALID_ARGUMENT`.
      # @attr [String] message A developer-facing error message, which should be
      #   in English.
      # @attr [Array, nil] details A list of messages that carry the error
      #   details.
      #
      # @example
      #   require "google/cloud/spanner"
      #
      #   spanner = Google::Cloud::Spanner.new
      #
      #   job = spanner.create_database "my-instance",
      #                                 "my-new-database"
      #
      #   job.error? # true
      #
      #   status = job.error
      #
      class Status
        attr_reader :code, :message, :details

        ##
        # @private Creates a Status object.
        def initialize code, message, details
          @code = code
          @message = message
          @details = details
        end

        ##
        # @private New Status from a Google::Rpc::Status object.
        def self.from_grpc grpc
          code_sym = grpc_code_description_for grpc.code
          new code_sym, grpc.message, grpc.details
        end

        # @private Get a descriptive symbol for a gRPC error integer
        def self.grpc_code_description_for grpc_error_code
          [:OK, :CANCELLED, :UNKNOWN, :INVALID_ARGUMENT, :DEADLINE_EXCEEDED,
           :NOT_FOUND, :ALREADY_EXISTS, :PERMISSION_DENIED, :RESOURCE_EXHAUSTED,
           :FAILED_PRECONDITION, :ABORTED, :OUT_OF_RANGE, :UNIMPLEMENTED,
           :INTERNAL, :UNAVAILABLE, :DATA_LOSS, :UNAUTHENTICATED
          ][grpc_error_code]
        end
      end
    end
  end
end
