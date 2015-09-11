#--
# Copyright 2015 Google Inc. All rights reserved.
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

require "gcloud/version"
require "google/api_client"

module Gcloud
  module Dns
    ##
    # Represents the connection to DNS,
    # as well as expose the API calls.
    class Connection #:nodoc:
      API_VERSION = "v1"

      attr_accessor :project
      attr_accessor :credentials #:nodoc:

      ##
      # Creates a new Connection instance.
      def initialize project, credentials #:nodoc:
        @project = project
        @credentials = credentials
        @client = Google::APIClient.new application_name:    "gcloud-ruby",
                                        application_version: Gcloud::VERSION
        @client.authorization = @credentials.client
        @dns = @client.discovered_api "dns", API_VERSION
      end

      def get_project project_id = @project
        @client.execute(
          api_method: @dns.projects.get,
          parameters: { project: project_id }
        )
      end

      def get_zone zone_id
        @client.execute(
          api_method: @dns.managed_zones.get,
          parameters: { project: @project, managedZone: zone_id }
        )
      end

      def list_zones options = {}
        params = { project: @project,
                   pageToken: options.delete(:token),
                   maxResults: options.delete(:max)
                 }.delete_if { |_, v| v.nil? }

        @client.execute(
          api_method: @dns.managed_zones.list,
          parameters: params
        )
      end

      def create_zone zone_name, zone_dns, options = {}
        body = { kind: "dns#managedZone",
                 name: zone_name, dnsName: zone_dns,
                 description: (options[:description] || ""),
                 nameServerSet: options[:name_server_set]
               }.delete_if { |_, v| v.nil? }

        @client.execute(
          api_method: @dns.managed_zones.create,
          parameters: { project: @project },
          body_object: body
        )
      end

      def delete_zone zone_id
        @client.execute(
          api_method: @dns.managed_zones.delete,
          parameters: { project: @project, managedZone: zone_id }
        )
      end

      def get_change zone_id, change_id
        @client.execute(
          api_method: @dns.changes.get,
          parameters: { project: @project, managedZone: zone_id,
                        changeId: change_id }
        )
      end

      def list_changes zone_id, options = {}
        params = { project: @project, managedZone: zone_id,
                   pageToken: options.delete(:token),
                   maxResults: options.delete(:max),
                   sortBy: options.delete(:sort),
                   sortOrder: options.delete(:order)
                 }.delete_if { |_, v| v.nil? }

        @client.execute(
          api_method: @dns.changes.list,
          parameters: params
        )
      end

      def inspect #:nodoc:
        "#{self.class}(#{@project})"
      end
    end
  end
end
