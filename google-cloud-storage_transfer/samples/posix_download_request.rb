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

# [START storagetransfer_download_to_posix]
def download_from_gcs project_id:, description:, sink_agent_pool_name:, destination_directory:, source_bucket:, gcs_source_path:
	# Your Google Cloud Project ID
	# project_id = "your-project_id"

	# A useful description for your transfer job
	# description = 'My transfer job'

	# The agent pool associated with the POSIX data sink.
	# Defaults to 'projects/{project_id}/agentPools/transfer_service_default'
	# sink_agent_pool_name = 'projects/my-project/agentPools/my-agent'

	# The root directory path on the source filesystem
	# root_directory = '/directory/to/transfer/source'

	# Google Cloud Storage source bucket name
    # source_bucket = 'my-gcs-source-bucket'

    # An optional path on the Google Cloud Storage bucket to download from
    # gcs_source_path = 'foo/bar/'

	require "google/cloud/storage_transfer"

	transfer_job = {
		project_id: project_id,
		description: description,
		transfer_spec: {
			sink_agent_pool_name: sink_agent_pool_name,
			posix_data_sink: {
				root_directory: destination_directory
			},
			gcs_data_source: {
				bucket_name: source_bucket,
				path: gcs_source_path
			}
		},
		status: :ENABLED
	}

	client = Google::Cloud::StorageTransfer.storage_transfer_service

	transfer_job_response = client.create_transfer_job transfer_job: transfer_job

	run_request = {
		project_id: project_id,
		job_name: transfer_job_response.name
	}
	client.run_transfer_job run_request

	puts "Created and ran transfer job between #{source_bucket} and #{gcs_source_path} with name #{transfer_job_response.name}"
end
# [END storagetransfer_download_to_posix]
  
if $PROGRAM_NAME == __FILE__
	download_from_gcs project_id: ARGV.shift, description: ARGV.shift, sink_agent_pool_name: ARGV.shift, destination_directory: ARGV.shift, source_bucket: ARGV.shift, gcs_source_path: ARGV.shift
end
  