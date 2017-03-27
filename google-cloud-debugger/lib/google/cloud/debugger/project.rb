# Copyright 2017 Google Inc. All rights reserved.
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


require "google/cloud/errors"
require "google/cloud/core/environment"
require "google/cloud/debugger/agent"
require "google/cloud/debugger/credentials"
require "google/cloud/debugger/middleware"
require "google/cloud/debugger/service"

module Google
  module Cloud
    module Debugger
      class Project
        ##
        # @private The gRPC Service object.
        attr_accessor :service

        attr_reader :agent

        ##
        # @private Creates a new Connection instance.
        def initialize service, module_name:, module_version:
          @service = service
          @agent = Agent.new service, module_name: module_name,
                                      module_version: module_version
        end

        def project
          service.project
        end

        ##
        # @private Default project.
        def self.default_project
          ENV["DEBUGGER_PROJECT"] ||
            ENV["GOOGLE_CLOUD_PROJECT"] ||
            ENV["GCLOUD_PROJECT"] ||
            Google::Cloud::Core::Environment.project_id
        end

        def self.default_module_name
          ENV["DEBUGGER_MODULE_NAME"] ||
            Google::Cloud::Core::Environment.gae_module_id ||
            "ruby-app"
        end

        def self.default_module_version
          ENV["DEBUGGER_MODULE_VERSION"] ||
            Google::Cloud::Core::Environment.gae_module_version ||
            ""
        end

        def start
          agent.start
        end
        alias_method :attach, :start

        def stop
          agent.stop
        end
      end
    end
  end
end
