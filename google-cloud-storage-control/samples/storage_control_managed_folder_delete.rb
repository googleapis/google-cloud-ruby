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

# [START storage_control_managed_folder_delete]
def delete_managed_folder bucket_name:, managed_folder_id:
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  # The name of the managed folder to be created
  # managed_folder_id = "managed-folder-name"

  require "google/cloud/storage/control"

  storage_control = Google::Cloud::Storage::Control.storage_control

  # The storage bucket path uses the global access pattern, in which the "_"
  # denotes this bucket exists in the global namespace.
  folder_path = storage_control.managed_folder_path project: "_",
                                                    bucket: bucket_name,
                                                    managed_folder: managed_folder_id

  request = Google::Cloud::Storage::Control::V2::DeleteManagedFolderRequest.new name: folder_path

  storage_control.delete_managed_folder request

  puts "Deleted managed folder: #{managed_folder_id}"
end
# [END storage_control_managed_folder_delete]

create_folder bucket_name: ARGV.shift if $PROGRAM_NAME == __FILE__
