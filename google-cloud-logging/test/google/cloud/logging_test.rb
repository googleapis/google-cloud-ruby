# Copyright 2016 Google LLC
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
  describe "#logging" do
    it "calls out to Google::Cloud.logging" do
      gcloud = Google::Cloud.new
      stubbed_logging = ->(project, keyfile, scope: nil, timeout: nil, client_config: nil) {
        project.must_be_nil
        keyfile.must_be_nil
        scope.must_be_nil
        timeout.must_be_nil
        client_config.must_be_nil
        "logging-project-object-empty"
      }
      Google::Cloud.stub :logging, stubbed_logging do
        project = gcloud.logging
        project.must_equal "logging-project-object-empty"
      end
    end

    it "passes project and keyfile to Google::Cloud.logging" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_logging = ->(project, keyfile, scope: nil, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        keyfile.must_equal "keyfile-path"
        scope.must_be_nil
        timeout.must_be_nil
        client_config.must_be_nil
        "logging-project-object"
      }
      Google::Cloud.stub :logging, stubbed_logging do
        project = gcloud.logging
        project.must_equal "logging-project-object"
      end
    end

    it "passes project and keyfile and options to Google::Cloud.logging" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_logging = ->(project, keyfile, scope: nil, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        keyfile.must_equal "keyfile-path"
        scope.must_equal "http://example.com/scope"
        timeout.must_equal 60
        client_config.must_equal({ "gax" => "options" })
        "logging-project-object-scoped"
      }
      Google::Cloud.stub :logging, stubbed_logging do
        project = gcloud.logging scope: "http://example.com/scope", timeout: 60, client_config: { "gax" => "options" }
        project.must_equal "logging-project-object-scoped"
      end
    end
  end

  describe ".logging" do
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
          Google::Cloud::Logging::Credentials.stub :default, default_credentials do
            logging = Google::Cloud.logging
            logging.must_be_kind_of Google::Cloud::Logging::Project
            logging.project.must_equal "project-id"
            logging.service.credentials.must_equal default_credentials
          end
        end
      end
    end

    it "uses provided project_id and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be_nil
        "logging-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        credentials.must_equal "logging-credentials"
        timeout.must_be_nil
        client_config.must_be_nil
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Logging::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Logging::Service.stub :new, stubbed_service do
                logging = Google::Cloud.logging "project-id", "path/to/keyfile.json"
                logging.must_be_kind_of Google::Cloud::Logging::Project
                logging.project.must_equal "project-id"
                logging.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end
  end

  describe "Logging.new" do
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
          Google::Cloud::Logging::Credentials.stub :default, default_credentials do
            logging = Google::Cloud::Logging.new
            logging.must_be_kind_of Google::Cloud::Logging::Project
            logging.project.must_equal "project-id"
            logging.service.credentials.must_equal default_credentials
          end
        end
      end
    end

    it "uses provided project_id and credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be_nil
        "logging-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        credentials.must_equal "logging-credentials"
        timeout.must_be_nil
        client_config.must_be_nil
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Logging::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Logging::Service.stub :new, stubbed_service do
                logging = Google::Cloud::Logging.new project_id: "project-id", credentials: "path/to/keyfile.json"
                logging.must_be_kind_of Google::Cloud::Logging::Project
                logging.project.must_equal "project-id"
                logging.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses provided project and keyfile aliases" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be_nil
        "logging-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        credentials.must_equal "logging-credentials"
        timeout.must_be_nil
        client_config.must_be_nil
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Logging::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Logging::Service.stub :new, stubbed_service do
                logging = Google::Cloud::Logging.new project: "project-id", keyfile: "path/to/keyfile.json"
                logging.must_be_kind_of Google::Cloud::Logging::Project
                logging.project.must_equal "project-id"
                logging.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end
  end

  describe "Logging.configure" do
    let(:found_credentials) { "{}" }
    let :logging_client_config do
      {"interfaces"=>
        {"google.logging.v1.Logging"=>
          {"retry_codes"=>{"idempotent"=>["DEADLINE_EXCEEDED", "UNAVAILABLE"]}}}}
    end

    after do
      Google::Cloud.configure.reset!
    end

    it "uses shared config for project and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "logging-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        credentials.must_equal "logging-credentials"
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
            Google::Cloud::Logging::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Logging::Service.stub :new, stubbed_service do
                logging = Google::Cloud::Logging.new
                logging.must_be_kind_of Google::Cloud::Logging::Project
                logging.project.must_equal "project-id"
                logging.service.must_be_kind_of OpenStruct
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
        "logging-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        credentials.must_equal "logging-credentials"
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
            Google::Cloud::Logging::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Logging::Service.stub :new, stubbed_service do
                logging = Google::Cloud::Logging.new
                logging.must_be_kind_of Google::Cloud::Logging::Project
                logging.project.must_equal "project-id"
                logging.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses logging config for project and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "logging-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        credentials.must_equal "logging-credentials"
        timeout.must_equal 42
        client_config.must_equal logging_client_config
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud::Logging.configure do |config|
          config.project = "project-id"
          config.keyfile = "path/to/keyfile.json"
          config.timeout = 42
          config.client_config = logging_client_config
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Logging::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Logging::Service.stub :new, stubbed_service do
                logging = Google::Cloud::Logging.new
                logging.must_be_kind_of Google::Cloud::Logging::Project
                logging.project.must_equal "project-id"
                logging.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses logging config for project_id and credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "logging-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        credentials.must_equal "logging-credentials"
        timeout.must_equal 42
        client_config.must_equal logging_client_config
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud::Logging.configure do |config|
          config.project_id = "project-id"
          config.credentials = "path/to/keyfile.json"
          config.timeout = 42
          config.client_config = logging_client_config
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Logging::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Logging::Service.stub :new, stubbed_service do
                logging = Google::Cloud::Logging.new
                logging.must_be_kind_of Google::Cloud::Logging::Project
                logging.project.must_equal "project-id"
                logging.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end
  end
end
