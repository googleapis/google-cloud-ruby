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

# [START vision_quickstart]
# [START vision_require]
# Imports the Google Cloud client library
require "google/cloud/vision"
# [END vision_require]

# Instantiates a client
# [START image_annotator_client_new]
# [START image_annotator_labels]
image_annotator = Google::Cloud::Vision.image_annotator
# [END image_annotator_client_new]

# The name of the image file to annotate
file_name = "./resources/cat.jpg"

# Performs label detection on the image file
response = image_annotator.label_detection image: file_name
response.responses.each do |res|
  puts "Labels:"
  res.label_annotations.each do |label|
    puts label.description
  end
end
# [END vision_quickstart]
# [END image_annotator_labels]

# rubocop:disable Lint/UselessAssignment

# [START image_annotator_client_version]
# Instantiates a client with a specified version
image_annotator = Google::Cloud::Vision.image_annotator version: :v1
# [END image_annotator_client_version]

# rubocop:enable Lint/UselessAssignment
