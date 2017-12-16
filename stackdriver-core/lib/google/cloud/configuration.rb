# Copyright 2017 Google LLC
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


require "stackdriver/core/configuration"

module Google
  module Cloud
    ##
    # @private Defines Google::Cloud.configure method. This will be the root
    # configuration object shared by Stackdriver instrumentation libraries'
    # configurations.
    module Configuration
      ##
      # @private The shared Configuration object that all the Stackdriver
      # instrumentation libraries will build on top of.
      @@config = ::Stackdriver::Core::Configuration.new

      ##
      # Configure the default parameter for Google::Cloud. The values defined on
      # this top level will be shared across all Stackdriver instrumentation
      # libraries (Debugger, ErrorReporting, Logging, and Trace). These other
      # libraries may also add sub configuration options under this.
      #
      # Possible configuration parameters:
      #   * project_id: The Google Cloud Project ID. Automatically discovered
      #                 when running from GCP environments.
      #   * keyfile: The service account JSON file path. Automatically
      #              discovered when running from GCP environments.
      #   * use_debugger: Explicitly enable or disable Stackdriver Debugger
      #                   instrumentation
      #   * use_error_reporting: Explicitly enable or disable Stackdriver Error
      #                          Reporting instrumentation
      #   * use_logging: Explicitly enable or disable Stackdriver Logging
      #                  instrumentation
      #   * use_trace: Explicitly enable or disable Stackdriver
      #
      # @return [Stackdriver::Core::Configuration] The configuration object
      #   the Google::Cloud module uses.
      #
      def configure
        yield @@config if block_given?

        @@config
      end
    end

    # Immediately extend Google::Cloud::Configuration#configure
    # into Google::Cloud.configure
    extend Configuration
  end
end
