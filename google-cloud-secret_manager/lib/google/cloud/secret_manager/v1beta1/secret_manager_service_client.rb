# Copyright 2019 Google LLC
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
# https://github.com/googleapis/googleapis/blob/master/google/cloud/secret_manager/v1beta1/service.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.


require "json"
require "pathname"

require "google/gax"

require "google/cloud/secret_manager/v1beta1/service_pb"
require "google/cloud/secret_manager/v1beta1/credentials"
require "google/cloud/secret_manager/version"

module Google
  module Cloud
    module SecretManager
      module V1beta1
        # Secret Manager Service
        #
        # Manages secrets and operations using those secrets. Implements a REST
        # model with the following objects:
        #
        # * {Google::Cloud::SecretManager::V1beta1::Secret Secret}
        # * {Google::Cloud::SecretManager::V1beta1::SecretVersion SecretVersion}
        #
        # @!attribute [r] secret_manager_service_stub
        #   @return [Google::Cloud::SecretManager::V1beta1::SecretManagerService::Stub]
        class SecretManagerServiceClient
          # @private
          attr_reader :secret_manager_service_stub

          # The default address of the service.
          SERVICE_ADDRESS = "secretmanager.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          # The default set of gRPC interceptors.
          GRPC_INTERCEPTORS = []

          DEFAULT_TIMEOUT = 30

          PAGE_DESCRIPTORS = {
            "list_secrets" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "secrets"),
            "list_secret_versions" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "versions")
          }.freeze

          private_constant :PAGE_DESCRIPTORS

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform"
          ].freeze


          PROJECT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}"
          )

          private_constant :PROJECT_PATH_TEMPLATE

          SECRET_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/secrets/{secret}"
          )

          private_constant :SECRET_PATH_TEMPLATE

          SECRET_VERSION_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/secrets/{secret}/versions/{secret_version}"
          )

          private_constant :SECRET_VERSION_PATH_TEMPLATE

          # Returns a fully-qualified project resource name string.
          # @param project [String]
          # @return [String]
          def self.project_path project
            PROJECT_PATH_TEMPLATE.render(
              :"project" => project
            )
          end

          # Returns a fully-qualified secret resource name string.
          # @param project [String]
          # @param secret [String]
          # @return [String]
          def self.secret_path project, secret
            SECRET_PATH_TEMPLATE.render(
              :"project" => project,
              :"secret" => secret
            )
          end

          # Returns a fully-qualified secret_version resource name string.
          # @param project [String]
          # @param secret [String]
          # @param secret_version [String]
          # @return [String]
          def self.secret_version_path project, secret, secret_version
            SECRET_VERSION_PATH_TEMPLATE.render(
              :"project" => project,
              :"secret" => secret,
              :"secret_version" => secret_version
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
            require "google/cloud/secret_manager/v1beta1/service_services_pb"

            credentials ||= Google::Cloud::SecretManager::V1beta1::Credentials.default

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::SecretManager::V1beta1::Credentials.new(credentials).updater_proc
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

            package_version = Google::Cloud::SecretManager::VERSION

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/#{package_version} gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            headers.merge!(metadata) unless metadata.nil?
            client_config_file = Pathname.new(__dir__).join(
              "secret_manager_service_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.cloud.secrets.v1beta1.SecretManagerService",
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
            service_path = service_address || self.class::SERVICE_ADDRESS
            port = service_port || self.class::DEFAULT_SERVICE_PORT
            interceptors = self.class::GRPC_INTERCEPTORS
            @secret_manager_service_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Cloud::SecretManager::V1beta1::SecretManagerService::Stub.method(:new)
            )

            @list_secrets = Google::Gax.create_api_call(
              @secret_manager_service_stub.method(:list_secrets),
              defaults["list_secrets"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @create_secret = Google::Gax.create_api_call(
              @secret_manager_service_stub.method(:create_secret),
              defaults["create_secret"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @add_secret_version = Google::Gax.create_api_call(
              @secret_manager_service_stub.method(:add_secret_version),
              defaults["add_secret_version"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @get_secret = Google::Gax.create_api_call(
              @secret_manager_service_stub.method(:get_secret),
              defaults["get_secret"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @update_secret = Google::Gax.create_api_call(
              @secret_manager_service_stub.method(:update_secret),
              defaults["update_secret"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'secret.name' => request.secret.name}
              end
            )
            @delete_secret = Google::Gax.create_api_call(
              @secret_manager_service_stub.method(:delete_secret),
              defaults["delete_secret"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @list_secret_versions = Google::Gax.create_api_call(
              @secret_manager_service_stub.method(:list_secret_versions),
              defaults["list_secret_versions"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @get_secret_version = Google::Gax.create_api_call(
              @secret_manager_service_stub.method(:get_secret_version),
              defaults["get_secret_version"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @access_secret_version = Google::Gax.create_api_call(
              @secret_manager_service_stub.method(:access_secret_version),
              defaults["access_secret_version"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @disable_secret_version = Google::Gax.create_api_call(
              @secret_manager_service_stub.method(:disable_secret_version),
              defaults["disable_secret_version"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @enable_secret_version = Google::Gax.create_api_call(
              @secret_manager_service_stub.method(:enable_secret_version),
              defaults["enable_secret_version"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @destroy_secret_version = Google::Gax.create_api_call(
              @secret_manager_service_stub.method(:destroy_secret_version),
              defaults["destroy_secret_version"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @set_iam_policy = Google::Gax.create_api_call(
              @secret_manager_service_stub.method(:set_iam_policy),
              defaults["set_iam_policy"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'resource' => request.resource}
              end
            )
            @get_iam_policy = Google::Gax.create_api_call(
              @secret_manager_service_stub.method(:get_iam_policy),
              defaults["get_iam_policy"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'resource' => request.resource}
              end
            )
            @test_iam_permissions = Google::Gax.create_api_call(
              @secret_manager_service_stub.method(:test_iam_permissions),
              defaults["test_iam_permissions"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'resource' => request.resource}
              end
            )
          end

          # Service calls

          # Lists {Google::Cloud::SecretManager::V1beta1::Secret Secrets}.
          #
          # @param parent [String]
          #   Required. The resource name of the project associated with the
          #   {Google::Cloud::SecretManager::V1beta1::Secret Secrets}, in the format `projects/*`.
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::SecretManager::V1beta1::Secret>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::SecretManager::V1beta1::Secret>]
          #   An enumerable of Google::Cloud::SecretManager::V1beta1::Secret instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/secret_manager"
          #
          #   secret_manager_client = Google::Cloud::SecretManager.new(version: :v1beta1)
          #   formatted_parent = Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient.project_path("[PROJECT]")
          #
          #   # Iterate over all results.
          #   secret_manager_client.list_secrets(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   secret_manager_client.list_secrets(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_secrets \
              parent,
              page_size: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::SecretManager::V1beta1::ListSecretsRequest)
            @list_secrets.call(req, options, &block)
          end

          # Creates a new {Google::Cloud::SecretManager::V1beta1::Secret Secret} containing no {Google::Cloud::SecretManager::V1beta1::SecretVersion SecretVersions}.
          #
          # @param parent [String]
          #   Required. The resource name of the project to associate with the
          #   {Google::Cloud::SecretManager::V1beta1::Secret Secret}, in the format `projects/*`.
          # @param secret_id [String]
          #   Required. This must be unique within the project.
          # @param secret [Google::Cloud::SecretManager::V1beta1::Secret | Hash]
          #   A {Google::Cloud::SecretManager::V1beta1::Secret Secret} with initial field values.
          #   A hash of the same form as `Google::Cloud::SecretManager::V1beta1::Secret`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::SecretManager::V1beta1::Secret]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::SecretManager::V1beta1::Secret]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/secret_manager"
          #
          #   secret_manager_client = Google::Cloud::SecretManager.new(version: :v1beta1)
          #   formatted_parent = Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient.project_path("[PROJECT]")
          #
          #   # TODO: Initialize `secret_id`:
          #   secret_id = ''
          #   response = secret_manager_client.create_secret(formatted_parent, secret_id)

          def create_secret \
              parent,
              secret_id,
              secret: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              secret_id: secret_id,
              secret: secret
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::SecretManager::V1beta1::CreateSecretRequest)
            @create_secret.call(req, options, &block)
          end

          # Creates a new {Google::Cloud::SecretManager::V1beta1::SecretVersion SecretVersion} containing secret data and attaches
          # it to an existing {Google::Cloud::SecretManager::V1beta1::Secret Secret}.
          #
          # @param parent [String]
          #   Required. The resource name of the {Google::Cloud::SecretManager::V1beta1::Secret Secret} to associate with the
          #   {Google::Cloud::SecretManager::V1beta1::SecretVersion SecretVersion} in the format `projects/*/secrets/*`.
          # @param payload [Google::Cloud::SecretManager::V1beta1::SecretPayload | Hash]
          #   Required. The secret payload of the {Google::Cloud::SecretManager::V1beta1::SecretVersion SecretVersion}.
          #   A hash of the same form as `Google::Cloud::SecretManager::V1beta1::SecretPayload`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::SecretManager::V1beta1::SecretVersion]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::SecretManager::V1beta1::SecretVersion]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/secret_manager"
          #
          #   secret_manager_client = Google::Cloud::SecretManager.new(version: :v1beta1)
          #   formatted_parent = Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient.secret_path("[PROJECT]", "[SECRET]")
          #
          #   # TODO: Initialize `payload`:
          #   payload = {}
          #   response = secret_manager_client.add_secret_version(formatted_parent, payload)

          def add_secret_version \
              parent,
              payload,
              options: nil,
              &block
            req = {
              parent: parent,
              payload: payload
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::SecretManager::V1beta1::AddSecretVersionRequest)
            @add_secret_version.call(req, options, &block)
          end

          # Gets metadata for a given {Google::Cloud::SecretManager::V1beta1::Secret Secret}.
          #
          # @param name [String]
          #   Required. The resource name of the {Google::Cloud::SecretManager::V1beta1::Secret Secret}, in the format `projects/*/secrets/*`.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::SecretManager::V1beta1::Secret]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::SecretManager::V1beta1::Secret]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/secret_manager"
          #
          #   secret_manager_client = Google::Cloud::SecretManager.new(version: :v1beta1)
          #   formatted_name = Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient.secret_path("[PROJECT]", "[SECRET]")
          #   response = secret_manager_client.get_secret(formatted_name)

          def get_secret \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::SecretManager::V1beta1::GetSecretRequest)
            @get_secret.call(req, options, &block)
          end

          # Updates metadata of an existing {Google::Cloud::SecretManager::V1beta1::Secret Secret}.
          #
          # @param secret [Google::Cloud::SecretManager::V1beta1::Secret | Hash]
          #   Required. {Google::Cloud::SecretManager::V1beta1::Secret Secret} with updated field values.
          #   A hash of the same form as `Google::Cloud::SecretManager::V1beta1::Secret`
          #   can also be provided.
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   Required. Specifies the fields to be updated.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::SecretManager::V1beta1::Secret]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::SecretManager::V1beta1::Secret]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/secret_manager"
          #
          #   secret_manager_client = Google::Cloud::SecretManager.new(version: :v1beta1)
          #
          #   # TODO: Initialize `secret`:
          #   secret = {}
          #
          #   # TODO: Initialize `update_mask`:
          #   update_mask = {}
          #   response = secret_manager_client.update_secret(secret, update_mask)

          def update_secret \
              secret,
              update_mask,
              options: nil,
              &block
            req = {
              secret: secret,
              update_mask: update_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::SecretManager::V1beta1::UpdateSecretRequest)
            @update_secret.call(req, options, &block)
          end

          # Deletes a {Google::Cloud::SecretManager::V1beta1::Secret Secret}.
          #
          # @param name [String]
          #   Required. The resource name of the {Google::Cloud::SecretManager::V1beta1::Secret Secret} to delete in the format
          #   `projects/*/secrets/*`.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/secret_manager"
          #
          #   secret_manager_client = Google::Cloud::SecretManager.new(version: :v1beta1)
          #   formatted_name = Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient.secret_path("[PROJECT]", "[SECRET]")
          #   secret_manager_client.delete_secret(formatted_name)

          def delete_secret \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::SecretManager::V1beta1::DeleteSecretRequest)
            @delete_secret.call(req, options, &block)
            nil
          end

          # Lists {Google::Cloud::SecretManager::V1beta1::SecretVersion SecretVersions}. This call does not return secret
          # data.
          #
          # @param parent [String]
          #   Required. The resource name of the {Google::Cloud::SecretManager::V1beta1::Secret Secret} associated with the
          #   {Google::Cloud::SecretManager::V1beta1::SecretVersion SecretVersions} to list, in the format
          #   `projects/*/secrets/*`.
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::SecretManager::V1beta1::SecretVersion>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::SecretManager::V1beta1::SecretVersion>]
          #   An enumerable of Google::Cloud::SecretManager::V1beta1::SecretVersion instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/secret_manager"
          #
          #   secret_manager_client = Google::Cloud::SecretManager.new(version: :v1beta1)
          #   formatted_parent = Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient.secret_path("[PROJECT]", "[SECRET]")
          #
          #   # Iterate over all results.
          #   secret_manager_client.list_secret_versions(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   secret_manager_client.list_secret_versions(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_secret_versions \
              parent,
              page_size: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::SecretManager::V1beta1::ListSecretVersionsRequest)
            @list_secret_versions.call(req, options, &block)
          end

          # Gets metadata for a {Google::Cloud::SecretManager::V1beta1::SecretVersion SecretVersion}.
          #
          # `projects/*/secrets/*/versions/latest` is an alias to the `latest`
          # {Google::Cloud::SecretManager::V1beta1::SecretVersion SecretVersion}.
          #
          # @param name [String]
          #   Required. The resource name of the {Google::Cloud::SecretManager::V1beta1::SecretVersion SecretVersion} in the format
          #   `projects/*/secrets/*/versions/*`.
          #   `projects/*/secrets/*/versions/latest` is an alias to the `latest`
          #   {Google::Cloud::SecretManager::V1beta1::SecretVersion SecretVersion}.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::SecretManager::V1beta1::SecretVersion]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::SecretManager::V1beta1::SecretVersion]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/secret_manager"
          #
          #   secret_manager_client = Google::Cloud::SecretManager.new(version: :v1beta1)
          #   formatted_name = Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient.secret_version_path("[PROJECT]", "[SECRET]", "[SECRET_VERSION]")
          #   response = secret_manager_client.get_secret_version(formatted_name)

          def get_secret_version \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::SecretManager::V1beta1::GetSecretVersionRequest)
            @get_secret_version.call(req, options, &block)
          end

          # Accesses a {Google::Cloud::SecretManager::V1beta1::SecretVersion SecretVersion}. This call returns the secret data.
          #
          # `projects/*/secrets/*/versions/latest` is an alias to the `latest`
          # {Google::Cloud::SecretManager::V1beta1::SecretVersion SecretVersion}.
          #
          # @param name [String]
          #   Required. The resource name of the {Google::Cloud::SecretManager::V1beta1::SecretVersion SecretVersion} in the format
          #   `projects/*/secrets/*/versions/*`.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::SecretManager::V1beta1::AccessSecretVersionResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::SecretManager::V1beta1::AccessSecretVersionResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/secret_manager"
          #
          #   secret_manager_client = Google::Cloud::SecretManager.new(version: :v1beta1)
          #   formatted_name = Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient.secret_version_path("[PROJECT]", "[SECRET]", "[SECRET_VERSION]")
          #   response = secret_manager_client.access_secret_version(formatted_name)

          def access_secret_version \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::SecretManager::V1beta1::AccessSecretVersionRequest)
            @access_secret_version.call(req, options, &block)
          end

          # Disables a {Google::Cloud::SecretManager::V1beta1::SecretVersion SecretVersion}.
          #
          # Sets the {Google::Cloud::SecretManager::V1beta1::SecretVersion#state state} of the {Google::Cloud::SecretManager::V1beta1::SecretVersion SecretVersion} to
          # {Google::Cloud::SecretManager::V1beta1::SecretVersion::State::DISABLED DISABLED}.
          #
          # @param name [String]
          #   Required. The resource name of the {Google::Cloud::SecretManager::V1beta1::SecretVersion SecretVersion} to disable in the format
          #   `projects/*/secrets/*/versions/*`.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::SecretManager::V1beta1::SecretVersion]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::SecretManager::V1beta1::SecretVersion]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/secret_manager"
          #
          #   secret_manager_client = Google::Cloud::SecretManager.new(version: :v1beta1)
          #   formatted_name = Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient.secret_version_path("[PROJECT]", "[SECRET]", "[SECRET_VERSION]")
          #   response = secret_manager_client.disable_secret_version(formatted_name)

          def disable_secret_version \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::SecretManager::V1beta1::DisableSecretVersionRequest)
            @disable_secret_version.call(req, options, &block)
          end

          # Enables a {Google::Cloud::SecretManager::V1beta1::SecretVersion SecretVersion}.
          #
          # Sets the {Google::Cloud::SecretManager::V1beta1::SecretVersion#state state} of the {Google::Cloud::SecretManager::V1beta1::SecretVersion SecretVersion} to
          # {Google::Cloud::SecretManager::V1beta1::SecretVersion::State::ENABLED ENABLED}.
          #
          # @param name [String]
          #   Required. The resource name of the {Google::Cloud::SecretManager::V1beta1::SecretVersion SecretVersion} to enable in the format
          #   `projects/*/secrets/*/versions/*`.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::SecretManager::V1beta1::SecretVersion]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::SecretManager::V1beta1::SecretVersion]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/secret_manager"
          #
          #   secret_manager_client = Google::Cloud::SecretManager.new(version: :v1beta1)
          #   formatted_name = Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient.secret_version_path("[PROJECT]", "[SECRET]", "[SECRET_VERSION]")
          #   response = secret_manager_client.enable_secret_version(formatted_name)

          def enable_secret_version \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::SecretManager::V1beta1::EnableSecretVersionRequest)
            @enable_secret_version.call(req, options, &block)
          end

          # Destroys a {Google::Cloud::SecretManager::V1beta1::SecretVersion SecretVersion}.
          #
          # Sets the {Google::Cloud::SecretManager::V1beta1::SecretVersion#state state} of the {Google::Cloud::SecretManager::V1beta1::SecretVersion SecretVersion} to
          # {Google::Cloud::SecretManager::V1beta1::SecretVersion::State::DESTROYED DESTROYED} and irrevocably destroys the
          # secret data.
          #
          # @param name [String]
          #   Required. The resource name of the {Google::Cloud::SecretManager::V1beta1::SecretVersion SecretVersion} to destroy in the format
          #   `projects/*/secrets/*/versions/*`.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::SecretManager::V1beta1::SecretVersion]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::SecretManager::V1beta1::SecretVersion]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/secret_manager"
          #
          #   secret_manager_client = Google::Cloud::SecretManager.new(version: :v1beta1)
          #   formatted_name = Google::Cloud::SecretManager::V1beta1::SecretManagerServiceClient.secret_version_path("[PROJECT]", "[SECRET]", "[SECRET_VERSION]")
          #   response = secret_manager_client.destroy_secret_version(formatted_name)

          def destroy_secret_version \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::SecretManager::V1beta1::DestroySecretVersionRequest)
            @destroy_secret_version.call(req, options, &block)
          end

          # Sets the access control policy on the specified secret. Replaces any
          # existing policy.
          #
          # Permissions on {Google::Cloud::SecretManager::V1beta1::SecretVersion SecretVersions} are enforced according
          # to the policy set on the associated {Google::Cloud::SecretManager::V1beta1::Secret Secret}.
          #
          # @param resource [String]
          #   REQUIRED: The resource for which the policy is being specified.
          #   See the operation documentation for the appropriate value for this field.
          # @param policy [Google::Iam::V1::Policy | Hash]
          #   REQUIRED: The complete policy to be applied to the `resource`. The size of
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
          #   require "google/cloud/secret_manager"
          #
          #   secret_manager_client = Google::Cloud::SecretManager.new(version: :v1beta1)
          #
          #   # TODO: Initialize `resource`:
          #   resource = ''
          #
          #   # TODO: Initialize `policy`:
          #   policy = {}
          #   response = secret_manager_client.set_iam_policy(resource, policy)

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

          # Gets the access control policy for a secret.
          # Returns empty policy if the secret exists and does not have a policy set.
          #
          # @param resource [String]
          #   REQUIRED: The resource for which the policy is being requested.
          #   See the operation documentation for the appropriate value for this field.
          # @param options_ [Google::Iam::V1::GetPolicyOptions | Hash]
          #   OPTIONAL: A `GetPolicyOptions` object for specifying options to
          #   `GetIamPolicy`. This field is only used by Cloud IAM.
          #   A hash of the same form as `Google::Iam::V1::GetPolicyOptions`
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
          #   require "google/cloud/secret_manager"
          #
          #   secret_manager_client = Google::Cloud::SecretManager.new(version: :v1beta1)
          #
          #   # TODO: Initialize `resource`:
          #   resource = ''
          #   response = secret_manager_client.get_iam_policy(resource)

          def get_iam_policy \
              resource,
              options_: nil,
              options: nil,
              &block
            req = {
              resource: resource,
              options: options_
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Iam::V1::GetIamPolicyRequest)
            @get_iam_policy.call(req, options, &block)
          end

          # Returns permissions that a caller has for the specified secret.
          # If the secret does not exist, this call returns an empty set of
          # permissions, not a NOT_FOUND error.
          #
          # Note: This operation is designed to be used for building permission-aware
          # UIs and command-line tools, not for authorization checking. This operation
          # may "fail open" without warning.
          #
          # @param resource [String]
          #   REQUIRED: The resource for which the policy detail is being requested.
          #   See the operation documentation for the appropriate value for this field.
          # @param permissions [Array<String>]
          #   The set of permissions to check for the `resource`. Permissions with
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
          #   require "google/cloud/secret_manager"
          #
          #   secret_manager_client = Google::Cloud::SecretManager.new(version: :v1beta1)
          #
          #   # TODO: Initialize `resource`:
          #   resource = ''
          #
          #   # TODO: Initialize `permissions`:
          #   permissions = []
          #   response = secret_manager_client.test_iam_permissions(resource, permissions)

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
