# Copyright 2018 Google LLC
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


module Google
  module Cloud
    module Tasks
      module V2beta3
        # A unit of scheduled work.
        # @!attribute [rw] name
        #   @return [String]
        #     Optionally caller-specified in {Google::Cloud::Tasks::V2beta3::CloudTasks::CreateTask CreateTask}.
        #
        #     The task name.
        #
        #     The task name must have the following format:
        #     `projects/PROJECT_ID/locations/LOCATION_ID/queues/QUEUE_ID/tasks/TASK_ID`
        #
        #     * `PROJECT_ID` can contain letters ([A-Za-z]), numbers ([0-9]),
        #       hyphens (-), colons (:), or periods (.).
        #       For more information, see
        #       [Identifying projects](https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects)
        #     * `LOCATION_ID` is the canonical ID for the task's location.
        #       The list of available locations can be obtained by calling
        #       {Google::Cloud::Location::Locations::ListLocations ListLocations}.
        #       For more information, see https://cloud.google.com/about/locations/.
        #     * `QUEUE_ID` can contain letters ([A-Za-z]), numbers ([0-9]), or
        #       hyphens (-). The maximum length is 100 characters.
        #     * `TASK_ID` can contain only letters ([A-Za-z]), numbers ([0-9]),
        #       hyphens (-), or underscores (_). The maximum length is 500 characters.
        # @!attribute [rw] app_engine_http_request
        #   @return [Google::Cloud::Tasks::V2beta3::AppEngineHttpRequest]
        #     App Engine HTTP request that is sent to the task's target. Can
        #     be set only if
        #     {Google::Cloud::Tasks::V2beta3::Queue#app_engine_http_queue app_engine_http_queue} is set
        #     on the queue.
        #
        #     An App Engine task is a task that has {Google::Cloud::Tasks::V2beta3::AppEngineHttpRequest AppEngineHttpRequest} set.
        # @!attribute [rw] schedule_time
        #   @return [Google::Protobuf::Timestamp]
        #     The time when the task is scheduled to be attempted.
        #
        #     For App Engine queues, this is when the task will be attempted or retried.
        #
        #     `schedule_time` will be truncated to the nearest microsecond.
        # @!attribute [rw] create_time
        #   @return [Google::Protobuf::Timestamp]
        #     Output only. The time that the task was created.
        #
        #     `create_time` will be truncated to the nearest second.
        # @!attribute [rw] dispatch_count
        #   @return [Integer]
        #     Output only. The number of attempts dispatched.
        #
        #     This count includes tasks which have been dispatched but haven't
        #     received a response.
        # @!attribute [rw] response_count
        #   @return [Integer]
        #     Output only. The number of attempts which have received a response.
        # @!attribute [rw] first_attempt
        #   @return [Google::Cloud::Tasks::V2beta3::Attempt]
        #     Output only. The status of the task's first attempt.
        #
        #     Only {Google::Cloud::Tasks::V2beta3::Attempt#dispatch_time dispatch_time} will be set.
        #     The other {Google::Cloud::Tasks::V2beta3::Attempt Attempt} information is not retained by Cloud Tasks.
        # @!attribute [rw] last_attempt
        #   @return [Google::Cloud::Tasks::V2beta3::Attempt]
        #     Output only. The status of the task's last attempt.
        # @!attribute [rw] view
        #   @return [Google::Cloud::Tasks::V2beta3::Task::View]
        #     Output only. The view specifies which subset of the {Google::Cloud::Tasks::V2beta3::Task Task} has
        #     been returned.
        class Task
          # The view specifies a subset of {Google::Cloud::Tasks::V2beta3::Task Task} data.
          #
          # When a task is returned in a response, not all
          # information is retrieved by default because some data, such as
          # payloads, might be desirable to return only when needed because
          # of its large size or because of the sensitivity of data that it
          # contains.
          module View
            # Unspecified. Defaults to BASIC.
            VIEW_UNSPECIFIED = 0

            # The basic view omits fields which can be large or can contain
            # sensitive data.
            #
            # This view does not include the
            # {Google::Cloud::Tasks::V2beta3::AppEngineHttpRequest#body body in AppEngineHttpRequest}.
            # Bodies are desirable to return only when needed, because they
            # can be large and because of the sensitivity of the data that you
            # choose to store in it.
            BASIC = 1

            # All information is returned.
            #
            # Authorization for {Google::Cloud::Tasks::V2beta3::Task::View::FULL FULL} requires
            # `cloudtasks.tasks.fullView` [Google IAM](https://cloud.google.com/iam/)
            # permission on the {Google::Cloud::Tasks::V2beta3::Queue Queue} resource.
            FULL = 2
          end
        end

        # The status of a task attempt.
        # @!attribute [rw] schedule_time
        #   @return [Google::Protobuf::Timestamp]
        #     Output only. The time that this attempt was scheduled.
        #
        #     `schedule_time` will be truncated to the nearest microsecond.
        # @!attribute [rw] dispatch_time
        #   @return [Google::Protobuf::Timestamp]
        #     Output only. The time that this attempt was dispatched.
        #
        #     `dispatch_time` will be truncated to the nearest microsecond.
        # @!attribute [rw] response_time
        #   @return [Google::Protobuf::Timestamp]
        #     Output only. The time that this attempt response was received.
        #
        #     `response_time` will be truncated to the nearest microsecond.
        # @!attribute [rw] response_status
        #   @return [Google::Rpc::Status]
        #     Output only. The response from the target for this attempt.
        #
        #     If `response_time` is unset, then the task has not been attempted or is
        #     currently running and the `response_status` field is meaningless.
        class Attempt; end
      end
    end
  end
end