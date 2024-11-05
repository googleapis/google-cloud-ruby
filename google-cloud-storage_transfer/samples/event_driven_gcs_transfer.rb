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

# [START storagetransfer_create_event_driven_gcs_transfer]
def create_event_driven_gcs_transfer project_id:, description:, gcs_source_bucket:, gcs_sink_bucket:, pubsub_id:
  # Your Google Cloud Project ID
  # project_id = "your-project_id"

  # The name of the source GCS bucket to transfer objects from
  # gcs_source_bucket = "your-source-gcs-source-bucket"

  # The name of the  GCS bucket to transfer objects to
  # gcs_sink_bucket = "your-sink-gcs-bucket"

  # pubsub_id = projects/<Project-name>topics/<Subscription-name>

  require "google/cloud/storage_transfer"

  transfer_job = {
    project_id: project_id,
    description: description,
    transfer_spec: {
      gcs_data_source: {
        bucket_name: gcs_source_bucket
      },
      gcs_data_sink: {
        bucket_name: gcs_sink_bucket
      },
      transfer_options: {
        overwrite_objects_already_existing_in_sink: true
      }
    },
    event_stream: {
      name: pubsub_id
    },
    status: :ENABLED
  }

  client = Google::Cloud::StorageTransfer.storage_transfer_service

  transfer_job_response = client.create_transfer_job transfer_job: transfer_job
  puts "Created and ran transfer job between #{gcs_source_bucket} and #{gcs_sink_bucket} with name #{transfer_job_response.name}"
end
# [END storagetransfer_create_event_driven_gcs_transfer]
if $PROGRAM_NAME == __FILE__
  create_event_driven_gcs_transfer project_id: ARGV.shift, description: ARGV.shift, gcs_source_bucket: ARGV.shift, gcs_sink_bucket: ARGV.shift, pubsub_id: ARGV.shift
end
