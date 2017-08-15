# Copyright 2017 Google Inc. All rights reserved.
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

describe Google::Cloud do
  describe "#debugger" do
    it "calls out to Google::Cloud.debugger" do
      gcloud = Google::Cloud.new
      stubbed_debugger = ->(project, keyfile, service_name: nil, service_version: nil,
        scope: nil, timeout: nil, client_config: nil) {
        project.must_be_nil
        keyfile.must_be_nil
        service_name.must_be_nil
        service_version.must_be_nil
        scope.must_be_nil
        timeout.must_be_nil
        client_config.must_be_nil
        "debugger-project-object-empty"
      }
      Google::Cloud.stub :debugger, stubbed_debugger do
        project = gcloud.debugger
        project.must_equal "debugger-project-object-empty"
      end
    end

    it "passes project and keyfile to Google::Cloud.debugger" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_debugger = ->(project, keyfile, service_name: nil, service_version: nil,
        scope: nil, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        keyfile.must_equal "keyfile-path"
        service_name.must_be_nil
        service_version.must_be_nil
        scope.must_be_nil
        timeout.must_be_nil
        client_config.must_be_nil
        "debugger-project-object"
      }
      Google::Cloud.stub :debugger, stubbed_debugger do
        project = gcloud.debugger
        project.must_equal "debugger-project-object"
      end
    end

    it "passes project and keyfile and options to Google::Cloud.debugger" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_debugger = ->(project, keyfile, service_name: nil, service_version: nil,
        scope: nil, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        keyfile.must_equal "keyfile-path"
        service_name.must_equal "utest-service"
        service_version.must_equal "vUTest"
        scope.must_equal "http://example.com/scope"
        timeout.must_equal 60
        client_config.must_equal({ "gax" => "options" })
        "debugger-project-object-scoped"
      }
      Google::Cloud.stub :debugger, stubbed_debugger do
        project = gcloud.debugger service_name: "utest-service", service_version: "vUTest", scope: "http://example.com/scope", timeout: 60, client_config: { "gax" => "options" }
        project.must_equal "debugger-project-object-scoped"
      end
    end
  end

  describe ".debugger" do
    let(:default_credentials) { OpenStruct.new empty: true }
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
            debugger.must_be_kind_of Google::Cloud::Debugger::Project
            debugger.project.must_equal "project-id"
            debugger.agent.debuggee.service_name.must_equal default_service_name
            debugger.agent.debuggee.service_version.must_equal default_service_version
            debugger.service.credentials.must_equal default_credentials
          end
        end
      end
    end

    it "uses provided project_id and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be_nil
        "debugger-credentials"
      }
      stubbed_service_name = "utest-service"
      stubbed_service_version = "vUTest"
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        credentials.must_equal "debugger-credentials"
        timeout.must_be_nil
        client_config.must_be_nil
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Debugger::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Debugger::Service.stub :new, stubbed_service do
                debugger = Google::Cloud.debugger "project-id", "path/to/keyfile.json", service_name: stubbed_service_name, service_version: stubbed_service_version
                debugger.must_be_kind_of Google::Cloud::Debugger::Project
                debugger.project.must_equal "project-id"
                debugger.agent.debuggee.service_name.must_equal stubbed_service_name
                debugger.agent.debuggee.service_version.must_equal stubbed_service_version
                debugger.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end
  end

  describe ".configure" do
    it "has Google::Cloud.configure.debugger initialized already" do
      Google::Cloud.configure.option?(:debugger).must_equal true
    end

    it "operates on the same Configuration object as Google::Cloud.configure.debugger" do
      Google::Cloud::Debugger.configure.must_equal Google::Cloud.configure.debugger
    end
  end

  describe "Debugger.new" do
    let(:default_credentials) { OpenStruct.new empty: true }
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
            debugger.must_be_kind_of Google::Cloud::Debugger::Project
            debugger.project.must_equal "project-id"
            debugger.agent.debuggee.service_name.must_equal default_service_name
            debugger.agent.debuggee.service_version.must_equal default_service_version
            debugger.service.credentials.must_equal default_credentials
          end
        end
      end
    end

    it "uses provided project_id, keyfile, service_name, and service_version" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be_nil
        "debugger-credentials"
      }
      stubbed_service_name = "utest-service"
      stubbed_service_version = "vUTest"
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        credentials.must_equal "debugger-credentials"
        timeout.must_be :nil?
        client_config.must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Debugger::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Debugger::Service.stub :new, stubbed_service do
                debugger = Google::Cloud::Debugger.new project: "project-id", keyfile: "path/to/keyfile.json", service_name: stubbed_service_name, service_version: stubbed_service_version
                debugger.must_be_kind_of Google::Cloud::Debugger::Project
                debugger.project.must_equal "project-id"
                debugger.agent.debuggee.service_name.must_equal stubbed_service_name
                debugger.agent.debuggee.service_version.must_equal stubbed_service_version
                debugger.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end
  end
end
