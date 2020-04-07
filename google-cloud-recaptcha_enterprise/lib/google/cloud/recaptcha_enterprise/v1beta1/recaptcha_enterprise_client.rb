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
# https://github.com/googleapis/googleapis/blob/master/google/cloud/recaptchaenterprise/v1beta1/recaptchaenterprise.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.


require "json"
require "pathname"

require "google/gax"

require "google/cloud/recaptchaenterprise/v1beta1/recaptchaenterprise_pb"
require "google/cloud/recaptcha_enterprise/v1beta1/credentials"
require "google/cloud/recaptcha_enterprise/version"

module Google
  module Cloud
    module RecaptchaEnterprise
      module V1beta1
        # Service to determine the likelihood an event is legitimate.
        #
        # @!attribute [r] recaptcha_enterprise_stub
        #   @return [Google::Cloud::RecaptchaEnterprise::V1beta1::RecaptchaEnterprise::Stub]
        class RecaptchaEnterpriseClient
          # @private
          attr_reader :recaptcha_enterprise_stub

          # The default address of the service.
          SERVICE_ADDRESS = "recaptchaenterprise.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          # The default set of gRPC interceptors.
          GRPC_INTERCEPTORS = []

          DEFAULT_TIMEOUT = 30

          PAGE_DESCRIPTORS = {
            "list_keys" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "keys")
          }.freeze

          private_constant :PAGE_DESCRIPTORS

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform"
          ].freeze


          ASSESSMENT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/assessments/{assessment}"
          )

          private_constant :ASSESSMENT_PATH_TEMPLATE

          KEY_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/keys/{key}"
          )

          private_constant :KEY_PATH_TEMPLATE

          PROJECT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}"
          )

          private_constant :PROJECT_PATH_TEMPLATE

          # Returns a fully-qualified assessment resource name string.
          # @param project [String]
          # @param assessment [String]
          # @return [String]
          def self.assessment_path project, assessment
            ASSESSMENT_PATH_TEMPLATE.render(
              :"project" => project,
              :"assessment" => assessment
            )
          end

          # Returns a fully-qualified key resource name string.
          # @param project [String]
          # @param key [String]
          # @return [String]
          def self.key_path project, key
            KEY_PATH_TEMPLATE.render(
              :"project" => project,
              :"key" => key
            )
          end

          # Returns a fully-qualified project resource name string.
          # @param project [String]
          # @return [String]
          def self.project_path project
            PROJECT_PATH_TEMPLATE.render(
              :"project" => project
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
            require "google/cloud/recaptchaenterprise/v1beta1/recaptchaenterprise_services_pb"

            credentials ||= Google::Cloud::RecaptchaEnterprise::V1beta1::Credentials.default

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::RecaptchaEnterprise::V1beta1::Credentials.new(credentials).updater_proc
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

            package_version = Google::Cloud::RecaptchaEnterprise::VERSION

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
              "recaptcha_enterprise_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.cloud.recaptchaenterprise.v1beta1.RecaptchaEnterpriseServiceV1Beta1",
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
            @recaptcha_enterprise_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Cloud::RecaptchaEnterprise::V1beta1::RecaptchaEnterprise::Stub.method(:new)
            )

            @create_assessment = Google::Gax.create_api_call(
              @recaptcha_enterprise_stub.method(:create_assessment),
              defaults["create_assessment"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @annotate_assessment = Google::Gax.create_api_call(
              @recaptcha_enterprise_stub.method(:annotate_assessment),
              defaults["annotate_assessment"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @create_key = Google::Gax.create_api_call(
              @recaptcha_enterprise_stub.method(:create_key),
              defaults["create_key"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @list_keys = Google::Gax.create_api_call(
              @recaptcha_enterprise_stub.method(:list_keys),
              defaults["list_keys"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @get_key = Google::Gax.create_api_call(
              @recaptcha_enterprise_stub.method(:get_key),
              defaults["get_key"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @update_key = Google::Gax.create_api_call(
              @recaptcha_enterprise_stub.method(:update_key),
              defaults["update_key"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'key.name' => request.key.name}
              end
            )
            @delete_key = Google::Gax.create_api_call(
              @recaptcha_enterprise_stub.method(:delete_key),
              defaults["delete_key"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
          end

          # Service calls

          # Creates an Assessment of the likelihood an event is legitimate.
          #
          # @param parent [String]
          #   Required. The name of the project in which the assessment will be created,
          #   in the format "projects/\\{project_number}".
          # @param assessment [Google::Cloud::RecaptchaEnterprise::V1beta1::Assessment | Hash]
          #   Required. The assessment details.
          #   A hash of the same form as `Google::Cloud::RecaptchaEnterprise::V1beta1::Assessment`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::RecaptchaEnterprise::V1beta1::Assessment]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::RecaptchaEnterprise::V1beta1::Assessment]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/recaptcha_enterprise"
          #
          #   recaptcha_enterprise_client = Google::Cloud::RecaptchaEnterprise.new(version: :v1beta1)
          #   formatted_parent = Google::Cloud::RecaptchaEnterprise::V1beta1::RecaptchaEnterpriseClient.project_path("[PROJECT]")
          #
          #   # TODO: Initialize `assessment`:
          #   assessment = {}
          #   response = recaptcha_enterprise_client.create_assessment(formatted_parent, assessment)

          def create_assessment \
              parent,
              assessment,
              options: nil,
              &block
            req = {
              parent: parent,
              assessment: assessment
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::RecaptchaEnterprise::V1beta1::CreateAssessmentRequest)
            @create_assessment.call(req, options, &block)
          end

          # Annotates a previously created Assessment to provide additional information
          # on whether the event turned out to be authentic or fradulent.
          #
          # @param name [String]
          #   Required. The resource name of the Assessment, in the format
          #   "projects/\\{project_number}/assessments/\\{assessment_id}".
          # @param annotation [Google::Cloud::RecaptchaEnterprise::V1beta1::AnnotateAssessmentRequest::Annotation]
          #   Required. The annotation that will be assigned to the Event.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::RecaptchaEnterprise::V1beta1::AnnotateAssessmentResponse]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::RecaptchaEnterprise::V1beta1::AnnotateAssessmentResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/recaptcha_enterprise"
          #
          #   recaptcha_enterprise_client = Google::Cloud::RecaptchaEnterprise.new(version: :v1beta1)
          #   formatted_name = Google::Cloud::RecaptchaEnterprise::V1beta1::RecaptchaEnterpriseClient.assessment_path("[PROJECT]", "[ASSESSMENT]")
          #
          #   # TODO: Initialize `annotation`:
          #   annotation = :ANNOTATION_UNSPECIFIED
          #   response = recaptcha_enterprise_client.annotate_assessment(formatted_name, annotation)

          def annotate_assessment \
              name,
              annotation,
              options: nil,
              &block
            req = {
              name: name,
              annotation: annotation
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::RecaptchaEnterprise::V1beta1::AnnotateAssessmentRequest)
            @annotate_assessment.call(req, options, &block)
          end

          # Creates a new reCAPTCHA Enterprise key.
          #
          # @param parent [String]
          #   Required. The name of the project in which the key will be created, in the
          #   format "projects/\\{project_number}".
          # @param key [Google::Cloud::RecaptchaEnterprise::V1beta1::Key | Hash]
          #   Required. Information to create a reCAPTCHA Enterprise key.
          #   A hash of the same form as `Google::Cloud::RecaptchaEnterprise::V1beta1::Key`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::RecaptchaEnterprise::V1beta1::Key]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::RecaptchaEnterprise::V1beta1::Key]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/recaptcha_enterprise"
          #
          #   recaptcha_enterprise_client = Google::Cloud::RecaptchaEnterprise.new(version: :v1beta1)
          #   formatted_parent = Google::Cloud::RecaptchaEnterprise::V1beta1::RecaptchaEnterpriseClient.project_path("[PROJECT]")
          #
          #   # TODO: Initialize `key`:
          #   key = {}
          #   response = recaptcha_enterprise_client.create_key(formatted_parent, key)

          def create_key \
              parent,
              key,
              options: nil,
              &block
            req = {
              parent: parent,
              key: key
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::RecaptchaEnterprise::V1beta1::CreateKeyRequest)
            @create_key.call(req, options, &block)
          end

          # Returns the list of all keys that belong to a project.
          #
          # @param parent [String]
          #   Required. The name of the project that contains the keys that will be
          #   listed, in the format "projects/\\{project_number}".
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::RecaptchaEnterprise::V1beta1::Key>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::RecaptchaEnterprise::V1beta1::Key>]
          #   An enumerable of Google::Cloud::RecaptchaEnterprise::V1beta1::Key instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/recaptcha_enterprise"
          #
          #   recaptcha_enterprise_client = Google::Cloud::RecaptchaEnterprise.new(version: :v1beta1)
          #   formatted_parent = Google::Cloud::RecaptchaEnterprise::V1beta1::RecaptchaEnterpriseClient.project_path("[PROJECT]")
          #
          #   # Iterate over all results.
          #   recaptcha_enterprise_client.list_keys(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   recaptcha_enterprise_client.list_keys(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_keys \
              parent,
              page_size: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::RecaptchaEnterprise::V1beta1::ListKeysRequest)
            @list_keys.call(req, options, &block)
          end

          # Returns the specified key.
          #
          # @param name [String]
          #   Required. The name of the requested key, in the format
          #   "projects/\\{project_number}/keys/\\{key_id}".
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::RecaptchaEnterprise::V1beta1::Key]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::RecaptchaEnterprise::V1beta1::Key]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/recaptcha_enterprise"
          #
          #   recaptcha_enterprise_client = Google::Cloud::RecaptchaEnterprise.new(version: :v1beta1)
          #   formatted_name = Google::Cloud::RecaptchaEnterprise::V1beta1::RecaptchaEnterpriseClient.key_path("[PROJECT]", "[KEY]")
          #   response = recaptcha_enterprise_client.get_key(formatted_name)

          def get_key \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::RecaptchaEnterprise::V1beta1::GetKeyRequest)
            @get_key.call(req, options, &block)
          end

          # Updates the specified key.
          #
          # @param key [Google::Cloud::RecaptchaEnterprise::V1beta1::Key | Hash]
          #   Required. The key to update.
          #   A hash of the same form as `Google::Cloud::RecaptchaEnterprise::V1beta1::Key`
          #   can also be provided.
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   Optional. The mask to control which field of the key get updated. If the mask is not
          #   present, all fields will be updated.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::RecaptchaEnterprise::V1beta1::Key]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::RecaptchaEnterprise::V1beta1::Key]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/recaptcha_enterprise"
          #
          #   recaptcha_enterprise_client = Google::Cloud::RecaptchaEnterprise.new(version: :v1beta1)
          #
          #   # TODO: Initialize `key`:
          #   key = {}
          #   response = recaptcha_enterprise_client.update_key(key)

          def update_key \
              key,
              update_mask: nil,
              options: nil,
              &block
            req = {
              key: key,
              update_mask: update_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::RecaptchaEnterprise::V1beta1::UpdateKeyRequest)
            @update_key.call(req, options, &block)
          end

          # Deletes the specified key.
          #
          # @param name [String]
          #   Required. The name of the key to be deleted, in the format
          #   "projects/\\{project_number}/keys/\\{key_id}".
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/recaptcha_enterprise"
          #
          #   recaptcha_enterprise_client = Google::Cloud::RecaptchaEnterprise.new(version: :v1beta1)
          #   formatted_name = Google::Cloud::RecaptchaEnterprise::V1beta1::RecaptchaEnterpriseClient.key_path("[PROJECT]", "[KEY]")
          #   recaptcha_enterprise_client.delete_key(formatted_name)

          def delete_key \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::RecaptchaEnterprise::V1beta1::DeleteKeyRequest)
            @delete_key.call(req, options, &block)
            nil
          end
        end
      end
    end
  end
end
