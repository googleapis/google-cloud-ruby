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


require "google/cloud/debugger/breakpoint/source_location"

module Google
  module Cloud
    module Debugger
      class Breakpoint
        ##
        # # StackFrame
        #
        # Represents a stack frame context.
        #
        # See also {Breakpoint#stack_frames}.
        #
        class StackFrame
          ##
          # Demangled function name at the call site.
          attr_accessor :function

          ##
          # Source location of the call site.
          attr_accessor :location

          ##
          # Set of arguments passed to this function. Note that this might not
          # be populated for all stack frames.
          attr_accessor :arguments

          ##
          # Set of local variables at the stack frame location. Note that this
          # might not be populated for all stack frames.
          attr_accessor :locals

          ##
          # @private Create an empty StackFrame object.
          def initialize
            @location = SourceLocation.new
            @arguments = []
            @locals = []
          end

          ##
          # @private New Google::Cloud::Debugger::Breakpoint::SourceLocation
          # from a Google::Devtools::Clouddebugger::V2::SourceLocation object.
          def self.from_grpc grpc
            new.tap do |o|
              o.function = grpc.function
              o.location = SourceLocation.from_grpc grpc.location
              o.arguments = Variable.from_grpc_list grpc.arguments
              o.locals = Variable.from_grpc_list grpc.locals
            end
          end

          ##
          # @private Determines if the StackFrame has any data.
          def empty?
            function.nil? &&
              location.nil? &&
              arguments.nil? &&
              locals.nil?
          end

          ##
          # @private Exports the StackFrame to a
          # Google::Devtools::Clouddebugger::V2::StackFrame object.
          def to_grpc
            return nil if empty?
            Google::Devtools::Clouddebugger::V2::StackFrame.new(
              function: function.to_s,
              location: location.to_grpc,
              arguments: arguments_to_grpc,
              locals: locals_to_grpc
            )
          end

          private

          ##
          # @private Exports the StackFrame arguments to an array of
          # Google::Devtools::Clouddebugger::V2::Variable objects.
          def arguments_to_grpc
            arguments.nil? ? [] : arguments.map(&:to_grpc)
          end

          ##
          # @private Exports the StackFrame locals to an array of
          # Google::Devtools::Clouddebugger::V2::Variable objects.
          def locals_to_grpc
            locals.nil? ? [] : locals.map(&:to_grpc)
          end
        end
      end
    end
  end
end
