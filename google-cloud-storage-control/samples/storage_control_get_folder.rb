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

# [START storage_control_get_folder]
def get_folder bucket_name:, folder_name:
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  # The name of the folder to be created
  # folder_name = "folder-name"

  require "google/cloud/storage/control"

  storage_control = Google::Cloud::Storage::Control.storage_control

  # The storage folder path uses the global access pattern, in which the "_"
  # denotes this bucket exists in the global namespace.
  folder_path = storage_control.folder_path project: "_", bucket: bucket_name, folder: folder_name

  request = Google::Cloud::Storage::Control::V2::GetFolderRequest.new name: folder_path

  response = storage_control.get_folder request

  puts "Got folder #{response.name}"
end
# [END storage_control_get_folder]

get_folder bucket_name: ARGV.shift if $PROGRAM_NAME == __FILE__
