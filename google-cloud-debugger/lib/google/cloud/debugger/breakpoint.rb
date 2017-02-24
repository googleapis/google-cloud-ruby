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


require "time"
require "google/cloud/debugger/breakpoint/evaluator"
require "google/cloud/debugger/breakpoint/source_location"
require "google/cloud/debugger/breakpoint/stack_frame"
require "google/cloud/debugger/breakpoint/variable"

module Google
  module Cloud
    module Debugger
      class Breakpoint
        include MonitorMixin

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
          super()

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
          @expressions = []
          @evaluated_expressions = []
          @completed = false
          @stack_frames = []
        end

        def add_expression expression
          @expressions << expression
          expression
        end

        # def path_hit? path
        #   synchronize do
        #     location.path.match(path) || path.match(location.path)
        #   end
        # end
        #
        # def line_hit? path, line
        #   synchronize do
        #     path_hit?(path) && location.line == line
        #   end
        # end

        def complete
          synchronize do
            @is_final_state = true
            @final_time = Time.now.utc.iso8601
            @completed = true
          end
        end

        alias_method :complete?, :completed

        def path
          synchronize do
            location.nil? ? nil : location.path
          end
        end

        def line
          synchronize do
            location.nil? ? nil : location.line
          end
        end

        def check_condition binding
          return true if condition.nil?
          Evaluator.eval_condition binding, condition
        end

        def eval_call_stack call_stack_bindings
          synchronize do
            top_frame_binding = call_stack_bindings[0]
            begin
              # Abort evaluation if breakpoint condition isn't met
              return false unless check_condition top_frame_binding

              @stack_frames = Evaluator.eval_call_stack call_stack_bindings
              if @expressions
                @evaluated_expressions =
                  Evaluator.eval_expressions top_frame_binding, @expressions
              end
            rescue => e
              # puts e.message
              # puts e.backtrace
              # TODO set breakpoint into error state
              return false
            end

            complete
          end
          true
        end

        def eql? other
          id == other.id &&
            path == other.path &&
            line == other.line
        end

        # def == other
        #   path == other.path &&
        #     line == other.line
        # end

        def hash
          id.hash ^ path.hash ^ line.hash
        end

        def to_grpc
          Google::Apis::ClouddebuggerV2::Breakpoint.new.tap do |b|
            b.id = @id
            b.action = @action
            b.location = @location.to_grpc
            b.condition = @condition
            b.expressions = @expressions
            b.is_final_state = @is_final_state
            this_stack_frames = @stack_frames || []
            b.stack_frames = this_stack_frames.map { |sf| sf.to_grpc }
            this_evaluated_expressions = @evaluated_expressions || []
            b.evaluated_expressions = this_evaluated_expressions.map { |exp| exp.to_grpc}
            #b.variable_table = @variable_table
          end
        end

        def self.from_grpc grpc
          new.tap do |b|
            b.id = grpc.id
            b.action = grpc.action
            b.location = Breakpoint::SourceLocation.from_grpc grpc.location
            b.condition = grpc.condition
            b.is_final_state = grpc.is_final_state
            b.expressions = grpc.expressions
            b.evaluated_expressions = grpc.evaluated_expressions
            b.create_time = grpc.create_time
            b.status = grpc.status
            stack_frames = grpc.stack_frames || []
            b.stack_frames = stack_frames.map { |sf|
              Breakpoint::StackFrame.from_grpc sf }
          end
        end
      end
    end
  end
end
