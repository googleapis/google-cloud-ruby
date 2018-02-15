# Copyright 2016 Google LLC
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

describe Google::Cloud::Trace::Notifications, :mock_trace do
  let(:event_type) { "test_event_type" }

  describe ".instrument" do
    it "generates spans for events" do
      Google::Cloud::Trace::Notifications.instrument event_type,
                                                     capture_stack: true
      frames = [
        stack_frame("/path/to/lib/active_support/notifications.rb",
          123, "method1"),
        stack_frame("/path/to/lib/active_support/notifications.rb",
          456, "method2"),
        stack_frame("/path/to/app/myapp.rb", 78, "app_method1"),
        stack_frame("/path/to/lib/mylib/stuff.rb", 90, "lib_method1"),
        stack_frame("/path/to/app/myapp.rb", 1, "main"),
      ]
      trace = Google::Cloud::Trace::TraceRecord.new project
      Google::Cloud::Trace.stub :get, trace do
        Kernel.stub :caller_locations, frames do
          ActiveSupport::Notifications.instrument event_type,
                                                  foo: "barrr",
                                                  whoops: "x" * 2000 do
            # yada yada yada
          end
          ActiveSupport::Notifications.instrument "othertype", bar: "foooo" do
            # yada yada yada
          end
        end
      end
      trace.all_spans.size.must_equal 1
      span = trace.root_spans.first
      span.name.must_equal event_type
      expected_labels = {
        "/ruby/foo" => "barrr",
        "/ruby/whoops" => "x" * 1021 + "...",
        "/stacktrace" => '{"stack_frame":[' \
          '{"file_name":"/path/to/app/myapp.rb",' \
          '"line_number":78,"method_name":"app_method1"},' \
          '{"file_name":"/path/to/lib/mylib/stuff.rb",' \
          '"line_number":90,"method_name":"lib_method1"},' \
          '{"file_name":"/path/to/app/myapp.rb",' \
          '"line_number":1,"method_name":"main"}' \
          ']}'
      }
      span.labels.must_equal expected_labels
    end
  end
end
