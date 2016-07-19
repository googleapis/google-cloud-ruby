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
require "gcloud/bigquery"

describe Gcloud do
  it "calls out to Gcloud.bigquery" do
    gcloud = Gcloud.new
    stubbed_bigquery = ->(project, keyfile, scope: nil, retries: nil, timeout: nil) {
      project.must_equal nil
      keyfile.must_equal nil
      scope.must_be :nil?
      retries.must_be :nil?
      timeout.must_be :nil?
      "bigquery-project-object-empty"
    }
    Gcloud.stub :bigquery, stubbed_bigquery do
      project = gcloud.bigquery
      project.must_equal "bigquery-project-object-empty"
    end
  end

  it "passes project and keyfile to Gcloud.bigquery" do
    gcloud = Gcloud.new "project-id", "keyfile-path"
    stubbed_bigquery = ->(project, keyfile, scope: nil, retries: nil, timeout: nil) {
      project.must_equal "project-id"
      keyfile.must_equal "keyfile-path"
      scope.must_be :nil?
      retries.must_be :nil?
      timeout.must_be :nil?
      "bigquery-project-object"
    }
    Gcloud.stub :bigquery, stubbed_bigquery do
      project = gcloud.bigquery
      project.must_equal "bigquery-project-object"
    end
  end

  it "passes project and keyfile and options to Gcloud.bigquery" do
    gcloud = Gcloud.new "project-id", "keyfile-path"
    stubbed_bigquery = ->(project, keyfile, scope: nil, retries: nil, timeout: nil) {
      project.must_equal "project-id"
      keyfile.must_equal "keyfile-path"
      scope.must_equal "http://example.com/scope"
      retries.must_equal 5
      timeout.must_equal 60
      "bigquery-project-object-scoped"
    }
    Gcloud.stub :bigquery, stubbed_bigquery do
      project = gcloud.bigquery scope: "http://example.com/scope", retries: 5, timeout: 60
      project.must_equal "bigquery-project-object-scoped"
    end
  end
end
