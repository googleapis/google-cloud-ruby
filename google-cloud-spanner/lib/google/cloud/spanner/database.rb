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


module Google
  module Cloud
    module Spanner
      ##
      # # Database
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
      # @attr_reader [String] project_id The project ID.
      # @attr_reader [String] instance_id The instance ID.
      # @attr_reader [String] database_id The database ID.
      #
      class Database
        ##
        # @private The gRPC Service object.
        attr_accessor :service

        ##
        # @attr_reader [String] instance_id The instance ID.
        #
        attr_reader :instance_id

        ##
        # @attr_reader [String] database_id The database ID.
        #
        attr_reader :database_id

        # The project ID.
        def project_id
          service.project
        end
        alias_method :project, :project_id

        ##
        # @private Creates a new Spanner Database instance.
        def initialize instance_id, database_id, service
          @instance_id = instance_id
          @database_id = database_id
          @service = service
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
