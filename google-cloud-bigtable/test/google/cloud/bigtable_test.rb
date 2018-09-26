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
  describe "#bigtable" do
    it "calls out to Google::Cloud.bigtable" do
      gcloud = Google::Cloud.new
      stubbed_bigtable = lambda { |project_id: nil, credentials: nil, scope: nil, timeout: nil, client_config: nil|
        project_id.must_be :nil?
        credentials.must_be :nil?
        scope.must_be :nil?
        timeout.must_be :nil?
        client_config.must_be :nil?
        "bigtable-project-object-empty"
      }
      Google::Cloud.stub(:bigtable, stubbed_bigtable) do
        project = gcloud.bigtable
        project.must_equal "bigtable-project-object-empty"
      end
    end

    it "passes project and credentials(keyfile) to Google::Cloud.bigtable" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_bigtable = lambda  { |project_id: nil, credentials: nil, scope: nil, timeout: nil, client_config: nil|
        project_id.must_equal "project-id"
        credentials.must_equal "keyfile-path"
        scope.must_be :nil?
        timeout.must_be :nil?
        client_config.must_be :nil?
        "bigtable-project-object"
      }

      Google::Cloud.stub(:bigtable, stubbed_bigtable) do
        project = gcloud.bigtable
        project.must_equal "bigtable-project-object"
      end
    end

    it "passes project and credentials(keyfile) and options to Google::Cloud.bigtable" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_bigtable = lambda { |project_id: nil, credentials: nil, scope: nil, timeout: nil, client_config: nil|
        project_id.must_equal "project-id"
        credentials.must_equal "keyfile-path"
        scope.must_equal "http://example.com/scope"
        timeout.must_equal 60
        client_config.must_equal("gax" => "options")
        "bigtable-project-object-scoped"
      }
      Google::Cloud.stub :bigtable, stubbed_bigtable do
        project = gcloud.bigtable(
          scope: "http://example.com/scope",
          timeout: 60,
          client_config: { "gax" => "options" }
        )
        project.must_equal "bigtable-project-object-scoped"
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
    let(:found_credentials) { "{}" }

    it "gets defaults for project_id and credentials(keyfile)" do
      # Clear all environment variables
      ENV.stub :[], nil do
        # Get project_id from Google Compute Engine
        Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
          Google::Cloud::Bigtable::Credentials.stub(:default, default_credentials) do
            bigtable = Google::Cloud.bigtable
            bigtable.must_be_kind_of Google::Cloud::Bigtable::Project
            bigtable.project_id.must_equal "project-id"
            bigtable.service.credentials.must_equal default_credentials
          end
        end
      end
    end

    it "uses provided project_id and credentials(keyfile)" do
      stubbed_credentials = lambda { |keyfile, scope: nil|
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "bigtable-credentials"
      }
      stubbed_service = lambda { |project_id, credentials, timeout: nil, client_config: nil|
        project_id.must_equal "project-id"
        credentials.must_equal "bigtable-credentials"
        timeout.must_be :nil?
        client_config.must_be :nil?
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
                bigtable.must_be_kind_of Google::Cloud::Bigtable::Project
                bigtable.project_id.must_equal "project-id"
                bigtable.service.must_be_kind_of OpenStruct
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
            bigtable.must_be_kind_of Google::Cloud::Bigtable::Project
            bigtable.project_id.must_equal "project-id"
            bigtable.service.credentials.must_equal default_credentials
          end
        end
      end
    end

    it "uses provided project_id and credentials" do
      stubbed_credentials = lambda { |keyfile, scope: nil|
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "bigtable-credentials"
      }
      stubbed_service = lambda { |project_id, credentials, timeout: nil, client_config: nil|
        project_id.must_equal "project-id"
        credentials.must_equal "bigtable-credentials"
        timeout.must_be :nil?
        client_config.must_be :nil?
        OpenStruct.new project_id: project_id
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Bigtable::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Bigtable::Service.stub :new, stubbed_service do
                bigtable = Google::Cloud::Bigtable.new project_id: "project-id", credentials: "path/to/keyfile.json"
                bigtable.must_be_kind_of Google::Cloud::Bigtable::Project
                bigtable.project_id.must_equal "project-id"
                bigtable.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses provided project and keyfile aliases" do
      stubbed_credentials = lambda { |keyfile, scope: nil|
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "bigtable-credentials"
      }
      stubbed_service = lambda { |project_id, credentials, timeout: nil, client_config: nil|
        project_id.must_equal "project-id"
        credentials.must_equal "bigtable-credentials"
        timeout.must_be :nil?
        client_config.must_be :nil?
        OpenStruct.new project_id: project_id
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Bigtable::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Bigtable::Service.stub :new, stubbed_service do
                bigtable = Google::Cloud::Bigtable.new project_id: "project-id", credentials: "path/to/keyfile.json"
                bigtable.must_be_kind_of Google::Cloud::Bigtable::Project
                bigtable.project_id.must_equal "project-id"
                bigtable.service.must_be_kind_of OpenStruct
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
            bigtable.must_be_kind_of Google::Cloud::Bigtable::Project
            bigtable.project_id.must_equal "project-id"
            bigtable.service.credentials.must_equal :this_channel_is_insecure
            bigtable.service.host.must_equal emulator_host
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
            bigtable.must_be_kind_of Google::Cloud::Bigtable::Project
            bigtable.project_id.must_equal "project-id"
            bigtable.service.credentials.must_equal :this_channel_is_insecure
            bigtable.service.host.must_equal emulator_host
          end
        end
      end
    end
  end

  describe "bigtable.configure" do
    let(:found_credentials) { "{}" }
    let :bigtable_client_config do
      { "interfaces" =>
        { "google.bigtable.v1.bigtable" =>
          { "retry_codes" => { "idempotent" => %w[DEADLINE_EXCEEDED UNAVAILABLE] } } } }
    end

    after do
      Google::Cloud.configure.reset!
    end

    it "uses shared config for project and keyfile" do
      stubbed_credentials = lambda { |keyfile, scope: nil|
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "bigtable-credentials"
      }
      stubbed_service = lambda { |project_id, credentials, timeout: nil, client_config: nil|
        project_id.must_equal "project-id"
        credentials.must_equal "bigtable-credentials"
        timeout.must_be :nil?
        client_config.must_be :nil?
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
                bigtable.must_be_kind_of Google::Cloud::Bigtable::Project
                bigtable.project_id.must_equal "project-id"
                bigtable.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses shared config for project_id and credentials" do
      stubbed_credentials = lambda { |keyfile, scope: nil|
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "bigtable-credentials"
      }
      stubbed_service = lambda { |project_id, credentials, timeout: nil, client_config: nil|
        project_id.must_equal "project-id"
        credentials.must_equal "bigtable-credentials"
        timeout.must_be :nil?
        client_config.must_be :nil?
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
                bigtable.must_be_kind_of Google::Cloud::Bigtable::Project
                bigtable.project_id.must_equal "project-id"
                bigtable.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses bigtable config for project and keyfile" do
      stubbed_credentials = lambda { |credentials, scope: nil|
        credentials.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "bigtable-credentials"
      }
      stubbed_service = lambda { |project_id, credentials, timeout: nil, client_config: nil|
        project_id.must_equal "project-id"
        credentials.must_equal "bigtable-credentials"
        timeout.must_equal 42
        client_config.must_equal bigtable_client_config
        OpenStruct.new project_id: project_id
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud::Bigtable.configure do |config|
          config.project_id = "project-id"
          config.credentials = "path/to/keyfile.json"
          config.timeout = 42
          config.client_config = bigtable_client_config
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Bigtable::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Bigtable::Service.stub :new, stubbed_service do
                bigtable = Google::Cloud::Bigtable.new
                bigtable.must_be_kind_of Google::Cloud::Bigtable::Project
                bigtable.project_id.must_equal "project-id"
                bigtable.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses bigtable config for project_id and credentials" do
      stubbed_credentials = lambda { |keyfile, scope: nil|
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "bigtable-credentials"
      }
      stubbed_service = lambda { |project_id, credentials, timeout: nil, client_config: nil|
        project_id.must_equal "project-id"
        credentials.must_equal "bigtable-credentials"
        timeout.must_equal 42
        client_config.must_equal bigtable_client_config
        OpenStruct.new project_id: project_id
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configuration
        Google::Cloud::Bigtable.configure do |config|
          config.project_id = "project-id"
          config.credentials = "path/to/keyfile.json"
          config.timeout = 42
          config.client_config = bigtable_client_config
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Bigtable::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Bigtable::Service.stub :new, stubbed_service do
                bigtable = Google::Cloud::Bigtable.new
                bigtable.must_be_kind_of Google::Cloud::Bigtable::Project
                bigtable.project_id.must_equal "project-id"
                bigtable.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end
  end
end
