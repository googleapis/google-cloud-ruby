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
# require "pry"
# def grant_sts_permissions project_id:, bucket_name:
# 	require "google/cloud/storage_transfer"
# 	require "google/cloud/storage"

#   client = Google::Cloud::StorageTransfer.storage_transfer_service
#   request = { project_id: project_id }

#   response = client.get_google_service_account request
#   email = response.account_email

#   storage = Google::Cloud::Storage.new
#   bucket = storage.bucket bucket_name

#   object_viewer = "roles/storage.objectViewer"
#   bucket_reader = "roles/storage.legacyBucketReader"
#   bucket_writer = "roles/storage.legacyBucketWriter"
#   member = "serviceAccount:#{email}"
# 	binding.pry


#   bucket.policy requested_policy_version: 3 do |policy|
#     policy.version = 3
#     policy.bindings.insert(
#       role:      object_viewer,
#       members:   member
#     )
#   end

#   bucket.policy requested_policy_version: 3 do |policy|
#     policy.version = 3
#     policy.bindings.insert(
#       role:      bucket_reader,
#       members:   member
#     )
#   end

#   bucket.policy requested_policy_version: 3 do |policy|
#     policy.version = 3
#     policy.bindings.insert(
#       role:      bucket_writer,
#       members:   member
#     )
#   end
# end

# [START storagetransfer_transfer_posix_to_posix]
def transfer_between_posix project_id:, description:, source_agent_pool_name:, sink_agent_pool_name:, root_directory:, destination_directory:, intermediate_bucket:
    # Your Google Cloud Project ID
    # project_id = "your-project_id"
  
    # The name of the source GCS bucket to transfer objects from
    # gcs_source_bucket = "your-source-gcs-source-bucket"
  
    # The name of the  GCS bucket to transfer objects to
    # gcs_sink_bucket = "your-sink-gcs-bucket"
  
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

		binding.pry

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

	# project_id= "storage-sdk-vendor"
	# description= "test test test"
	# source_agent_pool_name="projects/storage-sdk-vendor/agentPools/shubhangi-test-pool"
	# sink_agent_pool_name= "projects/storage-sdk-vendor/agentPools/shubhangi-test-pool"
	# root_directory= "/tmp/uploads"
	# destination_directory= "/tmp/downloads"
	# intermediate_bucket= "storagetranfersample2"

	# grant_sts_permissions project_id: project_id, bucket_name: intermediate_bucket

  #   transfer_between_posix(project_id: project_id, description: description, source_agent_pool_name: source_agent_pool_name,sink_agent_pool_name: sink_agent_pool_name, root_directory: root_directory, destination_directory: destination_directory, intermediate_bucket:intermediate_bucket)
  
  if $PROGRAM_NAME == __FILE__
    transfer_between_posix project_id: ARGV.shift, description: ARGV.shift, source_agent_pool_name: ARGV.shift,sink_agent_pool_name: ARGV.shift, root_directory: ARGV.shift, destination_directory: ARGV.shift, intermediate_bucket: ARGV.shift
  end
  