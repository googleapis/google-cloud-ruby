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
        # @return [Google::Apis::BigqueryV2::RemoteFunctionOptions]
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
        # @return [String] The endpoint of the user-provided remote service.
        #   Returns an empty string if the endpoint is not configured.
        #
        def endpoint
          @gapi.endpoint || ""
        end

        ##
        # Sets the endpoint of the user-provided remote service.
        #
        # @param [String, nil] new_endpoint The new endpoint. Passing `nil` will
        #   clear the endpoint, indicating that no remote service is configured.
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
        # @return [String] The fully qualified name of the user-provided
        #   connection object. Returns an empty string if the connection is not
        #   configured.
        #
        def connection
          @gapi.connection || ""
        end

        ##
        # Sets the fully qualified name of the user-provided connection object.
        #
        # @param [String, nil] new_connection The new connection. Passing `nil`
        #   will clear the connection, indicating that no authentication
        #   information is configured for the remote service.
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
        # @return [Hash] The user-defined context. Returns an empty hash if no
        #   context is configured.
        #
        def user_defined_context
          @gapi.user_defined_context || {}
        end

        ##
        # Sets the user-defined context.
        #
        # @param [Hash, nil] new_user_defined_context The new user-defined
        #   context. Passing `nil` will clear the context, meaning no
        #   user-defined key-value pairs will be sent.
        #
        def user_defined_context= new_user_defined_context
          @gapi.user_defined_context = new_user_defined_context
        end

        ##
        # Max number of rows in each batch sent to the remote service. If absent
        # or if 0, BigQuery dynamically decides the number of rows in a batch.
        #
        # @return [Integer] Max number of rows in each batch. Returns `0` if not
        #   set, which indicates that BigQuery dynamically decides the number of
        #   rows.
        #
        def max_batching_rows
          @gapi.max_batching_rows || 0
        end

        ##
        # Sets the max number of rows in each batch sent to the remote service.
        #
        # @param [Integer, nil] new_max_batching_rows The new max batching rows.
        #   Passing `nil` or `0` will reset the batch size, indicating that
        #   BigQuery should dynamically decide the number of rows in each batch.
        #
        def max_batching_rows= new_max_batching_rows
          @gapi.max_batching_rows = new_max_batching_rows
        end

        # @private New RemoteFunctionOptions from a Google API Client object.
        def self.from_gapi gapi
          return nil if gapi.nil?
          new.tap do |rfo|
            rfo.instance_variable_set :@gapi, gapi
          end
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
