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


require "helper"

describe Google::Cloud::Debugger::Breakpoint::Validator, :mock_debugger do
  let(:breakpoint) { Google::Cloud::Debugger::Snappoint.new nil, __FILE__, __LINE__}
  let(:validator) { Google::Cloud::Debugger::Breakpoint::Validator }

  describe ".validate" do
    it "return true if breakpoint is valid" do
      validator.validate(breakpoint).must_equal true
    end

    it "returns false if breakpoint's target file doesn't exist" do
      breakpoint.location.path = "/path/to/not-exist.rb"

      validator.validate(breakpoint).must_equal false

      breakpoint.complete?.must_equal true
      breakpoint.status.description.must_equal validator::FILE_NOT_FOUND_MSG
    end

    it "returns false if breakpoints target file isn't a ruby file" do
      breakpoint.location.path = "/path/to/not-ruby-file"

      validator.stub :verify_file_path, true do
        validator.validate(breakpoint).must_equal false
      end

      breakpoint.complete?.must_equal true
      breakpoint.status.description.must_equal validator::WRONG_FILE_TYPE_MSG
    end

    it "returns false if breakpoint line number is too large" do
      breakpoint.location.line = 999999

      validator.validate(breakpoint).must_equal false

      breakpoint.complete?.must_equal true
      breakpoint.status.description.must_equal validator::INVALID_LINE_MSG
    end

    it "returns false if breakpoint is on a blank line" do
      breakpoint.location.line = __LINE__ + 3

      # Intentional blank line below

      # End blank line

      validator.stub :verify_file_path, true do
        validator.stub :verify_file_type, true do
          validator.validate(breakpoint).must_equal false
        end
      end

      breakpoint.complete?.must_equal true
      breakpoint.status.description.must_equal validator::INVALID_LINE_MSG
    end

    it "returns false if breakpoint is on a blank line" do
      breakpoint.location.line = __LINE__ + 3

      #####
      # Intentional comment block for test
      #####

      validator.stub :verify_file_path, true do
        validator.stub :verify_file_type, true do
          validator.validate(breakpoint).must_equal false
        end
      end

      breakpoint.complete?.must_equal true
      breakpoint.status.description.must_equal validator::INVALID_LINE_MSG
    end
  end
end
