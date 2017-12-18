# Copyright 2017 Google LLC
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
# https://github.com/googleapis/googleapis/blob/master/google/devtools/clouddebugger/v2/controller.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.
#
# The only allowed edits are to method and file documentation. A 3-way
# merge preserves those additions if the generated source changes.

require "json"
require "pathname"

require "google/gax"

require "google/devtools/clouddebugger/v2/controller_pb"
require "google/cloud/debugger/credentials"

module Google
  module Cloud
    module Debugger
      module V2
        # The Controller service provides the API for orchestrating a collection of
        # debugger agents to perform debugging tasks. These agents are each attached
        # to a process of an application which may include one or more replicas.
        #
        # The debugger agents register with the Controller to identify the application
        # being debugged, the Debuggee. All agents that register with the same data,
        # represent the same Debuggee, and are assigned the same +debuggee_id+.
        #
        # The debugger agents call the Controller to retrieve  the list of active
        # Breakpoints. Agents with the same +debuggee_id+ get the same breakpoints
        # list. An agent that can fulfill the breakpoint request updates the
        # Controller with the breakpoint result. The controller selects the first
        # result received and discards the rest of the results.
        # Agents that poll again for active breakpoints will no longer have
        # the completed breakpoint in the list and should remove that breakpoint from
        # their attached process.
        #
        # The Controller service does not provide a way to retrieve the results of
        # a completed breakpoint. This functionality is available using the Debugger
        # service.
        #
        # @!attribute [r] controller2_stub
        #   @return [Google::Devtools::Clouddebugger::V2::Controller2::Stub]
        class Controller2Client
          attr_reader :controller2_stub

          # The default address of the service.
          SERVICE_ADDRESS = "clouddebugger.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

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
          def initialize \
              service_path: SERVICE_ADDRESS,
              port: DEFAULT_SERVICE_PORT,
              channel: nil,
              chan_creds: nil,
              updater_proc: nil,
              credentials: nil,
              scopes: ALL_SCOPES,
              client_config: {},
              timeout: DEFAULT_TIMEOUT,
              lib_name: nil,
              lib_version: ""
            # These require statements are intentionally placed here to initialize
            # the gRPC module only when it's required.
            # See https://github.com/googleapis/toolkit/issues/446
            require "google/gax/grpc"
            require "google/devtools/clouddebugger/v2/controller_services_pb"

            if channel || chan_creds || updater_proc
              warn "The `channel`, `chan_creds`, and `updater_proc` parameters will be removed " \
                "on 2017/09/08"
              credentials ||= channel
              credentials ||= chan_creds
              credentials ||= updater_proc
            end
            if service_path != SERVICE_ADDRESS || port != DEFAULT_SERVICE_PORT
              warn "`service_path` and `port` parameters are deprecated and will be removed"
            end

            credentials ||= Google::Cloud::Debugger::Credentials.default

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Debugger::Credentials.new(credentials).updater_proc
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

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/0.1.0 gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            client_config_file = Pathname.new(__dir__).join(
              "controller2_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.devtools.clouddebugger.v2.Controller2",
                JSON.parse(f.read),
                client_config,
                Google::Gax::Grpc::STATUS_CODE_NAMES,
                timeout,
                errors: Google::Gax::Grpc::API_ERRORS,
                kwargs: headers
              )
            end
            @controller2_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              &Google::Devtools::Clouddebugger::V2::Controller2::Stub.method(:new)
            )

            @register_debuggee = Google::Gax.create_api_call(
              @controller2_stub.method(:register_debuggee),
              defaults["register_debuggee"]
            )
            @list_active_breakpoints = Google::Gax.create_api_call(
              @controller2_stub.method(:list_active_breakpoints),
              defaults["list_active_breakpoints"]
            )
            @update_active_breakpoint = Google::Gax.create_api_call(
              @controller2_stub.method(:update_active_breakpoint),
              defaults["update_active_breakpoint"]
            )
          end

          # Service calls

          # Registers the debuggee with the controller service.
          #
          # All agents attached to the same application must call this method with
          # exactly the same request content to get back the same stable +debuggee_id+.
          # Agents should call this method again whenever +google.rpc.Code.NOT_FOUND+
          # is returned from any controller method.
          #
          # This protocol allows the controller service to disable debuggees, recover
          # from data loss, or change the +debuggee_id+ format. Agents must handle
          # +debuggee_id+ value changing upon re-registration.
          #
          # @param debuggee [Google::Devtools::Clouddebugger::V2::Debuggee | Hash]
          #   Debuggee information to register.
          #   The fields +project+, +uniquifier+, +description+ and +agent_version+
          #   of the debuggee must be set.
          #   A hash of the same form as `Google::Devtools::Clouddebugger::V2::Debuggee`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Devtools::Clouddebugger::V2::RegisterDebuggeeResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/debugger/v2"
          #
          #   controller2_client = Google::Cloud::Debugger::V2::Controller2.new
          #   debuggee = {}
          #   response = controller2_client.register_debuggee(debuggee)

          def register_debuggee \
              debuggee,
              options: nil
            req = {
              debuggee: debuggee
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Devtools::Clouddebugger::V2::RegisterDebuggeeRequest)
            @register_debuggee.call(req, options)
          end

          # Returns the list of all active breakpoints for the debuggee.
          #
          # The breakpoint specification (+location+, +condition+, and +expressions+
          # fields) is semantically immutable, although the field values may
          # change. For example, an agent may update the location line number
          # to reflect the actual line where the breakpoint was set, but this
          # doesn't change the breakpoint semantics.
          #
          # This means that an agent does not need to check if a breakpoint has changed
          # when it encounters the same breakpoint on a successive call.
          # Moreover, an agent should remember the breakpoints that are completed
          # until the controller removes them from the active list to avoid
          # setting those breakpoints again.
          #
          # @param debuggee_id [String]
          #   Identifies the debuggee.
          # @param wait_token [String]
          #   A token that, if specified, blocks the method call until the list
          #   of active breakpoints has changed, or a server-selected timeout has
          #   expired. The value should be set from the +next_wait_token+ field in
          #   the last response. The initial value should be set to +"init"+.
          # @param success_on_timeout [true, false]
          #   If set to +true+ (recommended), returns +google.rpc.Code.OK+ status and
          #   sets the +wait_expired+ response field to +true+ when the server-selected
          #   timeout has expired.
          #
          #   If set to +false+ (deprecated), returns +google.rpc.Code.ABORTED+ status
          #   when the server-selected timeout has expired.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Devtools::Clouddebugger::V2::ListActiveBreakpointsResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/debugger/v2"
          #
          #   controller2_client = Google::Cloud::Debugger::V2::Controller2.new
          #   debuggee_id = ''
          #   response = controller2_client.list_active_breakpoints(debuggee_id)

          def list_active_breakpoints \
              debuggee_id,
              wait_token: nil,
              success_on_timeout: nil,
              options: nil
            req = {
              debuggee_id: debuggee_id,
              wait_token: wait_token,
              success_on_timeout: success_on_timeout
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Devtools::Clouddebugger::V2::ListActiveBreakpointsRequest)
            @list_active_breakpoints.call(req, options)
          end

          # Updates the breakpoint state or mutable fields.
          # The entire Breakpoint message must be sent back to the controller service.
          #
          # Updates to active breakpoint fields are only allowed if the new value
          # does not change the breakpoint specification. Updates to the +location+,
          # +condition+ and +expressions+ fields should not alter the breakpoint
          # semantics. These may only make changes such as canonicalizing a value
          # or snapping the location to the correct line of code.
          #
          # @param debuggee_id [String]
          #   Identifies the debuggee being debugged.
          # @param breakpoint [Google::Devtools::Clouddebugger::V2::Breakpoint | Hash]
          #   Updated breakpoint information.
          #   The field +id+ must be set.
          #   The agent must echo all Breakpoint specification fields in the update.
          #   A hash of the same form as `Google::Devtools::Clouddebugger::V2::Breakpoint`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Devtools::Clouddebugger::V2::UpdateActiveBreakpointResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/debugger/v2"
          #
          #   controller2_client = Google::Cloud::Debugger::V2::Controller2.new
          #   debuggee_id = ''
          #   breakpoint = {}
          #   response = controller2_client.update_active_breakpoint(debuggee_id, breakpoint)

          def update_active_breakpoint \
              debuggee_id,
              breakpoint,
              options: nil
            req = {
              debuggee_id: debuggee_id,
              breakpoint: breakpoint
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Devtools::Clouddebugger::V2::UpdateActiveBreakpointRequest)
            @update_active_breakpoint.call(req, options)
          end
        end
      end
    end
  end
end
