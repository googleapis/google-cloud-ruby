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

require_relative "../intent_management"

describe "Intent Management" do
  before do
    @project_id             = ENV["GOOGLE_CLOUD_PROJECT"]
    @intent_display_name    = "fake_intent_for_testing"
    @message_text           = "fake_message_text_for_testing"
    @training_phrases_parts = %w[fake_training_phrase_part_1
                                 fake_training_phease_part_2]
  end

  example "create intent" do
    expect(
      get_intent_ids(project_id:   @project_id,
                     display_name: @intent_display_name).size
    ).to eq(0)

    expectation = expect {
      create_intent project_id:             @project_id,
                    display_name:           @intent_display_name,
                    message_text:           @message_text,
                    training_phrases_parts: @training_phrases_parts
    }.to output(
      /#{@intent_display_name}.*#{@message_text}/m
    ).to_stdout

    expect(
      get_intent_ids(project_id:   @project_id,
                     display_name: @intent_display_name).size
    ).to eq(1)
  end

  example "delete intent" do
    hide do
      intent_ids = get_intent_ids project_id:   @project_id,
                                  display_name: @intent_display_name

      intent_ids.each do |intent_id|
        delete_intent project_id: @project_id,
                      intent_id:  intent_id
      end
    end
    expect(
      (get_intent_ids project_id:   @project_id,
                      display_name: @intent_display_name).size
    ).to eq(0)
  end
end
