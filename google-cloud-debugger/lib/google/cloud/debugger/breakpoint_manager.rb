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


require "google/cloud/debugger/breakpoint"

module Google
  module Cloud
    module Debugger
      class BreakpointManager
        include MonitorMixin

        attr_reader :service

        attr_reader :app_root

        attr_accessor :on_breakpoints_change

        def initialize service
          super()

          @service = service

          @completed_breakpoints = []
          @active_breakpoints = []

          @wait_token = :init
        end

        def sync_active_breakpoints debuggee_id
          begin
            response = service.list_active_breakpoints debuggee_id, @wait_token
          rescue
            return false
          end

          return true if response.wait_expired

          @wait_token = response.next_wait_token

          server_breakpoints = response.breakpoints || []
          server_breakpoints = server_breakpoints.map do |grpc_b|
            Breakpoint.from_grpc grpc_b
          end

          update_breakpoints server_breakpoints

          true
        end

        def update_breakpoints server_breakpoints
          # puts "server_breakpoints"
          # p server_breakpoints

          synchronize do
            new_breakpoints =
              server_breakpoints - @active_breakpoints - @completed_breakpoints
            before_breakpoints_count =
              @active_breakpoints.size + @completed_breakpoints.size

            # Remember new active breakpoints from server
            @active_breakpoints += new_breakpoints unless new_breakpoints.empty?

            # Forget old breakpoints
            @completed_breakpoints &= server_breakpoints
            @active_breakpoints &= server_breakpoints
            after_breakpoints_acount =
              @active_breakpoints.size + @completed_breakpoints.size

            breakpoints_updated =
              !new_breakpoints.empty? ||
              (before_breakpoints_count != after_breakpoints_acount)

            on_breakpoints_change.call(@active_breakpoints) if
              on_breakpoints_change.respond_to?(:call) && breakpoints_updated

            # puts "Active breakpoints: after sync"
            # p @active_breakpoints
            # puts "Completed breakpoints: after sync"
            # p @completed_breakpoints
          end
        end

        def mark_off breakpoint
          synchronize do
            breakpoint = @active_breakpoints.delete breakpoint

            if breakpoint.nil?
              false
            else
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
      end
    end
  end
end
