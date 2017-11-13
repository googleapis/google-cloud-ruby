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
require "google/cloud/resource_manager"

describe Google::Cloud do
  describe "#resource_manager" do
    it "calls out to Google::Cloud.resource_manager" do
      gcloud = Google::Cloud.new
      stubbed_resource_manager = ->(keyfile, scope: nil, retries: nil, timeout: nil) {
        keyfile.must_be :nil?
        scope.must_be :nil?
        retries.must_be :nil?
        timeout.must_be :nil?
        "resource_manager-manager-object-empty"
      }
      Google::Cloud.stub :resource_manager, stubbed_resource_manager do
        manager = gcloud.resource_manager
        manager.must_equal "resource_manager-manager-object-empty"
      end
    end

    it "passes project and keyfile to Google::Cloud.resource_manager" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_resource_manager = ->(keyfile, scope: nil, retries: nil, timeout: nil) {
        keyfile.must_equal "keyfile-path"
        scope.must_be :nil?
        retries.must_be :nil?
        timeout.must_be :nil?
        "resource_manager-manager-object"
      }
      Google::Cloud.stub :resource_manager, stubbed_resource_manager do
        manager = gcloud.resource_manager
        manager.must_equal "resource_manager-manager-object"
      end
    end

    it "passes project and keyfile and options to Google::Cloud.resource_manager" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_resource_manager = ->(keyfile, scope: nil, retries: nil, timeout: nil) {
        keyfile.must_equal "keyfile-path"
        scope.must_equal "http://example.com/scope"
        retries.must_equal 5
        timeout.must_equal 60
        "resource_manager-manager-object-scoped"
      }
      Google::Cloud.stub :resource_manager, stubbed_resource_manager do
        manager = gcloud.resource_manager scope: "http://example.com/scope", retries: 5, timeout: 60
        manager.must_equal "resource_manager-manager-object-scoped"
      end
    end
  end

  describe ".resource_manager" do
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
        Google::Cloud::ResourceManager::Credentials.stub :default, default_credentials do
          resource_manager = Google::Cloud.resource_manager
          resource_manager.must_be_kind_of Google::Cloud::ResourceManager::Manager
          resource_manager.service.credentials.must_equal default_credentials
        end
      end
    end

    it "uses provided project_id and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "resource_manager-credentials"
      }
      stubbed_service = ->(credentials, retries: nil, timeout: nil) {
        credentials.must_equal "resource_manager-credentials"
        retries.must_be :nil?
        timeout.must_be :nil?
        OpenStruct.new
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::ResourceManager::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::ResourceManager::Service.stub :new, stubbed_service do
                resource_manager = Google::Cloud.resource_manager "path/to/keyfile.json"
                resource_manager.must_be_kind_of Google::Cloud::ResourceManager::Manager
                resource_manager.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end
  end

  describe "ResourceManager.new" do
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
        Google::Cloud::ResourceManager::Credentials.stub :default, default_credentials do
          resource_manager = Google::Cloud::ResourceManager.new
          resource_manager.must_be_kind_of Google::Cloud::ResourceManager::Manager
          resource_manager.service.credentials.must_equal default_credentials
        end
      end
    end

    it "uses provided credentials" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "resource_manager-credentials"
      }
      stubbed_service = ->(credentials, retries: nil, timeout: nil) {
        credentials.must_equal "resource_manager-credentials"
        retries.must_be :nil?
        timeout.must_be :nil?
        OpenStruct.new
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::ResourceManager::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::ResourceManager::Service.stub :new, stubbed_service do
                resource_manager = Google::Cloud::ResourceManager.new credentials: "path/to/keyfile.json"
                resource_manager.must_be_kind_of Google::Cloud::ResourceManager::Manager
                resource_manager.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end

    it "uses provided keyfile alias" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_be :nil?
        "resource_manager-credentials"
      }
      stubbed_service = ->(credentials, retries: nil, timeout: nil) {
        credentials.must_equal "resource_manager-credentials"
        retries.must_be :nil?
        timeout.must_be :nil?
        OpenStruct.new
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::ResourceManager::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::ResourceManager::Service.stub :new, stubbed_service do
                resource_manager = Google::Cloud::ResourceManager.new keyfile: "path/to/keyfile.json"
                resource_manager.must_be_kind_of Google::Cloud::ResourceManager::Manager
                resource_manager.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end
  end
end
