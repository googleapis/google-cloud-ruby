# Copyright 2018 Google LLC
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

module Google
  module Cloud
    module Trace
      ##
      # # AsyncReporterError
      #
      # Used to indicate a problem preventing traces from being buffered
      # asynchronously. This can occur when there are not enough resources
      # allocated for the amount of usage.
      #
      class AsyncReporterError < Google::Cloud::Error
        # @!attribute [r] count
        #   @return [Array<Google::Cloud::Trace::TraceRecord>] traces The trace
        #   objects that were not written to the API due to the error.
        attr_reader :traces

        def initialize message, traces = nil
          super(message)
          @traces = traces if traces
        end
      end

      ##
      # # AsyncPatchTracesError
      #
      # Used to indicate a problem when patching traces to the API. This can
      # occur when the API returns an error.
      #
      class AsyncPatchTracesError < Google::Cloud::Error
        # @!attribute [r] count
        #   @return [Array<Google::Cloud::Trace::TraceRecord>] traces The trace
        #   objects that were not written to the API due to the error.
        attr_reader :traces

        def initialize message, traces = nil
          super(message)
          @traces = traces if traces
        end
      end
    end
  end
end
