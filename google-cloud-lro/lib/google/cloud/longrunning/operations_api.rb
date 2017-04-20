# Copyright 2016 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# EDITING INSTRUCTIONS
# This file was generated from the file
# https://github.com/googleapis/googleapis/blob/master/google/longrunning/operations.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.
#
# The only allowed edits are to method and file documentation. A 3-way
# merge preserves those additions if the generated source changes.

require "json"
require "pathname"

require "google/gax"

module Google
  module Cloud
    module Longrunning
      # Manages long-running operations with an API service.
      #
      # When an API method normally takes long time to complete, it can be designed
      # to return Operation to the client, and the client can use this
      # interface to receive the real response asynchronously by polling the
      # operation resource, or pass the operation resource to another API (such as
      # Google Cloud Pub/Sub API) to receive the response.  Any API service that
      # returns long-running operations should implement the +Operations+ interface
      # so developers can have a consistent client experience.
      #
      # @!attribute [r] operations_stub
      #   @return [Google::Longrunning::Operations::Stub]
      class OperationsApi
        attr_reader :operations_stub

        # The default address of the service.
        SERVICE_ADDRESS = "longrunning.googleapis.com".freeze

        # The default port of the service.
        DEFAULT_SERVICE_PORT = 443

        CODE_GEN_NAME_VERSION = "gapic/0.1.0".freeze

        DEFAULT_TIMEOUT = 30

        PAGE_DESCRIPTORS = {
          "list_operations" => Google::Gax::PageDescriptor.new(
            "page_token",
            "next_page_token",
            "operations")
        }.freeze

        private_constant :PAGE_DESCRIPTORS

        # The scopes needed to make gRPC calls to all of the methods defined in
        # this service.
        ALL_SCOPES = [
        ].freeze

        OPERATION_PATH_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
          "operations/{operation_path=**}"
        )

        private_constant :OPERATION_PATH_PATH_TEMPLATE

        # Returns a fully-qualified operation_path resource name string.
        # @param operation_path [String]
        # @return [String]
        def self.operation_path_path operation_path
          OPERATION_PATH_PATH_TEMPLATE.render(
            :"operation_path" => operation_path
          )
        end

        # Parses the operation_path from a operation_path resource.
        # @param operation_path_name [String]
        # @return [String]
        def self.match_operation_path_from_operation_path_name operation_path_name
          OPERATION_PATH_PATH_TEMPLATE.match(operation_path_name)["operation_path"]
        end

        # @param service_path [String]
        #   The domain name of the API remote host.
        # @param port [Integer]
        #   The port on which to connect to the remote host.
        # @param channel [Channel]
        #   A Channel object through which to make calls.
        # @param chan_creds [Grpc::ChannelCredentials]
        #   A ChannelCredentials for the setting up the RPC client.
        # @param client_config[Hash]
        #   A Hash for call options for each method. See
        #   Google::Gax#construct_settings for the structure of
        #   this data. Falls back to the default config if not specified
        #   or the specified config is missing data points.
        # @param timeout [Numeric]
        #   The default timeout, in seconds, for calls made through this client.
        # @param app_name [String]
        #   The codename of the calling service.
        # @param app_version [String]
        #   The version of the calling service.
        def initialize \
            service_path: SERVICE_ADDRESS,
            port: DEFAULT_SERVICE_PORT,
            channel: nil,
            chan_creds: nil,
            scopes: ALL_SCOPES,
            client_config: {},
            timeout: DEFAULT_TIMEOUT,
            app_name: "gax",
            app_version: Google::Gax::VERSION
          # These require statements are intentionally placed here to initialize
          # the gRPC module only when it's required.
          # See https://github.com/googleapis/toolkit/issues/446
          require "google/gax/grpc"
          require "google/longrunning/operations_services_pb"

          google_api_client = "#{app_name}/#{app_version} " \
            "#{CODE_GEN_NAME_VERSION} gax/#{Google::Gax::VERSION} " \
            "ruby/#{RUBY_VERSION}".freeze
          headers = { :"x-goog-api-client" => google_api_client }
          client_config_file = Pathname.new(__dir__).join(
            "operations_client_config.json"
          )
          defaults = client_config_file.open do |f|
            Google::Gax.construct_settings(
              "google.longrunning.Operations",
              JSON.parse(f.read),
              client_config,
              Google::Gax::Grpc::STATUS_CODE_NAMES,
              timeout,
              page_descriptors: PAGE_DESCRIPTORS,
              errors: Google::Gax::Grpc::API_ERRORS,
              kwargs: headers
            )
          end
          @operations_stub = Google::Gax::Grpc.create_stub(
            service_path,
            port,
            chan_creds: chan_creds,
            channel: channel,
            scopes: scopes,
            &Google::Longrunning::Operations::Stub.method(:new)
          )

          @get_operation = Google::Gax.create_api_call(
            @operations_stub.method(:get_operation),
            defaults["get_operation"]
          )
          @list_operations = Google::Gax.create_api_call(
            @operations_stub.method(:list_operations),
            defaults["list_operations"]
          )
          @cancel_operation = Google::Gax.create_api_call(
            @operations_stub.method(:cancel_operation),
            defaults["cancel_operation"]
          )
          @delete_operation = Google::Gax.create_api_call(
            @operations_stub.method(:delete_operation),
            defaults["delete_operation"]
          )
        end

        # Service calls

        # Gets the latest state of a long-running operation.  Clients can use this
        # method to poll the operation result at intervals as recommended by the API
        # service.
        #
        # @param name [String]
        #   The name of the operation resource.
        # @param options [Google::Gax::CallOptions]
        #   Overrides the default settings for this call, e.g, timeout,
        #   retries, etc.
        # @return [Google::Longrunning::Operation]
        # @raise [Google::Gax::GaxError] if the RPC is aborted.
        # @example
        #   require "google/cloud/longrunning/operations_api"
        #
        #   OperationsApi = Google::Cloud::Longrunning::OperationsApi
        #
        #   operations_api = OperationsApi.new
        #   formatted_name = OperationsApi.operation_path_path("[OPERATION_PATH]")
        #   response = operations_api.get_operation(formatted_name)

        def get_operation \
            name,
            options: nil
          req = Google::Longrunning::GetOperationRequest.new(
            name: name
          )
          @get_operation.call(req, options)
        end

        # Lists operations that match the specified filter in the request. If the
        # server doesn't support this method, it returns +UNIMPLEMENTED+.
        #
        # NOTE: the +name+ binding below allows API services to override the binding
        # to use different resource name schemes, such as +users/*/operations+.
        #
        # @param name [String]
        #   The name of the operation collection.
        # @param filter [String]
        #   The standard list filter.
        # @param page_size [Integer]
        #   The maximum number of resources contained in the underlying API
        #   response. If page streaming is performed per-resource, this
        #   parameter does not affect the return value. If page streaming is
        #   performed per-page, this determines the maximum number of
        #   resources in a page.
        # @param options [Google::Gax::CallOptions]
        #   Overrides the default settings for this call, e.g, timeout,
        #   retries, etc.
        # @return [Google::Gax::PagedEnumerable<Google::Longrunning::Operation>]
        #   An enumerable of Google::Longrunning::Operation instances.
        #   See Google::Gax::PagedEnumerable documentation for other
        #   operations such as per-page iteration or access to the response
        #   object.
        # @raise [Google::Gax::GaxError] if the RPC is aborted.
        # @example
        #   require "google/cloud/longrunning/operations_api"
        #
        #   OperationsApi = Google::Cloud::Longrunning::OperationsApi
        #
        #   operations_api = OperationsApi.new
        #   name = ''
        #   filter = ''
        #
        #   # Iterate over all results.
        #   operations_api.list_operations(name, filter).each do |element|
        #     # Process element.
        #   end
        #
        #   # Or iterate over results one page at a time.
        #   operations_api.list_operations(name, filter).each_page do |page|
        #     # Process each page at a time.
        #     page.each do |element|
        #       # Process element.
        #     end
        #   end

        def list_operations \
            name,
            filter,
            page_size: nil,
            options: nil
          req = Google::Longrunning::ListOperationsRequest.new(
            name: name,
            filter: filter
          )
          req.page_size = page_size unless page_size.nil?
          @list_operations.call(req, options)
        end

        # Starts asynchronous cancellation on a long-running operation.  The server
        # makes a best effort to cancel the operation, but success is not
        # guaranteed.  If the server doesn't support this method, it returns
        # +google.rpc.Code.UNIMPLEMENTED+.  Clients can use
        # Operations::GetOperation or
        # other methods to check whether the cancellation succeeded or whether the
        # operation completed despite cancellation.
        #
        # @param name [String]
        #   The name of the operation resource to be cancelled.
        # @param options [Google::Gax::CallOptions]
        #   Overrides the default settings for this call, e.g, timeout,
        #   retries, etc.
        # @raise [Google::Gax::GaxError] if the RPC is aborted.
        # @example
        #   require "google/cloud/longrunning/operations_api"
        #
        #   OperationsApi = Google::Cloud::Longrunning::OperationsApi
        #
        #   operations_api = OperationsApi.new
        #   formatted_name = OperationsApi.operation_path_path("[OPERATION_PATH]")
        #   operations_api.cancel_operation(formatted_name)

        def cancel_operation \
            name,
            options: nil
          req = Google::Longrunning::CancelOperationRequest.new(
            name: name
          )
          @cancel_operation.call(req, options)
        end

        # Deletes a long-running operation. This method indicates that the client is
        # no longer interested in the operation result. It does not cancel the
        # operation. If the server doesn't support this method, it returns
        # +google.rpc.Code.UNIMPLEMENTED+.
        #
        # @param name [String]
        #   The name of the operation resource to be deleted.
        # @param options [Google::Gax::CallOptions]
        #   Overrides the default settings for this call, e.g, timeout,
        #   retries, etc.
        # @raise [Google::Gax::GaxError] if the RPC is aborted.
        # @example
        #   require "google/cloud/longrunning/operations_api"
        #
        #   OperationsApi = Google::Cloud::Longrunning::OperationsApi
        #
        #   operations_api = OperationsApi.new
        #   formatted_name = OperationsApi.operation_path_path("[OPERATION_PATH]")
        #   operations_api.delete_operation(formatted_name)

        def delete_operation \
            name,
            options: nil
          req = Google::Longrunning::DeleteOperationRequest.new(
            name: name
          )
          @delete_operation.call(req, options)
        end
      end
    end
  end
end
