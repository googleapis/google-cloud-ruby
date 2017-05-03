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


require "helper"
require "google/cloud/error_reporting/middleware"
require "action_dispatch"

describe Google::Cloud::ErrorReporting::Middleware, :mock_error_reporting do
  let(:app_exception_msg) { "A serious error from application" }
  let(:project_id) { "gcp-test-name" }
  let(:service_name) { "my-test-service" }
  let(:service_version) { "vTest" }

  class IgnoredError < ::StandardError
  end

  let(:rack_env) {{
    'REQUEST_METHOD' => 'GET',
    'RACK_URL_SCHEME' => 'http',
    'HTTP_HOST' => 'localhost:3000',
    'ORIGINAL_FULLPATH' => "test/path?abc=def",
    'HTTP_USER_AGENT' => 'chrome-1.2.3',
    'HTTP_REFERER' => nil,
    'REMOTE_ADDR' => '127.0.0.1'
  }}
  let(:app_exception) { StandardError.new(app_exception_msg) }
  let(:rack_app) {
    app = OpenStruct.new
    exception = app_exception
    app.define_singleton_method(:call) do |_|
      raise exception
    end
    app
  }
  # let(:error_reporting) {
  #   obj = OpenStruct.new report: Proc.new {}
  #   obj.define_singleton_method(:report_error_event) do end
  #   obj
  # }
  let(:middleware) {
    Google::Cloud::ErrorReporting::Middleware.new rack_app,
                                                  error_reporting: error_reporting,
                                                  project_id: project_id,
                                                  service_name: service_name,
                                                  service_version: service_version,
                                                  ignore_classes: [IgnoredError]
  }
  let(:default_middleware) {
    Google::Cloud::ErrorReporting::Middleware.new rack_app,
                                                  error_reporting: error_reporting,
                                                  project_id: project_id
  }

  describe "#initialize" do
    it "uses the error_reporting given" do
      middleware.error_reporting.must_equal error_reporting
    end

    it "creates a default error_reporting if not given one" do
      Google::Cloud::ErrorReporting.stub :new, "A default error_reporting" do
        middleware = Google::Cloud::ErrorReporting::Middleware.new nil,
                                                                   project_id: project_id

        middleware.error_reporting.must_equal "A default error_reporting"
      end
    end

    it "raises ArgumentError if empty project_id provided" do
      assert_raises ArgumentError do
        # Prevent return of actual project in any environment including GCE, etc.
        Google::Cloud::ErrorReporting::Project.stub :default_project, nil do
          Google::Cloud::ErrorReporting.stub :new, "A default error_reporting" do
            ENV.stub :[], nil do
              Google::Cloud::ErrorReporting::Middleware.new nil
            end
          end
        end
      end
    end
  end

  describe "#call" do
    it "catches exception and also raise it back up" do
      stub_report_exception = ->(_, exception) {
        exception.message.must_equal app_exception_msg
      }

      middleware.stub :report_exception, stub_report_exception do
        exception = assert_raises StandardError do
          middleware.call rack_env
        end

        exception.message.must_equal app_exception_msg
      end
    end

    it "also reports env['sinatra.error'] if exists" do
      stub_call = ->(env) {
        env['sinatra.error'] = app_exception
      }
      stub_report_exception = ->(_, exception) {
        exception.message.must_equal app_exception_msg
      }

      rack_app.stub :call, stub_call do
        middleware.stub :report_exception, stub_report_exception do
          middleware.call rack_env
        end
      end
    end
  end

  describe "#report_exception" do
    it "doesn't call report_exception if exception's class is been ignored" do
      stub_report = ->(_) { fail "This exception should've been ignored" }
      ignore_exception = IgnoredError.new "To be ignored"

      middleware.error_reporting.stub :report, stub_report do
        middleware.report_exception rack_env, ignore_exception
      end
    end

    it "calls error_reporting#report_error_event to report the error" do
      stub_reporting = ->(error_event) {
        error_event.must_be_kind_of Google::Cloud::ErrorReporting::ErrorEvent
      }

      middleware.error_reporting.stub :report, stub_reporting do
        middleware.report_exception rack_env, app_exception
      end
    end

    it "calls error_reporting#report_error_event when no correct status found" do
      stub_error_reporting = MiniTest::Mock.new
      stub_error_reporting.expect :report, nil do |error_event|
        error_event.must_be_kind_of Google::Cloud::ErrorReporting::ErrorEvent
      end
      stub_http_status = ->(exception) {
        exception.message.must_equal app_exception_msg
        nil
      }

      middleware.stub :http_status, stub_http_status do
        middleware.stub :error_reporting, stub_error_reporting do
          middleware.report_exception rack_env, app_exception
        end
      end
    end

    it "doesn't report if the exception maps to a HTTP code less than 500" do
      stub_reporting = ->(_) { fail "This exception should've been skipped" }
      stub_http_status = ->(exception) {
        exception.message.must_equal app_exception_msg
        407
      }

      middleware.stub :http_status, stub_http_status do
        middleware.error_reporting.stub :report, stub_reporting do
          middleware.report_exception rack_env, app_exception
        end
      end
    end
  end

  describe "#build_error_event_from_exception" do
    it "injects service_name and service_version" do
      error_event = middleware.error_event_from_exception rack_env, app_exception

      error_event.service_name.must_equal service_name
      error_event.service_version.must_equal service_version
    end

    it "injects user from ENV['USER']" do
      user = "john_doe"

      ENV.stub :[], user do
        error_event = middleware.error_event_from_exception rack_env, app_exception
        error_event.user.must_equal user
      end
    end
  end

  describe ".http_status" do
    it "returns right http_status code based on exception class" do
      status = middleware.send :http_status, app_exception
      status.must_equal 500
    end

    it "returns right http_status code based on exception class #2" do
      app_exception.class.stub :name, "ActionDispatch::ParamsParser::ParseError" do
        status = middleware.send :http_status, app_exception
        status.must_equal 400
      end
    end
  end
end
