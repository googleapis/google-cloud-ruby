# Copyright 2017 Google Inc. All rights reserved.
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
          Google::Cloud::ErrorReporting::Credentials.stub :credentials_with_scope, default_credentials do
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
        scope.must_be_nil
        "error_reporting-credentials"
      }

      ENV.stub :[], nil do
        File.stub :file?, true, ["/path/to/a/keyfile"] do
          File.stub :read, found_credentials, ["/path/to/a/keyfile"] do
            Google::Cloud::ErrorReporting::Credentials.stub :credentials_with_scope, stubbed_credentials do
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
      Google::Cloud::ErrorReporting::Credentials.stub :credentials_with_scope, default_credentials do
        exception = assert_raises ArgumentError do
          Google::Cloud::ErrorReporting.new project: ""
        end

        exception.message.must_equal "project is missing"
      end
    end
  end

  describe ".configure" do
    it "initializes Google::Cloud.configure.error_reporting once" do
      error_reporting_config = Google::Cloud.configure.error_reporting
      Google::Cloud::ErrorReporting.configure
      Google::Cloud.configure.error_reporting.must_equal error_reporting_config
    end

    it "operates on the same Configuration object as Google::Cloud.configure.error_reporting" do
      Google::Cloud::ErrorReporting.configure.must_equal Google::Cloud.configure.error_reporting
    end

    it "initialies ErrorReporting Configuration with all the valid operations" do
      Google::Cloud::ErrorReporting.configure.instance_variable_get(:@configs).keys.must_equal Google::Cloud::ErrorReporting::CONFIG_OPTIONS
      Google::Cloud.configure.error_reporting.instance_variable_get(:@configs).keys.must_equal Google::Cloud::ErrorReporting::CONFIG_OPTIONS
    end
  end

  describe ".report" do
    let(:exception) { RuntimeError.new "test-exception" }

    before {
      Google::Cloud::ErrorReporting.class_variable_set :@@default_client, nil
      Google::Cloud::ErrorReporting.class_variable_get(:@@default_client).must_be_nil
    }

    it "doesn't call Project#report_exception if Google::Cloud.configure.use_error_reporting is false" do
      # Google::Cloud.configure.use_error_reporting = false
      error_reporting = Google::Cloud::ErrorReporting.new project: "test-project-id"
      Google::Cloud::ErrorReporting.class_variable_set :@@default_client, error_reporting
      stubbed_report_exception = ->(_, _) { fail "Shouldn't be called" }

      error_reporting.stub :report_exception, stubbed_report_exception do
        Google::Cloud.configure.stub :method_missing, false do
          Google::Cloud::ErrorReporting.report exception
        end
      end
    end

    it "creates a default client when called first time" do
      mocked_default_client = Minitest::Mock.new
      mocked_default_client.expect :report_exception, nil, [Exception, Hash]

      Google::Cloud::ErrorReporting.stub :new, mocked_default_client do
        Google::Cloud::ErrorReporting.report exception
      end

      mocked_default_client.verify
    end

    it "calls Project#report_exception with the given service_name and service_version" do
      mocked_default_client = Minitest::Mock.new
      mocked_default_client.expect :report_exception, nil, [Exception, {
        service_name: "test-service-name",
        service_version: "test-service-version"
      }]

      Google::Cloud::ErrorReporting.stub :new, mocked_default_client do
        Google::Cloud::ErrorReporting.report exception, service_name: "test-service-name",
                                                        service_version: "test-service-version"
      end

      mocked_default_client.verify
    end

    it "uses the config options from Google::Cloud::ErrorReporting.configure" do
      stubbed_config = OpenStruct.new project_id: "test-project-id", keyfile: "test-keyfile",
                                      service_name: "test-service-name", service_version: "test-service-version"
      mocked_default_client = Minitest::Mock.new
      mocked_default_client.expect :report_exception, nil, [Exception, {
        service_name: "test-service-name",
        service_version: "test-service-version"
      }]

      stubbed_new = ->(args) {
        args[:project].must_equal "test-project-id"
        args[:keyfile].must_equal "test-keyfile"
        mocked_default_client
      }

      Google::Cloud::ErrorReporting.stub :configure, stubbed_config do
        Google::Cloud::ErrorReporting.stub :new, stubbed_new do
          Google::Cloud::ErrorReporting.report exception
        end
      end

      mocked_default_client.verify
    end

    it "uses the project_id and keyfile from Google::Cloud.configure if missing from Google::Cloud::ErrorReporting.configure" do
      stubbed_er_config = OpenStruct.new project_id: nil, keyfile: nil,
                                         service_name: "test-service-name", service_version: "test-service-version"
      stubbed_gcloud_config = OpenStruct.new project_id: "test-project-id", keyfile: "test-keyfile"
      mocked_default_client = Minitest::Mock.new
      mocked_default_client.expect :report_exception, nil, [Exception, Hash]

      stubbed_new = ->(args) {
        args[:project].must_equal "test-project-id"
        args[:keyfile].must_equal "test-keyfile"
        mocked_default_client
      }

      Google::Cloud::ErrorReporting.stub :configure, stubbed_er_config do
        Google::Cloud.stub :configure, stubbed_gcloud_config do
          Google::Cloud::ErrorReporting.stub :new, stubbed_new do
            Google::Cloud::ErrorReporting.report exception
          end
        end
      end

      mocked_default_client.verify
    end
  end
end
