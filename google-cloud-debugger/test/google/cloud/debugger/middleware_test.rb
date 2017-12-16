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


require "helper"

require "logger"

describe Google::Cloud::Debugger::Middleware, :mock_debugger do
  let(:rack_app) {
    app = OpenStruct.new
    def app.call(_) end
    app
  }
  let(:middleware) {
    Google::Cloud::Debugger::Middleware.new rack_app, debugger: debugger
  }

  after {
    Google::Cloud::Debugger.configure.instance_variable_get(:@configs).clear
    Google::Cloud.configure.delete :use_debugger

    debugger.stop
  }

  describe "#call" do
    it "calls Tracer#start and Tracer#disable_traces_for_thread for each request" do
      mocked_tracer = Minitest::Mock.new
      mocked_tracer.expect :start, nil
      mocked_tracer.expect :disable_traces_for_thread, nil

      # Construct middleware
      middleware

      debugger.agent.stub :tracer, mocked_tracer do
        middleware.call({})
      end

      mocked_tracer.verify
    end

    it "swaps debugger agent's logger if there's an Stackdriver Logger set for the Rack already" do
      logger = Google::Cloud::Logging::Logger.new nil, nil, nil
      debugger = middleware.instance_variable_get :@debugger
      env = { "rack.logger" => logger }

      debugger.agent.logger.wont_equal logger

      middleware.call env

      debugger.agent.logger.must_equal logger
    end

    it "doesn't swap debugger agent's logger if rack.logger isn't a Stackdriver Logger" do
      logger = Logger.new(STDOUT)
      debugger = middleware.instance_variable_get :@debugger
      env = { "rack.logger" => logger }

      debugger.agent.logger.wont_equal logger

      middleware.call env

      debugger.agent.logger.wont_equal logger
    end

    it "resets quota after each request" do
      debugger.agent.quota_manager = Google::Cloud::Debugger::RequestQuotaManager.new

      stubbed_call = ->(_) {
        debugger.agent.quota_manager.count_quota.times do
          debugger.agent.quota_manager.consume
        end

        debugger.agent.quota_manager.more?.must_equal false
      }

      rack_app.stub :call, stubbed_call do
        middleware.call({})

        debugger.agent.quota_manager.more?.must_equal true
      end
    end
  end
end

