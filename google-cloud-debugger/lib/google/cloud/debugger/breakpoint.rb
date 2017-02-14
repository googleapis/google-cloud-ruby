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


require "google/cloud/debugger/breakpoint/evaluator"
require "google/cloud/debugger/breakpoint/source_location"
require "google/cloud/debugger/breakpoint/stack_frame"
require "google/cloud/debugger/breakpoint/variable"

module Google
  module Cloud
    module Debugger
      class Breakpoint
        attr_accessor :id

        attr_accessor :action

        attr_accessor :location

        attr_accessor :condition

        attr_accessor :is_final_state

        attr_accessor :expressions

        attr_accessor :evaluated_expressions

        attr_accessor :create_time

        attr_accessor :status

        attr_accessor :completed

        attr_accessor :stack_frames

        def initialize id = nil, path = nil, line = nil
          @id = id
          @action = :capture
          if path || line
            @location = SourceLocation.new.tap do |sl|
              sl.path = path
              sl.line = line.to_i
            end
          else
            @location = nil
          end
          @condition = nil
          @is_final_state = nil
          @expressions = []
          @evaluated_expressions = []
          @create_time = create_time
          @status = nil
          @completed = false
          @stack_frames = []
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

        def complete
          #TODO set @is_final_state and @final_time
          @is_final_state = true
          @completed = true
        end

        alias_method :complete?, :completed

        def path
          location.path
        end

        def line
          location.line
        end

        def eval_call_stack call_stack_bindings
          puts "BREAKPOINT HIT*******************************\n\n"
          begin
            @stack_frames = Evaluator.eval_call_stack call_stack_bindings
            if @expressions
              @evaluated_expressions =
                Evaluator.eval_expressions call_stack_bindings[0], @expressions
            end
          rescue => e
            puts e.message
            puts e.backtrace
          end


          complete
          nil
        end

        def eql? other
          id == other.id &&
            path == other.path &&
            line == other.line
        end

        def == other
          path == other.path &&
            line == other.line
        end

        def hash
          id.hash ^ location.path.hash ^ location.line.hash
        end

        def to_grpc
          Google::Apis::ClouddebuggerV2::Breakpoint.new.tap do |b|
            b.id = @id
            # b.action = @action
            b.location = @location.to_grpc
            # b.condition = @condition
            b.expressions = @expressions
            b.is_final_state = @is_final_state
            this_stack_frames = @stack_frames || []
            b.stack_frames = this_stack_frames.map { |sf| sf.to_grpc }
            this_evaluated_expressions = @evaluated_expressions || []
            b.evaluated_expressions = this_evaluated_expressions.map { |exp| exp.to_grpc}
            #b.variable_table = @variable_table
          end
        end
      end
    end
  end
end
