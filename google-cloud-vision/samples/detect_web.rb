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

def detect_web image_path:
  # [START vision_web_detection]
  # image_path = "Path to local image file, eg. './image.png'"

  require "google/cloud/vision"

  image_annotator = Google::Cloud::Vision.image_annotator

  # [START vision_web_detection_migration]
  response = image_annotator.web_detection(
    image:       image_path,
    max_results: 15 # optional, defaults to 10
  )

  response.responses.each do |res|
    res.web_detection.web_entities.each do |entity|
      puts entity.description
    end

    res.web_detection.full_matching_images.each do |match|
      puts match.url
    end
  end
  # [END vision_web_detection_migration]
  # [END vision_web_detection]
end

# This method is a duplicate of the above method, but with a different
# description of the 'image_path' variable, demonstrating the gs://bucket/file
# GCS storage URI format.
def detect_web_gcs image_path:
  # [START vision_web_detection_gcs]
  # image_path = "Google Cloud Storage URI, eg. 'gs://my-bucket/image.png'"

  require "google/cloud/vision"

  image_annotator = Google::Cloud::Vision.image_annotator

  response = image_annotator.web_detection(
    image:       image_path,
    max_results: 15 # optional, defaults to 10
  )

  response.responses.each do |res|
    res.web_detection.web_entities.each do |entity|
      puts entity.description
    end

    res.web_detection.full_matching_images.each do |match|
      puts match.url
    end
  end
  # [END vision_web_detection_gcs]
end

if $PROGRAM_NAME == __FILE__
  image_path = ARGV.shift

  if !image_path
    puts <<~USAGE
      Usage: ruby detect_web.rb [image file path]
       Example:
        ruby detect_web.rb image.png
        ruby detect_web.rb https://public-url/image.png
        ruby detect_web.rb gs://my-bucket/image.png
    USAGE
  elsif image_path =~ URI::DEFAULT_PARSER.make_regexp
    detect_web_gs image_path: image_path
  else
    detect_web image_path: image_path
  end
end
