# Copyright 2017, Google Inc. All rights reserved.
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

module Google
  module Devtools
    module Clouddebugger
      module V2
        # Represents a message with parameters.
        # @!attribute [rw] format
        #   @return [String]
        #     Format template for the message. The +format+ uses placeholders +$0+,
        #     +$1+, etc. to reference parameters. +$$+ can be used to denote the +$+
        #     character.
        #
        #     Examples:
        #
        #     * +Failed to load '$0' which helps debug $1 the first time it
        #       is loaded.  Again, $0 is very important.+
        #     * +Please pay $$10 to use $0 instead of $1.+
        # @!attribute [rw] parameters
        #   @return [Array<String>]
        #     Optional parameters to be embedded into the message.
        class FormatMessage; end

        # Represents a contextual status message.
        # The message can indicate an error or informational status, and refer to
        # specific parts of the containing object.
        # For example, the +Breakpoint.status+ field can indicate an error referring
        # to the +BREAKPOINT_SOURCE_LOCATION+ with the message +Location not found+.
        # @!attribute [rw] is_error
        #   @return [true, false]
        #     Distinguishes errors from informational messages.
        # @!attribute [rw] refers_to
        #   @return [Google::Devtools::Clouddebugger::V2::StatusMessage::Reference]
        #     Reference to which the message applies.
        # @!attribute [rw] description
        #   @return [Google::Devtools::Clouddebugger::V2::FormatMessage]
        #     Status message text.
        class StatusMessage
          # Enumerates references to which the message applies.
          module Reference
            # Status doesn't refer to any particular input.
            UNSPECIFIED = 0

            # Status applies to the breakpoint and is related to its location.
            BREAKPOINT_SOURCE_LOCATION = 3

            # Status applies to the breakpoint and is related to its condition.
            BREAKPOINT_CONDITION = 4

            # Status applies to the breakpoint and is related to its expressions.
            BREAKPOINT_EXPRESSION = 7

            # Status applies to the breakpoint and is related to its age.
            BREAKPOINT_AGE = 8

            # Status applies to the entire variable.
            VARIABLE_NAME = 5

            # Status applies to variable value (variable name is valid).
            VARIABLE_VALUE = 6
          end
        end

        # Represents a location in the source code.
        # @!attribute [rw] path
        #   @return [String]
        #     Path to the source file within the source context of the target binary.
        # @!attribute [rw] line
        #   @return [Integer]
        #     Line inside the file. The first line in the file has the value +1+.
        class SourceLocation; end

        # Represents a variable or an argument possibly of a compound object type.
        # Note how the following variables are represented:
        #
        # 1) A simple variable:
        #
        #     int x = 5
        #
        #     { name: "x", value: "5", type: "int" }  // Captured variable
        #
        # 2) A compound object:
        #
        #     struct T {
        #         int m1;
        #         int m2;
        #     };
        #     T x = { 3, 7 };
        #
        #     {  // Captured variable
        #         name: "x",
        #         type: "T",
        #         members { name: "m1", value: "3", type: "int" },
        #         members { name: "m2", value: "7", type: "int" }
        #     }
        #
        # 3) A pointer where the pointee was captured:
        #
        #     T x = { 3, 7 };
        #     T* p = &x;
        #
        #     {   // Captured variable
        #         name: "p",
        #         type: "T*",
        #         value: "0x00500500",
        #         members { name: "m1", value: "3", type: "int" },
        #         members { name: "m2", value: "7", type: "int" }
        #     }
        #
        # 4) A pointer where the pointee was not captured:
        #
        #     T* p = new T;
        #
        #     {   // Captured variable
        #         name: "p",
        #         type: "T*",
        #         value: "0x00400400"
        #         status { is_error: true, description { format: "unavailable" } }
        #     }
        #
        # The status should describe the reason for the missing value,
        # such as +<optimized out>+, +<inaccessible>+, +<pointers limit reached>+.
        #
        # Note that a null pointer should not have members.
        #
        # 5) An unnamed value:
        #
        #     int* p = new int(7);
        #
        #     {   // Captured variable
        #         name: "p",
        #         value: "0x00500500",
        #         type: "int*",
        #         members { value: "7", type: "int" } }
        #
        # 6) An unnamed pointer where the pointee was not captured:
        #
        #     int* p = new int(7);
        #     int** pp = &p;
        #
        #     {  // Captured variable
        #         name: "pp",
        #         value: "0x00500500",
        #         type: "int**",
        #         members {
        #             value: "0x00400400",
        #             type: "int*"
        #             status {
        #                 is_error: true,
        #                 description: { format: "unavailable" } }
        #             }
        #         }
        #     }
        #
        # To optimize computation, memory and network traffic, variables that
        # repeat in the output multiple times can be stored once in a shared
        # variable table and be referenced using the +var_table_index+ field.  The
        # variables stored in the shared table are nameless and are essentially
        # a partition of the complete variable. To reconstruct the complete
        # variable, merge the referencing variable with the referenced variable.
        #
        # When using the shared variable table, the following variables:
        #
        #     T x = { 3, 7 };
        #     T* p = &x;
        #     T& r = x;
        #
        #     { name: "x", var_table_index: 3, type: "T" }  // Captured variables
        #     { name: "p", value "0x00500500", type="T*", var_table_index: 3 }
        #     { name: "r", type="T&", var_table_index: 3 }
        #
        #     {  // Shared variable table entry #3:
        #         members { name: "m1", value: "3", type: "int" },
        #         members { name: "m2", value: "7", type: "int" }
        #     }
        #
        # Note that the pointer address is stored with the referencing variable
        # and not with the referenced variable. This allows the referenced variable
        # to be shared between pointers and references.
        #
        # The type field is optional. The debugger agent may or may not support it.
        # @!attribute [rw] name
        #   @return [String]
        #     Name of the variable, if any.
        # @!attribute [rw] value
        #   @return [String]
        #     Simple value of the variable.
        # @!attribute [rw] type
        #   @return [String]
        #     Variable type (e.g. +MyClass+). If the variable is split with
        #     +var_table_index+, +type+ goes next to +value+. The interpretation of
        #     a type is agent specific. It is recommended to include the dynamic type
        #     rather than a static type of an object.
        # @!attribute [rw] members
        #   @return [Array<Google::Devtools::Clouddebugger::V2::Variable>]
        #     Members contained or pointed to by the variable.
        # @!attribute [rw] var_table_index
        #   @return [Google::Protobuf::Int32Value]
        #     Reference to a variable in the shared variable table. More than
        #     one variable can reference the same variable in the table. The
        #     +var_table_index+ field is an index into +variable_table+ in Breakpoint.
        # @!attribute [rw] status
        #   @return [Google::Devtools::Clouddebugger::V2::StatusMessage]
        #     Status associated with the variable. This field will usually stay
        #     unset. A status of a single variable only applies to that variable or
        #     expression. The rest of breakpoint data still remains valid. Variables
        #     might be reported in error state even when breakpoint is not in final
        #     state.
        #
        #     The message may refer to variable name with +refers_to+ set to
        #     +VARIABLE_NAME+. Alternatively +refers_to+ will be set to +VARIABLE_VALUE+.
        #     In either case variable value and members will be unset.
        #
        #     Example of error message applied to name: +Invalid expression syntax+.
        #
        #     Example of information message applied to value: +Not captured+.
        #
        #     Examples of error message applied to value:
        #
        #     * +Malformed string+,
        #     * +Field f not found in class C+
        #     * +Null pointer dereference+
        class Variable; end

        # Represents a stack frame context.
        # @!attribute [rw] function
        #   @return [String]
        #     Demangled function name at the call site.
        # @!attribute [rw] location
        #   @return [Google::Devtools::Clouddebugger::V2::SourceLocation]
        #     Source location of the call site.
        # @!attribute [rw] arguments
        #   @return [Array<Google::Devtools::Clouddebugger::V2::Variable>]
        #     Set of arguments passed to this function.
        #     Note that this might not be populated for all stack frames.
        # @!attribute [rw] locals
        #   @return [Array<Google::Devtools::Clouddebugger::V2::Variable>]
        #     Set of local variables at the stack frame location.
        #     Note that this might not be populated for all stack frames.
        class StackFrame; end

        # Represents the breakpoint specification, status and results.
        # @!attribute [rw] id
        #   @return [String]
        #     Breakpoint identifier, unique in the scope of the debuggee.
        # @!attribute [rw] action
        #   @return [Google::Devtools::Clouddebugger::V2::Breakpoint::Action]
        #     Action that the agent should perform when the code at the
        #     breakpoint location is hit.
        # @!attribute [rw] location
        #   @return [Google::Devtools::Clouddebugger::V2::SourceLocation]
        #     Breakpoint source location.
        # @!attribute [rw] condition
        #   @return [String]
        #     Condition that triggers the breakpoint.
        #     The condition is a compound boolean expression composed using expressions
        #     in a programming language at the source location.
        # @!attribute [rw] expressions
        #   @return [Array<String>]
        #     List of read-only expressions to evaluate at the breakpoint location.
        #     The expressions are composed using expressions in the programming language
        #     at the source location. If the breakpoint action is +LOG+, the evaluated
        #     expressions are included in log statements.
        # @!attribute [rw] log_message_format
        #   @return [String]
        #     Only relevant when action is +LOG+. Defines the message to log when
        #     the breakpoint hits. The message may include parameter placeholders +$0+,
        #     +$1+, etc. These placeholders are replaced with the evaluated value
        #     of the appropriate expression. Expressions not referenced in
        #     +log_message_format+ are not logged.
        #
        #     Example: +Message received, id = $0, count = $1+ with
        #     +expressions+ = +[ message.id, message.count ]+.
        # @!attribute [rw] log_level
        #   @return [Google::Devtools::Clouddebugger::V2::Breakpoint::LogLevel]
        #     Indicates the severity of the log. Only relevant when action is +LOG+.
        # @!attribute [rw] is_final_state
        #   @return [true, false]
        #     When true, indicates that this is a final result and the
        #     breakpoint state will not change from here on.
        # @!attribute [rw] create_time
        #   @return [Google::Protobuf::Timestamp]
        #     Time this breakpoint was created by the server in seconds resolution.
        # @!attribute [rw] final_time
        #   @return [Google::Protobuf::Timestamp]
        #     Time this breakpoint was finalized as seen by the server in seconds
        #     resolution.
        # @!attribute [rw] user_email
        #   @return [String]
        #     E-mail address of the user that created this breakpoint
        # @!attribute [rw] status
        #   @return [Google::Devtools::Clouddebugger::V2::StatusMessage]
        #     Breakpoint status.
        #
        #     The status includes an error flag and a human readable message.
        #     This field is usually unset. The message can be either
        #     informational or an error message. Regardless, clients should always
        #     display the text message back to the user.
        #
        #     Error status indicates complete failure of the breakpoint.
        #
        #     Example (non-final state): +Still loading symbols...+
        #
        #     Examples (final state):
        #
        #     * +Invalid line number+ referring to location
        #     * +Field f not found in class C+ referring to condition
        # @!attribute [rw] stack_frames
        #   @return [Array<Google::Devtools::Clouddebugger::V2::StackFrame>]
        #     The stack at breakpoint time.
        # @!attribute [rw] evaluated_expressions
        #   @return [Array<Google::Devtools::Clouddebugger::V2::Variable>]
        #     Values of evaluated expressions at breakpoint time.
        #     The evaluated expressions appear in exactly the same order they
        #     are listed in the +expressions+ field.
        #     The +name+ field holds the original expression text, the +value+ or
        #     +members+ field holds the result of the evaluated expression.
        #     If the expression cannot be evaluated, the +status+ inside the +Variable+
        #     will indicate an error and contain the error text.
        # @!attribute [rw] variable_table
        #   @return [Array<Google::Devtools::Clouddebugger::V2::Variable>]
        #     The +variable_table+ exists to aid with computation, memory and network
        #     traffic optimization.  It enables storing a variable once and reference
        #     it from multiple variables, including variables stored in the
        #     +variable_table+ itself.
        #     For example, the same +this+ object, which may appear at many levels of
        #     the stack, can have all of its data stored once in this table.  The
        #     stack frame variables then would hold only a reference to it.
        #
        #     The variable +var_table_index+ field is an index into this repeated field.
        #     The stored objects are nameless and get their name from the referencing
        #     variable. The effective variable is a merge of the referencing variable
        #     and the referenced variable.
        # @!attribute [rw] labels
        #   @return [Hash{String => String}]
        #     A set of custom breakpoint properties, populated by the agent, to be
        #     displayed to the user.
        class Breakpoint
          # Actions that can be taken when a breakpoint hits.
          # Agents should reject breakpoints with unsupported or unknown action values.
          module Action
            # Capture stack frame and variables and update the breakpoint.
            # The data is only captured once. After that the breakpoint is set
            # in a final state.
            CAPTURE = 0

            # Log each breakpoint hit. The breakpoint remains active until
            # deleted or expired.
            LOG = 1
          end

          # Log severity levels.
          module LogLevel
            # Information log message.
            INFO = 0

            # Warning log message.
            WARNING = 1

            # Error log message.
            ERROR = 2
          end
        end

        # Represents the debugged application. The application may include one or more
        # replicated processes executing the same code. Each of these processes is
        # attached with a debugger agent, carrying out the debugging commands.
        # Agents attached to the same debuggee identify themselves as such by using
        # exactly the same Debuggee message value when registering.
        # @!attribute [rw] id
        #   @return [String]
        #     Unique identifier for the debuggee generated by the controller service.
        # @!attribute [rw] project
        #   @return [String]
        #     Project the debuggee is associated with.
        #     Use project number or id when registering a Google Cloud Platform project.
        # @!attribute [rw] uniquifier
        #   @return [String]
        #     Uniquifier to further distiguish the application.
        #     It is possible that different applications might have identical values in
        #     the debuggee message, thus, incorrectly identified as a single application
        #     by the Controller service. This field adds salt to further distiguish the
        #     application. Agents should consider seeding this field with value that
        #     identifies the code, binary, configuration and environment.
        # @!attribute [rw] description
        #   @return [String]
        #     Human readable description of the debuggee.
        #     Including a human-readable project name, environment name and version
        #     information is recommended.
        # @!attribute [rw] is_inactive
        #   @return [true, false]
        #     If set to +true+, indicates that Controller service does not detect any
        #     activity from the debuggee agents and the application is possibly stopped.
        # @!attribute [rw] agent_version
        #   @return [String]
        #     Version ID of the agent.
        #     Schema: +domain/language-platform/vmajor.minor+ (for example
        #     +google.com/java-gcp/v1.1+).
        # @!attribute [rw] is_disabled
        #   @return [true, false]
        #     If set to +true+, indicates that the agent should disable itself and
        #     detach from the debuggee.
        # @!attribute [rw] status
        #   @return [Google::Devtools::Clouddebugger::V2::StatusMessage]
        #     Human readable message to be displayed to the user about this debuggee.
        #     Absence of this field indicates no status. The message can be either
        #     informational or an error status.
        # @!attribute [rw] source_contexts
        #   @return [Array<Google::Devtools::Source::V1::SourceContext>]
        #     References to the locations and revisions of the source code used in the
        #     deployed application.
        # @!attribute [rw] ext_source_contexts
        #   @return [Array<Google::Devtools::Source::V1::ExtendedSourceContext>]
        #     References to the locations and revisions of the source code used in the
        #     deployed application.
        #
        #     NOTE: this field is experimental and can be ignored.
        # @!attribute [rw] labels
        #   @return [Hash{String => String}]
        #     A set of custom debuggee properties, populated by the agent, to be
        #     displayed to the user.
        class Debuggee; end
      end
    end
  end
end