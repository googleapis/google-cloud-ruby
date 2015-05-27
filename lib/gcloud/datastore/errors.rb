#--
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

require "gcloud"

module Gcloud
  module Datastore
    ##
    # Base Datastore exception class.
    class Error < Gcloud::Error
    end

    ##
    # Raised when a keyfile is not correct.
    class KeyfileError < Gcloud::Datastore::Error
    end

    ##
    # Raised when an API call is not successful.
    class ApiError < Gcloud::Datastore::Error
      ##
      # The API method of the failed HTTP request.
      attr_reader :method

      ##
      # The response object of the failed HTTP request.
      attr_reader :response

      def initialize method, response = nil #:nodoc:
        super("API call to #{method} was not successful")
        @method = method
        @response = response
      end
    end

    ##
    # Raised when a property is not correct.
    class PropertyError < Gcloud::Datastore::Error
    end

    ##
    # General error for Transaction problems.
    class TransactionError < Gcloud::Datastore::Error
      ##
      # An error that occurred within the transaction. (optional)
      attr_reader :inner

      def initialize message, inner = nil #:nodoc:
        super(message)
        @inner = inner
      end
    end
  end
end
