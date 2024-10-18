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

# [START storagetransfer_manifest_request]

require "google/cloud/storage"

# def grant_sts_permissions project_id:, bucket_name:
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


def posix_request project_id:, gcs_sink_bucket:, source_agent_pool_name:, root_directory:
    # Your Google Cloud Project ID
    # # project_id = "your-project_id"
  
    # The name of the  GCS bucket to transfer objects to
    # gcs_sink_bucket = "your-sink-gcs-bucket"
  
    # The agent pool associated with the POSIX data source.
    # Defaults to 'projects/{project_id}/agentPools/transfer_service_default'
    # source_agent_pool_name = 'projects/your-project/agentPools/myouragent'
  
    # The root directory path on the source filesystem
    # root_directory = '/directory/to/transfer/source'
  
    # Google Cloud Storage destination bucket name
    # sink_bucket = 'your-destination-bucket'

  
    require "google/cloud/storage_transfer"
  
    transfer_job = {
      project_id: project_id,
      transfer_spec: {
        source_agent_pool_name: source_agent_pool_name,
        posix_data_source: {
          root_directory: root_directory
        },
        gcs_data_sink: {
          bucket_name: gcs_sink_bucket
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
    puts "Transfered a file from #{root_directory} to #{gcs_sink_bucket} via job name #{transfer_job_response.name}"
  end
  # [END storagetransfer_manifest_request]

  project_id= "storage-sdk-vendor"
  gcs_sink_bucket= "ruby-storagetransfer-samples-test-2024-10-18t07-52-55z-a6e2492c"
  source_agent_pool_name= "projects/storage-sdk-vendor/agentPools/shubhangi-test-pool"
  root_directory= "/tmp/try/ruby_storagetransfer_samples_dummy_1b2d68c56d5c6d856f40446bf93e4794.txt"


#   if $PROGRAM_NAME == __FILE__
#     posix_request project_id: project_id, gcs_sink_bucket: gcs_sink_bucket, source_agent_pool_name: source_agent_pool_name, root_directory: root_directory
#   end


  
  if $PROGRAM_NAME == __FILE__
    posix_request project_id: ARGV.shift, gcs_sink_bucket: ARGV.shift, source_agent_pool_name: ARGV.shift, root_directory: ARGV.shift
  end