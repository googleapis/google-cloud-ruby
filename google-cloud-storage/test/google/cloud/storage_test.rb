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
require "google/cloud/storage"

describe Google::Cloud do
  describe "#storage" do
    it "calls out to Google::Cloud.storage" do
      gcloud = Google::Cloud.new
      stubbed_storage = ->(project, keyfile, scope: nil, retries: nil, timeout: nil) {
        project.must_be :nil?
        keyfile.must_be :nil?
        scope.must_be :nil?
        retries.must_be :nil?
        timeout.must_be :nil?
        "storage-project-object-empty"
      }
      Google::Cloud.stub :storage, stubbed_storage do
        project = gcloud.storage
        project.must_equal "storage-project-object-empty"
      end
    end

    it "passes project and keyfile to Google::Cloud.storage" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_storage = ->(project, keyfile, scope: nil, retries: nil, timeout: nil) {
        project.must_equal "project-id"
        keyfile.must_equal "keyfile-path"
        scope.must_be :nil?
        retries.must_be :nil?
        timeout.must_be :nil?
        "storage-project-object"
      }
      Google::Cloud.stub :storage, stubbed_storage do
        project = gcloud.storage
        project.must_equal "storage-project-object"
      end
    end

    it "passes project and keyfile and options to Google::Cloud.storage" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_storage = ->(project, keyfile, scope: nil, retries: nil, timeout: nil) {
        project.must_equal "project-id"
        keyfile.must_equal "keyfile-path"
        scope.must_equal "http://example.com/scope"
        retries.must_equal 5
        timeout.must_equal 60
        "storage-project-object-scoped"
      }
      Google::Cloud.stub :storage, stubbed_storage do
        project = gcloud.storage scope: "http://example.com/scope", retries: 5, timeout: 60
        project.must_equal "storage-project-object-scoped"
      end
    end
  end

  describe ".storage" do
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
          Google::Cloud::Storage::Credentials.stub :default, default_credentials do
            storage = Google::Cloud.storage
            storage.must_be_kind_of Google::Cloud::Storage::Project
            storage.project.must_equal "project-id"
            storage.service.credentials.must_equal default_credentials
          end
        end
      end
    end

    it "uses provided project_id and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "storage-credentials"
      }
      stubbed_service = ->(project, credentials, retries: nil, timeout: nil) {
        project.must_equal "project-id"
        credentials.must_equal "storage-credentials"
        retries.must_be :nil?
        timeout.must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Storage::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Storage::Service.stub :new, stubbed_service do
                storage = Google::Cloud.storage "project-id", "path/to/keyfile.json"
                storage.must_be_kind_of Google::Cloud::Storage::Project
                storage.project.must_equal "project-id"
                storage.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end
  end

  describe "Storage.new" do
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
          Google::Cloud::Storage::Credentials.stub :default, default_credentials do
            storage = Google::Cloud::Storage.new
            storage.must_be_kind_of Google::Cloud::Storage::Project
            storage.project.must_equal "project-id"
            storage.service.credentials.must_equal default_credentials
          end
        end
      end
    end

    it "uses provided project_id and credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "storage-credentials"
      }
      stubbed_service = ->(project, credentials, retries: nil, timeout: nil) {
        project.must_equal "project-id"
        credentials.must_equal "storage-credentials"
        retries.must_be :nil?
        timeout.must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Storage::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Storage::Service.stub :new, stubbed_service do
                storage = Google::Cloud::Storage.new project_id: "project-id", credentials: "path/to/keyfile.json"
                storage.must_be_kind_of Google::Cloud::Storage::Project
                storage.project.must_equal "project-id"
                storage.service.must_be_kind_of OpenStruct
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
        "storage-credentials"
      }
      stubbed_service = ->(project, credentials, retries: nil, timeout: nil) {
        project.must_equal "project-id"
        credentials.must_equal "storage-credentials"
        retries.must_be :nil?
        timeout.must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Storage::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Storage::Service.stub :new, stubbed_service do
                storage = Google::Cloud::Storage.new project: "project-id", keyfile: "path/to/keyfile.json"
                storage.must_be_kind_of Google::Cloud::Storage::Project
                storage.project.must_equal "project-id"
                storage.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "gets project_id from credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        OpenStruct.new project_id: "project-id"
      }
      stubbed_service = ->(project, credentials, retries: nil, timeout: nil) {
        project.must_equal "project-id"
        credentials.must_be_kind_of OpenStruct
        credentials.project_id.must_equal "project-id"
        retries.must_be :nil?
        timeout.must_be :nil?
        OpenStruct.new project: project
      }
      empty_env = OpenStruct.new

      # Clear all environment variables
      ENV.stub :[], nil do
        Google::Cloud.stub :env, empty_env do
          File.stub :file?, true, ["path/to/keyfile.json"] do
            File.stub :read, found_credentials, ["path/to/keyfile.json"] do
              Google::Cloud::Storage::Credentials.stub :new, stubbed_credentials do
                Google::Cloud::Storage::Service.stub :new, stubbed_service do
                  storage = Google::Cloud::Storage.new credentials: "path/to/keyfile.json"
                  storage.must_be_kind_of Google::Cloud::Storage::Project
                  storage.project.must_equal "project-id"
                  storage.service.must_be_kind_of OpenStruct
                end
              end
            end
          end
        end
      end
    end
  end

  describe "Storage.configure" do
    let(:found_credentials) { "{}" }

    after do
      Google::Cloud.configure.reset!
    end

    it "uses shared config for project and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "storage-credentials"
      }
      stubbed_service = ->(project, credentials, retries: nil, timeout: nil) {
        project.must_equal "project-id"
        credentials.must_equal "storage-credentials"
        retries.must_be :nil?
        timeout.must_be :nil?
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
            Google::Cloud::Storage::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Storage::Service.stub :new, stubbed_service do
                storage = Google::Cloud::Storage.new
                storage.must_be_kind_of Google::Cloud::Storage::Project
                storage.project.must_equal "project-id"
                storage.service.must_be_kind_of OpenStruct
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
        "storage-credentials"
      }
      stubbed_service = ->(project, credentials, retries: nil, timeout: nil) {
        project.must_equal "project-id"
        credentials.must_equal "storage-credentials"
        retries.must_be :nil?
        timeout.must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configurations
        Google::Cloud.configure do |config|
          config.project_id = "project-id"
          config.credentials = "path/to/keyfile.json"
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Storage::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Storage::Service.stub :new, stubbed_service do
                storage = Google::Cloud::Storage.new
                storage.must_be_kind_of Google::Cloud::Storage::Project
                storage.project.must_equal "project-id"
                storage.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses storage config for project and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "storage-credentials"
      }
      stubbed_service = ->(project, credentials, retries: nil, timeout: nil) {
        project.must_equal "project-id"
        credentials.must_equal "storage-credentials"
        retries.must_equal 3
        timeout.must_equal 42
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud::Storage.configure do |config|
          config.project = "project-id"
          config.keyfile = "path/to/keyfile.json"
          config.retries = 3
          config.timeout = 42
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Storage::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Storage::Service.stub :new, stubbed_service do
                storage = Google::Cloud::Storage.new
                storage.must_be_kind_of Google::Cloud::Storage::Project
                storage.project.must_equal "project-id"
                storage.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses storage config for project_id and credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "storage-credentials"
      }
      stubbed_service = ->(project, credentials, retries: nil, timeout: nil) {
        project.must_equal "project-id"
        credentials.must_equal "storage-credentials"
        retries.must_equal 3
        timeout.must_equal 42
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configurations
        Google::Cloud::Storage.configure do |config|
          config.project_id = "project-id"
          config.credentials = "path/to/keyfile.json"
          config.retries = 3
          config.timeout = 42
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Storage::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Storage::Service.stub :new, stubbed_service do
                storage = Google::Cloud::Storage.new
                storage.must_be_kind_of Google::Cloud::Storage::Project
                storage.project.must_equal "project-id"
                storage.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end
  end
end
