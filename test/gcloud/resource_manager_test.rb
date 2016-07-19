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
require "gcloud/resource_manager"

describe Gcloud do
  it "calls out to Gcloud.resource_manager" do
    gcloud = Gcloud.new
    stubbed_resource_manager = ->(keyfile, scope: nil, retries: nil, timeout: nil) {
      keyfile.must_equal nil
      scope.must_be :nil?
      retries.must_be :nil?
      timeout.must_be :nil?
      "resource_manager-manager-object-empty"
    }
    Gcloud.stub :resource_manager, stubbed_resource_manager do
      manager = gcloud.resource_manager
      manager.must_equal "resource_manager-manager-object-empty"
    end
  end

  it "passes project and keyfile to Gcloud.resource_manager" do
    gcloud = Gcloud.new "project-id", "keyfile-path"
    stubbed_resource_manager = ->(keyfile, scope: nil, retries: nil, timeout: nil) {
      keyfile.must_equal "keyfile-path"
      scope.must_be :nil?
      retries.must_be :nil?
      timeout.must_be :nil?
      "resource_manager-manager-object"
    }
    Gcloud.stub :resource_manager, stubbed_resource_manager do
      manager = gcloud.resource_manager
      manager.must_equal "resource_manager-manager-object"
    end
  end

  it "passes project and keyfile and options to Gcloud.resource_manager" do
    gcloud = Gcloud.new "project-id", "keyfile-path"
    stubbed_resource_manager = ->(keyfile, scope: nil, retries: nil, timeout: nil) {
      keyfile.must_equal "keyfile-path"
      scope.must_equal "http://example.com/scope"
      retries.must_equal 5
      timeout.must_equal 60
      "resource_manager-manager-object-scoped"
    }
    Gcloud.stub :resource_manager, stubbed_resource_manager do
      manager = gcloud.resource_manager scope: "http://example.com/scope", retries: 5, timeout: 60
      manager.must_equal "resource_manager-manager-object-scoped"
    end
  end
end
