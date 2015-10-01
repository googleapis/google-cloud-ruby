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
  let(:project_hash) { random_project_hash(seed) }
  let(:project) { Gcloud::ResourceManager::Project.from_gapi project_hash,
                                                             resource_manager.connection }

  it "knows its attributes" do
    project.project_id.must_equal "example-project-123"
    project.project_number.must_equal "123456789123"
    project.name.must_equal "Example Project 123"
    project.labels["env"].must_equal "production"
    project.created_at.must_equal Time.new(2015, 9, 1, 12, 0, 0, 0)
  end

  it "updates the name" do
    mock_connection.put "/v1beta1/projects/#{project.project_id}" do |env|
      json = JSON.parse(env.body)
      json["name"].must_equal "Updated Project 123"
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
      json = JSON.parse(env.body)
      json["labels"].must_equal( "env" => "testing" )
      [200, {"Content-Type" => "application/json"},
       random_project_hash(123, nil, "env" => "testing").to_json]
    end

    project.labels = { "env" => "testing" }
  end

  it "can update labels by using a block" do
    mock_connection.put "/v1beta1/projects/#{project.project_id}" do |env|
      json = JSON.parse(env.body)
      json["labels"].must_equal( "env" => "testing" )
      [200, {"Content-Type" => "application/json"},
       random_project_hash(123, nil, "env" => "testing").to_json]
    end

    project.labels do |labels|
      labels["env"] = "testing"
    end
  end

  it "can update name and labels in a single API call" do
    mock_connection.put "/v1beta1/projects/#{project.project_id}" do |env|
      json = JSON.parse(env.body)
      json["name"].must_equal "Updated Project 123"
      json["labels"].must_equal( "env" => "testing" )
      [200, {"Content-Type" => "application/json"},
       random_project_hash(123, "Updated Project 123", "env" => "testing").to_json]
    end

    project.update do |tx|
      tx.name = "Updated Project 123"
      tx.labels["env"] = "testing"
    end
  end

  it "can update name and override labels in a single API call" do
    mock_connection.put "/v1beta1/projects/#{project.project_id}" do |env|
      json = JSON.parse(env.body)
      json["name"].must_equal "Updated Project 123"
      json["labels"].must_equal( "env" => "testing" )
      [200, {"Content-Type" => "application/json"},
       random_project_hash(123, "Updated Project 123", "env" => "testing").to_json]
    end

    project.update do |tx|
      tx.name = "Updated Project 123"
      tx.labels = { "env" => "testing" }
    end
  end

  it "reloads itself" do
    unspecified_hash = random_project_hash 123
    unspecified_hash["lifecycleState"] = "LIFECYCLE_STATE_UNSPECIFIED"

    mock_connection.get "/v1beta1/projects/#{project.project_id}" do |env|
      [200, {"Content-Type" => "application/json"},
       unspecified_hash.to_json]
    end

    project.must_be :active?
    project.reload!
    project.must_be :unspecified?
  end

  it "deletes itself" do
    mock_connection.delete "/v1beta1/projects/#{project.project_id}" do |env|
      [200, {}, ""]
    end

    project.delete
  end

  it "undeletes itself" do
    mock_connection.post "/v1beta1/projects/#{project.project_id}:undelete" do |env|
      [200, {}, ""]
    end

    project.undelete
  end

  describe :state do
    it "knows its state" do
      project.state.must_equal "ACTIVE"
      project.must_be :active?
      project.wont_be :unspecified?
      project.wont_be :delete_requested?
      project.wont_be :delete_in_progress?
    end

    describe :unspecified do
      let(:project_hash) do
        hash = random_project_hash(seed)
        hash["lifecycleState"] = "LIFECYCLE_STATE_UNSPECIFIED"
        hash
      end

      it "can be unspecified" do
        project.state.must_equal "LIFECYCLE_STATE_UNSPECIFIED"
        project.wont_be :active?
        project.must_be :unspecified?
        project.wont_be :delete_requested?
        project.wont_be :delete_in_progress?
      end
    end

    describe :delete_requested do
      let(:project_hash) do
        hash = random_project_hash(seed)
        hash["lifecycleState"] = "DELETE_REQUESTED"
        hash
      end

      it "can be delete_requested" do
        project.state.must_equal "DELETE_REQUESTED"
        project.wont_be :active?
        project.wont_be :unspecified?
        project.must_be :delete_requested?
        project.wont_be :delete_in_progress?
      end
    end

    describe :delete_in_progress do
      let(:project_hash) do
        hash = random_project_hash(seed)
        hash["lifecycleState"] = "DELETE_IN_PROGRESS"
        hash
      end

      it "can be DELETE_IN_PROGRESS" do
        project.state.must_equal "DELETE_IN_PROGRESS"
        project.wont_be :active?
        project.wont_be :unspecified?
        project.wont_be :delete_requested?
        project.must_be :delete_in_progress?
      end
    end
  end
end
