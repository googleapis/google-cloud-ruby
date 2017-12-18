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

describe Google::Cloud::Debugger::BreakpointManager, :mock_debugger do
  let(:breakpoint1) {
    Google::Cloud::Debugger::Breakpoint.new "1", __FILE__, __LINE__
  }
  let(:breakpoint2) {
    Google::Cloud::Debugger::Breakpoint.new "2", __FILE__, __LINE__
  }
  let(:breakpoint3) {
    Google::Cloud::Debugger::Breakpoint.new "3", __FILE__, __LINE__
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

    it "injects app_root to the breakpoints received from server" do
      wait_token = "a unique token"
      mocked_response = OpenStruct.new wait_expired: false,
                                       next_wait_token: wait_token,
                                       breakpoints: [nil]

      breakpoint_manager.service.stub :list_active_breakpoints, mocked_response do
        Google::Cloud::Debugger::Breakpoint.stub :from_grpc, breakpoint1 do
          app_root = "my/app/path"
          breakpoint_manager.agent.app_root =app_root
          breakpoint_manager.sync_active_breakpoints(nil).must_equal true

          breakpoint1.full_path.must_match app_root
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

    it "only add valid breakpoints" do
      breakpoint_manager.stub :filter_breakpoints, [breakpoint2] do
        breakpoint_manager.update_breakpoints [breakpoint1, breakpoint2]
      end

      breakpoint_manager.active_breakpoints.size.must_equal 1
      breakpoint_manager.active_breakpoints.first.must_equal breakpoint2
    end
  end

  describe "#breakpoint_hit" do
    let(:breakpoint) {
      Google::Cloud::Debugger::Snappoint.new nil, "path/to/file.rb", 123
    }

    it "marks breakpoint off and submits breakpoint" do
      mocked_submit = Minitest::Mock.new
      mocked_submit.expect :call, nil, [Google::Cloud::Debugger::Breakpoint]
      mocked_mark_off = Minitest::Mock.new
      mocked_mark_off.expect :call, nil, [Google::Cloud::Debugger::Breakpoint]

      stubbed_evaluate = ->(_) { breakpoint.complete }

      tracer.update_breakpoints_cache

      breakpoint.stub :evaluate, stubbed_evaluate do
        transmitter.stub :submit, mocked_submit do
          breakpoint_manager.stub :mark_off, mocked_mark_off do
            breakpoint_manager.breakpoint_hit breakpoint, nil
          end
        end
      end

      mocked_submit.verify
      mocked_mark_off.verify
    end

    it "doesn't mark breakpoint off ir submits breakpoint if breakpoint fail to evaluate" do
      stubbed_submit = ->(_) { fail }
      stubbed_mark_off = ->(_) { fail }

      breakpoint.stub :evaluate, nil do
        transmitter.stub :submit, stubbed_submit do
          breakpoint_manager.stub :mark_off, stubbed_mark_off do
            breakpoint_manager.breakpoint_hit breakpoint, nil
          end
        end
      end
    end

    it "calls #log_logpoint if the breakpoint is a logpoint" do
      mocked_log_logpoint = Minitest::Mock.new
      mocked_log_logpoint.expect :call, nil, [Google::Cloud::Debugger::Breakpoint]
      breakpoint.action = :LOG

      breakpoint_manager.stub :log_logpoint, mocked_log_logpoint do
        breakpoint.stub :evaluate, nil do
          breakpoint_manager.breakpoint_hit breakpoint, nil
        end
      end

      mocked_log_logpoint.verify
    end
  end

  describe "#log_logpoint" do
    let(:logpoint) do
      Google::Cloud::Debugger::Breakpoint.new.tap do |b|
        b.log_level = :INFO
        b.evaluated_log_message = "Hello World"
      end
    end

    it "calls logger.info if log_level is :INFO" do
      mocked_info = Minitest::Mock.new
      mocked_info.expect :call, nil, ["LOGPOINT: Hello World"]

      agent.logger.stub :info, mocked_info do
        breakpoint_manager.log_logpoint logpoint
      end

      mocked_info.verify
    end

    it "calls logger.warn if log_level is :WARNING" do
      mocked_warn = Minitest::Mock.new
      mocked_warn.expect :call, nil, ["LOGPOINT: Hello World"]

      agent.logger.stub :warn, mocked_warn do
        logpoint.log_level = :WARNING

        breakpoint_manager.log_logpoint logpoint
      end

      mocked_warn.verify
    end

    it "calls logger.error if log_level is :ERROR" do
      mocked_error = Minitest::Mock.new
      mocked_error.expect :call, nil, ["LOGPOINT: Hello World"]

      agent.logger.stub :error, mocked_error do
        logpoint.log_level = :ERROR

        breakpoint_manager.log_logpoint logpoint
      end

      mocked_error.verify
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

  describe "#filter_breakpoints" do
    it "validates breakpoint and directly submit those aren't valid" do
      breakpoint2.location.path = nil

      mocked_submit = Minitest::Mock.new
      mocked_submit.expect :call, nil, [breakpoint2]

      breakpoint_manager.agent.transmitter.stub :submit, mocked_submit do
        breakpoints = breakpoint_manager.send :filter_breakpoints, [breakpoint1, breakpoint2]

        breakpoints.size.must_equal 1
        breakpoints.first.must_equal breakpoint1
      end

      mocked_submit.verify
    end
  end
end
