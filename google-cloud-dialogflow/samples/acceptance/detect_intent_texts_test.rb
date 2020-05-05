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

require_relative "../detect_intent_texts"

describe "Detect Intent Texts" do
  before do
    @project_id = ENV["GOOGLE_CLOUD_PROJECT"]
    @session_id = "session_#{SecureRandom.hex}"
    @texts      = ["hello", "book a meeting room", "Mountain View",
                   "tomorrow", "10 AM", "2 hours", "10 people", "A", "yes"]
    @language_code = "en-US"
  end

  it "detects intent from texts" do
    assert_output(/All set!/) do
      detect_intent_texts project_id:    @project_id,
                          session_id:    @session_id,
                          texts:         @texts,
                          language_code: @language_code
    end
  end
end
