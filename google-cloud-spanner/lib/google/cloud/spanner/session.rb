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
      # # Session
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
      class Session
        ##
        # @private The gRPC Service object.
        attr_accessor :service

        # @private Creates a new Session instance.
        def initialize grpc, service
          @grpc = grpc
          @service = service
        end

        # The unique identifier for the project.
        # @return [String]
        def project_id
          V1::SpannerClient.match_project_from_session_name @grpc.name
        end

        # The unique identifier for the instance.
        # @return [String]
        def instance_id
          V1::SpannerClient.match_instance_from_session_name @grpc.name
        end

        # The unique identifier for the database.
        # @return [String]
        def database_id
          V1::SpannerClient.match_database_from_session_name @grpc.name
        end

        # The unique identifier for the session.
        # @return [String]
        def session_id
          V1::SpannerClient.match_session_from_session_name @grpc.name
        end

        # rubocop:disable LineLength

        ##
        # The full path for the session resource. Values are of the form
        # `projects/<project_id>/instances/<instance_id>/databases/<database_id>/sessions/<session_id>`.
        # @return [String]
        def path
          @grpc.name
        end

        # rubocop:enable LineLength

        ##
        # Reloads the session resource. Useful for determining if the session is
        # still valid on the Spanner API.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.session "my-instance", "my-database"
        #
        #   db.reload! # API call
        #
        def reload!
          ensure_service!
          @grpc = service.get_session path
          self
        end

        ##
        # Permanently deletes the session.
        #
        # @return [Boolean] Returns `true` if the session was deleted.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.session "my-instance", "my-database"
        #
        #   db.delete
        #
        def delete
          ensure_service!
          service.delete_session path
          true
        end

        ##
        # @private Creates a new Session instance from a
        # Google::Spanner::V1::Session.
        def self.from_grpc grpc, service
          new grpc, service
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
