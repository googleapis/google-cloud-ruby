# Copyright 2026 Google LLC
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

# [START storage_control_delete_folder_recursive]
require "google/cloud/storage/control/v2"

def delete_folder_recursive bucket_name:, folder_name:
  # Create a client object. The client can be reused for multiple calls.
  client = Google::Cloud::Storage::Control::V2::StorageControl::Client.new

  # Format the folder path
  # Note: Storage Control API requires the project to be "_" when using bucket names.
  formatted_name = client.folder_path project: "_", bucket: bucket_name, folder: folder_name

  # Call the delete_folder_recursive method.
  operation = client.delete_folder_recursive name: formatted_name

  # The returned object is of type Gapic::Operation. You can use it to
  # check the status of an operation, cancel it, or wait for results.
  # Here is how to wait for a response.
  operation.wait_until_done! timeout: 60

  puts "Deleted folder #{folder_name} recursively."
end
# [END storage_control_delete_folder_recursive]

if $PROGRAM_NAME == __FILE__
  delete_folder_recursive bucket_name: ARGV.shift, folder_name: ARGV.shift
end
