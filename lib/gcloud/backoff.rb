# Copyright 2014 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


module Gcloud
  ##
  # Backoff allows users to control how Google API calls are retried.
  # If an API call fails the response will be checked to see if the
  # call can be retried. If the response matches the criteria, then it
  # will be retried with an incremental backoff. This means that an
  # increasing delay will be added between each retried call. The first
  # retry will be delayed one second, the second retry will be delayed
  # two seconds, and so on.
  #
  # @example
  #   require "gcloud/backoff"
  #
  #   Gcloud::Backoff.retries = 5 # Set a maximum of five retries per call
  #
  class Backoff
    class << self
      ##
      # The number of times a retriable API call should be retried.
      #
      # The default value is 3.
      attr_accessor :retries

      ##
      # The HTTP Status Codes that should be retried.
      #
      # The default values are 500 and 503.
      attr_accessor :http_codes

      ##
      # The Google API error reasons that should be retried.
      #
      # The default values are rateLimitExceeded and
      # userRateLimitExceeded.
      attr_accessor :reasons

      ##
      # The code to run when a backoff is handled.
      # This must be a Proc and must take the number of
      # retries as an argument.
      #
      # Note: This method is undocumented and may change.
      attr_accessor :backoff # :nodoc:
    end
    # Set the default values
    self.retries = 3
    self.http_codes = [500, 503]
    self.reasons = %w(rateLimitExceeded userRateLimitExceeded)
    self.backoff = ->(retries) { sleep retries.to_i }

    ##
    # @private
    # Creates a new Backoff object to catch common errors when calling
    # the Google API and handle the error by retrying the call.
    #
    #   Gcloud::Backoff.new(options).execute do
    #     client.execute api_method: service.things.insert,
    #                    parameters: { thing: @thing },
    #                    body_object: { name: thing_name }
    #   end
    def initialize options = {}
      @max_retries  = (options[:retries]    || Backoff.retries).to_i
      @http_codes   = (options[:http_codes] || Backoff.http_codes).to_a
      @reasons      = (options[:reasons]    || Backoff.reasons).to_a
      @backoff      =  options[:backoff]    || Backoff.backoff
    end

    # @private
    def execute
      current_retries = 0
      loop do
        result = yield # Expecting Google::APIClient::Result
        return result if result.success?
        break result unless retry? result, current_retries
        current_retries += 1
        @backoff.call current_retries
      end
    end

    protected

    # @private
    def retry? result, current_retries #:nodoc:
      if current_retries < @max_retries
        return true if retry_http_code? result
        return true if retry_error_reason? result
      end
      false
    end

    # @private
    def retry_http_code? result #:nodoc:
      @http_codes.include? result.response.status
    end

    # @private
    def retry_error_reason? result
      if result.data &&
         result.data["error"] &&
         result.data["error"]["errors"]
        Array(result.data["error"]["errors"]).each do |error|
          return true if error["reason"] && @reasons.include?(error["reason"])
        end
      end
      false
    end
  end
end
