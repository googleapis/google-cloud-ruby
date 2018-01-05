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
require "google/cloud/datastore"

describe Google::Cloud do
  describe "#datastore" do
    it "calls out to Google::Cloud.datastore" do
      gcloud = Google::Cloud.new
      stubbed_datastore = ->(project, keyfile, scope: nil, timeout: nil, client_config: nil) {
        project.must_be :nil?
        keyfile.must_be :nil?
        scope.must_be :nil?
        timeout.must_be :nil?
        client_config.must_be :nil?
        "datastore-dataset-object-empty"
      }
      Google::Cloud.stub :datastore, stubbed_datastore do
        dataset = gcloud.datastore
        dataset.must_equal "datastore-dataset-object-empty"
      end
    end

    it "passes project and keyfile to Google::Cloud.datastore" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_datastore = ->(project, keyfile, scope: nil, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        keyfile.must_equal "keyfile-path"
        scope.must_be :nil?
        timeout.must_be :nil?
        client_config.must_be :nil?
        "datastore-dataset-object"
      }
      Google::Cloud.stub :datastore, stubbed_datastore do
        dataset = gcloud.datastore
        dataset.must_equal "datastore-dataset-object"
      end
    end

    it "passes project and keyfile and options to Google::Cloud.datastore" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_datastore = ->(project, keyfile, scope: nil, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        keyfile.must_equal "keyfile-path"
        scope.must_equal "http://example.com/scope"
        timeout.must_equal 60
        client_config.must_equal({ "gax" => "options" })
        "datastore-dataset-object-scoped"
      }
      Google::Cloud.stub :datastore, stubbed_datastore do
        dataset = gcloud.datastore scope: "http://example.com/scope", timeout: 60, client_config: { "gax" => "options" }
        dataset.must_equal "datastore-dataset-object-scoped"
      end
    end
  end

  describe ".datastore" do
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
          Google::Cloud::Datastore::Credentials.stub :default, default_credentials do
            datastore = Google::Cloud.datastore
            datastore.must_be_kind_of Google::Cloud::Datastore::Dataset
            datastore.project.must_equal "project-id"
            datastore.service.credentials.must_equal default_credentials
          end
        end
      end
    end

    it "uses provided project_id and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "datastore-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        credentials.must_equal "datastore-credentials"
        timeout.must_be :nil?
        client_config.must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Datastore::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Datastore::Service.stub :new, stubbed_service do
                datastore = Google::Cloud.datastore "project-id", "path/to/keyfile.json"
                datastore.must_be_kind_of Google::Cloud::Datastore::Dataset
                datastore.project.must_equal "project-id"
                datastore.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end
  end

  describe "Datastore.new" do
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
          Google::Cloud::Datastore::Credentials.stub :default, default_credentials do
            datastore = Google::Cloud::Datastore.new
            datastore.must_be_kind_of Google::Cloud::Datastore::Dataset
            datastore.project.must_equal "project-id"
            datastore.service.credentials.must_equal default_credentials
          end
        end
      end
    end

    it "uses provided project_id and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "datastore-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        credentials.must_equal "datastore-credentials"
        timeout.must_be :nil?
        client_config.must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Datastore::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Datastore::Service.stub :new, stubbed_service do
                datastore = Google::Cloud::Datastore.new project_id: "project-id", credentials: "path/to/keyfile.json"
                datastore.must_be_kind_of Google::Cloud::Datastore::Dataset
                datastore.project.must_equal "project-id"
                datastore.service.must_be_kind_of OpenStruct
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
        "datastore-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        credentials.must_equal "datastore-credentials"
        timeout.must_be :nil?
        client_config.must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Datastore::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Datastore::Service.stub :new, stubbed_service do
                datastore = Google::Cloud::Datastore.new project: "project-id", keyfile: "path/to/keyfile.json"
                datastore.must_be_kind_of Google::Cloud::Datastore::Dataset
                datastore.project.must_equal "project-id"
                datastore.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses DATASTORE_EMULATOR_HOST environment variable" do
      emulator_host = "localhost:4567"
      emulator_check = ->(name) { (name == "DATASTORE_EMULATOR_HOST") ? emulator_host : nil }
      # Clear all environment variables, except DATASTORE_EMULATOR_HOST
      ENV.stub :[], emulator_check do
        # Get project_id from Google Compute Engine
        Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
          Google::Cloud::Datastore::Credentials.stub :default, default_credentials do
            datastore = Google::Cloud::Datastore.new
            datastore.must_be_kind_of Google::Cloud::Datastore::Dataset
            datastore.project.must_equal "project-id"
            datastore.service.credentials.must_equal :this_channel_is_insecure
            datastore.service.host.must_equal emulator_host
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
          # Google::Cloud::Datastore::Credentials.stub :default, default_credentials do
            datastore = Google::Cloud::Datastore.new emulator_host: emulator_host
            datastore.must_be_kind_of Google::Cloud::Datastore::Dataset
            datastore.project.must_equal "project-id"
            datastore.service.credentials.must_equal :this_channel_is_insecure
            datastore.service.host.must_equal emulator_host
          # end
        end
      end
    end
  end

  describe "Datastore.configure" do
    let(:found_credentials) { "{}" }
    let :datastore_client_config do
      {"interfaces"=>
        {"google.datastore.v1.Datastore"=>
          {"retry_codes"=>{"idempotent"=>["DEADLINE_EXCEEDED", "UNAVAILABLE"]}}}}
    end

    after do
      Google::Cloud.configure.reset!
    end

    it "uses shared config for project and keyfile" do
      Google::Cloud.configure do |config|
        config.project = "project-id"
        config.keyfile = "path/to/keyfile.json"
      end

      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "datastore-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        credentials.must_equal "datastore-credentials"
        timeout.must_be :nil?
        client_config.must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Datastore::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Datastore::Service.stub :new, stubbed_service do
                datastore = Google::Cloud::Datastore.new
                datastore.must_be_kind_of Google::Cloud::Datastore::Dataset
                datastore.project.must_equal "project-id"
                datastore.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses shared config for project_id and credentials" do
      Google::Cloud.configure do |config|
        config.project_id = "project-id"
        config.credentials = "path/to/keyfile.json"
      end

      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "datastore-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        credentials.must_equal "datastore-credentials"
        timeout.must_be :nil?
        client_config.must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Datastore::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Datastore::Service.stub :new, stubbed_service do
                datastore = Google::Cloud::Datastore.new
                datastore.must_be_kind_of Google::Cloud::Datastore::Dataset
                datastore.project.must_equal "project-id"
                datastore.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses datastore config for project and keyfile" do
      Google::Cloud::Datastore.configure do |config|
        config.project = "project-id"
        config.keyfile = "path/to/keyfile.json"
        config.timeout = 42
        config.client_config = datastore_client_config
      end

      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "datastore-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        credentials.must_equal "datastore-credentials"
        timeout.must_equal 42
        client_config.must_equal datastore_client_config
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Datastore::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Datastore::Service.stub :new, stubbed_service do
                datastore = Google::Cloud::Datastore.new
                datastore.must_be_kind_of Google::Cloud::Datastore::Dataset
                datastore.project.must_equal "project-id"
                datastore.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses datastore config for project_id and credentials" do
      Google::Cloud::Datastore.configure do |config|
        config.project_id = "project-id"
        config.credentials = "path/to/keyfile.json"
        config.timeout = 42
        config.client_config = datastore_client_config
      end

      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "datastore-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        credentials.must_equal "datastore-credentials"
        timeout.must_equal 42
        client_config.must_equal datastore_client_config
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Datastore::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Datastore::Service.stub :new, stubbed_service do
                datastore = Google::Cloud::Datastore.new
                datastore.must_be_kind_of Google::Cloud::Datastore::Dataset
                datastore.project.must_equal "project-id"
                datastore.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses datastore config for emulator_host" do
      Google::Cloud::Datastore.configure do |config|
        config.project_id = "project-id"
        config.emulator_host = "localhost:4567"
      end

      # Clear all environment variables
      ENV.stub :[], nil do
        datastore = Google::Cloud::Datastore.new
        datastore.must_be_kind_of Google::Cloud::Datastore::Dataset
        datastore.project.must_equal "project-id"
        datastore.service.credentials.must_equal :this_channel_is_insecure
        datastore.service.host.must_equal "localhost:4567"
      end
    end
  end
end
