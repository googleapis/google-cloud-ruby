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

        # TODO: Implement logpoint
        # attr_accessor :action

        attr_accessor :location

        attr_accessor :condition

        attr_accessor :is_final_state

        attr_accessor :expressions

        attr_accessor :evaluated_expressions

        attr_accessor :create_time

        attr_accessor :final_time

        attr_accessor :user_email

        attr_accessor :status

        # TODO: Implement variable table
        # attr_accessor :variable_table

        attr_accessor :labels

        attr_accessor :stack_frames

        def initialize id = nil, path = nil, line = nil
          super()

          @id = id
          # @action = :capture
          @location = SourceLocation.new.tap do |sl|
            sl.path = path
            sl.line = line.to_i
          end
          @expressions = []
          @evaluated_expressions = []
          @stack_frames = []
          @labels = {}
        end

        ##
        # @private New Google::Cloud::Debugger::Breakpoint
        # from a Google::Devtools::Clouddebugger::V2::Breakpoint object.
        def self.from_grpc grpc
          return new if grpc.nil?
          new.tap do |b|
            b.id = grpc.id
            b.location = Breakpoint::SourceLocation.from_grpc grpc.location
            b.condition = grpc.condition
            b.is_final_state = grpc.is_final_state
            b.expressions = grpc.expressions.to_a
            b.evaluated_expressions =
              Breakpoint::Variable.from_grpc_list grpc.evaluated_expressions
            b.create_time = timestamp_from_grpc grpc.create_time
            b.final_time = timestamp_from_grpc grpc.final_time
            b.user_email = grpc.user_email
            b.status = grpc.status
            b.labels = hashify_labels grpc.labels
            b.stack_frames = stack_frames_from_grpc grpc
          end
        end

        ##
        # @private Extract array of stack_frame from grpc
        def self.stack_frames_from_grpc grpc
          return nil if grpc.stack_frames.nil?
          grpc.stack_frames.map { |sf| Breakpoint::StackFrame.from_grpc sf }
        end

        ##
        # @private Get a Time object from a Google::Protobuf::Timestamp object.
        def self.timestamp_from_grpc grpc_timestamp
          return nil if grpc_timestamp.nil?
          Time.at grpc_timestamp.seconds, Rational(grpc_timestamp.nanos, 1000)
        end

        def self.hashify_labels grpc_labels
          if grpc_labels.respond_to? :to_h
            grpc_labels.to_h
          else
            # Enumerable doesn't have to_h on ruby 2.0...
            Hash[grpc_labels.to_a]
          end
        end

        private_class_method :stack_frames_from_grpc, :timestamp_from_grpc,
                             :hashify_labels

        def complete
          synchronize do
            return if complete?

            @is_final_state = true
            @final_time = Time.now
          end
        end

        alias_method :complete?, :is_final_state

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
          return true if condition.nil? || condition.empty?
          begin
            Evaluator.eval_condition binding, condition
          rescue
            set_error_state "Unable to evaluate condition",
                            refers_to: :BREAKPOINT_CONDITION
            false
          end
        end

        def eval_call_stack call_stack_bindings
          synchronize do
            top_frame_binding = call_stack_bindings[0]

            # Abort evaluation if breakpoint condition isn't met
            return false unless check_condition top_frame_binding

            begin
              @stack_frames = Evaluator.eval_call_stack call_stack_bindings
              unless expressions.empty?
                @evaluated_expressions =
                  Evaluator.eval_expressions top_frame_binding, @expressions
              end
            rescue
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

        def hash
          id.hash ^ path.hash ^ line.hash
        end

        ##
        # @private Exports the Breakpoint to a
        # Google::Devtools::Clouddebugger::V2::Breakpoint object.
        def to_grpc
          Google::Devtools::Clouddebugger::V2::Breakpoint.new(
            id: id.to_s,
            location: location.to_grpc,
            condition: condition.to_s,
            expressions: expressions || [],
            is_final_state: is_final_state,
            create_time: timestamp_to_grpc(create_time),
            final_time: timestamp_to_grpc(final_time),
            user_email: user_email,
            stack_frames: stack_frames_to_grpc,
            evaluated_expressions: evaluated_expressions_to_grpc,
            status: status,
            labels: labels_to_grpc
          )
        end

        ##
        # Set breakoint to an eror state, which initializes the @status instance
        # variable with the error message. Also mark this breakpoint as
        # completed if is_final is true.
        #
        # @param [String] message The error message
        # @param [Google::Devtools::Clouddebugger::V2::StatusMessage::Reference]
        #   refers_to Enum that specifies what the error refers to. Defaults
        #   :UNSPECIFIED.
        # @param [bool] is_final Marks the breakpoint as final if true.
        #   Defaults true.
        #
        # @return [Google::Devtools::Clouddebugger::V2::StatusMessage] The grpc
        #   StatusMessage object, which describes the breakpoint's error state.
        def set_error_state message, refers_to: :UNSPECIFIED,
                                     is_final: true
          description = Google::Devtools::Clouddebugger::V2::FormatMessage.new(
            format: message
          )
          @status = Google::Devtools::Clouddebugger::V2::StatusMessage.new(
            is_error: true,
            refers_to: refers_to,
            description: description
          )

          complete if is_final

          @status
        end

        private

        ##
        # @private Formats the labels so they can be saved to a
        # Google::Devtools::Clouddebugger::V2::Breakpoint object.
        def labels_to_grpc
          # Coerce symbols to strings
          Hash[labels.map do |k, v|
            [String(k), String(v)]
          end]
        end

        ##
        # @private Exports the Breakpoint stack_frames to an array of
        # Google::Devtools::Clouddebugger::V2::StackFrame objects.
        def stack_frames_to_grpc
          return [] if stack_frames.nil?
          stack_frames.map { |sf| sf.to_grpc  }
        end

        ##
        # @private Exports the Breakpoint stack_frames to an array of
        # Google::Devtools::Clouddebugger::V2::StackFrame objects.
        def evaluated_expressions_to_grpc
          return [] if evaluated_expressions.nil?
          evaluated_expressions.map { |var| var.to_grpc }
        end

        ##
        # @private Formats the timestamp as a Google::Protobuf::Timestamp
        # object.
        def timestamp_to_grpc time
          return nil if time.nil?
          # TODO: ArgumentError if timestamp is not a Time object?
          Google::Protobuf::Timestamp.new(
            seconds: time.to_i,
            nanos: time.nsec
          )
        end
      end
    end
  end
end
