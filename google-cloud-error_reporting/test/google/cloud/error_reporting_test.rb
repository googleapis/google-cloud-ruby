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

describe Google::Cloud::ErrorReporting do
  describe ".new" do
    let(:default_credentials) { OpenStruct.new empty: true}
    let(:found_credentials) { "{}" }

    it "gets defaults for project-id, keyfile, service, and version" do
      ENV.stub :[], nil do
        Google::Cloud::ErrorReporting::Project.stub :default_project, "test-project-id" do
          Google::Cloud::ErrorReporting.stub :credentials_with_scope, default_credentials do
            error_reporting = Google::Cloud::ErrorReporting.new
            error_reporting.must_be_kind_of Google::Cloud::ErrorReporting::Project
            error_reporting.project.must_equal "test-project-id"
            error_reporting.service.credentials.must_equal default_credentials
          end
        end
      end
    end

    it "uses provided project-id, keyfile, service, and version" do
      stubbed_credentials = ->(keyfile, scope) {
        keyfile.must_equal "/path/to/a/keyfile"
        scope.must_equal nil
        "error_reporting-credentials"
      }

      ENV.stub :[], nil do
        File.stub :file?, true, ["/path/to/a/keyfile"] do
          File.stub :read, found_credentials, ["/path/to/a/keyfile"] do
            Google::Cloud::ErrorReporting.stub :credentials_with_scope, stubbed_credentials do
              error_reporting = Google::Cloud::ErrorReporting.new project: "test-project-id",
                                                                  keyfile: "/path/to/a/keyfile"
              error_reporting.must_be_kind_of Google::Cloud::ErrorReporting::Project
              error_reporting.project.must_equal "test-project-id"
              error_reporting.service.must_be_kind_of Google::Cloud::ErrorReporting::Service
            end
          end
        end
      end
    end

    it "errors when provided empty project_id" do
      Google::Cloud::ErrorReporting.stub :credentials_with_scope, default_credentials do
        exception = assert_raises ArgumentError do
          Google::Cloud::ErrorReporting.new project: ""
        end

        exception.message.must_equal "project is missing"
      end
    end
  end

  describe ".credentials_with_scope" do
    let(:default_credentials) { "default_credential" }
    let(:default_scope) { "gcp_scope" }

    it "calls for default credentials if no keyfile" do
      Google::Cloud::ErrorReporting::Credentials.stub :default, default_credentials do
        Google::Cloud::ErrorReporting.credentials_with_scope(nil).must_equal default_credentials
      end
    end

    it "passes scope to get default credentials" do
      stubbed_default = ->(scope: nil) {
        scope.must_equal default_scope
        default_credentials
      }
      Google::Cloud::ErrorReporting::Credentials.stub :default, stubbed_default do
        credentials = Google::Cloud::ErrorReporting.credentials_with_scope(
          nil, default_scope
        )
        credentials.must_equal default_credentials
      end
    end

    it "creates credential with keyfile and scope" do
      stubbed_new_credential = ->(keyfile, scope: nil) {
        keyfile.must_equal "/path/to/a/keyfile"
        scope.must_equal default_scope
        "new credentials"
      }
      Google::Cloud::ErrorReporting::Credentials.stub :new, stubbed_new_credential do
        credentials = Google::Cloud::ErrorReporting.credentials_with_scope "/path/to/a/keyfile",
                                                                           default_scope
        credentials.must_equal "new credentials"
      end
    end
  end
end
