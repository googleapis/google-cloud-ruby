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


require "google/cloud/spanner/database"

module Google
  module Cloud
    module Spanner
      ##
      # # Instance
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
      class Instance
        ##
        # @private The gRPC Service object.
        attr_accessor :service

        ##
        # @attr_reader [String] instance_id The instance ID.
        #
        attr_reader :instance_id

        # The project ID.
        def project_id
          service.project
        end
        alias_method :project, :project_id

        ##
        # @private Creates a new Spanner Instance instance.
        def initialize instance_id, service
          @instance_id = instance_id
          @service = service
        end

        def database database_id = nil
          ensure_service!
          database_id ||= ENV["GCLOUD_DATABASE"]
          Database.new instance_id, database_id, service
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
