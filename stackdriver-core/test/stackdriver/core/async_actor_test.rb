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
require "stackdriver/core/async_actor"

describe Stackdriver::Core::AsyncActor do
  class AsyncActorTest
    include Stackdriver::Core::AsyncActor

    def initialize
      super()

      set_cleanup_options timeout: 0.1
    end

    def run_backgrounder
      true
    end

    def start_thread &block
      block.call
    end

    def on_async_state_change

    end
  end

  let(:actor) { AsyncActorTest.new }

  describe "#async_start" do
    it "starts the thread" do
      thr = actor.instance_variable_get("@thread")
      thr.must_be_nil

      actor.async_start
      thr = actor.instance_variable_get("@thread")
      thr.must_be_kind_of Thread
      thr.status.must_equal "run"

      actor.async_state.must_equal :running

      thr.kill
      thr.join
    end

    it "calls #on_async_state_change" do
      mocked_change = Minitest::Mock.new
      mocked_change.expect :call, nil

      actor.instance_variable_set :@lock_cond, OpenStruct.new(broadcast: nil)

      actor.stub :on_async_state_change, mocked_change do
        actor.stub :ensure_thread, nil do
          actor.async_stop
        end
      end

      mocked_change.verify
    end
  end

  describe "#async_stop" do
    it "sets the state to :stopping" do
      stopping = actor.async_stop
      stopping.must_equal true

      # Wait for child thread to fully stop
      wait_result = wait_until_true do
        actor.async_state != :stopping
      end
      wait_result.must_equal :completed

      stopping = actor.async_stop
      stopping.must_equal false
    end

    it "calls #on_async_state_change" do
      mocked_change = Minitest::Mock.new
      mocked_change.expect :call, nil

      actor.instance_variable_set :@lock_cond, OpenStruct.new(broadcast: nil)

      actor.stub :on_async_state_change, mocked_change do
        actor.stub :ensure_thread, nil do
          actor.async_stop
        end
      end

      mocked_change.verify
    end
  end

  describe "#async_suspend" do
    it "sets the state to :stopping" do
      actor.async_start
      actor.async_state.must_equal :running

      suspended = actor.async_suspend
      suspended.must_equal true
      actor.async_state.must_equal :suspended

      suspended = actor.async_suspend
      suspended.must_equal false

      actor.async_stop
    end

    it "calls #on_async_state_change" do
      mocked_change = Minitest::Mock.new
      mocked_change.expect :call, nil

      actor.instance_variable_set :@lock_cond, OpenStruct.new(broadcast: nil)

      actor.stub :on_async_state_change, mocked_change do
        actor.stub :ensure_thread, nil do
          actor.async_stop
        end
      end

      mocked_change.verify
    end
  end

  describe "#async_resume" do
    it "sets the state back to :running from :suspended" do
      actor.async_start

      actor.async_suspend
      actor.async_state.must_equal :suspended

      resumed = actor.async_resume
      actor.async_state.must_equal :running
      resumed.must_equal true

      resumed = actor.async_resume
      resumed.must_equal false

      actor.async_stop
    end

    it "calls #on_async_state_change" do
      mocked_change = Minitest::Mock.new
      mocked_change.expect :call, nil

      actor.instance_variable_set :@lock_cond, OpenStruct.new(broadcast: nil)

      actor.stub :on_async_state_change, mocked_change do
        actor.stub :ensure_thread, nil do
          actor.async_stop
        end
      end

      mocked_change.verify
    end
  end

  describe "#async_running?" do
    it "returns true only when async job is running" do
      actor.async_running?.must_equal false

      actor.async_start
      actor.async_running?.must_equal true

      actor.async_suspend
      actor.async_running?.must_equal false

      actor.async_resume
      actor.async_running?.must_equal true

      actor.async_stop
      actor.async_running?.must_equal false
    end
  end

  describe "#async_suspended?" do
    it "returns true only when async job is suspended" do
      actor.async_suspended?.must_equal false

      actor.async_start
      actor.async_suspended?.must_equal false

      actor.async_suspend
      actor.async_suspended?.must_equal true

      actor.async_resume
      actor.async_suspended?.must_equal false

      actor.async_stop
      actor.async_suspended?.must_equal false
    end
  end

  describe "#async_working?" do
    it "returns true only when async job is running or suspended" do
      actor.async_working?.must_equal false

      actor.async_start
      actor.async_working?.must_equal true

      actor.async_suspend
      actor.async_working?.must_equal true

      actor.async_resume
      actor.async_working?.must_equal true

      actor.async_stop
      actor.async_working?.must_equal false
    end
  end

  describe "#async_stopped?" do
    it "returns true only when async job is stopped" do
      actor.async_stopped?.must_equal false

      actor.async_start
      actor.async_stopped?.must_equal false

      actor.async_suspend
      actor.async_stopped?.must_equal false

      actor.async_resume
      actor.async_stopped?.must_equal false

      actor.async_stop
      actor.async_state.must_equal :stopping

      wait_result = wait_until_true do
        actor.async_state != :stopping
      end

      wait_result.must_equal :completed
      actor.async_stopped?.must_equal true
    end
  end

  describe "#async_stop!" do
    it "waits for the async job to stop" do
      actor.async_start

      actor.send :set_cleanup_options, force: false

      actor.async_stopped?.must_equal false
      stop = actor.async_stop!
      stop.must_equal :waited
      actor.async_stopped?.must_equal true
    end

    it "forces the async job to stop" do
      thread_running = false
      actor.define_singleton_method :run_backgrounder do
        loop { thread_running = true }
      end

      actor.async_start

      wait_result = wait_until_true do
        thread_running
      end
      wait_result.must_equal :completed

      actor.async_stopped?.must_equal false
      stop = actor.async_stop!
      stop.must_equal :forced
      actor.async_stopped?.must_equal true
    end

    it "doesn't wait if timeout is 0" do
      thread_running = false
      actor.define_singleton_method :run_backgrounder do
        loop { thread_running = true }
      end

      actor.async_start

      wait_result = wait_until_true do
        thread_running
      end
      wait_result.must_equal :completed
      actor.async_stopped?.must_equal false

      actor.send :set_cleanup_options, timeout: 0
      stop = actor.async_stop!
      stop.must_equal :forced
      actor.async_stopped?.must_equal true
    end

    it "calls #on_async_state_change" do
      mocked_change = Minitest::Mock.new
      mocked_change.expect :call, nil

      actor.instance_variable_set :@lock_cond, OpenStruct.new(broadcast: nil)

      actor.stub :on_async_state_change, mocked_change do
        actor.stub :ensure_thread, nil do
          actor.async_stop
        end
      end

      mocked_change.verify
    end
  end

  describe ".register_for_cleanup" do
    it "adds actor to cleanup_list" do
      klass = Stackdriver::Core::AsyncActor
      actor.async_start
      klass.instance_variable_get("@cleanup_list").must_include actor
      actor.async_stop
    end
  end

  describe ".run_cleanup" do
    it "calls async_stop! on actors" do
      mock = Minitest::Mock.new
      mock.expect :async_stop!, true, []

      Stackdriver::Core::AsyncActor.instance_variable_set :@cleanup_list,  nil
      Stackdriver::Core::AsyncActor.register_for_cleanup mock
      Stackdriver::Core::AsyncActor.send :run_cleanup

      mock.verify
    end
  end
end
