# frozen_string_literal: true

# Copyright 2023 Google LLC
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

# Auto-generated by gapic-generator-ruby. DO NOT EDIT!

require "helper"
require "gapic/rest"
require "google/cloud/recommender/v1/recommender_service_pb"
require "google/cloud/recommender/v1/recommender/rest"


class ::Google::Cloud::Recommender::V1::Recommender::Rest::ClientTest < Minitest::Test
  class ClientStub
    attr_accessor :call_count, :requests

    def initialize response, &block
      @response = response
      @block = block
      @call_count = 0
      @requests = []
    end

    def make_get_request uri:, params: {}, options: {}, method_name: nil
      make_http_request :get, uri: uri, body: nil, params: params, options: options, method_name: method_name
    end

    def make_delete_request uri:, params: {}, options: {}, method_name: nil
      make_http_request :delete, uri: uri, body: nil, params: params, options: options, method_name: method_name
    end

    def make_post_request uri:, body: nil, params: {}, options: {}, method_name: nil
      make_http_request :post, uri: uri, body: body, params: params, options: options, method_name: method_name
    end

    def make_patch_request uri:, body:, params: {}, options: {}, method_name: nil
      make_http_request :patch, uri: uri, body: body, params: params, options: options, method_name: method_name
    end

    def make_put_request uri:, body:, params: {}, options: {}, method_name: nil
      make_http_request :put, uri: uri, body: body, params: params, options: options, method_name: method_name
    end

    def make_http_request *args, **kwargs
      @call_count += 1

      @requests << @block&.call(*args, **kwargs)

      @response
    end

    def endpoint
      "endpoint.example.com"
    end

    def universe_domain
      "example.com"
    end

    def stub_logger
      nil
    end

    def logger
      nil
    end
  end

  def test_list_insights
    # Create test objects.
    client_result = ::Google::Cloud::Recommender::V1::ListInsightsResponse.new
    http_response = OpenStruct.new body: client_result.to_json

    call_options = {}

    # Create request parameters for a unary method.
    parent = "hello world"
    page_size = 42
    page_token = "hello world"
    filter = "hello world"

    list_insights_client_stub = ClientStub.new http_response do |_verb, uri:, body:, params:, options:, method_name:|
      assert options.metadata.key? :"x-goog-api-client"
      assert options.metadata[:"x-goog-api-client"].include? "rest"
      refute options.metadata[:"x-goog-api-client"].include? "grpc"
    end

    ::Google::Cloud::Recommender::V1::Recommender::Rest::ServiceStub.stub :transcode_list_insights_request, ["", "", {}] do
      Gapic::Rest::ClientStub.stub :new, list_insights_client_stub do
        # Create client
        client = ::Google::Cloud::Recommender::V1::Recommender::Rest::Client.new do |config|
          config.credentials = :dummy_value
        end

        # Use hash object
        client.list_insights({ parent: parent, page_size: page_size, page_token: page_token, filter: filter }) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use named arguments
        client.list_insights parent: parent, page_size: page_size, page_token: page_token, filter: filter do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object
        client.list_insights ::Google::Cloud::Recommender::V1::ListInsightsRequest.new(parent: parent, page_size: page_size, page_token: page_token, filter: filter) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use hash object with options
        client.list_insights({ parent: parent, page_size: page_size, page_token: page_token, filter: filter }, call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object with options
        client.list_insights(::Google::Cloud::Recommender::V1::ListInsightsRequest.new(parent: parent, page_size: page_size, page_token: page_token, filter: filter), call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Verify method calls
        assert_equal 5, list_insights_client_stub.call_count
      end
    end
  end

  def test_get_insight
    # Create test objects.
    client_result = ::Google::Cloud::Recommender::V1::Insight.new
    http_response = OpenStruct.new body: client_result.to_json

    call_options = {}

    # Create request parameters for a unary method.
    name = "hello world"

    get_insight_client_stub = ClientStub.new http_response do |_verb, uri:, body:, params:, options:, method_name:|
      assert options.metadata.key? :"x-goog-api-client"
      assert options.metadata[:"x-goog-api-client"].include? "rest"
      refute options.metadata[:"x-goog-api-client"].include? "grpc"
    end

    ::Google::Cloud::Recommender::V1::Recommender::Rest::ServiceStub.stub :transcode_get_insight_request, ["", "", {}] do
      Gapic::Rest::ClientStub.stub :new, get_insight_client_stub do
        # Create client
        client = ::Google::Cloud::Recommender::V1::Recommender::Rest::Client.new do |config|
          config.credentials = :dummy_value
        end

        # Use hash object
        client.get_insight({ name: name }) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use named arguments
        client.get_insight name: name do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object
        client.get_insight ::Google::Cloud::Recommender::V1::GetInsightRequest.new(name: name) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use hash object with options
        client.get_insight({ name: name }, call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object with options
        client.get_insight(::Google::Cloud::Recommender::V1::GetInsightRequest.new(name: name), call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Verify method calls
        assert_equal 5, get_insight_client_stub.call_count
      end
    end
  end

  def test_mark_insight_accepted
    # Create test objects.
    client_result = ::Google::Cloud::Recommender::V1::Insight.new
    http_response = OpenStruct.new body: client_result.to_json

    call_options = {}

    # Create request parameters for a unary method.
    name = "hello world"
    state_metadata = {}
    etag = "hello world"

    mark_insight_accepted_client_stub = ClientStub.new http_response do |_verb, uri:, body:, params:, options:, method_name:|
      assert options.metadata.key? :"x-goog-api-client"
      assert options.metadata[:"x-goog-api-client"].include? "rest"
      refute options.metadata[:"x-goog-api-client"].include? "grpc"
    end

    ::Google::Cloud::Recommender::V1::Recommender::Rest::ServiceStub.stub :transcode_mark_insight_accepted_request, ["", "", {}] do
      Gapic::Rest::ClientStub.stub :new, mark_insight_accepted_client_stub do
        # Create client
        client = ::Google::Cloud::Recommender::V1::Recommender::Rest::Client.new do |config|
          config.credentials = :dummy_value
        end

        # Use hash object
        client.mark_insight_accepted({ name: name, state_metadata: state_metadata, etag: etag }) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use named arguments
        client.mark_insight_accepted name: name, state_metadata: state_metadata, etag: etag do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object
        client.mark_insight_accepted ::Google::Cloud::Recommender::V1::MarkInsightAcceptedRequest.new(name: name, state_metadata: state_metadata, etag: etag) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use hash object with options
        client.mark_insight_accepted({ name: name, state_metadata: state_metadata, etag: etag }, call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object with options
        client.mark_insight_accepted(::Google::Cloud::Recommender::V1::MarkInsightAcceptedRequest.new(name: name, state_metadata: state_metadata, etag: etag), call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Verify method calls
        assert_equal 5, mark_insight_accepted_client_stub.call_count
      end
    end
  end

  def test_list_recommendations
    # Create test objects.
    client_result = ::Google::Cloud::Recommender::V1::ListRecommendationsResponse.new
    http_response = OpenStruct.new body: client_result.to_json

    call_options = {}

    # Create request parameters for a unary method.
    parent = "hello world"
    page_size = 42
    page_token = "hello world"
    filter = "hello world"

    list_recommendations_client_stub = ClientStub.new http_response do |_verb, uri:, body:, params:, options:, method_name:|
      assert options.metadata.key? :"x-goog-api-client"
      assert options.metadata[:"x-goog-api-client"].include? "rest"
      refute options.metadata[:"x-goog-api-client"].include? "grpc"
    end

    ::Google::Cloud::Recommender::V1::Recommender::Rest::ServiceStub.stub :transcode_list_recommendations_request, ["", "", {}] do
      Gapic::Rest::ClientStub.stub :new, list_recommendations_client_stub do
        # Create client
        client = ::Google::Cloud::Recommender::V1::Recommender::Rest::Client.new do |config|
          config.credentials = :dummy_value
        end

        # Use hash object
        client.list_recommendations({ parent: parent, page_size: page_size, page_token: page_token, filter: filter }) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use named arguments
        client.list_recommendations parent: parent, page_size: page_size, page_token: page_token, filter: filter do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object
        client.list_recommendations ::Google::Cloud::Recommender::V1::ListRecommendationsRequest.new(parent: parent, page_size: page_size, page_token: page_token, filter: filter) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use hash object with options
        client.list_recommendations({ parent: parent, page_size: page_size, page_token: page_token, filter: filter }, call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object with options
        client.list_recommendations(::Google::Cloud::Recommender::V1::ListRecommendationsRequest.new(parent: parent, page_size: page_size, page_token: page_token, filter: filter), call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Verify method calls
        assert_equal 5, list_recommendations_client_stub.call_count
      end
    end
  end

  def test_get_recommendation
    # Create test objects.
    client_result = ::Google::Cloud::Recommender::V1::Recommendation.new
    http_response = OpenStruct.new body: client_result.to_json

    call_options = {}

    # Create request parameters for a unary method.
    name = "hello world"

    get_recommendation_client_stub = ClientStub.new http_response do |_verb, uri:, body:, params:, options:, method_name:|
      assert options.metadata.key? :"x-goog-api-client"
      assert options.metadata[:"x-goog-api-client"].include? "rest"
      refute options.metadata[:"x-goog-api-client"].include? "grpc"
    end

    ::Google::Cloud::Recommender::V1::Recommender::Rest::ServiceStub.stub :transcode_get_recommendation_request, ["", "", {}] do
      Gapic::Rest::ClientStub.stub :new, get_recommendation_client_stub do
        # Create client
        client = ::Google::Cloud::Recommender::V1::Recommender::Rest::Client.new do |config|
          config.credentials = :dummy_value
        end

        # Use hash object
        client.get_recommendation({ name: name }) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use named arguments
        client.get_recommendation name: name do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object
        client.get_recommendation ::Google::Cloud::Recommender::V1::GetRecommendationRequest.new(name: name) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use hash object with options
        client.get_recommendation({ name: name }, call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object with options
        client.get_recommendation(::Google::Cloud::Recommender::V1::GetRecommendationRequest.new(name: name), call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Verify method calls
        assert_equal 5, get_recommendation_client_stub.call_count
      end
    end
  end

  def test_mark_recommendation_dismissed
    # Create test objects.
    client_result = ::Google::Cloud::Recommender::V1::Recommendation.new
    http_response = OpenStruct.new body: client_result.to_json

    call_options = {}

    # Create request parameters for a unary method.
    name = "hello world"
    etag = "hello world"

    mark_recommendation_dismissed_client_stub = ClientStub.new http_response do |_verb, uri:, body:, params:, options:, method_name:|
      assert options.metadata.key? :"x-goog-api-client"
      assert options.metadata[:"x-goog-api-client"].include? "rest"
      refute options.metadata[:"x-goog-api-client"].include? "grpc"
    end

    ::Google::Cloud::Recommender::V1::Recommender::Rest::ServiceStub.stub :transcode_mark_recommendation_dismissed_request, ["", "", {}] do
      Gapic::Rest::ClientStub.stub :new, mark_recommendation_dismissed_client_stub do
        # Create client
        client = ::Google::Cloud::Recommender::V1::Recommender::Rest::Client.new do |config|
          config.credentials = :dummy_value
        end

        # Use hash object
        client.mark_recommendation_dismissed({ name: name, etag: etag }) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use named arguments
        client.mark_recommendation_dismissed name: name, etag: etag do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object
        client.mark_recommendation_dismissed ::Google::Cloud::Recommender::V1::MarkRecommendationDismissedRequest.new(name: name, etag: etag) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use hash object with options
        client.mark_recommendation_dismissed({ name: name, etag: etag }, call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object with options
        client.mark_recommendation_dismissed(::Google::Cloud::Recommender::V1::MarkRecommendationDismissedRequest.new(name: name, etag: etag), call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Verify method calls
        assert_equal 5, mark_recommendation_dismissed_client_stub.call_count
      end
    end
  end

  def test_mark_recommendation_claimed
    # Create test objects.
    client_result = ::Google::Cloud::Recommender::V1::Recommendation.new
    http_response = OpenStruct.new body: client_result.to_json

    call_options = {}

    # Create request parameters for a unary method.
    name = "hello world"
    state_metadata = {}
    etag = "hello world"

    mark_recommendation_claimed_client_stub = ClientStub.new http_response do |_verb, uri:, body:, params:, options:, method_name:|
      assert options.metadata.key? :"x-goog-api-client"
      assert options.metadata[:"x-goog-api-client"].include? "rest"
      refute options.metadata[:"x-goog-api-client"].include? "grpc"
    end

    ::Google::Cloud::Recommender::V1::Recommender::Rest::ServiceStub.stub :transcode_mark_recommendation_claimed_request, ["", "", {}] do
      Gapic::Rest::ClientStub.stub :new, mark_recommendation_claimed_client_stub do
        # Create client
        client = ::Google::Cloud::Recommender::V1::Recommender::Rest::Client.new do |config|
          config.credentials = :dummy_value
        end

        # Use hash object
        client.mark_recommendation_claimed({ name: name, state_metadata: state_metadata, etag: etag }) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use named arguments
        client.mark_recommendation_claimed name: name, state_metadata: state_metadata, etag: etag do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object
        client.mark_recommendation_claimed ::Google::Cloud::Recommender::V1::MarkRecommendationClaimedRequest.new(name: name, state_metadata: state_metadata, etag: etag) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use hash object with options
        client.mark_recommendation_claimed({ name: name, state_metadata: state_metadata, etag: etag }, call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object with options
        client.mark_recommendation_claimed(::Google::Cloud::Recommender::V1::MarkRecommendationClaimedRequest.new(name: name, state_metadata: state_metadata, etag: etag), call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Verify method calls
        assert_equal 5, mark_recommendation_claimed_client_stub.call_count
      end
    end
  end

  def test_mark_recommendation_succeeded
    # Create test objects.
    client_result = ::Google::Cloud::Recommender::V1::Recommendation.new
    http_response = OpenStruct.new body: client_result.to_json

    call_options = {}

    # Create request parameters for a unary method.
    name = "hello world"
    state_metadata = {}
    etag = "hello world"

    mark_recommendation_succeeded_client_stub = ClientStub.new http_response do |_verb, uri:, body:, params:, options:, method_name:|
      assert options.metadata.key? :"x-goog-api-client"
      assert options.metadata[:"x-goog-api-client"].include? "rest"
      refute options.metadata[:"x-goog-api-client"].include? "grpc"
    end

    ::Google::Cloud::Recommender::V1::Recommender::Rest::ServiceStub.stub :transcode_mark_recommendation_succeeded_request, ["", "", {}] do
      Gapic::Rest::ClientStub.stub :new, mark_recommendation_succeeded_client_stub do
        # Create client
        client = ::Google::Cloud::Recommender::V1::Recommender::Rest::Client.new do |config|
          config.credentials = :dummy_value
        end

        # Use hash object
        client.mark_recommendation_succeeded({ name: name, state_metadata: state_metadata, etag: etag }) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use named arguments
        client.mark_recommendation_succeeded name: name, state_metadata: state_metadata, etag: etag do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object
        client.mark_recommendation_succeeded ::Google::Cloud::Recommender::V1::MarkRecommendationSucceededRequest.new(name: name, state_metadata: state_metadata, etag: etag) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use hash object with options
        client.mark_recommendation_succeeded({ name: name, state_metadata: state_metadata, etag: etag }, call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object with options
        client.mark_recommendation_succeeded(::Google::Cloud::Recommender::V1::MarkRecommendationSucceededRequest.new(name: name, state_metadata: state_metadata, etag: etag), call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Verify method calls
        assert_equal 5, mark_recommendation_succeeded_client_stub.call_count
      end
    end
  end

  def test_mark_recommendation_failed
    # Create test objects.
    client_result = ::Google::Cloud::Recommender::V1::Recommendation.new
    http_response = OpenStruct.new body: client_result.to_json

    call_options = {}

    # Create request parameters for a unary method.
    name = "hello world"
    state_metadata = {}
    etag = "hello world"

    mark_recommendation_failed_client_stub = ClientStub.new http_response do |_verb, uri:, body:, params:, options:, method_name:|
      assert options.metadata.key? :"x-goog-api-client"
      assert options.metadata[:"x-goog-api-client"].include? "rest"
      refute options.metadata[:"x-goog-api-client"].include? "grpc"
    end

    ::Google::Cloud::Recommender::V1::Recommender::Rest::ServiceStub.stub :transcode_mark_recommendation_failed_request, ["", "", {}] do
      Gapic::Rest::ClientStub.stub :new, mark_recommendation_failed_client_stub do
        # Create client
        client = ::Google::Cloud::Recommender::V1::Recommender::Rest::Client.new do |config|
          config.credentials = :dummy_value
        end

        # Use hash object
        client.mark_recommendation_failed({ name: name, state_metadata: state_metadata, etag: etag }) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use named arguments
        client.mark_recommendation_failed name: name, state_metadata: state_metadata, etag: etag do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object
        client.mark_recommendation_failed ::Google::Cloud::Recommender::V1::MarkRecommendationFailedRequest.new(name: name, state_metadata: state_metadata, etag: etag) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use hash object with options
        client.mark_recommendation_failed({ name: name, state_metadata: state_metadata, etag: etag }, call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object with options
        client.mark_recommendation_failed(::Google::Cloud::Recommender::V1::MarkRecommendationFailedRequest.new(name: name, state_metadata: state_metadata, etag: etag), call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Verify method calls
        assert_equal 5, mark_recommendation_failed_client_stub.call_count
      end
    end
  end

  def test_get_recommender_config
    # Create test objects.
    client_result = ::Google::Cloud::Recommender::V1::RecommenderConfig.new
    http_response = OpenStruct.new body: client_result.to_json

    call_options = {}

    # Create request parameters for a unary method.
    name = "hello world"

    get_recommender_config_client_stub = ClientStub.new http_response do |_verb, uri:, body:, params:, options:, method_name:|
      assert options.metadata.key? :"x-goog-api-client"
      assert options.metadata[:"x-goog-api-client"].include? "rest"
      refute options.metadata[:"x-goog-api-client"].include? "grpc"
    end

    ::Google::Cloud::Recommender::V1::Recommender::Rest::ServiceStub.stub :transcode_get_recommender_config_request, ["", "", {}] do
      Gapic::Rest::ClientStub.stub :new, get_recommender_config_client_stub do
        # Create client
        client = ::Google::Cloud::Recommender::V1::Recommender::Rest::Client.new do |config|
          config.credentials = :dummy_value
        end

        # Use hash object
        client.get_recommender_config({ name: name }) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use named arguments
        client.get_recommender_config name: name do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object
        client.get_recommender_config ::Google::Cloud::Recommender::V1::GetRecommenderConfigRequest.new(name: name) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use hash object with options
        client.get_recommender_config({ name: name }, call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object with options
        client.get_recommender_config(::Google::Cloud::Recommender::V1::GetRecommenderConfigRequest.new(name: name), call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Verify method calls
        assert_equal 5, get_recommender_config_client_stub.call_count
      end
    end
  end

  def test_update_recommender_config
    # Create test objects.
    client_result = ::Google::Cloud::Recommender::V1::RecommenderConfig.new
    http_response = OpenStruct.new body: client_result.to_json

    call_options = {}

    # Create request parameters for a unary method.
    recommender_config = {}
    update_mask = {}
    validate_only = true

    update_recommender_config_client_stub = ClientStub.new http_response do |_verb, uri:, body:, params:, options:, method_name:|
      assert options.metadata.key? :"x-goog-api-client"
      assert options.metadata[:"x-goog-api-client"].include? "rest"
      refute options.metadata[:"x-goog-api-client"].include? "grpc"
    end

    ::Google::Cloud::Recommender::V1::Recommender::Rest::ServiceStub.stub :transcode_update_recommender_config_request, ["", "", {}] do
      Gapic::Rest::ClientStub.stub :new, update_recommender_config_client_stub do
        # Create client
        client = ::Google::Cloud::Recommender::V1::Recommender::Rest::Client.new do |config|
          config.credentials = :dummy_value
        end

        # Use hash object
        client.update_recommender_config({ recommender_config: recommender_config, update_mask: update_mask, validate_only: validate_only }) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use named arguments
        client.update_recommender_config recommender_config: recommender_config, update_mask: update_mask, validate_only: validate_only do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object
        client.update_recommender_config ::Google::Cloud::Recommender::V1::UpdateRecommenderConfigRequest.new(recommender_config: recommender_config, update_mask: update_mask, validate_only: validate_only) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use hash object with options
        client.update_recommender_config({ recommender_config: recommender_config, update_mask: update_mask, validate_only: validate_only }, call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object with options
        client.update_recommender_config(::Google::Cloud::Recommender::V1::UpdateRecommenderConfigRequest.new(recommender_config: recommender_config, update_mask: update_mask, validate_only: validate_only), call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Verify method calls
        assert_equal 5, update_recommender_config_client_stub.call_count
      end
    end
  end

  def test_get_insight_type_config
    # Create test objects.
    client_result = ::Google::Cloud::Recommender::V1::InsightTypeConfig.new
    http_response = OpenStruct.new body: client_result.to_json

    call_options = {}

    # Create request parameters for a unary method.
    name = "hello world"

    get_insight_type_config_client_stub = ClientStub.new http_response do |_verb, uri:, body:, params:, options:, method_name:|
      assert options.metadata.key? :"x-goog-api-client"
      assert options.metadata[:"x-goog-api-client"].include? "rest"
      refute options.metadata[:"x-goog-api-client"].include? "grpc"
    end

    ::Google::Cloud::Recommender::V1::Recommender::Rest::ServiceStub.stub :transcode_get_insight_type_config_request, ["", "", {}] do
      Gapic::Rest::ClientStub.stub :new, get_insight_type_config_client_stub do
        # Create client
        client = ::Google::Cloud::Recommender::V1::Recommender::Rest::Client.new do |config|
          config.credentials = :dummy_value
        end

        # Use hash object
        client.get_insight_type_config({ name: name }) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use named arguments
        client.get_insight_type_config name: name do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object
        client.get_insight_type_config ::Google::Cloud::Recommender::V1::GetInsightTypeConfigRequest.new(name: name) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use hash object with options
        client.get_insight_type_config({ name: name }, call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object with options
        client.get_insight_type_config(::Google::Cloud::Recommender::V1::GetInsightTypeConfigRequest.new(name: name), call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Verify method calls
        assert_equal 5, get_insight_type_config_client_stub.call_count
      end
    end
  end

  def test_update_insight_type_config
    # Create test objects.
    client_result = ::Google::Cloud::Recommender::V1::InsightTypeConfig.new
    http_response = OpenStruct.new body: client_result.to_json

    call_options = {}

    # Create request parameters for a unary method.
    insight_type_config = {}
    update_mask = {}
    validate_only = true

    update_insight_type_config_client_stub = ClientStub.new http_response do |_verb, uri:, body:, params:, options:, method_name:|
      assert options.metadata.key? :"x-goog-api-client"
      assert options.metadata[:"x-goog-api-client"].include? "rest"
      refute options.metadata[:"x-goog-api-client"].include? "grpc"
    end

    ::Google::Cloud::Recommender::V1::Recommender::Rest::ServiceStub.stub :transcode_update_insight_type_config_request, ["", "", {}] do
      Gapic::Rest::ClientStub.stub :new, update_insight_type_config_client_stub do
        # Create client
        client = ::Google::Cloud::Recommender::V1::Recommender::Rest::Client.new do |config|
          config.credentials = :dummy_value
        end

        # Use hash object
        client.update_insight_type_config({ insight_type_config: insight_type_config, update_mask: update_mask, validate_only: validate_only }) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use named arguments
        client.update_insight_type_config insight_type_config: insight_type_config, update_mask: update_mask, validate_only: validate_only do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object
        client.update_insight_type_config ::Google::Cloud::Recommender::V1::UpdateInsightTypeConfigRequest.new(insight_type_config: insight_type_config, update_mask: update_mask, validate_only: validate_only) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use hash object with options
        client.update_insight_type_config({ insight_type_config: insight_type_config, update_mask: update_mask, validate_only: validate_only }, call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object with options
        client.update_insight_type_config(::Google::Cloud::Recommender::V1::UpdateInsightTypeConfigRequest.new(insight_type_config: insight_type_config, update_mask: update_mask, validate_only: validate_only), call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Verify method calls
        assert_equal 5, update_insight_type_config_client_stub.call_count
      end
    end
  end

  def test_configure
    credentials_token = :dummy_value

    client = block_config = config = nil
    dummy_stub = ClientStub.new nil
    Gapic::Rest::ClientStub.stub :new, dummy_stub do
      client = ::Google::Cloud::Recommender::V1::Recommender::Rest::Client.new do |config|
        config.credentials = credentials_token
      end
    end

    config = client.configure do |c|
      block_config = c
    end

    assert_same block_config, config
    assert_kind_of ::Google::Cloud::Recommender::V1::Recommender::Rest::Client::Configuration, config
  end
end
