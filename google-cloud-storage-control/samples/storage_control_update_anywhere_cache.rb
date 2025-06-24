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

# [START storage_control_update_anywhere_cache]
def update_anywhere_cache bucket_name:, zone:
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  require "google/cloud/storage/control"
	require "google/cloud/storage/control/v2"

	# Create a client object. The client can be reused for multiple calls.
	client = Google::Cloud::Storage::Control::V2::StorageControl::Client.new
	parent = "projects/_/buckets/#{bucket_name}"
    name=  "#{parent}/anywhereCaches/#{zone}"
    binding.pry


	# Create a request. Replace the placeholder values with actual data.
    request = Google::Cloud::Storage::Control::V2::UpdateAnywhereCacheRequest.new(
		request_id: name
	)
  # Call the update_anywhere_cache method.

  result = client.update_anywhere_cache(request1)
  puts result
end
# [END storage_control_update_anywhere_cache]

update_anywhere_cache bucket_name: ARGV.shift if $PROGRAM_NAME == __FILE__

# => <Google::Cloud::Storage::Control::V2::UpdateAnywhereCacheRequest: anywhere_cache: <Google::Cloud::Storage::Control::V2::AnywhereCache: name: "projects/_/buckets/ruby_7/anywhereCaches/us-east1-b", zone: "us-east1-b", ttl: <Google::Protobuf::Duration: seconds: 86400, nanos: 0>, admission_policy: "admit-on-first-miss", state: "running", create_time: <Google::Protobuf::Timestamp: seconds: 1750052596, nanos: 734237461>, update_time: <Google::Protobuf::Timestamp: seconds: 1750418205, nanos: 763036952>, pending_update: false>, update_mask: <Google::Protobuf::FieldMask: paths: ["anywhere_cache.ttl"]>, request_id: ""> 
# Google::Cloud::InvalidArgumentError: 3:Please specify anywhere_cache.name in request.. debug_error_string:{UNKNOWN:Error received from peer ipv4:108.177.97.207:443 {grpc_message:"Please specify anywhere_cache.name in request.", grpc_status:3}
