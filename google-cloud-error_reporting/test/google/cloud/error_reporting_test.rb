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

describe Google::Cloud::ErrorReporting, :mock_error_reporting do
  describe ".new" do
    let(:default_credentials) do
      creds = OpenStruct.new empty: true
      def creds.is_a? target
        target == Google::Auth::Credentials
      end
      creds
    end
    let(:found_credentials) { "{}" }

    it "gets defaults for project-id, keyfile, service, and version" do
      ENV.stub :[], nil do
        Google::Cloud::ErrorReporting::Project.stub :default_project_id, "test-project-id" do
          Google::Cloud::ErrorReporting::Credentials.stub :default, default_credentials do
            error_reporting = Google::Cloud::ErrorReporting.new
            error_reporting.must_be_kind_of Google::Cloud::ErrorReporting::Project
            error_reporting.project.must_equal "test-project-id"
            error_reporting.service.credentials.must_equal default_credentials
          end
        end
      end
    end

    it "uses provided project_id, credentials, service, and version" do
      stubbed_credentials = ->(keyfile, scope: scope) {
        keyfile.must_equal "/path/to/a/keyfile"
        scope.must_be_nil
        "error_reporting-credentials"
      }

      ENV.stub :[], nil do
        File.stub :file?, true, ["/path/to/a/keyfile"] do
          File.stub :read, found_credentials, ["/path/to/a/keyfile"] do
            Google::Cloud::ErrorReporting::Credentials.stub :new, stubbed_credentials do
              error_reporting = Google::Cloud::ErrorReporting.new project_id: "test-project-id",
                                                                  credentials: "/path/to/a/keyfile"
              error_reporting.must_be_kind_of Google::Cloud::ErrorReporting::Project
              error_reporting.project.must_equal "test-project-id"
              error_reporting.service.must_be_kind_of Google::Cloud::ErrorReporting::Service
            end
          end
        end
      end
    end

    it "uses provided project (alias), keyfile (alias), service, and version" do
      stubbed_credentials = ->(keyfile, scope: scope) {
        keyfile.must_equal "/path/to/a/keyfile"
        scope.must_be_nil
        "error_reporting-credentials"
      }

      ENV.stub :[], nil do
        File.stub :file?, true, ["/path/to/a/keyfile"] do
          File.stub :read, found_credentials, ["/path/to/a/keyfile"] do
            Google::Cloud::ErrorReporting::Credentials.stub :new, stubbed_credentials do
              error_reporting = Google::Cloud::ErrorReporting.new project: "test-project-id",
                                                                  keyfile: "/path/to/a/keyfile"
              error_reporting.must_be_kind_of Google::Cloud::ErrorReporting::Project
              error_reporting.project.must_equal "test-project-id"
              error_reporting.service.must_be_kind_of Google::Cloud::ErrorReporting::Service
            end
          end
        end
      end
    end

    it "errors when provided empty project_id" do
      Google::Cloud::ErrorReporting::Credentials.stub :default, default_credentials do
        exception = assert_raises ArgumentError do
          Google::Cloud::ErrorReporting.new project: ""
        end

        exception.message.must_equal "project_id is missing"
      end
    end
  end

  describe ".configure" do
    it "has Google::Cloud.configure.error_reporting initialized already" do
      Google::Cloud.configure.option?(:error_reporting).must_equal true
    end

    it "operates on the same Configuration object as Google::Cloud.configure.error_reporting" do
      Google::Cloud::ErrorReporting.configure.must_equal Google::Cloud.configure.error_reporting
    end
  end

  describe ".report" do
    let(:exception) { RuntimeError.new "test-exception" }

    before {
      Google::Cloud::ErrorReporting.class_variable_set :@@default_client, nil
      Google::Cloud::ErrorReporting.class_variable_get(:@@default_client).must_be_nil
    }

    after {
      Google::Cloud::ErrorReporting.class_variable_set :@@default_client, nil
      Google::Cloud::ErrorReporting.class_variable_get(:@@default_client).must_be_nil
    }

    it "doesn't call Project#report_exception if Google::Cloud.configure.use_error_reporting is false" do
      stubbed_configure = OpenStruct.new use_error_reporting: false
      stubbed_report = ->(_) { fail "Shouldn't be called" }
      Google::Cloud::ErrorReporting.class_variable_set :@@default_client, error_reporting

      error_reporting.stub :report, stubbed_report do
        Google::Cloud.stub :configure, stubbed_configure do
          Google::Cloud::ErrorReporting.report exception
        end
      end
    end

    it "calls Project#report with the given service_name and service_version" do
      mocked_client = Minitest::Mock.new
      mocked_client.expect :report, nil do |event|
        event.service_name.must_equal "test-service-name"
        event.service_version.must_equal "test-service-version"
      end

      Google::Cloud::ErrorReporting.stub :default_client, mocked_client do
        Google::Cloud::ErrorReporting.report exception, service_name: "test-service-name",
                                                        service_version: "test-service-version"
      end

      mocked_client.verify
    end

    it "fallback to use service_name and service_version from Google::Cloud::ErrorReporting.configure" do
      stubbed_config = OpenStruct.new service_name: "test-service-name", service_version: "test-service-version"
      mocked_client = Minitest::Mock.new
      mocked_client.expect :report, nil do |event|
        event.service_name.must_equal "test-service-name"
        event.service_version.must_equal "test-service-version"
      end

      Google::Cloud::ErrorReporting.stub :configure, stubbed_config do
        Google::Cloud::ErrorReporting.stub :default_client, mocked_client do
          Google::Cloud::ErrorReporting.report exception
        end
      end
    end

    it "fallback to use Project.default_service_name and Project.default_service_version" do
      stubbed_config = OpenStruct.new service_name: nil, service_version: nil
      mocked_client = Minitest::Mock.new
      mocked_client.expect :report, nil do |event|
        event.service_name.must_equal "test-service-name"
        event.service_version.must_equal "test-service-version"
      end

      Google::Cloud::ErrorReporting.stub :configure, stubbed_config do
        Google::Cloud::ErrorReporting::Project.stub :default_service_name, "test-service-name" do
          Google::Cloud::ErrorReporting::Project.stub :default_service_version, "test-service-version" do
            Google::Cloud::ErrorReporting.stub :default_client, mocked_client do
              Google::Cloud::ErrorReporting.report exception
            end
          end
        end
      end
    end
  end

  describe ".default_client" do
    it "uses the config options from Google::Cloud::ErrorReporting.configure" do
      stubbed_config = OpenStruct.new project_id: "test-project-id", keyfile: "test-keyfile"

      stubbed_new = ->(args) {
        args[:project].must_equal "test-project-id"
        args[:keyfile].must_equal "test-keyfile"
      }

      Google::Cloud::ErrorReporting.stub :configure, stubbed_config do
        Google::Cloud::ErrorReporting.stub :new, stubbed_new do
          Google::Cloud::ErrorReporting.send :default_client
        end
      end
    end

    it "uses the project_id and keyfile from Google::Cloud.configure if missing from Google::Cloud::ErrorReporting.configure" do
      stubbed_er_config = OpenStruct.new project_id: nil, keyfile: nil
      stubbed_gcloud_config = OpenStruct.new project_id: "test-project-id", keyfile: "test-keyfile"

      stubbed_new = ->(args) {
        args[:project].must_equal "test-project-id"
        args[:keyfile].must_equal "test-keyfile"
      }

      Google::Cloud::ErrorReporting.stub :configure, stubbed_er_config do
        Google::Cloud.stub :configure, stubbed_gcloud_config do
          Google::Cloud::ErrorReporting.stub :new, stubbed_new do
            Google::Cloud::ErrorReporting.send :default_client
          end
        end
      end
    end

    it "returns the same client across calls" do
      stubbed_async_reporter = "a error reporting client"

      Google::Cloud::ErrorReporting::AsyncErrorReporter.stub :new, stubbed_async_reporter do
        Google::Cloud::ErrorReporting.stub :new, nil do
          first_client = Google::Cloud::ErrorReporting.send :default_client
          Google::Cloud::ErrorReporting.send(:default_client).must_equal first_client
        end
      end
    end
  end
end
