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


require "google/cloud/debugger/breakpoint"

module Google
  module Cloud
    module Debugger
      class BreakpointManager
        include MonitorMixin

        attr_reader :service

        attr_reader :app_root

        attr_accessor :on_breakpoints_change

        def initialize service, app_root: nil
          super()

          @service = service
          @app_root = app_root
          if defined? Rack::Directory
            @app_root ||= Rack::Directory.new("").root
          end

          fail "Unable to determine application root path" unless @app_root

          @completed_breakpoints = []
          @active_breakpoints = []

          @wait_token = :init
        end

        def sync_active_breakpoints debuggee_id
          begin
            response = service.list_debuggee_breakpoints debuggee_id, @wait_token
          rescue
            return false
          end
          return true if response.wait_expired?

          synchronize do
            server_breakpoints = response.breakpoints || []
            @wait_token = response.next_wait_token

            server_breakpoints = server_breakpoints.map { |b|
              create_breakpoint(b.id, b.location.path, b.location.line)
            }

            # server_breakpoints.each do |b| puts b.to_grpc end

            new_breakpoints = server_breakpoints - @active_breakpoints - @completed_breakpoints
            activate_breakpoints new_breakpoints unless new_breakpoints.empty?
            forget_breakpoints server_breakpoints

            on_breakpoints_change.call(@active_breakpoints) if
              on_breakpoints_change.respond_to?(:call)
          end

          true
        end

        def activate_breakpoints breakpoints
          synchronize do
            @active_breakpoints += breakpoints
          end
        end

        def forget_breakpoints server_breakpoints
          synchronize do
            @completed_breakpoints &= server_breakpoints
            @active_breakpoints &= server_breakpoints
          end
        end

        def create_breakpoint id, path, line
          abs_path = "#{app_root}/#{path}"
          breakpoint = Breakpoint.new id, abs_path, line.to_i

          yield breakpoint if block_given?

          breakpoint
        end

        def mark_off breakpoint
          synchronize do
            breakpoint = @active_breakpoints.delete breakpoint

            if breakpoint.nil?
              false
            else
              breakpoint.complete
              @completed_breakpoints << breakpoint
              true
            end
          end
        end

        def breakpoints
          synchronize do
            @active_breakpoints | @completed_breakpoints
          end
        end

        def completed_breakpoints
          synchronize do
            @completed_breakpoints
          end
        end

        def active_breakpoints
          synchronize do
            @active_breakpoints
          end
        end

        def all_complete?
          synchronize do
            @active_breakpoints.empty?
          end
        end

        def clear_breakpoints
          synchronize do
            @active_breakpoints.clear
            @completed_breakpoints.clear
          end
        end

        def stop
          tracer.stop
        end
      end
    end
  end
end