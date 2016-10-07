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



require "ostruct"
require "minitest/focus"
require 'google/cloud/error_reporting/middleware'

describe Google::Cloud::ErrorReporting::Middleware do
  APP_EXCEPTION_MSG = "A serious error from application"
  VALID_ERROR_EVENT = "A valid error event"
  SERVICE_NAME = "My microservice"
  SERVICE_VERSION = "Version testing"

  class IgnoredError < ::StandardError
  end

  before do
    @env = {
      'REQUEST_METHOD' => 'GET',
      'RACK_URL_SCHEME' => 'http',
      'HTTP_HOST' => 'localhost:3000',
      'ORIGINAL_FULLPATH' => "test/path?abc=def",
      'HTTP_USER_AGENT' => 'chrome-1.2.3',
      'HTTP_REFERER' => nil,
      'REMOTE_ADDR' => '127.0.0.1'
    }

    @app_exception = StandardError.new(APP_EXCEPTION_MSG)
    app = OpenStruct.new
    def app.call env
      fail StandardError, APP_EXCEPTION_MSG
    end
    error_reporting = OpenStruct.new report: Proc.new {}
    def error_reporting.error_event message, params
      VALID_ERROR_EVENT
    end

    @middleware = Google::Cloud::ErrorReporting::Middleware.new(
                    app,
                    error_reporting: error_reporting,
                    service_name: SERVICE_NAME,
                    service_version: SERVICE_VERSION,
                    ignore: [IgnoredError]
                  )
    @default_middleware = Google::Cloud::ErrorReporting::Middleware.new(
                            app,
                            error_reporting: error_reporting
                          )
  end

  describe "#initialize" do
    it "uses the error_reporting given" do
      @middleware.error_reporting.error_event(nil, nil).must_equal(
        VALID_ERROR_EVENT
      )
    end

    it "creates a default error_reporting if not given one" do
      Google::Cloud.stub :error_reporting, "A default error_reporting" do
        middleware = Google::Cloud::ErrorReporting::Middleware.new nil

        middleware.error_reporting.must_equal "A default error_reporting"
      end
    end
  end

  describe "#call" do
    it "catches exception and also raise it back up" do
      stub_report_exception = ->(_, exception) {
        exception.message.must_equal APP_EXCEPTION_MSG
      }

      @middleware.stub :report_exception, stub_report_exception do
        exception = assert_raises StandardError do
          @middleware.call @env
        end

        exception.message.must_equal APP_EXCEPTION_MSG
      end
    end
  end

  describe "#report_exception" do
    it "doesn't call report_exception if exception's class is been ignored" do
      stub_report = ->(_) { fail "This exception should've been ignored" }
      ignore_exception = IgnoredError.new "To be ignored"

      @middleware.error_reporting.stub :report, stub_report do
        @middleware.report_exception @env, ignore_exception
      end
    end

    it "calls error_reporting#report to report the error" do
      stub_reporting = ->(error_event) {
        error_event.is_a? Google::Cloud::ErrorReporting::ErrorEvent
      }

      @middleware.error_reporting.stub :report, stub_reporting do
        @middleware.report_exception @env, @app_exception
      end
    end

    it "doesn't report if the exception maps to a HTTP code less than 500" do
      stub_reporting = ->(_) { fail "This exception should've been skipped" }
      stub_http_status = ->(exception) {
        exception.message.must_equal APP_EXCEPTION_MSG
        407
      }


      @middleware.class.stub :get_http_status, stub_http_status do
        @middleware.error_reporting.stub :report, stub_reporting do
          @middleware.report_exception @env, @app_exception
        end
      end
    end

    it "injects service_name and service_version" do
      stub_reporting = ->(error_event) {
        error_event.service_context.service.must_equal SERVICE_NAME
        error_event.service_context.version.must_equal SERVICE_VERSION
      }

      @middleware.error_reporting.stub :report, stub_reporting do
        @middleware.report_exception @env, @app_exception
      end
    end

    it "add default service name and version" do
      service_name = "My other service"
      service_version = "A different version"
      stub_reporting = ->(error_event) {
        error_event.service_context.service.must_equal service_name
        error_event.service_context.version.must_equal service_version
      }

      Google::Cloud::ErrorReporting::Project.stub :default_service_name, service_name do
        Google::Cloud::ErrorReporting::Project.stub :default_service_version, service_version do
          @default_middleware.error_reporting.stub :report, stub_reporting do
            @default_middleware.report_exception @env, @app_exception
          end
        end
      end
    end

    it "injects user from ENV['USER']" do
      user = "john_doe"
      stub_reporting = ->(error_event) {
        error_event.error_context.user.must_equal user
      }

      @middleware.error_reporting.stub :report, stub_reporting do
        ENV.stub :[], user do
          @middleware.report_exception @env, @app_exception
        end
      end
    end

    it "changes binary string to utf-8 string" do
      stub_report = ->(error_event) {
        error_event.error_context.http_request_context.user_agent.encoding.name.must_equal "UTF-8"
      }
      envdup = @env.dup
      envdup["HTTP_USER_AGENT"].force_encoding("BINARY")

      @middleware.error_reporting.stub :report, stub_report do
        @middleware.report_exception envdup, @app_exception
      end
    end

    it "filters out invalid utf-8 string parameter" do
      stub_report = ->(error_event) {
        error_event.error_context.http_request_context.user_agent.must_be :nil?
      }
      envdup = @env.dup
      envdup['HTTP_USER_AGENT'] = "Invalid User \xFF Agent".encode("utf-8")

      @middleware.error_reporting.stub :report, stub_report do
        @middleware.report_exception envdup, @app_exception
      end
    end
  end

  describe ".get_http_status" do
    it "returns right http_status code based on exception class" do
      require "action_dispatch"

      status = @middleware.class.get_http_status @app_exception
      status.must_equal 500
    end

    it "returns right http_status code based on exception class #2" do
      require "action_dispatch"

      @app_exception.class.stub :name, "ActionDispatch::ParamsParser::ParseError" do
        status = @middleware.class.get_http_status @app_exception
        status.must_equal 400
      end
    end
  end
end
