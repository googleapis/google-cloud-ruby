# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative "helper"
require "securerandom"

describe "smoke test" do
  it "detects text intents" do
    project_id = ENV["GOOGLE_CLOUD_PROJECT"]
    session_id = "session_#{SecureRandom.hex}"
    session_client = Google::Cloud::Dialogflow.sessions
    session = session_client.session_path project: project_id,
                                          session: session_id
    texts = [
      "hello",
      "book a meeting room",
      "Mountain View",
      "tomorrow",
      "10 AM",
      "2 hours",
      "10 people",
      "A",
      "yes"
    ]
    language_code = "en-US"
    fulfillment_text = nil
    texts.each do |text|
      query_input = { text: { text: text, language_code: language_code } }
      response = session_client.detect_intent session:     session,
                                              query_input: query_input
      query_result = response.query_result
      fulfillment_text = query_result.fulfillment_text
    end
    assert_equal "All set!", fulfillment_text
  end
end
