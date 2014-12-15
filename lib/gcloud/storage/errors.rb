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
  module Storage
    ##
    # Base Storage exception class.
    class Error < Gcloud::Error
    end

    ##
    # Raised when an API call is not successful.
    class ApiError < Error
      ##
      # The code of the error.
      attr_reader :code

      ##
      # The errors encountered.
      attr_reader :errors

      def initialize message, code, errors
        super message
        @code, @errors = code, errors
      end

      def self.from_response resp #:nodoc:
        new resp.data["error"]["message"],
            resp.data["error"]["code"],
            resp.data["error"]["errors"]
      end
    end
  end
end
