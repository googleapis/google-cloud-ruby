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
    module Logging
      class Entry
        ##
        # # SourceLocation
        #
        # Additional information about the source code location that produced
        # the log entry.
        #
        # See also {Google::Cloud::Logging::Entry#source_location}.
        #
        class SourceLocation
          ##
          # @private Create an empty SourceLocation object.
          def initialize
          end

          ##
          # Source file name. Depending on the runtime environment, this might
          # be a simple name or a fully-qualified name. Optional.
          attr_accessor :file

          ##
          # Line within the source file. 1-based; `0` indicates no line number
          # available. Optional.
          attr_accessor :line

          ##
          # Human-readable name of the function or method being invoked, with
          # optional context such as the class or package name. This information
          # may be used in contexts such as the logs viewer, where a file and
          # line number are less meaningful. Optional.
          attr_accessor :function

          ##
          # @private Determines if the SourceLocation has any data.
          def empty?
            file.nil? &&
              line.nil? &&
              function.nil?
          end

          ##
          # @private Exports the SourceLocation to a
          # Google::Logging::V2::LogEntrySourceLocation object.
          def to_grpc
            return nil if empty?
            Google::Logging::V2::LogEntrySourceLocation.new(
              file:       file.to_s,
              line:       line,
              function:   function.to_s
            )
          end

          ##
          # @private New Google::Cloud::Logging::Entry::SourceLocation from a
          # Google::Logging::V2::LogEntrySourceLocation object.
          def self.from_grpc grpc
            return new if grpc.nil?
            new.tap do |o|
              o.file       = grpc.file
              o.line       = grpc.line
              o.function   = grpc.function
            end
          end
        end
      end
    end
  end
end
