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

def detect_safe_search image_path:
  # [START vision_safe_search_detection]
  # image_path = "Path to local image file, eg. './image.png'"

  require "google/cloud/vision"

  image_annotator = Google::Cloud::Vision.image_annotator

  # [START vision_safe_search_detection_migration]
  response = image_annotator.safe_search_detection image: image_path

  response.responses.each do |res|
    safe_search = res.safe_search_annotation

    puts "Adult:    #{safe_search.adult}"
    puts "Spoof:    #{safe_search.spoof}"
    puts "Medical:  #{safe_search.medical}"
    puts "Violence: #{safe_search.violence}"
    puts "Racy:     #{safe_search.racy}"
  end
  # [END vision_safe_search_detection_migration]
  # [END vision_safe_search_detection]
end

# This method is a duplicate of the above method, but with a different
# description of the 'image_path' variable, demonstrating the gs://bucket/file
# GCS storage URI format.
def detect_safe_search_gcs image_path:
  # [START vision_safe_search_detection_gcs]
  # image_path = "Google Cloud Storage URI, eg. 'gs://my-bucket/image.png'"

  require "google/cloud/vision"

  image_annotator = Google::Cloud::Vision.image_annotator

  response = image_annotator.safe_search_detection image: image_path

  response.responses.each do |res|
    safe_search = res.safe_search_annotation

    puts "Adult:    #{safe_search.adult}"
    puts "Spoof:    #{safe_search.spoof}"
    puts "Medical:  #{safe_search.medical}"
    puts "Violence: #{safe_search.violence}"
    puts "Racy:     #{safe_search.racy}"
  end
  # [END vision_safe_search_detection_gcs]
end

if $PROGRAM_NAME == __FILE__
  image_path = ARGV.shift

  if !image_path
    puts <<~USAGE
      Usage: ruby detect_safe_search.rb [image file path]
       Example:
        ruby detect_safe_search.rb image.png
        ruby detect_safe_search.rb https://public-url/image.png
        ruby detect_safe_search.rb gs://my-bucket/image.png
    USAGE
  elsif image_path =~ URI::DEFAULT_PARSER.make_regexp
    detect_safe_search_gs image_path: image_path
  else
    detect_safe_search image_path: image_path
  end
end
