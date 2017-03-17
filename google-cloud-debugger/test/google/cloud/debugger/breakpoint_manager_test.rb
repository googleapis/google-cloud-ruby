# Copyright 2017 Google Inc. All rights reserved.
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

describe Google::Cloud::Debugger::BreakpointManager, :mock_debugger do
  let(:breakpoint1) {
    Google::Cloud::Debugger::Breakpoint.new "1"
  }
  let(:breakpoint2) {
    Google::Cloud::Debugger::Breakpoint.new "2"
  }
  let(:breakpoint3) {
    Google::Cloud::Debugger::Breakpoint.new "3"
  }

  describe "#update_breakpoints" do
    it "addes new breakpoints" do
      breakpoint_manager.active_breakpoints.must_be_empty
      breakpoint_manager.completed_breakpoints.must_be_empty

      breakpoint_manager.update_breakpoints [breakpoint1]

      breakpoint_manager.active_breakpoints.size.must_equal 1
      breakpoint_manager.completed_breakpoints.must_be_empty

      breakpoint_manager.active_breakpoints.first.must_equal breakpoint1
    end

    it "doesn't add breakpoints already in @active_breakpoints" do
      breakpoint_manager.update_breakpoints [breakpoint1, breakpoint2]

      breakpoint_manager.active_breakpoints.size.must_equal 2

      breakpoint_manager.update_breakpoints [breakpoint1, breakpoint2, breakpoint3]

      breakpoint_manager.active_breakpoints.size.must_equal 3

      breakpoint_manager.active_breakpoints.must_include breakpoint1
      breakpoint_manager.active_breakpoints.must_include breakpoint2
      breakpoint_manager.active_breakpoints.must_include breakpoint3
    end

    it "removes old breakpoints not in new list" do
      breakpoint_manager.update_breakpoints [breakpoint1, breakpoint2]

      breakpoint_manager.active_breakpoints.size.must_equal 2

      breakpoint_manager.update_breakpoints [breakpoint2, breakpoint3]

      breakpoint_manager.active_breakpoints.size.must_equal 2

      breakpoint_manager.active_breakpoints.must_include breakpoint2
      breakpoint_manager.active_breakpoints.must_include breakpoint3
    end

    it "removes old breakpoints from @completed_breakpoints not in new list" do
      breakpoint_manager.update_breakpoints [breakpoint1, breakpoint2]
      breakpoint_manager.mark_off breakpoint2

      breakpoint_manager.active_breakpoints.size.must_equal 1
      breakpoint_manager.completed_breakpoints.size.must_equal 1
      breakpoint_manager.active_breakpoints.first.must_equal breakpoint1
      breakpoint_manager.completed_breakpoints.first.must_equal breakpoint2

      breakpoint_manager.update_breakpoints [breakpoint3]

      breakpoint_manager.active_breakpoints.size.must_equal 1
      breakpoint_manager.active_breakpoints.first.must_equal breakpoint3
      breakpoint_manager.completed_breakpoints.must_be_empty
    end

    it "doesn't add breakpoints already in @completed_breakpoints" do
      breakpoint_manager.update_breakpoints [breakpoint1]
      breakpoint_manager.mark_off breakpoint1

      breakpoint_manager.active_breakpoints.must_be_empty
      breakpoint_manager.completed_breakpoints.size.must_equal 1

      breakpoint_manager.update_breakpoints [breakpoint1]

      breakpoint_manager.active_breakpoints.must_be_empty
      breakpoint_manager.completed_breakpoints.size.must_equal 1
      breakpoint_manager.completed_breakpoints.must_include breakpoint1
    end
  end

  describe "#mark_off" do
    it "moves a breakpoint from @active_breakpoints list to @completed_breakpoints list" do
      breakpoint_manager.update_breakpoints [breakpoint1]

      breakpoint_manager.active_breakpoints.size.must_equal 1
      breakpoint_manager.completed_breakpoints.must_be_empty

      breakpoint_manager.mark_off breakpoint1

      breakpoint_manager.active_breakpoints.must_be_empty
      breakpoint_manager.completed_breakpoints.size.must_equal 1
      breakpoint_manager.completed_breakpoints.must_include breakpoint1
    end

    it "doesn't mark off a breakpoint not in @active_breakpoints" do
      breakpoint_manager.update_breakpoints [breakpoint1]

      breakpoint_manager.active_breakpoints.size.must_equal 1
      breakpoint_manager.completed_breakpoints.must_be_empty

      breakpoint_manager.mark_off breakpoint2

      breakpoint_manager.active_breakpoints.size.must_equal 1
      breakpoint_manager.completed_breakpoints.must_be_empty
    end
  end
end
