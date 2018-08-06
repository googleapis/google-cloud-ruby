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
# https://github.com/googleapis/googleapis/blob/master/google/cloud/kms/v1/service.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.

require "json"
require "pathname"

require "google/gax"

require "google/cloud/kms/v1/service_pb"
require "google/iam/v1/iam_policy_pb"
require "google/cloud/kms/v1/credentials"

module Google
  module Cloud
    module Kms
      module V1
        # Google Cloud Key Management Service
        #
        # Manages cryptographic keys and operations using those keys. Implements a REST
        # model with the following objects:
        #
        # * {Google::Cloud::Kms::V1::KeyRing KeyRing}
        # * {Google::Cloud::Kms::V1::CryptoKey CryptoKey}
        # * {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion}
        #
        # @!attribute [r] key_management_service_stub
        #   @return [Google::Cloud::Kms::V1::KeyManagementService::Stub]
        # @!attribute [r] iam_policy_stub
        #   @return [Google::Iam::V1::IAMPolicy::Stub]
        class KeyManagementServiceClient
          attr_reader :key_management_service_stub, :iam_policy_stub

          # The default address of the service.
          SERVICE_ADDRESS = "cloudkms.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          # The default set of gRPC interceptors.
          GRPC_INTERCEPTORS = []

          DEFAULT_TIMEOUT = 30

          PAGE_DESCRIPTORS = {
            "list_key_rings" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "key_rings"),
            "list_crypto_keys" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "crypto_keys"),
            "list_crypto_key_versions" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "crypto_key_versions")
          }.freeze

          private_constant :PAGE_DESCRIPTORS

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform"
          ].freeze


          KEY_RING_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/locations/{location}/keyRings/{key_ring}"
          )

          private_constant :KEY_RING_PATH_TEMPLATE

          CRYPTO_KEY_PATH_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/locations/{location}/keyRings/{key_ring}/cryptoKeys/{crypto_key_path=**}"
          )

          private_constant :CRYPTO_KEY_PATH_PATH_TEMPLATE

          LOCATION_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/locations/{location}"
          )

          private_constant :LOCATION_PATH_TEMPLATE

          CRYPTO_KEY_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/locations/{location}/keyRings/{key_ring}/cryptoKeys/{crypto_key}"
          )

          private_constant :CRYPTO_KEY_PATH_TEMPLATE

          CRYPTO_KEY_VERSION_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/locations/{location}/keyRings/{key_ring}/cryptoKeys/{crypto_key}/cryptoKeyVersions/{crypto_key_version}"
          )

          private_constant :CRYPTO_KEY_VERSION_PATH_TEMPLATE

          # Returns a fully-qualified key_ring resource name string.
          # @param project [String]
          # @param location [String]
          # @param key_ring [String]
          # @return [String]
          def self.key_ring_path project, location, key_ring
            KEY_RING_PATH_TEMPLATE.render(
              :"project" => project,
              :"location" => location,
              :"key_ring" => key_ring
            )
          end

          # Returns a fully-qualified crypto_key_path resource name string.
          # @param project [String]
          # @param location [String]
          # @param key_ring [String]
          # @param crypto_key_path [String]
          # @return [String]
          def self.crypto_key_path_path project, location, key_ring, crypto_key_path
            CRYPTO_KEY_PATH_PATH_TEMPLATE.render(
              :"project" => project,
              :"location" => location,
              :"key_ring" => key_ring,
              :"crypto_key_path" => crypto_key_path
            )
          end

          # Returns a fully-qualified location resource name string.
          # @param project [String]
          # @param location [String]
          # @return [String]
          def self.location_path project, location
            LOCATION_PATH_TEMPLATE.render(
              :"project" => project,
              :"location" => location
            )
          end

          # Returns a fully-qualified crypto_key resource name string.
          # @param project [String]
          # @param location [String]
          # @param key_ring [String]
          # @param crypto_key [String]
          # @return [String]
          def self.crypto_key_path project, location, key_ring, crypto_key
            CRYPTO_KEY_PATH_TEMPLATE.render(
              :"project" => project,
              :"location" => location,
              :"key_ring" => key_ring,
              :"crypto_key" => crypto_key
            )
          end

          # Returns a fully-qualified crypto_key_version resource name string.
          # @param project [String]
          # @param location [String]
          # @param key_ring [String]
          # @param crypto_key [String]
          # @param crypto_key_version [String]
          # @return [String]
          def self.crypto_key_version_path project, location, key_ring, crypto_key, crypto_key_version
            CRYPTO_KEY_VERSION_PATH_TEMPLATE.render(
              :"project" => project,
              :"location" => location,
              :"key_ring" => key_ring,
              :"crypto_key" => crypto_key,
              :"crypto_key_version" => crypto_key_version
            )
          end

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
            require "google/cloud/kms/v1/service_services_pb"
            require "google/iam/v1/iam_policy_services_pb"

            credentials ||= Google::Cloud::Kms::V1::Credentials.default

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Kms::V1::Credentials.new(credentials).updater_proc
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

            package_version = Gem.loaded_specs['google-cloud-kms'].version.version

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/#{package_version} gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            headers.merge!(metadata) unless metadata.nil?
            client_config_file = Pathname.new(__dir__).join(
              "key_management_service_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.cloud.kms.v1.KeyManagementService",
                JSON.parse(f.read),
                client_config,
                Google::Gax::Grpc::STATUS_CODE_NAMES,
                timeout,
                page_descriptors: PAGE_DESCRIPTORS,
                errors: Google::Gax::Grpc::API_ERRORS,
                metadata: headers
              )
            end

            # Allow overriding the service path/port in subclasses.
            service_path = self.class::SERVICE_ADDRESS
            port = self.class::DEFAULT_SERVICE_PORT
            interceptors = self.class::GRPC_INTERCEPTORS
            @key_management_service_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Cloud::Kms::V1::KeyManagementService::Stub.method(:new)
            )
            @iam_policy_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Iam::V1::IAMPolicy::Stub.method(:new)
            )

            @list_key_rings = Google::Gax.create_api_call(
              @key_management_service_stub.method(:list_key_rings),
              defaults["list_key_rings"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @list_crypto_keys = Google::Gax.create_api_call(
              @key_management_service_stub.method(:list_crypto_keys),
              defaults["list_crypto_keys"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @list_crypto_key_versions = Google::Gax.create_api_call(
              @key_management_service_stub.method(:list_crypto_key_versions),
              defaults["list_crypto_key_versions"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @get_key_ring = Google::Gax.create_api_call(
              @key_management_service_stub.method(:get_key_ring),
              defaults["get_key_ring"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @get_crypto_key = Google::Gax.create_api_call(
              @key_management_service_stub.method(:get_crypto_key),
              defaults["get_crypto_key"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @get_crypto_key_version = Google::Gax.create_api_call(
              @key_management_service_stub.method(:get_crypto_key_version),
              defaults["get_crypto_key_version"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @create_key_ring = Google::Gax.create_api_call(
              @key_management_service_stub.method(:create_key_ring),
              defaults["create_key_ring"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @create_crypto_key = Google::Gax.create_api_call(
              @key_management_service_stub.method(:create_crypto_key),
              defaults["create_crypto_key"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @create_crypto_key_version = Google::Gax.create_api_call(
              @key_management_service_stub.method(:create_crypto_key_version),
              defaults["create_crypto_key_version"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @update_crypto_key = Google::Gax.create_api_call(
              @key_management_service_stub.method(:update_crypto_key),
              defaults["update_crypto_key"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'crypto_key.name' => request.crypto_key.name}
              end
            )
            @update_crypto_key_version = Google::Gax.create_api_call(
              @key_management_service_stub.method(:update_crypto_key_version),
              defaults["update_crypto_key_version"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'crypto_key_version.name' => request.crypto_key_version.name}
              end
            )
            @encrypt = Google::Gax.create_api_call(
              @key_management_service_stub.method(:encrypt),
              defaults["encrypt"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @decrypt = Google::Gax.create_api_call(
              @key_management_service_stub.method(:decrypt),
              defaults["decrypt"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @update_crypto_key_primary_version = Google::Gax.create_api_call(
              @key_management_service_stub.method(:update_crypto_key_primary_version),
              defaults["update_crypto_key_primary_version"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @destroy_crypto_key_version = Google::Gax.create_api_call(
              @key_management_service_stub.method(:destroy_crypto_key_version),
              defaults["destroy_crypto_key_version"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @restore_crypto_key_version = Google::Gax.create_api_call(
              @key_management_service_stub.method(:restore_crypto_key_version),
              defaults["restore_crypto_key_version"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @set_iam_policy = Google::Gax.create_api_call(
              @iam_policy_stub.method(:set_iam_policy),
              defaults["set_iam_policy"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'resource' => request.resource}
              end
            )
            @get_iam_policy = Google::Gax.create_api_call(
              @iam_policy_stub.method(:get_iam_policy),
              defaults["get_iam_policy"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'resource' => request.resource}
              end
            )
            @test_iam_permissions = Google::Gax.create_api_call(
              @iam_policy_stub.method(:test_iam_permissions),
              defaults["test_iam_permissions"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'resource' => request.resource}
              end
            )
          end

          # Service calls

          # Lists {Google::Cloud::Kms::V1::KeyRing KeyRings}.
          #
          # @param parent [String]
          #   Required. The resource name of the location associated with the
          #   {Google::Cloud::Kms::V1::KeyRing KeyRings}, in the format +projects/*/locations/*+.
          # @param page_size [Integer]
          #   The maximum number of resources contained in the underlying API
          #   response. If page streaming is performed per-resource, this
          #   parameter does not affect the return value. If page streaming is
          #   performed per-page, this determines the maximum number of
          #   resources in a page.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::Kms::V1::KeyRing>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::Kms::V1::KeyRing>]
          #   An enumerable of Google::Cloud::Kms::V1::KeyRing instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/kms"
          #
          #   key_management_service_client = Google::Cloud::Kms.new(version: :v1)
          #   formatted_parent = Google::Cloud::Kms::V1::KeyManagementServiceClient.location_path("[PROJECT]", "[LOCATION]")
          #
          #   # Iterate over all results.
          #   key_management_service_client.list_key_rings(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   key_management_service_client.list_key_rings(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_key_rings \
              parent,
              page_size: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Kms::V1::ListKeyRingsRequest)
            @list_key_rings.call(req, options, &block)
          end

          # Lists {Google::Cloud::Kms::V1::CryptoKey CryptoKeys}.
          #
          # @param parent [String]
          #   Required. The resource name of the {Google::Cloud::Kms::V1::KeyRing KeyRing} to list, in the format
          #   +projects/*/locations/*/keyRings/*+.
          # @param page_size [Integer]
          #   The maximum number of resources contained in the underlying API
          #   response. If page streaming is performed per-resource, this
          #   parameter does not affect the return value. If page streaming is
          #   performed per-page, this determines the maximum number of
          #   resources in a page.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::Kms::V1::CryptoKey>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::Kms::V1::CryptoKey>]
          #   An enumerable of Google::Cloud::Kms::V1::CryptoKey instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/kms"
          #
          #   key_management_service_client = Google::Cloud::Kms.new(version: :v1)
          #   formatted_parent = Google::Cloud::Kms::V1::KeyManagementServiceClient.key_ring_path("[PROJECT]", "[LOCATION]", "[KEY_RING]")
          #
          #   # Iterate over all results.
          #   key_management_service_client.list_crypto_keys(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   key_management_service_client.list_crypto_keys(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_crypto_keys \
              parent,
              page_size: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Kms::V1::ListCryptoKeysRequest)
            @list_crypto_keys.call(req, options, &block)
          end

          # Lists {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersions}.
          #
          # @param parent [String]
          #   Required. The resource name of the {Google::Cloud::Kms::V1::CryptoKey CryptoKey} to list, in the format
          #   +projects/*/locations/*/keyRings/*/cryptoKeys/*+.
          # @param page_size [Integer]
          #   The maximum number of resources contained in the underlying API
          #   response. If page streaming is performed per-resource, this
          #   parameter does not affect the return value. If page streaming is
          #   performed per-page, this determines the maximum number of
          #   resources in a page.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::Kms::V1::CryptoKeyVersion>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::Kms::V1::CryptoKeyVersion>]
          #   An enumerable of Google::Cloud::Kms::V1::CryptoKeyVersion instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/kms"
          #
          #   key_management_service_client = Google::Cloud::Kms.new(version: :v1)
          #   formatted_parent = Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_path("[PROJECT]", "[LOCATION]", "[KEY_RING]", "[CRYPTO_KEY]")
          #
          #   # Iterate over all results.
          #   key_management_service_client.list_crypto_key_versions(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   key_management_service_client.list_crypto_key_versions(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_crypto_key_versions \
              parent,
              page_size: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Kms::V1::ListCryptoKeyVersionsRequest)
            @list_crypto_key_versions.call(req, options, &block)
          end

          # Returns metadata for a given {Google::Cloud::Kms::V1::KeyRing KeyRing}.
          #
          # @param name [String]
          #   The {Google::Cloud::Kms::V1::KeyRing#name name} of the {Google::Cloud::Kms::V1::KeyRing KeyRing} to get.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Kms::V1::KeyRing]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Kms::V1::KeyRing]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/kms"
          #
          #   key_management_service_client = Google::Cloud::Kms.new(version: :v1)
          #   formatted_name = Google::Cloud::Kms::V1::KeyManagementServiceClient.key_ring_path("[PROJECT]", "[LOCATION]", "[KEY_RING]")
          #   response = key_management_service_client.get_key_ring(formatted_name)

          def get_key_ring \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Kms::V1::GetKeyRingRequest)
            @get_key_ring.call(req, options, &block)
          end

          # Returns metadata for a given {Google::Cloud::Kms::V1::CryptoKey CryptoKey}, as well as its
          # {Google::Cloud::Kms::V1::CryptoKey#primary primary} {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion}.
          #
          # @param name [String]
          #   The {Google::Cloud::Kms::V1::CryptoKey#name name} of the {Google::Cloud::Kms::V1::CryptoKey CryptoKey} to get.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Kms::V1::CryptoKey]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Kms::V1::CryptoKey]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/kms"
          #
          #   key_management_service_client = Google::Cloud::Kms.new(version: :v1)
          #   formatted_name = Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_path("[PROJECT]", "[LOCATION]", "[KEY_RING]", "[CRYPTO_KEY]")
          #   response = key_management_service_client.get_crypto_key(formatted_name)

          def get_crypto_key \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Kms::V1::GetCryptoKeyRequest)
            @get_crypto_key.call(req, options, &block)
          end

          # Returns metadata for a given {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion}.
          #
          # @param name [String]
          #   The {Google::Cloud::Kms::V1::CryptoKeyVersion#name name} of the {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion} to get.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Kms::V1::CryptoKeyVersion]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Kms::V1::CryptoKeyVersion]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/kms"
          #
          #   key_management_service_client = Google::Cloud::Kms.new(version: :v1)
          #   formatted_name = Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_version_path("[PROJECT]", "[LOCATION]", "[KEY_RING]", "[CRYPTO_KEY]", "[CRYPTO_KEY_VERSION]")
          #   response = key_management_service_client.get_crypto_key_version(formatted_name)

          def get_crypto_key_version \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Kms::V1::GetCryptoKeyVersionRequest)
            @get_crypto_key_version.call(req, options, &block)
          end

          # Create a new {Google::Cloud::Kms::V1::KeyRing KeyRing} in a given Project and Location.
          #
          # @param parent [String]
          #   Required. The resource name of the location associated with the
          #   {Google::Cloud::Kms::V1::KeyRing KeyRings}, in the format +projects/*/locations/*+.
          # @param key_ring_id [String]
          #   Required. It must be unique within a location and match the regular
          #   expression +[a-zA-Z0-9_-]{1,63}+
          # @param key_ring [Google::Cloud::Kms::V1::KeyRing | Hash]
          #   A {Google::Cloud::Kms::V1::KeyRing KeyRing} with initial field values.
          #   A hash of the same form as `Google::Cloud::Kms::V1::KeyRing`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Kms::V1::KeyRing]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Kms::V1::KeyRing]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/kms"
          #
          #   key_management_service_client = Google::Cloud::Kms.new(version: :v1)
          #   formatted_parent = Google::Cloud::Kms::V1::KeyManagementServiceClient.location_path("[PROJECT]", "[LOCATION]")
          #
          #   # TODO: Initialize +key_ring_id+:
          #   key_ring_id = ''
          #
          #   # TODO: Initialize +key_ring+:
          #   key_ring = {}
          #   response = key_management_service_client.create_key_ring(formatted_parent, key_ring_id, key_ring)

          def create_key_ring \
              parent,
              key_ring_id,
              key_ring,
              options: nil,
              &block
            req = {
              parent: parent,
              key_ring_id: key_ring_id,
              key_ring: key_ring
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Kms::V1::CreateKeyRingRequest)
            @create_key_ring.call(req, options, &block)
          end

          # Create a new {Google::Cloud::Kms::V1::CryptoKey CryptoKey} within a {Google::Cloud::Kms::V1::KeyRing KeyRing}.
          #
          # {Google::Cloud::Kms::V1::CryptoKey#purpose CryptoKey#purpose} is required.
          #
          # @param parent [String]
          #   Required. The {Google::Cloud::Kms::V1::KeyRing#name name} of the KeyRing associated with the
          #   {Google::Cloud::Kms::V1::CryptoKey CryptoKeys}.
          # @param crypto_key_id [String]
          #   Required. It must be unique within a KeyRing and match the regular
          #   expression +[a-zA-Z0-9_-]{1,63}+
          # @param crypto_key [Google::Cloud::Kms::V1::CryptoKey | Hash]
          #   A {Google::Cloud::Kms::V1::CryptoKey CryptoKey} with initial field values.
          #   A hash of the same form as `Google::Cloud::Kms::V1::CryptoKey`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Kms::V1::CryptoKey]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Kms::V1::CryptoKey]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/kms"
          #
          #   key_management_service_client = Google::Cloud::Kms.new(version: :v1)
          #   formatted_parent = Google::Cloud::Kms::V1::KeyManagementServiceClient.key_ring_path("[PROJECT]", "[LOCATION]", "[KEY_RING]")
          #   crypto_key_id = "my-app-key"
          #   purpose = :ENCRYPT_DECRYPT
          #   seconds = 2147483647
          #   next_rotation_time = { seconds: seconds }
          #   seconds_2 = 604800
          #   rotation_period = { seconds: seconds_2 }
          #   crypto_key = {
          #     purpose: purpose,
          #     next_rotation_time: next_rotation_time,
          #     rotation_period: rotation_period
          #   }
          #   response = key_management_service_client.create_crypto_key(formatted_parent, crypto_key_id, crypto_key)

          def create_crypto_key \
              parent,
              crypto_key_id,
              crypto_key,
              options: nil,
              &block
            req = {
              parent: parent,
              crypto_key_id: crypto_key_id,
              crypto_key: crypto_key
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Kms::V1::CreateCryptoKeyRequest)
            @create_crypto_key.call(req, options, &block)
          end

          # Create a new {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion} in a {Google::Cloud::Kms::V1::CryptoKey CryptoKey}.
          #
          # The server will assign the next sequential id. If unset,
          # {Google::Cloud::Kms::V1::CryptoKeyVersion#state state} will be set to
          # {Google::Cloud::Kms::V1::CryptoKeyVersion::CryptoKeyVersionState::ENABLED ENABLED}.
          #
          # @param parent [String]
          #   Required. The {Google::Cloud::Kms::V1::CryptoKey#name name} of the {Google::Cloud::Kms::V1::CryptoKey CryptoKey} associated with
          #   the {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersions}.
          # @param crypto_key_version [Google::Cloud::Kms::V1::CryptoKeyVersion | Hash]
          #   A {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion} with initial field values.
          #   A hash of the same form as `Google::Cloud::Kms::V1::CryptoKeyVersion`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Kms::V1::CryptoKeyVersion]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Kms::V1::CryptoKeyVersion]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/kms"
          #
          #   key_management_service_client = Google::Cloud::Kms.new(version: :v1)
          #   formatted_parent = Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_path("[PROJECT]", "[LOCATION]", "[KEY_RING]", "[CRYPTO_KEY]")
          #
          #   # TODO: Initialize +crypto_key_version+:
          #   crypto_key_version = {}
          #   response = key_management_service_client.create_crypto_key_version(formatted_parent, crypto_key_version)

          def create_crypto_key_version \
              parent,
              crypto_key_version,
              options: nil,
              &block
            req = {
              parent: parent,
              crypto_key_version: crypto_key_version
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Kms::V1::CreateCryptoKeyVersionRequest)
            @create_crypto_key_version.call(req, options, &block)
          end

          # Update a {Google::Cloud::Kms::V1::CryptoKey CryptoKey}.
          #
          # @param crypto_key [Google::Cloud::Kms::V1::CryptoKey | Hash]
          #   {Google::Cloud::Kms::V1::CryptoKey CryptoKey} with updated values.
          #   A hash of the same form as `Google::Cloud::Kms::V1::CryptoKey`
          #   can also be provided.
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   Required list of fields to be updated in this request.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Kms::V1::CryptoKey]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Kms::V1::CryptoKey]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/kms"
          #
          #   key_management_service_client = Google::Cloud::Kms.new(version: :v1)
          #
          #   # TODO: Initialize +crypto_key+:
          #   crypto_key = {}
          #
          #   # TODO: Initialize +update_mask+:
          #   update_mask = {}
          #   response = key_management_service_client.update_crypto_key(crypto_key, update_mask)

          def update_crypto_key \
              crypto_key,
              update_mask,
              options: nil,
              &block
            req = {
              crypto_key: crypto_key,
              update_mask: update_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Kms::V1::UpdateCryptoKeyRequest)
            @update_crypto_key.call(req, options, &block)
          end

          # Update a {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion}'s metadata.
          #
          # {Google::Cloud::Kms::V1::CryptoKeyVersion#state state} may be changed between
          # {Google::Cloud::Kms::V1::CryptoKeyVersion::CryptoKeyVersionState::ENABLED ENABLED} and
          # {Google::Cloud::Kms::V1::CryptoKeyVersion::CryptoKeyVersionState::DISABLED DISABLED} using this
          # method. See {Google::Cloud::Kms::V1::KeyManagementService::DestroyCryptoKeyVersion DestroyCryptoKeyVersion} and {Google::Cloud::Kms::V1::KeyManagementService::RestoreCryptoKeyVersion RestoreCryptoKeyVersion} to
          # move between other states.
          #
          # @param crypto_key_version [Google::Cloud::Kms::V1::CryptoKeyVersion | Hash]
          #   {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion} with updated values.
          #   A hash of the same form as `Google::Cloud::Kms::V1::CryptoKeyVersion`
          #   can also be provided.
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   Required list of fields to be updated in this request.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Kms::V1::CryptoKeyVersion]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Kms::V1::CryptoKeyVersion]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/kms"
          #
          #   key_management_service_client = Google::Cloud::Kms.new(version: :v1)
          #
          #   # TODO: Initialize +crypto_key_version+:
          #   crypto_key_version = {}
          #
          #   # TODO: Initialize +update_mask+:
          #   update_mask = {}
          #   response = key_management_service_client.update_crypto_key_version(crypto_key_version, update_mask)

          def update_crypto_key_version \
              crypto_key_version,
              update_mask,
              options: nil,
              &block
            req = {
              crypto_key_version: crypto_key_version,
              update_mask: update_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Kms::V1::UpdateCryptoKeyVersionRequest)
            @update_crypto_key_version.call(req, options, &block)
          end

          # Encrypts data, so that it can only be recovered by a call to {Google::Cloud::Kms::V1::KeyManagementService::Decrypt Decrypt}.
          #
          # @param name [String]
          #   Required. The resource name of the {Google::Cloud::Kms::V1::CryptoKey CryptoKey} or {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion}
          #   to use for encryption.
          #
          #   If a {Google::Cloud::Kms::V1::CryptoKey CryptoKey} is specified, the server will use its
          #   {Google::Cloud::Kms::V1::CryptoKey#primary primary version}.
          # @param plaintext [String]
          #   Required. The data to encrypt. Must be no larger than 64KiB.
          # @param additional_authenticated_data [String]
          #   Optional data that, if specified, must also be provided during decryption
          #   through {Google::Cloud::Kms::V1::DecryptRequest#additional_authenticated_data DecryptRequest#additional_authenticated_data}.  Must be no
          #   larger than 64KiB.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Kms::V1::EncryptResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Kms::V1::EncryptResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/kms"
          #
          #   key_management_service_client = Google::Cloud::Kms.new(version: :v1)
          #   formatted_name = Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_path_path("[PROJECT]", "[LOCATION]", "[KEY_RING]", "[CRYPTO_KEY_PATH]")
          #
          #   # TODO: Initialize +plaintext+:
          #   plaintext = ''
          #   response = key_management_service_client.encrypt(formatted_name, plaintext)

          def encrypt \
              name,
              plaintext,
              additional_authenticated_data: nil,
              options: nil,
              &block
            req = {
              name: name,
              plaintext: plaintext,
              additional_authenticated_data: additional_authenticated_data
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Kms::V1::EncryptRequest)
            @encrypt.call(req, options, &block)
          end

          # Decrypts data that was protected by {Google::Cloud::Kms::V1::KeyManagementService::Encrypt Encrypt}.
          #
          # @param name [String]
          #   Required. The resource name of the {Google::Cloud::Kms::V1::CryptoKey CryptoKey} to use for decryption.
          #   The server will choose the appropriate version.
          # @param ciphertext [String]
          #   Required. The encrypted data originally returned in
          #   {Google::Cloud::Kms::V1::EncryptResponse#ciphertext EncryptResponse#ciphertext}.
          # @param additional_authenticated_data [String]
          #   Optional data that must match the data originally supplied in
          #   {Google::Cloud::Kms::V1::EncryptRequest#additional_authenticated_data EncryptRequest#additional_authenticated_data}.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Kms::V1::DecryptResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Kms::V1::DecryptResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/kms"
          #
          #   key_management_service_client = Google::Cloud::Kms.new(version: :v1)
          #   formatted_name = Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_path("[PROJECT]", "[LOCATION]", "[KEY_RING]", "[CRYPTO_KEY]")
          #
          #   # TODO: Initialize +ciphertext+:
          #   ciphertext = ''
          #   response = key_management_service_client.decrypt(formatted_name, ciphertext)

          def decrypt \
              name,
              ciphertext,
              additional_authenticated_data: nil,
              options: nil,
              &block
            req = {
              name: name,
              ciphertext: ciphertext,
              additional_authenticated_data: additional_authenticated_data
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Kms::V1::DecryptRequest)
            @decrypt.call(req, options, &block)
          end

          # Update the version of a {Google::Cloud::Kms::V1::CryptoKey CryptoKey} that will be used in {Google::Cloud::Kms::V1::KeyManagementService::Encrypt Encrypt}
          #
          # @param name [String]
          #   The resource name of the {Google::Cloud::Kms::V1::CryptoKey CryptoKey} to update.
          # @param crypto_key_version_id [String]
          #   The id of the child {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion} to use as primary.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Kms::V1::CryptoKey]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Kms::V1::CryptoKey]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/kms"
          #
          #   key_management_service_client = Google::Cloud::Kms.new(version: :v1)
          #   formatted_name = Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_path("[PROJECT]", "[LOCATION]", "[KEY_RING]", "[CRYPTO_KEY]")
          #
          #   # TODO: Initialize +crypto_key_version_id+:
          #   crypto_key_version_id = ''
          #   response = key_management_service_client.update_crypto_key_primary_version(formatted_name, crypto_key_version_id)

          def update_crypto_key_primary_version \
              name,
              crypto_key_version_id,
              options: nil,
              &block
            req = {
              name: name,
              crypto_key_version_id: crypto_key_version_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Kms::V1::UpdateCryptoKeyPrimaryVersionRequest)
            @update_crypto_key_primary_version.call(req, options, &block)
          end

          # Schedule a {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion} for destruction.
          #
          # Upon calling this method, {Google::Cloud::Kms::V1::CryptoKeyVersion#state CryptoKeyVersion#state} will be set to
          # {Google::Cloud::Kms::V1::CryptoKeyVersion::CryptoKeyVersionState::DESTROY_SCHEDULED DESTROY_SCHEDULED}
          # and {Google::Cloud::Kms::V1::CryptoKeyVersion#destroy_time destroy_time} will be set to a time 24
          # hours in the future, at which point the {Google::Cloud::Kms::V1::CryptoKeyVersion#state state}
          # will be changed to
          # {Google::Cloud::Kms::V1::CryptoKeyVersion::CryptoKeyVersionState::DESTROYED DESTROYED}, and the key
          # material will be irrevocably destroyed.
          #
          # Before the {Google::Cloud::Kms::V1::CryptoKeyVersion#destroy_time destroy_time} is reached,
          # {Google::Cloud::Kms::V1::KeyManagementService::RestoreCryptoKeyVersion RestoreCryptoKeyVersion} may be called to reverse the process.
          #
          # @param name [String]
          #   The resource name of the {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion} to destroy.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Kms::V1::CryptoKeyVersion]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Kms::V1::CryptoKeyVersion]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/kms"
          #
          #   key_management_service_client = Google::Cloud::Kms.new(version: :v1)
          #   formatted_name = Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_version_path("[PROJECT]", "[LOCATION]", "[KEY_RING]", "[CRYPTO_KEY]", "[CRYPTO_KEY_VERSION]")
          #   response = key_management_service_client.destroy_crypto_key_version(formatted_name)

          def destroy_crypto_key_version \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Kms::V1::DestroyCryptoKeyVersionRequest)
            @destroy_crypto_key_version.call(req, options, &block)
          end

          # Restore a {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion} in the
          # {Google::Cloud::Kms::V1::CryptoKeyVersion::CryptoKeyVersionState::DESTROY_SCHEDULED DESTROY_SCHEDULED},
          # state.
          #
          # Upon restoration of the CryptoKeyVersion, {Google::Cloud::Kms::V1::CryptoKeyVersion#state state}
          # will be set to {Google::Cloud::Kms::V1::CryptoKeyVersion::CryptoKeyVersionState::DISABLED DISABLED},
          # and {Google::Cloud::Kms::V1::CryptoKeyVersion#destroy_time destroy_time} will be cleared.
          #
          # @param name [String]
          #   The resource name of the {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion} to restore.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Kms::V1::CryptoKeyVersion]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Kms::V1::CryptoKeyVersion]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/kms"
          #
          #   key_management_service_client = Google::Cloud::Kms.new(version: :v1)
          #   formatted_name = Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_version_path("[PROJECT]", "[LOCATION]", "[KEY_RING]", "[CRYPTO_KEY]", "[CRYPTO_KEY_VERSION]")
          #   response = key_management_service_client.restore_crypto_key_version(formatted_name)

          def restore_crypto_key_version \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Kms::V1::RestoreCryptoKeyVersionRequest)
            @restore_crypto_key_version.call(req, options, &block)
          end

          # Sets the access control policy on the specified resource. Replaces any
          # existing policy.
          #
          # @param resource [String]
          #   REQUIRED: The resource for which the policy is being specified.
          #   +resource+ is usually specified as a path. For example, a Project
          #   resource is specified as +projects/{project}+.
          # @param policy [Google::Iam::V1::Policy | Hash]
          #   REQUIRED: The complete policy to be applied to the +resource+. The size of
          #   the policy is limited to a few 10s of KB. An empty policy is a
          #   valid policy but certain Cloud Platform services (such as Projects)
          #   might reject them.
          #   A hash of the same form as `Google::Iam::V1::Policy`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Iam::V1::Policy]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Iam::V1::Policy]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/kms"
          #
          #   key_management_service_client = Google::Cloud::Kms.new(version: :v1)
          #   formatted_resource = Google::Cloud::Kms::V1::KeyManagementServiceClient.key_ring_path("[PROJECT]", "[LOCATION]", "[KEY_RING]")
          #
          #   # TODO: Initialize +policy+:
          #   policy = {}
          #   response = key_management_service_client.set_iam_policy(formatted_resource, policy)

          def set_iam_policy \
              resource,
              policy,
              options: nil,
              &block
            req = {
              resource: resource,
              policy: policy
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Iam::V1::SetIamPolicyRequest)
            @set_iam_policy.call(req, options, &block)
          end

          # Gets the access control policy for a resource.
          # Returns an empty policy if the resource exists and does not have a policy
          # set.
          #
          # @param resource [String]
          #   REQUIRED: The resource for which the policy is being requested.
          #   +resource+ is usually specified as a path. For example, a Project
          #   resource is specified as +projects/{project}+.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Iam::V1::Policy]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Iam::V1::Policy]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/kms"
          #
          #   key_management_service_client = Google::Cloud::Kms.new(version: :v1)
          #   formatted_resource = Google::Cloud::Kms::V1::KeyManagementServiceClient.key_ring_path("[PROJECT]", "[LOCATION]", "[KEY_RING]")
          #   response = key_management_service_client.get_iam_policy(formatted_resource)

          def get_iam_policy \
              resource,
              options: nil,
              &block
            req = {
              resource: resource
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Iam::V1::GetIamPolicyRequest)
            @get_iam_policy.call(req, options, &block)
          end

          # Returns permissions that a caller has on the specified resource.
          # If the resource does not exist, this will return an empty set of
          # permissions, not a NOT_FOUND error.
          #
          # @param resource [String]
          #   REQUIRED: The resource for which the policy detail is being requested.
          #   +resource+ is usually specified as a path. For example, a Project
          #   resource is specified as +projects/{project}+.
          # @param permissions [Array<String>]
          #   The set of permissions to check for the +resource+. Permissions with
          #   wildcards (such as '*' or 'storage.*') are not allowed. For more
          #   information see
          #   [IAM Overview](https://cloud.google.com/iam/docs/overview#permissions).
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Iam::V1::TestIamPermissionsResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Iam::V1::TestIamPermissionsResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/kms"
          #
          #   key_management_service_client = Google::Cloud::Kms.new(version: :v1)
          #   formatted_resource = Google::Cloud::Kms::V1::KeyManagementServiceClient.key_ring_path("[PROJECT]", "[LOCATION]", "[KEY_RING]")
          #
          #   # TODO: Initialize +permissions+:
          #   permissions = []
          #   response = key_management_service_client.test_iam_permissions(formatted_resource, permissions)

          def test_iam_permissions \
              resource,
              permissions,
              options: nil,
              &block
            req = {
              resource: resource,
              permissions: permissions
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Iam::V1::TestIamPermissionsRequest)
            @test_iam_permissions.call(req, options, &block)
          end
        end
      end
    end
  end
end
