# Copyright 2020 Google LLC
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

# sample-metadata
#   title:
#   description: Perform batch file annotation

# [START vision_batch_annotate_files_gcs]
require "google/cloud/vision"

# Perform batch file annotation
#
# @param storage_uri {String} Cloud Storage URI to source image in the format gs://[bucket]/[file]
def sample_batch_annotate_files_gcs storage_uri
  # [START vision_batch_annotate_files_gcs_core]
  # Instantiate a client
  image_annotator_client = Google::Cloud::Vision.image_annotator

  # storage_uri = "gs://cloud-samples-data/vision/document_understanding/kafka.pdf"
  input_config = {
    gcs_source: { uri: storage_uri },
    mime_type:  "application/pdf"
  }
  feature = { type: :DOCUMENT_TEXT_DETECTION }

  # The service can process up to 5 pages per document file.
  # Here we specify the first, second, and last page of the document to be processed.
  request = {
    input_config: input_config,
    features:     [feature],
    pages:        [1, 2, -1]
  }

  response = image_annotator_client.batch_annotate_files requests: [request]
  response.responses[0].responses.each do |image_response|
    display_image_annotation_response image_response
  end
  # [END vision_batch_annotate_files_gcs_core]
end

def display_image_annotation_response image_response
  puts "Full text: #{image_response.full_text_annotation.text}"
  image_response.full_text_annotation.pages.each do |page|
    page.blocks.each do |block|
      puts "\nBlock confidence: #{block.confidence}"
      block.paragraphs.each do |par|
        puts "\tParagraph confidence: #{par.confidence}"
        par.words.each do |word|
          puts "\t\tWord confidence: #{word.confidence}"
          word.symbols.each do |symbol|
            puts "\t\t\tSymbol: #{symbol.text}, (confidence: #{symbol.confidence})"
          end
        end
      end
    end
  end
end
# [END vision_batch_annotate_files_gcs]


require "optparse"

if $PROGRAM_NAME == __FILE__
  storage_uri = "gs://cloud-samples-data/vision/document_understanding/kafka.pdf"

  ARGV.options do |opts|
    opts.on("--storage_uri=val") { |val| storage_uri = val }
    opts.parse!
  end

  sample_batch_annotate_files_gcs storage_uri
end
