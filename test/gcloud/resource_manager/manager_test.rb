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

describe Gcloud::ResourceManager::Manager, :mock_res_man do
  it "gets a project given a project_id" do
    mock_connection.get "/v1beta1/projects/example-project-123" do |env|
      [200, {"Content-Type" => "application/json"},
       random_project_hash(123).to_json]
    end

    project = resource_manager.project "example-project-123"

    project.must_be_kind_of Gcloud::ResourceManager::Project
    project.project_id.must_equal "example-project-123"
  end
end
