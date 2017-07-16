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
require "google/cloud/debugger/breakpoint/variable_table"

module Google
  module Cloud
    module Debugger
      class Breakpoint
        include MonitorMixin

        ##
        # Breakpoint identifier, unique in the scope of the debuggee.
        attr_accessor :id

        ##
        # Action to take when a breakpoint is hit. Either :CAPTURE or :LOG.
        # @return [Symbol]
        attr_accessor :action

        ##
        # Only relevant when action is LOG. Defines the message to log when the
        # breakpoint hits. The message may include parameter placeholders $0,
        # $1, etc. These placeholders are replaced with the evaluated value of
        # the appropriate expression. Expressions not referenced in
        # logMessageFormat are not logged.
        attr_accessor :log_message_format

        ##
        # Indicates the severity of the log. Only relevant when action is LOG.
        attr_accessor :log_level

        ##
        # The evaluated log message when action is LOG.
        attr_accessor :evaluated_log_message

        ##
        # Breakpoint source location.
        # @return [Google::Cloud::Debugger::Breakpoint::SourceLocation]
        attr_accessor :location

        ##
        # Condition that triggers the breakpoint. The condition is a compound
        # boolean expression composed using expressions in a programming
        # language at the source location.
        attr_accessor :condition

        ##
        # When true, indicates that this is a final result and the breakpoint
        # state will not change from here on.
        # @return [Boolean]
        attr_accessor :is_final_state

        ##
        # List of read-only expressions to evaluate at the breakpoint location.
        # The expressions are composed using expressions in the programming
        # language at the source location. If the breakpoint action is LOG, the
        # evaluated expressions are included in log statements.
        # @return [Array<String>]
        attr_accessor :expressions

        ##
        # Values of evaluated expressions at breakpoint time. The evaluated
        # expressions appear in exactly the same order they are listed in the
        # expressions field. The name field holds the original expression text,
        # the value or members field holds the result of the evaluated
        # expression. If the expression cannot be evaluated, the status inside
        # the Variable will indicate an error and contain the error text.
        # @return [Array<Google::Cloud::Debugger::Breakpoint::Variable>]
        attr_accessor :evaluated_expressions

        ##
        # Time this breakpoint was created by the server in seconds resolution.
        # @return [Time]
        attr_accessor :create_time

        ##
        # Time this breakpoint was finalized as seen by the server in seconds
        # resolution.
        # @return [Time]
        attr_accessor :final_time

        ##
        # E-mail address of the user that created this breakpoint
        attr_accessor :user_email

        ##
        # Breakpoint status.
        #
        # The status includes an error flag and a human readable message. This
        # field is usually unset. The message can be either informational or an
        # error message. Regardless, clients should always display the text
        # message back to the user.
        #
        #  Error status indicates complete failure of the breakpoint.
        attr_accessor :status

        ##
        # The variable_table exists to aid with computation, memory and network
        # traffic optimization. It enables storing a variable once and reference
        # it from multiple variables, including variables stored in the
        # variable_table itself. For example, the same this object, which may
        # appear at many levels of the stack, can have all of its data stored
        # once in this table. The stack frame variables then would hold only a
        # reference to it.
        #
        # The variable var_table_index field is an index into this repeated
        # field. The stored objects are nameless and get their name from the
        # referencing variable. The effective variable is a merge of the
        # referencing variable and the referenced variable.
        attr_accessor :variable_table

        ##
        # A set of custom breakpoint properties, populated by the agent, to be
        # displayed to the user.
        # @return [Hash<String, String>]
        attr_accessor :labels

        ##
        # The stack at breakpoint time.
        # @return [Array<Google::Cloud::Debugger::Breakpoint::StackFrame>]
        attr_accessor :stack_frames

        ##
        # @private Construct a new instance of Breakpoint.
        def initialize id = nil, path = nil, line = nil
          super()

          @id = id
          @action = :CAPTURE
          @location = SourceLocation.new.tap do |sl|
            sl.path = path
            sl.line = line.to_i
          end
          @expressions = []
          @evaluated_expressions = []
          @stack_frames = []
          @labels = {}
          @variable_table = []
        end

        ##
        # @private New Google::Cloud::Debugger::Breakpoint
        # from a Google::Devtools::Clouddebugger::V2::Breakpoint object.
        def self.from_grpc grpc
          return new if grpc.nil?

          breakpoint = grpc.action == :LOG ? Logpoint.new : Snappoint.new
          breakpoint.tap do |b|
            b.id = grpc.id
            b.action = grpc.action
            b.condition = grpc.condition
            b.expressions = grpc.expressions.to_a
            b.labels = hashify_labels grpc.labels
            b.log_message_format = grpc.log_message_format
            b.log_level = grpc.log_level
            b.is_final_state = grpc.is_final_state
            b.status = grpc.status
            b.user_email = grpc.user_email

            assign_complex_grpc_fields grpc, b
          end
        end

        ##
        # @private Helper method that helps extracting complex fields from
        # grpc struct into a breakpoint.
        def self.assign_complex_grpc_fields grpc, breakpoint
          breakpoint.create_time = timestamp_from_grpc grpc.create_time
          breakpoint.evaluated_expressions =
            Breakpoint::Variable.from_grpc_list grpc.evaluated_expressions
          breakpoint.final_time = timestamp_from_grpc grpc.final_time
          breakpoint.location =
            Breakpoint::SourceLocation.from_grpc grpc.location
          breakpoint.stack_frames = stack_frames_from_grpc grpc
          breakpoint.variable_table =
            Breakpoint::VariableTable.from_grpc grpc.variable_table
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

        ##
        # @private Helper method to convert a gRPC map to Ruby Hash
        def self.hashify_labels grpc_labels
          if grpc_labels.respond_to? :to_h
            grpc_labels.to_h
          else
            # Enumerable doesn't have to_h on ruby 2.0...
            Hash[grpc_labels.to_a]
          end
        end

        private_class_method :stack_frames_from_grpc,
                             :timestamp_from_grpc,
                             :hashify_labels,
                             :assign_complex_grpc_fields

        ##
        # Marks a breakpoint as complete if this breakpoint isn't completed
        # already. Set @is_final_state to true and set @final_time.
        def complete
          synchronize do
            return if complete?

            @is_final_state = true
            @final_time = Time.now
          end
        end

        alias_method :complete?, :is_final_state

        ##
        # Get the file path of this breakpoint
        # @example
        #   breakpoint = Breakpoint.new nil, "path/to/file.rb"
        #   breakpoint.path #=> "path/to/file.rb"
        # @return [String] The file path for this breakpoint
        def path
          location.nil? ? nil : location.path
        end

        ##
        # Get the line number of this breakpoint
        # @example
        #   breakpoint = Breakpoint.new nil, "path/to/file.rb", 11
        #   breakpoint.line #=> 11
        # @return [Integer] The line number for this breakpoint
        def line
          location.nil? ? nil : location.line
        end

        ##
        # Evaluate the breakpoint's condition expression against a given binding
        # object. Returns true if the condition expression evalutes to true;
        # false if error happens or the expression evaluates to false.
        #
        # @param [Binding] binding A Ruby Binding object
        # @return [Boolean] True if condition evalutes to true, false if
        #   condition evaluates to false or error raised during evaluation.
        #
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

        ##
        # Check if two breakpoints are equal to each other
        def eql? other
          id == other.id &&
            path == other.path &&
            line == other.line
        end

        ##
        # @private Override default hashing function
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
            labels: labels_to_grpc,
            variable_table: variable_table.to_grpc
          )
        end

        ##
        # Set breakpoint to an error state, which initializes the @status
        # instance variable with the error message. Also mark this breakpoint as
        # completed if is_final is true.
        #
        # @param [String] message The error message
        # @param [Google::Devtools::Clouddebugger::V2::StatusMessage::Reference]
        #   refers_to Enum that specifies what the error refers to. Defaults
        #   :UNSPECIFIED.
        # @param [Boolean] is_final Marks the breakpoint as final if true.
        #   Defaults true.
        #
        # @return [Google::Devtools::Clouddebugger::V2::StatusMessage] The grpc
        #   StatusMessage object, which describes the breakpoint's error state.
        def set_error_state message, refers_to: :UNSPECIFIED, is_final: true
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
          stack_frames.nil? ? [] : stack_frames.map(&:to_grpc)
        end

        ##
        # @private Exports the Breakpoint stack_frames to an array of
        # Google::Devtools::Clouddebugger::V2::Variable objects.
        def evaluated_expressions_to_grpc
          evaluated_expressions.nil? ? [] : evaluated_expressions.map(&:to_grpc)
        end

        ##
        # @private Formats the timestamp as a Google::Protobuf::Timestamp
        # object.
        def timestamp_to_grpc time
          return nil if time.nil?
          Google::Protobuf::Timestamp.new(
            seconds: time.to_i,
            nanos: time.nsec
          )
        end
      end
    end
  end
end
