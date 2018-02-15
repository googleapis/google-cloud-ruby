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

        error_event.service_name.must_equal "ruby"
        error_event.service_version.must_be_nil

        error_event.message.must_be_nil
        error_event.event_time.must_be_nil
        error_event.user.must_be_nil
        error_event.http_url.must_be_nil
      end
    end

    it "creates an error_event with all attributes" do
      message = 'Another Error'
      service_name = "secret-service"
      service_version = "v987"
      timestamp = Time.parse "2014-10-02T15:01:23.045123456Z"
      user = 'john_smith'
      file_path = "/path/to/file"
      line_number = 567
      function_name = "GreatSub"

      error_event = error_reporting.error_event message,
                                                service_name: service_name,
                                                service_version: service_version,
                                                event_time: timestamp,
                                                user: user,
                                                file_path: file_path,
                                                line_number: line_number,
                                                function_name: function_name

      error_event.service_name.must_equal service_name
      error_event.service_version.must_equal service_version

      error_event.message.must_equal message
      error_event.event_time.must_equal timestamp
      error_event.user.must_equal user
      error_event.file_path.must_equal file_path
      error_event.line_number.must_equal line_number
      error_event.function_name.must_equal function_name
    end
  end

  describe "#report_exception" do
    let(:exception_msg) { "A serious error from application" }
    let(:service_name) { "my-service" }
    let(:service_version) { "vTesting" }

    it "injects service_name and service_version" do
      stub_report = ->(error_event) {
        error_event.service_name.must_equal service_name
        error_event.service_version.must_equal service_version
      }

      error_reporting.stub :report, stub_report do
        exception = StandardError.new  exception_msg
        error_reporting.report_exception exception, service_name: service_name,
                                         service_version: service_version
      end
    end

    it "injects default service_name and service_version if not provided" do
      stub_report = ->(error_event) {
        error_event.service_name.must_equal service_name
        error_event.service_version.must_equal service_version
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

    it "calls report with an transformed ErrorEvent object" do
      mocked_report = Minitest::Mock.new
      mocked_report.expect :call, nil, [Google::Cloud::ErrorReporting::ErrorEvent]

      error_reporting.stub :report, mocked_report do
        exception = StandardError.new exception_msg
        error_reporting.report_exception exception
      end

      mocked_report.verify
    end
  end

  describe ".default_project_id" do
    it "calls Google::Cloud.env.project_id if no environment variable found" do
      Google::Cloud.env.stub :project_id, "another-project" do
        ENV.stub :[], nil do
          Google::Cloud::ErrorReporting::Project.default_project_id.must_equal "another-project"
        end
      end
    end
  end

  describe ".default_service_name" do
    it "calls Google::Cloud.env.app_engine_service_id if no environment variable found" do
      Google::Cloud.env.stub :app_engine_service_id, "another-service-id" do
        ENV.stub :[], nil do
          Google::Cloud::ErrorReporting::Project.default_service_name.must_equal "another-service-id"
        end
      end
    end

    it "defaults to 'ruby'" do
      Google::Cloud.env.stub :app_engine_service_id, nil do
        ENV.stub :[], nil do
          Google::Cloud::ErrorReporting::Project.default_service_name.must_equal "ruby"
        end
      end
    end
  end

  describe ".default_service_version" do
    it "calls Google::Cloud.env.app_engine_service_version if no environment variable found" do
      Google::Cloud.env.stub :app_engine_service_version, "another-service-version" do
        ENV.stub :[], nil do
          Google::Cloud::ErrorReporting::Project.default_service_version.must_equal "another-service-version"
        end
      end
    end
  end
end
