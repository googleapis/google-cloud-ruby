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


require "google/cloud/errors"
require "google/cloud/translate/v2/credentials"
require "google/cloud/translate/v2/version"
require "faraday"
require "uri"

module Google
  module Cloud
    module Translate
      module V2
        ##
        # @private
        # Represents the Translation API REST service, exposing the API calls.
        class Service # :nodoc:
          API_VERSION = "v2".freeze
          DEFAULT_UNIVERSE_DOMAIN = "googleapis.com".freeze
          ENDPOINT_SUBSTITUTION = "$UNIVERSE_DOMAIN$".freeze
          ENDPOINT_TEMPLATE = "translate.$UNIVERSE_DOMAIN$".freeze
          API_HOST = "translate.googleapis.com".freeze

          # @private
          attr_accessor :project_id, :credentials, :retries, :timeout, :key

          # @private
          # @return [String] The effective universe domain.
          attr_reader :universe_domain

          ##
          # @private Resolves the effective universe domain.
          #
          # @param [String, nil] universe_domain Explicit universe domain override.
          # @return [String]
          def self.resolve_universe_domain universe_domain = nil
            configured = universe_domain
            configured = V2.translation_config&.universe_domain if configured.nil?
            validate_non_empty_universe_domain! configured
            configured || env_universe_domain || DEFAULT_UNIVERSE_DOMAIN
          end

          ##
          # @private Returns the default service hostname for a universe domain.
          #
          # @param [String] universe_domain The resolved universe domain.
          # @return [String]
          def self.default_host_for universe_domain
            ENDPOINT_TEMPLATE.sub ENDPOINT_SUBSTITUTION, universe_domain
          end

          ##
          # @private Validates that a non-nil universe_domain is not empty.
          #
          # @param [String, nil] universe_domain
          def self.validate_non_empty_universe_domain! universe_domain
            return if universe_domain.nil?
            return unless universe_domain.to_s.strip.empty?

            raise ArgumentError, "universe_domain cannot be empty"
          end

          ##
          # @private Reads a non-empty GOOGLE_CLOUD_UNIVERSE_DOMAIN value from ENV.
          #
          # @return [String, nil]
          def self.env_universe_domain
            env_val = ENV["GOOGLE_CLOUD_UNIVERSE_DOMAIN"]
            return nil if env_val.nil?

            stripped = env_val.strip
            stripped.empty? ? nil : stripped
          end

          ##
          # Creates a new Service instance.
          def initialize project_id, credentials, retries: nil, timeout: nil, key: nil, host: nil, universe_domain: nil
            @project_id = project_id
            @credentials = credentials
            @retries = retries
            @timeout = timeout
            @key = key
            @universe_domain = self.class.resolve_universe_domain universe_domain
            verify_universe_domain! unless @key
            @url = resolve_url host
          end

          ##
          # Returns Hash of ListTranslationsResponse JSON
          def translate text, to: nil, from: nil, format: nil, model: nil, cid: nil
            body = {
              q: Array(text), target: to, source: from, format: format,
              model: model, cid: cid
            }.compact.to_json

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
            self.class.to_s
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

            raise Google::Cloud::Error.gapi_error_class_for(response.status)
          rescue Faraday::ConnectionFailed
            raise Google::Cloud::ResourceExhaustedError
          end

          ##
          # The HTTP object that makes calls to API.
          # This must be a Faraday object.
          def http
            @http ||= Faraday.new url: @url, request: {
              open_timeout: @timeout, timeout: @timeout
            }.compact
          end

          ##
          # The default HTTP headers to be sent on all API calls.
          def default_http_headers
            @default_http_headers ||= begin
              lib_version = Google::Cloud::Translate::V2::VERSION
              headers = {
                "User-Agent"                   => "gcloud-ruby/#{lib_version}",
                "google-cloud-resource-prefix" => "projects/#{@project}",
                "Content-Type"                 => "application/json",
                "x-goog-api-client"            => "gl-ruby/#{RUBY_VERSION} gccl/#{lib_version}"
              }
              quota_project = V2.translation_config&.quota_project
              quota_project ||= credentials.quota_project_id if credentials.respond_to? :quota_project_id
              headers["x-goog-user-project"] = quota_project if quota_project
              headers
            end
          end

          ##
          # Make a request and apply incremental backoff
          def execute &block
            backoff = Backoff.new retries: retries
            backoff.execute(&block)
          rescue Faraday::ConnectionFailed
            raise Google::Cloud::ResourceExhaustedError
          end

          ##
          # Sign OAuth2 / JWT API calls via googleauth's `#apply!`.
          def sign_http_request! request
            client = auth_client
            return request if client.nil?

            auth_headers = { jwt_aud_uri: "#{default_service_url}/" }
            client.apply! auth_headers
            apply_auth_headers! request, auth_headers
            request
          end

          def apply_auth_headers! request, auth_headers
            auth_headers.delete :jwt_aud_uri
            auth_headers.each do |header_key, header_val|
              normalized = header_key == :authorization ? "Authorization" : header_key.to_s
              request.headers[normalized] = header_val
            end
          end

          def default_service_url
            "https://#{self.class.default_host_for @universe_domain}"
          end

          def verify_universe_domain!
            return if @credentials.nil? || universe_domain_check_disabled?

            creds_universe = extract_credentials_universe_domain
            return if creds_universe.nil? || creds_universe == @universe_domain

            raise Google::Cloud::Error,
                  "Universe domain is #{@universe_domain} but credentials are in #{creds_universe}"
          end

          def universe_domain_check_disabled?
            return true if @credentials.respond_to?(:disable_universe_domain_check) &&
                           @credentials.disable_universe_domain_check

            client = auth_client
            client.respond_to?(:disable_universe_domain_check) && client.disable_universe_domain_check
          end

          def extract_credentials_universe_domain
            return @credentials.universe_domain if @credentials.respond_to? :universe_domain

            client = auth_client
            client.universe_domain if client.respond_to? :universe_domain
          end

          def auth_client
            @credentials.respond_to?(:client) ? @credentials.client : @credentials
          end

          def resolve_url host
            target = host || self.class.default_host_for(@universe_domain)
            return target.sub %r{/\z}, "" if target.start_with? "http://", "https://"

            "https://#{target}"
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
            self.reasons = ["rateLimitExceeded", "userRateLimitExceeded"]
            self.backoff = ->(retries) { sleep retries.to_i }

            def initialize options = {} # :nodoc:
              @max_retries = (options[:retries] || Backoff.retries).to_i
              @http_codes = (options[:http_codes] || Backoff.http_codes).to_a
              @reasons = (options[:reasons] || Backoff.reasons).to_a
              @backoff = options[:backoff] || Backoff.backoff
            end

            def execute # :nodoc:
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

            def retry? result, current_retries # :nodoc:
              if current_retries < @max_retries
                return true if retry_http_code? result
                return true if retry_error_reason? result
              end
              false
            end

            def retry_http_code? response # :nodoc:
              @http_codes.include? response.status
            end

            def retry_error_reason? response # :nodoc:
              result = JSON.parse response.body
              if result && result["error"] && result["error"]["errors"]
                Array(result["error"]["errors"]).each do |error|
                  return true if error["reason"] && @reasons.include?(error["reason"])
                end
              end
              false
            end
          end
        end
      end
    end
  end
end
