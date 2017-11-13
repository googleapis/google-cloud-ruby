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

describe Google::Cloud do
  describe '#error_reporting' do
    it "calls out to Google::Cloud.error_reporting" do
      gcloud = Google::Cloud.new
      stubbed_error_reporting =
        ->(project, keyfile, scope: nil, timeout: nil, client_config: nil) {
          project.must_be_nil
          keyfile.must_be_nil
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

  describe '.error_reporting' do
    it "calls out to Google::Cloud::ErrorReporting.new" do
      gcloud = Google::Cloud.new
      stubbed_new =
        ->(project_id: nil, credentials: nil, scope: nil, timeout: nil, client_config: nil) {
          project_id.must_be_nil
          credentials.must_be_nil
          scope.must_be :nil?
          timeout.must_be :nil?
          client_config.must_be :nil?
          "fake-error_reporting-project-object"
        }
      Google::Cloud::ErrorReporting.stub :new, stubbed_new do
        project = gcloud.error_reporting
        project.must_equal "fake-error_reporting-project-object"
      end
    end

    it "passes project and keyfile to Google::Cloud::ErrorReporting.new" do
      gcloud = Google::Cloud.new "test-project-id", "/path/to/a/keyfile"
      stubbed_new =
        ->(project_id: nil, credentials: nil, scope: nil, timeout: nil, client_config: nil) {
          project_id.must_equal "test-project-id"
          credentials.must_equal "/path/to/a/keyfile"
          scope.must_be :nil?
          timeout.must_be :nil?
          client_config.must_be :nil?
          "error_reporting-project-object"
        }
      Google::Cloud::ErrorReporting.stub :new, stubbed_new do
        project = gcloud.error_reporting
        project.must_equal "error_reporting-project-object"
      end
    end

    it "passes project and keyfile and options to Google::Cloud::ErrorReporting.new" do
      gcloud = Google::Cloud.new "test-project-id", "/path/to/a/keyfile"
      stubbed_new =
        ->(project_id: nil, credentials: nil, scope: nil, timeout: nil, client_config: nil) {
          project_id.must_equal "test-project-id"
          credentials.must_equal "/path/to/a/keyfile"
          scope.must_equal "http://example.com/scope"
          timeout.must_equal 60
          client_config.must_equal({ "gax" => "options" })
          "error_reporting-project-object"
        }
      Google::Cloud::ErrorReporting.stub :new, stubbed_new do
        project = gcloud.error_reporting scope: "http://example.com/scope",
                                         timeout: 60,
                                         client_config: { "gax" => "options" }
        project.must_equal "error_reporting-project-object"
      end
    end
  end
end
