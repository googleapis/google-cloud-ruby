# Copyright 2021 Google LLC
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

require "googleauth"
require "gapic/rest/faraday_middleware"

module Gapic
  module Rest
    ##
    # A class for making REST calls through Faraday
    # ClientStub's responsibilities:
    #   - wrap Faraday methods with a bounded explicit interface
    #   - store service endpoint and create full url for the request
    #   - store credentials and add auth information to the request
    #
    class ClientStub
      ##
      # Initializes with an endpoint and credentials
      # @param endpoint [String] an endpoint for the service that this stub will send requests to
      # @param credentials [Google::Auth::Credentials]
      #   Credentials to send with calls in form of a googleauth credentials object.
      #   (see the [googleauth docs](https://googleapis.dev/ruby/googleauth/latest/index.html))
      #
      # @yield [Faraday::Connection]
      #
      def initialize endpoint:, credentials:
        @endpoint = endpoint
        @endpoint = "https://#{endpoint}" unless /^https?:/.match? endpoint
        @endpoint.sub! %r{/$}, ""

        @credentials = credentials

        @connection = Faraday.new url: @endpoint do |conn|
          conn.headers = { "Content-Type" => "application/json" }
          conn.request :google_authorization, @credentials
          conn.request :retry
          conn.response :raise_error
          conn.adapter :net_http
        end

        yield @connection if block_given?
      end

      ##
      # Makes a GET request
      #
      # @param uri [String] uri to send this request to
      # @param params [Hash] query string parameters for the request
      # @param options [::Gapic::CallOptions] gapic options to be applied to the REST call.
      #   Currently only timeout and headers are supported.
      # @return [Faraday::Response]
      def make_get_request uri:, params: {}, options: {}
        make_http_request :get, uri: uri, body: nil, params: params, options: options
      end

      ##
      # Makes a DELETE request
      #
      # @param uri [String] uri to send this request to
      # @param params [Hash] query string parameters for the request
      # @param options [::Gapic::CallOptions] gapic options to be applied to the REST call.
      #   Currently only timeout and headers are supported.
      # @return [Faraday::Response]
      def make_delete_request uri:, params: {}, options: {}
        make_http_request :delete, uri: uri, body: nil, params: params, options: options
      end

      ##
      # Makes a PATCH request
      #
      # @param uri [String] uri to send this request to
      # @param body [String] a body to send with the request, nil for requests without a body
      # @param params [Hash] query string parameters for the request
      # @param options [::Gapic::CallOptions] gapic options to be applied to the REST call.
      #   Currently only timeout and headers are supported.
      # @return [Faraday::Response]
      def make_patch_request uri:, body:, params: {}, options: {}
        make_http_request :patch, uri: uri, body: body, params: params, options: options
      end

      ##
      # Makes a POST request
      #
      # @param uri [String] uri to send this request to
      # @param body [String] a body to send with the request, nil for requests without a body
      # @param params [Hash] query string parameters for the request
      # @param options [::Gapic::CallOptions] gapic options to be applied to the REST call.
      #   Currently only timeout and headers are supported.
      # @return [Faraday::Response]
      def make_post_request uri:, body: nil, params: {}, options: {}
        make_http_request :post, uri: uri, body: body, params: params, options: options
      end

      ##
      # Makes a PUT request
      #
      # @param uri [String] uri to send this request to
      # @param body [String] a body to send with the request, nil for requests without a body
      # @param params [Hash] query string parameters for the request
      # @param options [::Gapic::CallOptions] gapic options to be applied to the REST call.
      #   Currently only timeout and headers are supported.
      # @return [Faraday::Response]
      def make_put_request uri:, body: nil, params: {}, options: {}
        make_http_request :put, uri: uri, body: body, params: params, options: options
      end

      protected

      ##
      # Sends a http request via Faraday
      # @param verb [Symbol] http verb
      # @param uri [String] uri to send this request to
      # @param body [String, nil] a body to send with the request, nil for requests without a body
      # @param params [Hash] query string parameters for the request
      # @param options [::Gapic::CallOptions] gapic options to be applied to the REST call.
      #   Currently only timeout and headers are supported.
      # @return [Faraday::Response]
      def make_http_request verb, uri:, body:, params:, options:
        @connection.send verb, uri do |req|
          req.params = params if params.any?
          req.body = body unless body.nil?
          req.headers = req.headers.merge options.metadata
          req.options.timeout = options.timeout if options.timeout&.positive?
        end
      end
    end
  end
end
