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
    module Bigquery
      module DataTransfer
        module V1
          # Represents a data transfer configuration. A transfer configuration
          # contains all metadata needed to perform a data transfer. For example,
          # +destination_dataset_id+ specifies where data should be stored.
          # When a new transfer configuration is created, the specified
          # +destination_dataset_id+ is created when needed and shared with the
          # appropriate data source service account.
          # Next id: 20
          # @!attribute [rw] name
          #   @return [String]
          #     The resource name of the transfer config.
          #     Transfer config names have the form
          #     +projects/\\{project_id}/transferConfigs/\\{config_id}+.
          #     Where +config_id+ is usually a uuid, even though it is not
          #     guaranteed or required. The name is ignored when creating a transfer
          #     config.
          # @!attribute [rw] destination_dataset_id
          #   @return [String]
          #     The BigQuery target dataset id.
          # @!attribute [rw] display_name
          #   @return [String]
          #     User specified display name for the data transfer.
          # @!attribute [rw] data_source_id
          #   @return [String]
          #     Data source id. Cannot be changed once data transfer is created.
          # @!attribute [rw] params
          #   @return [Google::Protobuf::Struct]
          #     Data transfer specific parameters.
          # @!attribute [rw] schedule
          #   @return [String]
          #     Data transfer schedule.
          #     If the data source does not support a custom schedule, this should be
          #     empty. If it is empty, the default value for the data source will be
          #     used.
          #     The specified times are in UTC.
          #     Examples of valid format:
          #     +1st,3rd monday of month 15:30+,
          #     +every wed,fri of jan,jun 13:15+, and
          #     +first sunday of quarter 00:00+.
          #     See more explanation about the format here:
          #     https://cloud.google.com/appengine/docs/flexible/python/scheduling-jobs-with-cron-yaml#the_schedule_format
          #     NOTE: the granularity should be at least 8 hours, or less frequent.
          # @!attribute [rw] data_refresh_window_days
          #   @return [Integer]
          #     The number of days to look back to automatically refresh the data.
          #     For example, if +data_refresh_window_days = 10+, then every day
          #     BigQuery reingests data for [today-10, today-1], rather than ingesting data
          #     for just [today-1].
          #     Only valid if the data source supports the feature. Set the value to  0
          #     to use the default value.
          # @!attribute [rw] disabled
          #   @return [true, false]
          #     Is this config disabled. When set to true, no runs are scheduled
          #     for a given transfer.
          # @!attribute [rw] update_time
          #   @return [Google::Protobuf::Timestamp]
          #     Output only. Data transfer modification time. Ignored by server on input.
          # @!attribute [rw] next_run_time
          #   @return [Google::Protobuf::Timestamp]
          #     Output only. Next time when data transfer will run.
          # @!attribute [rw] state
          #   @return [Google::Cloud::Bigquery::DataTransfer::V1::TransferState]
          #     Output only. State of the most recently updated transfer run.
          # @!attribute [rw] user_id
          #   @return [Integer]
          #     Output only. Unique ID of the user on whose behalf transfer is done.
          #     Applicable only to data sources that do not support service accounts.
          #     When set to 0, the data source service account credentials are used.
          #     May be negative. Note, that this identifier is not stable.
          #     It may change over time even for the same user.
          # @!attribute [rw] dataset_region
          #   @return [String]
          #     Output only. Region in which BigQuery dataset is located.
          class TransferConfig; end

          # Represents a data transfer run.
          # Next id: 27
          # @!attribute [rw] name
          #   @return [String]
          #     The resource name of the transfer run.
          #     Transfer run names have the form
          #     +projects/\\{project_id}/locations/\\{location}/transferConfigs/\\{config_id}/runs/\\{run_id}+.
          #     The name is ignored when creating a transfer run.
          # @!attribute [rw] schedule_time
          #   @return [Google::Protobuf::Timestamp]
          #     Minimum time after which a transfer run can be started.
          # @!attribute [rw] run_time
          #   @return [Google::Protobuf::Timestamp]
          #     For batch transfer runs, specifies the date and time that
          #     data should be ingested.
          # @!attribute [rw] error_status
          #   @return [Google::Rpc::Status]
          #     Status of the transfer run.
          # @!attribute [rw] start_time
          #   @return [Google::Protobuf::Timestamp]
          #     Output only. Time when transfer run was started.
          #     Parameter ignored by server for input requests.
          # @!attribute [rw] end_time
          #   @return [Google::Protobuf::Timestamp]
          #     Output only. Time when transfer run ended.
          #     Parameter ignored by server for input requests.
          # @!attribute [rw] update_time
          #   @return [Google::Protobuf::Timestamp]
          #     Output only. Last time the data transfer run state was updated.
          # @!attribute [rw] params
          #   @return [Google::Protobuf::Struct]
          #     Output only. Data transfer specific parameters.
          # @!attribute [rw] destination_dataset_id
          #   @return [String]
          #     Output only. The BigQuery target dataset id.
          # @!attribute [rw] data_source_id
          #   @return [String]
          #     Output only. Data source id.
          # @!attribute [rw] state
          #   @return [Google::Cloud::Bigquery::DataTransfer::V1::TransferState]
          #     Data transfer run state. Ignored for input requests.
          # @!attribute [rw] user_id
          #   @return [Integer]
          #     Output only. Unique ID of the user on whose behalf transfer is done.
          #     Applicable only to data sources that do not support service accounts.
          #     When set to 0, the data source service account credentials are used.
          #     May be negative. Note, that this identifier is not stable.
          #     It may change over time even for the same user.
          # @!attribute [rw] schedule
          #   @return [String]
          #     Output only. Describes the schedule of this transfer run if it was
          #     created as part of a regular schedule. For batch transfer runs that are
          #     scheduled manually, this is empty.
          #     NOTE: the system might choose to delay the schedule depending on the
          #     current load, so +schedule_time+ doesn't always matches this.
          class TransferRun; end

          # Represents a user facing message for a particular data transfer run.
          # @!attribute [rw] message_time
          #   @return [Google::Protobuf::Timestamp]
          #     Time when message was logged.
          # @!attribute [rw] severity
          #   @return [Google::Cloud::Bigquery::DataTransfer::V1::TransferMessage::MessageSeverity]
          #     Message severity.
          # @!attribute [rw] message_text
          #   @return [String]
          #     Message text.
          class TransferMessage
            # Represents data transfer user facing message severity.
            module MessageSeverity
              # No severity specified.
              MESSAGE_SEVERITY_UNSPECIFIED = 0

              # Informational message.
              INFO = 1

              # Warning message.
              WARNING = 2

              # Error message.
              ERROR = 3
            end
          end

          # Represents data transfer type.
          module TransferType
            # Invalid or Unknown transfer type placeholder.
            TRANSFER_TYPE_UNSPECIFIED = 0

            # Batch data transfer.
            BATCH = 1

            # Streaming data transfer. Streaming data source currently doesn't
            # support multiple transfer configs per project.
            STREAMING = 2
          end

          # Represents data transfer run state.
          module TransferState
            # State placeholder.
            TRANSFER_STATE_UNSPECIFIED = 0

            # Data transfer is scheduled and is waiting to be picked up by
            # data transfer backend.
            PENDING = 2

            # Data transfer is in progress.
            RUNNING = 3

            # Data transfer completed successsfully.
            SUCCEEDED = 4

            # Data transfer failed.
            FAILED = 5

            # Data transfer is cancelled.
            CANCELLED = 6
          end
        end
      end
    end
  end
end
