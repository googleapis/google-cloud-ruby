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

require "set"


module Google
  module Cloud
    module Debugger
      module AsyncActor
        include MonitorMixin

        CLEANUP_TIMEOUT = 10.0
        WAIT_INTERVAL = 1.0

        @cleanup_list = nil
        @exit_lock = Mutex.new

        attr_reader :state
        attr_reader :last_exception

        def ensure_thread
          fail "async_actor not initialized" if @startup_lock.nil?
          fail "run_backgrounder method not defined" unless
            respond_to? :run_backgrounder
          @startup_lock.synchronize do
            if (@thread.nil? || !@thread.alive?) && @state != :stopped
              @lock_cond = new_cond
              AsyncActor.register_for_cleanup self
              # TODO: Remove this debug flag
              Thread.abort_on_exception = true
              @thread = Thread.new do
                run_backgrounder
                AsyncActor.unregister_for_cleanup self
              end
            end
            @state = :running
          end
        end

        def async_start
          ensure_thread
        end

        def async_stop
          ensure_thread
          synchronize do
            if state != :stopped
              @state = :stopping
              @lock_cond.broadcast
              true
            else
              false
            end
          end
        end

        def suspend
          ensure_thread
          synchronize do
            if state == :running
              @state = :suspended
              @lock_cond.broadcast
              true
            else
              false
            end
          end
        end

        def resume
          ensure_thread
          synchronize do
            if state == :suspended
              @state = :running
              @lock_cond.broadcast
              true
            else
              false
            end
          end
        end

        def running?
          ensure_thread
          synchronize do
            state == :running
          end
        end

        def suspended?
          ensure_thread
          synchronize do
            state == :suspended
          end
        end

        def writable?
          ensure_thread
          synchronize do
            state == :suspended || state == :running
          end
        end

        def stopped?
          ensure_thread
          synchronize do
            state == :stopped
          end
        end

        def wait_until_stopped timeout = nil
          ensure_thread
          deadline = timeout ? ::Time.new.to_f + timeout : nil
          synchronize do
            until state == :stopped
              cur_time = ::Time.new.to_f
              return false if deadline && cur_time >= deadline
              interval = deadline ? deadline - cur_time : WAIT_INTERVAL
              interval = WAIT_INTERVAL if interval > WAIT_INTERVAL
              @lock_cond.wait interval
            end
          end
          true
        end

        def async_stop! timeout, force: false
          return :stopped unless async_stop
          return :waited if wait_until_stopped timeout
          return :timeout unless force
          @thread.kill
          @thread.join
          :forced
        end

        def self.register_for_cleanup actor
          @exit_lock.synchronize do
            unless @cleanup_list
              @cleanup_list = ::Set.new
              at_exit { AsyncActor.run_cleanup }
            end
            @cleanup_list.add actor
          end
        end

        def self.unregister_for_cleanup actor
          @exit_lock.synchronize do
            @cleanup_list.delete actor if @cleanup_list
          end
        end

        def self.run_cleanup
          @exit_lock.synchronize do
            if @cleanup_list
              @cleanup_list.each do |actor|
                actor.async_stop! CLEANUP_TIMEOUT, force: true
              end
            end
          end
        end

        private
        def initialize
          super()
          async_actor_init
        end

        def async_actor_init
          @startup_lock = Mutex.new
          @thread = nil
          @state = nil
          @last_exception
        end
      end
    end
  end
end

