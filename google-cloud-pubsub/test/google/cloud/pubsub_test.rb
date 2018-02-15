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
require "google/cloud/pubsub"

describe Google::Cloud do
  describe "#pubsub" do
    it "calls out to Google::Cloud.pubsub" do
      gcloud = Google::Cloud.new
      stubbed_pubsub = ->(project, keyfile, scope: nil, timeout: nil, client_config: nil) {
        project.must_be :nil?
        keyfile.must_be :nil?
        scope.must_be :nil?
        timeout.must_be :nil?
        client_config.must_be :nil?
        "pubsub-project-object-empty"
      }
      Google::Cloud.stub :pubsub, stubbed_pubsub do
        project = gcloud.pubsub
        project.must_equal "pubsub-project-object-empty"
      end
    end

    it "passes project and keyfile to Google::Cloud.pubsub" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_pubsub = ->(project, keyfile, scope: nil, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        keyfile.must_equal "keyfile-path"
        scope.must_be :nil?
        timeout.must_be :nil?
        client_config.must_be :nil?
        "pubsub-project-object"
      }
      Google::Cloud.stub :pubsub, stubbed_pubsub do
        project = gcloud.pubsub
        project.must_equal "pubsub-project-object"
      end
    end

    it "passes project and keyfile and options to Google::Cloud.pubsub" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_pubsub = ->(project, keyfile, scope: nil, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        keyfile.must_equal "keyfile-path"
        scope.must_equal "http://example.com/scope"
        timeout.must_equal 60
        client_config.must_equal 5
        "pubsub-project-object-scoped"
      }
      Google::Cloud.stub :pubsub, stubbed_pubsub do
        project = gcloud.pubsub scope: "http://example.com/scope", timeout: 60, client_config: 5
        project.must_equal "pubsub-project-object-scoped"
      end
    end
  end

  describe ".pubsub" do
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
          Google::Cloud::Pubsub::Credentials.stub :default, default_credentials do
            pubsub = Google::Cloud.pubsub
            pubsub.must_be_kind_of Google::Cloud::Pubsub::Project
            pubsub.project.must_equal "project-id"
            pubsub.service.credentials.must_equal default_credentials
          end
        end
      end
    end

    it "uses provided project_id and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "pubsub-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        credentials.must_equal "pubsub-credentials"
        client_config.must_be :nil?
        timeout.must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Pubsub::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Pubsub::Service.stub :new, stubbed_service do
                pubsub = Google::Cloud.pubsub "project-id", "path/to/keyfile.json"
                pubsub.must_be_kind_of Google::Cloud::Pubsub::Project
                pubsub.project.must_equal "project-id"
                pubsub.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end
  end

  describe "Pubsub.new" do
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

    it "gets defaults for project_id and keyfile" do
      # Clear all environment variables
      ENV.stub :[], nil do
        # Get project_id from Google Compute Engine
        Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
          Google::Cloud::Pubsub::Credentials.stub :default, default_credentials do
            pubsub = Google::Cloud::Pubsub.new
            pubsub.must_be_kind_of Google::Cloud::Pubsub::Project
            pubsub.project.must_equal "project-id"
            pubsub.service.credentials.must_equal default_credentials
          end
        end
      end
    end

    it "uses provided project_id and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "pubsub-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        credentials.must_equal "pubsub-credentials"
        timeout.must_be :nil?
        client_config.must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Pubsub::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Pubsub::Service.stub :new, stubbed_service do
                pubsub = Google::Cloud::Pubsub.new project_id: "project-id", credentials: "path/to/keyfile.json"
                pubsub.must_be_kind_of Google::Cloud::Pubsub::Project
                pubsub.project.must_equal "project-id"
                pubsub.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses provided project and keyfile aliases" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "pubsub-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        credentials.must_equal "pubsub-credentials"
        timeout.must_be :nil?
        client_config.must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Pubsub::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Pubsub::Service.stub :new, stubbed_service do
                pubsub = Google::Cloud::Pubsub.new project: "project-id", keyfile: "path/to/keyfile.json"
                pubsub.must_be_kind_of Google::Cloud::Pubsub::Project
                pubsub.project.must_equal "project-id"
                pubsub.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses PUBSUB_EMULATOR_HOST environment variable" do
      emulator_host = "localhost:4567"
      emulator_check = ->(name) { (name == "PUBSUB_EMULATOR_HOST") ? emulator_host : nil }
      # Clear all environment variables, except PUBSUB_EMULATOR_HOST
      ENV.stub :[], emulator_check do
        # Get project_id from Google Compute Engine
        Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
          Google::Cloud::Pubsub::Credentials.stub :default, default_credentials do
            pubsub = Google::Cloud::Pubsub.new
            pubsub.must_be_kind_of Google::Cloud::Pubsub::Project
            pubsub.project.must_equal "project-id"
            pubsub.service.credentials.must_equal :this_channel_is_insecure
            pubsub.service.host.must_equal emulator_host
          end
        end
      end
    end

    it "allows emulator_host to be set" do
      emulator_host = "localhost:4567"
      # Clear all environment variables
      ENV.stub :[], nil do
        # Get project_id from Google Compute Engine
        Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
          Google::Cloud::Pubsub::Credentials.stub :default, default_credentials do
            pubsub = Google::Cloud::Pubsub.new emulator_host: emulator_host
            pubsub.must_be_kind_of Google::Cloud::Pubsub::Project
            pubsub.project.must_equal "project-id"
            pubsub.service.credentials.must_equal :this_channel_is_insecure
            pubsub.service.host.must_equal emulator_host
          end
        end
      end
    end
  end

  describe "Pubsub.configure" do
    let(:found_credentials) { "{}" }
    let :pubsub_client_config do
      {"interfaces"=>
        {"google.pubsub.v1.Pubsub"=>
          {"retry_codes"=>{"idempotent"=>["DEADLINE_EXCEEDED", "UNAVAILABLE"]}}}}
    end

    after do
      Google::Cloud.configure.reset!
    end

    it "uses shared config for project and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "pubsub-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        credentials.must_equal "pubsub-credentials"
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
            Google::Cloud::Pubsub::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Pubsub::Service.stub :new, stubbed_service do
                pubsub = Google::Cloud::Pubsub.new
                pubsub.must_be_kind_of Google::Cloud::Pubsub::Project
                pubsub.project.must_equal "project-id"
                pubsub.service.must_be_kind_of OpenStruct
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
        "pubsub-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        credentials.must_equal "pubsub-credentials"
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
            Google::Cloud::Pubsub::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Pubsub::Service.stub :new, stubbed_service do
                pubsub = Google::Cloud::Pubsub.new
                pubsub.must_be_kind_of Google::Cloud::Pubsub::Project
                pubsub.project.must_equal "project-id"
                pubsub.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses pubsub config for project and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "pubsub-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        credentials.must_equal "pubsub-credentials"
        timeout.must_equal 42
        client_config.must_equal pubsub_client_config
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud::Pubsub.configure do |config|
          config.project = "project-id"
          config.keyfile = "path/to/keyfile.json"
          config.timeout = 42
          config.client_config = pubsub_client_config
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Pubsub::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Pubsub::Service.stub :new, stubbed_service do
                pubsub = Google::Cloud::Pubsub.new
                pubsub.must_be_kind_of Google::Cloud::Pubsub::Project
                pubsub.project.must_equal "project-id"
                pubsub.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses pubsub config for project_id and credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "pubsub-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        credentials.must_equal "pubsub-credentials"
        timeout.must_equal 42
        client_config.must_equal pubsub_client_config
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud::Pubsub.configure do |config|
          config.project_id = "project-id"
          config.credentials = "path/to/keyfile.json"
          config.timeout = 42
          config.client_config = pubsub_client_config
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Pubsub::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Pubsub::Service.stub :new, stubbed_service do
                pubsub = Google::Cloud::Pubsub.new
                pubsub.must_be_kind_of Google::Cloud::Pubsub::Project
                pubsub.project.must_equal "project-id"
                pubsub.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses pubsub config for emulator_host" do
      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud::Pubsub.configure do |config|
          config.project_id = "project-id"
          config.emulator_host = "localhost:4567"
        end

        pubsub = Google::Cloud::Pubsub.new
        pubsub.must_be_kind_of Google::Cloud::Pubsub::Project
        pubsub.project.must_equal "project-id"
        pubsub.service.credentials.must_equal :this_channel_is_insecure
        pubsub.service.host.must_equal "localhost:4567"
      end
    end
  end
end
