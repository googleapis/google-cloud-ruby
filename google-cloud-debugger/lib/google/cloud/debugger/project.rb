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


require "google/cloud/errors"
require "google/cloud/core/environment"
require "google/cloud/debugger/backoff"
require "google/cloud/debugger/breakpoint_manager"
require "google/cloud/debugger/credentials"
require "google/cloud/debugger/debuggee"
require "google/cloud/debugger/debugger_c"
require "google/cloud/debugger/middleware"
require "google/cloud/debugger/service"
# require "monitor"

module Google
  module Cloud
    module Debugger
      class Project

        include MonitorMixin

        DEFAULT_MAX_QUEUE_SIZE = 100
        CLEANUP_TIMEOUT = 10.0
        WAIT_INTERVAL = 1.0

        @cleanup_list = nil
        @exit_lock = Mutex.new

        ##
        # @private The gRPC Service object.
        attr_accessor :service

        attr_reader :debuggee

        attr_reader :breakpoint_manager

        ##
        # @private The maximum size of the entries queue, or nil if not set.
        attr_accessor :max_queue_size

        ##
        # The current state. Either :running, :suspended, :stopping, or :stopped
        attr_reader :state

        ##
        # The last exception thrown by the background thread, or nil if nothing
        # has been thrown.
        attr_reader :last_exception

        ##
        # @private Creates a new Connection instance.
        def initialize service, module_name: nil, module_version: nil
          super()

          @service = service
          @debuggee = Debuggee.new service, module_name: module_name,
                                            module_version: module_version
          @breakpoint_manager = BreakpointManager.new service

          @max_queue_size = max_queue_size
          @lock_cond = new_cond
          @thread = nil
          @state = :new

          @register_backoff = Backoff.new
          @sync_backoff = Backoff.new
        end

        def project
          service.project
        end

        ##
        # @private Default project.
        def self.default_project
          ENV["DEBUGGER_PROJECT"] ||
            ENV["GOOGLE_CLOUD_PROJECT"] ||
            ENV["GCLOUD_PROJECT"] ||
            Google::Cloud::Core::Environment.project_id
        end

        def start
          synchronize do
            if (@thread.nil? || !@thread.alive?) && state == :new
              Debugger::Project.register_for_cleanup self
              @thread = Thread.new do
                run_agent
                Debugger::Project.unregister_for_cleanup self
              end
              @state = :running
            end
          end
          # caller_file_path = caller[0][/[^:]+/]
          # tracer.start caller_file_path
        end
        alias_method :attach, :start

        def running?
          synchronize do
            state == :running
          end
        end

        def stopped?
          synchronize do
            state == :stopped
          end
        end

        def started?
          synchronize do
            state != :new
          end
        end

        def stop
          synchronize do
            case state
              when :stopped
                false
              when :new
                @state = :stopped
                false
              else
                breakpoint_manager.stop
                @state = :stopping
                true
            end
          end
        end

        def stop! timeout, force: false
          return :stopped unless stop
          return :waited if wait_until_stopped timeout
          return :timeout unless force
          @thread.kill
          @thread.join
          :forced
        end

        def wait_until_stopped timeout = nil
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

        private

        def run_agent
          while running?
            delay = 0
            begin

              if debuggee.registered?
                sync_breakpoints = true
              else
                sync_breakpoints = debuggee.register
                delay = sync_breakpoints ? @register_backoff.succeeded :
                                           @register_backoff.failed
              end
            rescue => e
              @last_exception = e
              delay = @register_backoff.failed
              # break
            end

            begin
              if sync_breakpoints
                sync_result = breakpoint_manager.sync_active_breakpoints
                if sync_result
                  delay = 0
                  @sync_backoff.succeeded
                else
                  delay = @sync_backoff.failed
                end
              end
            rescue => e
              @last_exception = e
              delay = @sync_backoff.failed
              # break
            end

            sleep delay
            # sleep 3
          end
        ensure
          @state = :stopped
        end

        def self.register_for_cleanup debugger
          @exit_lock.synchronize do
            unless @cleanup_list
              @cleanup_list = ::Set.new
              at_exit { Debugger::Project.run_cleanup }
            end
            @cleanup_list.add debugger
          end
        end

        def self.unregister_for_cleanup debugger
          @exit_lock.synchronize do
            @cleanup_list.delete debugger if @cleanup_list
          end
        end

        def self.run_cleanup
          @exit_lock.synchronize do
            if @cleanup_list
              @cleanup_list.each do |debugger|
                debugger.stop! CLEANUP_TIMEOUT, force: true
              end
            end
          end
        end
      end
    end
  end
end
