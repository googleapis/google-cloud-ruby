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
  describe '#error_reporting' do
    it "calls out to Google::Cloud.error_reporting" do
      gcloud = Google::Cloud.new
      stubbed_error_reporting =
        ->(project, keyfile, scope: nil, timeout: nil, client_config: nil) {
          project.must_equal nil
          keyfile.must_equal nil
          scope.must_be :nil?
          timeout.must_be :nil?
          client_config.must_be :nil?
          "fake-error_reporting-project-object"
        }
      Google::Cloud.stub :error_reporting, stubbed_error_reporting do
        project = gcloud.error_reporting
        project.must_equal "fake-error_reporting-project-object"
      end
    end

    it "passes project and keyfile to Google::Cloud.error_reporting" do
      gcloud = Google::Cloud.new "test-project-id", "/path/to/a/keyfile"
      stubbed_error_reporting =
        ->(project, keyfile, scope: nil, timeout: nil, client_config: nil) {
          project.must_equal "test-project-id"
          keyfile.must_equal "/path/to/a/keyfile"
          scope.must_be :nil?
          timeout.must_be :nil?
          client_config.must_be :nil?
          "error_reporting-project-object"
        }
      Google::Cloud.stub :error_reporting, stubbed_error_reporting do
        project = gcloud.error_reporting
        project.must_equal "error_reporting-project-object"
      end
    end

    it "passes project and keyfile and options to Google::Cloud.error_reporting" do
      gcloud = Google::Cloud.new "test-project-id", "/path/to/a/keyfile"
      stubbed_error_reporting =
        ->(project, keyfile, scope: nil, timeout: nil, client_config: nil) {
          project.must_equal "test-project-id"
          keyfile.must_equal "/path/to/a/keyfile"
          scope.must_equal "http://example.com/scope"
          timeout.must_equal 60
          client_config.must_equal({ "gax" => "options" })
          "error_reporting-project-object"
        }
      Google::Cloud.stub :error_reporting, stubbed_error_reporting do
        project = gcloud.error_reporting scope: "http://example.com/scope",
                                         timeout: 60,
                                         client_config: { "gax" => "options" }
        project.must_equal "error_reporting-project-object"
      end
    end
  end

  describe ".error_reporting" do
    let(:default_credentials) { OpenStruct.new empty: true}
    let(:found_credentials) { "{}" }

    it "gets defaults for project-id, keyfile, service, and version" do
      ENV.stub :[], nil do
        Google::Cloud::ErrorReporting::Project.stub :default_project, "test-project-id" do
          Google::Cloud::ErrorReporting::Credentials.stub :default, default_credentials do
            error_reporting = Google::Cloud.error_reporting
            error_reporting.must_be_kind_of Google::Cloud::ErrorReporting::Project
            error_reporting.project.must_equal "test-project-id"
            error_reporting.service.credentials.must_equal default_credentials
          end
        end
      end
    end

    it "uses provided project-id, keyfile, service, and version" do
      stubbed_credentials = ->(keyfile, scope: nil) {
        keyfile.must_equal "/path/to/a/keyfile"
        scope.must_equal nil
        "error_reporting-credentials"
      }

      ENV.stub :[], nil do
        File.stub :file?, true, ["/path/to/a/keyfile"] do
          File.stub :read, found_credentials, ["/path/to/a/keyfile"] do
            Google::Cloud::ErrorReporting::Credentials.stub :new, stubbed_credentials do
              error_reporting = Google::Cloud.error_reporting "test-project-id",
                                                            "/path/to/a/keyfile"
              error_reporting.must_be_kind_of Google::Cloud::ErrorReporting::Project
              error_reporting.project.must_equal "test-project-id"
              error_reporting.service.must_be_kind_of Google::Cloud::ErrorReporting::Service
            end
          end
        end
      end
    end

    it "errors when provided empty project_id" do
      Google::Cloud::ErrorReporting::Credentials.stub :default, default_credentials do
        exception = assert_raises ArgumentError do
          Google::Cloud.error_reporting ""
        end

        exception.message.must_equal "project is missing"
      end
    end
  end
end
