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

require_relative "../context_management"

describe "Context Management" do
  before do
    @project_id = ENV["GOOGLE_CLOUD_PROJECT"]
    @session_id = "session_#{SecureRandom.hex}"
    @context_id = "context_#{SecureRandom.hex}"
  end

  it "creates context" do
    out, _err = capture_io do
      list_contexts project_id: @project_id, session_id: @session_id
    end
    refute_match(/#{@context_id}/, out)

    assert_output(/#{@session_id}.*#{@context_id}/m) do
      create_context project_id: @project_id,
                     session_id: @session_id,
                     context_id: @context_id
    end

    assert_output(/#{@context_id}/) do
      list_contexts project_id: @project_id, session_id: @session_id
    end
  end

  it "deletes context" do
    hide do
      create_context project_id: @project_id,
                     session_id: @session_id,
                     context_id: @context_id

      delete_context project_id: @project_id,
                     session_id: @session_id,
                     context_id: @context_id
    end

    out, _err = capture_io do
      list_contexts project_id: @project_id, session_id: @session_id
    end
    refute_match(/#{@context_id}/, out)
  end
end
