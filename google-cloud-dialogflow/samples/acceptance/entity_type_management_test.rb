# Copyright 2020 Google LLC
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

require_relative "helper"
require "securerandom"

require_relative "../entity_type_management"

describe "Entity Type Management" do
  before do
    @project_id               = ENV["GOOGLE_CLOUD_PROJECT"]
    @entity_type_display_name = "entity_type_#{SecureRandom.hex 8}"
    @kind                     = :KIND_MAP

    hide do
      clean_entity_types project_id:   @project_id,
                         display_name: @entity_type_display_name
    end
  end

  after do
    hide do
      clean_entity_types project_id:   @project_id,
                         display_name: @entity_type_display_name
    end
  end

  it "creates an entity type" do
    ids = get_entity_type_ids project_id:   @project_id,
                              display_name: @entity_type_display_name
    assert_empty ids

    assert_output(/#{@entity_type_display_name}/) do
      create_entity_type project_id:   @project_id,
                         display_name: @entity_type_display_name,
                         kind:         @kind
    end

    ids = get_entity_type_ids project_id:   @project_id,
                              display_name: @entity_type_display_name
    assert_equal 1, ids.size
  end

  it "deletes an entity type" do
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

    ids = get_entity_type_ids project_id:   @project_id,
                              display_name: @entity_type_display_name
    assert_empty ids
  end
end
