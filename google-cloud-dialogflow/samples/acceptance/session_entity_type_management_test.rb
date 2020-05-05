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

require_relative "../session_entity_type_management"
require_relative "../detect_intent_texts"
require_relative "../entity_type_management"

describe "Session Entity Type Management" do
  before do
    @project_id = ENV["GOOGLE_CLOUD_PROJECT"]
    @session_id = "session_#{SecureRandom.hex}"
    @entity_type_display_name = "entity_type_#{SecureRandom.hex 8}"
    @entity_values = ["fake_entity_value_1", "fake_entity_value_2"]

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

  def create_test_session_entity_type
    # create an entity type to be overridden
    create_entity_type project_id:   @project_id,
                       display_name: @entity_type_display_name,
                       kind:         :KIND_MAP

    # create a session
    detect_intent_texts project_id:    @project_id,
                        session_id:    @session_id,
                        texts:         ["hi"],
                        language_code: "en-US"

    create_session_entity_type project_id:               @project_id,
                               session_id:               @session_id,
                               entity_type_display_name: @entity_type_display_name,
                               entity_values:            @entity_values
  end

  it "creates a session_entity_type" do
    hide do
      create_test_session_entity_type
    end

    out, _err = capture_io do
      list_session_entity_types project_id: @project_id, session_id: @session_id
    end
    assert_match(/#{@session_id}/, out)
    assert_match(/#{@entity_type_display_name}/, out)
    assert_match(/#{@entity_values[0]}/, out)
    assert_match(/#{@entity_values[1]}/, out)
  end

  it "deletes a session_entity_type" do
    hide do
      create_test_session_entity_type
      delete_session_entity_type project_id:               @project_id,
                                 session_id:               @session_id,
                                 entity_type_display_name: @entity_type_display_name
    end

    out, _err = capture_io do
      list_session_entity_types project_id: @project_id, session_id: @session_id
    end
    refute_match(/#{@entity_type_display_name}/, out)
    refute_match(/#{@entity_values[0]}/, out)
    refute_match(/#{@entity_values[1]}/, out)
  end
end
