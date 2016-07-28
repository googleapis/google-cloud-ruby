# Copyright 2015 Google Inc. All rights reserved.
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
require "google/cloud/logging"

describe Google::Cloud do
  it "calls out to Google::Cloud.logging" do
    gcloud = Google::Cloud.new
    stubbed_logging = ->(project, keyfile, scope: nil, retries: nil, timeout: nil) {
      project.must_equal nil
      keyfile.must_equal nil
      scope.must_be :nil?
      retries.must_be :nil?
      timeout.must_be :nil?
      "logging-project-object-empty"
    }
    Google::Cloud.stub :logging, stubbed_logging do
      project = gcloud.logging
      project.must_equal "logging-project-object-empty"
    end
  end

  it "passes project and keyfile to Google::Cloud.logging" do
    gcloud = Google::Cloud.new "project-id", "keyfile-path"
    stubbed_logging = ->(project, keyfile, scope: nil, retries: nil, timeout: nil) {
      project.must_equal "project-id"
      keyfile.must_equal "keyfile-path"
      scope.must_be :nil?
      retries.must_be :nil?
      timeout.must_be :nil?
      "logging-project-object"
    }
    Google::Cloud.stub :logging, stubbed_logging do
      project = gcloud.logging
      project.must_equal "logging-project-object"
    end
  end

  it "passes project and keyfile and options to Google::Cloud.logging" do
    gcloud = Google::Cloud.new "project-id", "keyfile-path"
    stubbed_logging = ->(project, keyfile, scope: nil, retries: nil, timeout: nil) {
      project.must_equal "project-id"
      keyfile.must_equal "keyfile-path"
      scope.must_equal "http://example.com/scope"
      retries.must_equal 5
      timeout.must_equal 60
      "logging-project-object-scoped"
    }
    Google::Cloud.stub :logging, stubbed_logging do
      project = gcloud.logging scope: "http://example.com/scope", retries: 5, timeout: 60
      project.must_equal "logging-project-object-scoped"
    end
  end
end
