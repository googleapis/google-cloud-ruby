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

def export_assets project_id:, dump_file_path:
  # [START asset_quickstart_export_assets]
  require "google/cloud/asset"

  asset_service = Google::Cloud::Asset.asset_service
  # project_id = 'YOUR_PROJECT_ID'
  formatted_parent = asset_service.project_path project: project_id
  # Assets dump file path, e.g.: gs://[YOUR_BUCKET]/[YOUR_ASSETS_FILE]
  # dump_file_path = 'YOUR_ASSET_DUMP_FILE_PATH'
  output_config = {
    gcs_destination: {
      uri: dump_file_path
    }
  }

  operation = asset_service.export_assets(
    parent: formatted_parent, output_config: output_config
  ) do |op|
    # Handle the error.
    raise op.results.message if op.error?
  end

  operation.wait_until_done!
  # Do things with the result
  # [END asset_quickstart_export_assets]
end

def batch_get_history project_id:, asset_names:
  # [START asset_quickstart_batch_get_assets_history]
  require "google/cloud/asset"

  # project_id = 'YOUR_PROJECT_ID'
  # asset names, e.g.: //storage.googleapis.com/[YOUR_BUCKET_NAME]
  # asset_names = [ASSET_NAMES, COMMMA_DELIMTTED]
  asset_service = Google::Cloud::Asset.asset_service

  formatted_parent = asset_service.project_path project: project_id

  content_type = :RESOURCE
  read_time_window = {
    start_time: {
      seconds: Time.now.getutc.to_i
    }
  }

  response = asset_service.batch_get_assets_history(
    parent:           formatted_parent,
    content_type:     content_type,
    read_time_window: read_time_window,
    asset_names:      asset_names
  )
  # Do things with the response
  puts response.assets
  # [END asset_quickstart_batch_get_assets_history]
end

def create_feed project_id:, feed_id:, pubsub_topic:, asset_names:
  # [START asset_quickstart_create_feed]
  require "google/cloud/asset"

  # project_id = 'YOUR_PROJECT_ID'
  # feed_id = 'NAME_OF_FEED'
  # pubsub_topic = 'YOUR_PUBSUB_TOPIC'
  # asset names, e.g.: //storage.googleapis.com/[YOUR_BUCKET_NAME]
  # asset_names = [ASSET_NAMES, COMMMA_DELIMTTED]
  asset_service = Google::Cloud::Asset.asset_service

  formatted_parent = asset_service.project_path project: project_id

  feed = {
    asset_names:        asset_names,
    feed_output_config: {
      pubsub_destination: {
        topic: pubsub_topic
      }
    }
  }
  response = asset_service.create_feed(
    parent:  formatted_parent,
    feed_id: feed_id,
    feed:    feed
  )
  puts "Created feed: #{response.name}"
  # [END asset_quickstart_create_feed]
end
