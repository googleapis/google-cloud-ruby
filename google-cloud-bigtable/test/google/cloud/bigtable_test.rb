# frozen_string_literal: true

# Copyright 2018 Google LLC
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
  let(:found_credentials) { "{}" }
  let(:default_scope) do
    [
      "https://www.googleapis.com/auth/bigtable.admin",
      "https://www.googleapis.com/auth/bigtable.admin.cluster",
      "https://www.googleapis.com/auth/bigtable.admin.instance",
      "https://www.googleapis.com/auth/bigtable.admin.table",
      "https://www.googleapis.com/auth/bigtable.data",
      "https://www.googleapis.com/auth/bigtable.data.readonly",
      "https://www.googleapis.com/auth/cloud-bigtable.admin",
      "https://www.googleapis.com/auth/cloud-bigtable.admin.cluster",
      "https://www.googleapis.com/auth/cloud-bigtable.admin.table",
      "https://www.googleapis.com/auth/cloud-bigtable.data",
      "https://www.googleapis.com/auth/cloud-bigtable.data.readonly",
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/cloud-platform.read-only"
    ]
  end
  let(:default_host) { "bigtable.googleapis.com" }
  let(:default_host_admin) { "bigtableadmin.googleapis.com" }
  describe "#bigtable" do
    it "calls out to Google::Cloud.bigtable" do
      gcloud = Google::Cloud.new
      stubbed_bigtable = lambda { |project_id: nil, credentials: nil, scope: nil, timeout: nil, host: nil|
        _(project_id).must_be :nil?
        _(credentials).must_be :nil?
        _(scope).must_be :nil?
        _(timeout).must_be :nil?
        _(host).must_be :nil?
        "bigtable-project-object-empty"
      }
      Google::Cloud.stub(:bigtable, stubbed_bigtable) do
        project = gcloud.bigtable
        _(project).must_equal "bigtable-project-object-empty"
      end
    end

    it "passes project and credentials(keyfile) to Google::Cloud.bigtable" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_bigtable = lambda { |project_id: nil, credentials: nil, scope: nil, timeout: nil, host: nil|
        _(project_id).must_equal "project-id"
        _(credentials).must_equal "keyfile-path"
        _(scope).must_be :nil?
        _(timeout).must_be :nil?
        _(host).must_be :nil?
        "bigtable-project-object"
      }

      Google::Cloud.stub(:bigtable, stubbed_bigtable) do
        project = gcloud.bigtable
        _(project).must_equal "bigtable-project-object"
      end
    end

    it "passes project and credentials(keyfile) and options to Google::Cloud.bigtable" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_bigtable = lambda { |project_id: nil, credentials: nil, scope: nil, timeout: nil, host: nil|
        _(project_id).must_equal "project-id"
        _(credentials).must_equal "keyfile-path"
        _(scope).must_equal "http://example.com/scope"
        _(timeout).must_equal 60
        _(host).must_be :nil?
        "bigtable-project-object-scoped"
      }
      Google::Cloud.stub :bigtable, stubbed_bigtable do
        project = gcloud.bigtable(
          scope: "http://example.com/scope",
          timeout: 60
        )
        _(project).must_equal "bigtable-project-object-scoped"
      end
    end
  end

  describe ".bigtable" do
    let(:default_credentials) do
      creds = OpenStruct.new empty: true
      def creds.is_a? target
        target == Google::Auth::Credentials
      end
      creds
    end

    it "gets defaults for project_id and credentials(keyfile)" do
      # Clear all environment variables
      ENV.stub :[], nil do
        # Get project_id from Google Compute Engine
        Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
          Google::Cloud::Bigtable::Credentials.stub(:default, default_credentials) do
            bigtable = Google::Cloud.bigtable
            _(bigtable).must_be_kind_of Google::Cloud::Bigtable::Project
            _(bigtable.project_id).must_equal "project-id"
            _(bigtable.service.credentials).must_equal default_credentials
          end
        end
      end
    end

    it "uses provided project_id and credentials(keyfile)" do
      stubbed_credentials = lambda { |keyfile, scope: nil|
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_equal default_scope
        "bigtable-credentials"
      }
      stubbed_service = lambda { |project_id, credentials, timeout: nil, host: nil, host_admin: nil, channel_selection: nil, channel_count: nil|
        _(project_id).must_equal "project-id"
        _(credentials).must_equal "bigtable-credentials"
        _(timeout).must_be :nil?
        _(host).must_equal default_host
        _(host_admin).must_equal default_host_admin
        OpenStruct.new(project_id: project_id)
      }

      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Bigtable::Credentials.stub(:new, stubbed_credentials) do
              Google::Cloud::Bigtable::Service.stub(:new, stubbed_service) do
                bigtable = Google::Cloud.bigtable(
                  project_id: "project-id",
                  credentials: "path/to/keyfile.json"
                )
                _(bigtable).must_be_kind_of Google::Cloud::Bigtable::Project
                _(bigtable.project_id).must_equal "project-id"
                _(bigtable.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end
  end

  describe "Bigtable.new" do
    let(:default_credentials) do
      creds = OpenStruct.new empty: true
      def creds.is_a? target
        target == Google::Auth::Credentials
      end
      creds
    end
    let(:found_credentials) { "{}" }

    it "gets defaults for project_id and credentials" do
      # Clear all environment variables
      ENV.stub :[], nil do
        # Get project_id from Google Compute Engine
        Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
          Google::Cloud::Bigtable::Credentials.stub :default, default_credentials do
            bigtable = Google::Cloud::Bigtable.new
            _(bigtable).must_be_kind_of Google::Cloud::Bigtable::Project
            _(bigtable.project_id).must_equal "project-id"
            _(bigtable.service.credentials).must_equal default_credentials
          end
        end
      end
    end

    it "uses provided endpoints" do
      stubbed_service = lambda { |project_id, credentials, timeout: nil, host: nil, host_admin: nil, channel_selection: nil, channel_count: nil|
        _(credentials).must_equal default_credentials
        _(timeout).must_be :nil?
        _(host).must_equal "bigtable-endpoint2.example.com"
        _(host_admin).must_equal "bigtable-admin-endpoint2.example.com"
        OpenStruct.new project_id: project_id
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        Google::Cloud::Bigtable::Service.stub :new, stubbed_service do
          bigtable = Google::Cloud::Bigtable.new project_id: "project-id",
                                                 credentials: default_credentials,
                                                 endpoint: "bigtable-endpoint2.example.com",
                                                 endpoint_admin: "bigtable-admin-endpoint2.example.com"
          _(bigtable).must_be_kind_of Google::Cloud::Bigtable::Project
          _(bigtable.project_id).must_equal "project-id"
          _(bigtable.service).must_be_kind_of OpenStruct
        end
      end
    end

    it "uses provided project_id and credentials" do
      stubbed_credentials = lambda { |keyfile, scope: nil|
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_equal default_scope
        "bigtable-credentials"
      }
      stubbed_service = lambda { |project_id, credentials, timeout: nil, host: nil, host_admin: nil, channel_selection: nil, channel_count: nil|
        _(project_id).must_equal "project-id"
        _(credentials).must_equal "bigtable-credentials"
        _(timeout).must_be :nil?
        _(host).must_equal default_host
        _(host_admin).must_equal default_host_admin
        OpenStruct.new project_id: project_id
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Bigtable::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Bigtable::Service.stub :new, stubbed_service do
                bigtable = Google::Cloud::Bigtable.new project_id: "project-id", credentials: "path/to/keyfile.json"
                _(bigtable).must_be_kind_of Google::Cloud::Bigtable::Project
                _(bigtable.project_id).must_equal "project-id"
                _(bigtable.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses provided project and keyfile aliases" do
      stubbed_credentials = lambda { |keyfile, scope: nil|
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_equal default_scope
        "bigtable-credentials"
      }
      stubbed_service = lambda { |project_id, credentials, timeout: nil, host: nil, host_admin: nil, channel_selection: nil, channel_count: nil|
        _(project_id).must_equal "project-id"
        _(credentials).must_equal "bigtable-credentials"
        _(timeout).must_be :nil?
        _(host).must_equal default_host
        _(host_admin).must_equal default_host_admin
        OpenStruct.new project_id: project_id
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Bigtable::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Bigtable::Service.stub :new, stubbed_service do
                bigtable = Google::Cloud::Bigtable.new project_id: "project-id", credentials: "path/to/keyfile.json"
                _(bigtable).must_be_kind_of Google::Cloud::Bigtable::Project
                _(bigtable.project_id).must_equal "project-id"
                _(bigtable.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses provided channel_selection and channel_count" do
      stubbed_credentials = lambda { |keyfile, scope: nil|
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_equal default_scope
        "bigtable-credentials"
      }
      stubbed_service = lambda { |project_id, credentials, timeout: nil, host: nil, host_admin: nil, channel_selection: nil, channel_count: nil|
        _(project_id).must_equal "project-id"
        _(credentials).must_equal "bigtable-credentials"
        _(timeout).must_be :nil?
        _(host).must_equal default_host
        _(host_admin).must_equal default_host_admin
        _(channel_selection).must_equal :least_loaded
        _(channel_count).must_equal 5
        OpenStruct.new project_id: project_id
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Bigtable::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Bigtable::Service.stub :new, stubbed_service do
                bigtable = Google::Cloud::Bigtable.new project_id: "project-id", credentials: "path/to/keyfile.json", channel_selection: :least_loaded, channel_count: 5
                _(bigtable).must_be_kind_of Google::Cloud::Bigtable::Project
                _(bigtable.project_id).must_equal "project-id"
                _(bigtable.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses BIGTABLE_EMULATOR_HOST environment variable" do
      emulator_host = "localhost:4567"
      emulator_check = ->(name) { (name == "BIGTABLE_EMULATOR_HOST") ? emulator_host : nil }
      # Clear all environment variables, except BIGTABLE_EMULATOR_HOST
      ENV.stub :[], emulator_check do
        # Get project_id from Google Compute Engine
        Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
          Google::Cloud::Bigtable::Credentials.stub :default, default_credentials do
            bigtable = Google::Cloud::Bigtable.new
            _(bigtable).must_be_kind_of Google::Cloud::Bigtable::Project
            _(bigtable.project_id).must_equal "project-id"
            _(bigtable.service.credentials).must_equal :this_channel_is_insecure
            _(bigtable.service.host).must_equal emulator_host
            _(bigtable.service.host_admin).must_equal emulator_host
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
          Google::Cloud::Bigtable::Credentials.stub :default, default_credentials do
            bigtable = Google::Cloud::Bigtable.new emulator_host: emulator_host
            _(bigtable).must_be_kind_of Google::Cloud::Bigtable::Project
            _(bigtable.project_id).must_equal "project-id"
            _(bigtable.service.credentials).must_equal :this_channel_is_insecure
            _(bigtable.service.host).must_equal emulator_host
          end
        end
      end
    end

    it "gets project_id from credentials" do
      stubbed_credentials = lambda { |keyfile, scope: nil|
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_equal default_scope
        OpenStruct.new project_id: "project-id"
      }
      stubbed_service = lambda { |project_id, credentials, timeout: nil, host: nil, host_admin: nil, channel_selection: nil, channel_count: nil|
        _(project_id).must_equal "project-id"
        _(credentials).must_be_kind_of OpenStruct
        _(credentials.project_id).must_equal "project-id"
        _(timeout).must_be :nil?
        _(host).must_equal default_host
        _(host_admin).must_equal default_host_admin
        OpenStruct.new project_id: project_id
      }
      empty_env = OpenStruct.new

      # Clear all environment variables
      ENV.stub :[], nil do
        Google::Cloud.stub :env, empty_env do
          File.stub :file?, true, ["path/to/keyfile.json"] do
            File.stub :read, found_credentials, ["path/to/keyfile.json"] do
              Google::Cloud::Bigtable::Credentials.stub :new, stubbed_credentials do
                Google::Cloud::Bigtable::Service.stub :new, stubbed_service do
                  bigtable = Google::Cloud::Bigtable.new credentials: "path/to/keyfile.json"
                  _(bigtable).must_be_kind_of Google::Cloud::Bigtable::Project
                  _(bigtable.project_id).must_equal "project-id"
                  _(bigtable.service).must_be_kind_of OpenStruct
                end
              end
            end
          end
        end
      end
    end

    it "uses channel config" do
      stubbed_service = lambda { |project_id, credentials, timeout: nil, host: nil, host_admin: nil, channel_selection: nil, channel_count: nil|
        _(credentials).must_equal default_credentials
        _(timeout).must_be :nil?
        _(channel_selection).must_equal :least_loaded
        _(channel_count).must_equal 5
        OpenStruct.new project_id: project_id
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        Google::Cloud::Bigtable::Service.stub :new, stubbed_service do
          bigtable = Google::Cloud::Bigtable.new project_id: "project-id",
                                                 credentials: default_credentials,
                                                 channel_selection: :least_loaded,
                                                 channel_count: 5
          _(bigtable).must_be_kind_of Google::Cloud::Bigtable::Project
          _(bigtable.project_id).must_equal "project-id"
          _(bigtable.service).must_be_kind_of OpenStruct
        end
      end
    end
  end

  describe "bigtable.configure" do
    let(:found_credentials) { "{}" }

    after do
      Google::Cloud.configure.reset!
    end

    it "uses shared config for project and keyfile" do
      stubbed_credentials = lambda { |keyfile, scope: nil|
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_equal default_scope
        "bigtable-credentials"
      }
      stubbed_service = lambda { |project_id, credentials, timeout: nil, host: nil, host_admin: nil, channel_selection: nil, channel_count: nil|
        _(project_id).must_equal "project-id"
        _(credentials).must_equal "bigtable-credentials"
        _(timeout).must_be :nil?
        _(host).must_equal default_host
        _(host_admin).must_equal default_host_admin

        OpenStruct.new project_id: project_id
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud.configure do |config|
          config.project_id = "project-id"
          config.keyfile = "path/to/keyfile.json"
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Bigtable::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Bigtable::Service.stub :new, stubbed_service do
                bigtable = Google::Cloud::Bigtable.new
                _(bigtable).must_be_kind_of Google::Cloud::Bigtable::Project
                _(bigtable.project_id).must_equal "project-id"
                _(bigtable.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses shared config for project_id and credentials" do
      stubbed_credentials = lambda { |keyfile, scope: nil|
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_equal default_scope
        "bigtable-credentials"
      }
      stubbed_service = lambda { |project_id, credentials, timeout: nil, host: nil, host_admin: nil, channel_selection: nil, channel_count: nil|
        _(project_id).must_equal "project-id"
        _(credentials).must_equal "bigtable-credentials"
        _(timeout).must_be :nil?
        _(host).must_equal default_host
        _(host_admin).must_equal default_host_admin
        OpenStruct.new project_id: project_id
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
            Google::Cloud::Bigtable::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Bigtable::Service.stub :new, stubbed_service do
                bigtable = Google::Cloud::Bigtable.new
                _(bigtable).must_be_kind_of Google::Cloud::Bigtable::Project
                _(bigtable.project_id).must_equal "project-id"
                _(bigtable.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses bigtable config for project and keyfile" do
      stubbed_credentials = lambda { |credentials, scope: nil|
        _(credentials).must_equal "path/to/keyfile.json"
        _(scope).must_equal default_scope
        "bigtable-credentials"
      }
      stubbed_service = lambda { |project_id, credentials, timeout: nil, host: nil, host_admin: nil, channel_selection: nil, channel_count: nil|
        _(project_id).must_equal "project-id"
        _(credentials).must_equal "bigtable-credentials"
        _(timeout).must_equal 42
        _(host).must_equal default_host
        _(host_admin).must_equal default_host_admin
        OpenStruct.new project_id: project_id
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud::Bigtable.configure do |config|
          config.project_id = "project-id"
          config.credentials = "path/to/keyfile.json"
          config.timeout = 42
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Bigtable::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Bigtable::Service.stub :new, stubbed_service do
                bigtable = Google::Cloud::Bigtable.new
                _(bigtable).must_be_kind_of Google::Cloud::Bigtable::Project
                _(bigtable.project_id).must_equal "project-id"
                _(bigtable.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses bigtable config for project_id and credentials" do
      stubbed_credentials = lambda { |keyfile, scope: nil|
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_equal default_scope
        "bigtable-credentials"
      }
      stubbed_service = lambda { |project_id, credentials, timeout: nil, host: nil, host_admin: nil, channel_selection: nil, channel_count: nil|
        _(project_id).must_equal "project-id"
        _(credentials).must_equal "bigtable-credentials"
        _(timeout).must_equal 42
        _(host).must_equal default_host
        _(host_admin).must_equal default_host_admin
        OpenStruct.new project_id: project_id
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud::Bigtable.configure do |config|
          config.project_id = "project-id"
          config.credentials = "path/to/keyfile.json"
          config.timeout = 42
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Bigtable::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Bigtable::Service.stub :new, stubbed_service do
                bigtable = Google::Cloud::Bigtable.new
                _(bigtable).must_be_kind_of Google::Cloud::Bigtable::Project
                _(bigtable.project_id).must_equal "project-id"
                _(bigtable.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses bigtable config for endpoints" do
      stubbed_credentials = lambda { |keyfile, scope: nil|
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_equal default_scope
        "bigtable-credentials"
      }
      stubbed_service = lambda { |project_id, credentials, timeout: nil, host: nil, host_admin: nil, channel_selection: nil, channel_count: nil|
        _(project_id).must_equal "project-id"
        _(credentials).must_equal "bigtable-credentials"
        _(host).must_equal "bigtable-endpoint2.example.com"
        _(host_admin).must_equal "bigtable-admin-endpoint2.example.com"
        OpenStruct.new project_id: project_id
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud::Bigtable.configure do |config|
          config.project_id = "project-id"
          config.credentials = "path/to/keyfile.json"
          config.endpoint = "bigtable-endpoint2.example.com"
          config.endpoint_admin = "bigtable-admin-endpoint2.example.com"
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Bigtable::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Bigtable::Service.stub :new, stubbed_service do
                bigtable = Google::Cloud::Bigtable.new
                _(bigtable).must_be_kind_of Google::Cloud::Bigtable::Project
                _(bigtable.project_id).must_equal "project-id"
                _(bigtable.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses bigtable config for channel config" do
      stubbed_credentials = lambda { |keyfile, scope: nil|
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_equal default_scope
        "bigtable-credentials"
      }
      stubbed_service = lambda { |project_id, credentials, timeout: nil, host: nil, host_admin: nil, channel_selection: nil, channel_count: nil|
        _(project_id).must_equal "project-id"
        _(credentials).must_equal "bigtable-credentials"
        _(channel_selection).must_equal :least_loaded
        _(channel_count).must_equal 5
        OpenStruct.new project_id: project_id
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud::Bigtable.configure do |config|
          config.project_id = "project-id"
          config.credentials = "path/to/keyfile.json"
          config.channel_selection = :least_loaded
          config.channel_count = 5
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Bigtable::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Bigtable::Service.stub :new, stubbed_service do
                bigtable = Google::Cloud::Bigtable.new
                _(bigtable).must_be_kind_of Google::Cloud::Bigtable::Project
                _(bigtable.project_id).must_equal "project-id"
                _(bigtable.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end
  end
end
