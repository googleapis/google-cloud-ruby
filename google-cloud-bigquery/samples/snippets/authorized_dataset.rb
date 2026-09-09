# Copyright 2022 Google LLC
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
# [START bigquery_authorized_dataset]
require "google/cloud/bigquery"

##
# This is a snippet for showcasing how to authorize a dataset.
#
# Note: Only views target types are supported for now.
#
# @param source_project_id [String] The ID of the source Google Cloud project.
# @param source_database_id [String] The ID of the source database.
# @param user_project_id [String] The ID of the user Google Cloud project.
# @param user_database_id [String] The ID of the user database.
# @param target_types [Array<String>] List of target types for authorization.
#
def authorized_dataset source_project_id:, source_database_id:, user_project_id:, user_database_id:, target_types:
  # Initialize client and get source dataset's references
  source_bigquery = Google::Cloud::Bigquery.new project_id: source_project_id
  source_dataset  = source_bigquery.dataset source_database_id

  # Initialize client and get user dataset's references
  user_bigquery = Google::Cloud::Bigquery.new project_id: user_project_id
  user_dataset  = user_bigquery.dataset user_database_id

  # Add the user dataset's DatasetAccessEntry object to the existing source dataset rules
  source_dataset.access do |access|
    access.add_reader_dataset user_dataset.build_access_entry(target_types: target_types)
  end

  puts "Dataset #{user_dataset.dataset_id} added as authorized dataset in dataset #{source_dataset.dataset_id}"
end

# [END bigquery_authorized_dataset]
