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


module Google
  module Cloud
    module Debugger
      class Middleware
        def initialize app, debugger: nil, module_name:nil, module_version: nil,
                            project: nil, keyfile: nil
          @app = app
          @debugger = debugger ||
                      Cloud::Debugger.new({project: project,
                                           keyfile: keyfile,
                                           module_name: module_name,
                                           module_version: module_version})
          @debugger.start
        end

        def call env
            t = Time.now
            response = @app.call env

            # if @debugger.agent.last_exception
            #   puts "*******************************************************************************"
            #   puts @debugger.agent.last_exception
            #   exit
            # end

            # end_t = Time.now - t
            # f = File.open("debugger_on.txt", "a")
            # f.puts end_t
            # f.close

            # puts Time.now - t

            # @debugger.breakpoint_manager.clear_breakpoints

            response
        end
      end
    end
  end
end
