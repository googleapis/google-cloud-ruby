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
    module Logging
      ##
      # # AsyncWriterError
      #
      # Used to indicate a problem preventing {AsyncWriter} from asynchronously
      # calling the API. This can occur when the {AsyncWriter} has too few
      # resources allocated for the amount of usage.
      #
      # @example
      #   require "google/cloud/logging"
      #   require "google/cloud/error_reporting"
      #
      #   logging = Google::Cloud::Logging.new
      #
      #   resource = logging.resource "gae_app",
      #                               module_id: "1",
      #                               version_id: "20150925t173233"
      #
      #   async = logging.async_writer
      #
      #   # Register to be notified when unhandled errors occur.
      #   async.on_error do |error|
      #     # error can be a AsyncWriterError, with entries
      #     Google::Cloud::ErrorReporting.report error
      #   end
      #
      #   logger = async.logger "my_app_log", resource, env: :production
      #   logger.info "Job started."
      #
      class AsyncWriterError < Google::Cloud::Error
        # @!attribute [r] count
        #   @return [Array<Google::Cloud::Logging::Entry>] entries The entry
        #   objects that were not written to the API due to the error.
        attr_reader :entries

        def initialize message, entries = nil
          super(message)
          @entries = entries if entries
        end
      end

      ##
      # # AsyncWriteEntriesError
      #
      # Used to indicate a problem when {AsyncWriter} writes log entries to the
      # API. This can occur when the API returns an error.
      #
      # @example
      #   require "google/cloud/logging"
      #   require "google/cloud/error_reporting"
      #
      #   logging = Google::Cloud::Logging.new
      #
      #   resource = logging.resource "gae_app",
      #                               module_id: "1",
      #                               version_id: "20150925t173233"
      #
      #   async = logging.async_writer
      #
      #   # Register to be notified when unhandled errors occur.
      #   async.on_error do |error|
      #     # error can be a AsyncWriteEntriesError, with entries
      #     Google::Cloud::ErrorReporting.report error
      #   end
      #
      #   logger = async.logger "my_app_log", resource, env: :production
      #   logger.info "Job started."
      #
      class AsyncWriteEntriesError < Google::Cloud::Error
        # @!attribute [r] count
        #   @return [Array<Google::Cloud::Logging::Entry>] entries The entry
        #   objects that were not written to the API due to the error.
        attr_reader :entries

        def initialize message, entries = nil
          super(message)
          @entries = entries if entries
        end
      end
    end
  end
end
