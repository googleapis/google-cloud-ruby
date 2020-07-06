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
  let(:default_scopes) { ["https://www.googleapis.com/auth/cloud-platform"] }
  let(:default_endpoint) { "clouderrorreporting.googleapis.com" }

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
            _(error_reporting).must_be_kind_of Google::Cloud::ErrorReporting::Project
            _(error_reporting.project).must_equal "test-project-id"
            _(error_reporting.service.credentials).must_equal default_credentials
          end
        end
      end
    end

    it "uses provided project_id, credentials, service, and version" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "/path/to/a/keyfile"
        _(scope).must_equal default_scopes
        "error_reporting-credentials"
      }

      ENV.stub :[], nil do
        File.stub :file?, true, ["/path/to/a/keyfile"] do
          File.stub :read, found_credentials, ["/path/to/a/keyfile"] do
            Google::Cloud::ErrorReporting::Credentials.stub :new, stubbed_credentials do
              error_reporting = Google::Cloud::ErrorReporting.new project_id: "test-project-id",
                                                                  credentials: "/path/to/a/keyfile"
              _(error_reporting).must_be_kind_of Google::Cloud::ErrorReporting::Project
              _(error_reporting.project).must_equal "test-project-id"
              _(error_reporting.service).must_be_kind_of Google::Cloud::ErrorReporting::Service
            end
          end
        end
      end
    end

    it "uses provided endpoint" do
      endpoint = "errorreporting-endpoint2.example.com"
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil, host: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal default_credentials
        _(timeout).must_be :nil?
        _(client_config).must_be :nil?
        _(host).must_equal endpoint
        OpenStruct.new project: project
      }
      ENV.stub :[], nil do
        Google::Cloud::ErrorReporting::Service.stub :new, stubbed_service do
          error_reporting = Google::Cloud::ErrorReporting.new project_id: "project-id",
                                                              endpoint: endpoint,
                                                              credentials: default_credentials
          _(error_reporting).must_be_kind_of Google::Cloud::ErrorReporting::Project
          _(error_reporting.project).must_equal "project-id"
          _(error_reporting.service).must_be_kind_of OpenStruct
        end
      end
    end

    it "uses provided project (alias), keyfile (alias), service, and version" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "/path/to/a/keyfile"
        _(scope).must_equal default_scopes
        "error_reporting-credentials"
      }

      ENV.stub :[], nil do
        File.stub :file?, true, ["/path/to/a/keyfile"] do
          File.stub :read, found_credentials, ["/path/to/a/keyfile"] do
            Google::Cloud::ErrorReporting::Credentials.stub :new, stubbed_credentials do
              error_reporting = Google::Cloud::ErrorReporting.new project: "test-project-id",
                                                                  keyfile: "/path/to/a/keyfile"
              _(error_reporting).must_be_kind_of Google::Cloud::ErrorReporting::Project
              _(error_reporting.project).must_equal "test-project-id"
              _(error_reporting.service).must_be_kind_of Google::Cloud::ErrorReporting::Service
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

        _(exception.message).must_equal "project_id is missing"
      end
    end
  end

  describe ".configure" do
    it "has Google::Cloud.configure.error_reporting initialized already" do
      _(Google::Cloud.configure.option?(:error_reporting)).must_equal true
    end

    it "operates on the same Configuration object as Google::Cloud.configure.error_reporting" do
      assert Google::Cloud::ErrorReporting.configure.equal? Google::Cloud.configure.error_reporting
    end
  end

  describe ".report" do
    let(:exception) { RuntimeError.new "test-exception" }

    before {
      Google::Cloud::ErrorReporting.instance_variable_set :@default_reporter, nil
      _(Google::Cloud::ErrorReporting.instance_variable_get(:@default_reporter)).must_be_nil
    }

    after {
      Google::Cloud.configure.reset!
      Google::Cloud::ErrorReporting.configure.reset!
      Google::Cloud::ErrorReporting.instance_variable_set :@default_reporter, nil
      _(Google::Cloud::ErrorReporting.instance_variable_get(:@default_reporter)).must_be_nil
    }

    it "doesn't call Project#report_exception if Google::Cloud.configure.use_error_reporting is false" do
      Google::Cloud.configure do |config|
        config.use_error_reporting = false
      end
      stubbed_report = ->(_) { fail "Shouldn't be called" }
      Google::Cloud::ErrorReporting.instance_variable_set :@default_reporter, error_reporting

      error_reporting.stub :report, stubbed_report do
        Google::Cloud::ErrorReporting.report exception
      end
    end

    it "calls Project#report with the given service_name and service_version" do
      mocked_client = Minitest::Mock.new
      mocked_client.expect :report, nil do |event|
        _(event.service_name).must_equal "test-service-name"
        _(event.service_version).must_equal "test-service-version"
      end

      Google::Cloud::ErrorReporting.stub :default_reporter, mocked_client do
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
        _(event.service_name).must_equal "test-service-name"
        _(event.service_version).must_equal "test-service-version"
      end

      Google::Cloud::ErrorReporting.stub :default_reporter, mocked_client do
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
        _(event.service_name).must_equal "test-service-name"
        _(event.service_version).must_equal "test-service-version"
        _(event.file_path).must_equal "error_reporting.rb"
        _(event.line_number).must_equal 123
        _(event.function_name).must_equal "report"
      end

      Google::Cloud::ErrorReporting.stub :default_reporter, mocked_client do
        Google::Cloud::ErrorReporting.stub :caller, ["error_reporting.rb:123:in `report'"] do
          Google::Cloud::ErrorReporting.report exception
        end
      end
    end
  end

  describe ".default_reporter" do
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
        _(args[:project_id]).must_equal "test-project-id"
        _(args[:credentials]).must_equal "test-keyfile"
      }

      Google::Cloud::ErrorReporting.stub :new, stubbed_new do
        Google::Cloud::ErrorReporting.default_reporter
      end
    end

    it "uses the project and keyfile from Google::Cloud::ErrorReporting.configure" do
      Google::Cloud::ErrorReporting.configure do |config|
        config.project = "test-project-id"
        config.keyfile = "test-keyfile"
      end

      stubbed_new = ->(args) {
        _(args[:project_id]).must_equal "test-project-id"
        _(args[:credentials]).must_equal "test-keyfile"
      }

      Google::Cloud::ErrorReporting.stub :new, stubbed_new do
        Google::Cloud::ErrorReporting.default_reporter
      end
    end

    it "uses the project_id and credentials from Google::Cloud.configure if missing from Google::Cloud::ErrorReporting.configure" do
      Google::Cloud.configure do |config|
        config.project_id = "test-project-id"
        config.credentials = "test-keyfile"
      end

      stubbed_new = ->(args) {
        _(args[:project_id]).must_equal "test-project-id"
        _(args[:credentials]).must_equal "test-keyfile"
      }

      Google::Cloud::ErrorReporting.stub :new, stubbed_new do
        Google::Cloud::ErrorReporting.default_reporter
      end
    end

    it "uses the project and keyfile from Google::Cloud.configure if missing from Google::Cloud::ErrorReporting.configure" do
      Google::Cloud.configure do |config|
        config.project = "test-project-id"
        config.keyfile = "test-keyfile"
      end

      stubbed_new = ->(args) {
        _(args[:project_id]).must_equal "test-project-id"
        _(args[:credentials]).must_equal "test-keyfile"
      }

      Google::Cloud::ErrorReporting.stub :new, stubbed_new do
        Google::Cloud::ErrorReporting.default_reporter
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
          first_client = Google::Cloud::ErrorReporting.default_reporter
          _(Google::Cloud::ErrorReporting.default_reporter).must_equal first_client
        end
      end
    end
  end

  describe "ErrorReporting.configure" do
    let(:default_credentials) do
      creds = OpenStruct.new empty: true
      def creds.is_a? target
        target == Google::Auth::Credentials
      end
      creds
    end
    let(:found_credentials) { "{}" }

    after do
      Google::Cloud.configure.reset!
    end

    it "uses shared config for project and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_equal default_scopes
        "error_reporting-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil, host: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "error_reporting-credentials"
        _(timeout).must_be :nil?
        _(client_config).must_be :nil?
        _(host).must_equal default_endpoint
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
                _(error_reporting).must_be_kind_of Google::Cloud::ErrorReporting::Project
                _(error_reporting.project).must_equal "project-id"
                _(error_reporting.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses shared config for project_id and credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_equal default_scopes
        "error_reporting-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil, host: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "error_reporting-credentials"
        _(timeout).must_be :nil?
        _(client_config).must_be :nil?
        _(host).must_equal default_endpoint
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
                _(error_reporting).must_be_kind_of Google::Cloud::ErrorReporting::Project
                _(error_reporting.project).must_equal "project-id"
                _(error_reporting.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses error_reporting config for project and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_equal default_scopes
        "error_reporting-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil, host: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "error_reporting-credentials"
        _(timeout).must_equal 42
        _(client_config).must_be :nil?
        _(host).must_equal default_endpoint
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud::ErrorReporting.configure do |config|
          config.project = "project-id"
          config.keyfile = "path/to/keyfile.json"
          config.timeout = 42
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::ErrorReporting::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::ErrorReporting::Service.stub :new, stubbed_service do
                error_reporting = Google::Cloud::ErrorReporting.new
                _(error_reporting).must_be_kind_of Google::Cloud::ErrorReporting::Project
                _(error_reporting.project).must_equal "project-id"
                _(error_reporting.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses error_reporting config for endpoint" do
      endpoint = "errorreporting-endpoint2.example.com"
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil, host: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal default_credentials
        _(timeout).must_be :nil?
        _(client_config).must_be :nil?
        _(host).must_equal endpoint
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud::ErrorReporting.configure do |config|
          config.project = "project-id"
          config.endpoint = endpoint
        end

        Google::Cloud::ErrorReporting::Service.stub :new, stubbed_service do
          error_reporting = Google::Cloud::ErrorReporting.new project: "project-id", credentials: default_credentials, endpoint: endpoint
          _(error_reporting).must_be_kind_of Google::Cloud::ErrorReporting::Project
          _(error_reporting.project).must_equal "project-id"
          _(error_reporting.service).must_be_kind_of OpenStruct
        end
      end
    end

    it "uses error_reporting config for project_id and credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_equal default_scopes
        "error_reporting-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil, host: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "error_reporting-credentials"
        _(timeout).must_equal 42
        _(client_config).must_be :nil?
        _(host).must_equal default_endpoint
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud::ErrorReporting.configure do |config|
          config.project_id = "project-id"
          config.credentials = "path/to/keyfile.json"
          config.timeout = 42
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::ErrorReporting::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::ErrorReporting::Service.stub :new, stubbed_service do
                error_reporting = Google::Cloud::ErrorReporting.new
                _(error_reporting).must_be_kind_of Google::Cloud::ErrorReporting::Project
                _(error_reporting.project).must_equal "project-id"
                _(error_reporting.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end
  end
end
