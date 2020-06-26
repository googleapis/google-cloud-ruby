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

require "pp"

# [START monitoring_uptime_check_list_ips]
def list_ips
  require "google/cloud/monitoring"
  client = Google::Cloud::Monitoring.uptime_check_service

  # Iterate over all results.
  client.list_uptime_check_ips({}).each do |element|
    puts "#{element.location} #{element.ip_address}"
  end
end
# [END monitoring_uptime_check_list_ips]

# [START monitoring_uptime_check_create]
def create_uptime_check_config project_id: nil, host_name: nil, display_name: nil
  require "google/cloud/monitoring"

  client = Google::Cloud::Monitoring.uptime_check_service
  project_name = client.project_path project: project_id
  config = {
    display_name:       display_name.nil? ? "New uptime check" : display_name,
    monitored_resource: {
      type:   "uptime_url",
      labels: { "host" => host_name.nil? ? "example.com" : host_name }
    },
    http_check:         { path: "/", port: 80 },
    timeout:            { seconds: 10 },
    period:             { seconds: 300 }
  }
  new_config = client.create_uptime_check_config \
    parent:              project_name,
    uptime_check_config: config
  puts new_config.name
  new_config
end
# [END monitoring_uptime_check_create]

# [START monitoring_uptime_check_delete]
def delete_uptime_check_config config_name
  require "google/cloud/monitoring"

  client = Google::Cloud::Monitoring.uptime_check_service
  client.delete_uptime_check_config name: config_name
  puts "Deleted #{config_name}"
end
# [END monitoring_uptime_check_delete]


# [START monitoring_uptime_check_list_configs]
def list_uptime_check_configs project_id
  require "google/cloud/monitoring"

  client = Google::Cloud::Monitoring.uptime_check_service
  project_name = client.project_path project: project_id
  configs = client.list_uptime_check_configs parent: project_name

  configs.each { |config| puts config.name }
end
# [END monitoring_uptime_check_list_configs]

# [START monitoring_uptime_check_get]
def get_uptime_check_config config_name
  require "google/cloud/monitoring"

  client = Google::Cloud::Monitoring.uptime_check_service
  config = client.get_uptime_check_config name: config_name
  pp config.to_h
  config
end
# [END monitoring_uptime_check_get]

# [START monitoring_uptime_check_update]
def update_uptime_check_config config_name:         nil,
                               new_display_name:    nil,
                               new_http_check_path: nil
  require "google/cloud/monitoring"

  client = Google::Cloud::Monitoring.uptime_check_service
  config = { name: config_name }
  field_mask = { paths: [] }
  unless new_display_name.to_s.empty?
    field_mask[:paths].push "display_name"
    config[:display_name] = new_display_name
  end
  unless new_http_check_path.to_s.empty?
    field_mask[:paths].push "http_check.path"
    config[:http_check] = { path: new_http_check_path }
  end
  client.update_uptime_check_config uptime_check_config: config,
                                    update_mask:         field_mask
end
# [END monitoring_uptime_check_update]

if $PROGRAM_NAME == __FILE__
  command = ARGV.shift

  case command
  when "list_ips"
    list_ips
  when "create_uptime_check"
    create_uptime_check_config(
      project_id:   ARGV.shift.to_s,
      host_name:    ARGV.shift.to_s,
      display_name: ARGV.shift.to_s
    )
  when "delete_uptime_check"
    delete_uptime_check_config ARGV.shift.to_s
  when "list_uptime_check"
    list_uptime_check_configs ARGV.shift.to_s
  when "get_uptime_check"
    get_uptime_check_config ARGV.shift.to_s
  when "update_uptime_check"
    update_uptime_check_config(
      config_name:         ARGV.shift.to_s,
      new_display_name:    ARGV.shift.to_s,
      new_http_check_path: ARGV.shift.to_s
    )
  else
    puts <<~USAGE
      Usage: ruby uptime_check.rb <command> [arguments]

      Commands:
        list_ips  Lists the ip address of uptime check servers.
        create_uptime_check  <project_id> <host_name> <display_name> Create a new uptime check
        delete_uptime_check  <name>  Deletes an uptime check.
        get_uptime_check  <name>  Gets the full details for an uptime check.
        list_uptime_check  <project_id>  Lists the uptime checks.
        update_uptime_check  <name> <new_display_name> <new_http_path>

      Environment variables:
        GOOGLE_APPLICATION_CREDENTIALS set to the path to your JSON credentials
    USAGE
  end
end
