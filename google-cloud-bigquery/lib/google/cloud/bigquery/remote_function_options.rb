# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module Google
  module Cloud
    module Bigquery
      ##
      # # RemoteFunctionOptions
      #
      # Options for a remote user-defined function.
      #
      class RemoteFunctionOptions
        ##
        # @private The Google API Client object.
        attr_accessor :gapi

        ##
        # Creates a new RemoteFunctionOptions object.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   remote_function_options = Google::Cloud::Bigquery::RemoteFunctionOptions.new.tap do |rfo|
        #     rfo.endpoint = "https://us-east1-my_gcf_project.cloudfunctions.net/remote_add"
        #     rfo.connection = "projects/my-project/locations/us-east1/connections/my-connection"
        #     rfo.user_defined_context = { "foo" => "bar" }
        #   end
        #
        def initialize
          @gapi = Google::Apis::BigqueryV2::RemoteFunctionOptions.new
        end

        ##
        # The endpoint of the user-provided remote service, e.g.
        # `https://us-east1-my_gcf_project.cloudfunctions.net/remote_add`.
        #
        # @return [String, nil]
        #
        def endpoint
          @gapi.endpoint
        end

        ##
        # Sets the endpoint of the user-provided remote service.
        #
        # @param [String] new_endpoint
        #
        def endpoint= new_endpoint
          @gapi.endpoint = new_endpoint
        end

        ##
        # The fully qualified name of the user-provided connection object which
        # holds the authentication information to send requests to the remote
        # service.
        #
        # Format:
        # `projects/{projectId}/locations/{locationId}/connections/{connectionId}`
        #
        # @return [String, nil]
        #
        def connection
          @gapi.connection
        end

        ##
        # Sets the fully qualified name of the user-provided connection object.
        #
        # @param [String] new_connection
        #
        def connection= new_connection
          @gapi.connection = new_connection
        end

        ##
        # User-defined context as a set of key/value pairs, which will be sent
        # as function invocation context together with batched arguments in the
        # requests to the remote service. The total number of bytes of keys and
        # values must be less than 8KB.
        #
        # @return [Hash, nil]
        #
        def user_defined_context
          @gapi.user_defined_context
        end

        ##
        # Sets the user-defined context.
        #
        # @param [Hash] new_user_defined_context
        #
        def user_defined_context= new_user_defined_context
          @gapi.user_defined_context = new_user_defined_context
        end

        ##
        # Max number of rows in each batch sent to the remote service. If absent
        # or if 0, BigQuery dynamically decides the number of rows in a batch.
        #
        # @return [Integer, nil]
        #
        def max_batching_rows
          @gapi.max_batching_rows
        end

        ##
        # Sets the max number of rows in each batch sent to the remote service.
        #
        # @param [Integer] new_max_batching_rows
        #
        def max_batching_rows= new_max_batching_rows
          @gapi.max_batching_rows = new_max_batching_rows
        end

        # @private New RemoteFunctionOptions from a Google API Client object.
        def self.from_gapi gapi
          return nil if gapi.nil?
          updated_gapi = Google::Apis::BigqueryV2::RemoteFunctionOptions.new \
            endpoint: gapi.endpoint,
            connection: gapi.connection,
            user_defined_context: gapi.user_defined_context,
            max_batching_rows: gapi.max_batching_rows
          instance_variable_set :@gapi, updated_gapi
        end

        ##
        # @private Returns the Google API Client object.
        def to_gapi
          @gapi
        end
      end
    end
  end
end
