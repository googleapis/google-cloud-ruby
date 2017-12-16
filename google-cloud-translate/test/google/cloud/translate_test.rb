# Copyright 2016 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"
require "google/cloud/translate"

describe Google::Cloud do
  describe "#translate" do
    it "calls out to Google::Cloud.translate" do
      gcloud = Google::Cloud.new
      stubbed_translate = ->(key, project_id: nil, credentials: nil, scope: nil, retries: nil, timeout: nil, project: nil, keyfile: nil) {
        key.must_be :nil?
        project_id.must_be :nil?
        credentials.must_be :nil?
        scope.must_be :nil?
        retries.must_be :nil?
        timeout.must_be :nil?
        project.must_be :nil?
        keyfile.must_be :nil?
        "translate-project-object-empty"
      }
      Google::Cloud.stub :translate, stubbed_translate do
        project = gcloud.translate
        project.must_equal "translate-project-object-empty"
      end
    end

    it "passes key to Google::Cloud.translate" do
      gcloud = Google::Cloud.new
      stubbed_translate = ->(key, project_id: nil, credentials: nil, scope: nil, retries: nil, timeout: nil, project: nil, keyfile: nil) {
        key.must_equal "this-is-the-api-key"
        project_id.must_be :nil?
        credentials.must_be :nil?
        scope.must_be :nil?
        retries.must_be :nil?
        timeout.must_be :nil?
        project.must_be :nil?
        keyfile.must_be :nil?
        "translate-api-object-empty"
      }
      Google::Cloud.stub :translate, stubbed_translate do
        api = gcloud.translate "this-is-the-api-key"
        api.must_equal "translate-api-object-empty"
      end
    end

    it "passes key and options to Google::Cloud.translate" do
      gcloud = Google::Cloud.new
      stubbed_translate = ->(key, project_id: nil, credentials: nil, scope: nil, retries: nil, timeout: nil, project: nil, keyfile: nil) {
        key.must_equal "this-is-the-api-key"
        project_id.must_be :nil?
        credentials.must_be :nil?
        scope.must_be :nil?
        retries.must_equal 5
        timeout.must_equal 60
        project.must_be :nil?
        keyfile.must_be :nil?
        "translate-api-object-empty"
      }
      Google::Cloud.stub :translate, stubbed_translate do
        api = gcloud.translate "this-is-the-api-key", retries: 5, timeout: 60
        api.must_equal "translate-api-object-empty"
      end
    end

    it "passes project_id and credentials to Google::Cloud.translate" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_translate = ->(key, project_id: nil, credentials: nil, scope: nil, retries: nil, timeout: nil, project: nil, keyfile: nil) {
        project_id.must_equal "project-id"
        credentials.must_equal "keyfile-path"
        scope.must_be :nil?
        key.must_be :nil?
        retries.must_be :nil?
        timeout.must_be :nil?
        project.must_be :nil?
        keyfile.must_be :nil?
        "translate-api-object"
      }
      Google::Cloud.stub :translate, stubbed_translate do
        api = gcloud.translate
        api.must_equal "translate-api-object"
      end
    end

    it "passes project_id and credentials and options to Google::Cloud.translate" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_translate = ->(key, project_id: nil, credentials: nil, scope: nil, retries: nil, timeout: nil, project: nil, keyfile: nil) {
        project_id.must_equal "project-id"
        credentials.must_equal "keyfile-path"
        scope.must_be :nil?
        key.must_be :nil?
        retries.must_equal 5
        timeout.must_equal 60
        project.must_be :nil?
        keyfile.must_be :nil?
        "translate-api-object-scoped"
      }
      Google::Cloud.stub :translate, stubbed_translate do
        api = gcloud.translate retries: 5, timeout: 60
        api.must_equal "translate-api-object-scoped"
      end
    end
  end

  describe ".translate" do
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
      stubbed_service = ->(project, credentials, retries: nil, timeout: nil, key: nil) {
        key.must_equal "found-api-key"
        project.must_be :empty?
        credentials.must_be :nil?
        retries.must_be :nil?
        timeout.must_be :nil?
        OpenStruct.new key: key
      }

      # Prevent return of actual project in any environment including GCE, etc.
      Google::Cloud::Translate::Api.stub :default_project_id, nil do
        # Clear all environment variables
        # ENV.stub :[], nil do
        ENV.stub :[], stubbed_env do
          Google::Cloud::Translate::Service.stub :new, stubbed_service do
            translate = Google::Cloud.translate
            translate.must_be_kind_of Google::Cloud::Translate::Api
            translate.service.must_be_kind_of OpenStruct
            translate.service.key.must_equal "found-api-key"
          end
        end
      end
    end

    it "uses provided api key" do
      stubbed_service = ->(project, credentials, retries: nil, timeout: nil, key: nil) {
        key.must_equal "my-api-key"
        project.must_be :empty?
        credentials.must_be :nil?
        retries.must_be :nil?
        timeout.must_be :nil?
        OpenStruct.new key: key
      }
      # Prevent return of actual project in any environment including GCE, etc.
      Google::Cloud::Translate::Api.stub :default_project_id, nil do
        # Clear all environment variables
        ENV.stub :[], nil do
          Google::Cloud::Translate::Service.stub :new, stubbed_service do
            translate = Google::Cloud.translate "my-api-key"
            translate.must_be_kind_of Google::Cloud::Translate::Api
            translate.service.must_be_kind_of OpenStruct
            translate.service.key.must_equal "my-api-key"
          end
        end
      end
    end

    it "gets defaults for project_id and keyfile" do
      # Clear all environment variables
      ENV.stub :[], nil do
        # Get project_id from Google Compute Engine
        Google::Cloud.stub :env, OpenStruct.new(project_id: "project-id") do
          Google::Cloud::Translate::Credentials.stub :default, default_credentials do
            translate = Google::Cloud.translate
            translate.must_be_kind_of Google::Cloud::Translate::Api
            translate.project.must_equal "project-id"
            translate.service.credentials.must_equal default_credentials
          end
        end
      end
    end

    it "uses provided project_id and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "translate-credentials"
      }
      stubbed_service = ->(project, credentials, retries: nil, timeout: nil, key: nil) {
        project.must_equal "project-id"
        credentials.must_equal "translate-credentials"
        key.must_be :nil?
        retries.must_be :nil?
        timeout.must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Translate::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Translate::Service.stub :new, stubbed_service do
                translate = Google::Cloud.translate project: "project-id", keyfile: "path/to/keyfile.json"
                translate.must_be_kind_of Google::Cloud::Translate::Api
                translate.project.must_equal "project-id"
                translate.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end
  end

  describe "Translate.new" do
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
      stubbed_service = ->(project, credentials, retries: nil, timeout: nil, key: nil) {
        key.must_equal "found-api-key"
        project.must_be :empty?
        credentials.must_be :nil?
        retries.must_be :nil?
        timeout.must_be :nil?
        OpenStruct.new key: key
      }

      # Prevent return of actual project in any environment including GCE, etc.
      Google::Cloud::Translate::Api.stub :default_project_id, nil do
        # Clear all environment variables
        # ENV.stub :[], nil do
        ENV.stub :[], stubbed_env do
          Google::Cloud::Translate::Service.stub :new, stubbed_service do
            translate = Google::Cloud::Translate.new
            translate.must_be_kind_of Google::Cloud::Translate::Api
            translate.service.must_be_kind_of OpenStruct
            translate.service.key.must_equal "found-api-key"
          end
        end
      end
    end

    it "uses provided api key" do
      stubbed_service = ->(project, credentials, retries: nil, timeout: nil, key: nil) {
        key.must_equal "my-api-key"
        project.must_be :empty?
        credentials.must_be :nil?
        retries.must_be :nil?
        timeout.must_be :nil?
        OpenStruct.new key: key
      }

      # Prevent return of actual project in any environment including GCE, etc.
      Google::Cloud::Translate::Api.stub :default_project_id, nil do
        # Clear all environment variables
        ENV.stub :[], nil do
          Google::Cloud::Translate::Service.stub :new, stubbed_service do
            translate = Google::Cloud::Translate.new key: "my-api-key"
            translate.must_be_kind_of Google::Cloud::Translate::Api
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
          Google::Cloud::Translate::Credentials.stub :default, default_credentials do
            translate = Google::Cloud::Translate.new
            translate.must_be_kind_of Google::Cloud::Translate::Api
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
      stubbed_service = ->(project, credentials, scope: nil, key: nil, retries: nil, timeout: nil) {
        project.must_equal "project-id"
        credentials.must_equal "translate-credentials"
        scope.must_be :nil?
        key.must_be :nil?
        retries.must_be :nil?
        timeout.must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Translate::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Translate::Service.stub :new, stubbed_service do
                translate = Google::Cloud::Translate.new project_id: "project-id", credentials: "path/to/keyfile.json"
                translate.must_be_kind_of Google::Cloud::Translate::Api
                translate.project_id.must_equal "project-id"
                translate.service.must_be_kind_of OpenStruct
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
        "translate-credentials"
      }
      stubbed_service = ->(project, credentials, scope: nil, key: nil, retries: nil, timeout: nil) {
        project.must_equal "project-id"
        credentials.must_equal "translate-credentials"
        scope.must_be :nil?
        key.must_be :nil?
        retries.must_be :nil?
        timeout.must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Translate::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Translate::Service.stub :new, stubbed_service do
                translate = Google::Cloud::Translate.new project: "project-id", keyfile: "path/to/keyfile.json"
                translate.must_be_kind_of Google::Cloud::Translate::Api
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
