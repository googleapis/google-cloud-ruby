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

require "helper"

describe Google::Cloud::Trace::LabelKey, :mock_trace do
  describe ".set_stack_trace" do
    it "generates a default stack trace" do
      frames = [
        stack_frame("/path/to/lib/mylib/stuff.rb", 90, "lib_method1"),
        stack_frame("/path/to/app/myapp.rb", 1, "main"),
      ]
      Kernel.stub :caller_locations, frames do
        labels = {}
        Google::Cloud::Trace::LabelKey.set_stack_trace labels
        labels["/stacktrace"].must_equal '{"stack_frame":[' \
          '{"file_name":"/path/to/lib/mylib/stuff.rb",' \
          '"line_number":90,"method_name":"lib_method1"},' \
          '{"file_name":"/path/to/app/myapp.rb",' \
          '"line_number":1,"method_name":"main"}' \
          ']}'
      end
    end

    it "applies truncation and filters" do
      frames = [
        stack_frame("/path/to/lib/active_support/notifications.rb",
          123, "method1"),
        stack_frame("/path/to/lib/active_support/notifications.rb",
          456, "method2"),
        stack_frame("/path/to/app/myapp.rb", 78, "app_method1"),
        stack_frame("/path/to/lib/mylib/stuff.rb", 90, "lib_method1"),
        stack_frame("/path/to/app/myapp.rb", 1, "main"),
      ]
      truncation_proc = ->(frame) {
        frame.absolute_path !~ %r|/lib/active_support/notifications|
      }
      filter_proc = ->(frame) {
        frame.absolute_path !~ %r|/lib/mylib|
      }
      Kernel.stub :caller_locations, frames do
        labels = {}
        Google::Cloud::Trace::LabelKey.set_stack_trace labels,
          truncate_stack: truncation_proc, filter_stack: filter_proc
        labels["/stacktrace"].must_equal '{"stack_frame":[' \
          '{"file_name":"/path/to/app/myapp.rb",' \
          '"line_number":78,"method_name":"app_method1"},' \
          '{"file_name":"/path/to/app/myapp.rb",' \
          '"line_number":1,"method_name":"main"}' \
          ']}'
      end
    end
  end
end
