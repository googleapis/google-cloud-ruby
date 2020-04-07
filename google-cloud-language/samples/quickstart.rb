# Copyright 2016 Google, Inc
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

def quickstart
  # [START language_quickstart]
  # Imports the Google Cloud client library
  require "google/cloud/language"

  # Instantiates a client
  language = Google::Cloud::Language.language_service

  # The text to analyze
  text = "Hello, world!"

  # Detects the sentiment of the text
  document = { content: text, type: :PLAIN_TEXT }
  response = language.analyze_sentiment document: document

  # Get document sentiment from response
  sentiment = response.document_sentiment

  puts "Text: #{text}"
  puts "Score: #{sentiment.score}, #{sentiment.magnitude}"
  # [END language_quickstart]
end

quickstart if $PROGRAM_NAME == __FILE__

# todo delete this