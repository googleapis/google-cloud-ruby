require "google/cloud/debugger/breakpoint"
require "google/cloud/debugger/tracer"

module Google
  module Cloud
    module Debugger
      class BreakpointManager
        include MonitorMixin

        attr_reader :service

        attr_reader :app_root

        attr_reader :tracer

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

          @tracer = Debugger::Tracer.new self
          @wait_token = :init
        end

        def sync_active_breakpoints debuggee_id
          begin
            response = service.list_debuggee_breakpoints debuggee_id, @wait_token
          rescue
            return false
          end
          breakpoints = response.breakpoints || []
          @wait_token = response.next_wait_token
          return true if response.wait_expired?

          puts "************************ new breakpoints:"
          puts breakpoints

          server_breakpoints = breakpoints.map { |b|
            create_breakpoint(b.id, b.location.path, b.location.path)
          }

          # server_breakpoints = [
          #   create_breakpoint(Time.now.to_i, "app/controllers/test_controller.rb", 13) do |breakpoint|
          #     # breakpoint.add_expression 'blah = "modified blah"'
          #     # breakpoint.add_expression '"#{blah} is lame!"'
          #     # breakpoint.add_expression "$my_global = 'bye'"
          #     breakpoint.add_expression '1/0'
          #   end,
          #
          #   create_breakpoint(Time.now.to_i + 1, "app/controllers/test_controller.rb", 7) do |breakpoint|
          #     # breakpoint.add_expression 'blah = "modified blah"'
          #     breakpoint.add_expression '"#{blah} is lame!"'
          #     # breakpoint.add_expression "$my_global = 'bye'"
          #     # breakpoint.add_expression '1/0'
          #   end
          # ]

          synchronize do
            new_breakpoints = server_breakpoints - @active_breakpoints - @completed_breakpoints
            activate_breakpoints new_breakpoints unless new_breakpoints.empty?
            forget_breakpoints server_breakpoints
            signal_tracer
          end

          puts "active_breakpoints size: #{active_breakpoints.size}"
          puts active_breakpoints

          true
        end

        def signal_tracer
          synchronize do
            if @active_breakpoints.empty?
              tracer.stop
            else
              tracer.start
            end
          end
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
          breakpoint = Breakpoint.new id, abs_path, line

          yield breakpoint if block_given?

          breakpoint
        end

        def complete_breakpoint breakpoint
          synchronize do
            breakpoint = @active_breakpoints.delete breakpoint
            signal_tracer

            if breakpoint.nil? || breakpoint.complete?
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