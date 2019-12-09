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

# DO NOT EDIT! This is a generated sample ("Request",  "samplegen_map_field_access")

# sample-metadata
#   title: This sample reads and loops over a map field in the response
#   description: This sample reads and loops over a map field in the response
#   bundle exec ruby samples/v1/samplegen_map_field_access.rb

# This sample reads and loops over a map field in the response
def sample_analyze_entities
  # [START samplegen_map_field_access]
  # Import client library
  require "google/cloud/language"

  # Instantiate a client
  language_client = Google::Cloud::Language.new version: :v1

  type = :PLAIN_TEXT

  language = "en"

  # The text content to analyze
  content = "Googleplex is at 1600 Amphitheatre Parkway, Mountain View, CA."

  document = {
    type: type,
    language: language,
    content: content
  }

  response = language_client.analyze_entities(document)

  response.entities.each do |entity|
    # Each detected entity has a map of metadata:
    map = entity.metadata

    # Access value by key:
    puts "URL: #{map["wikipedia_url"]}"
    # Loop over keys and values:
    map.each do |key, value|
      puts "#{key}: #{value}"
    end

    # Loop over just keys:
    map.keys.each do |the_key|
      puts "Key: #{the_key}"
    end

    # Loop over just values:
    map.values.each do |the_value|
      puts "Value: #{the_value}"
    end

  end
  # [END samplegen_map_field_access]
end

# Code below processes command-line arguments to execute this code sample.

require "optparse"

if $PROGRAM_NAME == __FILE__
  sample_analyze_entities
end
