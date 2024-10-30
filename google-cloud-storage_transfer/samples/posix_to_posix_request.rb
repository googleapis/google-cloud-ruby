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

# [START storagetransfer_transfer_posix_to_posix]
def transfer_between_posix project_id:, description:, source_agent_pool_name:, sink_agent_pool_name:, root_directory:, destination_directory:, intermediate_bucket:
	# Your Google Cloud Project ID
	# project_id = "your-project_id"

	# A useful description for your transfer job
	# description = 'My transfer job'

	# The agent pool associated with the POSIX datasource.
	# Defaults to 'projects/{project_id}/agentPools/transfer_service_default'
	# source_agent_pool_name = 'projects/my-project/agentPools/my-agent'

	# The agent pool associated with the POSIX data sink.
	# Defaults to 'projects/{project_id}/agentPools/transfer_service_default'
	# sink_agent_pool_name = 'projects/my-project/agentPools/my-agent'

	# The root directory path on the source filesystem
	# root_directory = '/directory/to/transfer/source'

	# The root directory path on the destination filesystem
	# destination_directory = '/directory/to/transfer/sink'

	# The Google Cloud Storage bucket for intermediate storage
	# intermediate_bucket = 'my-intermediate-bucket'

	require "google/cloud/storage_transfer"
	require "pry"

	transfer_job = {
		project_id: project_id,
		description: description,
		transfer_spec: {
			source_agent_pool_name: source_agent_pool_name,
			sink_agent_pool_name: sink_agent_pool_name,
			posix_data_source: {
				root_directory: root_directory
			},
			posix_data_sink: {
				root_directory: destination_directory
			},
			gcs_intermediate_data_location: {
				bucket_name: intermediate_bucket
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

	puts "Created and ran transfer job between #{root_directory} and #{destination_directory} with name #{transfer_job_response.name}"
end
# [END storagetransfer_transfer_posix_to_posix]

	
  
if $PROGRAM_NAME == __FILE__
	transfer_between_posix project_id: ARGV.shift, description: ARGV.shift, source_agent_pool_name: ARGV.shift,sink_agent_pool_name: ARGV.shift, root_directory: ARGV.shift, destination_directory: ARGV.shift, intermediate_bucket: ARGV.shift
end
  