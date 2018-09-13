# Copyright 2018 Google LLC
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
#
# EDITING INSTRUCTIONS
# This file was generated from the file
# https://github.com/googleapis/googleapis/blob/master/google/devtools/clouddebugger/v2/debugger.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.


require "json"
require "pathname"

require "google/gax"

require "google/devtools/clouddebugger/v2/debugger_pb"
require "google/cloud/debugger/v2/credentials"

module Google
  module Cloud
    module Debugger
      module V2
        # The Debugger service provides the API that allows users to collect run-time
        # information from a running application, without stopping or slowing it down
        # and without modifying its state.  An application may include one or
        # more replicated processes performing the same work.
        #
        # A debugged application is represented using the Debuggee concept. The
        # Debugger service provides a way to query for available debuggees, but does
        # not provide a way to create one.  A debuggee is created using the Controller
        # service, usually by running a debugger agent with the application.
        #
        # The Debugger service enables the client to set one or more Breakpoints on a
        # Debuggee and collect the results of the set Breakpoints.
        #
        # @!attribute [r] debugger2_stub
        #   @return [Google::Devtools::Clouddebugger::V2::Debugger2::Stub]
        class Debugger2Client
          # @private
          attr_reader :debugger2_stub

          # The default address of the service.
          SERVICE_ADDRESS = "clouddebugger.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          # The default set of gRPC interceptors.
          GRPC_INTERCEPTORS = []

          DEFAULT_TIMEOUT = 30

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform",
            "https://www.googleapis.com/auth/cloud_debugger"
          ].freeze


          # @param credentials [Google::Auth::Credentials, String, Hash, GRPC::Core::Channel, GRPC::Core::ChannelCredentials, Proc]
          #   Provides the means for authenticating requests made by the client. This parameter can
          #   be many types.
          #   A `Google::Auth::Credentials` uses a the properties of its represented keyfile for
          #   authenticating requests made by this client.
          #   A `String` will be treated as the path to the keyfile to be used for the construction of
          #   credentials for this client.
          #   A `Hash` will be treated as the contents of a keyfile to be used for the construction of
          #   credentials for this client.
          #   A `GRPC::Core::Channel` will be used to make calls through.
          #   A `GRPC::Core::ChannelCredentials` for the setting up the RPC client. The channel credentials
          #   should already be composed with a `GRPC::Core::CallCredentials` object.
          #   A `Proc` will be used as an updater_proc for the Grpc channel. The proc transforms the
          #   metadata for requests, generally, to give OAuth credentials.
          # @param scopes [Array<String>]
          #   The OAuth scopes for this service. This parameter is ignored if
          #   an updater_proc is supplied.
          # @param client_config [Hash]
          #   A Hash for call options for each method. See
          #   Google::Gax#construct_settings for the structure of
          #   this data. Falls back to the default config if not specified
          #   or the specified config is missing data points.
          # @param timeout [Numeric]
          #   The default timeout, in seconds, for calls made through this client.
          # @param metadata [Hash]
          #   Default metadata to be sent with each request. This can be overridden on a per call basis.
          # @param exception_transformer [Proc]
          #   An optional proc that intercepts any exceptions raised during an API call to inject
          #   custom error handling.
          def initialize \
              credentials: nil,
              scopes: ALL_SCOPES,
              client_config: {},
              timeout: DEFAULT_TIMEOUT,
              metadata: nil,
              exception_transformer: nil,
              lib_name: nil,
              lib_version: ""
            # These require statements are intentionally placed here to initialize
            # the gRPC module only when it's required.
            # See https://github.com/googleapis/toolkit/issues/446
            require "google/gax/grpc"
            require "google/devtools/clouddebugger/v2/debugger_services_pb"

            credentials ||= Google::Cloud::Debugger::V2::Credentials.default

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Debugger::V2::Credentials.new(credentials).updater_proc
            end
            if credentials.is_a?(GRPC::Core::Channel)
              channel = credentials
            end
            if credentials.is_a?(GRPC::Core::ChannelCredentials)
              chan_creds = credentials
            end
            if credentials.is_a?(Proc)
              updater_proc = credentials
            end
            if credentials.is_a?(Google::Auth::Credentials)
              updater_proc = credentials.updater_proc
            end

            package_version = Gem.loaded_specs['google-cloud-debugger'].version.version

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/#{package_version} gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            headers.merge!(metadata) unless metadata.nil?
            client_config_file = Pathname.new(__dir__).join(
              "debugger2_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.devtools.clouddebugger.v2.Debugger2",
                JSON.parse(f.read),
                client_config,
                Google::Gax::Grpc::STATUS_CODE_NAMES,
                timeout,
                errors: Google::Gax::Grpc::API_ERRORS,
                metadata: headers
              )
            end

            # Allow overriding the service path/port in subclasses.
            service_path = self.class::SERVICE_ADDRESS
            port = self.class::DEFAULT_SERVICE_PORT
            interceptors = self.class::GRPC_INTERCEPTORS
            @debugger2_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Devtools::Clouddebugger::V2::Debugger2::Stub.method(:new)
            )

            @set_breakpoint = Google::Gax.create_api_call(
              @debugger2_stub.method(:set_breakpoint),
              defaults["set_breakpoint"],
              exception_transformer: exception_transformer
            )
            @get_breakpoint = Google::Gax.create_api_call(
              @debugger2_stub.method(:get_breakpoint),
              defaults["get_breakpoint"],
              exception_transformer: exception_transformer
            )
            @delete_breakpoint = Google::Gax.create_api_call(
              @debugger2_stub.method(:delete_breakpoint),
              defaults["delete_breakpoint"],
              exception_transformer: exception_transformer
            )
            @list_breakpoints = Google::Gax.create_api_call(
              @debugger2_stub.method(:list_breakpoints),
              defaults["list_breakpoints"],
              exception_transformer: exception_transformer
            )
            @list_debuggees = Google::Gax.create_api_call(
              @debugger2_stub.method(:list_debuggees),
              defaults["list_debuggees"],
              exception_transformer: exception_transformer
            )
          end

          # Service calls

          # Sets the breakpoint to the debuggee.
          #
          # @param debuggee_id [String]
          #   ID of the debuggee where the breakpoint is to be set.
          # @param breakpoint [Google::Devtools::Clouddebugger::V2::Breakpoint | Hash]
          #   Breakpoint specification to set.
          #   The field `location` of the breakpoint must be set.
          #   A hash of the same form as `Google::Devtools::Clouddebugger::V2::Breakpoint`
          #   can also be provided.
          # @param client_version [String]
          #   The client version making the call.
          #   Schema: `domain/type/version` (e.g., `google.com/intellij/v1`).
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Devtools::Clouddebugger::V2::SetBreakpointResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Devtools::Clouddebugger::V2::SetBreakpointResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/debugger/v2"
          #
          #   debugger2_client = Google::Cloud::Debugger::V2::Debugger2.new
          #
          #   # TODO: Initialize `debuggee_id`:
          #   debuggee_id = ''
          #
          #   # TODO: Initialize `breakpoint`:
          #   breakpoint = {}
          #
          #   # TODO: Initialize `client_version`:
          #   client_version = ''
          #   response = debugger2_client.set_breakpoint(debuggee_id, breakpoint, client_version)

          def set_breakpoint \
              debuggee_id,
              breakpoint,
              client_version,
              options: nil,
              &block
            req = {
              debuggee_id: debuggee_id,
              breakpoint: breakpoint,
              client_version: client_version
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Devtools::Clouddebugger::V2::SetBreakpointRequest)
            @set_breakpoint.call(req, options, &block)
          end

          # Gets breakpoint information.
          #
          # @param debuggee_id [String]
          #   ID of the debuggee whose breakpoint to get.
          # @param breakpoint_id [String]
          #   ID of the breakpoint to get.
          # @param client_version [String]
          #   The client version making the call.
          #   Schema: `domain/type/version` (e.g., `google.com/intellij/v1`).
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Devtools::Clouddebugger::V2::GetBreakpointResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Devtools::Clouddebugger::V2::GetBreakpointResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/debugger/v2"
          #
          #   debugger2_client = Google::Cloud::Debugger::V2::Debugger2.new
          #
          #   # TODO: Initialize `debuggee_id`:
          #   debuggee_id = ''
          #
          #   # TODO: Initialize `breakpoint_id`:
          #   breakpoint_id = ''
          #
          #   # TODO: Initialize `client_version`:
          #   client_version = ''
          #   response = debugger2_client.get_breakpoint(debuggee_id, breakpoint_id, client_version)

          def get_breakpoint \
              debuggee_id,
              breakpoint_id,
              client_version,
              options: nil,
              &block
            req = {
              debuggee_id: debuggee_id,
              breakpoint_id: breakpoint_id,
              client_version: client_version
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Devtools::Clouddebugger::V2::GetBreakpointRequest)
            @get_breakpoint.call(req, options, &block)
          end

          # Deletes the breakpoint from the debuggee.
          #
          # @param debuggee_id [String]
          #   ID of the debuggee whose breakpoint to delete.
          # @param breakpoint_id [String]
          #   ID of the breakpoint to delete.
          # @param client_version [String]
          #   The client version making the call.
          #   Schema: `domain/type/version` (e.g., `google.com/intellij/v1`).
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/debugger/v2"
          #
          #   debugger2_client = Google::Cloud::Debugger::V2::Debugger2.new
          #
          #   # TODO: Initialize `debuggee_id`:
          #   debuggee_id = ''
          #
          #   # TODO: Initialize `breakpoint_id`:
          #   breakpoint_id = ''
          #
          #   # TODO: Initialize `client_version`:
          #   client_version = ''
          #   debugger2_client.delete_breakpoint(debuggee_id, breakpoint_id, client_version)

          def delete_breakpoint \
              debuggee_id,
              breakpoint_id,
              client_version,
              options: nil,
              &block
            req = {
              debuggee_id: debuggee_id,
              breakpoint_id: breakpoint_id,
              client_version: client_version
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Devtools::Clouddebugger::V2::DeleteBreakpointRequest)
            @delete_breakpoint.call(req, options, &block)
            nil
          end

          # Lists all breakpoints for the debuggee.
          #
          # @param debuggee_id [String]
          #   ID of the debuggee whose breakpoints to list.
          # @param client_version [String]
          #   The client version making the call.
          #   Schema: `domain/type/version` (e.g., `google.com/intellij/v1`).
          # @param include_all_users [true, false]
          #   When set to `true`, the response includes the list of breakpoints set by
          #   any user. Otherwise, it includes only breakpoints set by the caller.
          # @param include_inactive [true, false]
          #   When set to `true`, the response includes active and inactive
          #   breakpoints. Otherwise, it includes only active breakpoints.
          # @param action [Google::Devtools::Clouddebugger::V2::ListBreakpointsRequest::BreakpointActionValue | Hash]
          #   When set, the response includes only breakpoints with the specified action.
          #   A hash of the same form as `Google::Devtools::Clouddebugger::V2::ListBreakpointsRequest::BreakpointActionValue`
          #   can also be provided.
          # @param strip_results [true, false]
          #   This field is deprecated. The following fields are always stripped out of
          #   the result: `stack_frames`, `evaluated_expressions` and `variable_table`.
          # @param wait_token [String]
          #   A wait token that, if specified, blocks the call until the breakpoints
          #   list has changed, or a server selected timeout has expired.  The value
          #   should be set from the last response. The error code
          #   `google.rpc.Code.ABORTED` (RPC) is returned on wait timeout, which
          #   should be called again with the same `wait_token`.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Devtools::Clouddebugger::V2::ListBreakpointsResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Devtools::Clouddebugger::V2::ListBreakpointsResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/debugger/v2"
          #
          #   debugger2_client = Google::Cloud::Debugger::V2::Debugger2.new
          #
          #   # TODO: Initialize `debuggee_id`:
          #   debuggee_id = ''
          #
          #   # TODO: Initialize `client_version`:
          #   client_version = ''
          #   response = debugger2_client.list_breakpoints(debuggee_id, client_version)

          def list_breakpoints \
              debuggee_id,
              client_version,
              include_all_users: nil,
              include_inactive: nil,
              action: nil,
              strip_results: nil,
              wait_token: nil,
              options: nil,
              &block
            req = {
              debuggee_id: debuggee_id,
              client_version: client_version,
              include_all_users: include_all_users,
              include_inactive: include_inactive,
              action: action,
              strip_results: strip_results,
              wait_token: wait_token
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Devtools::Clouddebugger::V2::ListBreakpointsRequest)
            @list_breakpoints.call(req, options, &block)
          end

          # Lists all the debuggees that the user has access to.
          #
          # @param project [String]
          #   Project number of a Google Cloud project whose debuggees to list.
          # @param client_version [String]
          #   The client version making the call.
          #   Schema: `domain/type/version` (e.g., `google.com/intellij/v1`).
          # @param include_inactive [true, false]
          #   When set to `true`, the result includes all debuggees. Otherwise, the
          #   result includes only debuggees that are active.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Devtools::Clouddebugger::V2::ListDebuggeesResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Devtools::Clouddebugger::V2::ListDebuggeesResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/debugger/v2"
          #
          #   debugger2_client = Google::Cloud::Debugger::V2::Debugger2.new
          #
          #   # TODO: Initialize `project`:
          #   project = ''
          #
          #   # TODO: Initialize `client_version`:
          #   client_version = ''
          #   response = debugger2_client.list_debuggees(project, client_version)

          def list_debuggees \
              project,
              client_version,
              include_inactive: nil,
              options: nil,
              &block
            req = {
              project: project,
              client_version: client_version,
              include_inactive: include_inactive
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Devtools::Clouddebugger::V2::ListDebuggeesRequest)
            @list_debuggees.call(req, options, &block)
          end
        end
      end
    end
  end
end
