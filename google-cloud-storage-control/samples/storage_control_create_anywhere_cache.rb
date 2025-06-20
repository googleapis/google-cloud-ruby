# Copyright 2025 Google LLC
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

# [START storage_control_create_anywhere_cache]
def create_anywhere_cache bucket_name:, project_name:, zone:
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"


  require "google/cloud/storage/control"
	require "google/cloud/storage/control/v2"

	require "pry"

	# Create a client object. The client can be reused for multiple calls.
	client = Google::Cloud::Storage::Control::V2::StorageControl::Client.new
	parent = "projects/_/buckets/#{bucket_name}"

	anywhere_cache = Google::Cloud::Storage::Control::V2::AnywhereCache.new(
		name: "test_cache_shubhangi",
		zone: zone
	)
	# Create a request. Replace the placeholder values with actual data.
	request = Google::Cloud::Storage::Control::V2::CreateAnywhereCacheRequest.new(
		parent: parent,
		anywhere_cache: anywhere_cache
	)
# Call the create_anywhere_cache method.

result = client.create_anywhere_cache(request)

end
# [END storage_control_create_anywhere_cache]

create_anywhere_cache bucket_name: ARGV.shift if $PROGRAM_NAME == __FILE__

# request=>
#  <Google::Cloud::Storage::Control::V2::CreateAnywhereCacheRequest: 
#  		parent: "projects/_/buckets/ruby-storage-control-samples-test-2025-06-20t04-23-38z-4690f615",
# 		anywhere_cache: <Google::Cloud::Storage::Control::V2::AnywhereCache: 
# 			name: "",
# 			zone: "US",
# 			admission_policy: "",
# 			state: "",
# 			pending_update: false>,
# 		request_id: "">

# GRPC::InvalidArgument: 3:This operation does not support custom billing projects at this time.. debug_error_string:{UNKNOWN:Error received from peer ipv4:64.233.189.207:443 {grpc_status:3, grpc_message:"This operation does not support custom billing projects at this time."}}