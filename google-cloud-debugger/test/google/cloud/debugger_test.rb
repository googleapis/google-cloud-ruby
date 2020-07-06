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

describe Google::Cloud do
  describe "#debugger" do
    it "calls out to Google::Cloud.debugger" do
      gcloud = Google::Cloud.new
      stubbed_debugger = ->(project, keyfile, service_name: nil, service_version: nil,
        scope: nil, timeout: nil, client_config: nil, host: nil) {
        _(project).must_be_nil
        _(keyfile).must_be_nil
        _(service_name).must_be_nil
        _(service_version).must_be_nil
        _(scope).must_be_nil
        _(timeout).must_be_nil
        _(client_config).must_be_nil
        _(host).must_be_nil
        "debugger-project-object-empty"
      }
      Google::Cloud.stub :debugger, stubbed_debugger do
        project = gcloud.debugger
        _(project).must_equal "debugger-project-object-empty"
      end
    end

    it "passes project and keyfile to Google::Cloud.debugger" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_debugger = ->(project, keyfile, service_name: nil, service_version: nil,
        scope: nil, timeout: nil, client_config: nil, host: nil) {
        _(project).must_equal "project-id"
        _(keyfile).must_equal "keyfile-path"
        _(service_name).must_be_nil
        _(service_version).must_be_nil
        _(scope).must_be_nil
        _(timeout).must_be_nil
        _(client_config).must_be_nil
        _(host).must_be_nil
        "debugger-project-object"
      }
      Google::Cloud.stub :debugger, stubbed_debugger do
        project = gcloud.debugger
        _(project).must_equal "debugger-project-object"
      end
    end

    it "passes project and keyfile and options to Google::Cloud.debugger" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_debugger = ->(project, keyfile, service_name: nil, service_version: nil,
        scope: nil, timeout: nil, client_config: nil, host: nil) {
        _(project).must_equal "project-id"
        _(keyfile).must_equal "keyfile-path"
        _(service_name).must_equal "utest-service"
        _(service_version).must_equal "vUTest"
        _(scope).must_equal "http://example.com/scope"
        _(timeout).must_equal 60
        _(client_config).must_equal({ "gax" => "options" })
        _(host).must_be_nil
        "debugger-project-object-scoped"
      }
      Google::Cloud.stub :debugger, stubbed_debugger do
        project = gcloud.debugger service_name: "utest-service", service_version: "vUTest", scope: "http://example.com/scope", timeout: 60, client_config: { "gax" => "options" }
        _(project).must_equal "debugger-project-object-scoped"
      end
    end
  end

  describe ".debugger" do
    let(:default_credentials) do
      creds = OpenStruct.new empty: true
      def creds.is_a? target
        target == Google::Auth::Credentials
      end
      creds
    end
    let(:default_service_name) { "default-utest-service" }
    let(:default_service_version) { "vDefaultUTest" }
    let(:found_credentials) { "{}" }

    it "gets defaults for project_id and keyfile" do
      stubbed_env = OpenStruct.new project_id: "project-id",
                                   app_engine_service_id: default_service_name,
                                   app_engine_service_version: default_service_version
      # Clear all environment variables
      ENV.stub :[], nil do
        # Get project_id from Google Compute Engine
        Google::Cloud.stub :env, stubbed_env do
          Google::Cloud::Debugger::Credentials.stub :default, default_credentials do
            debugger = Google::Cloud.debugger
            _(debugger).must_be_kind_of Google::Cloud::Debugger::Project
            _(debugger.project).must_equal "project-id"
            _(debugger.agent.debuggee.service_name).must_equal default_service_name
            _(debugger.agent.debuggee.service_version).must_equal default_service_version
            _(debugger.service.credentials).must_equal default_credentials
          end
        end
      end
    end

    it "uses provided project_id and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        "debugger-credentials"
      }
      stubbed_service_name = "utest-service"
      stubbed_service_version = "vUTest"
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil, host: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "debugger-credentials"
        _(timeout).must_be_nil
        _(client_config).must_be_nil
        _(host).must_equal "clouddebugger.googleapis.com"
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Debugger::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Debugger::Service.stub :new, stubbed_service do
                debugger = Google::Cloud.debugger "project-id", "path/to/keyfile.json", service_name: stubbed_service_name, service_version: stubbed_service_version
                _(debugger).must_be_kind_of Google::Cloud::Debugger::Project
                _(debugger.project).must_equal "project-id"
                _(debugger.agent.debuggee.service_name).must_equal stubbed_service_name
                _(debugger.agent.debuggee.service_version).must_equal stubbed_service_version
                _(debugger.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end
  end

  describe ".configure" do
    it "has Google::Cloud.configure.debugger initialized already" do
      _(Google::Cloud.configure.option?(:debugger)).must_equal true
    end

    it "operates on the same Configuration object as Google::Cloud.configure.debugger" do
      assert Google::Cloud::Debugger.configure.equal? Google::Cloud.configure.debugger
    end
  end

  describe "Debugger.new" do
    let(:default_credentials) do
      creds = OpenStruct.new empty: true
      def creds.is_a? target
        target == Google::Auth::Credentials
      end
      creds
    end
    let(:default_service_name) { "default-utest-service" }
    let(:default_service_version) { "vDefaultUTest" }
    let(:found_credentials) { "{}" }

    it "gets defaults for project_id, keyfile, service_name, and service_version" do
      stubbed_env = OpenStruct.new project_id: "project-id",
                                   app_engine_service_id: default_service_name,
                                   app_engine_service_version: default_service_version

      # Clear all environment variables
      ENV.stub :[], nil do
        # Get project_id from Google Compute Engine
        Google::Cloud.stub :env, stubbed_env do
          Google::Cloud::Debugger::Credentials.stub :default, default_credentials do
            debugger = Google::Cloud::Debugger.new
            _(debugger).must_be_kind_of Google::Cloud::Debugger::Project
            _(debugger.project).must_equal "project-id"
            _(debugger.agent.debuggee.service_name).must_equal default_service_name
            _(debugger.agent.debuggee.service_version).must_equal default_service_version
            _(debugger.service.credentials).must_equal default_credentials
          end
        end
      end
    end

    it "uses provided project_id, credentials, service_name, and service_version" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        "debugger-credentials"
      }
      stubbed_service_name = "utest-service"
      stubbed_service_version = "vUTest"
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil, host: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "debugger-credentials"
        _(timeout).must_be :nil?
        _(client_config).must_be :nil?
        _(host).must_equal "clouddebugger.googleapis.com"
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Debugger::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Debugger::Service.stub :new, stubbed_service do
                debugger = Google::Cloud::Debugger.new project_id: "project-id", credentials: "path/to/keyfile.json", service_name: stubbed_service_name, service_version: stubbed_service_version
                _(debugger).must_be_kind_of Google::Cloud::Debugger::Project
                _(debugger.project).must_equal "project-id"
                _(debugger.agent.debuggee.service_name).must_equal stubbed_service_name
                _(debugger.agent.debuggee.service_version).must_equal stubbed_service_version
                _(debugger.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses provided endpoint" do
      endpoint = "debugger-endpoint2.example.com"
      stubbed_service_name = "utest-service"
      stubbed_service_version = "vUTest"
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
        Google::Cloud::Debugger::Service.stub :new, stubbed_service do
          debugger = Google::Cloud::Debugger.new project_id: "project-id", credentials: default_credentials, endpoint: endpoint, service_name: stubbed_service_name, service_version: stubbed_service_version
          _(debugger).must_be_kind_of Google::Cloud::Debugger::Project
          _(debugger.project).must_equal "project-id"
          _(debugger.agent.debuggee.service_name).must_equal stubbed_service_name
          _(debugger.agent.debuggee.service_version).must_equal stubbed_service_version
          _(debugger.service).must_be_kind_of OpenStruct
        end
      end
    end

    it "uses provided project (alias), keyfile (alias), service_name, and service_version" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        "debugger-credentials"
      }
      stubbed_service_name = "utest-service"
      stubbed_service_version = "vUTest"
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil, host: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "debugger-credentials"
        _(timeout).must_be :nil?
        _(client_config).must_be :nil?
        _(host).must_equal "clouddebugger.googleapis.com"
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Debugger::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Debugger::Service.stub :new, stubbed_service do
                debugger = Google::Cloud::Debugger.new project: "project-id", keyfile: "path/to/keyfile.json", service_name: stubbed_service_name, service_version: stubbed_service_version
                _(debugger).must_be_kind_of Google::Cloud::Debugger::Project
                _(debugger.project).must_equal "project-id"
                _(debugger.agent.debuggee.service_name).must_equal stubbed_service_name
                _(debugger.agent.debuggee.service_version).must_equal stubbed_service_version
                _(debugger.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "gets project_id from credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        OpenStruct.new project_id: "project-id"
      }
      stubbed_service_name = "utest-service"
      stubbed_service_version = "vUTest"
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil, host: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_be_kind_of OpenStruct
        _(credentials.project_id).must_equal "project-id"
        _(timeout).must_be_nil
        _(client_config).must_be_nil
        _(host).must_equal "clouddebugger.googleapis.com"
        OpenStruct.new project: project
      }
      empty_env = OpenStruct.new
      ENV.stub :[], nil do
        Google::Cloud.stub :env, empty_env do
          File.stub :file?, true, ["path/to/keyfile.json"] do
            File.stub :read, found_credentials, ["path/to/keyfile.json"] do
              Google::Cloud::Debugger::Credentials.stub :new, stubbed_credentials do
                Google::Cloud::Debugger::Service.stub :new, stubbed_service do
                  debugger = Google::Cloud::Debugger.new credentials: "path/to/keyfile.json"
                  _(debugger).must_be_kind_of Google::Cloud::Debugger::Project
                  _(debugger.project).must_equal "project-id"
                  _(debugger.service).must_be_kind_of OpenStruct
                end
              end
            end
          end
        end
      end
    end
  end

  describe "Debugger.configure" do
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
        "debugger-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil, host: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "debugger-credentials"
        _(timeout).must_be :nil?
        _(client_config).must_be :nil?
        _(host).must_equal "clouddebugger.googleapis.com"
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
            Google::Cloud::Debugger::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Debugger::Service.stub :new, stubbed_service do
                debugger = Google::Cloud::Debugger.new
                _(debugger).must_be_kind_of Google::Cloud::Debugger::Project
                _(debugger.project).must_equal "project-id"
                _(debugger.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses shared config for project_id and credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        "debugger-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil, host: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "debugger-credentials"
        _(timeout).must_be :nil?
        _(client_config).must_be :nil?
        _(host).must_equal "clouddebugger.googleapis.com"
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
            Google::Cloud::Debugger::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Debugger::Service.stub :new, stubbed_service do
                debugger = Google::Cloud::Debugger.new
                _(debugger).must_be_kind_of Google::Cloud::Debugger::Project
                _(debugger.project).must_equal "project-id"
                _(debugger.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses debugger config for project and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        "debugger-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil, host: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "debugger-credentials"
        _(timeout).must_equal 42
        _(client_config).must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud::Debugger.configure do |config|
          config.project = "project-id"
          config.keyfile = "path/to/keyfile.json"
          config.timeout = 42
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Debugger::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Debugger::Service.stub :new, stubbed_service do
                debugger = Google::Cloud::Debugger.new
                _(debugger).must_be_kind_of Google::Cloud::Debugger::Project
                _(debugger.project).must_equal "project-id"
                _(debugger.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses debugger config for endpoint" do
      endpoint = "debugger-endpoint2.example.com"
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
        Google::Cloud::Debugger.configure do |config|
          config.project = "project-id"
          config.endpoint = endpoint
        end

        Google::Cloud::Debugger::Service.stub :new, stubbed_service do
          debugger = Google::Cloud::Debugger.new project: "project-id", credentials: default_credentials, endpoint: endpoint
          _(debugger).must_be_kind_of Google::Cloud::Debugger::Project
          _(debugger.project).must_equal "project-id"
          _(debugger.service).must_be_kind_of OpenStruct
        end
      end
    end

    it "uses debugger config for project_id and credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        "debugger-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil, host: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "debugger-credentials"
        _(timeout).must_equal 42
        _(client_config).must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud::Debugger.configure do |config|
          config.project_id = "project-id"
          config.credentials = "path/to/keyfile.json"
          config.timeout = 42
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Debugger::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Debugger::Service.stub :new, stubbed_service do
                debugger = Google::Cloud::Debugger.new
                _(debugger).must_be_kind_of Google::Cloud::Debugger::Project
                _(debugger.project).must_equal "project-id"
                _(debugger.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end
  end
end
