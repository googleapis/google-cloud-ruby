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
require_relative "../entity_management"

describe "Entity Management" do
  before do
    @project_id               = ENV["GOOGLE_CLOUD_PROJECT"]
    @entity_type_display_name = "entity_type_#{SecureRandom.hex 8}"
    @kind                     = :KIND_MAP
    @entity_value_1           = "fake_entity_for_testing_1"
    @entity_value_2           = "fake_entity_for_testing_2"
    @synonyms                 = ["fake_synonym_for_testing_1", "fake_synonym_for_testing_2"]

    hide do
      clean_entity_types project_id:   @project_id,
                         display_name: @entity_type_display_name
      create_entity_type project_id:   @project_id,
                         display_name: @entity_type_display_name,
                         kind:         @kind
      @entity_type_id = (get_entity_type_ids project_id:   @project_id,
                                             display_name: @entity_type_display_name).first
    end
  end

  after do
    hide do
      delete_entity_type project_id:     @project_id,
                         entity_type_id: @entity_type_id
    end
  end

  it "creates entities" do
    hide do
      create_entity project_id: @project_id, entity_type_id: @entity_type_id,
                    entity_value: @entity_value_1, synonyms: [""]
      create_entity project_id: @project_id, entity_type_id: @entity_type_id,
                    entity_value: @entity_value_2, synonyms: @synonyms
    end

    out, _err = capture_io do
      list_entities project_id: @project_id, entity_type_id: @entity_type_id
    end

    assert_match(/#{@entity_value_1}/, out)
    assert_match(/#{@entity_value_2}/, out)
    assert_match(/#{@synonyms[0]}/, out)
    assert_match(/#{@synonyms[1]}/, out)
  end

  it "deletes entities" do
    hide do
      delete_entity project_id: @project_id, entity_type_id: @entity_type_id,
                    entity_value: @entity_value_1
      delete_entity project_id: @project_id, entity_type_id: @entity_type_id,
                    entity_value: @entity_value_2
    end

    out, _err = capture_io do
      list_entities project_id: @project_id, entity_type_id: @entity_type_id
    end
    refute_match(/#{@entity_value_1}/, out)
  end
end
