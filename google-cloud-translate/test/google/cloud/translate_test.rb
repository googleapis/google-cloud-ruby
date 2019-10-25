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
require "google/cloud/translate"
require "google/cloud/translate/v3"

describe Google::Cloud do
  describe "#translate" do
    it "calls out to Google::Cloud.translate" do
      gcloud = Google::Cloud.new
      stubbed_translate = ->(credentials: nil, scopes: nil, timeout: nil) {
        credentials.must_be :nil?
        scopes.must_be :nil?
        timeout.must_be :nil?
        "translate-project-object-empty"
      }
      ENV.stub :[], nil do
        Google::Cloud.stub :translate, stubbed_translate do
          project_id = gcloud.translate
          project_id.must_equal "translate-project-object-empty"
        end
      end
    end
    it "passes credentials to Google::Cloud.translate" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_translate = ->(credentials: nil, scopes: nil, timeout: nil) {
        credentials.must_equal "keyfile-path"
        scopes.must_be :nil?
        timeout.must_be :nil?
        "translate-api-object"
      }
      ENV.stub :[], nil do
        Google::Cloud.stub :translate, stubbed_translate do
          api = gcloud.translate
          api.must_equal "translate-api-object"
        end
      end
    end

    it "passes credentials and options to Google::Cloud.translate" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_translate = ->(credentials: nil, scopes: nil, timeout: nil) {
        credentials.must_equal "keyfile-path"
        scopes.must_be :nil?
        timeout.must_equal 60
        "translate-api-object-scoped"
      }
      ENV.stub :[], nil do
        Google::Cloud.stub :translate, stubbed_translate do
          api = gcloud.translate timeout: 60
          api.must_equal "translate-api-object-scoped"
        end
      end
    end
  end

  describe ".translate" do
    let(:default_credentials) do
      creds = OpenStruct.new(empty: true, updater_proc: ->(_) {})
      def creds.is_a? target
        target == Google::Auth::Credentials
      end
      creds
    end
    let(:found_credentials) { "{}" }

    it "gets defaults for credentials" do
      # Clear all environment variables
      ENV.stub :[], nil do
        Google::Cloud::Translate::V3::Credentials.stub :default, default_credentials do
          translate = Google::Cloud.translate
          translate.must_be_kind_of Google::Cloud::Translate::V3::TranslationServiceClient
        end
      end
    end

    it "uses provided project_id and credentials" do
      skip "Stubbing Google::Auth::Credentials doesn't clear, and v3 tests fail"
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        OpenStruct.new(updater_proc: ->(_) {})
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Auth::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Translate::V3::Credentials.stub :new, stubbed_credentials do
                translate = Google::Cloud.translate credentials: "path/to/keyfile.json"
                translate.must_be_kind_of Google::Cloud::Translate::V3::TranslationServiceClient
              end
            end
          end
        end
      end
    end
  end

  describe "Translate.new" do
    describe "version: :v3" do
      let(:default_credentials) do
        creds = OpenStruct.new(empty: true, updater_proc: ->(_) {})
        def creds.is_a? target
          target == Google::Auth::Credentials
        end
        creds
      end

      it "gets defaults for credentials" do
        # Clear all environment variables
        ENV.stub :[], nil do
          Google::Cloud::Translate::V3::Credentials.stub :default, default_credentials do
            translate = Google::Cloud::Translate.new
            translate.must_be_kind_of Google::Cloud::Translate::V3::TranslationServiceClient
          end
        end
      end
    end
    describe "version: :v2" do
      let(:default_credentials) do
        creds = OpenStruct.new empty: true
        def creds.is_a? target
          target == Google::Auth::Credentials
        end
        creds
      end
      let(:found_credentials) { "{}" }

      it "gets defaults for api key" do
        stubbed_env = ->(name) {
          "found-api-key" if name == "GOOGLE_CLOUD_KEY"
        }
        stubbed_service = ->(project_id, credentials, retries: nil, timeout: nil, host: nil, key: nil) {
          key.must_equal "found-api-key"
          project_id.must_be :empty?
          credentials.must_be :nil?
          retries.must_be :nil?
          timeout.must_be :nil?
          OpenStruct.new key: key
        }

        # Prevent return of actual project in any environment including GCE, etc.
        Google::Cloud::Translate::V2.stub :default_project_id, nil do
          # Clear all environment variables
          ENV.stub :[], stubbed_env do
            Google::Cloud::Translate::V2::Service.stub :new, stubbed_service do
              translate = Google::Cloud::Translate.new version: :v2
              translate.must_be_kind_of Google::Cloud::Translate::V2::Api
              translate.service.must_be_kind_of OpenStruct
              translate.service.key.must_equal "found-api-key"
            end
          end
        end
      end

      it "uses provided api key" do
        stubbed_service = ->(project_id, credentials, retries: nil, timeout: nil, host: nil, key: nil) {
          key.must_equal "my-api-key"
          project_id.must_be :empty?
          credentials.must_be :nil?
          retries.must_be :nil?
          timeout.must_be :nil?
          OpenStruct.new key: key
        }

        # Prevent return of actual project in any environment including GCE, etc.
        Google::Cloud::Translate::V2.stub :default_project_id, nil do
          # Clear all environment variables
          ENV.stub :[], nil do
            Google::Cloud::Translate::V2::Service.stub :new, stubbed_service do
              translate = Google::Cloud::Translate.new version: :v2, key: "my-api-key"
              translate.must_be_kind_of Google::Cloud::Translate::V2::Api
              translate.service.must_be_kind_of OpenStruct
              translate.service.key.must_equal "my-api-key"
            end
          end
        end
      end

      it "gets defaults for project_id and credentials" do
        # Clear all environment variables
        ENV.stub :[], nil do
          # Get project_id from Google Compute Engine
          Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
            Google::Cloud::Translate::V2::Credentials.stub :default, default_credentials do
              translate = Google::Cloud::Translate.new version: :v2
              translate.must_be_kind_of Google::Cloud::Translate::V2::Api
              translate.project_id.must_equal "project-id"
              translate.service.credentials.must_equal default_credentials
            end
          end
        end
      end

      it "uses provided project_id and credentials" do
        stubbed_credentials = ->(keyfile, scope: nil) {
          keyfile.must_equal "path/to/keyfile.json"
          scope.must_be :nil?
          "translate-credentials"
        }
        stubbed_service = ->(project_id, credentials, scope: nil, key: nil, retries: nil, timeout: nil, host: nil) {
          project_id.must_equal "project-id"
          credentials.must_equal "translate-credentials"
          scope.must_be :nil?
          key.must_be :nil?
          retries.must_be :nil?
          timeout.must_be :nil?
          host.must_be :nil?
          OpenStruct.new project_id: project_id
        }

        # Clear all environment variables
        ENV.stub :[], nil do
          File.stub :file?, true, ["path/to/keyfile.json"] do
            File.stub :read, found_credentials, ["path/to/keyfile.json"] do
              Google::Cloud::Translate::V2::Credentials.stub :new, stubbed_credentials do
                Google::Cloud::Translate::V2::Service.stub :new, stubbed_service do
                  translate = Google::Cloud::Translate.new version: :v2, project_id: "project-id", credentials: "path/to/keyfile.json"
                  translate.must_be_kind_of Google::Cloud::Translate::V2::Api
                  translate.project_id.must_equal "project-id"
                  translate.service.must_be_kind_of OpenStruct
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
        stubbed_service = ->(project_id, credentials, scope: nil, key: nil, retries: nil, timeout: nil, host: nil) {
          project_id.must_equal "project-id"
          credentials.must_be_kind_of OpenStruct
          credentials.project_id.must_equal "project-id"
          scope.must_be :nil?
          key.must_be :nil?
          retries.must_be :nil?
          timeout.must_be :nil?
          host.must_be :nil?
          OpenStruct.new project_id: project_id
        }
        empty_env = OpenStruct.new

        # Clear all environment variables
        ENV.stub :[], nil do
          Google::Cloud.stub :env, empty_env do
            File.stub :file?, true, ["path/to/keyfile.json"] do
              File.stub :read, found_credentials, ["path/to/keyfile.json"] do
                Google::Cloud::Translate::V2::Credentials.stub :new, stubbed_credentials do
                  Google::Cloud::Translate::V2::Service.stub :new, stubbed_service do
                    translate = Google::Cloud::Translate.new version: :v2, credentials: "path/to/keyfile.json"
                    translate.must_be_kind_of Google::Cloud::Translate::V2::Api
                    translate.project_id.must_equal "project-id"
                    translate.service.must_be_kind_of OpenStruct
                  end
                end
              end
            end
          end
        end
      end

      it "uses provided endpoint" do
        stubbed_credentials = ->(keyfile, scope: nil) {
          keyfile.must_equal "path/to/keyfile.json"
          scope.must_be :nil?
          "translate-credentials"
        }
        stubbed_service = ->(project_id, credentials, scope: nil, key: nil, retries: nil, timeout: nil, host: nil) {
          project_id.must_equal "project-id"
          credentials.must_equal "translate-credentials"
          host.must_equal "custom-translate-endpoint.example.com"
          scope.must_be :nil?
          key.must_be :nil?
          retries.must_be :nil?
          timeout.must_be :nil?
          OpenStruct.new project_id: project_id
        }

        # Clear all environment variables
        ENV.stub :[], nil do
          File.stub :file?, true, ["path/to/keyfile.json"] do
            File.stub :read, found_credentials, ["path/to/keyfile.json"] do
              Google::Cloud::Translate::V2::Credentials.stub :new, stubbed_credentials do
                Google::Cloud::Translate::V2::Service.stub :new, stubbed_service do
                  translate = Google::Cloud::Translate.new version: :v2, project_id: "project-id", credentials: "path/to/keyfile.json", endpoint: "custom-translate-endpoint.example.com"
                  translate.must_be_kind_of Google::Cloud::Translate::V2::Api
                  translate.project_id.must_equal "project-id"
                  translate.service.must_be_kind_of OpenStruct
                end
              end
            end
          end
        end
      end
    end
  end

  describe "Translate.configure" do
    let(:found_credentials) { "{}" }

    after do
      Google::Cloud.configure.reset!
    end

    it "uses shared config for project and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "translate-credentials"
      }
      stubbed_service = ->(project_id, credentials, scope: nil, key: nil, retries: nil, timeout: nil, host: nil) {
        project_id.must_equal "project-id"
        credentials.must_equal "translate-credentials"
        scope.must_be :nil?
        key.must_be :nil?
        retries.must_be :nil?
        timeout.must_be :nil?
        host.must_be :nil?
        OpenStruct.new project_id: project_id
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
            Google::Cloud::Translate::V2::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Translate::V2::Service.stub :new, stubbed_service do
                translate = Google::Cloud::Translate.new version: :v2
                translate.must_be_kind_of Google::Cloud::Translate::V2::Api
                translate.project_id.must_equal "project-id"
                translate.service.must_be_kind_of OpenStruct
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
        "translate-credentials"
      }
      stubbed_service = ->(project_id, credentials, scope: nil, key: nil, retries: nil, timeout: nil, host: nil) {
        project_id.must_equal "project-id"
        credentials.must_equal "translate-credentials"
        scope.must_be :nil?
        key.must_be :nil?
        retries.must_be :nil?
        timeout.must_be :nil?
        host.must_be :nil?
        OpenStruct.new project_id: project_id
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
            Google::Cloud::Translate::V2::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Translate::V2::Service.stub :new, stubbed_service do
                translate = Google::Cloud::Translate.new version: :v2
                translate.must_be_kind_of Google::Cloud::Translate::V2::Api
                translate.project_id.must_equal "project-id"
                translate.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses translate config for project_id and credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "translate-credentials"
      }
      stubbed_service = ->(project_id, credentials, scope: nil, key: nil, retries: nil, timeout: nil, host: nil) {
        project_id.must_equal "project-id"
        credentials.must_equal "translate-credentials"
        scope.must_be :nil?
        key.must_be :nil?
        retries.must_equal 3
        timeout.must_equal 42
        host.must_be :nil?
        OpenStruct.new project_id: project_id
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configurations
        Google::Cloud::Translate.configure do |config|
          config.project_id = "project-id"
          config.credentials = "path/to/keyfile.json"
          config.retries = 3
          config.timeout = 42
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Translate::V2::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Translate::V2::Service.stub :new, stubbed_service do
                translate = Google::Cloud::Translate.new version: :v2
                translate.must_be_kind_of Google::Cloud::Translate::V2::Api
                translate.project_id.must_equal "project-id"
                translate.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses translate config for key" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "translate-credentials"
      }
      stubbed_service = ->(project_id, credentials, scope: nil, key: nil, retries: nil, timeout: nil, host: nil) {
        key.must_equal "this-is-the-api-key"
        credentials.must_be :nil?
        scope.must_be :nil?
        retries.must_be :nil?
        timeout.must_be :nil?
        host.must_be :nil?
        OpenStruct.new project_id: project_id
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configurations
        Google::Cloud::Translate.configure do |config|
          config.key = "this-is-the-api-key"
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Translate::V2::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Translate::V2::Service.stub :new, stubbed_service do
                translate = Google::Cloud::Translate.new version: :v2
                translate.must_be_kind_of Google::Cloud::Translate::V2::Api
                translate.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses translate config for endpoint" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "translate-credentials"
      }
      stubbed_service = ->(project_id, credentials, scope: nil, key: nil, retries: nil, timeout: nil, host: nil) {
        project_id.must_equal "project-id"
        credentials.must_equal "translate-credentials"
        scope.must_be :nil?
        key.must_be :nil?
        retries.must_be :nil?
        timeout.must_be :nil?
        host.must_equal "custom-translate-endpoint.example.com"
        OpenStruct.new project_id: project_id
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        # Set new configurations
        Google::Cloud::Translate.configure do |config|
          config.project_id = "project-id"
          config.credentials = "path/to/keyfile.json"
          config.endpoint = "custom-translate-endpoint.example.com"
        end

        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Translate::V2::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Translate::V2::Service.stub :new, stubbed_service do
                translate = Google::Cloud::Translate.new version: :v2
                translate.must_be_kind_of Google::Cloud::Translate::V2::Api
                translate.project_id.must_equal "project-id"
                translate.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end
  end

  describe "Translate::V2.new" do
    let(:default_credentials) do
      creds = OpenStruct.new empty: true
      def creds.is_a? target
        target == Google::Auth::Credentials
      end
      creds
    end
    let(:found_credentials) { "{}" }

    it "gets defaults for api key" do
      stubbed_env = ->(name) {
        "found-api-key" if name == "GOOGLE_CLOUD_KEY"
      }
      stubbed_service = ->(project_id, credentials, retries: nil, timeout: nil, host: nil, key: nil) {
        key.must_equal "found-api-key"
        project_id.must_be :empty?
        credentials.must_be :nil?
        retries.must_be :nil?
        timeout.must_be :nil?
        OpenStruct.new key: key
      }

      # Prevent return of actual project in any environment including GCE, etc.
      Google::Cloud::Translate::V2.stub :default_project_id, nil do
        # Clear all environment variables
        ENV.stub :[], stubbed_env do
          Google::Cloud::Translate::V2::Service.stub :new, stubbed_service do
            translate = Google::Cloud::Translate::V2.new
            translate.must_be_kind_of Google::Cloud::Translate::V2::Api
            translate.service.must_be_kind_of OpenStruct
            translate.service.key.must_equal "found-api-key"
          end
        end
      end
    end

    it "uses provided api key" do
      stubbed_service = ->(project_id, credentials, retries: nil, timeout: nil, host: nil, key: nil) {
        key.must_equal "my-api-key"
        project_id.must_be :empty?
        credentials.must_be :nil?
        retries.must_be :nil?
        timeout.must_be :nil?
        OpenStruct.new key: key
      }

      # Prevent return of actual project in any environment including GCE, etc.
      Google::Cloud::Translate::V2.stub :default_project_id, nil do
        # Clear all environment variables
        ENV.stub :[], nil do
          Google::Cloud::Translate::V2::Service.stub :new, stubbed_service do
            translate = Google::Cloud::Translate::V2.new key: "my-api-key"
            translate.must_be_kind_of Google::Cloud::Translate::V2::Api
            translate.service.must_be_kind_of OpenStruct
            translate.service.key.must_equal "my-api-key"
          end
        end
      end
    end

    it "gets defaults for project_id and credentials" do
      # Clear all environment variables
      ENV.stub :[], nil do
        # Get project_id from Google Compute Engine
        Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
          Google::Cloud::Translate::V2::Credentials.stub :default, default_credentials do
            translate = Google::Cloud::Translate::V2.new
            translate.must_be_kind_of Google::Cloud::Translate::V2::Api
            translate.project_id.must_equal "project-id"
            translate.service.credentials.must_equal default_credentials
          end
        end
      end
    end

    it "uses provided project_id and credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "translate-credentials"
      }
      stubbed_service = ->(project_id, credentials, scope: nil, key: nil, retries: nil, timeout: nil, host: nil) {
        project_id.must_equal "project-id"
        credentials.must_equal "translate-credentials"
        scope.must_be :nil?
        key.must_be :nil?
        retries.must_be :nil?
        timeout.must_be :nil?
        host.must_be :nil?
        OpenStruct.new project_id: project_id
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Translate::V2::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Translate::V2::Service.stub :new, stubbed_service do
                translate = Google::Cloud::Translate::V2.new project_id: "project-id", credentials: "path/to/keyfile.json"
                translate.must_be_kind_of Google::Cloud::Translate::V2::Api
                translate.project_id.must_equal "project-id"
                translate.service.must_be_kind_of OpenStruct
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
      stubbed_service = ->(project_id, credentials, scope: nil, key: nil, retries: nil, timeout: nil, host: nil) {
        project_id.must_equal "project-id"
        credentials.must_be_kind_of OpenStruct
        credentials.project_id.must_equal "project-id"
        scope.must_be :nil?
        key.must_be :nil?
        retries.must_be :nil?
        timeout.must_be :nil?
        host.must_be :nil?
        OpenStruct.new project_id: project_id
      }
      empty_env = OpenStruct.new

      # Clear all environment variables
      ENV.stub :[], nil do
        Google::Cloud.stub :env, empty_env do
          File.stub :file?, true, ["path/to/keyfile.json"] do
            File.stub :read, found_credentials, ["path/to/keyfile.json"] do
              Google::Cloud::Translate::V2::Credentials.stub :new, stubbed_credentials do
                Google::Cloud::Translate::V2::Service.stub :new, stubbed_service do
                  translate = Google::Cloud::Translate::V2.new credentials: "path/to/keyfile.json"
                  translate.must_be_kind_of Google::Cloud::Translate::V2::Api
                  translate.project_id.must_equal "project-id"
                  translate.service.must_be_kind_of OpenStruct
                end
              end
            end
          end
        end
      end
    end

    it "uses provided endpoint" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "translate-credentials"
      }
      stubbed_service = ->(project_id, credentials, scope: nil, key: nil, retries: nil, timeout: nil, host: nil) {
        project_id.must_equal "project-id"
        credentials.must_equal "translate-credentials"
        host.must_equal "custom-translate-endpoint.example.com"
        scope.must_be :nil?
        key.must_be :nil?
        retries.must_be :nil?
        timeout.must_be :nil?
        OpenStruct.new project_id: project_id
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Translate::V2::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Translate::V2::Service.stub :new, stubbed_service do
                translate = Google::Cloud::Translate::V2.new project_id: "project-id", credentials: "path/to/keyfile.json", endpoint: "custom-translate-endpoint.example.com"
                translate.must_be_kind_of Google::Cloud::Translate::V2::Api
                translate.project_id.must_equal "project-id"
                translate.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end
  end
end
