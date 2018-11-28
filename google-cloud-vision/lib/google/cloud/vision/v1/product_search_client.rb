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
# https://github.com/googleapis/googleapis/blob/master/google/cloud/vision/v1/product_search_service.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.


require "json"
require "pathname"

require "google/gax"
require "google/gax/operation"
require "google/longrunning/operations_client"

require "google/cloud/vision/v1/product_search_service_pb"
require "google/cloud/vision/v1/credentials"

module Google
  module Cloud
    module Vision
      module V1
        # Manages Products and ProductSets of reference images for use in product
        # search. It uses the following resource model:
        #
        # * The API has a collection of {Google::Cloud::Vision::V1::ProductSet ProductSet} resources, named
        #   `projects/*/locations/*/productSets/*`, which acts as a way to put different
        #   products into groups to limit identification.
        #
        # In parallel,
        #
        # * The API has a collection of {Google::Cloud::Vision::V1::Product Product} resources, named
        #   `projects/*/locations/*/products/*`
        #
        # * Each {Google::Cloud::Vision::V1::Product Product} has a collection of {Google::Cloud::Vision::V1::ReferenceImage ReferenceImage} resources, named
        #   `projects/*/locations/*/products/*/referenceImages/*`
        #
        # @!attribute [r] product_search_stub
        #   @return [Google::Cloud::Vision::V1::ProductSearch::Stub]
        class ProductSearchClient
          # @private
          attr_reader :product_search_stub

          # The default address of the service.
          SERVICE_ADDRESS = "vision.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          # The default set of gRPC interceptors.
          GRPC_INTERCEPTORS = []

          DEFAULT_TIMEOUT = 30

          PAGE_DESCRIPTORS = {
            "list_products" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "products"),
            "list_reference_images" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "reference_images"),
            "list_product_sets" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "product_sets"),
            "list_products_in_product_set" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "products")
          }.freeze

          private_constant :PAGE_DESCRIPTORS

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform",
            "https://www.googleapis.com/auth/cloud-vision"
          ].freeze

          # @private
          class OperationsClient < Google::Longrunning::OperationsClient
            self::SERVICE_ADDRESS = ProductSearchClient::SERVICE_ADDRESS
            self::GRPC_INTERCEPTORS = ProductSearchClient::GRPC_INTERCEPTORS
          end

          LOCATION_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/locations/{location}"
          )

          private_constant :LOCATION_PATH_TEMPLATE

          PRODUCT_SET_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/locations/{location}/productSets/{product_set}"
          )

          private_constant :PRODUCT_SET_PATH_TEMPLATE

          PRODUCT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/locations/{location}/products/{product}"
          )

          private_constant :PRODUCT_PATH_TEMPLATE

          REFERENCE_IMAGE_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/locations/{location}/products/{product}/referenceImages/{reference_image}"
          )

          private_constant :REFERENCE_IMAGE_PATH_TEMPLATE

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

          # Returns a fully-qualified product_set resource name string.
          # @param project [String]
          # @param location [String]
          # @param product_set [String]
          # @return [String]
          def self.product_set_path project, location, product_set
            PRODUCT_SET_PATH_TEMPLATE.render(
              :"project" => project,
              :"location" => location,
              :"product_set" => product_set
            )
          end

          # Returns a fully-qualified product resource name string.
          # @param project [String]
          # @param location [String]
          # @param product [String]
          # @return [String]
          def self.product_path project, location, product
            PRODUCT_PATH_TEMPLATE.render(
              :"project" => project,
              :"location" => location,
              :"product" => product
            )
          end

          # Returns a fully-qualified reference_image resource name string.
          # @param project [String]
          # @param location [String]
          # @param product [String]
          # @param reference_image [String]
          # @return [String]
          def self.reference_image_path project, location, product, reference_image
            REFERENCE_IMAGE_PATH_TEMPLATE.render(
              :"project" => project,
              :"location" => location,
              :"product" => product,
              :"reference_image" => reference_image
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
            require "google/cloud/vision/v1/product_search_service_services_pb"

            credentials ||= Google::Cloud::Vision::V1::Credentials.default

            @operations_client = OperationsClient.new(
              credentials: credentials,
              scopes: scopes,
              client_config: client_config,
              timeout: timeout,
              lib_name: lib_name,
              lib_version: lib_version,
            )

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Vision::V1::Credentials.new(credentials).updater_proc
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

            package_version = Gem.loaded_specs['google-cloud-vision'].version.version

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/#{package_version} gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            headers.merge!(metadata) unless metadata.nil?
            client_config_file = Pathname.new(__dir__).join(
              "product_search_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.cloud.vision.v1.ProductSearch",
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
            @product_search_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Cloud::Vision::V1::ProductSearch::Stub.method(:new)
            )

            @create_product = Google::Gax.create_api_call(
              @product_search_stub.method(:create_product),
              defaults["create_product"],
              exception_transformer: exception_transformer
            )
            @list_products = Google::Gax.create_api_call(
              @product_search_stub.method(:list_products),
              defaults["list_products"],
              exception_transformer: exception_transformer
            )
            @get_product = Google::Gax.create_api_call(
              @product_search_stub.method(:get_product),
              defaults["get_product"],
              exception_transformer: exception_transformer
            )
            @update_product = Google::Gax.create_api_call(
              @product_search_stub.method(:update_product),
              defaults["update_product"],
              exception_transformer: exception_transformer
            )
            @delete_product = Google::Gax.create_api_call(
              @product_search_stub.method(:delete_product),
              defaults["delete_product"],
              exception_transformer: exception_transformer
            )
            @list_reference_images = Google::Gax.create_api_call(
              @product_search_stub.method(:list_reference_images),
              defaults["list_reference_images"],
              exception_transformer: exception_transformer
            )
            @get_reference_image = Google::Gax.create_api_call(
              @product_search_stub.method(:get_reference_image),
              defaults["get_reference_image"],
              exception_transformer: exception_transformer
            )
            @delete_reference_image = Google::Gax.create_api_call(
              @product_search_stub.method(:delete_reference_image),
              defaults["delete_reference_image"],
              exception_transformer: exception_transformer
            )
            @create_reference_image = Google::Gax.create_api_call(
              @product_search_stub.method(:create_reference_image),
              defaults["create_reference_image"],
              exception_transformer: exception_transformer
            )
            @create_product_set = Google::Gax.create_api_call(
              @product_search_stub.method(:create_product_set),
              defaults["create_product_set"],
              exception_transformer: exception_transformer
            )
            @list_product_sets = Google::Gax.create_api_call(
              @product_search_stub.method(:list_product_sets),
              defaults["list_product_sets"],
              exception_transformer: exception_transformer
            )
            @get_product_set = Google::Gax.create_api_call(
              @product_search_stub.method(:get_product_set),
              defaults["get_product_set"],
              exception_transformer: exception_transformer
            )
            @update_product_set = Google::Gax.create_api_call(
              @product_search_stub.method(:update_product_set),
              defaults["update_product_set"],
              exception_transformer: exception_transformer
            )
            @delete_product_set = Google::Gax.create_api_call(
              @product_search_stub.method(:delete_product_set),
              defaults["delete_product_set"],
              exception_transformer: exception_transformer
            )
            @add_product_to_product_set = Google::Gax.create_api_call(
              @product_search_stub.method(:add_product_to_product_set),
              defaults["add_product_to_product_set"],
              exception_transformer: exception_transformer
            )
            @remove_product_from_product_set = Google::Gax.create_api_call(
              @product_search_stub.method(:remove_product_from_product_set),
              defaults["remove_product_from_product_set"],
              exception_transformer: exception_transformer
            )
            @list_products_in_product_set = Google::Gax.create_api_call(
              @product_search_stub.method(:list_products_in_product_set),
              defaults["list_products_in_product_set"],
              exception_transformer: exception_transformer
            )
            @import_product_sets = Google::Gax.create_api_call(
              @product_search_stub.method(:import_product_sets),
              defaults["import_product_sets"],
              exception_transformer: exception_transformer
            )
          end

          # Service calls

          # Creates and returns a new product resource.
          #
          # Possible errors:
          #
          # * Returns INVALID_ARGUMENT if display_name is missing or longer than 4096
          #   characters.
          # * Returns INVALID_ARGUMENT if description is longer than 4096 characters.
          # * Returns INVALID_ARGUMENT if product_category is missing or invalid.
          #
          # @param parent [String]
          #   The project in which the Product should be created.
          #
          #   Format is
          #   `projects/PROJECT_ID/locations/LOC_ID`.
          # @param product [Google::Cloud::Vision::V1::Product | Hash]
          #   The product to create.
          #   A hash of the same form as `Google::Cloud::Vision::V1::Product`
          #   can also be provided.
          # @param product_id [String]
          #   A user-supplied resource id for this Product. If set, the server will
          #   attempt to use this value as the resource id. If it is already in use, an
          #   error is returned with code ALREADY_EXISTS. Must be at most 128 characters
          #   long. It cannot contain the character `/`.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Vision::V1::Product]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Vision::V1::Product]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/vision"
          #
          #   product_search_client = Google::Cloud::Vision::ProductSearch.new(version: :v1)
          #   formatted_parent = Google::Cloud::Vision::V1::ProductSearchClient.location_path("[PROJECT]", "[LOCATION]")
          #
          #   # TODO: Initialize `product`:
          #   product = {}
          #   response = product_search_client.create_product(formatted_parent, product)

          def create_product \
              parent,
              product,
              product_id: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              product: product,
              product_id: product_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Vision::V1::CreateProductRequest)
            @create_product.call(req, options, &block)
          end

          # Lists products in an unspecified order.
          #
          # Possible errors:
          #
          # * Returns INVALID_ARGUMENT if page_size is greater than 100 or less than 1.
          #
          # @param parent [String]
          #   The project OR ProductSet from which Products should be listed.
          #
          #   Format:
          #   `projects/PROJECT_ID/locations/LOC_ID`
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::Vision::V1::Product>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::Vision::V1::Product>]
          #   An enumerable of Google::Cloud::Vision::V1::Product instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/vision"
          #
          #   product_search_client = Google::Cloud::Vision::ProductSearch.new(version: :v1)
          #   formatted_parent = Google::Cloud::Vision::V1::ProductSearchClient.location_path("[PROJECT]", "[LOCATION]")
          #
          #   # Iterate over all results.
          #   product_search_client.list_products(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   product_search_client.list_products(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_products \
              parent,
              page_size: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Vision::V1::ListProductsRequest)
            @list_products.call(req, options, &block)
          end

          # Gets information associated with a Product.
          #
          # Possible errors:
          #
          # * Returns NOT_FOUND if the Product does not exist.
          #
          # @param name [String]
          #   Resource name of the Product to get.
          #
          #   Format is:
          #   `projects/PROJECT_ID/locations/LOC_ID/products/PRODUCT_ID`
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Vision::V1::Product]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Vision::V1::Product]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/vision"
          #
          #   product_search_client = Google::Cloud::Vision::ProductSearch.new(version: :v1)
          #   formatted_name = Google::Cloud::Vision::V1::ProductSearchClient.product_path("[PROJECT]", "[LOCATION]", "[PRODUCT]")
          #   response = product_search_client.get_product(formatted_name)

          def get_product \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Vision::V1::GetProductRequest)
            @get_product.call(req, options, &block)
          end

          # Makes changes to a Product resource.
          # Only the `display_name`, `description`, and `labels` fields can be updated
          # right now.
          #
          # If labels are updated, the change will not be reflected in queries until
          # the next index time.
          #
          # Possible errors:
          #
          # * Returns NOT_FOUND if the Product does not exist.
          # * Returns INVALID_ARGUMENT if display_name is present in update_mask but is
          #   missing from the request or longer than 4096 characters.
          # * Returns INVALID_ARGUMENT if description is present in update_mask but is
          #   longer than 4096 characters.
          # * Returns INVALID_ARGUMENT if product_category is present in update_mask.
          #
          # @param product [Google::Cloud::Vision::V1::Product | Hash]
          #   The Product resource which replaces the one on the server.
          #   product.name is immutable.
          #   A hash of the same form as `Google::Cloud::Vision::V1::Product`
          #   can also be provided.
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   The {Google::Protobuf::FieldMask FieldMask} that specifies which fields
          #   to update.
          #   If update_mask isn't specified, all mutable fields are to be updated.
          #   Valid mask paths include `product_labels`, `display_name`, and
          #   `description`.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Vision::V1::Product]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Vision::V1::Product]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/vision"
          #
          #   product_search_client = Google::Cloud::Vision::ProductSearch.new(version: :v1)
          #
          #   # TODO: Initialize `product`:
          #   product = {}
          #   response = product_search_client.update_product(product)

          def update_product \
              product,
              update_mask: nil,
              options: nil,
              &block
            req = {
              product: product,
              update_mask: update_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Vision::V1::UpdateProductRequest)
            @update_product.call(req, options, &block)
          end

          # Permanently deletes a product and its reference images.
          #
          # Metadata of the product and all its images will be deleted right away, but
          # search queries against ProductSets containing the product may still work
          # until all related caches are refreshed.
          #
          # Possible errors:
          #
          # * Returns NOT_FOUND if the product does not exist.
          #
          # @param name [String]
          #   Resource name of product to delete.
          #
          #   Format is:
          #   `projects/PROJECT_ID/locations/LOC_ID/products/PRODUCT_ID`
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/vision"
          #
          #   product_search_client = Google::Cloud::Vision::ProductSearch.new(version: :v1)
          #   formatted_name = Google::Cloud::Vision::V1::ProductSearchClient.product_path("[PROJECT]", "[LOCATION]", "[PRODUCT]")
          #   product_search_client.delete_product(formatted_name)

          def delete_product \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Vision::V1::DeleteProductRequest)
            @delete_product.call(req, options, &block)
            nil
          end

          # Lists reference images.
          #
          # Possible errors:
          #
          # * Returns NOT_FOUND if the parent product does not exist.
          # * Returns INVALID_ARGUMENT if the page_size is greater than 100, or less
          #   than 1.
          #
          # @param parent [String]
          #   Resource name of the product containing the reference images.
          #
          #   Format is
          #   `projects/PROJECT_ID/locations/LOC_ID/products/PRODUCT_ID`.
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::Vision::V1::ReferenceImage>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::Vision::V1::ReferenceImage>]
          #   An enumerable of Google::Cloud::Vision::V1::ReferenceImage instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/vision"
          #
          #   product_search_client = Google::Cloud::Vision::ProductSearch.new(version: :v1)
          #   formatted_parent = Google::Cloud::Vision::V1::ProductSearchClient.product_path("[PROJECT]", "[LOCATION]", "[PRODUCT]")
          #
          #   # Iterate over all results.
          #   product_search_client.list_reference_images(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   product_search_client.list_reference_images(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_reference_images \
              parent,
              page_size: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Vision::V1::ListReferenceImagesRequest)
            @list_reference_images.call(req, options, &block)
          end

          # Gets information associated with a ReferenceImage.
          #
          # Possible errors:
          #
          # * Returns NOT_FOUND if the specified image does not exist.
          #
          # @param name [String]
          #   The resource name of the ReferenceImage to get.
          #
          #   Format is:
          #
          #   `projects/PROJECT_ID/locations/LOC_ID/products/PRODUCT_ID/referenceImages/IMAGE_ID`.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Vision::V1::ReferenceImage]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Vision::V1::ReferenceImage]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/vision"
          #
          #   product_search_client = Google::Cloud::Vision::ProductSearch.new(version: :v1)
          #   formatted_name = Google::Cloud::Vision::V1::ProductSearchClient.reference_image_path("[PROJECT]", "[LOCATION]", "[PRODUCT]", "[REFERENCE_IMAGE]")
          #   response = product_search_client.get_reference_image(formatted_name)

          def get_reference_image \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Vision::V1::GetReferenceImageRequest)
            @get_reference_image.call(req, options, &block)
          end

          # Permanently deletes a reference image.
          #
          # The image metadata will be deleted right away, but search queries
          # against ProductSets containing the image may still work until all related
          # caches are refreshed.
          #
          # The actual image files are not deleted from Google Cloud Storage.
          #
          # Possible errors:
          #
          # * Returns NOT_FOUND if the reference image does not exist.
          #
          # @param name [String]
          #   The resource name of the reference image to delete.
          #
          #   Format is:
          #
          #   `projects/PROJECT_ID/locations/LOC_ID/products/PRODUCT_ID/referenceImages/IMAGE_ID`
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/vision"
          #
          #   product_search_client = Google::Cloud::Vision::ProductSearch.new(version: :v1)
          #   formatted_name = Google::Cloud::Vision::V1::ProductSearchClient.reference_image_path("[PROJECT]", "[LOCATION]", "[PRODUCT]", "[REFERENCE_IMAGE]")
          #   product_search_client.delete_reference_image(formatted_name)

          def delete_reference_image \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Vision::V1::DeleteReferenceImageRequest)
            @delete_reference_image.call(req, options, &block)
            nil
          end

          # Creates and returns a new ReferenceImage resource.
          #
          # The `bounding_poly` field is optional. If `bounding_poly` is not specified,
          # the system will try to detect regions of interest in the image that are
          # compatible with the product_category on the parent product. If it is
          # specified, detection is ALWAYS skipped. The system converts polygons into
          # non-rotated rectangles.
          #
          # Note that the pipeline will resize the image if the image resolution is too
          # large to process (above 50MP).
          #
          # Possible errors:
          #
          # * Returns INVALID_ARGUMENT if the image_uri is missing or longer than 4096
          #   characters.
          # * Returns INVALID_ARGUMENT if the product does not exist.
          # * Returns INVALID_ARGUMENT if bounding_poly is not provided, and nothing
          #   compatible with the parent product's product_category is detected.
          # * Returns INVALID_ARGUMENT if bounding_poly contains more than 10 polygons.
          #
          # @param parent [String]
          #   Resource name of the product in which to create the reference image.
          #
          #   Format is
          #   `projects/PROJECT_ID/locations/LOC_ID/products/PRODUCT_ID`.
          # @param reference_image [Google::Cloud::Vision::V1::ReferenceImage | Hash]
          #   The reference image to create.
          #   If an image ID is specified, it is ignored.
          #   A hash of the same form as `Google::Cloud::Vision::V1::ReferenceImage`
          #   can also be provided.
          # @param reference_image_id [String]
          #   A user-supplied resource id for the ReferenceImage to be added. If set,
          #   the server will attempt to use this value as the resource id. If it is
          #   already in use, an error is returned with code ALREADY_EXISTS. Must be at
          #   most 128 characters long. It cannot contain the character `/`.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Vision::V1::ReferenceImage]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Vision::V1::ReferenceImage]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/vision"
          #
          #   product_search_client = Google::Cloud::Vision::ProductSearch.new(version: :v1)
          #   formatted_parent = Google::Cloud::Vision::V1::ProductSearchClient.product_path("[PROJECT]", "[LOCATION]", "[PRODUCT]")
          #
          #   # TODO: Initialize `reference_image`:
          #   reference_image = {}
          #   response = product_search_client.create_reference_image(formatted_parent, reference_image)

          def create_reference_image \
              parent,
              reference_image,
              reference_image_id: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              reference_image: reference_image,
              reference_image_id: reference_image_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Vision::V1::CreateReferenceImageRequest)
            @create_reference_image.call(req, options, &block)
          end

          # Creates and returns a new ProductSet resource.
          #
          # Possible errors:
          #
          # * Returns INVALID_ARGUMENT if display_name is missing, or is longer than
          #   4096 characters.
          #
          # @param parent [String]
          #   The project in which the ProductSet should be created.
          #
          #   Format is `projects/PROJECT_ID/locations/LOC_ID`.
          # @param product_set [Google::Cloud::Vision::V1::ProductSet | Hash]
          #   The ProductSet to create.
          #   A hash of the same form as `Google::Cloud::Vision::V1::ProductSet`
          #   can also be provided.
          # @param product_set_id [String]
          #   A user-supplied resource id for this ProductSet. If set, the server will
          #   attempt to use this value as the resource id. If it is already in use, an
          #   error is returned with code ALREADY_EXISTS. Must be at most 128 characters
          #   long. It cannot contain the character `/`.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Vision::V1::ProductSet]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Vision::V1::ProductSet]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/vision"
          #
          #   product_search_client = Google::Cloud::Vision::ProductSearch.new(version: :v1)
          #   formatted_parent = Google::Cloud::Vision::V1::ProductSearchClient.location_path("[PROJECT]", "[LOCATION]")
          #
          #   # TODO: Initialize `product_set`:
          #   product_set = {}
          #   response = product_search_client.create_product_set(formatted_parent, product_set)

          def create_product_set \
              parent,
              product_set,
              product_set_id: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              product_set: product_set,
              product_set_id: product_set_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Vision::V1::CreateProductSetRequest)
            @create_product_set.call(req, options, &block)
          end

          # Lists ProductSets in an unspecified order.
          #
          # Possible errors:
          #
          # * Returns INVALID_ARGUMENT if page_size is greater than 100, or less
          #   than 1.
          #
          # @param parent [String]
          #   The project from which ProductSets should be listed.
          #
          #   Format is `projects/PROJECT_ID/locations/LOC_ID`.
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::Vision::V1::ProductSet>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::Vision::V1::ProductSet>]
          #   An enumerable of Google::Cloud::Vision::V1::ProductSet instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/vision"
          #
          #   product_search_client = Google::Cloud::Vision::ProductSearch.new(version: :v1)
          #   formatted_parent = Google::Cloud::Vision::V1::ProductSearchClient.location_path("[PROJECT]", "[LOCATION]")
          #
          #   # Iterate over all results.
          #   product_search_client.list_product_sets(formatted_parent).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   product_search_client.list_product_sets(formatted_parent).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_product_sets \
              parent,
              page_size: nil,
              options: nil,
              &block
            req = {
              parent: parent,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Vision::V1::ListProductSetsRequest)
            @list_product_sets.call(req, options, &block)
          end

          # Gets information associated with a ProductSet.
          #
          # Possible errors:
          #
          # * Returns NOT_FOUND if the ProductSet does not exist.
          #
          # @param name [String]
          #   Resource name of the ProductSet to get.
          #
          #   Format is:
          #   `projects/PROJECT_ID/locations/LOG_ID/productSets/PRODUCT_SET_ID`
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Vision::V1::ProductSet]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Vision::V1::ProductSet]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/vision"
          #
          #   product_search_client = Google::Cloud::Vision::ProductSearch.new(version: :v1)
          #   formatted_name = Google::Cloud::Vision::V1::ProductSearchClient.product_set_path("[PROJECT]", "[LOCATION]", "[PRODUCT_SET]")
          #   response = product_search_client.get_product_set(formatted_name)

          def get_product_set \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Vision::V1::GetProductSetRequest)
            @get_product_set.call(req, options, &block)
          end

          # Makes changes to a ProductSet resource.
          # Only display_name can be updated currently.
          #
          # Possible errors:
          #
          # * Returns NOT_FOUND if the ProductSet does not exist.
          # * Returns INVALID_ARGUMENT if display_name is present in update_mask but
          #   missing from the request or longer than 4096 characters.
          #
          # @param product_set [Google::Cloud::Vision::V1::ProductSet | Hash]
          #   The ProductSet resource which replaces the one on the server.
          #   A hash of the same form as `Google::Cloud::Vision::V1::ProductSet`
          #   can also be provided.
          # @param update_mask [Google::Protobuf::FieldMask | Hash]
          #   The {Google::Protobuf::FieldMask FieldMask} that specifies which fields to
          #   update.
          #   If update_mask isn't specified, all mutable fields are to be updated.
          #   Valid mask path is `display_name`.
          #   A hash of the same form as `Google::Protobuf::FieldMask`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Cloud::Vision::V1::ProductSet]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Cloud::Vision::V1::ProductSet]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/vision"
          #
          #   product_search_client = Google::Cloud::Vision::ProductSearch.new(version: :v1)
          #
          #   # TODO: Initialize `product_set`:
          #   product_set = {}
          #   response = product_search_client.update_product_set(product_set)

          def update_product_set \
              product_set,
              update_mask: nil,
              options: nil,
              &block
            req = {
              product_set: product_set,
              update_mask: update_mask
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Vision::V1::UpdateProductSetRequest)
            @update_product_set.call(req, options, &block)
          end

          # Permanently deletes a ProductSet. Products and ReferenceImages in the
          # ProductSet are not deleted.
          #
          # The actual image files are not deleted from Google Cloud Storage.
          #
          # Possible errors:
          #
          # * Returns NOT_FOUND if the ProductSet does not exist.
          #
          # @param name [String]
          #   Resource name of the ProductSet to delete.
          #
          #   Format is:
          #   `projects/PROJECT_ID/locations/LOC_ID/productSets/PRODUCT_SET_ID`
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/vision"
          #
          #   product_search_client = Google::Cloud::Vision::ProductSearch.new(version: :v1)
          #   formatted_name = Google::Cloud::Vision::V1::ProductSearchClient.product_set_path("[PROJECT]", "[LOCATION]", "[PRODUCT_SET]")
          #   product_search_client.delete_product_set(formatted_name)

          def delete_product_set \
              name,
              options: nil,
              &block
            req = {
              name: name
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Vision::V1::DeleteProductSetRequest)
            @delete_product_set.call(req, options, &block)
            nil
          end

          # Adds a Product to the specified ProductSet. If the Product is already
          # present, no change is made.
          #
          # One Product can be added to at most 100 ProductSets.
          #
          # Possible errors:
          #
          # * Returns NOT_FOUND if the Product or the ProductSet doesn't exist.
          #
          # @param name [String]
          #   The resource name for the ProductSet to modify.
          #
          #   Format is:
          #   `projects/PROJECT_ID/locations/LOC_ID/productSets/PRODUCT_SET_ID`
          # @param product [String]
          #   The resource name for the Product to be added to this ProductSet.
          #
          #   Format is:
          #   `projects/PROJECT_ID/locations/LOC_ID/products/PRODUCT_ID`
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/vision"
          #
          #   product_search_client = Google::Cloud::Vision::ProductSearch.new(version: :v1)
          #   formatted_name = Google::Cloud::Vision::V1::ProductSearchClient.product_set_path("[PROJECT]", "[LOCATION]", "[PRODUCT_SET]")
          #
          #   # TODO: Initialize `product`:
          #   product = ''
          #   product_search_client.add_product_to_product_set(formatted_name, product)

          def add_product_to_product_set \
              name,
              product,
              options: nil,
              &block
            req = {
              name: name,
              product: product
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Vision::V1::AddProductToProductSetRequest)
            @add_product_to_product_set.call(req, options, &block)
            nil
          end

          # Removes a Product from the specified ProductSet.
          #
          # Possible errors:
          #
          # * Returns NOT_FOUND If the Product is not found under the ProductSet.
          #
          # @param name [String]
          #   The resource name for the ProductSet to modify.
          #
          #   Format is:
          #   `projects/PROJECT_ID/locations/LOC_ID/productSets/PRODUCT_SET_ID`
          # @param product [String]
          #   The resource name for the Product to be removed from this ProductSet.
          #
          #   Format is:
          #   `projects/PROJECT_ID/locations/LOC_ID/products/PRODUCT_ID`
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/vision"
          #
          #   product_search_client = Google::Cloud::Vision::ProductSearch.new(version: :v1)
          #   formatted_name = Google::Cloud::Vision::V1::ProductSearchClient.product_set_path("[PROJECT]", "[LOCATION]", "[PRODUCT_SET]")
          #
          #   # TODO: Initialize `product`:
          #   product = ''
          #   product_search_client.remove_product_from_product_set(formatted_name, product)

          def remove_product_from_product_set \
              name,
              product,
              options: nil,
              &block
            req = {
              name: name,
              product: product
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Vision::V1::RemoveProductFromProductSetRequest)
            @remove_product_from_product_set.call(req, options, &block)
            nil
          end

          # Lists the Products in a ProductSet, in an unspecified order. If the
          # ProductSet does not exist, the products field of the response will be
          # empty.
          #
          # Possible errors:
          #
          # * Returns INVALID_ARGUMENT if page_size is greater than 100 or less than 1.
          #
          # @param name [String]
          #   The ProductSet resource for which to retrieve Products.
          #
          #   Format is:
          #   `projects/PROJECT_ID/locations/LOC_ID/productSets/PRODUCT_SET_ID`
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
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Cloud::Vision::V1::Product>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Cloud::Vision::V1::Product>]
          #   An enumerable of Google::Cloud::Vision::V1::Product instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/vision"
          #
          #   product_search_client = Google::Cloud::Vision::ProductSearch.new(version: :v1)
          #   formatted_name = Google::Cloud::Vision::V1::ProductSearchClient.product_set_path("[PROJECT]", "[LOCATION]", "[PRODUCT_SET]")
          #
          #   # Iterate over all results.
          #   product_search_client.list_products_in_product_set(formatted_name).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   product_search_client.list_products_in_product_set(formatted_name).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_products_in_product_set \
              name,
              page_size: nil,
              options: nil,
              &block
            req = {
              name: name,
              page_size: page_size
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Vision::V1::ListProductsInProductSetRequest)
            @list_products_in_product_set.call(req, options, &block)
          end

          # Asynchronous API that imports a list of reference images to specified
          # product sets based on a list of image information.
          #
          # The {Google::Longrunning::Operation} API can be used to keep track of the
          # progress and results of the request.
          # `Operation.metadata` contains `BatchOperationMetadata`. (progress)
          # `Operation.response` contains `ImportProductSetsResponse`. (results)
          #
          # The input source of this method is a csv file on Google Cloud Storage.
          # For the format of the csv file please see
          # {Google::Cloud::Vision::V1::ImportProductSetsGcsSource#csv_file_uri ImportProductSetsGcsSource#csv_file_uri}.
          #
          # @param parent [String]
          #   The project in which the ProductSets should be imported.
          #
          #   Format is `projects/PROJECT_ID/locations/LOC_ID`.
          # @param input_config [Google::Cloud::Vision::V1::ImportProductSetsInputConfig | Hash]
          #   The input content for the list of requests.
          #   A hash of the same form as `Google::Cloud::Vision::V1::ImportProductSetsInputConfig`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @return [Google::Gax::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/vision"
          #
          #   product_search_client = Google::Cloud::Vision::ProductSearch.new(version: :v1)
          #   formatted_parent = Google::Cloud::Vision::V1::ProductSearchClient.location_path("[PROJECT]", "[LOCATION]")
          #
          #   # TODO: Initialize `input_config`:
          #   input_config = {}
          #
          #   # Register a callback during the method call.
          #   operation = product_search_client.import_product_sets(formatted_parent, input_config) do |op|
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

          def import_product_sets \
              parent,
              input_config,
              options: nil
            req = {
              parent: parent,
              input_config: input_config
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Cloud::Vision::V1::ImportProductSetsRequest)
            operation = Google::Gax::Operation.new(
              @import_product_sets.call(req, options),
              @operations_client,
              Google::Cloud::Vision::V1::ImportProductSetsResponse,
              Google::Cloud::Vision::V1::BatchOperationMetadata,
              call_options: options
            )
            operation.on_done { |operation| yield(operation) } if block_given?
            operation
          end
        end
      end
    end
  end
end
