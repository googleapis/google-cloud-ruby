# Copyright 2021 Google LLC
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

# [START storagetransfer_quickstart]

def quickstart project_id:, gcs_source_bucket:, gcs_sink_bucket:
	# Your Google Cloud Project ID
    # project_id = "your-project_id"

    # The name of the source GCS bucket to transfer objects from
    #gcs_source_bucket = "your-source-gcs-source-bucket"

    # The name of the  GCS bucket to transfer  objects to
    # gcs_sink_bucket = "your-sink-gcs-bucket"

    require "google/cloud/storage_transfer/v1"

    transfer_job = { project_id: project_id,
                     transfer_spec: { gcs_data_source: {bucket_name: gcs_source_bucket},
                                       gcs_data_sink:  {bucket_name: gcs_sink_bucket}
                                   },

                     status: :ENABLED
                 }

    client = ::Google::Cloud::StorageTransfer::V1::StorageTransferService::Client.new

    response = client.create_transfer_job transfer_job: transfer_job

    puts "Created transfer job between two GCS buckets:"
    puts response
end
# [END storagetransfer_quickstart]

quickstart project_id: ARGV.shift, gcs_source_bucket: ARGV.shift, gcs_sink_bucket: ARGV.shift if $PROGRAM_NAME == __FILE__