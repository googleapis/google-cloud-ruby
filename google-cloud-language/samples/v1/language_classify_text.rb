# Copyright 2019 Google LLC
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

# DO NOT EDIT! This is a generated sample ("Request",  "language_classify_text")

# sample-metadata
#   title: Classify Content
#   description: Classifying Content in a String
#   bundle exec ruby samples/v1/language_classify_text.rb [--text_content "That actor on TV makes movies in Hollywood and also stars in a variety of popular new TV shows."]

require "google/cloud/language"

# [START language_classify_text]

# Classifying Content in a String
#
# @param text_content {String} The text content to analyze. Must include at least 20 words.
def sample_classify_text text_content
  # Instantiate a client
  language_client = Google::Cloud::Language.new version: :v1

  # text_content = "That actor on TV makes movies in Hollywood and also stars in a variety of popular new TV shows."

  # Available types: PLAIN_TEXT, HTML
  type = :PLAIN_TEXT

  # Optional. If not specified, the language is automatically detected.
  # For list of supported languages:
  # https://cloud.google.com/natural-language/docs/languages
  language = "en"
  document = {
    content: text_content,
    type: type,
    language: language
  }

  response = language_client.classify_text(document)
  # Loop through classified categories returned from the API
  response.categories.each do |category|
    # Get the name of the category representing the document.
    # See the predefined taxonomy of categories:
    # https://cloud.google.com/natural-language/docs/categories
    puts "Category name: #{category.name}"
    # Get the confidence. Number representing how certain the classifier
    # is that this category represents the provided text.
    puts "Confidence: #{category.confidence}"
  end
end
# [END language_classify_text]


require "optparse"

if $PROGRAM_NAME == __FILE__

  text_content = "That actor on TV makes movies in Hollywood and also stars in a variety of popular new TV shows."

  ARGV.options do |opts|
    opts.on("--text_content=val") { |val| text_content = val }
    opts.parse!
  end


  sample_classify_text(text_content)
end
