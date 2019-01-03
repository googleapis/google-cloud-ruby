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
      stubbed_credentials = ->(keyfile, scope: nil) {
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
      stubbed_credentials = ->(keyfile, scope: nil) {
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
      assert Google::Cloud::ErrorReporting.configure.equal? Google::Cloud.configure.error_reporting
    end
  end

  describe ".report" do
    let(:exception) { RuntimeError.new "test-exception" }

    before {
      Google::Cloud::ErrorReporting.class_variable_set :@@default_client, nil
      Google::Cloud::ErrorReporting.class_variable_get(:@@default_client).must_be_nil
    }

    after {
      Google::Cloud.configure.reset!
      Google::Cloud::ErrorReporting.configure.reset!
      Google::Cloud::ErrorReporting.class_variable_set :@@default_client, nil
      Google::Cloud::ErrorReporting.class_variable_get(:@@default_client).must_be_nil
    }

    it "doesn't call Project#report_exception if Google::Cloud.configure.use_error_reporting is false" do
      Google::Cloud.configure do |config|
        config.use_error_reporting = false
      end
      stubbed_report = ->(_) { fail "Shouldn't be called" }
      Google::Cloud::ErrorReporting.class_variable_set :@@default_client, error_reporting

      error_reporting.stub :report, stubbed_report do
        Google::Cloud::ErrorReporting.report exception
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
      Google::Cloud::ErrorReporting.configure do |config|
        config.service_name = "test-service-name"
        config.service_version = "test-service-version"
      end
      mocked_client = Minitest::Mock.new
      mocked_client.expect :report, nil do |event|
        event.service_name.must_equal "test-service-name"
        event.service_version.must_equal "test-service-version"
      end

      Google::Cloud::ErrorReporting.stub :default_client, mocked_client do
        Google::Cloud::ErrorReporting.report exception
      end
    end

    it "sets exception backtrace when missing" do
      Google::Cloud::ErrorReporting.configure do |config|
        config.service_name = "test-service-name"
        config.service_version = "test-service-version"
      end
      mocked_client = Minitest::Mock.new
      mocked_client.expect :report, nil do |event|
        event.service_name.must_equal "test-service-name"
        event.service_version.must_equal "test-service-version"
        event.file_path.must_equal "error_reporting.rb"
        event.line_number.must_equal 123
        event.function_name.must_equal "report"
      end

      Google::Cloud::ErrorReporting.stub :default_client, mocked_client do
        Google::Cloud::ErrorReporting.stub :caller, ["error_reporting.rb:123:in `report'"] do
          Google::Cloud::ErrorReporting.report exception
        end
      end
    end
  end

  describe ".default_client" do
    after {
      Google::Cloud.configure.reset!
      Google::Cloud::ErrorReporting.configure.reset!
    }

    it "uses the project_id and credentials from Google::Cloud::ErrorReporting.configure" do
      Google::Cloud::ErrorReporting.configure do |config|
        config.project_id = "test-project-id"
        config.credentials = "test-keyfile"
      end

      stubbed_new = ->(args) {
        args[:project_id].must_equal "test-project-id"
        args[:credentials].must_equal "test-keyfile"
      }

      Google::Cloud::ErrorReporting.stub :new, stubbed_new do
        Google::Cloud::ErrorReporting.send :default_client
      end
    end

    it "uses the project and keyfile from Google::Cloud::ErrorReporting.configure" do
      Google::Cloud::ErrorReporting.configure do |config|
        config.project = "test-project-id"
        config.keyfile = "test-keyfile"
      end

      stubbed_new = ->(args) {
        args[:project_id].must_equal "test-project-id"
        args[:credentials].must_equal "test-keyfile"
      }

      Google::Cloud::ErrorReporting.stub :new, stubbed_new do
        Google::Cloud::ErrorReporting.send :default_client
      end
    end

    it "uses the project_id and credentials from Google::Cloud.configure if missing from Google::Cloud::ErrorReporting.configure" do
      Google::Cloud.configure do |config|
        config.project_id = "test-project-id"
        config.credentials = "test-keyfile"
      end

      stubbed_new = ->(args) {
        args[:project_id].must_equal "test-project-id"
        args[:credentials].must_equal "test-keyfile"
      }

      Google::Cloud::ErrorReporting.stub :new, stubbed_new do
        Google::Cloud::ErrorReporting.send :default_client
      end
    end

    it "uses the project and keyfile from Google::Cloud.configure if missing from Google::Cloud::ErrorReporting.configure" do
      Google::Cloud.configure do |config|
        config.project = "test-project-id"
        config.keyfile = "test-keyfile"
      end

      stubbed_new = ->(args) {
        args[:project_id].must_equal "test-project-id"
        args[:credentials].must_equal "test-keyfile"
      }

      Google::Cloud::ErrorReporting.stub :new, stubbed_new do
        Google::Cloud::ErrorReporting.send :default_client
      end
    end

    it "returns the same client across calls" do
      Google::Cloud::ErrorReporting.configure do |config|
        config.project_id = "test-project-id"
        config.credentials = "test-keyfile"
      end

      stubbed_async_reporter = "a error reporting client"

      Google::Cloud::ErrorReporting::AsyncErrorReporter.stub :new, stubbed_async_reporter do
        Google::Cloud::ErrorReporting.stub :new, nil do
          first_client = Google::Cloud::ErrorReporting.send :default_client
          Google::Cloud::ErrorReporting.send(:default_client).must_equal first_client
        end
      end
    end
  end

  describe "ErrorReporting.configure" do
    let(:found_credentials) { "{}" }
    let :error_reporting_client_config do
      {"interfaces"=>
        {"google.error_reporting.v1.ErrorReporting"=>
          {"retry_codes"=>{"idempotent"=>["DEADLINE_EXCEEDED", "UNAVAILABLE"]}}}}
    end

    after do
      Google::Cloud.configure.reset!
    end

    it "uses shared config for project and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "error_reporting-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        credentials.must_equal "error_reporting-credentials"
        timeout.must_be :nil?
        client_config.must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud.configure do |config|
          config.project = "project-id"
          config.keyfile = "path/to/keyfile.json"
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::ErrorReporting::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::ErrorReporting::Service.stub :new, stubbed_service do
                error_reporting = Google::Cloud::ErrorReporting.new
                error_reporting.must_be_kind_of Google::Cloud::ErrorReporting::Project
                error_reporting.project.must_equal "project-id"
                error_reporting.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses shared config for project_id and credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "error_reporting-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        credentials.must_equal "error_reporting-credentials"
        timeout.must_be :nil?
        client_config.must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud.configure do |config|
          config.project_id = "project-id"
          config.credentials = "path/to/keyfile.json"
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::ErrorReporting::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::ErrorReporting::Service.stub :new, stubbed_service do
                error_reporting = Google::Cloud::ErrorReporting.new
                error_reporting.must_be_kind_of Google::Cloud::ErrorReporting::Project
                error_reporting.project.must_equal "project-id"
                error_reporting.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses error_reporting config for project and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "error_reporting-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        credentials.must_equal "error_reporting-credentials"
        timeout.must_equal 42
        client_config.must_equal error_reporting_client_config
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud::ErrorReporting.configure do |config|
          config.project = "project-id"
          config.keyfile = "path/to/keyfile.json"
          config.timeout = 42
          config.client_config = error_reporting_client_config
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::ErrorReporting::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::ErrorReporting::Service.stub :new, stubbed_service do
                error_reporting = Google::Cloud::ErrorReporting.new
                error_reporting.must_be_kind_of Google::Cloud::ErrorReporting::Project
                error_reporting.project.must_equal "project-id"
                error_reporting.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses error_reporting config for project_id and credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "error_reporting-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        credentials.must_equal "error_reporting-credentials"
        timeout.must_equal 42
        client_config.must_equal error_reporting_client_config
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud::ErrorReporting.configure do |config|
          config.project_id = "project-id"
          config.credentials = "path/to/keyfile.json"
          config.timeout = 42
          config.client_config = error_reporting_client_config
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::ErrorReporting::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::ErrorReporting::Service.stub :new, stubbed_service do
                error_reporting = Google::Cloud::ErrorReporting.new
                error_reporting.must_be_kind_of Google::Cloud::ErrorReporting::Project
                error_reporting.project.must_equal "project-id"
                error_reporting.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end
  end
end
