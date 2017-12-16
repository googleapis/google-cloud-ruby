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
        # # Validator
        #
        # A collection of static methods to help validate a given breakpoint.
        module Validator
          FILE_NOT_FOUND_MSG = "File not found."
          WRONG_FILE_TYPE_MSG = "File must be a `.rb` file."
          INVALID_LINE_MSG = "Invalid line."

          ##
          # Validate a given breakpoint. Set breakpoint to error state if
          # the breakpoint fails validation.
          def self.validate breakpoint
            error_msg = nil
            if !verify_file_path breakpoint.full_path
              error_msg = FILE_NOT_FOUND_MSG
            elsif !verify_file_type breakpoint.full_path
              error_msg = WRONG_FILE_TYPE_MSG
            elsif !verify_line breakpoint.full_path, breakpoint.line
              error_msg = INVALID_LINE_MSG
            end

            if error_msg
              cause = Breakpoint::StatusMessage::BREAKPOINT_SOURCE_LOCATION
              breakpoint.set_error_state error_msg, refers_to: cause
              false
            else
              true
            end
          end

          ##
          # @private Verifies the given file path exists
          def self.verify_file_path file_path
            File.exist? file_path
          rescue
            false
          end

          ##
          # @private Check the file from given file path is a Ruby file
          def self.verify_file_type file_path
            File.extname(file_path) == ".rb" ||
              File.basename(file_path) == "config.ru"
          rescue
            false
          end

          ##
          # @private Verifies the given line from a Ruby
          def self.verify_line file_path, line
            file = File.open file_path, "r"

            # Skip through lines from beginning
            file.gets while file.lineno < line - 1 && !file.eof?

            line = file.gets

            # Make sure we have a line (not eof)
            return false unless line

            blank_line = line =~ /^\s*$/
            comment_line = line =~ /^\s*#.*$/

            blank_line || comment_line ? false : true
          rescue
            false
          end
        end
      end
    end
  end
end
