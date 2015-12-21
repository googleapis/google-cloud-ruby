#--
# Copyright 2015 Google Inc. All rights reserved.
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

require "gcloud/errors"

module Gcloud
  module Pubsub
    ##
    # = Storage Error
    #
    # Base Pub/Sub exception class.
    class Error < Gcloud::Error
      ##
      # The response object of the failed HTTP request.
      attr_reader :response

      # @private
      def self.from_response resp
        new.tap do |e|
          e.response = resp
        end
      end
    end

    ##
    # = ApiError
    #
    # Raised when an API call is not successful.
    class ApiError < Error
      ##
      # The code of the error.
      def code
        response.data["error"]["code"]
      rescue
        nil
      end

      ##
      # The errors encountered.
      def errors
        response.data["error"]["errors"]
      rescue
        []
      end

      def initialize message, response
        super message
        @response = response
      end

      # @private
      def self.from_response resp
        klass = klass_for resp.data["error"]["status"]
        klass.new resp.data["error"]["message"], resp
      rescue
        Gcloud::Pubsub::Error.from_response resp
      end

      def self.klass_for status
        if status == "ALREADY_EXISTS"
          return AlreadyExistsError
        elsif status == "NOT_FOUND"
          return NotFoundError
        end
        self
      end
    end

    ##
    # = AlreadyExistsError
    #
    # Raised when Pub/Sub returns an +ALREADY_EXISTS+ error.
    class AlreadyExistsError < ApiError
    end

    ##
    # = NotFoundError
    #
    # Raised when Pub/Sub returns a +NOT_FOUND+ error.
    class NotFoundError < ApiError
    end
  end
end
