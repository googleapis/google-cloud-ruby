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

      protected

      ##
      # Raise an error unless an active connection is available.
      def ensure_connection!
        fail "Must have active connection" unless connection
      end
    end
  end
end
