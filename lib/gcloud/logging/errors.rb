# Copyright 2016 Google Inc. All rights reserved.
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
  module Logging
    ##
    # # Logging Error
    #
    # Base Logging exception class.
    class Error < Gcloud::Error
      ##
      # The error object of the failed HTTP request.
      attr_reader :inner

      ##
      # Create a new Logging error object.
      def initialize message, error = nil
        super message
        @inner = error
      end

      # @private Create a new Logging error object.
      def self.from_error e
        new e.message, e
      end
    end
  end
end
