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


module Google
  module Cloud
    module ErrorReporting
      class ErrorEvent
        ##
        # SourceLocation
        #
        # Rrepresent
        # Google::Devtools::Clouderrorreporting::V1beta1::SourceLocation
        # class. Indicates a location in thesource code of the service for which
        # errors are reported. This data should be provided by the application
        # when reporting an error, unless the error report has been generated
        # automatically from Google App Engine logs. All fields are optional.
        #
        class SourceLocation
          ##
          # Build a new
          # Google::Cloud::ErrorReporting::ErrorEvent::SourceLocation object
          def initialize
          end

          ##
          # String. The source code filename, which can include a truncated
          # relative path, or a full path from a production machine.
          attr_accessor :file_path

          ##
          # Number. 1-based. 0 indicates that the line number is unknown.
          attr_accessor :line_number

          ##
          # String. Human-readable name of a function or method. The value can
          # include optional context like the class or package name. For
          # example, my.package.MyClass.method in case of Java.
          attr_accessor :function_name

          ##
          # Determines if the SourceLocation has any data
          def empty?
            file_path.nil? &&
              line_number.nil? &&
              function_name.nil?
          end

          ##
          # Exports the SourceLocation to a
          # Google::Devtools::Clouderrorreporting::V1beta1::SourceLocation
          # object.
          def to_grpc
            return nil if empty?
            Google::Devtools::Clouderrorreporting::V1beta1::SourceLocation.new(
              file_path:     file_path.to_s,
              line_number:   line_number.to_i,
              function_name: function_name.to_s
            )
          end

          ##
          # New SourceLocation from a
          # Google::Devtools::Clouderrorreporting::V1beta1::SourceLocation
          # object.
          def self.from_grpc grpc
            return new if grpc.nil?
            new.tap do |s|
              s.file_path     = grpc.file_path
              s.line_number   = grpc.line_number
              s.function_name = grpc.function_name
            end
          end
        end
      end
    end
  end
end
