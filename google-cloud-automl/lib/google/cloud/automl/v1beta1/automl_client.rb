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
# https://github.com/googleapis/googleapis/blob/master/google/cloud/automl/v1beta1/service.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.


require "json"
require "pathname"

require "google/gax"
require "google/gax/operation"
require "google/longrunning/operations_client"

require "google/cloud/automl/v1beta1/service_pb"
require "google/cloud/automl/v1beta1/credentials"
require "google/cloud/automl/version"
require "google/cloud/automl/v1beta1/automl_client_helpers"

module Google
  module Cloud
    module AutoML
      module V1beta1
        # AutoML Server API.
        #
        # The resource names are assigned by the server.
        # The server never reuses names that it has created after the resources with
        # those names are deleted.
        #
        # An ID of a resource is the last element of the item's resource name. For
        # `projects/{project_id}/locations/{location_id}/datasets/{dataset_id}`, then
        # the id for the item is `{dataset_id}`.
        #
        # Currently the only supported `location_id` is "us-central1".
        #
        # On any input that is documented to expect a string parameter in
        # snake_case or kebab-case, either of those cases is accepted.
        #
        # @!attribute [r] automl_stub
        #   @return [Google::Cloud::AutoML::V1beta1::AutoML::Stub]
        class AutoMLClient
          # @private
          attr_reader :automl_stub

          # The default address of the service.
          SERVICE_ADDRESS = "automl.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          # The default set of gRPC interceptors.
          GRPC_INTERCEPTORS = []

          DEFAULT_TIMEOUT = 30

          PAGE_DESCRIPTORS = {
            "list_datasets" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "datasets"),
            "list_models" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "model"),
            "list_model_evaluations" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "model_evaluation"),
            "list_table_specs" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "table_specs"),
            "list_column_specs" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "column_specs")
          }.freeze

          private_constant :PAGE_DESCRIPTORS

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform"
          ].freeze

          class OperationsClient < Google::Longrunning::OperationsClient
            self::SERVICE_ADDRESS = AutoMLClient::SERVICE_ADDRESS
            self::GRPC_INTERCEPTORS = AutoMLClient::GRPC_INTERCEPTORS
          end

          ANNOTATION_SPEC_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/locations/{location}/datasets/{dataset}/annotationSpecs/{annotation_spec}"
          )

          private_constant :ANNOTATION_SPEC_PATH_TEMPLATE

          COLUMN_SPEC_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/locations/{location}/datasets/{dataset}/tableSpecs/{table_spec}/columnSpecs/{column_spec}"
          )

          private_constant :COLUMN_SPEC_PATH_TEMPLATE

          DATASET_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/locations/{location}/datasets/{dataset}"
          )

          private_constant :DATASET_PATH_TEMPLATE

          LOCATION_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/locations/{location}"
          )

          private_constant :LOCATION_PATH_TEMPLATE

          MODEL_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/locations/{location}/models/{model}"
          )

          private_constant :MODEL_PATH_TEMPLATE

          MODEL_EVALUATION_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/locations/{location}/models/{model}/modelEvaluations/{model_evaluation}"
          )

          private_constant :MODEL_EVALUATION_PATH_TEMPLATE

          TABLE_SPEC_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/locations/{location}/datasets/{dataset}/tableSpecs/{table_spec}"
          )

          private_constant :TABLE_SPEC_PATH_TEMPLATE

          # Returns a fully-qualified annotation_spec resource name string.
          # @param project [String]
          # @param location [String]
          # @param dataset [String]
          # @param annotation_spec [String]
          # @return [String]
          def self.annotation_spec_path project, location, dataset, annotation_spec
            ANNOTATION_SPEC_PATH_TEMPLATE.render(
              :"project" => project,
              :"location" => location,
              :"dataset" => dataset,
              :"annotation_spec" => annotation_spec
            )
          end

          # Returns a fully-qualified column_spec resource name string.
          # @param project [String]
          # @param location [String]
          # @param dataset [String]
          # @param table_spec [String]
          # @param column_spec [String]
          # @return [String]
          def self.column_spec_path project, location, dataset, table_spec, column_spec
            COLUMN_SPEC_PATH_TEMPLATE.render(
              :"project" => project,
              :"location" => location,
              :"dataset" => dataset,
              :"table_spec" => table_spec,
              :"column_spec" => column_spec
            )
          end

          # Returns a fully-qualified dataset resource name string.
          # @param project [String]
          # @param location [String]
          # @param dataset [String]
          # @return [String]
          def self.dataset_path project, location, dataset
            DATASET_PATH_TEMPLATE.render(
              :"project" => project,
              :"location" => location,
              :"dataset" => dataset
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

          # Returns a fully-qualified model resource name string.
          # @param project [String]
          # @param location [String]
          # @param model [String]
          # @return [String]
          def self.model_path project, location, model
            MODEL_PATH_TEMPLATE.render(
              :"project" => project,
              :"location" => location,
              :"model" => model
            )
          end

          # Returns a fully-qualified model_evaluation resource name string.
          # @param project [String]
          # @param location [String]
          # @param model [String]
          # @param model_evaluation [String]
          # @return [String]
          def self.model_evaluation_path project, location, model, model_evaluation
            MODEL_EVALUATION_PATH_TEMPLATE.render(
              :"project" => project,
              :"location" => location,
              :"model" => model,
              :"model_evaluation" => model_evaluation
            )
          end

          # Returns a fully-qualified table_spec resource name string.
          # @param project [String]
          # @param location [String]
          # @param dataset [String]
          # @param table_spec [String]
          # @return [String]
          def self.table_spec_path project, location, dataset, table_spec
            TABLE_SPEC_PATH_TEMPLATE.render(
              :"project" => project,
              :"location" => location,
              :"dataset" => dataset,
              :"table_spec" => table_spec
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
            require "google/cloud/automl/v1beta1/service_services_pb"

            credentials ||= Google::Cloud::AutoML::V1beta1::Credentials.default

            @operations_client = OperationsClient.new(
              credentials: credentials,
              scopes: scopes,
              client_config: client_config,
              timeout: timeout,
              lib_name: lib_name,
              service_address: service_address,
              service_port: service_port,
              lib_version: lib_version,
              metadata: metadata,
            )

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::AutoML::V1beta1::Credentials.new(credentials).updater_proc
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

            package_version = Google::Cloud::AutoML::VERSION

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
              "automl_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.cloud.automl.v1beta1.AutoMl",
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
            @automl_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Cloud::AutoML::V1beta1::AutoML::Stub.method(:new)
            )

            @create_dataset = Google::Gax.create_api_call(
              @automl_stub.method(:create_dataset),
              defaults["create_dataset"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @update_dataset = Google::Gax.create_api_call(
              @automl_stub.method(:update_dataset),
              defaults["update_dataset"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'dataset.name' => request.dataset.name}
              end
            )
            @get_dataset = Google::Gax.create_api_call(
              @automl_stub.method(:get_dataset),
              defaults["get_dataset"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @list_datasets = Google::Gax.create_api_call(
              @automl_stub.method(:list_datasets),
              defaults["list_datasets"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @delete_dataset = Google::Gax.create_api_call(
              @automl_stub.method(:delete_dataset),
              defaults["delete_dataset"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @import_data = Google::Gax.create_api_call(
              @automl_stub.method(:import_data),
              defaults["import_data"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @export_data = Google::Gax.create_api_call(
              @automl_stub.method(:export_data),
              defaults["export_data"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @create_model = Google::Gax.create_api_call(
              @automl_stub.method(:create_model),
              defaults["create_model"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @get_model = Google::Gax.create_api_call(
              @automl_stub.method(:get_model),
              defaults["get_model"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @list_models = Google::Gax.create_api_call(
              @automl_stub.method(:list_models),
              defaults["list_models"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @delete_model = Google::Gax.create_api_call(
              @automl_stub.method(:delete_model),
              defaults["delete_model"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @deploy_model = Google::Gax.create_api_call(
              @automl_stub.method(:deploy_model),
              defaults["deploy_model"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @undeploy_model = Google::Gax.create_api_call(
              @automl_stub.method(:undeploy_model),
              defaults["undeploy_model"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @get_model_evaluation = Google::Gax.create_api_call(
              @automl_stub.method(:get_model_evaluation),
              defaults["get_model_evaluation"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @export_model = Google::Gax.create_api_call(
              @automl_stub.method(:export_model),
              defaults["export_model"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @export_evaluated_examples = Google::Gax.create_api_call(
              @automl_stub.method(:export_evaluated_examples),
              defaults["export_evaluated_examples"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @list_model_evaluations = Google::Gax.create_api_call(
              @automl_stub.method(:list_model_evaluations),
              defaults["list_model_evaluations"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @get_annotation_spec = Google::Gax.create_api_call(
              @automl_stub.method(:get_annotation_spec),
              defaults["get_annotation_spec"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @get_table_spec = Google::Gax.create_api_call(
              @automl_stub.method(:get_table_spec),
              defaults["get_table_spec"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @list_table_specs = Google::Gax.create_api_call(
              @automl_stub.method(:list_table_specs),
              defaults["list_table_specs"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @update_table_spec = Google::Gax.create_api_call(
              @automl_stub.method(:update_table_spec),
              defaults["update_table_spec"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'table_spec.name' => request.table_spec.name}
              end
            )
            @get_column_spec = Google::Gax.create_api_call(
              @automl_stub.method(:get_column_spec),
              defaults["get_column_spec"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'name' => request.name}
              end
            )
            @list_column_specs = Google::Gax.create_api_call(
              @automl_stub.method(:list_column_specs),
              defaults["list_column_specs"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'parent' => request.parent}
              end
            )
            @update_column_spec = Google::Gax.create_api_call(
              @automl_stub.method(:update_column_spec),
              defaults["update_column_spec"],
              exception_transformer: exception_transformer,
              params_extractor: proc do |request|
                {'column_spec.name' => request.column_spec.name}
              end
            )
          end

          # Service calls

          # Creates a dataset.
          #
          # @param parent [String]
          #   Required. The resource name of the project to create the dataset for.
          # @param dataset [Google::Cloud::AutoML::V1beta1::Dataset | Hash]
          #   Required. The dataset to create.
          #   A hash of the same form as `Google::Cloud::AutoML::V1beta1::Dataset`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::AutoML::V1beta1::Dataset]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::AutoML::V1beta1::Dataset]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/automl"
          #
          #   automl_client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)
          #   formatted_parent = Google::Cloud::AutoML::V1beta1::AutoMLClient.location_path("[PROJECT]", "[LOCATION]")
          #
          #   # TODO: Initialize `dataset`:
          #   dataset = {}
          #   response = automl_client.create_dataset(formatted_parent, dataset)

          def create_dataset \
              parent,
              dataset,
              options: nil,
              &block
            req = {
              parent: parent,
              dataset: dataset
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::AutoML::V1beta1::CreateDatasetRequest)
            @create_dataset.call(req, options, &block)
          end

          # Updates a dataset.
          #
          # @param dataset [Google::Cloud::AutoML::V1beta1::Dataset | Hash]
          #   Required. The dataset which replaces the resource on the server.
          #   A hash of the same form as `Google::Cloud::AutoML::V1beta1::Dataset`
          #   can also be provided.
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   The update mask applies to the resource.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::AutoML::V1beta1::Dataset]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::AutoML::V1beta1::Dataset]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/automl"
          #
          #   automl_client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)
          #
          #   # TODO: Initialize `dataset`:
          #   dataset = {}
          #   response = automl_client.update_dataset(dataset)

          def update_dataset \
              dataset,
              update_mask: nil,
              options: nil,
              &block
            req = {
              dataset: dataset,
              update_mask: update_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::AutoML::V1beta1::UpdateDatasetRequest)
            @update_dataset.call(req, options, &block)
          end

          # Gets a dataset.
          #
          # @param name [String]
          #   Required. The resource name of the dataset to retrieve.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::AutoML::V1beta1::Dataset]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::AutoML::V1beta1::Dataset]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/automl"
          #
          #   automl_client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)
          #   formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.dataset_path("[PROJECT]", "[LOCATION]", "[DATASET]")
          #   response = automl_client.get_dataset(formatted_name)

          def get_dataset \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::AutoML::V1beta1::GetDatasetRequest)
            @get_dataset.call(req, options, &block)
          end

          # Lists datasets in a project.
          #
          # @param parent [String]
          #   Required. The resource name of the project from which to list datasets.
          # @param filter [String]
          #   An expression for filtering the results of the request.
          #
          #   * `dataset_metadata` - for existence of the case (e.g.
          #     image_classification_dataset_metadata:*). Some examples of using the filter are:
          #
          #     * `translation_dataset_metadata:*` --> The dataset has
          #       translation_dataset_metadata.
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::AutoML::V1beta1::Dataset>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::AutoML::V1beta1::Dataset>]
          #   An enumerable of Google::Cloud::AutoML::V1beta1::Dataset instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/automl"
          #
          #   automl_client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)
          #   formatted_parent = Google::Cloud::AutoML::V1beta1::AutoMLClient.location_path("[PROJECT]", "[LOCATION]")
          #
          #   # Iterate over all results.
          #   automl_client.list_datasets(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   automl_client.list_datasets(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_datasets \
              parent,
              filter: nil,
              page_size: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              filter: filter,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::AutoML::V1beta1::ListDatasetsRequest)
            @list_datasets.call(req, options, &block)
          end

          # Deletes a dataset and all of its contents.
          # Returns empty response in the
          # {Google::Longrunning::Operation#response response} field when it completes,
          # and `delete_details` in the
          # {Google::Longrunning::Operation#metadata metadata} field.
          #
          # @param name [String]
          #   Required. The resource name of the dataset to delete.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/automl"
          #
          #   automl_client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)
          #   formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.dataset_path("[PROJECT]", "[LOCATION]", "[DATASET]")
          #
          #   # Register a callback during the method call.
          #   operation = automl_client.delete_dataset(formatted_name) do |op|
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

          def delete_dataset \
              name,
              options: nil
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::AutoML::V1beta1::DeleteDatasetRequest)
            operation = Google::Gax::Operation.new(
              @delete_dataset.call(req, options),
              @operations_client,
              Google::Protobuf::Empty,
              Google::Cloud::AutoML::V1beta1::OperationMetadata,
              call_options: options
            )
            operation.on_done { |operation| yield(operation) } if block_given?
            operation
          end

          # Imports data into a dataset.
          # For Tables this method can only be called on an empty Dataset.
          #
          # For Tables:
          # * A
          #   {Google::Cloud::AutoML::V1beta1::InputConfig#params schema_inference_version}
          #   parameter must be explicitly set.
          #   Returns an empty response in the
          #   {Google::Longrunning::Operation#response response} field when it completes.
          #
          # @param name [String]
          #   Required. Dataset name. Dataset must already exist. All imported
          #   annotations and examples will be added.
          # @param input_config [Google::Cloud::AutoML::V1beta1::InputConfig | Hash]
          #   Required. The desired input location and its domain specific semantics,
          #   if any.
          #   A hash of the same form as `Google::Cloud::AutoML::V1beta1::InputConfig`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/automl"
          #
          #   automl_client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)
          #   formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.dataset_path("[PROJECT]", "[LOCATION]", "[DATASET]")
          #
          #   # TODO: Initialize `input_config`:
          #   input_config = {}
          #
          #   # Register a callback during the method call.
          #   operation = automl_client.import_data(formatted_name, input_config) do |op|
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

          def import_data \
              name,
              input_config,
              options: nil
            req = {
              name: name,
              input_config: input_config
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::AutoML::V1beta1::ImportDataRequest)
            operation = Google::Gax::Operation.new(
              @import_data.call(req, options),
              @operations_client,
              Google::Protobuf::Empty,
              Google::Cloud::AutoML::V1beta1::OperationMetadata,
              call_options: options
            )
            operation.on_done { |operation| yield(operation) } if block_given?
            operation
          end

          # Exports dataset's data to the provided output location.
          # Returns an empty response in the
          # {Google::Longrunning::Operation#response response} field when it completes.
          #
          # @param name [String]
          #   Required. The resource name of the dataset.
          # @param output_config [Google::Cloud::AutoML::V1beta1::OutputConfig | Hash]
          #   Required. The desired output location.
          #   A hash of the same form as `Google::Cloud::AutoML::V1beta1::OutputConfig`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/automl"
          #
          #   automl_client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)
          #   formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.dataset_path("[PROJECT]", "[LOCATION]", "[DATASET]")
          #
          #   # TODO: Initialize `output_config`:
          #   output_config = {}
          #
          #   # Register a callback during the method call.
          #   operation = automl_client.export_data(formatted_name, output_config) do |op|
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

          def export_data \
              name,
              output_config,
              options: nil
            req = {
              name: name,
              output_config: output_config
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::AutoML::V1beta1::ExportDataRequest)
            operation = Google::Gax::Operation.new(
              @export_data.call(req, options),
              @operations_client,
              Google::Protobuf::Empty,
              Google::Cloud::AutoML::V1beta1::OperationMetadata,
              call_options: options
            )
            operation.on_done { |operation| yield(operation) } if block_given?
            operation
          end

          # Creates a model.
          # Returns a Model in the {Google::Longrunning::Operation#response response}
          # field when it completes.
          # When you create a model, several model evaluations are created for it:
          # a global evaluation, and one evaluation for each annotation spec.
          #
          # @param parent [String]
          #   Required. Resource name of the parent project where the model is being created.
          # @param model [Google::Cloud::AutoML::V1beta1::Model | Hash]
          #   Required. The model to create.
          #   A hash of the same form as `Google::Cloud::AutoML::V1beta1::Model`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/automl"
          #
          #   automl_client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)
          #   formatted_parent = Google::Cloud::AutoML::V1beta1::AutoMLClient.location_path("[PROJECT]", "[LOCATION]")
          #
          #   # TODO: Initialize `model`:
          #   model = {}
          #
          #   # Register a callback during the method call.
          #   operation = automl_client.create_model(formatted_parent, model) do |op|
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

          def create_model \
              parent,
              model,
              options: nil
            req = {
              parent: parent,
              model: model
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::AutoML::V1beta1::CreateModelRequest)
            operation = Google::Gax::Operation.new(
              @create_model.call(req, options),
              @operations_client,
              Google::Cloud::AutoML::V1beta1::Model,
              Google::Cloud::AutoML::V1beta1::OperationMetadata,
              call_options: options
            )
            operation.on_done { |operation| yield(operation) } if block_given?
            operation
          end

          # Gets a model.
          #
          # @param name [String]
          #   Required. Resource name of the model.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::AutoML::V1beta1::Model]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::AutoML::V1beta1::Model]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/automl"
          #
          #   automl_client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)
          #   formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.model_path("[PROJECT]", "[LOCATION]", "[MODEL]")
          #   response = automl_client.get_model(formatted_name)

          def get_model \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::AutoML::V1beta1::GetModelRequest)
            @get_model.call(req, options, &block)
          end

          # Lists models.
          #
          # @param parent [String]
          #   Required. Resource name of the project, from which to list the models.
          # @param filter [String]
          #   An expression for filtering the results of the request.
          #
          #   * `model_metadata` - for existence of the case (e.g.
          #     video_classification_model_metadata:*).
          #     * `dataset_id` - for = or !=. Some examples of using the filter are:
          #
          #     * `image_classification_model_metadata:*` --> The model has
          #       image_classification_model_metadata.
          #     * `dataset_id=5` --> The model was created from a dataset with ID 5.
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::AutoML::V1beta1::Model>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::AutoML::V1beta1::Model>]
          #   An enumerable of Google::Cloud::AutoML::V1beta1::Model instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/automl"
          #
          #   automl_client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)
          #   formatted_parent = Google::Cloud::AutoML::V1beta1::AutoMLClient.location_path("[PROJECT]", "[LOCATION]")
          #
          #   # Iterate over all results.
          #   automl_client.list_models(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   automl_client.list_models(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_models \
              parent,
              filter: nil,
              page_size: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              filter: filter,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::AutoML::V1beta1::ListModelsRequest)
            @list_models.call(req, options, &block)
          end

          # Deletes a model.
          # Returns `google.protobuf.Empty` in the
          # {Google::Longrunning::Operation#response response} field when it completes,
          # and `delete_details` in the
          # {Google::Longrunning::Operation#metadata metadata} field.
          #
          # @param name [String]
          #   Required. Resource name of the model being deleted.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/automl"
          #
          #   automl_client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)
          #   formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.model_path("[PROJECT]", "[LOCATION]", "[MODEL]")
          #
          #   # Register a callback during the method call.
          #   operation = automl_client.delete_model(formatted_name) do |op|
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

          def delete_model \
              name,
              options: nil
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::AutoML::V1beta1::DeleteModelRequest)
            operation = Google::Gax::Operation.new(
              @delete_model.call(req, options),
              @operations_client,
              Google::Protobuf::Empty,
              Google::Cloud::AutoML::V1beta1::OperationMetadata,
              call_options: options
            )
            operation.on_done { |operation| yield(operation) } if block_given?
            operation
          end

          # Deploys a model. If a model is already deployed, deploying it with the
          # same parameters has no effect. Deploying with different parametrs
          # (as e.g. changing
          #
          # {Google::Cloud::AutoML::V1beta1::ImageObjectDetectionModelDeploymentMetadata#node_number node_number})
          #  will reset the deployment state without pausing the model's availability.
          #
          # Only applicable for Text Classification, Image Object Detection , Tables, and Image Segmentation; all other domains manage
          # deployment automatically.
          #
          # Returns an empty response in the
          # {Google::Longrunning::Operation#response response} field when it completes.
          #
          # @param name [String]
          #   Required. Resource name of the model to deploy.
          # @param image_object_detection_model_deployment_metadata [Google::Cloud::AutoML::V1beta1::ImageObjectDetectionModelDeploymentMetadata | Hash]
          #   Model deployment metadata specific to Image Object Detection.
          #   A hash of the same form as `Google::Cloud::AutoML::V1beta1::ImageObjectDetectionModelDeploymentMetadata`
          #   can also be provided.
          # @param image_classification_model_deployment_metadata [Google::Cloud::AutoML::V1beta1::ImageClassificationModelDeploymentMetadata | Hash]
          #   Model deployment metadata specific to Image Classification.
          #   A hash of the same form as `Google::Cloud::AutoML::V1beta1::ImageClassificationModelDeploymentMetadata`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/automl"
          #
          #   automl_client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)
          #   formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.model_path("[PROJECT]", "[LOCATION]", "[MODEL]")
          #
          #   # Register a callback during the method call.
          #   operation = automl_client.deploy_model(formatted_name) do |op|
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

          def deploy_model \
              name,
              image_object_detection_model_deployment_metadata: nil,
              image_classification_model_deployment_metadata: nil,
              options: nil
            req = {
              name: name,
              image_object_detection_model_deployment_metadata: image_object_detection_model_deployment_metadata,
              image_classification_model_deployment_metadata: image_classification_model_deployment_metadata
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::AutoML::V1beta1::DeployModelRequest)
            operation = Google::Gax::Operation.new(
              @deploy_model.call(req, options),
              @operations_client,
              Google::Protobuf::Empty,
              Google::Cloud::AutoML::V1beta1::OperationMetadata,
              call_options: options
            )
            operation.on_done { |operation| yield(operation) } if block_given?
            operation
          end

          # Undeploys a model. If the model is not deployed this method has no effect.
          #
          # Only applicable for Text Classification, Image Object Detection and Tables;
          # all other domains manage deployment automatically.
          #
          # Returns an empty response in the
          # {Google::Longrunning::Operation#response response} field when it completes.
          #
          # @param name [String]
          #   Required. Resource name of the model to undeploy.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/automl"
          #
          #   automl_client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)
          #   formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.model_path("[PROJECT]", "[LOCATION]", "[MODEL]")
          #
          #   # Register a callback during the method call.
          #   operation = automl_client.undeploy_model(formatted_name) do |op|
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

          def undeploy_model \
              name,
              options: nil
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::AutoML::V1beta1::UndeployModelRequest)
            operation = Google::Gax::Operation.new(
              @undeploy_model.call(req, options),
              @operations_client,
              Google::Protobuf::Empty,
              Google::Cloud::AutoML::V1beta1::OperationMetadata,
              call_options: options
            )
            operation.on_done { |operation| yield(operation) } if block_given?
            operation
          end

          # Gets a model evaluation.
          #
          # @param name [String]
          #   Required. Resource name for the model evaluation.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::AutoML::V1beta1::ModelEvaluation]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::AutoML::V1beta1::ModelEvaluation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/automl"
          #
          #   automl_client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)
          #   formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.model_evaluation_path("[PROJECT]", "[LOCATION]", "[MODEL]", "[MODEL_EVALUATION]")
          #   response = automl_client.get_model_evaluation(formatted_name)

          def get_model_evaluation \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::AutoML::V1beta1::GetModelEvaluationRequest)
            @get_model_evaluation.call(req, options, &block)
          end

          # Exports a trained, "export-able", model to a user specified Google Cloud
          # Storage location. A model is considered export-able if and only if it has
          # an export format defined for it in
          #
          # {Google::Cloud::AutoML::V1beta1::ModelExportOutputConfig ModelExportOutputConfig}.
          #
          # Returns an empty response in the
          # {Google::Longrunning::Operation#response response} field when it completes.
          #
          # @param name [String]
          #   Required. The resource name of the model to export.
          # @param output_config [Google::Cloud::AutoML::V1beta1::ModelExportOutputConfig | Hash]
          #   Required. The desired output location and configuration.
          #   A hash of the same form as `Google::Cloud::AutoML::V1beta1::ModelExportOutputConfig`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/automl"
          #
          #   automl_client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)
          #   formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.model_path("[PROJECT]", "[LOCATION]", "[MODEL]")
          #
          #   # TODO: Initialize `output_config`:
          #   output_config = {}
          #
          #   # Register a callback during the method call.
          #   operation = automl_client.export_model(formatted_name, output_config) do |op|
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

          def export_model \
              name,
              output_config,
              options: nil
            req = {
              name: name,
              output_config: output_config
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::AutoML::V1beta1::ExportModelRequest)
            operation = Google::Gax::Operation.new(
              @export_model.call(req, options),
              @operations_client,
              Google::Protobuf::Empty,
              Google::Cloud::AutoML::V1beta1::OperationMetadata,
              call_options: options
            )
            operation.on_done { |operation| yield(operation) } if block_given?
            operation
          end

          # Exports examples on which the model was evaluated (i.e. which were in the
          # TEST set of the dataset the model was created from), together with their
          # ground truth annotations and the annotations created (predicted) by the
          # model.
          # The examples, ground truth and predictions are exported in the state
          # they were at the moment the model was evaluated.
          #
          # This export is available only for 30 days since the model evaluation is
          # created.
          #
          # Currently only available for Tables.
          #
          # Returns an empty response in the
          # {Google::Longrunning::Operation#response response} field when it completes.
          #
          # @param name [String]
          #   Required. The resource name of the model whose evaluated examples are to
          #   be exported.
          # @param output_config [Google::Cloud::AutoML::V1beta1::ExportEvaluatedExamplesOutputConfig | Hash]
          #   Required. The desired output location and configuration.
          #   A hash of the same form as `Google::Cloud::AutoML::V1beta1::ExportEvaluatedExamplesOutputConfig`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/automl"
          #
          #   automl_client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)
          #   formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.model_path("[PROJECT]", "[LOCATION]", "[MODEL]")
          #
          #   # TODO: Initialize `output_config`:
          #   output_config = {}
          #
          #   # Register a callback during the method call.
          #   operation = automl_client.export_evaluated_examples(formatted_name, output_config) do |op|
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

          def export_evaluated_examples \
              name,
              output_config,
              options: nil
            req = {
              name: name,
              output_config: output_config
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::AutoML::V1beta1::ExportEvaluatedExamplesRequest)
            operation = Google::Gax::Operation.new(
              @export_evaluated_examples.call(req, options),
              @operations_client,
              Google::Protobuf::Empty,
              Google::Cloud::AutoML::V1beta1::OperationMetadata,
              call_options: options
            )
            operation.on_done { |operation| yield(operation) } if block_given?
            operation
          end

          # Lists model evaluations.
          #
          # @param parent [String]
          #   Required. Resource name of the model to list the model evaluations for.
          #   If modelId is set as "-", this will list model evaluations from across all
          #   models of the parent location.
          # @param filter [String]
          #   An expression for filtering the results of the request.
          #
          #   * `annotation_spec_id` - for =, !=  or existence. See example below for
          #     the last.
          #
          #   Some examples of using the filter are:
          #
          #   * `annotation_spec_id!=4` --> The model evaluation was done for
          #     annotation spec with ID different than 4.
          #     * `NOT annotation_spec_id:*` --> The model evaluation was done for
          #       aggregate of all annotation specs.
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::AutoML::V1beta1::ModelEvaluation>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::AutoML::V1beta1::ModelEvaluation>]
          #   An enumerable of Google::Cloud::AutoML::V1beta1::ModelEvaluation instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/automl"
          #
          #   automl_client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)
          #   formatted_parent = Google::Cloud::AutoML::V1beta1::AutoMLClient.model_path("[PROJECT]", "[LOCATION]", "[MODEL]")
          #
          #   # Iterate over all results.
          #   automl_client.list_model_evaluations(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   automl_client.list_model_evaluations(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_model_evaluations \
              parent,
              filter: nil,
              page_size: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              filter: filter,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::AutoML::V1beta1::ListModelEvaluationsRequest)
            @list_model_evaluations.call(req, options, &block)
          end

          # Gets an annotation spec.
          #
          # @param name [String]
          #   Required. The resource name of the annotation spec to retrieve.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::AutoML::V1beta1::AnnotationSpec]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::AutoML::V1beta1::AnnotationSpec]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/automl"
          #
          #   automl_client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)
          #   formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.annotation_spec_path("[PROJECT]", "[LOCATION]", "[DATASET]", "[ANNOTATION_SPEC]")
          #   response = automl_client.get_annotation_spec(formatted_name)

          def get_annotation_spec \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::AutoML::V1beta1::GetAnnotationSpecRequest)
            @get_annotation_spec.call(req, options, &block)
          end

          # Gets a table spec.
          #
          # @param name [String]
          #   Required. The resource name of the table spec to retrieve.
          # @param field_mask [Google::Protobuf::FieldMask | Hash]
          #   Mask specifying which fields to read.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::AutoML::V1beta1::TableSpec]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::AutoML::V1beta1::TableSpec]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/automl"
          #
          #   automl_client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)
          #   formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.table_spec_path("[PROJECT]", "[LOCATION]", "[DATASET]", "[TABLE_SPEC]")
          #   response = automl_client.get_table_spec(formatted_name)

          def get_table_spec \
              name,
              field_mask: nil,
              options: nil,
              &block
            req = {
              name: name,
              field_mask: field_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::AutoML::V1beta1::GetTableSpecRequest)
            @get_table_spec.call(req, options, &block)
          end

          # Lists table specs in a dataset.
          #
          # @param parent [String]
          #   Required. The resource name of the dataset to list table specs from.
          # @param field_mask [Google::Protobuf::FieldMask | Hash]
          #   Mask specifying which fields to read.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param filter [String]
          #   Filter expression, see go/filtering.
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::AutoML::V1beta1::TableSpec>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::AutoML::V1beta1::TableSpec>]
          #   An enumerable of Google::Cloud::AutoML::V1beta1::TableSpec instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/automl"
          #
          #   automl_client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)
          #   formatted_parent = Google::Cloud::AutoML::V1beta1::AutoMLClient.dataset_path("[PROJECT]", "[LOCATION]", "[DATASET]")
          #
          #   # Iterate over all results.
          #   automl_client.list_table_specs(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   automl_client.list_table_specs(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_table_specs \
              parent,
              field_mask: nil,
              filter: nil,
              page_size: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              field_mask: field_mask,
              filter: filter,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::AutoML::V1beta1::ListTableSpecsRequest)
            @list_table_specs.call(req, options, &block)
          end

          # Updates a table spec.
          #
          # @param table_spec [Google::Cloud::AutoML::V1beta1::TableSpec | Hash]
          #   Required. The table spec which replaces the resource on the server.
          #   A hash of the same form as `Google::Cloud::AutoML::V1beta1::TableSpec`
          #   can also be provided.
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   The update mask applies to the resource.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::AutoML::V1beta1::TableSpec]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::AutoML::V1beta1::TableSpec]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/automl"
          #
          #   automl_client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)
          #
          #   # TODO: Initialize `table_spec`:
          #   table_spec = {}
          #   response = automl_client.update_table_spec(table_spec)

          def update_table_spec \
              table_spec,
              update_mask: nil,
              options: nil,
              &block
            req = {
              table_spec: table_spec,
              update_mask: update_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::AutoML::V1beta1::UpdateTableSpecRequest)
            @update_table_spec.call(req, options, &block)
          end

          # Gets a column spec.
          #
          # @param name [String]
          #   Required. The resource name of the column spec to retrieve.
          # @param field_mask [Google::Protobuf::FieldMask | Hash]
          #   Mask specifying which fields to read.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::AutoML::V1beta1::ColumnSpec]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::AutoML::V1beta1::ColumnSpec]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/automl"
          #
          #   automl_client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)
          #   formatted_name = Google::Cloud::AutoML::V1beta1::AutoMLClient.column_spec_path("[PROJECT]", "[LOCATION]", "[DATASET]", "[TABLE_SPEC]", "[COLUMN_SPEC]")
          #   response = automl_client.get_column_spec(formatted_name)

          def get_column_spec \
              name,
              field_mask: nil,
              options: nil,
              &block
            req = {
              name: name,
              field_mask: field_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::AutoML::V1beta1::GetColumnSpecRequest)
            @get_column_spec.call(req, options, &block)
          end

          # Lists column specs in a table spec.
          #
          # @param parent [String]
          #   Required. The resource name of the table spec to list column specs from.
          # @param field_mask [Google::Protobuf::FieldMask | Hash]
          #   Mask specifying which fields to read.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param filter [String]
          #   Filter expression, see go/filtering.
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::AutoML::V1beta1::ColumnSpec>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::AutoML::V1beta1::ColumnSpec>]
          #   An enumerable of Google::Cloud::AutoML::V1beta1::ColumnSpec instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/automl"
          #
          #   automl_client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)
          #   formatted_parent = Google::Cloud::AutoML::V1beta1::AutoMLClient.table_spec_path("[PROJECT]", "[LOCATION]", "[DATASET]", "[TABLE_SPEC]")
          #
          #   # Iterate over all results.
          #   automl_client.list_column_specs(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   automl_client.list_column_specs(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_column_specs \
              parent,
              field_mask: nil,
              filter: nil,
              page_size: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              field_mask: field_mask,
              filter: filter,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::AutoML::V1beta1::ListColumnSpecsRequest)
            @list_column_specs.call(req, options, &block)
          end

          # Updates a column spec.
          #
          # @param column_spec [Google::Cloud::AutoML::V1beta1::ColumnSpec | Hash]
          #   Required. The column spec which replaces the resource on the server.
          #   A hash of the same form as `Google::Cloud::AutoML::V1beta1::ColumnSpec`
          #   can also be provided.
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   The update mask applies to the resource.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::AutoML::V1beta1::ColumnSpec]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::AutoML::V1beta1::ColumnSpec]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/automl"
          #
          #   automl_client = Google::Cloud::AutoML::AutoML.new(version: :v1beta1)
          #
          #   # TODO: Initialize `column_spec`:
          #   column_spec = {}
          #   response = automl_client.update_column_spec(column_spec)

          def update_column_spec \
              column_spec,
              update_mask: nil,
              options: nil,
              &block
            req = {
              column_spec: column_spec,
              update_mask: update_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::AutoML::V1beta1::UpdateColumnSpecRequest)
            @update_column_spec.call(req, options, &block)
          end
        end
      end
    end
  end
end
