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

# DO NOT EDIT! This is a generated sample ("Request",  "language_sentiment_text")

# sample-metadata
#   title: Analyzing Sentiment
#   description: Analyzing Sentiment in a String
#   bundle exec ruby samples/v1/language_sentiment_text.rb [--text_content "I am so happy and joyful."]

require "google/cloud/language"

# [START language_sentiment_text]

# Analyzing Sentiment in a String
#
# @param text_content {String} The text content to analyze
def sample_analyze_sentiment text_content
  # Instantiate a client
  language_client = Google::Cloud::Language.new version: :v1

  # text_content = "I am so happy and joyful."

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

  # Available values: NONE, UTF8, UTF16, UTF32
  encoding_type = :UTF8

  response = language_client.analyze_sentiment(document, encoding_type: encoding_type)
  # Get overall sentiment of the input document
  puts "Document sentiment score: #{response.document_sentiment.score}"
  puts "Document sentiment magnitude: #{response.document_sentiment.magnitude}"
  # Get sentiment for all sentences in the document
  response.sentences.each do |sentence|
    puts "Sentence text: #{sentence.text.content}"
    puts "Sentence sentiment score: #{sentence.sentiment.score}"
    puts "Sentence sentiment magnitude: #{sentence.sentiment.magnitude}"
  end
  # Get the language of the text, which will be the same as
  # the language specified in the request or, if not specified,
  # the automatically-detected language.
  puts "Language of the text: #{response.language}"
end
# [END language_sentiment_text]


require "optparse"

if $PROGRAM_NAME == __FILE__

  text_content = "I am so happy and joyful."

  ARGV.options do |opts|
    opts.on("--text_content=val") { |val| text_content = val }
    opts.parse!
  end


  sample_analyze_sentiment(text_content)
end
