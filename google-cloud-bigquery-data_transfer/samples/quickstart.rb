# Copyright 2020 Google LLC
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

def quickstart project_id:
  # [START bigquerydatatransfer_quickstart]
  # [START require_library]
  # Imports the Google Cloud client library
  require "google/cloud/bigquery/data_transfer"
  # [END require_library]

  # Your Google Cloud Platform project ID
  # project_id = "YOUR_PROJECT_ID"

  # Instantiate a client
  data_transfer = Google::Cloud::Bigquery::DataTransfer.data_transfer_service

  # Get the full path to your project.
  project_path = data_transfer.project_path project: project_id

  puts "Supported Data Sources:"

  # Iterate over all possible data sources.
  data_transfer.list_data_sources(parent: project_path).each do |data_source|
    puts "Data source: #{data_source.display_name}"
    puts "ID: #{data_source.data_source_id}"
    puts "Full path: #{data_source.name}"
    puts "Description: #{data_source.description}"
  end
  # [END bigquerydatatransfer_quickstart]
end

if $PROGRAM_NAME == __FILE__
  quickstart project_id: ENV["GOOGLE_CLOUD_PROJECT"]
end
