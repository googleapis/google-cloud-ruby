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
require "google/cloud/datastore"

describe Google::Cloud do
  it "calls out to Google::Cloud.datastore" do
    gcloud = Google::Cloud.new
    stubbed_datastore = ->(project, keyfile, scope: nil, retries: nil, timeout: nil) {
      project.must_equal nil
      keyfile.must_equal nil
      scope.must_be :nil?
      retries.must_be :nil?
      timeout.must_be :nil?
      "datastore-dataset-object-empty"
    }
    Google::Cloud.stub :datastore, stubbed_datastore do
      dataset = gcloud.datastore
      dataset.must_equal "datastore-dataset-object-empty"
    end
  end

  it "passes project and keyfile to Google::Cloud.datastore" do
    gcloud = Google::Cloud.new "project-id", "keyfile-path"
    stubbed_datastore = ->(project, keyfile, scope: nil, retries: nil, timeout: nil) {
      project.must_equal "project-id"
      keyfile.must_equal "keyfile-path"
      scope.must_be :nil?
      retries.must_be :nil?
      timeout.must_be :nil?
      "datastore-dataset-object"
    }
    Google::Cloud.stub :datastore, stubbed_datastore do
      dataset = gcloud.datastore
      dataset.must_equal "datastore-dataset-object"
    end
  end

  it "passes project and keyfile and options to Google::Cloud.datastore" do
    gcloud = Google::Cloud.new "project-id", "keyfile-path"
    stubbed_datastore = ->(project, keyfile, scope: nil, retries: nil, timeout: nil) {
      project.must_equal "project-id"
      keyfile.must_equal "keyfile-path"
      scope.must_equal "http://example.com/scope"
      retries.must_equal 5
      timeout.must_equal 60
      "datastore-dataset-object-scoped"
    }
    Google::Cloud.stub :datastore, stubbed_datastore do
      dataset = gcloud.datastore scope: "http://example.com/scope", retries: 5, timeout: 60
      dataset.must_equal "datastore-dataset-object-scoped"
    end
  end
end
