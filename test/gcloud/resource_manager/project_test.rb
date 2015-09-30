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

describe Gcloud::ResourceManager::Project, :mock_res_man do
  let(:seed) { 123 }
  let(:project) { Gcloud::ResourceManager::Project.from_gapi random_project_hash(seed),
                                                             resource_manager.connection }

  it "knows its attributes" do
    creation_time = Time.new 2015, 9, 1, 12, 0, 0, 0

    project.project_id.must_equal "example-project-123"
    project.project_number.must_equal "123456789123"
    project.name.must_equal "Example Project 123"
    project.labels["env"].must_equal "production"
    project.created_at.must_equal creation_time
  end

  it "updates the name" do
    mock_connection.put "/v1beta1/projects/#{project.project_id}" do |env|
      [200, {"Content-Type" => "application/json"},
       random_project_hash(123, "Updated Project 123").to_json]
    end

    project.name = "Updated Project 123"
    project.name.must_equal "Updated Project 123"
  end

  it "can't update labels directly" do
    expect do
      project.labels["env"] = "testing"
    end.must_raise RuntimeError # because labels is frozen
  end

  it "can update labels by setting a new hash" do
    mock_connection.put "/v1beta1/projects/#{project.project_id}" do |env|
      [200, {"Content-Type" => "application/json"},
       random_project_hash(123, nil, "env" => "testing").to_json]
    end

    project.labels = { "env" => "testing" }
  end

  it "can update labels by using a block" do
    mock_connection.put "/v1beta1/projects/#{project.project_id}" do |env|
      [200, {"Content-Type" => "application/json"},
       random_project_hash(123, nil, "env" => "testing").to_json]
    end

    project.labels do |labels|
      labels["env"] = "testing"
    end
  end
end
