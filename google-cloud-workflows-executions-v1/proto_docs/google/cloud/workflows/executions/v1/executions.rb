# frozen_string_literal: true

# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Auto-generated by gapic-generator-ruby. DO NOT EDIT!


module Google
  module Cloud
    module Workflows
      module Executions
        module V1
          # A running instance of a
          # [Workflow](/workflows/docs/reference/rest/v1/projects.locations.workflows).
          # @!attribute [r] name
          #   @return [::String]
          #     Output only. The resource name of the execution.
          #     Format:
          #     projects/\\{project}/locations/\\{location}/workflows/\\{workflow}/executions/\\{execution}
          # @!attribute [r] start_time
          #   @return [::Google::Protobuf::Timestamp]
          #     Output only. Marks the beginning of execution.
          # @!attribute [r] end_time
          #   @return [::Google::Protobuf::Timestamp]
          #     Output only. Marks the end of execution, successful or not.
          # @!attribute [r] duration
          #   @return [::Google::Protobuf::Duration]
          #     Output only. Measures the duration of the execution.
          # @!attribute [r] state
          #   @return [::Google::Cloud::Workflows::Executions::V1::Execution::State]
          #     Output only. Current state of the execution.
          # @!attribute [rw] argument
          #   @return [::String]
          #     Input parameters of the execution represented as a JSON string.
          #     The size limit is 32KB.
          #
          #     *Note*: If you are using the REST API directly to run your workflow, you
          #     must escape any JSON string value of `argument`. Example:
          #     `'{"argument":"{\"firstName\":\"FIRST\",\"lastName\":\"LAST\"}"}'`
          # @!attribute [r] result
          #   @return [::String]
          #     Output only. Output of the execution represented as a JSON string. The
          #     value can only be present if the execution's state is `SUCCEEDED`.
          # @!attribute [r] error
          #   @return [::Google::Cloud::Workflows::Executions::V1::Execution::Error]
          #     Output only. The error which caused the execution to finish prematurely.
          #     The value is only present if the execution's state is `FAILED`
          #     or `CANCELLED`.
          # @!attribute [r] workflow_revision_id
          #   @return [::String]
          #     Output only. Revision of the workflow this execution is using.
          # @!attribute [rw] call_log_level
          #   @return [::Google::Cloud::Workflows::Executions::V1::Execution::CallLogLevel]
          #     The call logging level associated to this execution.
          # @!attribute [r] status
          #   @return [::Google::Cloud::Workflows::Executions::V1::Execution::Status]
          #     Output only. Status tracks the current steps and progress data of this
          #     execution.
          # @!attribute [rw] labels
          #   @return [::Google::Protobuf::Map{::String => ::String}]
          #     Labels associated with this execution.
          #     Labels can contain at most 64 entries. Keys and values can be no longer
          #     than 63 characters and can only contain lowercase letters, numeric
          #     characters, underscores, and dashes. Label keys must start with a letter.
          #     International characters are allowed.
          #     By default, labels are inherited from the workflow but are overridden by
          #     any labels associated with the execution.
          # @!attribute [r] state_error
          #   @return [::Google::Cloud::Workflows::Executions::V1::Execution::StateError]
          #     Output only. Error regarding the state of the Execution resource. For
          #     example, this field will have error details if the execution data is
          #     unavailable due to revoked KMS key permissions.
          class Execution
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods

            # A single stack element (frame) where an error occurred.
            # @!attribute [rw] step
            #   @return [::String]
            #     The step the error occurred at.
            # @!attribute [rw] routine
            #   @return [::String]
            #     The routine where the error occurred.
            # @!attribute [rw] position
            #   @return [::Google::Cloud::Workflows::Executions::V1::Execution::StackTraceElement::Position]
            #     The source position information of the stack trace element.
            class StackTraceElement
              include ::Google::Protobuf::MessageExts
              extend ::Google::Protobuf::MessageExts::ClassMethods

              # Position contains source position information about the stack trace
              # element such as line number, column number and length of the code block
              # in bytes.
              # @!attribute [rw] line
              #   @return [::Integer]
              #     The source code line number the current instruction was generated from.
              # @!attribute [rw] column
              #   @return [::Integer]
              #     The source code column position (of the line) the current instruction
              #     was generated from.
              # @!attribute [rw] length
              #   @return [::Integer]
              #     The number of bytes of source code making up this stack trace element.
              class Position
                include ::Google::Protobuf::MessageExts
                extend ::Google::Protobuf::MessageExts::ClassMethods
              end
            end

            # A collection of stack elements (frames) where an error occurred.
            # @!attribute [rw] elements
            #   @return [::Array<::Google::Cloud::Workflows::Executions::V1::Execution::StackTraceElement>]
            #     An array of stack elements.
            class StackTrace
              include ::Google::Protobuf::MessageExts
              extend ::Google::Protobuf::MessageExts::ClassMethods
            end

            # Error describes why the execution was abnormally terminated.
            # @!attribute [rw] payload
            #   @return [::String]
            #     Error message and data returned represented as a JSON string.
            # @!attribute [rw] context
            #   @return [::String]
            #     Human-readable stack trace string.
            # @!attribute [rw] stack_trace
            #   @return [::Google::Cloud::Workflows::Executions::V1::Execution::StackTrace]
            #     Stack trace with detailed information of where error was generated.
            class Error
              include ::Google::Protobuf::MessageExts
              extend ::Google::Protobuf::MessageExts::ClassMethods
            end

            # Represents the current status of this execution.
            # @!attribute [rw] current_steps
            #   @return [::Array<::Google::Cloud::Workflows::Executions::V1::Execution::Status::Step>]
            #     A list of currently executing or last executed step names for the
            #     workflow execution currently running. If the workflow has succeeded or
            #     failed, this is the last attempted or executed step. Presently, if the
            #     current step is inside a subworkflow, the list only includes that step.
            #     In the future, the list will contain items for each step in the call
            #     stack, starting with the outermost step in the `main` subworkflow, and
            #     ending with the most deeply nested step.
            class Status
              include ::Google::Protobuf::MessageExts
              extend ::Google::Protobuf::MessageExts::ClassMethods

              # Represents a step of the workflow this execution is running.
              # @!attribute [rw] routine
              #   @return [::String]
              #     Name of a routine within the workflow.
              # @!attribute [rw] step
              #   @return [::String]
              #     Name of a step within the routine.
              class Step
                include ::Google::Protobuf::MessageExts
                extend ::Google::Protobuf::MessageExts::ClassMethods
              end
            end

            # Describes an error related to the current state of the Execution resource.
            # @!attribute [rw] details
            #   @return [::String]
            #     Provides specifics about the error.
            # @!attribute [rw] type
            #   @return [::Google::Cloud::Workflows::Executions::V1::Execution::StateError::Type]
            #     The type of this state error.
            class StateError
              include ::Google::Protobuf::MessageExts
              extend ::Google::Protobuf::MessageExts::ClassMethods

              # Describes the possible types of a state error.
              module Type
                # No type specified.
                TYPE_UNSPECIFIED = 0

                # Caused by an issue with KMS.
                KMS_ERROR = 1
              end
            end

            # @!attribute [rw] key
            #   @return [::String]
            # @!attribute [rw] value
            #   @return [::String]
            class LabelsEntry
              include ::Google::Protobuf::MessageExts
              extend ::Google::Protobuf::MessageExts::ClassMethods
            end

            # Describes the current state of the execution. More states might be added
            # in the future.
            module State
              # Invalid state.
              STATE_UNSPECIFIED = 0

              # The execution is in progress.
              ACTIVE = 1

              # The execution finished successfully.
              SUCCEEDED = 2

              # The execution failed with an error.
              FAILED = 3

              # The execution was stopped intentionally.
              CANCELLED = 4

              # Execution data is unavailable. See the `state_error` field.
              UNAVAILABLE = 5

              # Request has been placed in the backlog for processing at a later time.
              QUEUED = 6
            end

            # Describes the level of platform logging to apply to calls and call
            # responses during workflow executions.
            module CallLogLevel
              # No call logging level specified.
              CALL_LOG_LEVEL_UNSPECIFIED = 0

              # Log all call steps within workflows, all call returns, and all exceptions
              # raised.
              LOG_ALL_CALLS = 1

              # Log only exceptions that are raised from call steps within workflows.
              LOG_ERRORS_ONLY = 2

              # Explicitly log nothing.
              LOG_NONE = 3
            end
          end

          # Request for the
          # [ListExecutions][]
          # method.
          # @!attribute [rw] parent
          #   @return [::String]
          #     Required. Name of the workflow for which the executions should be listed.
          #     Format: projects/\\{project}/locations/\\{location}/workflows/\\{workflow}
          # @!attribute [rw] page_size
          #   @return [::Integer]
          #     Maximum number of executions to return per call.
          #     Max supported value depends on the selected Execution view: it's 1000 for
          #     BASIC and 100 for FULL. The default value used if the field is not
          #     specified is 100, regardless of the selected view. Values greater than
          #     the max value will be coerced down to it.
          # @!attribute [rw] page_token
          #   @return [::String]
          #     A page token, received from a previous `ListExecutions` call.
          #     Provide this to retrieve the subsequent page.
          #
          #     When paginating, all other parameters provided to `ListExecutions` must
          #     match the call that provided the page token.
          #
          #     Note that pagination is applied to dynamic data. The list of executions
          #     returned can change between page requests.
          # @!attribute [rw] view
          #   @return [::Google::Cloud::Workflows::Executions::V1::ExecutionView]
          #     Optional. A view defining which fields should be filled in the returned
          #     executions. The API will default to the BASIC view.
          # @!attribute [rw] filter
          #   @return [::String]
          #     Optional. Filters applied to the [Executions.ListExecutions] results.
          #     The following fields are supported for filtering:
          #     executionID, state, startTime, endTime, duration, workflowRevisionID,
          #     stepName, and label.
          # @!attribute [rw] order_by
          #   @return [::String]
          #     Optional. The ordering applied to the [Executions.ListExecutions] results.
          #     By default the ordering is based on descending start time.
          #     The following fields are supported for order by:
          #     executionID, startTime, endTime, duration, state, and workflowRevisionID.
          class ListExecutionsRequest
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # Response for the
          # {::Google::Cloud::Workflows::Executions::V1::Executions::Client#list_executions ListExecutions}
          # method.
          # @!attribute [rw] executions
          #   @return [::Array<::Google::Cloud::Workflows::Executions::V1::Execution>]
          #     The executions which match the request.
          # @!attribute [rw] next_page_token
          #   @return [::String]
          #     A token, which can be sent as `page_token` to retrieve the next page.
          #     If this field is omitted, there are no subsequent pages.
          class ListExecutionsResponse
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # Request for the
          # {::Google::Cloud::Workflows::Executions::V1::Executions::Client#create_execution CreateExecution}
          # method.
          # @!attribute [rw] parent
          #   @return [::String]
          #     Required. Name of the workflow for which an execution should be created.
          #     Format: projects/\\{project}/locations/\\{location}/workflows/\\{workflow}
          #     The latest revision of the workflow will be used.
          # @!attribute [rw] execution
          #   @return [::Google::Cloud::Workflows::Executions::V1::Execution]
          #     Required. Execution to be created.
          class CreateExecutionRequest
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # Request for the
          # {::Google::Cloud::Workflows::Executions::V1::Executions::Client#get_execution GetExecution}
          # method.
          # @!attribute [rw] name
          #   @return [::String]
          #     Required. Name of the execution to be retrieved.
          #     Format:
          #     projects/\\{project}/locations/\\{location}/workflows/\\{workflow}/executions/\\{execution}
          # @!attribute [rw] view
          #   @return [::Google::Cloud::Workflows::Executions::V1::ExecutionView]
          #     Optional. A view defining which fields should be filled in the returned
          #     execution. The API will default to the FULL view.
          class GetExecutionRequest
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # Request for the
          # {::Google::Cloud::Workflows::Executions::V1::Executions::Client#cancel_execution CancelExecution}
          # method.
          # @!attribute [rw] name
          #   @return [::String]
          #     Required. Name of the execution to be cancelled.
          #     Format:
          #     projects/\\{project}/locations/\\{location}/workflows/\\{workflow}/executions/\\{execution}
          class CancelExecutionRequest
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # Defines possible views for execution resource.
          module ExecutionView
            # The default / unset value.
            EXECUTION_VIEW_UNSPECIFIED = 0

            # Includes only basic metadata about the execution.
            # The following fields are returned: name, start_time, end_time, duration,
            # state, and workflow_revision_id.
            BASIC = 1

            # Includes all data.
            FULL = 2
          end
        end
      end
    end
  end
end
