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

require "minitest/autorun"
require "minitest/spec"

require "google/gax"

require "google/cloud/vision"
require "google/cloud/vision/v1/product_search_client"
require "google/cloud/vision/v1/product_search_service_services_pb"
require "google/longrunning/operations_pb"

class CustomTestError_v1 < StandardError; end

# Mock for the GRPC::ClientStub class.
class MockGrpcClientStub_v1

  # @param expected_symbol [Symbol] the symbol of the grpc method to be mocked.
  # @param mock_method [Proc] The method that is being mocked.
  def initialize(expected_symbol, mock_method)
    @expected_symbol = expected_symbol
    @mock_method = mock_method
  end

  # This overrides the Object#method method to return the mocked method when the mocked method
  # is being requested. For methods that aren't being tested, this method returns a proc that
  # will raise an error when called. This is to assure that only the mocked grpc method is being
  # called.
  #
  # @param symbol [Symbol] The symbol of the method being requested.
  # @return [Proc] The proc of the requested method. If the requested method is not being mocked
  #   the proc returned will raise when called.
  def method(symbol)
    return @mock_method if symbol == @expected_symbol

    # The requested method is not being tested, raise if it called.
    proc do
      raise "The method #{symbol} was unexpectedly called during the " \
        "test for #{@expected_symbol}."
    end
  end
end

class MockProductSearchCredentials_v1 < Google::Cloud::Vision::V1::Credentials
  def initialize(method_name)
    @method_name = method_name
  end

  def updater_proc
    proc do
      raise "The method `#{@method_name}` was trying to make a grpc request. This should not " \
          "happen since the grpc layer is being mocked."
    end
  end
end

describe Google::Cloud::Vision::V1::ProductSearchClient do

  describe 'create_product' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Vision::V1::ProductSearchClient#create_product."

    it 'invokes create_product without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Vision::V1::ProductSearchClient.location_path("[PROJECT]", "[LOCATION]")
      product = {}

      # Create expected grpc response
      name = "name3373707"
      display_name = "displayName1615086568"
      description = "description-1724546052"
      product_category = "productCategory-1607451058"
      expected_response = {
        name: name,
        display_name: display_name,
        description: description,
        product_category: product_category
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Vision::V1::Product)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Vision::V1::CreateProductRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(product, Google::Cloud::Vision::V1::Product), request.product)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:create_product, mock_method)

      # Mock auth layer
      mock_credentials = MockProductSearchCredentials_v1.new("create_product")

      Google::Cloud::Vision::V1::ProductSearch::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision::ProductSearch.new(version: :v1)

          # Call method
          response = client.create_product(formatted_parent, product)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_product(formatted_parent, product) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_product with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Vision::V1::ProductSearchClient.location_path("[PROJECT]", "[LOCATION]")
      product = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Vision::V1::CreateProductRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(product, Google::Cloud::Vision::V1::Product), request.product)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:create_product, mock_method)

      # Mock auth layer
      mock_credentials = MockProductSearchCredentials_v1.new("create_product")

      Google::Cloud::Vision::V1::ProductSearch::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision::ProductSearch.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.create_product(formatted_parent, product)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_products' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Vision::V1::ProductSearchClient#list_products."

    it 'invokes list_products without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Vision::V1::ProductSearchClient.location_path("[PROJECT]", "[LOCATION]")

      # Create expected grpc response
      next_page_token = ""
      products_element = {}
      products = [products_element]
      expected_response = { next_page_token: next_page_token, products: products }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Vision::V1::ListProductsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Vision::V1::ListProductsRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_products, mock_method)

      # Mock auth layer
      mock_credentials = MockProductSearchCredentials_v1.new("list_products")

      Google::Cloud::Vision::V1::ProductSearch::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision::ProductSearch.new(version: :v1)

          # Call method
          response = client.list_products(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.products.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_products with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Vision::V1::ProductSearchClient.location_path("[PROJECT]", "[LOCATION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Vision::V1::ListProductsRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_products, mock_method)

      # Mock auth layer
      mock_credentials = MockProductSearchCredentials_v1.new("list_products")

      Google::Cloud::Vision::V1::ProductSearch::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision::ProductSearch.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_products(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_product' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Vision::V1::ProductSearchClient#get_product."

    it 'invokes get_product without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Vision::V1::ProductSearchClient.product_path("[PROJECT]", "[LOCATION]", "[PRODUCT]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      display_name = "displayName1615086568"
      description = "description-1724546052"
      product_category = "productCategory-1607451058"
      expected_response = {
        name: name_2,
        display_name: display_name,
        description: description,
        product_category: product_category
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Vision::V1::Product)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Vision::V1::GetProductRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_product, mock_method)

      # Mock auth layer
      mock_credentials = MockProductSearchCredentials_v1.new("get_product")

      Google::Cloud::Vision::V1::ProductSearch::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision::ProductSearch.new(version: :v1)

          # Call method
          response = client.get_product(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_product(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_product with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Vision::V1::ProductSearchClient.product_path("[PROJECT]", "[LOCATION]", "[PRODUCT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Vision::V1::GetProductRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_product, mock_method)

      # Mock auth layer
      mock_credentials = MockProductSearchCredentials_v1.new("get_product")

      Google::Cloud::Vision::V1::ProductSearch::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision::ProductSearch.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_product(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_product' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Vision::V1::ProductSearchClient#update_product."

    it 'invokes update_product without error' do
      # Create request parameters
      product = {}

      # Create expected grpc response
      name = "name3373707"
      display_name = "displayName1615086568"
      description = "description-1724546052"
      product_category = "productCategory-1607451058"
      expected_response = {
        name: name,
        display_name: display_name,
        description: description,
        product_category: product_category
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Vision::V1::Product)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Vision::V1::UpdateProductRequest, request)
        assert_equal(Google::Gax::to_proto(product, Google::Cloud::Vision::V1::Product), request.product)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_product, mock_method)

      # Mock auth layer
      mock_credentials = MockProductSearchCredentials_v1.new("update_product")

      Google::Cloud::Vision::V1::ProductSearch::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision::ProductSearch.new(version: :v1)

          # Call method
          response = client.update_product(product)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_product(product) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_product with error' do
      # Create request parameters
      product = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Vision::V1::UpdateProductRequest, request)
        assert_equal(Google::Gax::to_proto(product, Google::Cloud::Vision::V1::Product), request.product)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_product, mock_method)

      # Mock auth layer
      mock_credentials = MockProductSearchCredentials_v1.new("update_product")

      Google::Cloud::Vision::V1::ProductSearch::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision::ProductSearch.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.update_product(product)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_product' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Vision::V1::ProductSearchClient#delete_product."

    it 'invokes delete_product without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Vision::V1::ProductSearchClient.product_path("[PROJECT]", "[LOCATION]", "[PRODUCT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Vision::V1::DeleteProductRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v1.new(:delete_product, mock_method)

      # Mock auth layer
      mock_credentials = MockProductSearchCredentials_v1.new("delete_product")

      Google::Cloud::Vision::V1::ProductSearch::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision::ProductSearch.new(version: :v1)

          # Call method
          response = client.delete_product(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_product(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_product with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Vision::V1::ProductSearchClient.product_path("[PROJECT]", "[LOCATION]", "[PRODUCT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Vision::V1::DeleteProductRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:delete_product, mock_method)

      # Mock auth layer
      mock_credentials = MockProductSearchCredentials_v1.new("delete_product")

      Google::Cloud::Vision::V1::ProductSearch::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision::ProductSearch.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.delete_product(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_reference_images' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Vision::V1::ProductSearchClient#list_reference_images."

    it 'invokes list_reference_images without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Vision::V1::ProductSearchClient.product_path("[PROJECT]", "[LOCATION]", "[PRODUCT]")

      # Create expected grpc response
      page_size = 883849137
      next_page_token = ""
      reference_images_element = {}
      reference_images = [reference_images_element]
      expected_response = {
        page_size: page_size,
        next_page_token: next_page_token,
        reference_images: reference_images
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Vision::V1::ListReferenceImagesResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Vision::V1::ListReferenceImagesRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_reference_images, mock_method)

      # Mock auth layer
      mock_credentials = MockProductSearchCredentials_v1.new("list_reference_images")

      Google::Cloud::Vision::V1::ProductSearch::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision::ProductSearch.new(version: :v1)

          # Call method
          response = client.list_reference_images(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.reference_images.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_reference_images with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Vision::V1::ProductSearchClient.product_path("[PROJECT]", "[LOCATION]", "[PRODUCT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Vision::V1::ListReferenceImagesRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_reference_images, mock_method)

      # Mock auth layer
      mock_credentials = MockProductSearchCredentials_v1.new("list_reference_images")

      Google::Cloud::Vision::V1::ProductSearch::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision::ProductSearch.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_reference_images(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_reference_image' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Vision::V1::ProductSearchClient#get_reference_image."

    it 'invokes get_reference_image without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Vision::V1::ProductSearchClient.reference_image_path("[PROJECT]", "[LOCATION]", "[PRODUCT]", "[REFERENCE_IMAGE]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      uri = "uri116076"
      expected_response = { name: name_2, uri: uri }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Vision::V1::ReferenceImage)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Vision::V1::GetReferenceImageRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_reference_image, mock_method)

      # Mock auth layer
      mock_credentials = MockProductSearchCredentials_v1.new("get_reference_image")

      Google::Cloud::Vision::V1::ProductSearch::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision::ProductSearch.new(version: :v1)

          # Call method
          response = client.get_reference_image(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_reference_image(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_reference_image with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Vision::V1::ProductSearchClient.reference_image_path("[PROJECT]", "[LOCATION]", "[PRODUCT]", "[REFERENCE_IMAGE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Vision::V1::GetReferenceImageRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_reference_image, mock_method)

      # Mock auth layer
      mock_credentials = MockProductSearchCredentials_v1.new("get_reference_image")

      Google::Cloud::Vision::V1::ProductSearch::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision::ProductSearch.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_reference_image(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_reference_image' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Vision::V1::ProductSearchClient#delete_reference_image."

    it 'invokes delete_reference_image without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Vision::V1::ProductSearchClient.reference_image_path("[PROJECT]", "[LOCATION]", "[PRODUCT]", "[REFERENCE_IMAGE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Vision::V1::DeleteReferenceImageRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v1.new(:delete_reference_image, mock_method)

      # Mock auth layer
      mock_credentials = MockProductSearchCredentials_v1.new("delete_reference_image")

      Google::Cloud::Vision::V1::ProductSearch::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision::ProductSearch.new(version: :v1)

          # Call method
          response = client.delete_reference_image(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_reference_image(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_reference_image with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Vision::V1::ProductSearchClient.reference_image_path("[PROJECT]", "[LOCATION]", "[PRODUCT]", "[REFERENCE_IMAGE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Vision::V1::DeleteReferenceImageRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:delete_reference_image, mock_method)

      # Mock auth layer
      mock_credentials = MockProductSearchCredentials_v1.new("delete_reference_image")

      Google::Cloud::Vision::V1::ProductSearch::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision::ProductSearch.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.delete_reference_image(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_reference_image' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Vision::V1::ProductSearchClient#create_reference_image."

    it 'invokes create_reference_image without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Vision::V1::ProductSearchClient.product_path("[PROJECT]", "[LOCATION]", "[PRODUCT]")
      reference_image = {}

      # Create expected grpc response
      name = "name3373707"
      uri = "uri116076"
      expected_response = { name: name, uri: uri }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Vision::V1::ReferenceImage)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Vision::V1::CreateReferenceImageRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(reference_image, Google::Cloud::Vision::V1::ReferenceImage), request.reference_image)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:create_reference_image, mock_method)

      # Mock auth layer
      mock_credentials = MockProductSearchCredentials_v1.new("create_reference_image")

      Google::Cloud::Vision::V1::ProductSearch::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision::ProductSearch.new(version: :v1)

          # Call method
          response = client.create_reference_image(formatted_parent, reference_image)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_reference_image(formatted_parent, reference_image) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_reference_image with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Vision::V1::ProductSearchClient.product_path("[PROJECT]", "[LOCATION]", "[PRODUCT]")
      reference_image = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Vision::V1::CreateReferenceImageRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(reference_image, Google::Cloud::Vision::V1::ReferenceImage), request.reference_image)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:create_reference_image, mock_method)

      # Mock auth layer
      mock_credentials = MockProductSearchCredentials_v1.new("create_reference_image")

      Google::Cloud::Vision::V1::ProductSearch::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision::ProductSearch.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.create_reference_image(formatted_parent, reference_image)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_product_set' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Vision::V1::ProductSearchClient#create_product_set."

    it 'invokes create_product_set without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Vision::V1::ProductSearchClient.location_path("[PROJECT]", "[LOCATION]")
      product_set = {}

      # Create expected grpc response
      name = "name3373707"
      display_name = "displayName1615086568"
      expected_response = { name: name, display_name: display_name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Vision::V1::ProductSet)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Vision::V1::CreateProductSetRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(product_set, Google::Cloud::Vision::V1::ProductSet), request.product_set)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:create_product_set, mock_method)

      # Mock auth layer
      mock_credentials = MockProductSearchCredentials_v1.new("create_product_set")

      Google::Cloud::Vision::V1::ProductSearch::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision::ProductSearch.new(version: :v1)

          # Call method
          response = client.create_product_set(formatted_parent, product_set)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_product_set(formatted_parent, product_set) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_product_set with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Vision::V1::ProductSearchClient.location_path("[PROJECT]", "[LOCATION]")
      product_set = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Vision::V1::CreateProductSetRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(product_set, Google::Cloud::Vision::V1::ProductSet), request.product_set)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:create_product_set, mock_method)

      # Mock auth layer
      mock_credentials = MockProductSearchCredentials_v1.new("create_product_set")

      Google::Cloud::Vision::V1::ProductSearch::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision::ProductSearch.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.create_product_set(formatted_parent, product_set)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_product_sets' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Vision::V1::ProductSearchClient#list_product_sets."

    it 'invokes list_product_sets without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Vision::V1::ProductSearchClient.location_path("[PROJECT]", "[LOCATION]")

      # Create expected grpc response
      next_page_token = ""
      product_sets_element = {}
      product_sets = [product_sets_element]
      expected_response = { next_page_token: next_page_token, product_sets: product_sets }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Vision::V1::ListProductSetsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Vision::V1::ListProductSetsRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_product_sets, mock_method)

      # Mock auth layer
      mock_credentials = MockProductSearchCredentials_v1.new("list_product_sets")

      Google::Cloud::Vision::V1::ProductSearch::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision::ProductSearch.new(version: :v1)

          # Call method
          response = client.list_product_sets(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.product_sets.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_product_sets with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Vision::V1::ProductSearchClient.location_path("[PROJECT]", "[LOCATION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Vision::V1::ListProductSetsRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_product_sets, mock_method)

      # Mock auth layer
      mock_credentials = MockProductSearchCredentials_v1.new("list_product_sets")

      Google::Cloud::Vision::V1::ProductSearch::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision::ProductSearch.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_product_sets(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_product_set' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Vision::V1::ProductSearchClient#get_product_set."

    it 'invokes get_product_set without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Vision::V1::ProductSearchClient.product_set_path("[PROJECT]", "[LOCATION]", "[PRODUCT_SET]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      display_name = "displayName1615086568"
      expected_response = { name: name_2, display_name: display_name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Vision::V1::ProductSet)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Vision::V1::GetProductSetRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_product_set, mock_method)

      # Mock auth layer
      mock_credentials = MockProductSearchCredentials_v1.new("get_product_set")

      Google::Cloud::Vision::V1::ProductSearch::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision::ProductSearch.new(version: :v1)

          # Call method
          response = client.get_product_set(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_product_set(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_product_set with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Vision::V1::ProductSearchClient.product_set_path("[PROJECT]", "[LOCATION]", "[PRODUCT_SET]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Vision::V1::GetProductSetRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_product_set, mock_method)

      # Mock auth layer
      mock_credentials = MockProductSearchCredentials_v1.new("get_product_set")

      Google::Cloud::Vision::V1::ProductSearch::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision::ProductSearch.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_product_set(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_product_set' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Vision::V1::ProductSearchClient#update_product_set."

    it 'invokes update_product_set without error' do
      # Create request parameters
      product_set = {}

      # Create expected grpc response
      name = "name3373707"
      display_name = "displayName1615086568"
      expected_response = { name: name, display_name: display_name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Vision::V1::ProductSet)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Vision::V1::UpdateProductSetRequest, request)
        assert_equal(Google::Gax::to_proto(product_set, Google::Cloud::Vision::V1::ProductSet), request.product_set)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_product_set, mock_method)

      # Mock auth layer
      mock_credentials = MockProductSearchCredentials_v1.new("update_product_set")

      Google::Cloud::Vision::V1::ProductSearch::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision::ProductSearch.new(version: :v1)

          # Call method
          response = client.update_product_set(product_set)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_product_set(product_set) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_product_set with error' do
      # Create request parameters
      product_set = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Vision::V1::UpdateProductSetRequest, request)
        assert_equal(Google::Gax::to_proto(product_set, Google::Cloud::Vision::V1::ProductSet), request.product_set)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_product_set, mock_method)

      # Mock auth layer
      mock_credentials = MockProductSearchCredentials_v1.new("update_product_set")

      Google::Cloud::Vision::V1::ProductSearch::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision::ProductSearch.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.update_product_set(product_set)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_product_set' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Vision::V1::ProductSearchClient#delete_product_set."

    it 'invokes delete_product_set without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Vision::V1::ProductSearchClient.product_set_path("[PROJECT]", "[LOCATION]", "[PRODUCT_SET]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Vision::V1::DeleteProductSetRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v1.new(:delete_product_set, mock_method)

      # Mock auth layer
      mock_credentials = MockProductSearchCredentials_v1.new("delete_product_set")

      Google::Cloud::Vision::V1::ProductSearch::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision::ProductSearch.new(version: :v1)

          # Call method
          response = client.delete_product_set(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_product_set(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_product_set with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Vision::V1::ProductSearchClient.product_set_path("[PROJECT]", "[LOCATION]", "[PRODUCT_SET]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Vision::V1::DeleteProductSetRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:delete_product_set, mock_method)

      # Mock auth layer
      mock_credentials = MockProductSearchCredentials_v1.new("delete_product_set")

      Google::Cloud::Vision::V1::ProductSearch::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision::ProductSearch.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.delete_product_set(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'add_product_to_product_set' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Vision::V1::ProductSearchClient#add_product_to_product_set."

    it 'invokes add_product_to_product_set without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Vision::V1::ProductSearchClient.product_set_path("[PROJECT]", "[LOCATION]", "[PRODUCT_SET]")
      product = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Vision::V1::AddProductToProductSetRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(product, request.product)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v1.new(:add_product_to_product_set, mock_method)

      # Mock auth layer
      mock_credentials = MockProductSearchCredentials_v1.new("add_product_to_product_set")

      Google::Cloud::Vision::V1::ProductSearch::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision::ProductSearch.new(version: :v1)

          # Call method
          response = client.add_product_to_product_set(formatted_name, product)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.add_product_to_product_set(formatted_name, product) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes add_product_to_product_set with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Vision::V1::ProductSearchClient.product_set_path("[PROJECT]", "[LOCATION]", "[PRODUCT_SET]")
      product = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Vision::V1::AddProductToProductSetRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(product, request.product)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:add_product_to_product_set, mock_method)

      # Mock auth layer
      mock_credentials = MockProductSearchCredentials_v1.new("add_product_to_product_set")

      Google::Cloud::Vision::V1::ProductSearch::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision::ProductSearch.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.add_product_to_product_set(formatted_name, product)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'remove_product_from_product_set' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Vision::V1::ProductSearchClient#remove_product_from_product_set."

    it 'invokes remove_product_from_product_set without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Vision::V1::ProductSearchClient.product_set_path("[PROJECT]", "[LOCATION]", "[PRODUCT_SET]")
      product = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Vision::V1::RemoveProductFromProductSetRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(product, request.product)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v1.new(:remove_product_from_product_set, mock_method)

      # Mock auth layer
      mock_credentials = MockProductSearchCredentials_v1.new("remove_product_from_product_set")

      Google::Cloud::Vision::V1::ProductSearch::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision::ProductSearch.new(version: :v1)

          # Call method
          response = client.remove_product_from_product_set(formatted_name, product)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.remove_product_from_product_set(formatted_name, product) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes remove_product_from_product_set with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Vision::V1::ProductSearchClient.product_set_path("[PROJECT]", "[LOCATION]", "[PRODUCT_SET]")
      product = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Vision::V1::RemoveProductFromProductSetRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(product, request.product)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:remove_product_from_product_set, mock_method)

      # Mock auth layer
      mock_credentials = MockProductSearchCredentials_v1.new("remove_product_from_product_set")

      Google::Cloud::Vision::V1::ProductSearch::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision::ProductSearch.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.remove_product_from_product_set(formatted_name, product)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_products_in_product_set' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Vision::V1::ProductSearchClient#list_products_in_product_set."

    it 'invokes list_products_in_product_set without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Vision::V1::ProductSearchClient.product_set_path("[PROJECT]", "[LOCATION]", "[PRODUCT_SET]")

      # Create expected grpc response
      next_page_token = ""
      products_element = {}
      products = [products_element]
      expected_response = { next_page_token: next_page_token, products: products }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Vision::V1::ListProductsInProductSetResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Vision::V1::ListProductsInProductSetRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_products_in_product_set, mock_method)

      # Mock auth layer
      mock_credentials = MockProductSearchCredentials_v1.new("list_products_in_product_set")

      Google::Cloud::Vision::V1::ProductSearch::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision::ProductSearch.new(version: :v1)

          # Call method
          response = client.list_products_in_product_set(formatted_name)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.products.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_products_in_product_set with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Vision::V1::ProductSearchClient.product_set_path("[PROJECT]", "[LOCATION]", "[PRODUCT_SET]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Vision::V1::ListProductsInProductSetRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_products_in_product_set, mock_method)

      # Mock auth layer
      mock_credentials = MockProductSearchCredentials_v1.new("list_products_in_product_set")

      Google::Cloud::Vision::V1::ProductSearch::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision::ProductSearch.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_products_in_product_set(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'import_product_sets' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Vision::V1::ProductSearchClient#import_product_sets."

    it 'invokes import_product_sets without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Vision::V1::ProductSearchClient.location_path("[PROJECT]", "[LOCATION]")
      input_config = {}

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Vision::V1::ImportProductSetsResponse)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/import_product_sets_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Vision::V1::ImportProductSetsRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(input_config, Google::Cloud::Vision::V1::ImportProductSetsInputConfig), request.input_config)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v1.new(:import_product_sets, mock_method)

      # Mock auth layer
      mock_credentials = MockProductSearchCredentials_v1.new("import_product_sets")

      Google::Cloud::Vision::V1::ProductSearch::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision::ProductSearch.new(version: :v1)

          # Call method
          response = client.import_product_sets(formatted_parent, input_config)

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes import_product_sets and returns an operation error.' do
      # Create request parameters
      formatted_parent = Google::Cloud::Vision::V1::ProductSearchClient.location_path("[PROJECT]", "[LOCATION]")
      input_config = {}

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Vision::V1::ProductSearchClient#import_product_sets.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/import_product_sets_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Vision::V1::ImportProductSetsRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(input_config, Google::Cloud::Vision::V1::ImportProductSetsInputConfig), request.input_config)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v1.new(:import_product_sets, mock_method)

      # Mock auth layer
      mock_credentials = MockProductSearchCredentials_v1.new("import_product_sets")

      Google::Cloud::Vision::V1::ProductSearch::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision::ProductSearch.new(version: :v1)

          # Call method
          response = client.import_product_sets(formatted_parent, input_config)

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes import_product_sets with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Vision::V1::ProductSearchClient.location_path("[PROJECT]", "[LOCATION]")
      input_config = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Vision::V1::ImportProductSetsRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(input_config, Google::Cloud::Vision::V1::ImportProductSetsInputConfig), request.input_config)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:import_product_sets, mock_method)

      # Mock auth layer
      mock_credentials = MockProductSearchCredentials_v1.new("import_product_sets")

      Google::Cloud::Vision::V1::ProductSearch::Stub.stub(:new, mock_stub) do
        Google::Cloud::Vision::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Vision::ProductSearch.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.import_product_sets(formatted_parent, input_config)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end