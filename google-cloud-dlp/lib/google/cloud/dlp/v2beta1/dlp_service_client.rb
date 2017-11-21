# Copyright 2017, Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# EDITING INSTRUCTIONS
# This file was generated from the file
# https://github.com/googleapis/googleapis/blob/master/google/privacy/dlp/v2beta1/dlp.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.
#
# The only allowed edits are to method and file documentation. A 3-way
# merge preserves those additions if the generated source changes.

require "json"
require "pathname"

require "google/gax"
require "google/gax/operation"
require "google/longrunning/operations_client"

require "google/privacy/dlp/v2beta1/dlp_pb"
require "google/cloud/dlp/credentials"

module Google
  module Cloud
    module Dlp
      module V2beta1
        # The DLP API is a service that allows clients
        # to detect the presence of Personally Identifiable Information (PII) and other
        # privacy-sensitive data in user-supplied, unstructured data streams, like text
        # blocks or images.
        # The service also includes methods for sensitive data redaction and
        # scheduling of data scans on Google Cloud Platform based data sets.
        #
        # @!attribute [r] dlp_service_stub
        #   @return [Google::Privacy::Dlp::V2beta1::DlpService::Stub]
        class DlpServiceClient
          attr_reader :dlp_service_stub

          # The default address of the service.
          SERVICE_ADDRESS = "dlp.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          DEFAULT_TIMEOUT = 30

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform"
          ].freeze

          RESULT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "inspect/results/{result}"
          )

          private_constant :RESULT_PATH_TEMPLATE

          # Returns a fully-qualified result resource name string.
          # @param result [String]
          # @return [String]
          def self.result_path result
            RESULT_PATH_TEMPLATE.render(
              :"result" => result
            )
          end

          # @param service_path [String]
          #   The domain name of the API remote host.
          # @param port [Integer]
          #   The port on which to connect to the remote host.
          # @param credentials
          #   [Google::Gax::Credentials, String, Hash, GRPC::Core::Channel, GRPC::Core::ChannelCredentials, Proc]
          #   Provides the means for authenticating requests made by the client. This parameter can
          #   be many types.
          #   A `Google::Gax::Credentials` uses a the properties of its represented keyfile for
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
          # @param client_config[Hash]
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
              app_name: nil,
              app_version: nil,
              lib_name: nil,
              lib_version: ""
            # These require statements are intentionally placed here to initialize
            # the gRPC module only when it's required.
            # See https://github.com/googleapis/toolkit/issues/446
            require "google/gax/grpc"
            require "google/privacy/dlp/v2beta1/dlp_services_pb"

            if channel || chan_creds || updater_proc
              warn "The `channel`, `chan_creds`, and `updater_proc` parameters will be removed " \
                "on 2017/09/08"
              credentials ||= channel
              credentials ||= chan_creds
              credentials ||= updater_proc
            end
            if app_name || app_version
              warn "`app_name` and `app_version` are no longer being used in the request headers."
            end

            credentials ||= Google::Cloud::Dlp::Credentials.default

            @operations_client = Google::Longrunning::OperationsClient.new(
              service_path: service_path,
              port: port,
              credentials: credentials,
              scopes: scopes,
              client_config: client_config,
              timeout: timeout,
              app_name: app_name,
              app_version: app_version,
              lib_name: lib_name,
              lib_version: lib_version,
            )

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
            if credentials.is_a?(Google::Gax::Credentials)
              updater_proc = credentials.updater_proc
            end

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/0.20.0 gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            client_config_file = Pathname.new(__dir__).join(
              "dlp_service_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.privacy.dlp.v2beta1.DlpService",
                JSON.parse(f.read),
                client_config,
                Google::Gax::Grpc::STATUS_CODE_NAMES,
                timeout,
                errors: Google::Gax::Grpc::API_ERRORS,
                kwargs: headers
              )
            end
            @dlp_service_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              &Google::Privacy::Dlp::V2beta1::DlpService::Stub.method(:new)
            )

            @inspect_content = Google::Gax.create_api_call(
              @dlp_service_stub.method(:inspect_content),
              defaults["inspect_content"]
            )
            @redact_content = Google::Gax.create_api_call(
              @dlp_service_stub.method(:redact_content),
              defaults["redact_content"]
            )
            @create_inspect_operation = Google::Gax.create_api_call(
              @dlp_service_stub.method(:create_inspect_operation),
              defaults["create_inspect_operation"]
            )
            @list_inspect_findings = Google::Gax.create_api_call(
              @dlp_service_stub.method(:list_inspect_findings),
              defaults["list_inspect_findings"]
            )
            @list_info_types = Google::Gax.create_api_call(
              @dlp_service_stub.method(:list_info_types),
              defaults["list_info_types"]
            )
            @list_root_categories = Google::Gax.create_api_call(
              @dlp_service_stub.method(:list_root_categories),
              defaults["list_root_categories"]
            )
          end

          # Service calls

          # Finds potentially sensitive info in a list of strings.
          # This method has limits on input size, processing time, and output size.
          #
          # @param inspect_config [Google::Privacy::Dlp::V2beta1::InspectConfig | Hash]
          #   Configuration for the inspector.
          #   A hash of the same form as `Google::Privacy::Dlp::V2beta1::InspectConfig`
          #   can also be provided.
          # @param items [Array<Google::Privacy::Dlp::V2beta1::ContentItem | Hash>]
          #   The list of items to inspect. Items in a single request are
          #   considered "related" unless inspect_config.independent_inputs is true.
          #   Up to 100 are allowed per request.
          #   A hash of the same form as `Google::Privacy::Dlp::V2beta1::ContentItem`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Privacy::Dlp::V2beta1::InspectContentResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dlp/v2beta1"
          #
          #   dlp_service_client = Google::Cloud::Dlp::V2beta1.new
          #   name = "EMAIL_ADDRESS"
          #   info_types_element = { name: name }
          #   info_types = [info_types_element]
          #   inspect_config = { info_types: info_types }
          #   type = "text/plain"
          #   value = "My email is example@example.com."
          #   items_element = { type: type, value: value }
          #   items = [items_element]
          #   response = dlp_service_client.inspect_content(inspect_config, items)

          def inspect_content \
              inspect_config,
              items,
              options: nil
            req = {
              inspect_config: inspect_config,
              items: items
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Privacy::Dlp::V2beta1::InspectContentRequest)
            @inspect_content.call(req, options)
          end

          # Redacts potentially sensitive info from a list of strings.
          # This method has limits on input size, processing time, and output size.
          #
          # @param inspect_config [Google::Privacy::Dlp::V2beta1::InspectConfig | Hash]
          #   Configuration for the inspector.
          #   A hash of the same form as `Google::Privacy::Dlp::V2beta1::InspectConfig`
          #   can also be provided.
          # @param items [Array<Google::Privacy::Dlp::V2beta1::ContentItem | Hash>]
          #   The list of items to inspect. Up to 100 are allowed per request.
          #   A hash of the same form as `Google::Privacy::Dlp::V2beta1::ContentItem`
          #   can also be provided.
          # @param replace_configs [Array<Google::Privacy::Dlp::V2beta1::RedactContentRequest::ReplaceConfig | Hash>]
          #   The strings to replace findings text findings with. Must specify at least
          #   one of these or one ImageRedactionConfig if redacting images.
          #   A hash of the same form as `Google::Privacy::Dlp::V2beta1::RedactContentRequest::ReplaceConfig`
          #   can also be provided.
          # @param image_redaction_configs [Array<Google::Privacy::Dlp::V2beta1::RedactContentRequest::ImageRedactionConfig | Hash>]
          #   The configuration for specifying what content to redact from images.
          #   A hash of the same form as `Google::Privacy::Dlp::V2beta1::RedactContentRequest::ImageRedactionConfig`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Privacy::Dlp::V2beta1::RedactContentResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dlp/v2beta1"
          #
          #   dlp_service_client = Google::Cloud::Dlp::V2beta1.new
          #   name = "EMAIL_ADDRESS"
          #   info_types_element = { name: name }
          #   info_types = [info_types_element]
          #   inspect_config = { info_types: info_types }
          #   type = "text/plain"
          #   value = "My email is example@example.com."
          #   items_element = { type: type, value: value }
          #   items = [items_element]
          #   name_2 = "EMAIL_ADDRESS"
          #   info_type = { name: name_2 }
          #   replace_with = "REDACTED"
          #   replace_configs_element = { info_type: info_type, replace_with: replace_with }
          #   replace_configs = [replace_configs_element]
          #   response = dlp_service_client.redact_content(inspect_config, items, replace_configs)

          def redact_content \
              inspect_config,
              items,
              replace_configs,
              image_redaction_configs: nil,
              options: nil
            req = {
              inspect_config: inspect_config,
              items: items,
              replace_configs: replace_configs,
              image_redaction_configs: image_redaction_configs
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Privacy::Dlp::V2beta1::RedactContentRequest)
            @redact_content.call(req, options)
          end

          # Schedules a job scanning content in a Google Cloud Platform data
          # repository.
          #
          # @param inspect_config [Google::Privacy::Dlp::V2beta1::InspectConfig | Hash]
          #   Configuration for the inspector.
          #   A hash of the same form as `Google::Privacy::Dlp::V2beta1::InspectConfig`
          #   can also be provided.
          # @param storage_config [Google::Privacy::Dlp::V2beta1::StorageConfig | Hash]
          #   Specification of the data set to process.
          #   A hash of the same form as `Google::Privacy::Dlp::V2beta1::StorageConfig`
          #   can also be provided.
          # @param output_config [Google::Privacy::Dlp::V2beta1::OutputStorageConfig | Hash]
          #   Optional location to store findings. The bucket must already exist and
          #   the Google APIs service account for DLP must have write permission to
          #   write to the given bucket.
          #   <p>Results are split over multiple csv files with each file name matching
          #   the pattern "[operation_id]_[count].csv", for example
          #   +3094877188788974909_1.csv+. The +operation_id+ matches the
          #   identifier for the Operation, and the +count+ is a counter used for
          #   tracking the number of files written. <p>The CSV file(s) contain the
          #   following columns regardless of storage type scanned: <li>id <li>info_type
          #   <li>likelihood <li>byte size of finding <li>quote <li>timestamp<br/>
          #   <p>For Cloud Storage the next columns are: <li>file_path
          #   <li>start_offset<br/>
          #   <p>For Cloud Datastore the next columns are: <li>project_id
          #   <li>namespace_id <li>path <li>column_name <li>offset<br/>
          #   <p>For BigQuery the next columns are: <li>row_number <li>project_id
          #   <li>dataset_id <li>table_id
          #   A hash of the same form as `Google::Privacy::Dlp::V2beta1::OutputStorageConfig`
          #   can also be provided.
          # @param operation_config [Google::Privacy::Dlp::V2beta1::OperationConfig | Hash]
          #   Additional configuration settings for long running operations.
          #   A hash of the same form as `Google::Privacy::Dlp::V2beta1::OperationConfig`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dlp/v2beta1"
          #
          #   dlp_service_client = Google::Cloud::Dlp::V2beta1.new
          #   name = "EMAIL_ADDRESS"
          #   info_types_element = { name: name }
          #   info_types = [info_types_element]
          #   inspect_config = { info_types: info_types }
          #   url = "gs://example_bucket/example_file.png"
          #   file_set = { url: url }
          #   cloud_storage_options = { file_set: file_set }
          #   storage_config = { cloud_storage_options: cloud_storage_options }
          #   output_config = {}
          #
          #   # Register a callback during the method call.
          #   operation = dlp_service_client.create_inspect_operation(inspect_config, storage_config, output_config) do |op|
          #     raise op.results.message if op.error?
          #     op_results = op.results
          #     # Process the results.
          #
          #     metadata = op.metadata
          #     # Process the metadata.
          #   end
          #
          #   # Or use the return value to register a callback.
          #   operation.on_done do |op|
          #     raise op.results.message if op.error?
          #     op_results = op.results
          #     # Process the results.
          #
          #     metadata = op.metadata
          #     # Process the metadata.
          #   end
          #
          #   # Manually reload the operation.
          #   operation.reload!
          #
          #   # Or block until the operation completes, triggering callbacks on
          #   # completion.
          #   operation.wait_until_done!

          def create_inspect_operation \
              inspect_config,
              storage_config,
              output_config,
              operation_config: nil,
              options: nil
            req = {
              inspect_config: inspect_config,
              storage_config: storage_config,
              output_config: output_config,
              operation_config: operation_config
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Privacy::Dlp::V2beta1::CreateInspectOperationRequest)
            operation = Google::Gax::Operation.new(
              @create_inspect_operation.call(req, options),
              @operations_client,
              Google::Privacy::Dlp::V2beta1::InspectOperationResult,
              Google::Privacy::Dlp::V2beta1::InspectOperationMetadata,
              call_options: options
            )
            operation.on_done { |operation| yield(operation) } if block_given?
            operation
          end

          # Returns list of results for given inspect operation result set id.
          #
          # @param name [String]
          #   Identifier of the results set returned as metadata of
          #   the longrunning operation created by a call to CreateInspectOperation.
          #   Should be in the format of +inspect/results/{id}+.
          # @param page_size [Integer]
          #   Maximum number of results to return.
          #   If 0, the implementation selects a reasonable value.
          # @param page_token [String]
          #   The value returned by the last +ListInspectFindingsResponse+; indicates
          #   that this is a continuation of a prior +ListInspectFindings+ call, and that
          #   the system should return the next page of data.
          # @param filter [String]
          #   Restricts findings to items that match. Supports info_type and likelihood.
          #   <p>Examples:<br/>
          #   <li>info_type=EMAIL_ADDRESS
          #   <li>info_type=PHONE_NUMBER,EMAIL_ADDRESS
          #   <li>likelihood=VERY_LIKELY
          #   <li>likelihood=VERY_LIKELY,LIKELY
          #   <li>info_type=EMAIL_ADDRESS,likelihood=VERY_LIKELY,LIKELY
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Privacy::Dlp::V2beta1::ListInspectFindingsResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dlp/v2beta1"
          #
          #   dlp_service_client = Google::Cloud::Dlp::V2beta1.new
          #   formatted_name = Google::Cloud::Dlp::V2beta1::DlpServiceClient.result_path("[RESULT]")
          #   response = dlp_service_client.list_inspect_findings(formatted_name)

          def list_inspect_findings \
              name,
              page_size: nil,
              page_token: nil,
              filter: nil,
              options: nil
            req = {
              name: name,
              page_size: page_size,
              page_token: page_token,
              filter: filter
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Privacy::Dlp::V2beta1::ListInspectFindingsRequest)
            @list_inspect_findings.call(req, options)
          end

          # Returns sensitive information types for given category.
          #
          # @param category [String]
          #   Category name as returned by ListRootCategories.
          # @param language_code [String]
          #   Optional BCP-47 language code for localized info type friendly
          #   names. If omitted, or if localized strings are not available,
          #   en-US strings will be returned.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Privacy::Dlp::V2beta1::ListInfoTypesResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dlp/v2beta1"
          #
          #   dlp_service_client = Google::Cloud::Dlp::V2beta1.new
          #   category = "PII"
          #   language_code = "en"
          #   response = dlp_service_client.list_info_types(category, language_code)

          def list_info_types \
              category,
              language_code,
              options: nil
            req = {
              category: category,
              language_code: language_code
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Privacy::Dlp::V2beta1::ListInfoTypesRequest)
            @list_info_types.call(req, options)
          end

          # Returns the list of root categories of sensitive information.
          #
          # @param language_code [String]
          #   Optional language code for localized friendly category names.
          #   If omitted or if localized strings are not available,
          #   en-US strings will be returned.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Privacy::Dlp::V2beta1::ListRootCategoriesResponse]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/dlp/v2beta1"
          #
          #   dlp_service_client = Google::Cloud::Dlp::V2beta1.new
          #   language_code = "en"
          #   response = dlp_service_client.list_root_categories(language_code)

          def list_root_categories \
              language_code,
              options: nil
            req = {
              language_code: language_code
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Privacy::Dlp::V2beta1::ListRootCategoriesRequest)
            @list_root_categories.call(req, options)
          end
        end
      end
    end
  end
end
