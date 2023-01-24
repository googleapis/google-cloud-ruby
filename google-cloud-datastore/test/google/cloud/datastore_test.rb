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

describe Google do
  it "aliases Google::Datastore to Google::Cloud::Datastore" do
    assert defined?(::Google::Datastore)
  end
end

describe Google::Cloud do
  let(:default_scope) do
    [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/datastore"
    ]
  end
  let(:default_host) { "datastore.googleapis.com" }
  describe "#datastore" do
    it "calls out to Google::Cloud.datastore" do
      gcloud = Google::Cloud.new
      stubbed_datastore = ->(project, keyfile, scope: nil, timeout: nil, host: nil, database_id: nil) {
        _(project).must_be :nil?
        _(keyfile).must_be :nil?
        _(scope).must_be :nil?
        _(timeout).must_be :nil?
        _(host).must_be :nil?
        "datastore-dataset-object-empty"
      }
      Google::Cloud.stub :datastore, stubbed_datastore do
        dataset = gcloud.datastore
        _(dataset).must_equal "datastore-dataset-object-empty"
      end
    end

    it "passes project and keyfile to Google::Cloud.datastore" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_datastore = ->(project, keyfile, scope: nil, timeout: nil, host: nil, database_id: nil) {
        _(project).must_equal "project-id"
        _(keyfile).must_equal "keyfile-path"
        _(scope).must_be :nil?
        _(timeout).must_be :nil?
        _(host).must_be :nil?
        "datastore-dataset-object"
      }
      Google::Cloud.stub :datastore, stubbed_datastore do
        dataset = gcloud.datastore
        _(dataset).must_equal "datastore-dataset-object"
      end
    end

    it "passes project and keyfile and options to Google::Cloud.datastore" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_datastore = ->(project, keyfile, scope: nil, timeout: nil, host: nil, database_id: nil) {
        _(project).must_equal "project-id"
        _(keyfile).must_equal "keyfile-path"
        _(scope).must_equal "http://example.com/scope"
        _(timeout).must_equal 60
        _(host).must_be :nil?
        "datastore-dataset-object-scoped"
      }
      Google::Cloud.stub :datastore, stubbed_datastore do
        dataset = gcloud.datastore scope: "http://example.com/scope", timeout: 60
        _(dataset).must_equal "datastore-dataset-object-scoped"
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
            _(datastore).must_be_kind_of Google::Cloud::Datastore::Dataset
            _(datastore.project).must_equal "project-id"
            _(datastore.service.credentials).must_equal default_credentials
          end
        end
      end
    end

    it "uses provided project_id and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_equal default_scope
        "datastore-credentials"
      }
      stubbed_service = ->(project, credentials, default_database, timeout: nil, host: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "datastore-credentials"
        _(timeout).must_be :nil?
        _(host).must_equal default_host
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Datastore::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Datastore::Service.stub :new, stubbed_service do
                datastore = Google::Cloud.datastore "project-id", "path/to/keyfile.json"
                _(datastore).must_be_kind_of Google::Cloud::Datastore::Dataset
                _(datastore.project).must_equal "project-id"
                _(datastore.service).must_be_kind_of OpenStruct
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

    after do
      Google::Cloud.configure.reset!
    end

    it "gets defaults for project_id and keyfile" do
      # Clear all environment variables
      ENV.stub :[], nil do
        # Get project_id from Google Compute Engine
        Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
          Google::Cloud::Datastore::Credentials.stub :default, default_credentials do
            datastore = Google::Cloud::Datastore.new
            _(datastore).must_be_kind_of Google::Cloud::Datastore::Dataset
            _(datastore.project).must_equal "project-id"
            _(datastore.service.credentials).must_equal default_credentials
          end
        end
      end
    end

    it "uses provided project_id and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_equal default_scope
        "datastore-credentials"
      }
      stubbed_service = ->(project, credentials, default_database, timeout: nil, host: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "datastore-credentials"
        _(timeout).must_be :nil?
        _(host).must_equal default_host
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Datastore::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Datastore::Service.stub :new, stubbed_service do
                datastore = Google::Cloud::Datastore.new project_id: "project-id", credentials: "path/to/keyfile.json"
                _(datastore).must_be_kind_of Google::Cloud::Datastore::Dataset
                _(datastore.project).must_equal "project-id"
                _(datastore.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses provided project and keyfile aliases" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_equal default_scope
        "datastore-credentials"
      }
      stubbed_service = ->(project, credentials, default_database, timeout: nil, host: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "datastore-credentials"
        _(timeout).must_be :nil?
        _(host).must_equal default_host
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Datastore::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Datastore::Service.stub :new, stubbed_service do
                datastore = Google::Cloud::Datastore.new project: "project-id", keyfile: "path/to/keyfile.json"
                _(datastore).must_be_kind_of Google::Cloud::Datastore::Dataset
                _(datastore.project).must_equal "project-id"
                _(datastore.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses provided endpoint" do
      endpoint = "datastore-endpoint2.example.com"
      stubbed_service = ->(project, credentials, default_database, timeout: nil, host: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal default_credentials
        _(timeout).must_be :nil?
        _(host).must_equal endpoint
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        Google::Cloud::Datastore::Service.stub :new, stubbed_service do
          datastore = Google::Cloud::Datastore.new project: "project-id", credentials: default_credentials, endpoint: endpoint
          _(datastore).must_be_kind_of Google::Cloud::Datastore::Dataset
          _(datastore.project).must_equal "project-id"
          _(datastore.service).must_be_kind_of OpenStruct
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
            _(datastore).must_be_kind_of Google::Cloud::Datastore::Dataset
            _(datastore.project).must_equal "project-id"
            _(datastore.service.credentials).must_equal :this_channel_is_insecure
            _(datastore.service.host).must_equal emulator_host
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
            _(datastore).must_be_kind_of Google::Cloud::Datastore::Dataset
            _(datastore.project).must_equal "project-id"
            _(datastore.service.credentials).must_equal :this_channel_is_insecure
            _(datastore.service.host).must_equal emulator_host
          # end
        end
      end
    end

    it "gets project_id from credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_equal default_scope
        OpenStruct.new project_id: "project-id"
      }
      stubbed_service = ->(project, credentials, default_database, timeout: nil, host: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_be_kind_of OpenStruct
        _(credentials.project_id).must_equal "project-id"
        _(timeout).must_be :nil?
        _(host).must_equal default_host
        OpenStruct.new project: project
      }
      empty_env = OpenStruct.new

      # Clear all environment variables
      ENV.stub :[], nil do
        Google::Cloud.stub :env, empty_env do
          File.stub :file?, true, ["path/to/keyfile.json"] do
            File.stub :read, found_credentials, ["path/to/keyfile.json"] do
              Google::Cloud::Datastore::Credentials.stub :new, stubbed_credentials do
                Google::Cloud::Datastore::Service.stub :new, stubbed_service do
                  datastore = Google::Cloud::Datastore.new credentials: "path/to/keyfile.json"
                  _(datastore).must_be_kind_of Google::Cloud::Datastore::Dataset
                  _(datastore.project).must_equal "project-id"
                  _(datastore.service).must_be_kind_of OpenStruct
                end
              end
            end
          end
        end
      end
    end
  end

  describe "Datastore.configure" do
    let(:found_credentials) { "{}" }

    after do
      Google::Cloud.configure.reset!
    end

    it "uses shared config for project and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_equal default_scope
        "datastore-credentials"
      }
      stubbed_service = ->(project, credentials, default_database, timeout: nil, host: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "datastore-credentials"
        _(timeout).must_be :nil?
        _(host).must_equal default_host
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
            Google::Cloud::Datastore::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Datastore::Service.stub :new, stubbed_service do
                datastore = Google::Cloud::Datastore.new
                _(datastore).must_be_kind_of Google::Cloud::Datastore::Dataset
                _(datastore.project).must_equal "project-id"
                _(datastore.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses shared config for project_id and credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_equal default_scope
        "datastore-credentials"
      }
      stubbed_service = ->(project, credentials, default_database, timeout: nil, host: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "datastore-credentials"
        _(timeout).must_be :nil?
        _(host).must_equal default_host
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
            Google::Cloud::Datastore::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Datastore::Service.stub :new, stubbed_service do
                datastore = Google::Cloud::Datastore.new
                _(datastore).must_be_kind_of Google::Cloud::Datastore::Dataset
                _(datastore.project).must_equal "project-id"
                _(datastore.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses datastore config for project and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_equal default_scope
        "datastore-credentials"
      }
      stubbed_service = ->(project, credentials, default_database, timeout: nil, host: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "datastore-credentials"
        _(timeout).must_equal 42
        _(host).must_equal default_host
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud::Datastore.configure do |config|
          config.project = "project-id"
          config.keyfile = "path/to/keyfile.json"
          config.timeout = 42
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Datastore::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Datastore::Service.stub :new, stubbed_service do
                datastore = Google::Cloud::Datastore.new
                _(datastore).must_be_kind_of Google::Cloud::Datastore::Dataset
                _(datastore.project).must_equal "project-id"
                _(datastore.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses datastore config for project_id and credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_equal default_scope
        "datastore-credentials"
      }
      stubbed_service = ->(project, credentials, default_database, timeout: nil, host: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "datastore-credentials"
        _(timeout).must_equal 42
        _(host).must_equal default_host
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud::Datastore.configure do |config|
          config.project_id = "project-id"
          config.credentials = "path/to/keyfile.json"
          config.timeout = 42
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Datastore::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Datastore::Service.stub :new, stubbed_service do
                datastore = Google::Cloud::Datastore.new
                _(datastore).must_be_kind_of Google::Cloud::Datastore::Dataset
                _(datastore.project).must_equal "project-id"
                _(datastore.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses datastore config for endpoint" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_equal default_scope
        "datastore-credentials"
      }
      stubbed_service = ->(project, credentials, default_database, timeout: nil, host: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "datastore-credentials"
        _(timeout).must_be :nil?
        _(host).must_equal "datastore-endpoint2.example.com"
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud::Datastore.configure do |config|
          config.project = "project-id"
          config.keyfile = "path/to/keyfile.json"
          config.endpoint = "datastore-endpoint2.example.com"
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Datastore::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Datastore::Service.stub :new, stubbed_service do
                datastore = Google::Cloud::Datastore.new
                _(datastore).must_be_kind_of Google::Cloud::Datastore::Dataset
                _(datastore.project).must_equal "project-id"
                _(datastore.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses datastore config for emulator_host" do
      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud::Datastore.configure do |config|
          config.project_id = "project-id"
          config.emulator_host = "localhost:4567"
        end

        datastore = Google::Cloud::Datastore.new
        _(datastore).must_be_kind_of Google::Cloud::Datastore::Dataset
        _(datastore.project).must_equal "project-id"
        _(datastore.service.credentials).must_equal :this_channel_is_insecure
        _(datastore.service.host).must_equal "localhost:4567"
      end
    end
  end
end
