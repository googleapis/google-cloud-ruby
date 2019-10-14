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

require "grafeas"
require "grafeas/v1/grafeas_client"
require "grafeas/v1/grafeas_services_pb"

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

class MockGrafeasCredentials_v1 < Grafeas::V1::Credentials
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

describe Grafeas::V1::GrafeasClient do

  describe 'get_occurrence' do
    custom_error = CustomTestError_v1.new "Custom test error for Grafeas::V1::GrafeasClient#get_occurrence."

    it 'invokes get_occurrence without error' do
      # Create request parameters
      formatted_name = Grafeas::V1::GrafeasClient.occurrence_path("[PROJECT]", "[OCCURRENCE]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      resource_uri = "resourceUri-384040517"
      note_name = "noteName1780787896"
      remediation = "remediation779381797"
      expected_response = {
        name: name_2,
        resource_uri: resource_uri,
        note_name: note_name,
        remediation: remediation
      }
      expected_response = Google::Gax::to_proto(expected_response, Grafeas::V1::Occurrence)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Grafeas::V1::GetOccurrenceRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_occurrence, mock_method)

      # Mock auth layer
      mock_credentials = MockGrafeasCredentials_v1.new("get_occurrence")

      Grafeas::V1::GrafeasService::Stub.stub(:new, mock_stub) do
        Grafeas::V1::Credentials.stub(:default, mock_credentials) do
          client = Grafeas.new(version: :v1)

          # Call method
          response = client.get_occurrence(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_occurrence(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_occurrence with error' do
      # Create request parameters
      formatted_name = Grafeas::V1::GrafeasClient.occurrence_path("[PROJECT]", "[OCCURRENCE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Grafeas::V1::GetOccurrenceRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_occurrence, mock_method)

      # Mock auth layer
      mock_credentials = MockGrafeasCredentials_v1.new("get_occurrence")

      Grafeas::V1::GrafeasService::Stub.stub(:new, mock_stub) do
        Grafeas::V1::Credentials.stub(:default, mock_credentials) do
          client = Grafeas.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.get_occurrence(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_occurrences' do
    custom_error = CustomTestError_v1.new "Custom test error for Grafeas::V1::GrafeasClient#list_occurrences."

    it 'invokes list_occurrences without error' do
      # Create request parameters
      formatted_parent = Grafeas::V1::GrafeasClient.project_path("[PROJECT]")

      # Create expected grpc response
      next_page_token = ""
      occurrences_element = {}
      occurrences = [occurrences_element]
      expected_response = { next_page_token: next_page_token, occurrences: occurrences }
      expected_response = Google::Gax::to_proto(expected_response, Grafeas::V1::ListOccurrencesResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Grafeas::V1::ListOccurrencesRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_occurrences, mock_method)

      # Mock auth layer
      mock_credentials = MockGrafeasCredentials_v1.new("list_occurrences")

      Grafeas::V1::GrafeasService::Stub.stub(:new, mock_stub) do
        Grafeas::V1::Credentials.stub(:default, mock_credentials) do
          client = Grafeas.new(version: :v1)

          # Call method
          response = client.list_occurrences(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.occurrences.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_occurrences with error' do
      # Create request parameters
      formatted_parent = Grafeas::V1::GrafeasClient.project_path("[PROJECT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Grafeas::V1::ListOccurrencesRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_occurrences, mock_method)

      # Mock auth layer
      mock_credentials = MockGrafeasCredentials_v1.new("list_occurrences")

      Grafeas::V1::GrafeasService::Stub.stub(:new, mock_stub) do
        Grafeas::V1::Credentials.stub(:default, mock_credentials) do
          client = Grafeas.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.list_occurrences(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_occurrence' do
    custom_error = CustomTestError_v1.new "Custom test error for Grafeas::V1::GrafeasClient#delete_occurrence."

    it 'invokes delete_occurrence without error' do
      # Create request parameters
      formatted_name = Grafeas::V1::GrafeasClient.occurrence_path("[PROJECT]", "[OCCURRENCE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Grafeas::V1::DeleteOccurrenceRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v1.new(:delete_occurrence, mock_method)

      # Mock auth layer
      mock_credentials = MockGrafeasCredentials_v1.new("delete_occurrence")

      Grafeas::V1::GrafeasService::Stub.stub(:new, mock_stub) do
        Grafeas::V1::Credentials.stub(:default, mock_credentials) do
          client = Grafeas.new(version: :v1)

          # Call method
          response = client.delete_occurrence(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_occurrence(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_occurrence with error' do
      # Create request parameters
      formatted_name = Grafeas::V1::GrafeasClient.occurrence_path("[PROJECT]", "[OCCURRENCE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Grafeas::V1::DeleteOccurrenceRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:delete_occurrence, mock_method)

      # Mock auth layer
      mock_credentials = MockGrafeasCredentials_v1.new("delete_occurrence")

      Grafeas::V1::GrafeasService::Stub.stub(:new, mock_stub) do
        Grafeas::V1::Credentials.stub(:default, mock_credentials) do
          client = Grafeas.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.delete_occurrence(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_occurrence' do
    custom_error = CustomTestError_v1.new "Custom test error for Grafeas::V1::GrafeasClient#create_occurrence."

    it 'invokes create_occurrence without error' do
      # Create request parameters
      formatted_parent = Grafeas::V1::GrafeasClient.project_path("[PROJECT]")
      occurrence = {}

      # Create expected grpc response
      name = "name3373707"
      resource_uri = "resourceUri-384040517"
      note_name = "noteName1780787896"
      remediation = "remediation779381797"
      expected_response = {
        name: name,
        resource_uri: resource_uri,
        note_name: note_name,
        remediation: remediation
      }
      expected_response = Google::Gax::to_proto(expected_response, Grafeas::V1::Occurrence)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Grafeas::V1::CreateOccurrenceRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(occurrence, Grafeas::V1::Occurrence), request.occurrence)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:create_occurrence, mock_method)

      # Mock auth layer
      mock_credentials = MockGrafeasCredentials_v1.new("create_occurrence")

      Grafeas::V1::GrafeasService::Stub.stub(:new, mock_stub) do
        Grafeas::V1::Credentials.stub(:default, mock_credentials) do
          client = Grafeas.new(version: :v1)

          # Call method
          response = client.create_occurrence(formatted_parent, occurrence)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_occurrence(formatted_parent, occurrence) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_occurrence with error' do
      # Create request parameters
      formatted_parent = Grafeas::V1::GrafeasClient.project_path("[PROJECT]")
      occurrence = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Grafeas::V1::CreateOccurrenceRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(occurrence, Grafeas::V1::Occurrence), request.occurrence)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:create_occurrence, mock_method)

      # Mock auth layer
      mock_credentials = MockGrafeasCredentials_v1.new("create_occurrence")

      Grafeas::V1::GrafeasService::Stub.stub(:new, mock_stub) do
        Grafeas::V1::Credentials.stub(:default, mock_credentials) do
          client = Grafeas.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.create_occurrence(formatted_parent, occurrence)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'batch_create_occurrences' do
    custom_error = CustomTestError_v1.new "Custom test error for Grafeas::V1::GrafeasClient#batch_create_occurrences."

    it 'invokes batch_create_occurrences without error' do
      # Create request parameters
      formatted_parent = Grafeas::V1::GrafeasClient.project_path("[PROJECT]")
      occurrences = []

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Grafeas::V1::BatchCreateOccurrencesResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Grafeas::V1::BatchCreateOccurrencesRequest, request)
        assert_equal(formatted_parent, request.parent)
        occurrences = occurrences.map do |req|
          Google::Gax::to_proto(req, Grafeas::V1::Occurrence)
        end
        assert_equal(occurrences, request.occurrences)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:batch_create_occurrences, mock_method)

      # Mock auth layer
      mock_credentials = MockGrafeasCredentials_v1.new("batch_create_occurrences")

      Grafeas::V1::GrafeasService::Stub.stub(:new, mock_stub) do
        Grafeas::V1::Credentials.stub(:default, mock_credentials) do
          client = Grafeas.new(version: :v1)

          # Call method
          response = client.batch_create_occurrences(formatted_parent, occurrences)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.batch_create_occurrences(formatted_parent, occurrences) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes batch_create_occurrences with error' do
      # Create request parameters
      formatted_parent = Grafeas::V1::GrafeasClient.project_path("[PROJECT]")
      occurrences = []

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Grafeas::V1::BatchCreateOccurrencesRequest, request)
        assert_equal(formatted_parent, request.parent)
        occurrences = occurrences.map do |req|
          Google::Gax::to_proto(req, Grafeas::V1::Occurrence)
        end
        assert_equal(occurrences, request.occurrences)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:batch_create_occurrences, mock_method)

      # Mock auth layer
      mock_credentials = MockGrafeasCredentials_v1.new("batch_create_occurrences")

      Grafeas::V1::GrafeasService::Stub.stub(:new, mock_stub) do
        Grafeas::V1::Credentials.stub(:default, mock_credentials) do
          client = Grafeas.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.batch_create_occurrences(formatted_parent, occurrences)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_occurrence' do
    custom_error = CustomTestError_v1.new "Custom test error for Grafeas::V1::GrafeasClient#update_occurrence."

    it 'invokes update_occurrence without error' do
      # Create request parameters
      formatted_name = Grafeas::V1::GrafeasClient.occurrence_path("[PROJECT]", "[OCCURRENCE]")
      occurrence = {}

      # Create expected grpc response
      name_2 = "name2-1052831874"
      resource_uri = "resourceUri-384040517"
      note_name = "noteName1780787896"
      remediation = "remediation779381797"
      expected_response = {
        name: name_2,
        resource_uri: resource_uri,
        note_name: note_name,
        remediation: remediation
      }
      expected_response = Google::Gax::to_proto(expected_response, Grafeas::V1::Occurrence)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Grafeas::V1::UpdateOccurrenceRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(occurrence, Grafeas::V1::Occurrence), request.occurrence)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_occurrence, mock_method)

      # Mock auth layer
      mock_credentials = MockGrafeasCredentials_v1.new("update_occurrence")

      Grafeas::V1::GrafeasService::Stub.stub(:new, mock_stub) do
        Grafeas::V1::Credentials.stub(:default, mock_credentials) do
          client = Grafeas.new(version: :v1)

          # Call method
          response = client.update_occurrence(formatted_name, occurrence)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_occurrence(formatted_name, occurrence) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_occurrence with error' do
      # Create request parameters
      formatted_name = Grafeas::V1::GrafeasClient.occurrence_path("[PROJECT]", "[OCCURRENCE]")
      occurrence = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Grafeas::V1::UpdateOccurrenceRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(occurrence, Grafeas::V1::Occurrence), request.occurrence)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_occurrence, mock_method)

      # Mock auth layer
      mock_credentials = MockGrafeasCredentials_v1.new("update_occurrence")

      Grafeas::V1::GrafeasService::Stub.stub(:new, mock_stub) do
        Grafeas::V1::Credentials.stub(:default, mock_credentials) do
          client = Grafeas.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.update_occurrence(formatted_name, occurrence)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_occurrence_note' do
    custom_error = CustomTestError_v1.new "Custom test error for Grafeas::V1::GrafeasClient#get_occurrence_note."

    it 'invokes get_occurrence_note without error' do
      # Create request parameters
      formatted_name = Grafeas::V1::GrafeasClient.occurrence_path("[PROJECT]", "[OCCURRENCE]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      short_description = "shortDescription-235369287"
      long_description = "longDescription-1747792199"
      expected_response = {
        name: name_2,
        short_description: short_description,
        long_description: long_description
      }
      expected_response = Google::Gax::to_proto(expected_response, Grafeas::V1::Note)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Grafeas::V1::GetOccurrenceNoteRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_occurrence_note, mock_method)

      # Mock auth layer
      mock_credentials = MockGrafeasCredentials_v1.new("get_occurrence_note")

      Grafeas::V1::GrafeasService::Stub.stub(:new, mock_stub) do
        Grafeas::V1::Credentials.stub(:default, mock_credentials) do
          client = Grafeas.new(version: :v1)

          # Call method
          response = client.get_occurrence_note(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_occurrence_note(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_occurrence_note with error' do
      # Create request parameters
      formatted_name = Grafeas::V1::GrafeasClient.occurrence_path("[PROJECT]", "[OCCURRENCE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Grafeas::V1::GetOccurrenceNoteRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_occurrence_note, mock_method)

      # Mock auth layer
      mock_credentials = MockGrafeasCredentials_v1.new("get_occurrence_note")

      Grafeas::V1::GrafeasService::Stub.stub(:new, mock_stub) do
        Grafeas::V1::Credentials.stub(:default, mock_credentials) do
          client = Grafeas.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.get_occurrence_note(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_note' do
    custom_error = CustomTestError_v1.new "Custom test error for Grafeas::V1::GrafeasClient#get_note."

    it 'invokes get_note without error' do
      # Create request parameters
      formatted_name = Grafeas::V1::GrafeasClient.note_path("[PROJECT]", "[NOTE]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      short_description = "shortDescription-235369287"
      long_description = "longDescription-1747792199"
      expected_response = {
        name: name_2,
        short_description: short_description,
        long_description: long_description
      }
      expected_response = Google::Gax::to_proto(expected_response, Grafeas::V1::Note)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Grafeas::V1::GetNoteRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_note, mock_method)

      # Mock auth layer
      mock_credentials = MockGrafeasCredentials_v1.new("get_note")

      Grafeas::V1::GrafeasService::Stub.stub(:new, mock_stub) do
        Grafeas::V1::Credentials.stub(:default, mock_credentials) do
          client = Grafeas.new(version: :v1)

          # Call method
          response = client.get_note(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_note(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_note with error' do
      # Create request parameters
      formatted_name = Grafeas::V1::GrafeasClient.note_path("[PROJECT]", "[NOTE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Grafeas::V1::GetNoteRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_note, mock_method)

      # Mock auth layer
      mock_credentials = MockGrafeasCredentials_v1.new("get_note")

      Grafeas::V1::GrafeasService::Stub.stub(:new, mock_stub) do
        Grafeas::V1::Credentials.stub(:default, mock_credentials) do
          client = Grafeas.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.get_note(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_notes' do
    custom_error = CustomTestError_v1.new "Custom test error for Grafeas::V1::GrafeasClient#list_notes."

    it 'invokes list_notes without error' do
      # Create request parameters
      formatted_parent = Grafeas::V1::GrafeasClient.project_path("[PROJECT]")

      # Create expected grpc response
      next_page_token = ""
      notes_element = {}
      notes = [notes_element]
      expected_response = { next_page_token: next_page_token, notes: notes }
      expected_response = Google::Gax::to_proto(expected_response, Grafeas::V1::ListNotesResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Grafeas::V1::ListNotesRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_notes, mock_method)

      # Mock auth layer
      mock_credentials = MockGrafeasCredentials_v1.new("list_notes")

      Grafeas::V1::GrafeasService::Stub.stub(:new, mock_stub) do
        Grafeas::V1::Credentials.stub(:default, mock_credentials) do
          client = Grafeas.new(version: :v1)

          # Call method
          response = client.list_notes(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.notes.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_notes with error' do
      # Create request parameters
      formatted_parent = Grafeas::V1::GrafeasClient.project_path("[PROJECT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Grafeas::V1::ListNotesRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_notes, mock_method)

      # Mock auth layer
      mock_credentials = MockGrafeasCredentials_v1.new("list_notes")

      Grafeas::V1::GrafeasService::Stub.stub(:new, mock_stub) do
        Grafeas::V1::Credentials.stub(:default, mock_credentials) do
          client = Grafeas.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.list_notes(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_note' do
    custom_error = CustomTestError_v1.new "Custom test error for Grafeas::V1::GrafeasClient#delete_note."

    it 'invokes delete_note without error' do
      # Create request parameters
      formatted_name = Grafeas::V1::GrafeasClient.note_path("[PROJECT]", "[NOTE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Grafeas::V1::DeleteNoteRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v1.new(:delete_note, mock_method)

      # Mock auth layer
      mock_credentials = MockGrafeasCredentials_v1.new("delete_note")

      Grafeas::V1::GrafeasService::Stub.stub(:new, mock_stub) do
        Grafeas::V1::Credentials.stub(:default, mock_credentials) do
          client = Grafeas.new(version: :v1)

          # Call method
          response = client.delete_note(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_note(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_note with error' do
      # Create request parameters
      formatted_name = Grafeas::V1::GrafeasClient.note_path("[PROJECT]", "[NOTE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Grafeas::V1::DeleteNoteRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:delete_note, mock_method)

      # Mock auth layer
      mock_credentials = MockGrafeasCredentials_v1.new("delete_note")

      Grafeas::V1::GrafeasService::Stub.stub(:new, mock_stub) do
        Grafeas::V1::Credentials.stub(:default, mock_credentials) do
          client = Grafeas.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.delete_note(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_note' do
    custom_error = CustomTestError_v1.new "Custom test error for Grafeas::V1::GrafeasClient#create_note."

    it 'invokes create_note without error' do
      # Create request parameters
      formatted_parent = Grafeas::V1::GrafeasClient.project_path("[PROJECT]")
      note_id = ''
      note = {}

      # Create expected grpc response
      name = "name3373707"
      short_description = "shortDescription-235369287"
      long_description = "longDescription-1747792199"
      expected_response = {
        name: name,
        short_description: short_description,
        long_description: long_description
      }
      expected_response = Google::Gax::to_proto(expected_response, Grafeas::V1::Note)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Grafeas::V1::CreateNoteRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(note_id, request.note_id)
        assert_equal(Google::Gax::to_proto(note, Grafeas::V1::Note), request.note)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:create_note, mock_method)

      # Mock auth layer
      mock_credentials = MockGrafeasCredentials_v1.new("create_note")

      Grafeas::V1::GrafeasService::Stub.stub(:new, mock_stub) do
        Grafeas::V1::Credentials.stub(:default, mock_credentials) do
          client = Grafeas.new(version: :v1)

          # Call method
          response = client.create_note(
            formatted_parent,
            note_id,
            note
          )

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_note(
            formatted_parent,
            note_id,
            note
          ) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_note with error' do
      # Create request parameters
      formatted_parent = Grafeas::V1::GrafeasClient.project_path("[PROJECT]")
      note_id = ''
      note = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Grafeas::V1::CreateNoteRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(note_id, request.note_id)
        assert_equal(Google::Gax::to_proto(note, Grafeas::V1::Note), request.note)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:create_note, mock_method)

      # Mock auth layer
      mock_credentials = MockGrafeasCredentials_v1.new("create_note")

      Grafeas::V1::GrafeasService::Stub.stub(:new, mock_stub) do
        Grafeas::V1::Credentials.stub(:default, mock_credentials) do
          client = Grafeas.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.create_note(
              formatted_parent,
              note_id,
              note
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'batch_create_notes' do
    custom_error = CustomTestError_v1.new "Custom test error for Grafeas::V1::GrafeasClient#batch_create_notes."

    it 'invokes batch_create_notes without error' do
      # Create request parameters
      formatted_parent = Grafeas::V1::GrafeasClient.project_path("[PROJECT]")
      notes = {}

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Grafeas::V1::BatchCreateNotesResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Grafeas::V1::BatchCreateNotesRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(notes, request.notes.to_h)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:batch_create_notes, mock_method)

      # Mock auth layer
      mock_credentials = MockGrafeasCredentials_v1.new("batch_create_notes")

      Grafeas::V1::GrafeasService::Stub.stub(:new, mock_stub) do
        Grafeas::V1::Credentials.stub(:default, mock_credentials) do
          client = Grafeas.new(version: :v1)

          # Call method
          response = client.batch_create_notes(formatted_parent, notes)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.batch_create_notes(formatted_parent, notes) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes batch_create_notes with error' do
      # Create request parameters
      formatted_parent = Grafeas::V1::GrafeasClient.project_path("[PROJECT]")
      notes = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Grafeas::V1::BatchCreateNotesRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(notes, request.notes.to_h)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:batch_create_notes, mock_method)

      # Mock auth layer
      mock_credentials = MockGrafeasCredentials_v1.new("batch_create_notes")

      Grafeas::V1::GrafeasService::Stub.stub(:new, mock_stub) do
        Grafeas::V1::Credentials.stub(:default, mock_credentials) do
          client = Grafeas.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.batch_create_notes(formatted_parent, notes)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_note' do
    custom_error = CustomTestError_v1.new "Custom test error for Grafeas::V1::GrafeasClient#update_note."

    it 'invokes update_note without error' do
      # Create request parameters
      formatted_name = Grafeas::V1::GrafeasClient.note_path("[PROJECT]", "[NOTE]")
      note = {}

      # Create expected grpc response
      name_2 = "name2-1052831874"
      short_description = "shortDescription-235369287"
      long_description = "longDescription-1747792199"
      expected_response = {
        name: name_2,
        short_description: short_description,
        long_description: long_description
      }
      expected_response = Google::Gax::to_proto(expected_response, Grafeas::V1::Note)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Grafeas::V1::UpdateNoteRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(note, Grafeas::V1::Note), request.note)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_note, mock_method)

      # Mock auth layer
      mock_credentials = MockGrafeasCredentials_v1.new("update_note")

      Grafeas::V1::GrafeasService::Stub.stub(:new, mock_stub) do
        Grafeas::V1::Credentials.stub(:default, mock_credentials) do
          client = Grafeas.new(version: :v1)

          # Call method
          response = client.update_note(formatted_name, note)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_note(formatted_name, note) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_note with error' do
      # Create request parameters
      formatted_name = Grafeas::V1::GrafeasClient.note_path("[PROJECT]", "[NOTE]")
      note = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Grafeas::V1::UpdateNoteRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(note, Grafeas::V1::Note), request.note)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_note, mock_method)

      # Mock auth layer
      mock_credentials = MockGrafeasCredentials_v1.new("update_note")

      Grafeas::V1::GrafeasService::Stub.stub(:new, mock_stub) do
        Grafeas::V1::Credentials.stub(:default, mock_credentials) do
          client = Grafeas.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.update_note(formatted_name, note)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_note_occurrences' do
    custom_error = CustomTestError_v1.new "Custom test error for Grafeas::V1::GrafeasClient#list_note_occurrences."

    it 'invokes list_note_occurrences without error' do
      # Create request parameters
      formatted_name = Grafeas::V1::GrafeasClient.note_path("[PROJECT]", "[NOTE]")

      # Create expected grpc response
      next_page_token = ""
      occurrences_element = {}
      occurrences = [occurrences_element]
      expected_response = { next_page_token: next_page_token, occurrences: occurrences }
      expected_response = Google::Gax::to_proto(expected_response, Grafeas::V1::ListNoteOccurrencesResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Grafeas::V1::ListNoteOccurrencesRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_note_occurrences, mock_method)

      # Mock auth layer
      mock_credentials = MockGrafeasCredentials_v1.new("list_note_occurrences")

      Grafeas::V1::GrafeasService::Stub.stub(:new, mock_stub) do
        Grafeas::V1::Credentials.stub(:default, mock_credentials) do
          client = Grafeas.new(version: :v1)

          # Call method
          response = client.list_note_occurrences(formatted_name)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.occurrences.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_note_occurrences with error' do
      # Create request parameters
      formatted_name = Grafeas::V1::GrafeasClient.note_path("[PROJECT]", "[NOTE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Grafeas::V1::ListNoteOccurrencesRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_note_occurrences, mock_method)

      # Mock auth layer
      mock_credentials = MockGrafeasCredentials_v1.new("list_note_occurrences")

      Grafeas::V1::GrafeasService::Stub.stub(:new, mock_stub) do
        Grafeas::V1::Credentials.stub(:default, mock_credentials) do
          client = Grafeas.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.list_note_occurrences(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end
