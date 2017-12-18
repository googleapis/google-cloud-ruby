# Copyright 2016 Google LLC
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


require "google/cloud/errors"
require "google/cloud/translate/credentials"
require "google/cloud/translate/version"
require "faraday"

module Google
  module Cloud
    module Translate
      ##
      # @private
      # Represents the Translation API REST service, exposing the API calls.
      class Service #:nodoc:
        API_VERSION = "v2"
        API_URL = "https://translation.googleapis.com"

        # @private
        attr_accessor :project, :credentials, :retries, :timeout, :key

        ##
        # Creates a new Service instance.
        def initialize project, credentials, retries: nil, timeout: nil,
                       key: nil
          @project = project
          @credentials = credentials
          @retries = retries
          @timeout = timeout
          @key = key
        end

        ##
        # Returns Hash of ListTranslationsResponse JSON
        def translate text, to: nil, from: nil, format: nil, model: nil,
                      cid: nil
          body = {
            q: Array(text), target: to, source: from, format: format,
            model: model, cid: cid
          }.delete_if { |_k, v| v.nil? }.to_json

          post "/language/translate/v2", body
        end

        ##
        # Returns API::ListDetectionsResponse
        def detect text
          body = { q: Array(text) }.to_json

          post "language/translate/v2/detect", body
        end

        ##
        # Returns API::ListLanguagesResponse
        def languages language = nil
          body = { target: language }.to_json

          post "language/translate/v2/languages", body
        end

        def inspect
          "#{self.class}"
        end

        protected

        def post path, body = nil
          response = execute do
            http.post path do |req|
              req.headers.merge! default_http_headers
              req.body = body unless body.nil?

              if @key
                req.params = { key: @key }
              else
                sign_http_request! req
              end
            end
          end

          return JSON.parse(response.body)["data"] if response.success?

          fail Google::Cloud::Error.gapi_error_class_for(response.status)
        rescue Faraday::ConnectionFailed
          raise Google::Cloud::ResourceExhaustedError
        end

        ##
        # The HTTP object that makes calls to API.
        # This must be a Faraday object.
        def http
          @http ||= Faraday.new url: API_URL, request: {
            open_timeout: @timeout, timeout: @timeout
          }.delete_if { |_k, v| v.nil? }
        end

        ##
        # The default HTTP headers to be sent on all API calls.
        def default_http_headers
          @default_http_headers ||= {
            "User-Agent" => "gcloud-ruby/#{Google::Cloud::Translate::VERSION}",
            "google-cloud-resource-prefix" => "projects/#{@project}",
            "Content-Type" => "application/json",
            "x-goog-api-client" => "gl-ruby/#{RUBY_VERSION} " \
              "gccl/#{Google::Cloud::Translate::VERSION}"
          }
        end

        ##
        # Make a request and apply incremental backoff
        def execute
          backoff = Backoff.new retries: retries
          backoff.execute do
            yield
          end
        rescue Faraday::ConnectionFailed
          raise Google::Cloud::ResourceExhaustedError
        end

        ##
        # Sign Oauth2 API calls.
        def sign_http_request! request
          client = credentials.client
          return if client.nil?

          client.fetch_access_token! if client.expires_within? 30
          client.generate_authenticated_request request: request
          request
        end

        ##
        # @private Backoff
        class Backoff
          class << self
            attr_accessor :retries
            attr_accessor :http_codes
            attr_accessor :reasons
            attr_accessor :backoff # :nodoc:
          end

          # Set the default values
          self.retries = 3
          self.http_codes = [500, 503]
          self.reasons = %w(rateLimitExceeded userRateLimitExceeded)
          self.backoff = ->(retries) { sleep retries.to_i }

          def initialize options = {} #:nodoc:
            @max_retries  = (options[:retries]    || Backoff.retries).to_i
            @http_codes   = (options[:http_codes] || Backoff.http_codes).to_a
            @reasons      = (options[:reasons]    || Backoff.reasons).to_a
            @backoff      =  options[:backoff]    || Backoff.backoff
          end

          def execute #:nodoc:
            current_retries = 0
            loop do
              response = yield # Expecting Faraday::Response
              return response if response.success?
              break response unless retry? response, current_retries
              current_retries += 1
              @backoff.call current_retries
            end
          end

          protected

          def retry? result, current_retries #:nodoc:
            if current_retries < @max_retries
              return true if retry_http_code? result
              return true if retry_error_reason? result
            end
            false
          end

          def retry_http_code? response #:nodoc:
            @http_codes.include? response.status
          end

          def retry_error_reason? response #:nodoc:
            result = JSON.parse(response.body)
            if result &&
               result["error"] &&
               result["error"]["errors"]
              Array(result["error"]["errors"]).each do |error|
                if error["reason"] && @reasons.include?(error["reason"])
                  return true
                end
              end
            end
            false
          end
        end
      end
    end
  end
end
