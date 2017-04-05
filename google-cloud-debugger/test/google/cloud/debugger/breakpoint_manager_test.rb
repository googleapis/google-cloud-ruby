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

  describe "#sync_active_breakpoints" do
    it "returns false if sync request raises error" do
      mocked_list_breakpoints = ->(_, _) { raise }

      breakpoint_manager.service.stub :list_active_breakpoints, mocked_list_breakpoints do
        breakpoint_manager.sync_active_breakpoints(nil).must_equal false
      end
    end

    it "returns true if response.wait_expired is true" do
      mocked_response = OpenStruct.new(wait_expired: true)
      breakpoint_manager.service.stub :list_active_breakpoints, mocked_response do
        breakpoint_manager.sync_active_breakpoints(nil).must_equal true
      end
    end

    it "updates @wait_token after a successful sync" do
      wait_token = "a unique token"
      mocked_response = OpenStruct.new(wait_expired: false, next_wait_token: wait_token)

      breakpoint_manager.wait_token.must_equal :init

      breakpoint_manager.service.stub :list_active_breakpoints, mocked_response do
        breakpoint_manager.sync_active_breakpoints(nil)
      end

      breakpoint_manager.wait_token.must_equal wait_token
    end

    it "calls #update_breakpoints with a list of Google::Cloud::Debugger::Breakpoints" do
      wait_token = "a unique token"
      mocked_response = OpenStruct.new wait_expired: false,
                                       next_wait_token: wait_token,
                                       breakpoints: [nil]
      mocked_update_breakpoints = Minitest::Mock.new
      mocked_update_breakpoints.expect :call, nil, [[breakpoint1]]

      breakpoint_manager.service.stub :list_active_breakpoints, mocked_response do
        Google::Cloud::Debugger::Breakpoint.stub :from_grpc, breakpoint1 do
          breakpoint_manager.stub :update_breakpoints, mocked_update_breakpoints do
            breakpoint_manager.sync_active_breakpoints(nil).must_equal true
          end
        end
      end
    end
  end

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

  describe "#breakpoints" do
    it "returns both active and completed breakpoints" do
      breakpoint_manager.instance_variable_set :@active_breakpoints, [
        breakpoint1,
        breakpoint2
      ]
      breakpoint_manager.instance_variable_set :@completed_breakpoints, [
        breakpoint3
      ]

      breakpoint_manager.breakpoints.must_equal [breakpoint1, breakpoint2, breakpoint3]
    end
  end

  describe "#active_breakpoints" do
    it "only returns both active breakpoints" do
      breakpoint_manager.instance_variable_set :@active_breakpoints, [
        breakpoint1,
        breakpoint2
      ]
      breakpoint_manager.instance_variable_set :@completed_breakpoints, [
        breakpoint3
      ]

      breakpoint_manager.active_breakpoints.must_equal [breakpoint1, breakpoint2]
    end
  end

  describe "#completed breakpoints" do
    it "only returns completed breakpoints" do
      breakpoint_manager.instance_variable_set :@active_breakpoints, [
        breakpoint1,
        breakpoint2
      ]
      breakpoint_manager.instance_variable_set :@completed_breakpoints, [
        breakpoint3
      ]

      breakpoint_manager.completed_breakpoints.must_equal [breakpoint3]
    end
  end

  describe "#all_complete?" do
    it "returns true only if there are active breakpoints" do
      breakpoint_manager.all_complete?.must_equal true
      breakpoint_manager.instance_variable_set :@active_breakpoints, [
        breakpoint1,
        breakpoint2
      ]
      breakpoint_manager.all_complete?.must_equal false
      breakpoint_manager.instance_variable_set :@active_breakpoints, []
      breakpoint_manager.all_complete?.must_equal true
    end

    it "return true if there are only completed breakpoints" do
      breakpoint_manager.all_complete?.must_equal true
      breakpoint_manager.instance_variable_set :@completed_breakpoints, [
        breakpoint3
      ]
      breakpoint_manager.all_complete?.must_equal true
    end
  end

  describe "#clear_breakpoints" do
    it "deletes all local active and completed breakpoints" do
      breakpoint_manager.instance_variable_set :@active_breakpoints, [
        breakpoint1,
        breakpoint2
      ]
      breakpoint_manager.instance_variable_set :@completed_breakpoints, [
        breakpoint3
      ]

      breakpoint_manager.breakpoints.wont_be_empty

      breakpoint_manager.clear_breakpoints
      breakpoint_manager.breakpoints.must_be_empty
    end
  end
end
