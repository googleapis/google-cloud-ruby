# Copyright 2017 Google LLC
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
    module Debugger
      class Breakpoint
        ##
        # # StatusMessage
        #
        # Represents a contextual status message. The message can indicate an
        # error or informational status, and refer to specific parts of the
        # containing object. For example, the Breakpoint.status field can
        # indicate an error referring to the BREAKPOINT_SOURCE_LOCATION with
        # the message Location not found.
        class StatusMessage
          ##
          # Constants used as references to which the message applies.
          UNSPECIFIED = :UNSPECIFIED
          BREAKPOINT_SOURCE_LOCATION = :BREAKPOINT_SOURCE_LOCATION
          BREAKPOINT_CONDITION = :BREAKPOINT_CONDITION
          BREAKPOINT_EXPRESSION = :BREAKPOINT_EXPRESSION
          BREAKPOINT_AGE = :BREAKPOINT_AGE
          VARIABLE_NAME = :VARIABLE_NAME
          VARIABLE_VALUE = :VARIABLE_VALUE

          ##
          # Distinguishes errors from informational messages.
          attr_accessor :is_error

          ##
          # Reference to which the message applies.
          attr_accessor :refers_to

          ##
          # Status message text.
          attr_accessor :description

          ##
          # New Google::Cloud::Debugger::Breakpoint::StatusMessage
          # from a Google::Devtools::Clouddebugger::V2::StatusMessage object.
          def self.from_grpc grpc
            return nil if grpc.nil?
            new.tap do |s|
              s.is_error = grpc.is_error
              s.refers_to = grpc.refers_to
              s.description = grpc.description.format
            end
          end

          ##
          # @private Construct a new StatusMessage instance.
          def initialize
            @refers_to = UNSPECIFIED
          end

          ##
          # @private Determines if the Variable has any data.
          def empty?
            is_error.nil? &&
              refers_to.nil? &&
              description.nil?
          end

          ##
          # Exports the StatusMessage to a
          # Google::Devtools::Clouddebugger::V2::StatusMessage object.
          def to_grpc
            return nil if empty?
            description_grpc =
              Google::Devtools::Clouddebugger::V2::FormatMessage.new \
                format: description.to_s

            Google::Devtools::Clouddebugger::V2::StatusMessage.new \
              is_error: true,
              refers_to: refers_to,
              description: description_grpc
          end
        end
      end
    end
  end
end
