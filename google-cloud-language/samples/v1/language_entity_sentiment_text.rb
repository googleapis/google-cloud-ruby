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

# DO NOT EDIT! This is a generated sample ("Request",  "language_entity_sentiment_text")

# sample-metadata
#   title: Analyzing Entity Sentiment
#   description: Analyzing Entity Sentiment in a String
#   bundle exec ruby samples/v1/language_entity_sentiment_text.rb [--text_content "Grapes are good. Bananas are bad."]

require "google/cloud/language"

# [START language_entity_sentiment_text]

# Analyzing Entity Sentiment in a String
#
# @param text_content {String} The text content to analyze
def sample_analyze_entity_sentiment text_content
  # Instantiate a client
  language_client = Google::Cloud::Language.new version: :v1

  # text_content = "Grapes are good. Bananas are bad."

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

  response = language_client.analyze_entity_sentiment(document, encoding_type: encoding_type)
  # Loop through entitites returned from the API
  response.entities.each do |entity|
    puts "Representative name for the entity: #{entity.name}"
    # Get entity type, e.g. PERSON, LOCATION, ADDRESS, NUMBER, et al
    puts "Entity type: #{entity.type}"
    # Get the salience score associated with the entity in the [0, 1.0] range
    puts "Salience score: #{entity.salience}"
    # Get the aggregate sentiment expressed for this entity in the provided document.
    sentiment = entity.sentiment
    puts "Entity sentiment score: #{sentiment.score}"
    puts "Entity sentiment magnitude: #{sentiment.magnitude}"
    # Loop over the metadata associated with entity. For many known entities,
    # the metadata is a Wikipedia URL (wikipedia_url) and Knowledge Graph MID (mid).
    # Some entity types may have additional metadata, e.g. ADDRESS entities
    # may have metadata for the address street_name, postal_code, et al.
    entity.metadata.each do |metadata_name, metadata_value|
      puts "#{metadata_name} = #{metadata_value}"
    end

    # Loop over the mentions of this entity in the input document.
    # The API currently supports proper noun mentions.
    entity.mentions.each do |mention|
      puts "Mention text: #{mention.text.content}"
      # Get the mention type, e.g. PROPER for proper noun
      puts "Mention type: #{mention.type}"
    end
  end
  # Get the language of the text, which will be the same as
  # the language specified in the request or, if not specified,
  # the automatically-detected language.
  puts "Language of the text: #{response.language}"
end
# [END language_entity_sentiment_text]


require "optparse"

if $PROGRAM_NAME == __FILE__

  text_content = "Grapes are good. Bananas are bad."

  ARGV.options do |opts|
    opts.on("--text_content=val") { |val| text_content = val }
    opts.parse!
  end


  sample_analyze_entity_sentiment(text_content)
end
