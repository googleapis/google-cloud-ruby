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

require "helper"

require "google/gax"

require "google/cloud/irm"
require "google/cloud/irm/v1alpha2/incident_service_client"
require "google/cloud/irm/v1alpha2/incidents_service_services_pb"

class CustomTestError_v1alpha2 < StandardError; end

# Mock for the GRPC::ClientStub class.
class MockGrpcClientStub_v1alpha2

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

class MockIncidentServiceCredentials_v1alpha2 < Google::Cloud::Irm::V1alpha2::Credentials
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

describe Google::Cloud::Irm::V1alpha2::IncidentServiceClient do

  describe 'create_incident' do
    custom_error = CustomTestError_v1alpha2.new "Custom test error for Google::Cloud::Irm::V1alpha2::IncidentServiceClient#create_incident."

    it 'invokes create_incident without error' do
      # Create request parameters
      incident = {}
      formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.project_path("[PROJECT]")

      # Create expected grpc response
      name = "name3373707"
      title = "title110371416"
      etag = "etag3123477"
      duplicate_incident = "duplicateIncident-316496506"
      expected_response = {
        name: name,
        title: title,
        etag: etag,
        duplicate_incident: duplicate_incident
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Irm::V1alpha2::Incident)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::CreateIncidentRequest, request)
        assert_equal(Google::Gax::to_proto(incident, Google::Cloud::Irm::V1alpha2::Incident), request.incident)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:create_incident, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("create_incident")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          response = client.create_incident(incident, formatted_parent)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_incident(incident, formatted_parent) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_incident with error' do
      # Create request parameters
      incident = {}
      formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.project_path("[PROJECT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::CreateIncidentRequest, request)
        assert_equal(Google::Gax::to_proto(incident, Google::Cloud::Irm::V1alpha2::Incident), request.incident)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:create_incident, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("create_incident")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha2 do
            client.create_incident(incident, formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_incident' do
    custom_error = CustomTestError_v1alpha2.new "Custom test error for Google::Cloud::Irm::V1alpha2::IncidentServiceClient#get_incident."

    it 'invokes get_incident without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path("[PROJECT]", "[INCIDENT]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      title = "title110371416"
      etag = "etag3123477"
      duplicate_incident = "duplicateIncident-316496506"
      expected_response = {
        name: name_2,
        title: title,
        etag: etag,
        duplicate_incident: duplicate_incident
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Irm::V1alpha2::Incident)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::GetIncidentRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:get_incident, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("get_incident")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          response = client.get_incident(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_incident(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_incident with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path("[PROJECT]", "[INCIDENT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::GetIncidentRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:get_incident, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("get_incident")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha2 do
            client.get_incident(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'search_incidents' do
    custom_error = CustomTestError_v1alpha2.new "Custom test error for Google::Cloud::Irm::V1alpha2::IncidentServiceClient#search_incidents."

    it 'invokes search_incidents without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.project_path("[PROJECT]")

      # Create expected grpc response
      next_page_token = ""
      incidents_element = {}
      incidents = [incidents_element]
      expected_response = { next_page_token: next_page_token, incidents: incidents }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Irm::V1alpha2::SearchIncidentsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::SearchIncidentsRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:search_incidents, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("search_incidents")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          response = client.search_incidents(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.incidents.to_a, response.to_a)
        end
      end
    end

    it 'invokes search_incidents with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.project_path("[PROJECT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::SearchIncidentsRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:search_incidents, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("search_incidents")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha2 do
            client.search_incidents(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_incident' do
    custom_error = CustomTestError_v1alpha2.new "Custom test error for Google::Cloud::Irm::V1alpha2::IncidentServiceClient#update_incident."

    it 'invokes update_incident without error' do
      # Create request parameters
      incident = {}

      # Create expected grpc response
      name = "name3373707"
      title = "title110371416"
      etag = "etag3123477"
      duplicate_incident = "duplicateIncident-316496506"
      expected_response = {
        name: name,
        title: title,
        etag: etag,
        duplicate_incident: duplicate_incident
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Irm::V1alpha2::Incident)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::UpdateIncidentRequest, request)
        assert_equal(Google::Gax::to_proto(incident, Google::Cloud::Irm::V1alpha2::Incident), request.incident)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:update_incident, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("update_incident")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          response = client.update_incident(incident)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_incident(incident) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_incident with error' do
      # Create request parameters
      incident = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::UpdateIncidentRequest, request)
        assert_equal(Google::Gax::to_proto(incident, Google::Cloud::Irm::V1alpha2::Incident), request.incident)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:update_incident, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("update_incident")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha2 do
            client.update_incident(incident)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'search_similar_incidents' do
    custom_error = CustomTestError_v1alpha2.new "Custom test error for Google::Cloud::Irm::V1alpha2::IncidentServiceClient#search_similar_incidents."

    it 'invokes search_similar_incidents without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path("[PROJECT]", "[INCIDENT]")

      # Create expected grpc response
      next_page_token = ""
      results_element = {}
      results = [results_element]
      expected_response = { next_page_token: next_page_token, results: results }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Irm::V1alpha2::SearchSimilarIncidentsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::SearchSimilarIncidentsRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:search_similar_incidents, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("search_similar_incidents")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          response = client.search_similar_incidents(formatted_name)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.results.to_a, response.to_a)
        end
      end
    end

    it 'invokes search_similar_incidents with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path("[PROJECT]", "[INCIDENT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::SearchSimilarIncidentsRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:search_similar_incidents, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("search_similar_incidents")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha2 do
            client.search_similar_incidents(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_annotation' do
    custom_error = CustomTestError_v1alpha2.new "Custom test error for Google::Cloud::Irm::V1alpha2::IncidentServiceClient#create_annotation."

    it 'invokes create_annotation without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path("[PROJECT]", "[INCIDENT]")
      annotation = {}

      # Create expected grpc response
      name = "name3373707"
      content = "content951530617"
      content_type = "contentType831846208"
      expected_response = {
        name: name,
        content: content,
        content_type: content_type
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Irm::V1alpha2::Annotation)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::CreateAnnotationRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(annotation, Google::Cloud::Irm::V1alpha2::Annotation), request.annotation)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:create_annotation, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("create_annotation")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          response = client.create_annotation(formatted_parent, annotation)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_annotation(formatted_parent, annotation) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_annotation with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path("[PROJECT]", "[INCIDENT]")
      annotation = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::CreateAnnotationRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(annotation, Google::Cloud::Irm::V1alpha2::Annotation), request.annotation)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:create_annotation, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("create_annotation")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha2 do
            client.create_annotation(formatted_parent, annotation)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_annotations' do
    custom_error = CustomTestError_v1alpha2.new "Custom test error for Google::Cloud::Irm::V1alpha2::IncidentServiceClient#list_annotations."

    it 'invokes list_annotations without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path("[PROJECT]", "[INCIDENT]")

      # Create expected grpc response
      next_page_token = ""
      annotations_element = {}
      annotations = [annotations_element]
      expected_response = { next_page_token: next_page_token, annotations: annotations }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Irm::V1alpha2::ListAnnotationsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::ListAnnotationsRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:list_annotations, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("list_annotations")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          response = client.list_annotations(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.annotations.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_annotations with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path("[PROJECT]", "[INCIDENT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::ListAnnotationsRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:list_annotations, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("list_annotations")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha2 do
            client.list_annotations(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_tag' do
    custom_error = CustomTestError_v1alpha2.new "Custom test error for Google::Cloud::Irm::V1alpha2::IncidentServiceClient#create_tag."

    it 'invokes create_tag without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path("[PROJECT]", "[INCIDENT]")
      tag = {}

      # Create expected grpc response
      name = "name3373707"
      display_name = "displayName1615086568"
      expected_response = { name: name, display_name: display_name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Irm::V1alpha2::Tag)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::CreateTagRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(tag, Google::Cloud::Irm::V1alpha2::Tag), request.tag)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:create_tag, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("create_tag")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          response = client.create_tag(formatted_parent, tag)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_tag(formatted_parent, tag) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_tag with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path("[PROJECT]", "[INCIDENT]")
      tag = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::CreateTagRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(tag, Google::Cloud::Irm::V1alpha2::Tag), request.tag)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:create_tag, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("create_tag")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha2 do
            client.create_tag(formatted_parent, tag)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_tag' do
    custom_error = CustomTestError_v1alpha2.new "Custom test error for Google::Cloud::Irm::V1alpha2::IncidentServiceClient#delete_tag."

    it 'invokes delete_tag without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.tag_path("[PROJECT]", "[INCIDENT]", "[TAG]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::DeleteTagRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:delete_tag, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("delete_tag")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          response = client.delete_tag(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_tag(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_tag with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.tag_path("[PROJECT]", "[INCIDENT]", "[TAG]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::DeleteTagRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:delete_tag, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("delete_tag")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha2 do
            client.delete_tag(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_tags' do
    custom_error = CustomTestError_v1alpha2.new "Custom test error for Google::Cloud::Irm::V1alpha2::IncidentServiceClient#list_tags."

    it 'invokes list_tags without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path("[PROJECT]", "[INCIDENT]")

      # Create expected grpc response
      next_page_token = ""
      tags_element = {}
      tags = [tags_element]
      expected_response = { next_page_token: next_page_token, tags: tags }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Irm::V1alpha2::ListTagsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::ListTagsRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:list_tags, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("list_tags")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          response = client.list_tags(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.tags.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_tags with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path("[PROJECT]", "[INCIDENT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::ListTagsRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:list_tags, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("list_tags")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha2 do
            client.list_tags(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_signal' do
    custom_error = CustomTestError_v1alpha2.new "Custom test error for Google::Cloud::Irm::V1alpha2::IncidentServiceClient#create_signal."

    it 'invokes create_signal without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.project_path("[PROJECT]")
      signal = {}

      # Create expected grpc response
      name = "name3373707"
      etag = "etag3123477"
      incident = "incident86983890"
      title = "title110371416"
      content_type = "contentType831846208"
      content = "content951530617"
      expected_response = {
        name: name,
        etag: etag,
        incident: incident,
        title: title,
        content_type: content_type,
        content: content
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Irm::V1alpha2::Signal)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::CreateSignalRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(signal, Google::Cloud::Irm::V1alpha2::Signal), request.signal)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:create_signal, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("create_signal")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          response = client.create_signal(formatted_parent, signal)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_signal(formatted_parent, signal) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_signal with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.project_path("[PROJECT]")
      signal = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::CreateSignalRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(signal, Google::Cloud::Irm::V1alpha2::Signal), request.signal)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:create_signal, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("create_signal")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha2 do
            client.create_signal(formatted_parent, signal)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'search_signals' do
    custom_error = CustomTestError_v1alpha2.new "Custom test error for Google::Cloud::Irm::V1alpha2::IncidentServiceClient#search_signals."

    it 'invokes search_signals without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.project_path("[PROJECT]")

      # Create expected grpc response
      next_page_token = ""
      signals_element = {}
      signals = [signals_element]
      expected_response = { next_page_token: next_page_token, signals: signals }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Irm::V1alpha2::SearchSignalsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::SearchSignalsRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:search_signals, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("search_signals")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          response = client.search_signals(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.signals.to_a, response.to_a)
        end
      end
    end

    it 'invokes search_signals with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.project_path("[PROJECT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::SearchSignalsRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:search_signals, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("search_signals")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha2 do
            client.search_signals(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_signal' do
    custom_error = CustomTestError_v1alpha2.new "Custom test error for Google::Cloud::Irm::V1alpha2::IncidentServiceClient#get_signal."

    it 'invokes get_signal without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.signal_path("[PROJECT]", "[SIGNAL]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      etag = "etag3123477"
      incident = "incident86983890"
      title = "title110371416"
      content_type = "contentType831846208"
      content = "content951530617"
      expected_response = {
        name: name_2,
        etag: etag,
        incident: incident,
        title: title,
        content_type: content_type,
        content: content
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Irm::V1alpha2::Signal)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::GetSignalRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:get_signal, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("get_signal")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          response = client.get_signal(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_signal(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_signal with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.signal_path("[PROJECT]", "[SIGNAL]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::GetSignalRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:get_signal, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("get_signal")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha2 do
            client.get_signal(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'lookup_signal' do
    custom_error = CustomTestError_v1alpha2.new "Custom test error for Google::Cloud::Irm::V1alpha2::IncidentServiceClient#lookup_signal."

    it 'invokes lookup_signal without error' do
      # Create expected grpc response
      name = "name3373707"
      etag = "etag3123477"
      incident = "incident86983890"
      title = "title110371416"
      content_type = "contentType831846208"
      content = "content951530617"
      expected_response = {
        name: name,
        etag: etag,
        incident: incident,
        title: title,
        content_type: content_type,
        content: content
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Irm::V1alpha2::Signal)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:lookup_signal, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("lookup_signal")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          response = client.lookup_signal

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.lookup_signal do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes lookup_signal with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:lookup_signal, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("lookup_signal")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha2 do
            client.lookup_signal
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_signal' do
    custom_error = CustomTestError_v1alpha2.new "Custom test error for Google::Cloud::Irm::V1alpha2::IncidentServiceClient#update_signal."

    it 'invokes update_signal without error' do
      # Create request parameters
      signal = {}

      # Create expected grpc response
      name = "name3373707"
      etag = "etag3123477"
      incident = "incident86983890"
      title = "title110371416"
      content_type = "contentType831846208"
      content = "content951530617"
      expected_response = {
        name: name,
        etag: etag,
        incident: incident,
        title: title,
        content_type: content_type,
        content: content
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Irm::V1alpha2::Signal)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::UpdateSignalRequest, request)
        assert_equal(Google::Gax::to_proto(signal, Google::Cloud::Irm::V1alpha2::Signal), request.signal)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:update_signal, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("update_signal")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          response = client.update_signal(signal)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_signal(signal) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_signal with error' do
      # Create request parameters
      signal = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::UpdateSignalRequest, request)
        assert_equal(Google::Gax::to_proto(signal, Google::Cloud::Irm::V1alpha2::Signal), request.signal)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:update_signal, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("update_signal")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha2 do
            client.update_signal(signal)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'escalate_incident' do
    custom_error = CustomTestError_v1alpha2.new "Custom test error for Google::Cloud::Irm::V1alpha2::IncidentServiceClient#escalate_incident."

    it 'invokes escalate_incident without error' do
      # Create request parameters
      incident = {}

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Irm::V1alpha2::EscalateIncidentResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::EscalateIncidentRequest, request)
        assert_equal(Google::Gax::to_proto(incident, Google::Cloud::Irm::V1alpha2::Incident), request.incident)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:escalate_incident, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("escalate_incident")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          response = client.escalate_incident(incident)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.escalate_incident(incident) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes escalate_incident with error' do
      # Create request parameters
      incident = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::EscalateIncidentRequest, request)
        assert_equal(Google::Gax::to_proto(incident, Google::Cloud::Irm::V1alpha2::Incident), request.incident)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:escalate_incident, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("escalate_incident")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha2 do
            client.escalate_incident(incident)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_artifact' do
    custom_error = CustomTestError_v1alpha2.new "Custom test error for Google::Cloud::Irm::V1alpha2::IncidentServiceClient#create_artifact."

    it 'invokes create_artifact without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path("[PROJECT]", "[INCIDENT]")
      artifact = {}

      # Create expected grpc response
      name = "name3373707"
      display_name = "displayName1615086568"
      etag = "etag3123477"
      url = "url116079"
      expected_response = {
        name: name,
        display_name: display_name,
        etag: etag,
        url: url
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Irm::V1alpha2::Artifact)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::CreateArtifactRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(artifact, Google::Cloud::Irm::V1alpha2::Artifact), request.artifact)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:create_artifact, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("create_artifact")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          response = client.create_artifact(formatted_parent, artifact)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_artifact(formatted_parent, artifact) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_artifact with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path("[PROJECT]", "[INCIDENT]")
      artifact = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::CreateArtifactRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(artifact, Google::Cloud::Irm::V1alpha2::Artifact), request.artifact)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:create_artifact, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("create_artifact")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha2 do
            client.create_artifact(formatted_parent, artifact)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_artifacts' do
    custom_error = CustomTestError_v1alpha2.new "Custom test error for Google::Cloud::Irm::V1alpha2::IncidentServiceClient#list_artifacts."

    it 'invokes list_artifacts without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path("[PROJECT]", "[INCIDENT]")

      # Create expected grpc response
      next_page_token = ""
      artifacts_element = {}
      artifacts = [artifacts_element]
      expected_response = { next_page_token: next_page_token, artifacts: artifacts }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Irm::V1alpha2::ListArtifactsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::ListArtifactsRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:list_artifacts, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("list_artifacts")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          response = client.list_artifacts(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.artifacts.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_artifacts with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path("[PROJECT]", "[INCIDENT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::ListArtifactsRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:list_artifacts, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("list_artifacts")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha2 do
            client.list_artifacts(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_artifact' do
    custom_error = CustomTestError_v1alpha2.new "Custom test error for Google::Cloud::Irm::V1alpha2::IncidentServiceClient#update_artifact."

    it 'invokes update_artifact without error' do
      # Create request parameters
      artifact = {}

      # Create expected grpc response
      name = "name3373707"
      display_name = "displayName1615086568"
      etag = "etag3123477"
      url = "url116079"
      expected_response = {
        name: name,
        display_name: display_name,
        etag: etag,
        url: url
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Irm::V1alpha2::Artifact)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::UpdateArtifactRequest, request)
        assert_equal(Google::Gax::to_proto(artifact, Google::Cloud::Irm::V1alpha2::Artifact), request.artifact)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:update_artifact, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("update_artifact")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          response = client.update_artifact(artifact)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_artifact(artifact) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_artifact with error' do
      # Create request parameters
      artifact = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::UpdateArtifactRequest, request)
        assert_equal(Google::Gax::to_proto(artifact, Google::Cloud::Irm::V1alpha2::Artifact), request.artifact)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:update_artifact, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("update_artifact")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha2 do
            client.update_artifact(artifact)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_artifact' do
    custom_error = CustomTestError_v1alpha2.new "Custom test error for Google::Cloud::Irm::V1alpha2::IncidentServiceClient#delete_artifact."

    it 'invokes delete_artifact without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.artifact_path("[PROJECT]", "[INCIDENT]", "[ARTIFACT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::DeleteArtifactRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:delete_artifact, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("delete_artifact")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          response = client.delete_artifact(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_artifact(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_artifact with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.artifact_path("[PROJECT]", "[INCIDENT]", "[ARTIFACT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::DeleteArtifactRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:delete_artifact, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("delete_artifact")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha2 do
            client.delete_artifact(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'send_shift_handoff' do
    custom_error = CustomTestError_v1alpha2.new "Custom test error for Google::Cloud::Irm::V1alpha2::IncidentServiceClient#send_shift_handoff."

    it 'invokes send_shift_handoff without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.project_path("[PROJECT]")
      recipients = []
      subject = ''

      # Create expected grpc response
      content_type = "contentType831846208"
      content = "content951530617"
      expected_response = { content_type: content_type, content: content }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Irm::V1alpha2::SendShiftHandoffResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::SendShiftHandoffRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(recipients, request.recipients)
        assert_equal(subject, request.subject)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:send_shift_handoff, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("send_shift_handoff")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          response = client.send_shift_handoff(
            formatted_parent,
            recipients,
            subject
          )

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.send_shift_handoff(
            formatted_parent,
            recipients,
            subject
          ) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes send_shift_handoff with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.project_path("[PROJECT]")
      recipients = []
      subject = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::SendShiftHandoffRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(recipients, request.recipients)
        assert_equal(subject, request.subject)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:send_shift_handoff, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("send_shift_handoff")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha2 do
            client.send_shift_handoff(
              formatted_parent,
              recipients,
              subject
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_subscription' do
    custom_error = CustomTestError_v1alpha2.new "Custom test error for Google::Cloud::Irm::V1alpha2::IncidentServiceClient#create_subscription."

    it 'invokes create_subscription without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path("[PROJECT]", "[INCIDENT]")
      subscription = {}

      # Create expected grpc response
      name = "name3373707"
      etag = "etag3123477"
      expected_response = { name: name, etag: etag }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Irm::V1alpha2::Subscription)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::CreateSubscriptionRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(subscription, Google::Cloud::Irm::V1alpha2::Subscription), request.subscription)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:create_subscription, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("create_subscription")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          response = client.create_subscription(formatted_parent, subscription)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_subscription(formatted_parent, subscription) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_subscription with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path("[PROJECT]", "[INCIDENT]")
      subscription = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::CreateSubscriptionRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(subscription, Google::Cloud::Irm::V1alpha2::Subscription), request.subscription)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:create_subscription, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("create_subscription")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha2 do
            client.create_subscription(formatted_parent, subscription)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_subscription' do
    custom_error = CustomTestError_v1alpha2.new "Custom test error for Google::Cloud::Irm::V1alpha2::IncidentServiceClient#update_subscription."

    it 'invokes update_subscription without error' do
      # Create request parameters
      subscription = {}

      # Create expected grpc response
      name = "name3373707"
      etag = "etag3123477"
      expected_response = { name: name, etag: etag }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Irm::V1alpha2::Subscription)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::UpdateSubscriptionRequest, request)
        assert_equal(Google::Gax::to_proto(subscription, Google::Cloud::Irm::V1alpha2::Subscription), request.subscription)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:update_subscription, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("update_subscription")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          response = client.update_subscription(subscription)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_subscription(subscription) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_subscription with error' do
      # Create request parameters
      subscription = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::UpdateSubscriptionRequest, request)
        assert_equal(Google::Gax::to_proto(subscription, Google::Cloud::Irm::V1alpha2::Subscription), request.subscription)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:update_subscription, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("update_subscription")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha2 do
            client.update_subscription(subscription)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_subscriptions' do
    custom_error = CustomTestError_v1alpha2.new "Custom test error for Google::Cloud::Irm::V1alpha2::IncidentServiceClient#list_subscriptions."

    it 'invokes list_subscriptions without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path("[PROJECT]", "[INCIDENT]")

      # Create expected grpc response
      next_page_token = ""
      subscriptions_element = {}
      subscriptions = [subscriptions_element]
      expected_response = { next_page_token: next_page_token, subscriptions: subscriptions }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Irm::V1alpha2::ListSubscriptionsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::ListSubscriptionsRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:list_subscriptions, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("list_subscriptions")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          response = client.list_subscriptions(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.subscriptions.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_subscriptions with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path("[PROJECT]", "[INCIDENT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::ListSubscriptionsRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:list_subscriptions, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("list_subscriptions")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha2 do
            client.list_subscriptions(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_subscription' do
    custom_error = CustomTestError_v1alpha2.new "Custom test error for Google::Cloud::Irm::V1alpha2::IncidentServiceClient#delete_subscription."

    it 'invokes delete_subscription without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.subscription_path("[PROJECT]", "[INCIDENT]", "[SUBSCRIPTION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::DeleteSubscriptionRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:delete_subscription, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("delete_subscription")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          response = client.delete_subscription(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_subscription(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_subscription with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.subscription_path("[PROJECT]", "[INCIDENT]", "[SUBSCRIPTION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::DeleteSubscriptionRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:delete_subscription, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("delete_subscription")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha2 do
            client.delete_subscription(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_incident_role_assignment' do
    custom_error = CustomTestError_v1alpha2.new "Custom test error for Google::Cloud::Irm::V1alpha2::IncidentServiceClient#create_incident_role_assignment."

    it 'invokes create_incident_role_assignment without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path("[PROJECT]", "[INCIDENT]")
      incident_role_assignment = {}

      # Create expected grpc response
      name = "name3373707"
      etag = "etag3123477"
      expected_response = { name: name, etag: etag }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Irm::V1alpha2::IncidentRoleAssignment)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::CreateIncidentRoleAssignmentRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(incident_role_assignment, Google::Cloud::Irm::V1alpha2::IncidentRoleAssignment), request.incident_role_assignment)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:create_incident_role_assignment, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("create_incident_role_assignment")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          response = client.create_incident_role_assignment(formatted_parent, incident_role_assignment)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_incident_role_assignment(formatted_parent, incident_role_assignment) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_incident_role_assignment with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path("[PROJECT]", "[INCIDENT]")
      incident_role_assignment = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::CreateIncidentRoleAssignmentRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(incident_role_assignment, Google::Cloud::Irm::V1alpha2::IncidentRoleAssignment), request.incident_role_assignment)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:create_incident_role_assignment, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("create_incident_role_assignment")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha2 do
            client.create_incident_role_assignment(formatted_parent, incident_role_assignment)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_incident_role_assignment' do
    custom_error = CustomTestError_v1alpha2.new "Custom test error for Google::Cloud::Irm::V1alpha2::IncidentServiceClient#delete_incident_role_assignment."

    it 'invokes delete_incident_role_assignment without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.role_assignment_path("[PROJECT]", "[INCIDENT]", "[ROLE_ASSIGNMENT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::DeleteIncidentRoleAssignmentRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:delete_incident_role_assignment, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("delete_incident_role_assignment")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          response = client.delete_incident_role_assignment(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_incident_role_assignment(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_incident_role_assignment with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.role_assignment_path("[PROJECT]", "[INCIDENT]", "[ROLE_ASSIGNMENT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::DeleteIncidentRoleAssignmentRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:delete_incident_role_assignment, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("delete_incident_role_assignment")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha2 do
            client.delete_incident_role_assignment(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_incident_role_assignments' do
    custom_error = CustomTestError_v1alpha2.new "Custom test error for Google::Cloud::Irm::V1alpha2::IncidentServiceClient#list_incident_role_assignments."

    it 'invokes list_incident_role_assignments without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path("[PROJECT]", "[INCIDENT]")

      # Create expected grpc response
      next_page_token = ""
      incident_role_assignments_element = {}
      incident_role_assignments = [incident_role_assignments_element]
      expected_response = { next_page_token: next_page_token, incident_role_assignments: incident_role_assignments }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Irm::V1alpha2::ListIncidentRoleAssignmentsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::ListIncidentRoleAssignmentsRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:list_incident_role_assignments, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("list_incident_role_assignments")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          response = client.list_incident_role_assignments(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.incident_role_assignments.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_incident_role_assignments with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path("[PROJECT]", "[INCIDENT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::ListIncidentRoleAssignmentsRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:list_incident_role_assignments, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("list_incident_role_assignments")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha2 do
            client.list_incident_role_assignments(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'request_incident_role_handover' do
    custom_error = CustomTestError_v1alpha2.new "Custom test error for Google::Cloud::Irm::V1alpha2::IncidentServiceClient#request_incident_role_handover."

    it 'invokes request_incident_role_handover without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.role_assignment_path("[PROJECT]", "[INCIDENT]", "[ROLE_ASSIGNMENT]")
      new_assignee = {}

      # Create expected grpc response
      name_2 = "name2-1052831874"
      etag = "etag3123477"
      expected_response = { name: name_2, etag: etag }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Irm::V1alpha2::IncidentRoleAssignment)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::RequestIncidentRoleHandoverRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(new_assignee, Google::Cloud::Irm::V1alpha2::User), request.new_assignee)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:request_incident_role_handover, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("request_incident_role_handover")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          response = client.request_incident_role_handover(formatted_name, new_assignee)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.request_incident_role_handover(formatted_name, new_assignee) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes request_incident_role_handover with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.role_assignment_path("[PROJECT]", "[INCIDENT]", "[ROLE_ASSIGNMENT]")
      new_assignee = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::RequestIncidentRoleHandoverRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(new_assignee, Google::Cloud::Irm::V1alpha2::User), request.new_assignee)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:request_incident_role_handover, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("request_incident_role_handover")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha2 do
            client.request_incident_role_handover(formatted_name, new_assignee)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'confirm_incident_role_handover' do
    custom_error = CustomTestError_v1alpha2.new "Custom test error for Google::Cloud::Irm::V1alpha2::IncidentServiceClient#confirm_incident_role_handover."

    it 'invokes confirm_incident_role_handover without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.role_assignment_path("[PROJECT]", "[INCIDENT]", "[ROLE_ASSIGNMENT]")
      new_assignee = {}

      # Create expected grpc response
      name_2 = "name2-1052831874"
      etag = "etag3123477"
      expected_response = { name: name_2, etag: etag }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Irm::V1alpha2::IncidentRoleAssignment)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::ConfirmIncidentRoleHandoverRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(new_assignee, Google::Cloud::Irm::V1alpha2::User), request.new_assignee)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:confirm_incident_role_handover, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("confirm_incident_role_handover")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          response = client.confirm_incident_role_handover(formatted_name, new_assignee)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.confirm_incident_role_handover(formatted_name, new_assignee) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes confirm_incident_role_handover with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.role_assignment_path("[PROJECT]", "[INCIDENT]", "[ROLE_ASSIGNMENT]")
      new_assignee = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::ConfirmIncidentRoleHandoverRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(new_assignee, Google::Cloud::Irm::V1alpha2::User), request.new_assignee)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:confirm_incident_role_handover, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("confirm_incident_role_handover")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha2 do
            client.confirm_incident_role_handover(formatted_name, new_assignee)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'force_incident_role_handover' do
    custom_error = CustomTestError_v1alpha2.new "Custom test error for Google::Cloud::Irm::V1alpha2::IncidentServiceClient#force_incident_role_handover."

    it 'invokes force_incident_role_handover without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.role_assignment_path("[PROJECT]", "[INCIDENT]", "[ROLE_ASSIGNMENT]")
      new_assignee = {}

      # Create expected grpc response
      name_2 = "name2-1052831874"
      etag = "etag3123477"
      expected_response = { name: name_2, etag: etag }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Irm::V1alpha2::IncidentRoleAssignment)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::ForceIncidentRoleHandoverRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(new_assignee, Google::Cloud::Irm::V1alpha2::User), request.new_assignee)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:force_incident_role_handover, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("force_incident_role_handover")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          response = client.force_incident_role_handover(formatted_name, new_assignee)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.force_incident_role_handover(formatted_name, new_assignee) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes force_incident_role_handover with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.role_assignment_path("[PROJECT]", "[INCIDENT]", "[ROLE_ASSIGNMENT]")
      new_assignee = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::ForceIncidentRoleHandoverRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(new_assignee, Google::Cloud::Irm::V1alpha2::User), request.new_assignee)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:force_incident_role_handover, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("force_incident_role_handover")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha2 do
            client.force_incident_role_handover(formatted_name, new_assignee)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'cancel_incident_role_handover' do
    custom_error = CustomTestError_v1alpha2.new "Custom test error for Google::Cloud::Irm::V1alpha2::IncidentServiceClient#cancel_incident_role_handover."

    it 'invokes cancel_incident_role_handover without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.role_assignment_path("[PROJECT]", "[INCIDENT]", "[ROLE_ASSIGNMENT]")
      new_assignee = {}

      # Create expected grpc response
      name_2 = "name2-1052831874"
      etag = "etag3123477"
      expected_response = { name: name_2, etag: etag }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Irm::V1alpha2::IncidentRoleAssignment)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::CancelIncidentRoleHandoverRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(new_assignee, Google::Cloud::Irm::V1alpha2::User), request.new_assignee)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:cancel_incident_role_handover, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("cancel_incident_role_handover")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          response = client.cancel_incident_role_handover(formatted_name, new_assignee)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.cancel_incident_role_handover(formatted_name, new_assignee) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes cancel_incident_role_handover with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Irm::V1alpha2::IncidentServiceClient.role_assignment_path("[PROJECT]", "[INCIDENT]", "[ROLE_ASSIGNMENT]")
      new_assignee = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Irm::V1alpha2::CancelIncidentRoleHandoverRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(new_assignee, Google::Cloud::Irm::V1alpha2::User), request.new_assignee)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha2.new(:cancel_incident_role_handover, mock_method)

      # Mock auth layer
      mock_credentials = MockIncidentServiceCredentials_v1alpha2.new("cancel_incident_role_handover")

      Google::Cloud::Irm::V1alpha2::IncidentService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Irm::V1alpha2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Irm.new(version: :v1alpha2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha2 do
            client.cancel_incident_role_handover(formatted_name, new_assignee)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end
