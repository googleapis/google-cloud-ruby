# Copyright 2020 Google LLC
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
# https://github.com/googleapis/googleapis/blob/master/google/cloud/webrisk/v1beta1/webrisk.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.


require "json"
require "pathname"

require "google/gax"

require "google/cloud/webrisk/v1beta1/webrisk_pb"
require "google/cloud/webrisk/v1beta1/credentials"
require "google/cloud/webrisk/version"

module Google
  module Cloud
    module Webrisk
      module V1beta1
        # Web Risk v1beta1 API defines an interface to detect malicious URLs on your
        # website and in client applications.
        #
        # @!attribute [r] web_risk_service_v1_beta1_stub
        #   @return [Google::Cloud::Webrisk::V1beta1::WebRiskServiceV1Beta1::Stub]
        class WebRiskServiceV1Beta1Client
          # @private
          attr_reader :web_risk_service_v1_beta1_stub

          # The default address of the service.
          SERVICE_ADDRESS = "webrisk.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          # The default set of gRPC interceptors.
          GRPC_INTERCEPTORS = []

          DEFAULT_TIMEOUT = 30

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform"
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
          # @param service_address [String]
          #   Override for the service hostname, or `nil` to leave as the default.
          # @param service_port [Integer]
          #   Override for the service port, or `nil` to leave as the default.
          # @param exception_transformer [Proc]
          #   An optional proc that intercepts any exceptions raised during an API call to inject
          #   custom error handling.
          def initialize \
              credentials: nil,
              scopes: ALL_SCOPES,
              client_config: {},
              timeout: DEFAULT_TIMEOUT,
              metadata: nil,
              service_address: nil,
              service_port: nil,
              exception_transformer: nil,
              lib_name: nil,
              lib_version: ""
            # These require statements are intentionally placed here to initialize
            # the gRPC module only when it's required.
            # See https://github.com/googleapis/toolkit/issues/446
            require "google/gax/grpc"
            require "google/cloud/webrisk/v1beta1/webrisk_services_pb"

            credentials ||= Google::Cloud::Webrisk::V1beta1::Credentials.default

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Webrisk::V1beta1::Credentials.new(credentials).updater_proc
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

            package_version = Google::Cloud::Webrisk::VERSION

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/#{package_version} gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            if credentials.respond_to?(:quota_project_id) && credentials.quota_project_id
              headers[:"x-goog-user-project"] = credentials.quota_project_id
            end
            headers.merge!(metadata) unless metadata.nil?
            client_config_file = Pathname.new(__dir__).join(
              "web_risk_service_v1_beta1_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.cloud.webrisk.v1beta1.WebRiskServiceV1Beta1",
                JSON.parse(f.read),
                client_config,
                Google::Gax::Grpc::STATUS_CODE_NAMES,
                timeout,
                errors: Google::Gax::Grpc::API_ERRORS,
                metadata: headers
              )
            end

            # Allow overriding the service path/port in subclasses.
            service_path = service_address || self.class::SERVICE_ADDRESS
            port = service_port || self.class::DEFAULT_SERVICE_PORT
            interceptors = self.class::GRPC_INTERCEPTORS
            @web_risk_service_v1_beta1_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Cloud::Webrisk::V1beta1::WebRiskServiceV1Beta1::Stub.method(:new)
            )

            @compute_threat_list_diff = Google::Gax.create_api_call(
              @web_risk_service_v1_beta1_stub.method(:compute_threat_list_diff),
              defaults["compute_threat_list_diff"],
              exception_transformer: exception_transformer
            )
            @search_uris = Google::Gax.create_api_call(
              @web_risk_service_v1_beta1_stub.method(:search_uris),
              defaults["search_uris"],
              exception_transformer: exception_transformer
            )
            @search_hashes = Google::Gax.create_api_call(
              @web_risk_service_v1_beta1_stub.method(:search_hashes),
              defaults["search_hashes"],
              exception_transformer: exception_transformer
            )
          end

          # Service calls

          # Gets the most recent threat list diffs.
          #
          # @param threat_type [Google::Cloud::Webrisk::V1beta1::ThreatType]
          #   The ThreatList to update.
          # @param constraints [Google::Cloud::Webrisk::V1beta1::ComputeThreatListDiffRequest::Constraints | Hash]
          #   Required. The constraints associated with this request.
          #   A hash of the same form as `Google::Cloud::Webrisk::V1beta1::ComputeThreatListDiffRequest::Constraints`
          #   can also be provided.
          # @param version_token [String]
          #   The current version token of the client for the requested list (the
          #   client version that was received from the last successful diff).
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Webrisk::V1beta1::ComputeThreatListDiffResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Webrisk::V1beta1::ComputeThreatListDiffResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/webrisk"
          #
          #   web_risk_service_v1_beta1_client = Google::Cloud::Webrisk.new(version: :v1beta1)
          #
          #   # TODO: Initialize `threat_type`:
          #   threat_type = :THREAT_TYPE_UNSPECIFIED
          #
          #   # TODO: Initialize `constraints`:
          #   constraints = {}
          #   response = web_risk_service_v1_beta1_client.compute_threat_list_diff(threat_type, constraints)

          def compute_threat_list_diff \
              threat_type,
              constraints,
              version_token: nil,
              options: nil,
              &block
            req = {
              threat_type: threat_type,
              constraints: constraints,
              version_token: version_token
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Webrisk::V1beta1::ComputeThreatListDiffRequest)
            @compute_threat_list_diff.call(req, options, &block)
          end

          # This method is used to check whether a URI is on a given threatList.
          #
          # @param uri [String]
          #   Required. The URI to be checked for matches.
          # @param threat_types [Array<Google::Cloud::Webrisk::V1beta1::ThreatType>]
          #   Required. The ThreatLists to search in.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Webrisk::V1beta1::SearchUrisResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Webrisk::V1beta1::SearchUrisResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/webrisk"
          #
          #   web_risk_service_v1_beta1_client = Google::Cloud::Webrisk.new(version: :v1beta1)
          #
          #   # TODO: Initialize `uri`:
          #   uri = ''
          #
          #   # TODO: Initialize `threat_types`:
          #   threat_types = []
          #   response = web_risk_service_v1_beta1_client.search_uris(uri, threat_types)

          def search_uris \
              uri,
              threat_types,
              options: nil,
              &block
            req = {
              uri: uri,
              threat_types: threat_types
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Webrisk::V1beta1::SearchUrisRequest)
            @search_uris.call(req, options, &block)
          end

          # Gets the full hashes that match the requested hash prefix.
          # This is used after a hash prefix is looked up in a threatList
          # and there is a match. The client side threatList only holds partial hashes
          # so the client must query this method to determine if there is a full
          # hash match of a threat.
          #
          # @param threat_types [Array<Google::Cloud::Webrisk::V1beta1::ThreatType>]
          #   Required. The ThreatLists to search in.
          # @param hash_prefix [String]
          #   A hash prefix, consisting of the most significant 4-32 bytes of a SHA256
          #   hash. For JSON requests, this field is base64-encoded.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Webrisk::V1beta1::SearchHashesResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Webrisk::V1beta1::SearchHashesResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/webrisk"
          #
          #   web_risk_service_v1_beta1_client = Google::Cloud::Webrisk.new(version: :v1beta1)
          #
          #   # TODO: Initialize `threat_types`:
          #   threat_types = []
          #   response = web_risk_service_v1_beta1_client.search_hashes(threat_types)

          def search_hashes \
              threat_types,
              hash_prefix: nil,
              options: nil,
              &block
            req = {
              threat_types: threat_types,
              hash_prefix: hash_prefix
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Webrisk::V1beta1::SearchHashesRequest)
            @search_hashes.call(req, options, &block)
          end
        end
      end
    end
  end
end
