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
# https://github.com/googleapis/googleapis/blob/master/google/privacy/dlp/v2/dlp.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.

require "json"
require "pathname"

require "google/gax"

require "google/privacy/dlp/v2/dlp_pb"
require "google/cloud/dlp/credentials"

module Google
  module Cloud
    module Dlp
      module V2
        # The DLP API is a service that allows clients
        # to detect the presence of Personally Identifiable Information (PII) and other
        # privacy-sensitive data in user-supplied, unstructured data streams, like text
        # blocks or images.
        # The service also includes methods for sensitive data redaction and
        # scheduling of data scans on Google Cloud Platform based data sets.
        #
        # @!attribute [r] dlp_service_stub
        #   @return [Google::Privacy::Dlp::V2::DlpService::Stub]
        class DlpServiceClient
          attr_reader :dlp_service_stub

          # The default address of the service.
          SERVICE_ADDRESS = "dlp.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          DEFAULT_TIMEOUT = 30

          PAGE_DESCRIPTORS = {
            "list_inspect_templates" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "inspect_templates"),
            "list_deidentify_templates" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "deidentify_templates"),
            "list_dlp_jobs" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "jobs"),
            "list_job_triggers" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "job_triggers")
          }.freeze

          private_constant :PAGE_DESCRIPTORS

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform"
          ].freeze


          ORGANIZATION_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "organizations/{organization}"
          )

          private_constant :ORGANIZATION_PATH_TEMPLATE

          ORGANIZATION_DEIDENTIFY_TEMPLATE_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "organizations/{organization}/deidentifyTemplates/{deidentify_template}"
          )

          private_constant :ORGANIZATION_DEIDENTIFY_TEMPLATE_PATH_TEMPLATE

          PROJECT_DEIDENTIFY_TEMPLATE_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/deidentifyTemplates/{deidentify_template}"
          )

          private_constant :PROJECT_DEIDENTIFY_TEMPLATE_PATH_TEMPLATE

          ORGANIZATION_INSPECT_TEMPLATE_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "organizations/{organization}/inspectTemplates/{inspect_template}"
          )

          private_constant :ORGANIZATION_INSPECT_TEMPLATE_PATH_TEMPLATE

          PROJECT_INSPECT_TEMPLATE_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/inspectTemplates/{inspect_template}"
          )

          private_constant :PROJECT_INSPECT_TEMPLATE_PATH_TEMPLATE

          PROJECT_JOB_TRIGGER_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/jobTriggers/{job_trigger}"
          )

          private_constant :PROJECT_JOB_TRIGGER_PATH_TEMPLATE

          PROJECT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}"
          )

          private_constant :PROJECT_PATH_TEMPLATE

          DLP_JOB_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/dlpJobs/{dlp_job}"
          )

          private_constant :DLP_JOB_PATH_TEMPLATE

          # Returns a fully-qualified organization resource name string.
          # @param organization [String]
          # @return [String]
          def self.organization_path organization
            ORGANIZATION_PATH_TEMPLATE.render(
              :"organization" => organization
            )
          end

          # Returns a fully-qualified organization_deidentify_template resource name string.
          # @param organization [String]
          # @param deidentify_template [String]
          # @return [String]
          def self.organization_deidentify_template_path organization, deidentify_template
            ORGANIZATION_DEIDENTIFY_TEMPLATE_PATH_TEMPLATE.render(
              :"organization" => organization,
              :"deidentify_template" => deidentify_template
            )
          end

          # Returns a fully-qualified project_deidentify_template resource name string.
          # @param project [String]
          # @param deidentify_template [String]
          # @return [String]
          def self.project_deidentify_template_path project, deidentify_template
            PROJECT_DEIDENTIFY_TEMPLATE_PATH_TEMPLATE.render(
              :"project" => project,
              :"deidentify_template" => deidentify_template
            )
          end

          # Returns a fully-qualified organization_inspect_template resource name string.
          # @param organization [String]
          # @param inspect_template [String]
          # @return [String]
          def self.organization_inspect_template_path organization, inspect_template
            ORGANIZATION_INSPECT_TEMPLATE_PATH_TEMPLATE.render(
              :"organization" => organization,
              :"inspect_template" => inspect_template
            )
          end

          # Returns a fully-qualified project_inspect_template resource name string.
          # @param project [String]
          # @param inspect_template [String]
          # @return [String]
          def self.project_inspect_template_path project, inspect_template
            PROJECT_INSPECT_TEMPLATE_PATH_TEMPLATE.render(
              :"project" => project,
              :"inspect_template" => inspect_template
            )
          end

          # Returns a fully-qualified project_job_trigger resource name string.
          # @param project [String]
          # @param job_trigger [String]
          # @return [String]
          def self.project_job_trigger_path project, job_trigger
            PROJECT_JOB_TRIGGER_PATH_TEMPLATE.render(
              :"project" => project,
              :"job_trigger" => job_trigger
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

          # Returns a fully-qualified dlp_job resource name string.
          # @param project [String]
          # @param dlp_job [String]
          # @return [String]
          def self.dlp_job_path project, dlp_job
            DLP_JOB_PATH_TEMPLATE.render(
              :"project" => project,
              :"dlp_job" => dlp_job
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
          def initialize \
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
            require "google/privacy/dlp/v2/dlp_services_pb"

            credentials ||= Google::Cloud::Dlp::Credentials.default

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Dlp::Credentials.new(credentials).updater_proc
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

            package_version = Gem.loaded_specs['google-cloud-dlp'].version.version

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/#{package_version} gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            client_config_file = Pathname.new(__dir__).join(
              "dlp_service_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.privacy.dlp.v2.DlpService",
                JSON.parse(f.read),
                client_config,
                Google::Gax::Grpc::STATUS_CODE_NAMES,
                timeout,
                page_descriptors: PAGE_DESCRIPTORS,
                errors: Google::Gax::Grpc::API_ERRORS,
                kwargs: headers
              )
            end

            # Allow overriding the service path/port in subclasses.
            service_path = self.class::SERVICE_ADDRESS
            port = self.class::DEFAULT_SERVICE_PORT
            @dlp_service_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              &Google::Privacy::Dlp::V2::DlpService::Stub.method(:new)
            )

            @inspect_content = Google::Gax.create_api_call(
              @dlp_service_stub.method(:inspect_content),
              defaults["inspect_content"]
            )
            @redact_image = Google::Gax.create_api_call(
              @dlp_service_stub.method(:redact_image),
              defaults["redact_image"]
            )
            @deidentify_content = Google::Gax.create_api_call(
              @dlp_service_stub.method(:deidentify_content),
              defaults["deidentify_content"]
            )
            @reidentify_content = Google::Gax.create_api_call(
              @dlp_service_stub.method(:reidentify_content),
              defaults["reidentify_content"]
            )
            @list_info_types = Google::Gax.create_api_call(
              @dlp_service_stub.method(:list_info_types),
              defaults["list_info_types"]
            )
            @create_inspect_template = Google::Gax.create_api_call(
              @dlp_service_stub.method(:create_inspect_template),
              defaults["create_inspect_template"]
            )
            @update_inspect_template = Google::Gax.create_api_call(
              @dlp_service_stub.method(:update_inspect_template),
              defaults["update_inspect_template"]
            )
            @get_inspect_template = Google::Gax.create_api_call(
              @dlp_service_stub.method(:get_inspect_template),
              defaults["get_inspect_template"]
            )
            @list_inspect_templates = Google::Gax.create_api_call(
              @dlp_service_stub.method(:list_inspect_templates),
              defaults["list_inspect_templates"]
            )
            @delete_inspect_template = Google::Gax.create_api_call(
              @dlp_service_stub.method(:delete_inspect_template),
              defaults["delete_inspect_template"]
            )
            @create_deidentify_template = Google::Gax.create_api_call(
              @dlp_service_stub.method(:create_deidentify_template),
              defaults["create_deidentify_template"]
            )
            @update_deidentify_template = Google::Gax.create_api_call(
              @dlp_service_stub.method(:update_deidentify_template),
              defaults["update_deidentify_template"]
            )
            @get_deidentify_template = Google::Gax.create_api_call(
              @dlp_service_stub.method(:get_deidentify_template),
              defaults["get_deidentify_template"]
            )
            @list_deidentify_templates = Google::Gax.create_api_call(
              @dlp_service_stub.method(:list_deidentify_templates),
              defaults["list_deidentify_templates"]
            )
            @delete_deidentify_template = Google::Gax.create_api_call(
              @dlp_service_stub.method(:delete_deidentify_template),
              defaults["delete_deidentify_template"]
            )
            @create_dlp_job = Google::Gax.create_api_call(
              @dlp_service_stub.method(:create_dlp_job),
              defaults["create_dlp_job"]
            )
            @list_dlp_jobs = Google::Gax.create_api_call(
              @dlp_service_stub.method(:list_dlp_jobs),
              defaults["list_dlp_jobs"]
            )
            @get_dlp_job = Google::Gax.create_api_call(
              @dlp_service_stub.method(:get_dlp_job),
              defaults["get_dlp_job"]
            )
            @delete_dlp_job = Google::Gax.create_api_call(
              @dlp_service_stub.method(:delete_dlp_job),
              defaults["delete_dlp_job"]
            )
            @cancel_dlp_job = Google::Gax.create_api_call(
              @dlp_service_stub.method(:cancel_dlp_job),
              defaults["cancel_dlp_job"]
            )
            @list_job_triggers = Google::Gax.create_api_call(
              @dlp_service_stub.method(:list_job_triggers),
              defaults["list_job_triggers"]
            )
            @get_job_trigger = Google::Gax.create_api_call(
              @dlp_service_stub.method(:get_job_trigger),
              defaults["get_job_trigger"]
            )
            @delete_job_trigger = Google::Gax.create_api_call(
              @dlp_service_stub.method(:delete_job_trigger),
              defaults["delete_job_trigger"]
            )
            @update_job_trigger = Google::Gax.create_api_call(
              @dlp_service_stub.method(:update_job_trigger),
              defaults["update_job_trigger"]
            )
            @create_job_trigger = Google::Gax.create_api_call(
              @dlp_service_stub.method(:create_job_trigger),
              defaults["create_job_trigger"]
            )
          end

          # Service calls

          # Finds potentially sensitive info in content.
          # This method has limits on input size, processing time, and output size.
          # [How-to guide for text](https://cloud.google.com/dlp/docs/inspecting-text), [How-to guide for
          # images](/dlp/docs/inspecting-images)
          #
          # @param parent [String]
          #   The parent resource name, for example projects/my-project-id.
          # @param inspect_config [Google::Privacy::Dlp::V2::InspectConfig | Hash]
          #   Configuration for the inspector. What specified here will override
          #   the template referenced by the inspect_template_name argument.
          #   A hash of the same form as `Google::Privacy::Dlp::V2::InspectConfig`
          #   can also be provided.
          # @param item [Google::Privacy::Dlp::V2::ContentItem | Hash]
          #   The item to inspect.
          #   A hash of the same form as `Google::Privacy::Dlp::V2::ContentItem`
          #   can also be provided.
          # @param inspect_template_name [String]
          #   Optional template to use. Any configuration directly specified in
          #   inspect_config will override those set in the template. Singular fields
          #   that are set in this request will replace their corresponding fields in the
          #   template. Repeated fields are appended. Singular sub-messages and groups
          #   are recursively merged.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Privacy::Dlp::V2::InspectContentResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dlp/v2"
          #
          #   dlp_service_client = Google::Cloud::Dlp::V2.new
          #   formatted_parent = Google::Cloud::Dlp::V2::DlpServiceClient.project_path("[PROJECT]")
          #   response = dlp_service_client.inspect_content(formatted_parent)

          def inspect_content \
              parent,
              inspect_config: nil,
              item: nil,
              inspect_template_name: nil,
              options: nil
            req = {
              parent: parent,
              inspect_config: inspect_config,
              item: item,
              inspect_template_name: inspect_template_name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Privacy::Dlp::V2::InspectContentRequest)
            @inspect_content.call(req, options)
          end

          # Redacts potentially sensitive info from an image.
          # This method has limits on input size, processing time, and output size.
          # [How-to guide](https://cloud.google.com/dlp/docs/redacting-sensitive-data-images)
          #
          # @param parent [String]
          #   The parent resource name, for example projects/my-project-id.
          # @param inspect_config [Google::Privacy::Dlp::V2::InspectConfig | Hash]
          #   Configuration for the inspector.
          #   A hash of the same form as `Google::Privacy::Dlp::V2::InspectConfig`
          #   can also be provided.
          # @param image_redaction_configs [Array<Google::Privacy::Dlp::V2::RedactImageRequest::ImageRedactionConfig | Hash>]
          #   The configuration for specifying what content to redact from images.
          #   A hash of the same form as `Google::Privacy::Dlp::V2::RedactImageRequest::ImageRedactionConfig`
          #   can also be provided.
          # @param byte_item [Google::Privacy::Dlp::V2::ByteContentItem | Hash]
          #   The content must be PNG, JPEG, SVG or BMP.
          #   A hash of the same form as `Google::Privacy::Dlp::V2::ByteContentItem`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Privacy::Dlp::V2::RedactImageResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dlp/v2"
          #
          #   dlp_service_client = Google::Cloud::Dlp::V2.new
          #   formatted_parent = Google::Cloud::Dlp::V2::DlpServiceClient.project_path("[PROJECT]")
          #   response = dlp_service_client.redact_image(formatted_parent)

          def redact_image \
              parent,
              inspect_config: nil,
              image_redaction_configs: nil,
              byte_item: nil,
              options: nil
            req = {
              parent: parent,
              inspect_config: inspect_config,
              image_redaction_configs: image_redaction_configs,
              byte_item: byte_item
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Privacy::Dlp::V2::RedactImageRequest)
            @redact_image.call(req, options)
          end

          # De-identifies potentially sensitive info from a ContentItem.
          # This method has limits on input size and output size.
          # [How-to guide](https://cloud.google.com/dlp/docs/deidentify-sensitive-data)
          #
          # @param parent [String]
          #   The parent resource name, for example projects/my-project-id.
          # @param deidentify_config [Google::Privacy::Dlp::V2::DeidentifyConfig | Hash]
          #   Configuration for the de-identification of the content item.
          #   Items specified here will override the template referenced by the
          #   deidentify_template_name argument.
          #   A hash of the same form as `Google::Privacy::Dlp::V2::DeidentifyConfig`
          #   can also be provided.
          # @param inspect_config [Google::Privacy::Dlp::V2::InspectConfig | Hash]
          #   Configuration for the inspector.
          #   Items specified here will override the template referenced by the
          #   inspect_template_name argument.
          #   A hash of the same form as `Google::Privacy::Dlp::V2::InspectConfig`
          #   can also be provided.
          # @param item [Google::Privacy::Dlp::V2::ContentItem | Hash]
          #   The item to de-identify. Will be treated as text.
          #   A hash of the same form as `Google::Privacy::Dlp::V2::ContentItem`
          #   can also be provided.
          # @param inspect_template_name [String]
          #   Optional template to use. Any configuration directly specified in
          #   inspect_config will override those set in the template. Singular fields
          #   that are set in this request will replace their corresponding fields in the
          #   template. Repeated fields are appended. Singular sub-messages and groups
          #   are recursively merged.
          # @param deidentify_template_name [String]
          #   Optional template to use. Any configuration directly specified in
          #   deidentify_config will override those set in the template. Singular fields
          #   that are set in this request will replace their corresponding fields in the
          #   template. Repeated fields are appended. Singular sub-messages and groups
          #   are recursively merged.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Privacy::Dlp::V2::DeidentifyContentResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dlp/v2"
          #
          #   dlp_service_client = Google::Cloud::Dlp::V2.new
          #   formatted_parent = Google::Cloud::Dlp::V2::DlpServiceClient.project_path("[PROJECT]")
          #   response = dlp_service_client.deidentify_content(formatted_parent)

          def deidentify_content \
              parent,
              deidentify_config: nil,
              inspect_config: nil,
              item: nil,
              inspect_template_name: nil,
              deidentify_template_name: nil,
              options: nil
            req = {
              parent: parent,
              deidentify_config: deidentify_config,
              inspect_config: inspect_config,
              item: item,
              inspect_template_name: inspect_template_name,
              deidentify_template_name: deidentify_template_name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Privacy::Dlp::V2::DeidentifyContentRequest)
            @deidentify_content.call(req, options)
          end

          # Re-identify content that has been de-identified.
          #
          # @param parent [String]
          #   The parent resource name.
          # @param reidentify_config [Google::Privacy::Dlp::V2::DeidentifyConfig | Hash]
          #   Configuration for the re-identification of the content item.
          #   This field shares the same proto message type that is used for
          #   de-identification, however its usage here is for the reversal of the
          #   previous de-identification. Re-identification is performed by examining
          #   the transformations used to de-identify the items and executing the
          #   reverse. This requires that only reversible transformations
          #   be provided here. The reversible transformations are:
          #
          #   * +CryptoReplaceFfxFpeConfig+
          #   A hash of the same form as `Google::Privacy::Dlp::V2::DeidentifyConfig`
          #   can also be provided.
          # @param inspect_config [Google::Privacy::Dlp::V2::InspectConfig | Hash]
          #   Configuration for the inspector.
          #   A hash of the same form as `Google::Privacy::Dlp::V2::InspectConfig`
          #   can also be provided.
          # @param item [Google::Privacy::Dlp::V2::ContentItem | Hash]
          #   The item to re-identify. Will be treated as text.
          #   A hash of the same form as `Google::Privacy::Dlp::V2::ContentItem`
          #   can also be provided.
          # @param inspect_template_name [String]
          #   Optional template to use. Any configuration directly specified in
          #   +inspect_config+ will override those set in the template. Singular fields
          #   that are set in this request will replace their corresponding fields in the
          #   template. Repeated fields are appended. Singular sub-messages and groups
          #   are recursively merged.
          # @param reidentify_template_name [String]
          #   Optional template to use. References an instance of +DeidentifyTemplate+.
          #   Any configuration directly specified in +reidentify_config+ or
          #   +inspect_config+ will override those set in the template. Singular fields
          #   that are set in this request will replace their corresponding fields in the
          #   template. Repeated fields are appended. Singular sub-messages and groups
          #   are recursively merged.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Privacy::Dlp::V2::ReidentifyContentResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dlp/v2"
          #
          #   dlp_service_client = Google::Cloud::Dlp::V2.new
          #   formatted_parent = Google::Cloud::Dlp::V2::DlpServiceClient.project_path("[PROJECT]")
          #   response = dlp_service_client.reidentify_content(formatted_parent)

          def reidentify_content \
              parent,
              reidentify_config: nil,
              inspect_config: nil,
              item: nil,
              inspect_template_name: nil,
              reidentify_template_name: nil,
              options: nil
            req = {
              parent: parent,
              reidentify_config: reidentify_config,
              inspect_config: inspect_config,
              item: item,
              inspect_template_name: inspect_template_name,
              reidentify_template_name: reidentify_template_name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Privacy::Dlp::V2::ReidentifyContentRequest)
            @reidentify_content.call(req, options)
          end

          # Returns sensitive information types DLP supports.
          #
          # @param language_code [String]
          #   Optional BCP-47 language code for localized infoType friendly
          #   names. If omitted, or if localized strings are not available,
          #   en-US strings will be returned.
          # @param filter [String]
          #   Optional filter to only return infoTypes supported by certain parts of the
          #   API. Defaults to supported_by=INSPECT.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Privacy::Dlp::V2::ListInfoTypesResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dlp/v2"
          #
          #   dlp_service_client = Google::Cloud::Dlp::V2.new
          #   response = dlp_service_client.list_info_types

          def list_info_types \
              language_code: nil,
              filter: nil,
              options: nil
            req = {
              language_code: language_code,
              filter: filter
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Privacy::Dlp::V2::ListInfoTypesRequest)
            @list_info_types.call(req, options)
          end

          # Creates an inspect template for re-using frequently used configuration
          # for inspecting content, images, and storage.
          #
          # @param parent [String]
          #   The parent resource name, for example projects/my-project-id or
          #   organizations/my-org-id.
          # @param inspect_template [Google::Privacy::Dlp::V2::InspectTemplate | Hash]
          #   The InspectTemplate to create.
          #   A hash of the same form as `Google::Privacy::Dlp::V2::InspectTemplate`
          #   can also be provided.
          # @param template_id [String]
          #   The template id can contain uppercase and lowercase letters,
          #   numbers, and hyphens; that is, it must match the regular
          #   expression: +[a-zA-Z\\d-]++. The maximum length is 100
          #   characters. Can be empty to allow the system to generate one.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Privacy::Dlp::V2::InspectTemplate]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dlp/v2"
          #
          #   dlp_service_client = Google::Cloud::Dlp::V2.new
          #   formatted_parent = Google::Cloud::Dlp::V2::DlpServiceClient.organization_path("[ORGANIZATION]")
          #   response = dlp_service_client.create_inspect_template(formatted_parent)

          def create_inspect_template \
              parent,
              inspect_template: nil,
              template_id: nil,
              options: nil
            req = {
              parent: parent,
              inspect_template: inspect_template,
              template_id: template_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Privacy::Dlp::V2::CreateInspectTemplateRequest)
            @create_inspect_template.call(req, options)
          end

          # Updates the inspect template.
          #
          # @param name [String]
          #   Resource name of organization and inspectTemplate to be updated, for
          #   example +organizations/433245324/inspectTemplates/432452342+ or
          #   projects/project-id/inspectTemplates/432452342.
          # @param inspect_template [Google::Privacy::Dlp::V2::InspectTemplate | Hash]
          #   New InspectTemplate value.
          #   A hash of the same form as `Google::Privacy::Dlp::V2::InspectTemplate`
          #   can also be provided.
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   Mask to control which fields get updated.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Privacy::Dlp::V2::InspectTemplate]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dlp/v2"
          #
          #   dlp_service_client = Google::Cloud::Dlp::V2.new
          #   formatted_name = Google::Cloud::Dlp::V2::DlpServiceClient.organization_inspect_template_path("[ORGANIZATION]", "[INSPECT_TEMPLATE]")
          #   response = dlp_service_client.update_inspect_template(formatted_name)

          def update_inspect_template \
              name,
              inspect_template: nil,
              update_mask: nil,
              options: nil
            req = {
              name: name,
              inspect_template: inspect_template,
              update_mask: update_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Privacy::Dlp::V2::UpdateInspectTemplateRequest)
            @update_inspect_template.call(req, options)
          end

          # Gets an inspect template.
          #
          # @param name [String]
          #   Resource name of the organization and inspectTemplate to be read, for
          #   example +organizations/433245324/inspectTemplates/432452342+ or
          #   projects/project-id/inspectTemplates/432452342.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Privacy::Dlp::V2::InspectTemplate]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dlp/v2"
          #
          #   dlp_service_client = Google::Cloud::Dlp::V2.new
          #   response = dlp_service_client.get_inspect_template

          def get_inspect_template \
              name: nil,
              options: nil
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Privacy::Dlp::V2::GetInspectTemplateRequest)
            @get_inspect_template.call(req, options)
          end

          # Lists inspect templates.
          #
          # @param parent [String]
          #   The parent resource name, for example projects/my-project-id or
          #   organizations/my-org-id.
          # @param page_size [Integer]
          #   The maximum number of resources contained in the underlying API
          #   response. If page streaming is performed per-resource, this
          #   parameter does not affect the return value. If page streaming is
          #   performed per-page, this determines the maximum number of
          #   resources in a page.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::PagedEnumerable<Google::Privacy::Dlp::V2::InspectTemplate>]
          #   An enumerable of Google::Privacy::Dlp::V2::InspectTemplate instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dlp/v2"
          #
          #   dlp_service_client = Google::Cloud::Dlp::V2.new
          #   formatted_parent = Google::Cloud::Dlp::V2::DlpServiceClient.organization_path("[ORGANIZATION]")
          #
          #   # Iterate over all results.
          #   dlp_service_client.list_inspect_templates(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   dlp_service_client.list_inspect_templates(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_inspect_templates \
              parent,
              page_size: nil,
              options: nil
            req = {
              parent: parent,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Privacy::Dlp::V2::ListInspectTemplatesRequest)
            @list_inspect_templates.call(req, options)
          end

          # Deletes inspect templates.
          #
          # @param name [String]
          #   Resource name of the organization and inspectTemplate to be deleted, for
          #   example +organizations/433245324/inspectTemplates/432452342+ or
          #   projects/project-id/inspectTemplates/432452342.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dlp/v2"
          #
          #   dlp_service_client = Google::Cloud::Dlp::V2.new
          #   formatted_name = Google::Cloud::Dlp::V2::DlpServiceClient.organization_inspect_template_path("[ORGANIZATION]", "[INSPECT_TEMPLATE]")
          #   dlp_service_client.delete_inspect_template(formatted_name)

          def delete_inspect_template \
              name,
              options: nil
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Privacy::Dlp::V2::DeleteInspectTemplateRequest)
            @delete_inspect_template.call(req, options)
            nil
          end

          # Creates an Deidentify template for re-using frequently used configuration
          # for Deidentifying content, images, and storage.
          #
          # @param parent [String]
          #   The parent resource name, for example projects/my-project-id or
          #   organizations/my-org-id.
          # @param deidentify_template [Google::Privacy::Dlp::V2::DeidentifyTemplate | Hash]
          #   The DeidentifyTemplate to create.
          #   A hash of the same form as `Google::Privacy::Dlp::V2::DeidentifyTemplate`
          #   can also be provided.
          # @param template_id [String]
          #   The template id can contain uppercase and lowercase letters,
          #   numbers, and hyphens; that is, it must match the regular
          #   expression: +[a-zA-Z\\d-]++. The maximum length is 100
          #   characters. Can be empty to allow the system to generate one.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Privacy::Dlp::V2::DeidentifyTemplate]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dlp/v2"
          #
          #   dlp_service_client = Google::Cloud::Dlp::V2.new
          #   formatted_parent = Google::Cloud::Dlp::V2::DlpServiceClient.organization_path("[ORGANIZATION]")
          #   response = dlp_service_client.create_deidentify_template(formatted_parent)

          def create_deidentify_template \
              parent,
              deidentify_template: nil,
              template_id: nil,
              options: nil
            req = {
              parent: parent,
              deidentify_template: deidentify_template,
              template_id: template_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Privacy::Dlp::V2::CreateDeidentifyTemplateRequest)
            @create_deidentify_template.call(req, options)
          end

          # Updates the inspect template.
          #
          # @param name [String]
          #   Resource name of organization and deidentify template to be updated, for
          #   example +organizations/433245324/deidentifyTemplates/432452342+ or
          #   projects/project-id/deidentifyTemplates/432452342.
          # @param deidentify_template [Google::Privacy::Dlp::V2::DeidentifyTemplate | Hash]
          #   New DeidentifyTemplate value.
          #   A hash of the same form as `Google::Privacy::Dlp::V2::DeidentifyTemplate`
          #   can also be provided.
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   Mask to control which fields get updated.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Privacy::Dlp::V2::DeidentifyTemplate]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dlp/v2"
          #
          #   dlp_service_client = Google::Cloud::Dlp::V2.new
          #   formatted_name = Google::Cloud::Dlp::V2::DlpServiceClient.organization_deidentify_template_path("[ORGANIZATION]", "[DEIDENTIFY_TEMPLATE]")
          #   response = dlp_service_client.update_deidentify_template(formatted_name)

          def update_deidentify_template \
              name,
              deidentify_template: nil,
              update_mask: nil,
              options: nil
            req = {
              name: name,
              deidentify_template: deidentify_template,
              update_mask: update_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Privacy::Dlp::V2::UpdateDeidentifyTemplateRequest)
            @update_deidentify_template.call(req, options)
          end

          # Gets an inspect template.
          #
          # @param name [String]
          #   Resource name of the organization and deidentify template to be read, for
          #   example +organizations/433245324/deidentifyTemplates/432452342+ or
          #   projects/project-id/deidentifyTemplates/432452342.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Privacy::Dlp::V2::DeidentifyTemplate]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dlp/v2"
          #
          #   dlp_service_client = Google::Cloud::Dlp::V2.new
          #   formatted_name = Google::Cloud::Dlp::V2::DlpServiceClient.organization_deidentify_template_path("[ORGANIZATION]", "[DEIDENTIFY_TEMPLATE]")
          #   response = dlp_service_client.get_deidentify_template(formatted_name)

          def get_deidentify_template \
              name,
              options: nil
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Privacy::Dlp::V2::GetDeidentifyTemplateRequest)
            @get_deidentify_template.call(req, options)
          end

          # Lists inspect templates.
          #
          # @param parent [String]
          #   The parent resource name, for example projects/my-project-id or
          #   organizations/my-org-id.
          # @param page_size [Integer]
          #   The maximum number of resources contained in the underlying API
          #   response. If page streaming is performed per-resource, this
          #   parameter does not affect the return value. If page streaming is
          #   performed per-page, this determines the maximum number of
          #   resources in a page.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::PagedEnumerable<Google::Privacy::Dlp::V2::DeidentifyTemplate>]
          #   An enumerable of Google::Privacy::Dlp::V2::DeidentifyTemplate instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dlp/v2"
          #
          #   dlp_service_client = Google::Cloud::Dlp::V2.new
          #   formatted_parent = Google::Cloud::Dlp::V2::DlpServiceClient.organization_path("[ORGANIZATION]")
          #
          #   # Iterate over all results.
          #   dlp_service_client.list_deidentify_templates(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   dlp_service_client.list_deidentify_templates(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_deidentify_templates \
              parent,
              page_size: nil,
              options: nil
            req = {
              parent: parent,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Privacy::Dlp::V2::ListDeidentifyTemplatesRequest)
            @list_deidentify_templates.call(req, options)
          end

          # Deletes inspect templates.
          #
          # @param name [String]
          #   Resource name of the organization and deidentify template to be deleted,
          #   for example +organizations/433245324/deidentifyTemplates/432452342+ or
          #   projects/project-id/deidentifyTemplates/432452342.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dlp/v2"
          #
          #   dlp_service_client = Google::Cloud::Dlp::V2.new
          #   formatted_name = Google::Cloud::Dlp::V2::DlpServiceClient.organization_deidentify_template_path("[ORGANIZATION]", "[DEIDENTIFY_TEMPLATE]")
          #   dlp_service_client.delete_deidentify_template(formatted_name)

          def delete_deidentify_template \
              name,
              options: nil
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Privacy::Dlp::V2::DeleteDeidentifyTemplateRequest)
            @delete_deidentify_template.call(req, options)
            nil
          end

          # Create a new job to inspect storage or calculate risk metrics [How-to
          # guide](/dlp/docs/compute-risk-analysis).
          #
          # @param parent [String]
          #   The parent resource name, for example projects/my-project-id.
          # @param inspect_job [Google::Privacy::Dlp::V2::InspectJobConfig | Hash]
          #   A hash of the same form as `Google::Privacy::Dlp::V2::InspectJobConfig`
          #   can also be provided.
          # @param risk_job [Google::Privacy::Dlp::V2::RiskAnalysisJobConfig | Hash]
          #   A hash of the same form as `Google::Privacy::Dlp::V2::RiskAnalysisJobConfig`
          #   can also be provided.
          # @param job_id [String]
          #   The job id can contain uppercase and lowercase letters,
          #   numbers, and hyphens; that is, it must match the regular
          #   expression: +[a-zA-Z\\d-]++. The maximum length is 100
          #   characters. Can be empty to allow the system to generate one.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Privacy::Dlp::V2::DlpJob]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dlp/v2"
          #
          #   dlp_service_client = Google::Cloud::Dlp::V2.new
          #   formatted_parent = Google::Cloud::Dlp::V2::DlpServiceClient.project_path("[PROJECT]")
          #   response = dlp_service_client.create_dlp_job(formatted_parent)

          def create_dlp_job \
              parent,
              inspect_job: nil,
              risk_job: nil,
              job_id: nil,
              options: nil
            req = {
              parent: parent,
              inspect_job: inspect_job,
              risk_job: risk_job,
              job_id: job_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Privacy::Dlp::V2::CreateDlpJobRequest)
            @create_dlp_job.call(req, options)
          end

          # Lists DlpJobs that match the specified filter in the request.
          #
          # @param parent [String]
          #   The parent resource name, for example projects/my-project-id.
          # @param filter [String]
          #   Optional. Allows filtering.
          #
          #   Supported syntax:
          #
          #   * Filter expressions are made up of one or more restrictions.
          #   * Restrictions can be combined by +AND+ or +OR+ logical operators. A
          #     sequence of restrictions implicitly uses +AND+.
          #   * A restriction has the form of +<field> <operator> <value>+.
          #   * Supported fields/values for inspect jobs:
          #     * +state+ - PENDING|RUNNING|CANCELED|FINISHED|FAILED
          #       * +inspected_storage+ - DATASTORE|CLOUD_STORAGE|BIGQUERY
          #       * +trigger_name+ - The resource name of the trigger that created job.
          #     * Supported fields for risk analysis jobs:
          #       * +state+ - RUNNING|CANCELED|FINISHED|FAILED
          #     * The operator must be +=+ or +!=+.
          #
          #     Examples:
          #
          #   * inspected_storage = cloud_storage AND state = done
          #   * inspected_storage = cloud_storage OR inspected_storage = bigquery
          #   * inspected_storage = cloud_storage AND (state = done OR state = canceled)
          #
          #   The length of this field should be no more than 500 characters.
          # @param page_size [Integer]
          #   The maximum number of resources contained in the underlying API
          #   response. If page streaming is performed per-resource, this
          #   parameter does not affect the return value. If page streaming is
          #   performed per-page, this determines the maximum number of
          #   resources in a page.
          # @param type [Google::Privacy::Dlp::V2::DlpJobType]
          #   The type of job. Defaults to +DlpJobType.INSPECT+
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::PagedEnumerable<Google::Privacy::Dlp::V2::DlpJob>]
          #   An enumerable of Google::Privacy::Dlp::V2::DlpJob instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dlp/v2"
          #
          #   dlp_service_client = Google::Cloud::Dlp::V2.new
          #   formatted_parent = Google::Cloud::Dlp::V2::DlpServiceClient.project_path("[PROJECT]")
          #
          #   # Iterate over all results.
          #   dlp_service_client.list_dlp_jobs(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   dlp_service_client.list_dlp_jobs(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_dlp_jobs \
              parent,
              filter: nil,
              page_size: nil,
              type: nil,
              options: nil
            req = {
              parent: parent,
              filter: filter,
              page_size: page_size,
              type: type
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Privacy::Dlp::V2::ListDlpJobsRequest)
            @list_dlp_jobs.call(req, options)
          end

          # Gets the latest state of a long-running DlpJob.
          #
          # @param name [String]
          #   The name of the DlpJob resource.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Privacy::Dlp::V2::DlpJob]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dlp/v2"
          #
          #   dlp_service_client = Google::Cloud::Dlp::V2.new
          #   formatted_name = Google::Cloud::Dlp::V2::DlpServiceClient.dlp_job_path("[PROJECT]", "[DLP_JOB]")
          #   response = dlp_service_client.get_dlp_job(formatted_name)

          def get_dlp_job \
              name,
              options: nil
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Privacy::Dlp::V2::GetDlpJobRequest)
            @get_dlp_job.call(req, options)
          end

          # Deletes a long-running DlpJob. This method indicates that the client is
          # no longer interested in the DlpJob result. The job will be cancelled if
          # possible.
          #
          # @param name [String]
          #   The name of the DlpJob resource to be deleted.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dlp/v2"
          #
          #   dlp_service_client = Google::Cloud::Dlp::V2.new
          #   formatted_name = Google::Cloud::Dlp::V2::DlpServiceClient.dlp_job_path("[PROJECT]", "[DLP_JOB]")
          #   dlp_service_client.delete_dlp_job(formatted_name)

          def delete_dlp_job \
              name,
              options: nil
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Privacy::Dlp::V2::DeleteDlpJobRequest)
            @delete_dlp_job.call(req, options)
            nil
          end

          # Starts asynchronous cancellation on a long-running DlpJob.  The server
          # makes a best effort to cancel the DlpJob, but success is not
          # guaranteed.
          #
          # @param name [String]
          #   The name of the DlpJob resource to be cancelled.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dlp/v2"
          #
          #   dlp_service_client = Google::Cloud::Dlp::V2.new
          #   formatted_name = Google::Cloud::Dlp::V2::DlpServiceClient.dlp_job_path("[PROJECT]", "[DLP_JOB]")
          #   dlp_service_client.cancel_dlp_job(formatted_name)

          def cancel_dlp_job \
              name,
              options: nil
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Privacy::Dlp::V2::CancelDlpJobRequest)
            @cancel_dlp_job.call(req, options)
            nil
          end

          # Lists job triggers.
          #
          # @param parent [String]
          #   The parent resource name, for example projects/my-project-id.
          # @param page_size [Integer]
          #   The maximum number of resources contained in the underlying API
          #   response. If page streaming is performed per-resource, this
          #   parameter does not affect the return value. If page streaming is
          #   performed per-page, this determines the maximum number of
          #   resources in a page.
          # @param order_by [String]
          #   Optional comma separated list of triggeredJob fields to order by,
          #   followed by 'asc/desc' postfix, i.e.
          #   +"create_time asc,name desc,schedule_mode asc"+. This list is
          #   case-insensitive.
          #
          #   Example: +"name asc,schedule_mode desc, status desc"+
          #
          #   Supported filters keys and values are:
          #
          #   * +create_time+: corresponds to time the triggeredJob was created.
          #   * +update_time+: corresponds to time the triggeredJob was last updated.
          #   * +name+: corresponds to JobTrigger's display name.
          #   * +status+: corresponds to the triggeredJob status.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::PagedEnumerable<Google::Privacy::Dlp::V2::JobTrigger>]
          #   An enumerable of Google::Privacy::Dlp::V2::JobTrigger instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dlp/v2"
          #
          #   dlp_service_client = Google::Cloud::Dlp::V2.new
          #   formatted_parent = Google::Cloud::Dlp::V2::DlpServiceClient.project_path("[PROJECT]")
          #
          #   # Iterate over all results.
          #   dlp_service_client.list_job_triggers(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   dlp_service_client.list_job_triggers(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_job_triggers \
              parent,
              page_size: nil,
              order_by: nil,
              options: nil
            req = {
              parent: parent,
              page_size: page_size,
              order_by: order_by
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Privacy::Dlp::V2::ListJobTriggersRequest)
            @list_job_triggers.call(req, options)
          end

          # Gets a job trigger.
          #
          # @param name [String]
          #   Resource name of the project and the triggeredJob, for example
          #   +projects/dlp-test-project/jobTriggers/53234423+.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Privacy::Dlp::V2::JobTrigger]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dlp/v2"
          #
          #   dlp_service_client = Google::Cloud::Dlp::V2.new
          #   formatted_name = Google::Cloud::Dlp::V2::DlpServiceClient.project_job_trigger_path("[PROJECT]", "[JOB_TRIGGER]")
          #   response = dlp_service_client.get_job_trigger(formatted_name)

          def get_job_trigger \
              name,
              options: nil
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Privacy::Dlp::V2::GetJobTriggerRequest)
            @get_job_trigger.call(req, options)
          end

          # Deletes a job trigger.
          #
          # @param name [String]
          #   Resource name of the project and the triggeredJob, for example
          #   +projects/dlp-test-project/jobTriggers/53234423+.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dlp/v2"
          #
          #   dlp_service_client = Google::Cloud::Dlp::V2.new
          #
          #   # TODO: Initialize +name+:
          #   name = ''
          #   dlp_service_client.delete_job_trigger(name)

          def delete_job_trigger \
              name,
              options: nil
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Privacy::Dlp::V2::DeleteJobTriggerRequest)
            @delete_job_trigger.call(req, options)
            nil
          end

          # Updates a job trigger.
          #
          # @param name [String]
          #   Resource name of the project and the triggeredJob, for example
          #   +projects/dlp-test-project/jobTriggers/53234423+.
          # @param job_trigger [Google::Privacy::Dlp::V2::JobTrigger | Hash]
          #   New JobTrigger value.
          #   A hash of the same form as `Google::Privacy::Dlp::V2::JobTrigger`
          #   can also be provided.
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   Mask to control which fields get updated.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Privacy::Dlp::V2::JobTrigger]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dlp/v2"
          #
          #   dlp_service_client = Google::Cloud::Dlp::V2.new
          #   formatted_name = Google::Cloud::Dlp::V2::DlpServiceClient.project_job_trigger_path("[PROJECT]", "[JOB_TRIGGER]")
          #   response = dlp_service_client.update_job_trigger(formatted_name)

          def update_job_trigger \
              name,
              job_trigger: nil,
              update_mask: nil,
              options: nil
            req = {
              name: name,
              job_trigger: job_trigger,
              update_mask: update_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Privacy::Dlp::V2::UpdateJobTriggerRequest)
            @update_job_trigger.call(req, options)
          end

          # Creates a job to run DLP actions such as scanning storage for sensitive
          # information on a set schedule.
          #
          # @param parent [String]
          #   The parent resource name, for example projects/my-project-id.
          # @param job_trigger [Google::Privacy::Dlp::V2::JobTrigger | Hash]
          #   The JobTrigger to create.
          #   A hash of the same form as `Google::Privacy::Dlp::V2::JobTrigger`
          #   can also be provided.
          # @param trigger_id [String]
          #   The trigger id can contain uppercase and lowercase letters,
          #   numbers, and hyphens; that is, it must match the regular
          #   expression: +[a-zA-Z\\d-]++. The maximum length is 100
          #   characters. Can be empty to allow the system to generate one.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Privacy::Dlp::V2::JobTrigger]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dlp/v2"
          #
          #   dlp_service_client = Google::Cloud::Dlp::V2.new
          #   formatted_parent = Google::Cloud::Dlp::V2::DlpServiceClient.project_path("[PROJECT]")
          #   response = dlp_service_client.create_job_trigger(formatted_parent)

          def create_job_trigger \
              parent,
              job_trigger: nil,
              trigger_id: nil,
              options: nil
            req = {
              parent: parent,
              job_trigger: job_trigger,
              trigger_id: trigger_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Privacy::Dlp::V2::CreateJobTriggerRequest)
            @create_job_trigger.call(req, options)
          end
        end
      end
    end
  end
end
