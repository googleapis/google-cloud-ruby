# Copyright 2020 Google LLC
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

def detect_text_with_custom_endpoint image_path: nil
  # image_path = "Google Cloud Storage URI, eg. 'gs://my-bucket/image.png'"
  # [START vision_set_endpoint]
  require "google/cloud/vision"

  # Specifies the location of the api endpoint
  image_annotator = Google::Cloud::Vision.image_annotator do |config|
    config.endpoint = "eu-vision.googleapis.com"
  end
  # [END vision_set_endpoint]

  response = image_annotator.text_detection(
    image:       image_path,
    max_results: 1
  )

  response.responses.each do |res|
    res.text_annotations.each do |text|
      puts text.description
    end
  end
end

detect_text_with_custom_endpoint image_path: ARGV.first if $PROGRAM_NAME == __FILE__
