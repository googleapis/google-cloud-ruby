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

require "uri"

def detect_document_text image_path:
  # [START vision_fulltext_detection]
  # image_path = "Path to local image file, eg. './image.png'"

  require "google/cloud/vision"

  image_annotator = Google::Cloud::Vision.image_annotator

  # [START vision_fulltext_detection_migration]
  response = image_annotator.document_text_detection image: image_path

  text = ""
  response.responses.each do |res|
    res.text_annotations.each do |annotation|
      text << annotation.description
    end
  end

  puts text
  # [END vision_fulltext_detection_migration]
  # [END vision_fulltext_detection]
end

# This method is a duplicate of the above method, but with a different
# description of the 'image_path' variable, demonstrating the gs://bucket/file
# GCS storage URI format.
def detect_document_text_gcs image_path:
  # [START vision_fulltext_detection_gcs]
  # image_path = "Google Cloud Storage URI, eg. 'gs://my-bucket/image.png'"

  require "google/cloud/vision"

  image_annotator = Google::Cloud::Vision.image_annotator

  response = image_annotator.document_text_detection image: image_path

  text = ""
  response.responses.each do |res|
    res.text_annotations.each do |annotation|
      text << annotation.description
    end
  end

  puts text
  # [END vision_fulltext_detection_gcs]
end

def detect_document_text_async image_path:, output_path:
  # [START vision_fulltext_detection_asynchronous]
  # image_path = "Google Cloud Storage URI, eg. 'gs://my-bucket/document.pdf'"
  # output_path = "Google Cloud Storage URI, eg. 'gs://my-bucket/prefix'"

  # [START image_annotator_asynchronous_migration]
  require "google/cloud/vision"

  image_annotator = Google::Cloud::Vision.image_annotator

  operation = image_annotator.document_text_detection(
    image:       image_path,
    async:       true,
    max_results: 15, # optional, defaults to 10
    destination: output_path,
    batch_size:  1, # optional, defaults to 10.
    mime_type:   "application/pdf"
  )

  operation.wait_until_done!
  # [END image_annotator_asynchronous_migration]
  # results will be stored in Google Cloud Storage formatted like
  # "#{output_path}output-#{start_page}-to-#{end_page}.json"
  # [END vision_fulltext_detection_asynchronous]
end

if $PROGRAM_NAME == __FILE__
  args = {
    image_path:  ARGV.shift,
    output_path: ARGV.shift
  }

  if args[:image_path].nil?
    puts <<~USAGE
      Usage: ruby detect_document_text.rb [image file path]
       Example:
        ruby detect_document_text.rb image.png
        ruby detect_document_text.rb https://public-url/image.png
        ruby detect_document_text.rb gs://my-bucket/image.png
    USAGE
  elsif args[:image_path] =~ URI::DEFAULT_PARSER.make_regexp
    detect_document_text_gcs args unless args[:output_path]
    detect_document_text_async args if args[:output_path]
  else
    detect_document_text args
  end
end
