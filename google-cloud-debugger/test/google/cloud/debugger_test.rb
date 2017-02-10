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

describe Google::Cloud do
  describe "#debugger" do
    it "calls out to Google::Cloud.debugger" do
      gcloud = Google::Cloud.new
      stubbed_debugger = ->(project, keyfile, module_name: nil, module_version: nil,
        scope: nil, timeout: nil, client_config: nil) {
        project.must_be_nil
        keyfile.must_be_nil
        module_name.must_be_nil
        module_version.must_be_nil
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
      stubbed_debugger = ->(project, keyfile, module_name: nil, module_version: nil,
        scope: nil, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        keyfile.must_equal "keyfile-path"
        module_name.must_be_nil
        module_version.must_be_nil
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
      stubbed_debugger = ->(project, keyfile, module_name: nil, module_version: nil,
        scope: nil, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        keyfile.must_equal "keyfile-path"
        module_name.must_equal "utest-service"
        module_version.must_equal "vUTest"
        scope.must_equal "http://example.com/scope"
        timeout.must_equal 60
        client_config.must_equal({ "gax" => "options" })
        "debugger-project-object-scoped"
      }
      Google::Cloud.stub :debugger, stubbed_debugger do
        project = gcloud.debugger module_name: "utest-service", module_version: "vUTest", scope: "http://example.com/scope", timeout: 60, client_config: { "gax" => "options" }
        project.must_equal "debugger-project-object-scoped"
      end
    end
  end

  describe ".debugger" do
    let(:default_credentials) { OpenStruct.new empty: true }
    let(:default_module_name) { "default-utest-service" }
    let(:default_module_version) { "vDefaultUTest" }
    let(:found_credentials) { "{}" }

    it "gets defaults for project_id and keyfile" do
      # Clear all environment variables
      ENV.stub :[], nil do
        # Get project_id from Google Compute Engine
        Google::Cloud::Core::Environment.stub :project_id, "project-id" do
          Google::Cloud::Debugger::Credentials.stub :default, default_credentials do
            Google::Cloud::Core::Environment.stub :gae_module_id, default_module_name do
              Google::Cloud::Core::Environment.stub :gae_module_version, default_module_version do
                debugger = Google::Cloud.debugger
                debugger.must_be_kind_of Google::Cloud::Debugger::Project
                debugger.project.must_equal "project-id"
                debugger.agent.debuggee.module_name.must_equal default_module_name
                debugger.agent.debuggee.module_version.must_equal default_module_version
                debugger.service.credentials.must_equal default_credentials
              end
            end
          end
        end
      end
    end

    it "uses provided project_id and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_equal nil
        "debugger-credentials"
      }
      stubbed_module_name = "utest-service"
      stubbed_module_version = "vUTest"
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
                debugger = Google::Cloud.debugger "project-id", "path/to/keyfile.json", module_name: stubbed_module_name, module_version: stubbed_module_version
                debugger.must_be_kind_of Google::Cloud::Debugger::Project
                debugger.project.must_equal "project-id"
                debugger.agent.debuggee.module_name.must_equal stubbed_module_name
                debugger.agent.debuggee.module_version.must_equal stubbed_module_version
                debugger.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end
  end

  describe "Debugger.new" do
    let(:default_credentials) { OpenStruct.new empty: true }
    let(:default_module_name) { "default-utest-service" }
    let(:default_module_version) { "vDefaultUTest" }
    let(:found_credentials) { "{}" }

    it "gets defaults for project_id, keyfile, module_name, and module_version" do
      # Clear all environment variables
      ENV.stub :[], nil do
        # Get project_id from Google Compute Engine
        Google::Cloud::Core::Environment.stub :project_id, "project-id" do
          Google::Cloud::Debugger::Credentials.stub :default, default_credentials do
            Google::Cloud::Core::Environment.stub :gae_module_id, default_module_name do
              Google::Cloud::Core::Environment.stub :gae_module_version, default_module_version do
                debugger = Google::Cloud::Debugger.new
                debugger.must_be_kind_of Google::Cloud::Debugger::Project
                debugger.project.must_equal "project-id"
                debugger.agent.debuggee.module_name.must_equal default_module_name
                debugger.agent.debuggee.module_version.must_equal default_module_version
                debugger.service.credentials.must_equal default_credentials
              end
            end
          end
        end
      end
    end

    it "uses provided project_id, keyfile, module_name, and module_version" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_equal nil
        "debugger-credentials"
      }
      stubbed_module_name = "utest-service"
      stubbed_module_version = "vUTest"
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
                debugger = Google::Cloud::Debugger.new project: "project-id", keyfile: "path/to/keyfile.json", module_name: stubbed_module_name, module_version: stubbed_module_version
                debugger.must_be_kind_of Google::Cloud::Debugger::Project
                debugger.project.must_equal "project-id"
                debugger.agent.debuggee.module_name.must_equal stubbed_module_name
                debugger.agent.debuggee.module_version.must_equal stubbed_module_version
                debugger.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end
  end
end
