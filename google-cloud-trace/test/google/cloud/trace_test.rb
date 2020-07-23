# Copyright 2019 Google LLC
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
  let(:default_scopes) { [
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/trace.append",
    "https://www.googleapis.com/auth/trace.readonly"
  ] }
  let(:default_endpoint) { "cloudtrace.googleapis.com" }

  describe "#trace" do
    it "calls out to Google::Cloud.trace" do
      gcloud = Google::Cloud.new
      stubbed_trace = ->(project, keyfile, scope: nil, timeout: nil, host: nil) {
        project.must_be :nil?
        keyfile.must_be :nil?
        scope.must_be :nil?
        timeout.must_be :nil?
        host.must_be :nil?
        "trace-project-object-empty"
      }
      Google::Cloud.stub :trace, stubbed_trace do
        project = gcloud.trace
        project.must_equal "trace-project-object-empty"
      end
    end

    it "passes project and keyfile to Google::Cloud.trace" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_trace = ->(project, keyfile, scope: nil, timeout: nil, host: nil) {
        project.must_equal "project-id"
        keyfile.must_equal "keyfile-path"
        scope.must_be :nil?
        timeout.must_be :nil?
        host.must_be :nil?
        "trace-project-object"
      }
      Google::Cloud.stub :trace, stubbed_trace do
        project = gcloud.trace
        project.must_equal "trace-project-object"
      end
    end

    it "passes project and keyfile and options to Google::Cloud.trace" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_trace = ->(project, keyfile, scope: nil, timeout: nil, host: nil) {
        project.must_equal "project-id"
        keyfile.must_equal "keyfile-path"
        scope.must_equal "http://example.com/scope"
        timeout.must_equal 60
        host.must_be :nil?
        "trace-project-object-scoped"
      }
      Google::Cloud.stub :trace, stubbed_trace do
        project = gcloud.trace scope: "http://example.com/scope", timeout: 60
        project.must_equal "trace-project-object-scoped"
      end
    end
  end

  describe ".trace" do
    let(:default_credentials) do
      creds = OpenStruct.new empty: true
      def creds.is_a? target
        target == Google::Auth::Credentials
      end
      creds
    end
    let(:found_credentials) { "{}" }

    it "gets defaults for project_id and keyfile" do
      # Clear all environment variables
      ENV.stub :[], nil do
        # Get project_id from Google Compute Engine
        Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
          Google::Cloud::Trace::Credentials.stub :default, default_credentials do
            trace = Google::Cloud.trace
            trace.must_be_kind_of Google::Cloud::Trace::Project
            trace.project.must_equal "project-id"
            trace.service.credentials.must_equal default_credentials
          end
        end
      end
    end

    it "uses provided project_id and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_equal default_scopes
        "trace-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, host: nil) {
        project.must_equal "project-id"
        credentials.must_equal "trace-credentials"
        timeout.must_be :nil?
        host.must_equal default_endpoint
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Trace::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Trace::Service.stub :new, stubbed_service do
                trace = Google::Cloud.trace "project-id", "path/to/keyfile.json"
                trace.must_be_kind_of Google::Cloud::Trace::Project
                trace.project.must_equal "project-id"
                trace.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end
  end

  describe "Trace.new" do
    let(:default_credentials) do
      creds = OpenStruct.new empty: true
      def creds.is_a? target
        target == Google::Auth::Credentials
      end
      creds
    end
    let(:found_credentials) { "{}" }

    it "gets defaults for project_id and keyfile" do
      # Clear all environment variables
      ENV.stub :[], nil do
        # Get project_id from Google Compute Engine
        Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
          Google::Cloud::Trace::Credentials.stub :default, default_credentials do
            trace = Google::Cloud::Trace.new
            trace.must_be_kind_of Google::Cloud::Trace::Project
            trace.project.must_equal "project-id"
            trace.service.credentials.must_equal default_credentials
          end
        end
      end
    end

    it "uses provided project_id and credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_equal default_scopes
        "trace-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, host: nil) {
        project.must_equal "project-id"
        credentials.must_equal "trace-credentials"
        timeout.must_be :nil?
        host.must_equal default_endpoint
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Trace::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Trace::Service.stub :new, stubbed_service do
                trace = Google::Cloud::Trace.new project_id: "project-id", credentials: "path/to/keyfile.json"
                trace.must_be_kind_of Google::Cloud::Trace::Project
                trace.project.must_equal "project-id"
                trace.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses provided endpoint" do
      endpoint = "trace-endpoint2.example.com"
      stubbed_service = ->(project, credentials, timeout: nil, host: nil) {
        project.must_equal "project-id"
        credentials.must_equal default_credentials
        timeout.must_be :nil?
        host.must_equal endpoint
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        Google::Cloud::Trace::Service.stub :new, stubbed_service do
          trace = Google::Cloud::Trace.new project: "project-id", credentials: default_credentials, endpoint: endpoint
          trace.must_be_kind_of Google::Cloud::Trace::Project
          trace.project.must_equal "project-id"
          trace.service.must_be_kind_of OpenStruct
        end
      end
    end

    it "uses provided project and keyfile aliases" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_equal default_scopes
        "trace-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, host: nil) {
        project.must_equal "project-id"
        credentials.must_equal "trace-credentials"
        timeout.must_be :nil?
        host.must_equal default_endpoint
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Trace::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Trace::Service.stub :new, stubbed_service do
                trace = Google::Cloud::Trace.new project: "project-id", keyfile: "path/to/keyfile.json"
                trace.must_be_kind_of Google::Cloud::Trace::Project
                trace.project.must_equal "project-id"
                trace.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "gets project_id from credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_equal default_scopes
        OpenStruct.new project_id: "project-id"
      }
      stubbed_service = ->(project, credentials, timeout: nil, host: nil) {
        project.must_equal "project-id"
        credentials.must_be_kind_of OpenStruct
        credentials.project_id.must_equal "project-id"
        timeout.must_be :nil?
        host.must_equal default_endpoint
        OpenStruct.new project: project
      }
      empty_env = OpenStruct.new

      # Clear all environment variables
      ENV.stub :[], nil do
        Google::Cloud.stub :env, empty_env do
          File.stub :file?, true, ["path/to/keyfile.json"] do
            File.stub :read, found_credentials, ["path/to/keyfile.json"] do
              Google::Cloud::Trace::Credentials.stub :new, stubbed_credentials do
                Google::Cloud::Trace::Service.stub :new, stubbed_service do
                  trace = Google::Cloud::Trace.new credentials: "path/to/keyfile.json"
                  trace.must_be_kind_of Google::Cloud::Trace::Project
                  trace.project.must_equal "project-id"
                  trace.service.must_be_kind_of OpenStruct
                end
              end
            end
          end
        end
      end
    end
  end

  describe "Trace.configure" do
    let(:found_credentials) { "{}" }

    after do
      Google::Cloud.configure.reset!
    end

    it "uses shared config for project and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_equal default_scopes
        "trace-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, host: nil) {
        project.must_equal "project-id"
        credentials.must_equal "trace-credentials"
        timeout.must_be :nil?
        host.must_equal default_endpoint
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
            Google::Cloud::Trace::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Trace::Service.stub :new, stubbed_service do
                trace = Google::Cloud::Trace.new
                trace.must_be_kind_of Google::Cloud::Trace::Project
                trace.project.must_equal "project-id"
                trace.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses shared config for project_id and credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_equal default_scopes
        "trace-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, host: nil) {
        project.must_equal "project-id"
        credentials.must_equal "trace-credentials"
        timeout.must_be :nil?
        host.must_equal default_endpoint
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
            Google::Cloud::Trace::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Trace::Service.stub :new, stubbed_service do
                trace = Google::Cloud::Trace.new
                trace.must_be_kind_of Google::Cloud::Trace::Project
                trace.project.must_equal "project-id"
                trace.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses trace config for project and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_equal default_scopes
        "trace-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, host: nil) {
        project.must_equal "project-id"
        credentials.must_equal "trace-credentials"
        timeout.must_equal 42
        host.must_equal default_endpoint
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud::Trace.configure do |config|
          config.project = "project-id"
          config.keyfile = "path/to/keyfile.json"
          config.timeout = 42
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Trace::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Trace::Service.stub :new, stubbed_service do
                trace = Google::Cloud::Trace.new
                trace.must_be_kind_of Google::Cloud::Trace::Project
                trace.project.must_equal "project-id"
                trace.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses trace config for project_id and credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_equal default_scopes
        "trace-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, host: nil) {
        project.must_equal "project-id"
        credentials.must_equal "trace-credentials"
        timeout.must_equal 42
        host.must_equal default_endpoint
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud::Trace.configure do |config|
          config.project_id = "project-id"
          config.credentials = "path/to/keyfile.json"
          config.timeout = 42
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Trace::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Trace::Service.stub :new, stubbed_service do
                trace = Google::Cloud::Trace.new
                trace.must_be_kind_of Google::Cloud::Trace::Project
                trace.project.must_equal "project-id"
                trace.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses trace config for endpoint" do
      endpoint = "trace-endpoint2.example.com"
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_equal default_scopes
        "trace-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, host: nil) {
        project.must_equal "project-id"
        credentials.must_equal "trace-credentials"
        timeout.must_be :nil?
        host.must_equal endpoint
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud::Trace.configure do |config|
          config.project = "project-id"
          config.keyfile = "path/to/keyfile.json"
          config.endpoint = endpoint
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Trace::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Trace::Service.stub :new, stubbed_service do
                trace = Google::Cloud::Trace.new
                trace.must_be_kind_of Google::Cloud::Trace::Project
                trace.project.must_equal "project-id"
                trace.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end
  end
end
