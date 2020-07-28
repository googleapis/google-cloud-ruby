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

def create_notification_config org_id:, config_id:, pubsub_topic:
  # [START scc_create_notification_config]
  require "google/cloud/security_center"

  # Your organization id. e.g. for "organizations/123", this would be "123".
  # org_id = "YOUR_ORGANZATION_ID"

  # Your notification config id. e.g. for
  # "organizations/123/notificationConfigs/my-config" this would be "my-config".
  # config_id = "YOUR_CONFIG_ID"

  # The PubSub topic where notifications will be published.
  # pubsub_topic = "YOUR_TOPIC"

  client = Google::Cloud::SecurityCenter.security_center

  org_path = client.organization_path organization: org_id

  notification_config = {
    description:      "Sample config for Ruby",
    pubsub_topic:     pubsub_topic,
    streaming_config: { filter: 'state = "ACTIVE"' }
  }

  response = client.create_notification_config(
    parent:              org_path,
    config_id:           config_id,
    notification_config: notification_config
  )
  puts "Created notification config #{config_id}: #{response}."
  # [END scc_create_notification_config]
end

def update_notification_config org_id:, config_id:, description: nil, pubsub_topic: nil, filter: nil
  # [START scc_update_notification_config]
  require "google/cloud/security_center"

  # Your organization id. e.g. for "organizations/123", this would be "123".
  # org_id = "YOUR_ORGANZATION_ID"

  # Your notification config id. e.g. for
  # "organizations/123/notificationConfigs/my-config" this would be "my-config".
  # config_id = "YOUR_CONFIG_ID"

  # Updated description of the notification config.
  # description = "YOUR_DESCRIPTION"

  # The PubSub topic where notifications will be published.
  # pubsub_topic = "YOUR_TOPIC"

  # Updated filter string for Notification config. 
  # filter = "UPDATED_FILTER"

  client = Google::Cloud::SecurityCenter.security_center

  config_path = client.notification_config_path organization:        org_id,
                                                notification_config: config_id
  notification_config = { name: config_path }
  notification_config[:description] = description unless description.nil?
  notification_config[:pubsub_topic] = pubsub_topic unless pubsub_topic.nil?
  notification_config[:streaming_config][:filter] = filter unless filter.nil?

  paths = []
  paths.push "description" unless description.nil?
  paths.push "pubsub_topic" unless pubsub_topic.nil?
  paths.push "streaming_config.filter" unless filter.nil?
  update_mask = { paths: paths }

  response = client.update_notification_config(
    notification_config: notification_config,
    update_mask:         update_mask
  )
  puts response
  # [END scc_update_notification_config]
end

def delete_notification_config org_id:, config_id:
  # [START scc_delete_notification_config]
  require "google/cloud/security_center"

  # Your organization id. e.g. for "organizations/123", this would be "123".
  # org_id = "YOUR_ORGANZATION_ID"

  # Your notification config id. e.g. for
  # "organizations/123/notificationConfigs/my-config" this would be "my-config".
  # config_id = "YOUR_CONFIG_ID"

  client = Google::Cloud::SecurityCenter.security_center

  config_path = client.notification_config_path organization:        org_id,
                                                notification_config: config_id

  response = client.delete_notification_config name: config_path
  puts "Deleted notification config #{config_id} with response: #{response}"
  # [END scc_delete_notification_config]
end

def get_notification_config org_id:, config_id:
  # [START scc_get_notification_config]
  require "google/cloud/security_center"

  # Your organization id. e.g. for "organizations/123", this would be "123".
  # org_id = "YOUR_ORGANZATION_ID"

  # Your notification config id. e.g. for
  # "organizations/123/notificationConfigs/my-config" this would be "my-config".
  # config_id = "YOUR_CONFIG_ID"

  client = Google::Cloud::SecurityCenter.security_center

  config_path = client.notification_config_path organization:        org_id,
                                                notification_config: config_id

  response = client.get_notification_config name: config_path
  puts "Notification config fetched: #{response}"
  # [END scc_get_notification_config]
end

def list_notification_configs org_id:
  # [START scc_list_notification_configs]
  require "google/cloud/security_center"

  # Your organization id. e.g. for "organizations/123", this would be "123".
  # org_id = "YOUR_ORGANZATION_ID"

  client = Google::Cloud::SecurityCenter.security_center

  org_path = client.organization_path organization: org_id

  client.list_notification_configs(parent: org_path).each_page do |page|
    page.each do |element|
      puts element
    end
  end
  # [END scc_list_notification_configs]
end

if $PROGRAM_NAME == __FILE__
  case ARGV.shift
  when "create_notification_config"
    create_notification_config org_id:       ARGV.shift,
                               config_id:    ARGV.shift,
                               pubsub_topic: ARGV.shift
  when "delete_notification_config"
    delete_notification_config org_id:    ARGV.shift,
                               config_id: ARGV.shift
  when "update_notification_config"
    update_notification_config org_id:       ARGV.shift,
                               config_id:    ARGV.shift,
                               description:  ARGV.shift,
                               pubsub_topic: ARGV.shift,
                               filter:       ARGV.shift
  when "get_notification_config"
    get_notification_config org_id:    ARGV.shift,
                            config_id: ARGV.shift

  when "list_notification_configs"
    list_notification_configs org_id: ARGV.shift
  else
    puts <<~USAGE
      Usage: bundle exec ruby notification.rb [command] [arguments]

      Commands:
        create_notification_config  <org_id> <config_id> <pubsub_topic>                Creates a Notification config
        delete_notification_config  <org_id> <config_id>                               Deletes a Notification config
        get_notification_config     <org_id> <config_id>                               Fetches a Notification config
        update_notification_config  <org_id> <config_id> <description> <pubsub_topic> <filter>  Updates a Notification config
        list_notification_configs   <org_id>                                           Lists Notification configs in an organization
    USAGE
  end
end
