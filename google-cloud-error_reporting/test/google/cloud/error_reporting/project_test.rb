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


require "minitest/focus"
require "helper"

describe Google::Cloud::ErrorReporting::Project, :mock_error_reporting do
  it "knows the project identifier" do
    error_reporting.must_be_kind_of Google::Cloud::ErrorReporting::Project
    error_reporting.project.must_equal project
  end

  describe "#error_event" do
    it "creates an empty error_event" do
      ENV.stub :[], nil do
        error_event = error_reporting.error_event
        error_event.must_be_kind_of Google::Cloud::ErrorReporting::ErrorEvent

        error_event.service_context.service.must_equal "ruby"
        error_event.service_context.version.must_be :nil?

        error_event.message.must_be :empty?
        error_event.timestamp.must_be :nil?
        error_event.error_context.user.must_be :nil?
        error_event.error_context.http_request_context.url.must_be :nil?
      end
    end

    it "creates an error_event with all attributes" do
      message = 'Another Error'
      service_name = "secret-service"
      service_version = "v987"
      timestamp = Time.parse "2014-10-02T15:01:23.045123456Z"
      user = 'john_smith'
      http_method = 'DELETE'
      http_url = 'http://test.org'
      http_user_agent = 'chrome_ua'
      http_referrer = 'http://test.google.com'
      http_status = 302
      http_remote_ip = '192.168.0.1:80'
      file_path = "/path/to/file"
      line_number = 567
      function_name = "GreatSub"

      error_event = error_reporting.error_event message,
                                                service_name: service_name,
                                                service_version: service_version,
                                                timestamp: timestamp,
                                                user: user,
                                                http_method: http_method,
                                                http_url: http_url,
                                                http_user_agent: http_user_agent,
                                                http_referrer: http_referrer,
                                                http_status: http_status,
                                                http_remote_ip: http_remote_ip,
                                                file_path: file_path,
                                                line_number: line_number,
                                                function_name: function_name

      error_event.service_context.service.must_equal service_name
      error_event.service_context.version.must_equal service_version

      error_event.message.must_equal message
      error_event.timestamp.must_equal timestamp
      error_event.error_context.user.must_equal user
      error_event.error_context.http_request_context.method.must_equal http_method
      error_event.error_context.http_request_context.url.must_equal http_url
      error_event.error_context.http_request_context.user_agent.must_equal http_user_agent
      error_event.error_context.http_request_context.referrer.must_equal http_referrer
      error_event.error_context.http_request_context.status.must_equal http_status
      error_event.error_context.http_request_context.remote_ip.must_equal http_remote_ip
      error_event.error_context.source_location.file_path.must_equal file_path
      error_event.error_context.source_location.line_number.must_equal line_number
      error_event.error_context.source_location.function_name.must_equal function_name
    end
  end

  describe "#report_exception" do
    exception_msg = "A serious error from application"
    service_name = "my-microservice"
    service_version ="vTesting"

    it "injects service_name and service_version" do
      stub_report = ->(error_event) {
        error_event.service_context.service.must_equal service_name
        error_event.service_context.version.must_equal service_version
      }

      error_reporting.stub :report, stub_report do
        exception = StandardError.new  exception_msg
        error_reporting.report_exception exception, service_name: service_name,
                                                    service_version: service_version
      end
    end

    it "injects default service_name and service_version if not provided" do
      stub_report = ->(error_event) {
        error_event.service_context.service.must_equal service_name
        error_event.service_context.version.must_equal service_version
      }

      error_reporting.class.stub :default_service_name, service_name do
        error_reporting.class.stub :default_service_version, service_version do
          error_reporting.stub :report, stub_report do
            exception = StandardError.new  exception_msg
            error_reporting.report_exception exception
          end
        end
      end
    end
  end

end
