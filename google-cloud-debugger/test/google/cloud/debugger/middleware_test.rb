# Copyright 2017 Google LLC
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

  before do
    # Clear configuration values between each test
    Google::Cloud.configure.reset!
  end

  after do
    # Clear configuration values between each test
    Google::Cloud.configure.reset!
    Google::Cloud::Debugger::Middleware.reset_deferred_start
    debugger.stop
  end

  describe ".start_agents" do
    it "starts pending agents" do
      Google::Cloud::Debugger::Credentials.stub :default, "/default/keyfile.json" do
        middleware
        _(debugger.agent.async_running?).must_equal false
        Google::Cloud::Debugger::Middleware.start_agents
        _(debugger.agent.async_running?).must_equal true
      end
    end

    it "causes later agents to start automatically" do
      Google::Cloud::Debugger::Credentials.stub :default, "/default/keyfile.json" do
        Google::Cloud::Debugger::Middleware.start_agents
        _(debugger.agent.async_running?).must_equal false
        middleware
        _(debugger.agent.async_running?).must_equal true
      end
    end

    it "is idempotent" do
      Google::Cloud::Debugger::Credentials.stub :default, "/default/keyfile.json" do
        middleware
        Google::Cloud::Debugger::Middleware.start_agents
        Google::Cloud::Debugger::Middleware.start_agents
        _(debugger.agent.async_running?).must_equal true
      end
    end
  end

  describe "#call" do
    it "calls Tracer#start and Tracer#disable_traces_for_thread for each request" do
      Google::Cloud::Debugger::Credentials.stub :default, "/default/keyfile.json" do
        mocked_tracer = Minitest::Mock.new
        mocked_tracer.expect :start, nil
        mocked_tracer.expect :disable_traces_for_thread, nil

        # Construct middleware
        middleware
        Google::Cloud::Debugger::Middleware.start_agents

        debugger.agent.stub :tracer, mocked_tracer do
          middleware.call({})
        end

        mocked_tracer.verify
      end
    end

    it "swaps debugger agent's logger if there's an Stackdriver Logger set for the Rack already" do
      Google::Cloud::Debugger::Credentials.stub :default, "/default/keyfile.json" do
        logger = Google::Cloud::Logging::Logger.new nil, nil, nil
        debugger = middleware.instance_variable_get :@debugger
        env = { "rack.logger" => logger }

        _(debugger.agent.logger).wont_equal logger

        middleware.call env

        _(debugger.agent.logger).must_equal logger
      end
    end

    it "doesn't swap debugger agent's logger if rack.logger isn't a Stackdriver Logger" do
      Google::Cloud::Debugger::Credentials.stub :default, "/default/keyfile.json" do
        logger = Logger.new(STDOUT)
        debugger = middleware.instance_variable_get :@debugger
        env = { "rack.logger" => logger }

        _(debugger.agent.logger).wont_equal logger

        middleware.call env

        _(debugger.agent.logger).wont_equal logger
      end
    end

    it "resets quota after each request" do
      Google::Cloud::Debugger::Credentials.stub :default, "/default/keyfile.json" do
        debugger.agent.quota_manager = Google::Cloud::Debugger::RequestQuotaManager.new

        stubbed_call = ->(*) {
          debugger.agent.quota_manager.count_quota.times do
            debugger.agent.quota_manager.consume
          end

          _(debugger.agent.quota_manager.more?).must_equal false
        }

        rack_app.stub :call, stubbed_call do
          middleware.call({})

          _(debugger.agent.quota_manager.more?).must_equal true
        end
      end
    end
  end
end
