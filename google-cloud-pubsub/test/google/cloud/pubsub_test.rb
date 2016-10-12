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
require "google/cloud/pubsub"

describe Google::Cloud do
  describe "#pubsub" do
    it "calls out to Google::Cloud.pubsub" do
      gcloud = Google::Cloud.new
      stubbed_pubsub = ->(project, keyfile, scope: nil, timeout: nil, client_config: nil) {
        project.must_equal nil
        keyfile.must_equal nil
        scope.must_be :nil?
        timeout.must_be :nil?
        client_config.must_be :nil?
        "pubsub-project-object-empty"
      }
      Google::Cloud.stub :pubsub, stubbed_pubsub do
        project = gcloud.pubsub
        project.must_equal "pubsub-project-object-empty"
      end
    end

    it "passes project and keyfile to Google::Cloud.pubsub" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_pubsub = ->(project, keyfile, scope: nil, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        keyfile.must_equal "keyfile-path"
        scope.must_be :nil?
        timeout.must_be :nil?
        client_config.must_be :nil?
        "pubsub-project-object"
      }
      Google::Cloud.stub :pubsub, stubbed_pubsub do
        project = gcloud.pubsub
        project.must_equal "pubsub-project-object"
      end
    end

    it "passes project and keyfile and options to Google::Cloud.pubsub" do
      gcloud = Google::Cloud.new "project-id", "keyfile-path"
      stubbed_pubsub = ->(project, keyfile, scope: nil, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        keyfile.must_equal "keyfile-path"
        scope.must_equal "http://example.com/scope"
        timeout.must_equal 60
        client_config.must_equal 5
        "pubsub-project-object-scoped"
      }
      Google::Cloud.stub :pubsub, stubbed_pubsub do
        project = gcloud.pubsub scope: "http://example.com/scope", timeout: 60, client_config: 5
        project.must_equal "pubsub-project-object-scoped"
      end
    end
  end

  describe ".pubsub" do
    let(:default_credentials) { OpenStruct.new empty: true }
    let(:found_credentials) { "{}" }

    it "gets defaults for project_id and keyfile" do
      # Clear all environment variables
      ENV.stub :[], nil do
        # Get project_id from Google Compute Engine
        Google::Cloud::Core::Environment.stub :project_id, "project-id" do
          Google::Cloud::Pubsub::Credentials.stub :default, default_credentials do
            pubsub = Google::Cloud.pubsub
            pubsub.must_be_kind_of Google::Cloud::Pubsub::Project
            pubsub.project.must_equal "project-id"
            pubsub.service.credentials.must_equal default_credentials
          end
        end
      end
    end

    it "uses provided project_id and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_equal nil
        "pubsub-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        credentials.must_equal "pubsub-credentials"
        client_config.must_equal nil
        timeout.must_equal nil
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Pubsub::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Pubsub::Service.stub :new, stubbed_service do
                pubsub = Google::Cloud.pubsub "project-id", "path/to/keyfile.json"
                pubsub.must_be_kind_of Google::Cloud::Pubsub::Project
                pubsub.project.must_equal "project-id"
                pubsub.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end
  end

  describe "Pubsub.new" do
    let(:default_credentials) { OpenStruct.new empty: true }
    let(:found_credentials) { "{}" }

    it "gets defaults for project_id and keyfile" do
      # Clear all environment variables
      ENV.stub :[], nil do
        # Get project_id from Google Compute Engine
        Google::Cloud::Core::Environment.stub :project_id, "project-id" do
          Google::Cloud::Pubsub::Credentials.stub :default, default_credentials do
            pubsub = Google::Cloud::Pubsub.new
            pubsub.must_be_kind_of Google::Cloud::Pubsub::Project
            pubsub.project.must_equal "project-id"
            pubsub.service.credentials.must_equal default_credentials
          end
        end
      end
    end

    it "uses provided project_id and keyfile" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "path/to/keyfile.json"
        scope.must_equal nil
        "pubsub-credentials"
      }
      stubbed_service = ->(project, credentials, timeout: nil, client_config: nil) {
        project.must_equal "project-id"
        credentials.must_equal "pubsub-credentials"
        timeout.must_equal nil
        client_config.must_equal nil
        OpenStruct.new project: project
      }

      # Clear all environment variables
      ENV.stub :[], nil do
        File.stub :file?, true, ["path/to/keyfile.json"] do
          File.stub :read, found_credentials, ["path/to/keyfile.json"] do
            Google::Cloud::Pubsub::Credentials.stub :new, stubbed_credentials do
              Google::Cloud::Pubsub::Service.stub :new, stubbed_service do
                pubsub = Google::Cloud::Pubsub.new project: "project-id", keyfile: "path/to/keyfile.json"
                pubsub.must_be_kind_of Google::Cloud::Pubsub::Project
                pubsub.project.must_equal "project-id"
                pubsub.service.must_be_kind_of OpenStruct
              end
            end
          end
        end
      end
    end
  end
end
