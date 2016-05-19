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
  module Vision
    ##
    # # Vision Error
    #
    # Base Vision exception class.
    class Error < Gcloud::Error
      ##
      # The response object of the failed HTTP request.
      attr_reader :response

      # @private
      def self.from_response resp
        new.tap do |e|
          e.instance_variable_set "@response", resp
        end
      end
    end

    ##
    # # ApiError
    #
    # Raised when an API call is not successful.
    class ApiError < Error
      ##
      # The HTTP code of the error.
      attr_reader :code

      ##
      # The Google API error status.
      attr_reader :status

      ##
      # The errors encountered.
      attr_reader :errors

      # @private
      def self.from_response resp
        if resp.data? && resp.data["error"]
          new(resp.data["error"]["message"]).tap do |e|
            e.instance_variable_set "@code", resp.data["error"]["code"]
            e.instance_variable_set "@status", resp.data["error"]["status"]
            e.instance_variable_set "@errors", resp.data["error"]["errors"]
            e.instance_variable_set "@response", resp
          end
        else
          Error.from_response_status resp
        end
      end
    end
  end
end
