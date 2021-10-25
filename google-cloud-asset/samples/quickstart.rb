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
  response = operation.response
  puts "Exported assets to: #{response.output_config.gcs_destination.uri}"
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

def list_assets project_id:
  # [START asset_quickstart_list_assets]
  require "google/cloud/asset"

  asset_service = Google::Cloud::Asset.asset_service
  # project_id = 'YOUR_PROJECT_ID'
  formatted_parent = asset_service.project_path project: project_id

  content_type = :RESOURCE
  response = asset_service.list_assets(
    parent:           formatted_parent,
    content_type:     content_type
  )

  # Do things with the result
  response.page.each do |resource|
    puts resource
  end
  # [END asset_quickstart_list_assets]
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

def search_all_resources scope: "", query: "", asset_types: [], page_size: 0, page_token: "", order_by: ""
  # [START asset_quickstart_search_all_resources]
  require "google/cloud/asset"

  # scope = 'SCOPE_OF_THE_QUERY'
  # query = 'QUERY_STATEMENT'
  # asset_types = 'AN_ARRAY_OF_ASSET_TYPES_TO_SEARCH_FOR'
  # page_size = 'SIZE_OF_EACH_RESULT_PAGE'
  # page_token = 'TOKEN_PRODUCED_BY_THE_PRECEDING_CALL'
  # order_by = 'FIELDS_TO_SORT_THE RESULTS'
  asset_service = Google::Cloud::Asset.asset_service

  response = asset_service.search_all_resources(
    scope:       scope,
    query:       query,
    asset_types: asset_types,
    page_size:   page_size,
    page_token:  page_token,
    order_by:    order_by
  )
  # Do things with the response
  response.page.each do |resource|
    puts resource
  end
  # [END asset_quickstart_search_all_resources]
end

def search_all_iam_policies scope: "", query: "", page_size: 0, page_token: ""
  # [START asset_quickstart_search_all_iam_policies]
  require "google/cloud/asset"

  # scope = 'SCOPE_OF_THE_QUERY'
  # query = 'QUERY_STATEMENT'
  # page_size = 'SIZE_OF_EACH_RESULT_PAGE'
  # page_token = 'TOKEN_PRODUCED_BY_THE_PRECEDING_CALL'
  asset_service = Google::Cloud::Asset.asset_service

  response = asset_service.search_all_iam_policies(
    scope:      scope,
    query:      query,
    page_size:  page_size,
    page_token: page_token
  )
  # Do things with the response
  response.page.each do |policy|
    puts policy
  end
  # [END asset_quickstart_search_all_iam_policies]
end

def analyze_iam_policy scope: "", full_resource_name: ""
  # [START asset_quickstart_analyze_iam_policy]
  require "google/cloud/asset"

  # scope = 'SCOPE_OF_THE_QUERY'
  # full_resource_name = 'QUERY_RESOURCE'
  asset_service = Google::Cloud::Asset.asset_service

  query = {
    scope:             scope,
    resource_selector: {
      full_resource_name: full_resource_name
    },
    options:           {
      expand_groups:      true,
      output_group_edges: true
    }
  }

  response = asset_service.analyze_iam_policy analysis_query: query
  # Do things with the response
  puts response
  # [END asset_quickstart_analyze_iam_policy]
end

def analyze_iam_policy_longrunning_gcs scope: "", full_resource_name: "", uri: ""
  # [START asset_quickstart_analyze_iam_policy_lognrunning_gcs]
  require "google/cloud/asset"

  # scope = 'SCOPE_OF_THE_QUERY'
  # full_resource_name = 'QUERY_RESOURCE'
  # uri = 'OUTPUT_GCS_URI'
  asset_service = Google::Cloud::Asset.asset_service

  query = {
    scope:             scope,
    resource_selector: {
      full_resource_name: full_resource_name
    },
    options:           {
      expand_groups:      true,
      output_group_edges: true
    }
  }
  output_config = {
    gcs_destination: {
      uri: uri
    }
  }

  operation = asset_service.analyze_iam_policy_longrunning(
    analysis_query: query,
    output_config:  output_config
  )

  operation.wait_until_done!
  puts "Wrote analysis results to: #{uri}"
  # Do things with the result
  # [END asset_quickstart_analyze_iam_policy_lognrunning_gcs]
end

def analyze_iam_policy_longrunning_bigquery scope: "", full_resource_name: "", dataset: "", table_prefix: ""
  # [START analyze_iam_policy_longrunning_bigquery]
  require "google/cloud/asset"

  # scope = 'SCOPE_OF_THE_QUERY'
  # full_resource_name = 'QUERY_RESOURCE'
  # dataset = 'BIGQUERY_DATASET'
  # table_prefix = 'BIGQUERY_TABLE_PREFIX'
  asset_service = Google::Cloud::Asset.asset_service

  query = {
    scope:             scope,
    resource_selector: {
      full_resource_name: full_resource_name
    },
    options:           {
      expand_groups:      true,
      output_group_edges: true
    }
  }
  output_config = {
    bigquery_destination: {
      dataset:      dataset,
      table_prefix: table_prefix
    }
  }

  operation = asset_service.analyze_iam_policy_longrunning(
    analysis_query: query,
    output_config:  output_config
  )

  operation.wait_until_done!
  puts "Wrote analysis results to: #{dataset}"
  # Do things with the result
  # [END analyze_iam_policy_longrunning_bigquery]
end
