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

##
# This file is here to be autorequired by bundler, so that the .logging and
# #logging methods can be available, but the library and all dependencies won't
# be loaded until required and used.


gem "google-cloud-core"
require "google/cloud"

module Google
  module Cloud
    def debugger module_name: nil, module_version: nil, scope: nil,
                 timeout: nil, client_config: nil
      Google::Cloud.debugger @project, @keyfile, module_name: module_name,
                                                 module_version: module_version,
                                                 scope: scope,
                                                 timeout: (timeout || @timeout),
                                                 client_config: client_config
    end

    def self.debugger project = nil, keyfile = nil, module_name: nil,
                      module_version: nil, scope: nil, timeout: nil,
                      client_config: nil
      require "google/cloud/debugger"
      Google::Cloud::Debugger.new project: project, keyfile: keyfile,
                                  module_name: module_name,
                                  module_version: module_version,
                                  scope: scope, timeout: timeout,
                                  client_config: client_config
    end
  end
end
