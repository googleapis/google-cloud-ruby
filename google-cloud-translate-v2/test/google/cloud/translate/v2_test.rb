# Copyright 2020 Google LLC
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
require "google/cloud/translate/v2"

describe Google::Cloud::Translate::V2 do
  describe ".new" do
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
        _(key).must_equal "found-api-key"
        _(project_id).must_be :empty?
        _(credentials).must_be :nil?
        _(retries).must_be :nil?
        _(timeout).must_be :nil?
        OpenStruct.new key: key
      }

      # Prevent return of actual project in any environment including GCE, etc.
      Google::Cloud::Translate::V2.stub :default_project_id, nil do
        # Clear all environment variables
        ENV.stub :[], stubbed_env do
          Google::Cloud::Translate::V2::Service.stub :new, stubbed_service do
            translate = Google::Cloud::Translate::V2.new
            _(translate).must_be_kind_of Google::Cloud::Translate::V2::Api
            _(translate.service).must_be_kind_of OpenStruct
            _(translate.service.key).must_equal "found-api-key"
          end
        end
      end
    end

    it "uses provided api key" do
      stubbed_service = ->(project_id, credentials, retries: nil, timeout: nil, host: nil, key: nil) {
        _(key).must_equal "my-api-key"
        _(project_id).must_be :empty?
        _(credentials).must_be :nil?
        _(retries).must_be :nil?
        _(timeout).must_be :nil?
        OpenStruct.new key: key
      }

      # Prevent return of actual project in any environment including GCE, etc.
      Google::Cloud::Translate::V2.stub :default_project_id, nil do
        # Clear all environment variables
        ENV.stub :[], nil do
          Google::Cloud::Translate::V2::Service.stub :new, stubbed_service do
            translate = Google::Cloud::Translate::V2.new key: "my-api-key"
            _(translate).must_be_kind_of Google::Cloud::Translate::V2::Api
            _(translate.service).must_be_kind_of OpenStruct
            _(translate.service.key).must_equal "my-api-key"
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
            _(translate).must_be_kind_of Google::Cloud::Translate::V2::Api
            _(translate.project_id).must_equal "project-id"
            _(translate.service.credentials).must_equal default_credentials
          end
        end
      end
    end

    it "uses provided project_id and credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_be :nil?
        "translate-credentials"
      }
      stubbed_service = ->(project_id, credentials, scope: nil, key: nil, retries: nil, timeout: nil, host: nil) {
        _(project_id).must_equal "project-id"
        _(credentials).must_equal "translate-credentials"
        _(scope).must_be :nil?
        _(key).must_be :nil?
        _(retries).must_be :nil?
        _(timeout).must_be :nil?
        _(host).must_be :nil?
        OpenStruct.new project_id: project_id
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Translate::V2::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Translate::V2::Service.stub :new, stubbed_service do
                translate = Google::Cloud::Translate::V2.new project_id: "project-id", credentials: "path/to/keyfile.json"
                _(translate).must_be_kind_of Google::Cloud::Translate::V2::Api
                _(translate.project_id).must_equal "project-id"
                _(translate.service).must_be_kind_of OpenStruct
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
      stubbed_service = ->(project_id, credentials, scope: nil, key: nil, retries: nil, timeout: nil, host: nil) {
        _(project_id).must_equal "project-id"
        _(credentials).must_be_kind_of OpenStruct
        _(credentials.project_id).must_equal "project-id"
        _(scope).must_be :nil?
        _(key).must_be :nil?
        _(retries).must_be :nil?
        _(timeout).must_be :nil?
        _(host).must_be :nil?
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
                  _(translate).must_be_kind_of Google::Cloud::Translate::V2::Api
                  _(translate.project_id).must_equal "project-id"
                  _(translate.service).must_be_kind_of OpenStruct
                end
              end
            end
          end
        end
      end
    end

    it "uses provided endpoint" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        _(keyfile).must_equal "path/to/keyfile.json"
        _(scope).must_be :nil?
        "translate-credentials"
      }
      stubbed_service = ->(project_id, credentials, scope: nil, key: nil, retries: nil, timeout: nil, host: nil) {
        _(project_id).must_equal "project-id"
        _(credentials).must_equal "translate-credentials"
        _(host).must_equal "custom-translate-endpoint.example.com"
        _(scope).must_be :nil?
        _(key).must_be :nil?
        _(retries).must_be :nil?
        _(timeout).must_be :nil?
        OpenStruct.new project_id: project_id
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Translate::V2::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Translate::V2::Service.stub :new, stubbed_service do
                translate = Google::Cloud::Translate::V2.new project_id: "project-id", credentials: "path/to/keyfile.json", endpoint: "custom-translate-endpoint.example.com"
                _(translate).must_be_kind_of Google::Cloud::Translate::V2::Api
                _(translate.project_id).must_equal "project-id"
                _(translate.service).must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end
  end
end
