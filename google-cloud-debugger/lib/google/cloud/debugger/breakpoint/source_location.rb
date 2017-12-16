# Copyright 2017 Google LLC
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
    module Debugger
      class Breakpoint
        ##
        # # SourceLocation
        #
        # Additional information about the source code location that's
        # associated with the breakpoint.
        #
        # See also {Breakpoint#location}.
        #
        class SourceLocation
          ##
          # Path to the source file within the source context of the target
          # binary.
          attr_accessor :path

          ##
          # Line inside the file. The first line in the file has the value 1.
          attr_accessor :line

          ##
          # @private Create an empty SourceLocation object.
          def initialize
          end

          ##
          # @private New Google::Cloud::Debugger::Breakpoint::SourceLocation
          # from a Google::Devtools::Clouddebugger::V2::SourceLocation object.
          def self.from_grpc grpc
            return new if grpc.nil?
            new.tap do |o|
              o.path = grpc.path
              o.line = grpc.line
            end
          end

          ##
          # @private Determines if the SourceLocation has any data.
          def empty?
            path.nil? &&
              line.nil?
          end

          ##
          # @private Exports the SourceLocation to a
          # Google::Devtools::Clouddebugger::V2::SourceLocation object.
          def to_grpc
            return nil if empty?
            Google::Devtools::Clouddebugger::V2::SourceLocation.new(
              path: path.to_s,
              line: line
            )
          end
        end
      end
    end
  end
end
