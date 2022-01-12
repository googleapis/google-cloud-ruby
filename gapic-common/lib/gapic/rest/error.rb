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

require "json"

module Gapic
  module Rest
    # Gapic REST exception class
    class Error < StandardError
      # @return [Integer] the http status code for the error
      attr_reader :status_code

      ##
      # @param message [String, nil] error message
      # @param status_code [Integer, nil] HTTP status code of this error
      #
      def initialize message, status_code
        @status_code = status_code
        super message
      end

      class << self
        ##
        # This creates a new error message wrapping the Faraday's one. Additionally
        # it tries to parse and set a detailed message and an error code from
        # from the Google Cloud's response body
        #
        def wrap_faraday_error err
          message = err.message
          status_code = err.response_status

          if err.response_body
            msg, code = try_parse_from_body err.response_body
            message = "An error has occurred when making a REST request: #{msg}" unless msg.nil?
            status_code = code unless code.nil?
          end

          Gapic::Rest::Error.new message, status_code
        end

        private

        ##
        # Tries to get the error information from the JSON bodies
        #
        # @param body_str [String]
        # @return [Array(String, String)]
        def try_parse_from_body body_str
          body = JSON.parse body_str
          return [nil, nil] unless body && body["error"].is_a?(Hash)

          message = body["error"]["message"]
          code = body["error"]["code"]

          [message, code]
        rescue JSON::ParserError
          [nil, nil]
        end
      end
    end
  end
end
