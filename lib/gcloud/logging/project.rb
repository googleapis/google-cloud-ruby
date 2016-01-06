# Copyright 2016 Google Inc. All rights reserved.
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


require "gcloud/gce"
require "gcloud/logging/connection"
require "gcloud/logging/credentials"
require "gcloud/logging/errors"
require "gcloud/logging/resource"
require "gcloud/logging/sink"

module Gcloud
  module Logging
    ##
    # # Project
    #
    # Google Cloud Logging collects and stores logs from applications and
    # services on the Google Cloud Platform.
    #
    # @example
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   logging = gcloud.logging
    #   # ...
    #
    # See Gcloud#logging
    class Project
      ##
      # @private The Connection object.
      attr_accessor :connection

      ##
      # @private Creates a new Connection instance.
      def initialize project, credentials
        project = project.to_s # Always cast to a string
        fail ArgumentError, "project is missing" if project.empty?
        @connection = Connection.new project, credentials
      end

      # The Logging project connected to.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new "my-todo-project",
      #                       "/path/to/keyfile.json"
      #   logging = gcloud.logging
      #
      #   logging.project #=> "my-todo-project"
      #
      def project
        connection.project
      end

      ##
      # @private Default project.
      def self.default_project
        ENV["LOGGING_PROJECT"] ||
          ENV["GCLOUD_PROJECT"] ||
          ENV["GOOGLE_CLOUD_PROJECT"] ||
          Gcloud::GCE.project_id
      end

      ##
      # Retrieves the list of monitored resources that are used by Google Cloud
      # Logging.
      #
      # @param [String] token A previously-returned page token representing part
      #   of the larger set of results to view.
      # @param [Integer] max Maximum number of resources to return.
      #
      # @return [Array<Gcloud::Logging::Resource>] (See
      #   {Gcloud::Logging::Resource::List})
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #   resources = logging.resources
      #   resources.each do |resource|
      #     puts resource.name
      #   end
      #
      # @example With pagination: (See {Gcloud::Logging::Resource::List})
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #   resources = logging.resources
      #   loop do
      #     resources.each do |resource|
      #       puts resource.name
      #     end
      #     break unless resources.next?
      #     resources = resources.next
      #   end
      #
      def resources token: nil, max: nil
        ensure_connection!
        resp = connection.list_resources token: token, max: max
        if resp.success?
          Resource::List.from_response resp, connection
        else
          fail ApiError.from_response(resp)
        end
      end
      alias_method :find_resources, :resources

      ##
      # Retrieves the list of sinks belonging to the project.
      #
      # @param [String] token A previously-returned page token representing part
      #   of the larger set of results to view.
      # @param [Integer] max Maximum number of sinks to return.
      #
      # @return [Array<Gcloud::Logging::Sink>] (See
      #   {Gcloud::Logging::Sink::List})
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #   sinks = logging.sinks
      #   sinks.each do |sink|
      #     puts sink.name
      #   end
      #
      # @example With pagination: (See {Gcloud::Logging::Sink::List})
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #   sinks = logging.sinks
      #   loop do
      #     sinks.each do |sink|
      #       puts sink.name
      #     end
      #     break unless sinks.next?
      #     sinks = sinks.next
      #   end
      #
      def sinks token: nil, max: nil
        ensure_connection!
        resp = connection.list_sinks token: token, max: max
        if resp.success?
          Sink::List.from_response resp, connection
        else
          fail ApiError.from_response(resp)
        end
      end
      alias_method :find_sinks, :sinks

      protected

      ##
      # Raise an error unless an active connection is available.
      def ensure_connection!
        fail "Must have active connection" unless connection
      end
    end
  end
end
