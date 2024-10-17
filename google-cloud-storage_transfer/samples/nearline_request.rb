# Copyright 2024 Google LLC
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

# [Start storagetransfer_transfer_to_nearline]
def create_daily_nearline_30_day_migration project_id:, gcs_source_bucket:, gcs_sink_bucket:, start_date:
  # Your Google Cloud Project ID
  # project_id = "your-project_id"

  # The name of the source GCS bucket to transfer objects from
  # gcs_source_bucket = "your-source-gcs-source-bucket"

  # The name of the  GCS bucket to transfer objects to
  # gcs_sink_bucket = "your-nearline-gcs-bucket"

  # Time when you want to schedule the job
  # start_date = Time.now

  require "google/cloud/storage_transfer"

  transfer_job = {
    project_id: project_id,
    transfer_spec: {
      gcs_data_source: {
        bucket_name: gcs_source_bucket
      },
      gcs_data_sink: {
        bucket_name: gcs_sink_bucket
      },
      object_conditions: {
        min_time_elapsed_since_last_modification: {
          seconds: 259_200_0 # 30 days
        }
      },
      transfer_options: {
        delete_objects_from_source_after_transfer: true # Deletes the object from source bucket after transfer
      }
    },
    schedule: {
      schedule_start_date: {
        year: start_date.year,
        month: start_date.month,
        day: start_date.day
      },
      start_time_of_day: {
        hours: start_date.hour,
        minutes: start_date.min,
        seconds: start_date.sec + 1
      }
    },
    status: :ENABLED
  }

  client = Google::Cloud::StorageTransfer.storage_transfer_service

  transfer_job_response = client.create_transfer_job transfer_job: transfer_job

  # This is a scheduled job hence there is no need to run the job seprately

  puts "Created transfer job between #{gcs_source_bucket} and nearline bucket #{gcs_sink_bucket} with name #{transfer_job_response.name}"
end
# [END storagetransfer_transfer_to_nearline]
if $PROGRAM_NAME == __FILE__
  create_daily_nearline_30_day_migration project_id: ARGV.shift, gcs_source_bucket: ARGV.shift, gcs_sink_bucket: ARGV.shift, start_date: ARGV.shift
end
