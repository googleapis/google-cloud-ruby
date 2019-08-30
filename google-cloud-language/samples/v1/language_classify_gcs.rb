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

# DO NOT EDIT! This is a generated sample ("Request",  "language_classify_gcs")

# sample-metadata
#   title: Classify Content (GCS)
#   description: Classifying Content in text file stored in Cloud Storage
#   bundle exec ruby samples/v1/language_classify_gcs.rb [--gcs_content_uri "gs://cloud-samples-data/language/classify-entertainment.txt"]

require "google/cloud/language"

# [START language_classify_gcs]

# Classifying Content in text file stored in Cloud Storage
#
# @param gcs_content_uri {String} Google Cloud Storage URI where the file content is located.
# e.g. gs://[Your Bucket]/[Path to File]
# The text file must include at least 20 words.
def sample_classify_text gcs_content_uri
  # Instantiate a client
  language_client = Google::Cloud::Language.new version: :v1

  # gcs_content_uri = "gs://cloud-samples-data/language/classify-entertainment.txt"

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
# [END language_classify_gcs]


require "optparse"

if $PROGRAM_NAME == __FILE__

  gcs_content_uri = "gs://cloud-samples-data/language/classify-entertainment.txt"

  ARGV.options do |opts|
    opts.on("--gcs_content_uri=val") { |val| gcs_content_uri = val }
    opts.parse!
  end


  sample_classify_text(gcs_content_uri)
end
