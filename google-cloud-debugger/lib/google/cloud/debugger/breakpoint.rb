require "google/cloud/debugger/breakpoint/evaluator"

module Google
  module Cloud
    module Debugger
      class Breakpoint
        attr_accessor :id

        attr_accessor :action

        attr_accessor :location

        attr_accessor :expressions

        attr_accessor :create_time

        attr_accessor :status

        attr_accessor :condition

        def initialize id, path, line, create_time = nil
          @id = id
          @action = :capture
          @location = Location.new path, line
          @expressions = []
          @create_time = create_time
          @status = :active
        end

        def add_expression expression
          @expressions << expression
          expression
        end

        def path_hit? path
          location.path.match(path) || path.match(location.path)
        end

        def line_hit? path, line
          path_hit?(path) && location.line == line
        end

        def active?
          status == :active
        end

        def complete
          @status = :complete
        end

        def complete?
          status == :complete
        end

        def path
          location.path
        end

        def line
          location.line
        end

        def eval_call_stack call_stack_bindings
          result = Evaluator.eval_call_stack self, call_stack_bindings

          # result.each do |x|
          #   puts "********************"
          #   puts x
          #   break
          # end

          complete
        end

        def eql? other_breakpoint
          @id == other_breakpoint.id
        end

        def == other_breakpoint
          @id == other_breakpoint.id
        end

        def hash
          id.hash ^ location.path.hash ^ location.line.hash
        end

        private

        class Location
          attr_accessor :path

          attr_accessor :line

          def initialize path, line
            @path = path
            @line = line
          end
        end
      end
    end
  end
end
