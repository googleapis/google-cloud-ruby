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
# https://github.com/googleapis/googleapis/blob/master/google/cloud/oslogin/v1/oslogin.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.


require "json"
require "pathname"

require "google/gax"

require "google/cloud/oslogin/v1/oslogin_pb"
require "google/cloud/os_login/v1/credentials"
require "google/cloud/os_login/version"

module Google
  module Cloud
    module OsLogin
      module V1
        # Cloud OS Login API
        #
        # The Cloud OS Login API allows you to manage users and their associated SSH
        # public keys for logging into virtual machines on Google Cloud Platform.
        #
        # @!attribute [r] os_login_service_stub
        #   @return [Google::Cloud::Oslogin::V1::OsLoginService::Stub]
        class OsLoginServiceClient
          # @private
          attr_reader :os_login_service_stub

          # The default address of the service.
          SERVICE_ADDRESS = "oslogin.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          # The default set of gRPC interceptors.
          GRPC_INTERCEPTORS = []

          DEFAULT_TIMEOUT = 30

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform",
            "https://www.googleapis.com/auth/compute"
          ].freeze


          POSIX_ACCOUNT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "users/{user}/projects/{project}"
          )

          private_constant :POSIX_ACCOUNT_PATH_TEMPLATE

          SSH_PUBLIC_KEY_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "users/{user}/sshPublicKeys/{fingerprint}"
          )

          private_constant :SSH_PUBLIC_KEY_PATH_TEMPLATE

          USER_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "users/{user}"
          )

          private_constant :USER_PATH_TEMPLATE

          # Returns a fully-qualified posix_account resource name string.
          # @param user [String]
          # @param project [String]
          # @return [String]
          def self.posix_account_path user, project
            POSIX_ACCOUNT_PATH_TEMPLATE.render(
              :"user" => user,
              :"project" => project
            )
          end

          # Returns a fully-qualified ssh_public_key resource name string.
          # @param user [String]
          # @param fingerprint [String]
          # @return [String]
          def self.ssh_public_key_path user, fingerprint
            SSH_PUBLIC_KEY_PATH_TEMPLATE.render(
              :"user" => user,
              :"fingerprint" => fingerprint
            )
          end

          # Returns a fully-qualified user resource name string.
          # @param user [String]
          # @return [String]
          def self.user_path user
            USER_PATH_TEMPLATE.render(
              :"user" => user
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
            require "google/cloud/oslogin/v1/oslogin_services_pb"

            credentials ||= Google::Cloud::OsLogin::V1::Credentials.default

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::OsLogin::V1::Credentials.new(credentials).updater_proc
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

            package_version = Google::Cloud::OsLogin::VERSION

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
              "os_login_service_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.cloud.oslogin.v1.OsLoginService",
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
            @os_login_service_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Cloud::Oslogin::V1::OsLoginService::Stub.method(:new)
            )

            @delete_posix_account = Google::Gax.create_api_call(
              @os_login_service_stub.method(:delete_posix_account),
              defaults["delete_posix_account"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @delete_ssh_public_key = Google::Gax.create_api_call(
              @os_login_service_stub.method(:delete_ssh_public_key),
              defaults["delete_ssh_public_key"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @get_login_profile = Google::Gax.create_api_call(
              @os_login_service_stub.method(:get_login_profile),
              defaults["get_login_profile"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @get_ssh_public_key = Google::Gax.create_api_call(
              @os_login_service_stub.method(:get_ssh_public_key),
              defaults["get_ssh_public_key"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @import_ssh_public_key = Google::Gax.create_api_call(
              @os_login_service_stub.method(:import_ssh_public_key),
              defaults["import_ssh_public_key"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @update_ssh_public_key = Google::Gax.create_api_call(
              @os_login_service_stub.method(:update_ssh_public_key),
              defaults["update_ssh_public_key"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
          end

          # Service calls

          # Deletes a POSIX account.
          #
          # @param name [String]
          #   Required. A reference to the POSIX account to update. POSIX accounts are identified
          #   by the project ID they are associated with. A reference to the POSIX
          #   account is in format `users/{user}/projects/{project}`.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/os_login"
          #
          #   os_login_client = Google::Cloud::OsLogin.new(version: :v1)
          #   formatted_name = Google::Cloud::OsLogin::V1::OsLoginServiceClient.posix_account_path("[USER]", "[PROJECT]")
          #   os_login_client.delete_posix_account(formatted_name)

          def delete_posix_account \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Oslogin::V1::DeletePosixAccountRequest)
            @delete_posix_account.call(req, options, &block)
            nil
          end

          # Deletes an SSH public key.
          #
          # @param name [String]
          #   Required. The fingerprint of the public key to update. Public keys are identified by
          #   their SHA-256 fingerprint. The fingerprint of the public key is in format
          #   `users/{user}/sshPublicKeys/{fingerprint}`.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/os_login"
          #
          #   os_login_client = Google::Cloud::OsLogin.new(version: :v1)
          #   formatted_name = Google::Cloud::OsLogin::V1::OsLoginServiceClient.ssh_public_key_path("[USER]", "[FINGERPRINT]")
          #   os_login_client.delete_ssh_public_key(formatted_name)

          def delete_ssh_public_key \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Oslogin::V1::DeleteSshPublicKeyRequest)
            @delete_ssh_public_key.call(req, options, &block)
            nil
          end

          # Retrieves the profile information used for logging in to a virtual machine
          # on Google Compute Engine.
          #
          # @param name [String]
          #   Required. The unique ID for the user in format `users/{user}`.
          # @param project_id [String]
          #   The project ID of the Google Cloud Platform project.
          # @param system_id [String]
          #   A system ID for filtering the results of the request.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Oslogin::V1::LoginProfile]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Oslogin::V1::LoginProfile]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/os_login"
          #
          #   os_login_client = Google::Cloud::OsLogin.new(version: :v1)
          #   formatted_name = Google::Cloud::OsLogin::V1::OsLoginServiceClient.user_path("[USER]")
          #   response = os_login_client.get_login_profile(formatted_name)

          def get_login_profile \
              name,
              project_id: nil,
              system_id: nil,
              options: nil,
              &block
            req = {
              name: name,
              project_id: project_id,
              system_id: system_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Oslogin::V1::GetLoginProfileRequest)
            @get_login_profile.call(req, options, &block)
          end

          # Retrieves an SSH public key.
          #
          # @param name [String]
          #   Required. The fingerprint of the public key to retrieve. Public keys are identified
          #   by their SHA-256 fingerprint. The fingerprint of the public key is in
          #   format `users/{user}/sshPublicKeys/{fingerprint}`.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Oslogin::Common::SshPublicKey]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Oslogin::Common::SshPublicKey]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/os_login"
          #
          #   os_login_client = Google::Cloud::OsLogin.new(version: :v1)
          #   formatted_name = Google::Cloud::OsLogin::V1::OsLoginServiceClient.ssh_public_key_path("[USER]", "[FINGERPRINT]")
          #   response = os_login_client.get_ssh_public_key(formatted_name)

          def get_ssh_public_key \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Oslogin::V1::GetSshPublicKeyRequest)
            @get_ssh_public_key.call(req, options, &block)
          end

          # Adds an SSH public key and returns the profile information. Default POSIX
          # account information is set when no username and UID exist as part of the
          # login profile.
          #
          # @param parent [String]
          #   Required. The unique ID for the user in format `users/{user}`.
          # @param ssh_public_key [Google::Cloud::Oslogin::Common::SshPublicKey | Hash]
          #   Optional. The SSH public key and expiration time.
          #   A hash of the same form as `Google::Cloud::Oslogin::Common::SshPublicKey`
          #   can also be provided.
          # @param project_id [String]
          #   The project ID of the Google Cloud Platform project.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Oslogin::V1::ImportSshPublicKeyResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Oslogin::V1::ImportSshPublicKeyResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/os_login"
          #
          #   os_login_client = Google::Cloud::OsLogin.new(version: :v1)
          #   formatted_parent = Google::Cloud::OsLogin::V1::OsLoginServiceClient.user_path("[USER]")
          #   response = os_login_client.import_ssh_public_key(formatted_parent)

          def import_ssh_public_key \
              parent,
              ssh_public_key: nil,
              project_id: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              ssh_public_key: ssh_public_key,
              project_id: project_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Oslogin::V1::ImportSshPublicKeyRequest)
            @import_ssh_public_key.call(req, options, &block)
          end

          # Updates an SSH public key and returns the profile information. This method
          # supports patch semantics.
          #
          # @param name [String]
          #   Required. The fingerprint of the public key to update. Public keys are identified by
          #   their SHA-256 fingerprint. The fingerprint of the public key is in format
          #   `users/{user}/sshPublicKeys/{fingerprint}`.
          # @param ssh_public_key [Google::Cloud::Oslogin::Common::SshPublicKey | Hash]
          #   Required. The SSH public key and expiration time.
          #   A hash of the same form as `Google::Cloud::Oslogin::Common::SshPublicKey`
          #   can also be provided.
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   Mask to control which fields get updated. Updates all if not present.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Oslogin::Common::SshPublicKey]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Oslogin::Common::SshPublicKey]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/os_login"
          #
          #   os_login_client = Google::Cloud::OsLogin.new(version: :v1)
          #   formatted_name = Google::Cloud::OsLogin::V1::OsLoginServiceClient.ssh_public_key_path("[USER]", "[FINGERPRINT]")
          #
          #   # TODO: Initialize `ssh_public_key`:
          #   ssh_public_key = {}
          #   response = os_login_client.update_ssh_public_key(formatted_name, ssh_public_key)

          def update_ssh_public_key \
              name,
              ssh_public_key,
              update_mask: nil,
              options: nil,
              &block
            req = {
              name: name,
              ssh_public_key: ssh_public_key,
              update_mask: update_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Oslogin::V1::UpdateSshPublicKeyRequest)
            @update_ssh_public_key.call(req, options, &block)
          end
        end
      end
    end
  end
end
