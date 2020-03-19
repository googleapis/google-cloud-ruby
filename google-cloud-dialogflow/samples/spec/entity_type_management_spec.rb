# Copyright 2018 Google, Inc
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

require "rspec"
require "google/cloud/dialogflow"
require "spec_helper"

require_relative "../entity_type_management"

describe "Entity Type Management" do
  before do
    @project_id               = ENV["GOOGLE_CLOUD_PROJECT"]
    @entity_type_display_name = "fake_entity_type_for_testing"
    @kind                     = :KIND_MAP
  end

  before :each do
    hide do
      clean_entity_types project_id:   @project_id,
                         display_name: @entity_type_display_name
    end
  end

  after :each do
    hide do
      clean_entity_types project_id:   @project_id,
                         display_name: @entity_type_display_name
    end
  end

  example "create entity type" do
    expect(
      get_entity_type_ids(project_id:   @project_id,
                          display_name: @entity_type_display_name).size
    ).to eq(0)

    expect {
      create_entity_type project_id:   @project_id,
                         display_name: @entity_type_display_name,
                         kind:         @kind
    }.to output(
      /#{@entity_type_display_name}/
    ).to_stdout

    expect(
      (get_entity_type_ids project_id:   @project_id,
                           display_name: @entity_type_display_name).size
    ).to eq(1)
  end

  example "delete entity type" do
    hide do
      create_entity_type project_id:   @project_id,
                         display_name: @entity_type_display_name,
                         kind:         @kind
      entity_type_ids = get_entity_type_ids project_id:   @project_id,
                                            display_name: @entity_type_display_name
      entity_type_ids.each do |entity_type_id|
        delete_entity_type project_id:     @project_id,
                           entity_type_id: entity_type_id
      end
    end
    expect(
      (get_entity_type_ids project_id:   @project_id,
                           display_name: @entity_type_display_name).size
    ).to eq(0)
  end
end
