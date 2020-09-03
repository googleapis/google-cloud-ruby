# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");x
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

require "google/cloud/datastore/admin/v1"

def client_create
  # [START datastore_admin_client_create]
  # [START require_library]
  # Import the client library
  require "google/cloud/datastore/admin/v1"
  # [END require_library]

  # Instantiate a client
  client = Google::Cloud::Datastore::Admin::V1::DatastoreAdmin::Client.new
  # [END datastore_admin_client_create]
end

def entities_export project_id:, output_url_prefix:
  client = Google::Cloud::Datastore::Admin::V1::DatastoreAdmin::Client.new
  # [START datastore_admin_entities_export]
  # project_id = "project-id"
  # output_url_prefix = "gs://bucket-name"
  op = client.export_entities project_id: project_id, output_url_prefix: output_url_prefix

  op.wait_until_done!
  raise op.error.message if op.error?

  response = op.response
  # Process the response.

  metadata = op.metadata
  # Process the metadata.

  puts "Entities were exported"
  # [END datastore_admin_entities_export]
  op
end

def entities_import project_id:, input_url:
  client = Google::Cloud::Datastore::Admin::V1::DatastoreAdmin::Client.new
  # [START datastore_admin_entities_import]
  # project_id = "project-id"
  # input_url = "gs://bucket-name/overall-export-metadata-file"
  op = client.import_entities project_id: project_id, input_url: input_url

  op.wait_until_done!
  raise op.error.message if op.error?

  response = op.response
  # Process the response.

  metadata = op.metadata
  # Process the metadata.

  puts "Entities were imported"
  # [END datastore_admin_entities_import]
  op
end

def index_get project_id:, index_id:
  client = Google::Cloud::Datastore::Admin::V1::DatastoreAdmin::Client.new
  # [START datastore_admin_index_get]
  # project_id = "project-id"
  # index_id = "my-index"
  index = client.get_index project_id: project_id, index_id: index_id
  puts "Got index: #{index.index_id}"
  # [END datastore_admin_index_get]
  index
end

def index_list project_id:
  client = Google::Cloud::Datastore::Admin::V1::DatastoreAdmin::Client.new
  # [START datastore_admin_index_list]
  # project_id = "project-id"
  indexes = client.list_indexes(project_id: project_id).map do |index|
    puts "Got index: #{index.index_id}"
    index
  end

  puts "Got list of indexes"
  # [END datastore_admin_index_list]
  indexes
end
