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

# DO NOT EDIT! This is a generated sample ("Request",  "language_syntax_gcs")

# sample-metadata
#   title: Analyzing Syntax (GCS)
#   description: Analyzing Syntax in text file stored in Cloud Storage
#   bundle exec ruby samples/v1/language_syntax_gcs.rb [--gcs_content_uri "gs://cloud-samples-data/language/syntax-sentence.txt"]

require "google/cloud/language"

# [START language_syntax_gcs]

# Analyzing Syntax in text file stored in Cloud Storage
#
# @param gcs_content_uri {String} Google Cloud Storage URI where the file content is located.
# e.g. gs://[Your Bucket]/[Path to File]
def sample_analyze_syntax gcs_content_uri
  # Instantiate a client
  language_client = Google::Cloud::Language.new version: :v1

  # gcs_content_uri = "gs://cloud-samples-data/language/syntax-sentence.txt"

  # Available types: PLAIN_TEXT, HTML
  type = :PLAIN_TEXT

  # Optional. If not specified, the language is automatically detected.
  # For list of supported languages:
  # https://cloud.google.com/natural-language/docs/languages
  language = "en"
  document = {
    gcs_content_uri: gcs_content_uri,
    type: type,
    language: language
  }

  # Available values: NONE, UTF8, UTF16, UTF32
  encoding_type = :UTF8

  response = language_client.analyze_syntax(document, encoding_type: encoding_type)
  # Loop through tokens returned from the API
  response.tokens.each do |token|
    # Get the text content of this token. Usually a word or punctuation.
    text = token.text
    puts "Token text: #{text.content}"
    puts "Location of this token in overall document: #{text.begin_offset}"
    # Get the part of speech information for this token.
    # Parts of spech are as defined in:
    # http://www.lrec-conf.org/proceedings/lrec2012/pdf/274_Paper.pdf
    part_of_speech = token.part_of_speech
    # Get the tag, e.g. NOUN, ADJ for Adjective, et al.
    puts "Part of Speech tag: #{part_of_speech.tag}"
    # Get the voice, e.g. ACTIVE or PASSIVE
    puts "Voice: #{part_of_speech.voice}"
    # Get the tense, e.g. PAST, FUTURE, PRESENT, et al.
    puts "Tense: #{part_of_speech.tense}"
    # See API reference for additional Part of Speech information available
    # Get the lemma of the token. Wikipedia lemma description
    # https://en.wikipedia.org/wiki/Lemma_(morphology)
    puts "Lemma: #{token.lemma}"
    # Get the dependency tree parse information for this token.
    # For more information on dependency labels:
    # http://www.aclweb.org/anthology/P13-2017
    dependency_edge = token.dependency_edge
    puts "Head token index: #{dependency_edge.head_token_index}"
    puts "Label: #{dependency_edge.label}"
  end
  # Get the language of the text, which will be the same as
  # the language specified in the request or, if not specified,
  # the automatically-detected language.
  puts "Language of the text: #{response.language}"
end
# [END language_syntax_gcs]


require "optparse"

if $PROGRAM_NAME == __FILE__

  gcs_content_uri = "gs://cloud-samples-data/language/syntax-sentence.txt"

  ARGV.options do |opts|
    opts.on("--gcs_content_uri=val") { |val| gcs_content_uri = val }
    opts.parse!
  end


  sample_analyze_syntax(gcs_content_uri)
end
