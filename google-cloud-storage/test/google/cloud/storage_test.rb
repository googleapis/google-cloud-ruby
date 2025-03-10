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
      stubbed_storage = ->(project, keyfile, scope: nil, retries: nil, timeout: nil, open_timeout: nil, read_timeout: nil, send_timeout: nil, host: nil, max_elapsed_time: nil, base_interval: nil, max_interval: nil, multiplier: nil, upload_chunk_size: nil) {
        _(project).must_be :nil?
        _(keyfile).must_be :nil?
        _(scope).must_be :nil?
        _(retries).must_be :nil?
        _(timeout).must_be :nil?
        _(open_timeout).must_be :nil?
        _(read_timeout).must_be :nil?
        _(send_timeout).must_be :nil?
        _(host).must_be :nil?
        _(max_elapsed_time).must_be :nil?
        _(base_interval).must_be :nil?
        _(max_interval).must_be :nil?
        _(multiplier).must_be :nil?
        _(upload_chunk_size).must_be :nil?
        "storage-project-object-empty"
      }
      Google::Cloud.stub :storage, stubbed_storage do
        project = gcloud.storage
        _(project).must_equal "storage-project-object-empty"
      end
    end

    it "passes project and keyfile to Google::Cloud.storage" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_storage = ->(project, keyfile, scope: nil, retries: nil, timeout: nil, open_timeout: nil, read_timeout: nil, send_timeout: nil, host: nil, max_elapsed_time: nil, base_interval: nil, max_interval: nil, multiplier: nil, upload_chunk_size: nil) {
        _(project).must_equal "project-id"
        _(keyfile).must_equal "keyfile-path"
        _(scope).must_be :nil?
        _(retries).must_be :nil?
        _(timeout).must_be :nil?
        _(open_timeout).must_be :nil?
        _(read_timeout).must_be :nil?
        _(send_timeout).must_be :nil?
        _(host).must_be :nil?
        _(max_elapsed_time).must_be :nil?
        _(base_interval).must_be :nil?
        _(max_interval).must_be :nil?
        _(multiplier).must_be :nil?
        _(upload_chunk_size).must_be :nil?
        "storage-project-object"
      }
      Google::Cloud.stub :storage, stubbed_storage do
        project = gcloud.storage
        _(project).must_equal "storage-project-object"
      end
    end

    it "passes project and keyfile and options to Google::Cloud.storage" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_storage = ->(project, keyfile, scope: nil, retries: nil, timeout: nil, open_timeout: nil, read_timeout: nil, send_timeout: nil, host: nil, max_elapsed_time: nil, base_interval: nil, max_interval: nil, multiplier: nil, upload_chunk_size: nil) {
        _(project).must_equal "project-id"
        _(keyfile).must_equal "keyfile-path"
        _(scope).must_equal "http://example.com/scope"
        _(retries).must_equal 5
        _(timeout).must_equal 60
        _(open_timeout).must_equal 30
        _(read_timeout).must_equal 60
        _(send_timeout).must_equal 60
        _(host).must_be :nil?
        _(max_elapsed_time).must_equal 1000
        _(base_interval).must_equal 2
        _(max_interval).must_equal 30
        _(multiplier).must_equal 1
        _(upload_chunk_size).must_equal 100
        "storage-project-object-scoped"
      }
      Google::Cloud.stub :storage, stubbed_storage do
        project = gcloud.storage scope: "http://example.com/scope", retries: 5, timeout: 60, open_timeout: 30,
                                 max_elapsed_time: 1000, base_interval: 2, max_interval: 30, multiplier: 1, upload_chunk_size: 100
        _(project).must_equal "storage-project-object-scoped"
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
            _(storage).must_be_kind_of Google::Cloud::Storage::Project
            _(storage.project).must_equal "project-id"
            _(storage.service.credentials).must_equal default_credentials
          end
        end
      end
    end

    it "uses provided project_id and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_be :nil?
        "storage-credentials"
      }
      stubbed_service = ->(project, credentials, retries: nil, timeout: nil, open_timeout: nil, read_timeout: nil, send_timeout: nil, host: nil, quota_project: nil, max_elapsed_time: nil, base_interval: nil,
        max_interval: nil, multiplier: nil, upload_chunk_size: nil, universe_domain: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "storage-credentials"
        _(retries).must_be :nil?
        _(timeout).must_be :nil?
        _(open_timeout).must_be :nil?
        _(read_timeout).must_be :nil?
        _(send_timeout).must_be :nil?
        _(host).must_be :nil?
        _(universe_domain).must_be :nil?
        _(max_elapsed_time).must_be :nil?
        _(base_interval).must_be :nil?
        _(max_interval).must_be :nil?
        _(base_interval).must_be :nil?
        _(multiplier).must_be :nil?
        _(upload_chunk_size).must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Storage::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Storage::Service.stub :new, stubbed_service do
                storage = Google::Cloud.storage "project-id", "path/to/keyfile.json"
                _(storage).must_be_kind_of Google::Cloud::Storage::Project
                _(storage.project).must_equal "project-id"
                _(storage.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end
  end

  describe "Storage.anonymous" do
    it "uses provided options" do
      stubbed_service = ->(project, credentials, retries: nil, timeout: nil, open_timeout: nil, read_timeout: nil, send_timeout: nil, host: nil, quota_project: nil, max_elapsed_time: nil, base_interval: nil,
        max_interval: nil, multiplier: nil, upload_chunk_size: nil, universe_domain: nil) {
        _(project).must_be :nil?
        _(credentials).must_be :nil?
        _(retries).must_equal 5
        _(timeout).must_equal 60
        _(open_timeout).must_equal 60
        _(read_timeout).must_equal 30
        _(send_timeout).must_equal 60
        _(host).must_equal "storage-endpoint2.example.com"
        _(universe_domain).must_equal "myuniverse1.com"
        _(max_elapsed_time).must_equal 1000
        _(base_interval).must_equal 2
        _(max_interval).must_equal 30
        _(multiplier).must_equal 1
        _(upload_chunk_size).must_equal 100
        OpenStruct.new project: project
      }
      # Clear all environment variables
      ENV.stub :[], nil do
        Google::Cloud::Storage::Service.stub :new, stubbed_service do
          storage = Google::Cloud::Storage.anonymous retries: 5, timeout: 60, read_timeout: 30, endpoint: "storage-endpoint2.example.com", max_elapsed_time: 1000, base_interval: 2, max_interval: 30,
            multiplier: 1, upload_chunk_size: 100, universe_domain: "myuniverse1.com"
          _(storage).must_be_kind_of Google::Cloud::Storage::Project
          _(storage.project).must_be :nil?
          _(storage.service.credentials).must_be :nil?
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
            _(storage).must_be_kind_of Google::Cloud::Storage::Project
            _(storage.project).must_equal "project-id"
            _(storage.service.credentials).must_equal default_credentials
          end
        end
      end
    end

    it "uses provided endpoint and universe_domain" do
      stubbed_service = ->(project, credentials, retries: nil, timeout: nil, open_timeout: nil, read_timeout: nil, send_timeout: nil, host: nil, quota_project: nil, max_elapsed_time: nil, base_interval: nil,
        max_interval: nil, multiplier: nil, upload_chunk_size: nil, universe_domain: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal default_credentials
        _(retries).must_be :nil?
        _(timeout).must_be :nil?
        _(open_timeout).must_be :nil?
        _(read_timeout).must_be :nil?
        _(send_timeout).must_be :nil?
        _(host).must_equal "storage-endpoint2.example.com"
        _(universe_domain).must_equal "myuniverse2.com"
        _(max_elapsed_time).must_be :nil?
        _(base_interval).must_be :nil?
        _(max_interval).must_be :nil?
        _(multiplier).must_be :nil?
        _(upload_chunk_size).must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
          Google::Cloud::Storage::Service.stub :new, stubbed_service do
            storage = Google::Cloud::Storage.new credentials: default_credentials,
                                                 endpoint: "storage-endpoint2.example.com",
                                                 universe_domain: "myuniverse2.com"
            _(storage).must_be_kind_of Google::Cloud::Storage::Project
            _(storage.project).must_equal "project-id"
            _(storage.service).must_be_kind_of OpenStruct
          end
        end
      end
    end

    it "uses provided project_id and credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_be :nil?
        "storage-credentials"
      }
      stubbed_service = ->(project, credentials, retries: nil, timeout: nil, open_timeout: nil, read_timeout: nil, send_timeout: nil, host: nil, quota_project: nil, max_elapsed_time: nil, base_interval: nil,
        max_interval: nil, multiplier: nil, upload_chunk_size: nil, universe_domain: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "storage-credentials"
        _(retries).must_be :nil?
        _(timeout).must_be :nil?
        _(open_timeout).must_be :nil?
        _(read_timeout).must_be :nil?
        _(send_timeout).must_be :nil?
        _(host).must_be :nil?
        _(universe_domain).must_be :nil?
        _(max_elapsed_time).must_be :nil?
        _(base_interval).must_be :nil?
        _(max_interval).must_be :nil?
        _(multiplier).must_be :nil?
        _(upload_chunk_size).must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Storage::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Storage::Service.stub :new, stubbed_service do
                storage = Google::Cloud::Storage.new project_id: "project-id", credentials: "path/to/keyfile.json"
                _(storage).must_be_kind_of Google::Cloud::Storage::Project
                _(storage.project).must_equal "project-id"
                _(storage.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses provided project and keyfile aliases" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_be :nil?
        "storage-credentials"
      }
      stubbed_service = ->(project, credentials, retries: nil, timeout: nil, open_timeout: nil, read_timeout: nil, send_timeout: nil, host: nil, quota_project: nil, max_elapsed_time: nil, base_interval: nil,
        max_interval: nil, multiplier: nil, upload_chunk_size: nil, universe_domain: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "storage-credentials"
        _(retries).must_be :nil?
        _(timeout).must_be :nil?
        _(open_timeout).must_be :nil?
        _(read_timeout).must_be :nil?
        _(send_timeout).must_be :nil?
        _(host).must_be :nil?
        _(universe_domain).must_be :nil?
        _(max_elapsed_time).must_be :nil?
        _(base_interval).must_be :nil?
        _(max_interval).must_be :nil?
        _(multiplier).must_be :nil?
        _(upload_chunk_size).must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Storage::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Storage::Service.stub :new, stubbed_service do
                storage = Google::Cloud::Storage.new project: "project-id", keyfile: "path/to/keyfile.json"
                _(storage).must_be_kind_of Google::Cloud::Storage::Project
                _(storage.project).must_equal "project-id"
                _(storage.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "gets project_id from credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_be :nil?
        OpenStruct.new project_id: "project-id"
      }
      stubbed_service = ->(project, credentials, retries: nil, timeout: nil, open_timeout: nil, read_timeout: nil, send_timeout: nil, host: nil, quota_project: nil, max_elapsed_time: nil, base_interval: nil,
        max_interval: nil, multiplier: nil, upload_chunk_size: nil, universe_domain: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_be_kind_of OpenStruct
        _(credentials.project_id).must_equal "project-id"
        _(retries).must_be :nil?
        _(timeout).must_be :nil?
        _(open_timeout).must_be :nil?
        _(read_timeout).must_be :nil?
        _(send_timeout).must_be :nil?
        _(host).must_be :nil?
        _(universe_domain).must_be :nil?
        _(max_elapsed_time).must_be :nil?
        _(base_interval).must_be :nil?
        _(max_interval).must_be :nil?
        _(multiplier).must_be :nil?
        _(upload_chunk_size).must_be :nil?
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
                  _(storage).must_be_kind_of Google::Cloud::Storage::Project
                  _(storage.project).must_equal "project-id"
                  _(storage.service).must_be_kind_of OpenStruct
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
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_be :nil?
        "storage-credentials"
      }
      stubbed_service = ->(project, credentials, retries: nil, timeout: nil, open_timeout: nil, read_timeout: nil, send_timeout: nil, host: nil, quota_project: nil, max_elapsed_time: nil, base_interval: nil,
        max_interval: nil, multiplier: nil, upload_chunk_size: nil, universe_domain: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "storage-credentials"
        _(retries).must_be :nil?
        _(timeout).must_be :nil?
        _(open_timeout).must_be :nil?
        _(read_timeout).must_be :nil?
        _(send_timeout).must_be :nil?
        _(host).must_be :nil?
        _(universe_domain).must_be :nil?
        _(max_elapsed_time).must_be :nil?
        _(base_interval).must_be :nil?
        _(max_interval).must_be :nil?
        _(multiplier).must_be :nil?
        _(upload_chunk_size).must_be :nil?
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
                _(storage).must_be_kind_of Google::Cloud::Storage::Project
                _(storage.project).must_equal "project-id"
                _(storage.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses shared config for project_id and credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_be :nil?
        "storage-credentials"
      }
      stubbed_service = ->(project, credentials, retries: nil, timeout: nil, open_timeout: nil, read_timeout: nil, send_timeout: nil, host: nil, quota_project: nil, max_elapsed_time: nil, base_interval: nil,
        max_interval: nil, multiplier: nil, upload_chunk_size: nil, universe_domain: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "storage-credentials"
        _(retries).must_be :nil?
        _(timeout).must_be :nil?
        _(open_timeout).must_be :nil?
        _(read_timeout).must_be :nil?
        _(send_timeout).must_be :nil?
        _(host).must_be :nil?
        _(universe_domain).must_be :nil?
        _(max_elapsed_time).must_be :nil?
        _(base_interval).must_be :nil?
        _(max_interval).must_be :nil?
        _(multiplier).must_be :nil?
        _(upload_chunk_size).must_be :nil?
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
                _(storage).must_be_kind_of Google::Cloud::Storage::Project
                _(storage.project).must_equal "project-id"
                _(storage.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses storage config for project and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_be :nil?
        "storage-credentials"
      }
      stubbed_service = ->(project, credentials, retries: nil, timeout: nil, open_timeout: nil, read_timeout: nil, send_timeout: nil, host: nil, quota_project: nil, max_elapsed_time: nil, base_interval: nil,
        max_interval: nil, multiplier: nil, upload_chunk_size: nil, universe_domain: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "storage-credentials"
        _(retries).must_equal 3
        _(timeout).must_equal 42
        _(open_timeout).must_equal 24
        _(read_timeout).must_equal 42
        _(send_timeout).must_equal 42
        _(host).must_be :nil?
        _(universe_domain).must_be :nil?
        _(max_elapsed_time).must_equal 1000
        _(base_interval).must_equal 2
        _(max_interval).must_equal 30
        _(multiplier).must_equal 1
        _(upload_chunk_size).must_equal 100
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
          config.open_timeout = 24
          config.max_elapsed_time = 1000
          config.base_interval = 2.0
          config.max_interval = 30
          config.multiplier = 1
          config.upload_chunk_size = 100
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Storage::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Storage::Service.stub :new, stubbed_service do
                storage = Google::Cloud::Storage.new
                _(storage).must_be_kind_of Google::Cloud::Storage::Project
                _(storage.project).must_equal "project-id"
                _(storage.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses storage config for project_id and credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_be :nil?
        "storage-credentials"
      }
      stubbed_service = ->(project, credentials, retries: nil, timeout: nil, open_timeout: nil, read_timeout: nil, send_timeout: nil, host: nil, quota_project: nil, max_elapsed_time: nil, base_interval: nil,
        max_interval: nil, multiplier: nil, upload_chunk_size: nil, universe_domain: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "storage-credentials"
        _(retries).must_equal 3
        _(timeout).must_equal 42
        _(open_timeout).must_equal 42
        _(read_timeout).must_equal 24
        _(send_timeout).must_equal 42
        _(host).must_be :nil?
        _(universe_domain).must_be :nil?
        _(max_elapsed_time).must_equal 1000
        _(base_interval).must_equal 2
        _(max_interval).must_equal 30
        _(multiplier).must_equal 1
        _(upload_chunk_size).must_equal 100
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
          config.read_timeout = 24
          config.max_elapsed_time = 1000
          config.base_interval = 2.0
          config.max_interval = 30
          config.multiplier = 1
          config.upload_chunk_size = 100
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Storage::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Storage::Service.stub :new, stubbed_service do
                storage = Google::Cloud::Storage.new
                _(storage).must_be_kind_of Google::Cloud::Storage::Project
                _(storage.project).must_equal "project-id"
                _(storage.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses storage config for endpoint and universe_domain" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_be :nil?
        "storage-credentials"
      }
      stubbed_service = ->(project, credentials, retries: nil, timeout: nil, open_timeout: nil, read_timeout: nil, send_timeout: nil, host: nil, quota_project: nil, max_elapsed_time: nil, base_interval: nil,
        max_interval: nil, multiplier: nil, upload_chunk_size: nil, universe_domain: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "storage-credentials"
        _(retries).must_equal 3
        _(timeout).must_equal 42
        _(open_timeout).must_equal 42
        _(read_timeout).must_equal 42
        _(send_timeout).must_equal 24
        _(host).must_equal "storage-endpoint2.example.com"
        _(universe_domain).must_equal "myuniverse3.com"
        _(max_elapsed_time).must_equal 1000
        _(base_interval).must_equal 2
        _(max_interval).must_equal 30
        _(multiplier).must_equal 1
        _(upload_chunk_size).must_equal 100
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
          config.send_timeout = 24
          config.endpoint = "storage-endpoint2.example.com"
          config.universe_domain = "myuniverse3.com"
          config.max_elapsed_time = 1000
          config.base_interval = 2.0
          config.max_interval = 30
          config.multiplier = 1
          config.upload_chunk_size = 100
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Storage::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Storage::Service.stub :new, stubbed_service do
                storage = Google::Cloud::Storage.new
                _(storage).must_be_kind_of Google::Cloud::Storage::Project
                _(storage.project).must_equal "project-id"
                _(storage.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses storage config for quota project" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_be :nil?
        "storage-credentials"
      }
      stubbed_service = ->(project, credentials, retries: nil, timeout: nil, open_timeout: nil, read_timeout: nil, send_timeout: nil, host: nil, quota_project: nil, max_elapsed_time: nil, base_interval: nil,
        max_interval: nil, multiplier: nil, upload_chunk_size: nil, universe_domain: nil) {
        _(project).must_equal "project-id"
        _(credentials).must_equal "storage-credentials"
        _(retries).must_equal 3
        _(timeout).must_equal 42
        _(open_timeout).must_equal 24
        _(read_timeout).must_equal 42
        _(send_timeout).must_equal 42
        _(host).must_be :nil?
        _(universe_domain).must_be :nil?
        _(quota_project).must_equal "project-id-2"
        _(max_elapsed_time).must_equal 1000
        _(base_interval).must_equal 2
        _(max_interval).must_equal 30
        _(multiplier).must_equal 1
        _(upload_chunk_size).must_equal 100
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
          config.open_timeout = 24
          config.quota_project = "project-id-2"
          config.max_elapsed_time = 1000
          config.base_interval = 2.0
          config.max_interval = 30
          config.multiplier = 1
          config.upload_chunk_size = 100
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Storage::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Storage::Service.stub :new, stubbed_service do
                storage = Google::Cloud::Storage.new
                _(storage).must_be_kind_of Google::Cloud::Storage::Project
                _(storage.project).must_equal "project-id"
                _(storage.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end
  end
end
