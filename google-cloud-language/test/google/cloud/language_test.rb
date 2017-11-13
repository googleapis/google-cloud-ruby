# Copyright 2016 Google Inc. All rights reserved.
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

describe Google::Cloud do
  describe "#language" do
    it "calls out to Google::Cloud.language" do
      gcloud = Google::Cloud.new
      stubbed_language = ->(project, keyfile, scope: nil, timeout: nil, client_config: nil) {
        project.must_be :nil?
        keyfile.must_be :nil?
        scope.must_be :nil?
        timeout.must_be :nil?
        client_config.must_be :nil?
        "language-project-object-empty"
      }
      Google::Cloud.stub :language, stubbed_language do
        project = gcloud.language
        project.must_equal "language-project-object-empty"
      end
    end

    it "passes project and keyfile to Google::Cloud.language" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_language = ->(project, keyfile, scope: nil, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        keyfile.must_equal "keyfile-path"
        scope.must_be :nil?
        timeout.must_be :nil?
        client_config.must_be :nil?
        "language-project-object"
      }
      Google::Cloud.stub :language, stubbed_language do
        project = gcloud.language
        project.must_equal "language-project-object"
      end
    end

    it "passes project and keyfile and options to Google::Cloud.language" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_language = ->(project, keyfile, scope: nil, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        keyfile.must_equal "keyfile-path"
        scope.must_equal "http://example.com/scope"
        timeout.must_equal 60
        client_config.must_equal({ "gax" => "options" })
        "language-project-object-scoped"
      }
      Google::Cloud.stub :language, stubbed_language do
        project = gcloud.language scope: "http://example.com/scope", timeout: 60, client_config: { "gax" => "options" }
        project.must_equal "language-project-object-scoped"
      end
    end
  end

  describe ".language" do
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
          Google::Cloud::Language::Credentials.stub :default, default_credentials do
            language = Google::Cloud.language
            language.must_be_kind_of Google::Cloud::Language::Project
            language.project.must_equal "project-id"
            language.service.credentials.must_equal default_credentials
          end
        end
      end
    end

    it "uses provided project_id and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "language-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        credentials.must_equal "language-credentials"
        timeout.must_be :nil?
        client_config.must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Language::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Language::Service.stub :new, stubbed_service do
                language = Google::Cloud.language "project-id", "path/to/keyfile.json"
                language.must_be_kind_of Google::Cloud::Language::Project
                language.project.must_equal "project-id"
                language.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end
  end

  describe "Language.new" do
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
          Google::Cloud::Language::Credentials.stub :default, default_credentials do
            language = Google::Cloud::Language.new
            language.must_be_kind_of Google::Cloud::Language::Project
            language.project.must_equal "project-id"
            language.service.credentials.must_equal default_credentials
          end
        end
      end
    end

    it "uses provided project_id and credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "language-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        credentials.must_equal "language-credentials"
        timeout.must_be :nil?
        client_config.must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Language::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Language::Service.stub :new, stubbed_service do
                language = Google::Cloud::Language.new project_id: "project-id", credentials: "path/to/keyfile.json"
                language.must_be_kind_of Google::Cloud::Language::Project
                language.project.must_equal "project-id"
                language.service.must_be_kind_of OpenStruct
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
        "language-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        credentials.must_equal "language-credentials"
        timeout.must_be :nil?
        client_config.must_be :nil?
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Language::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Language::Service.stub :new, stubbed_service do
                language = Google::Cloud::Language.new project: "project-id", keyfile: "path/to/keyfile.json"
                language.must_be_kind_of Google::Cloud::Language::Project
                language.project.must_equal "project-id"
                language.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end
  end
end
