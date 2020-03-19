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

require_relative "../context_management"

describe "Context Management" do
  before do
    @project_id = ENV["GOOGLE_CLOUD_PROJECT"]
    @session_id = "fake_session_for_testing"
    @context_id = "fake_context_for_testing"
  end

  example "create context" do
    expect {
      list_contexts project_id: @project_id, session_id: @session_id
    }.not_to output(
      /#{@context_id}/
    ).to_stdout
    expect {
      create_context project_id: @project_id,
                     session_id: @session_id,
                     context_id: @context_id
    }.to output(
      /#{@session_id}.*#{@context_id}/m
    ).to_stdout
    expect {
      list_contexts project_id: @project_id, session_id: @session_id
    }.to output(
      /#{@context_id}/
    ).to_stdout
  end

  example "delete context" do
    hide do
      create_context project_id: @project_id,
                     session_id: @session_id,
                     context_id: @context_id

      delete_context project_id: @project_id,
                     session_id: @session_id,
                     context_id: @context_id
    end
    expect {
      list_contexts project_id: @project_id, session_id: @session_id
    }.not_to output(
      /#{@context_id}/
    ).to_stdout
  end
end
