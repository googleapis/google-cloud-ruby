# Copyright 2016 Google LLC
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


module Google
  module Cloud
    module Logging
      class Entry
        ##
        # # Operation
        #
        # Additional information about a potentially long-running operation with
        # which a log entry is associated.
        #
        # See also {Google::Cloud::Logging::Entry#operation}.
        #
        class Operation
          ##
          # @private Create an empty Operation object.
          def initialize
          end

          ##
          # An arbitrary operation identifier. Log entries with the same
          # identifier are assumed to be part of the same operation.
          attr_accessor :id

          ##
          # An arbitrary producer identifier. The combination of `id` and
          # `producer` must be globally unique. Examples for `producer`:
          # `"MyDivision.MyBigCompany.com"`,
          # `"github.com/MyProject/MyApplication"`.
          attr_accessor :producer

          ##
          # Set this to `true` if this is the first log entry in the operation.
          attr_accessor :first

          ##
          # Set this to `true` if this is the last log entry in the operation.
          attr_accessor :last

          ##
          # @private Determines if the Operation has any data.
          def empty?
            id.nil? &&
              producer.nil? &&
              first.nil? &&
              last.nil?
          end

          ##
          # @private Exports the Operation to a
          # Google::Logging::V2::LogEntryOperation object.
          def to_grpc
            return nil if empty?
            Google::Logging::V2::LogEntryOperation.new(
              id:       id.to_s,
              producer: producer.to_s,
              first:    !(!first),
              last:     !(!last)
            )
          end

          ##
          # @private New Google::Cloud::Logging::Entry::Operation from a
          # Google::Logging::V2::LogEntryOperation object.
          def self.from_grpc grpc
            return new if grpc.nil?
            new.tap do |o|
              o.id       = grpc.id
              o.producer = grpc.producer
              o.first    = grpc.first
              o.last     = grpc.last
            end
          end
        end
      end
    end
  end
end
