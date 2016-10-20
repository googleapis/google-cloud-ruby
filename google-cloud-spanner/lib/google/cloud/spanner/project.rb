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


require "google/cloud/errors"
require "google/cloud/core/environment"
require "google/cloud/spanner/service"
require "google/cloud/spanner/instance"
require "google/cloud/spanner/database"

module Google
  module Cloud
    module Spanner
      ##
      # # Project
      #
      # ...
      #
      # See {Google::Cloud#spanner}
      #
      # @example
      #   require "google/cloud"
      #
      #   gcloud = Google::Cloud.new
      #   spanner = gcloud.spanner
      #
      #   # ...
      #
      class Project
        ##
        # @private The gRPC Service object.
        attr_accessor :service

        ##
        # @private Creates a new Spanner Project instance.
        def initialize service
          @service = service
        end

        # The Spanner project connected to.
        #
        # @example
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new "my-project-id",
        #                              "/path/to/keyfile.json"
        #   spanner = gcloud.spanner
        #
        #   spanner.project #=> "my-project-id"
        #
        def project
          service.project
        end
        alias_method :project_id, :project

        ##
        # @private Default project.
        def self.default_project
          ENV["SPANNER_PROJECT"] ||
            ENV["GOOGLE_CLOUD_PROJECT"] ||
            ENV["GCLOUD_PROJECT"] ||
            Google::Cloud::Core::Environment.project_id
        end

        def instance instance_id = nil
          ensure_service!
          instance_id ||= ENV["GCLOUD_INSTANCE"]
          Instance.new instance_id, service
        end

        protected

        ##
        # @private Raise an error unless an active connection to the service is
        # available.
        def ensure_service!
          fail "Must have active connection to service" unless service
        end
      end
    end
  end
end
