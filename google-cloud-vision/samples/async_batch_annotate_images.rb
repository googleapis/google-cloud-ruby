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
#   title: Async Batch Image Annotation
#   description: Perform async batch image annotation

# [START vision_async_batch_annotate_images]
require "google/cloud/vision"

# Perform async batch image annotation
def sample_async_batch_annotate_images input_image_uri, output_uri
  # [START vision_async_batch_annotate_images_core]
  # Instantiate a client
  image_annotator_client = Google::Cloud::Vision.image_annotator

  # input_image_uri = "gs://cloud-samples-data/vision/label/wakeupcat.jpg"
  # output_uri = "gs://your-bucket/prefix/"
  image = { source: { image_uri: input_image_uri } }
  features = [{ type: :LABEL_DETECTION }, { type: :IMAGE_PROPERTIES }]

  # Each requests element corresponds to a single image.  To annotate more
  # images, create a request element for each image and add it to
  # the array of requests
  request = { image: image, features: features }
  gcs_destination = { uri: output_uri }

  # The max number of responses to output in each JSON file
  output_config = { gcs_destination: gcs_destination, batch_size: 2 }

  # Make the long-running operation request
  operation = image_annotator_client.async_batch_annotate_images \
    requests: [request], output_config: output_config

  # Block until operation complete
  operation.wait_until_done!

  raise operation.results.message if operation.error?

  response = operation.response

  # The output is written to GCS with the provided output_uri as prefix
  gcs_output_uri = response.output_config.gcs_destination.uri
  puts "Output written to GCS with prefix: #{gcs_output_uri}"
  # [END vision_async_batch_annotate_images_core]
end
# [END vision_async_batch_annotate_images]


require "optparse"

if $PROGRAM_NAME == __FILE__
  input_image_uri = "gs://cloud-samples-data/vision/label/wakeupcat.jpg"
  output_uri = "gs://your-bucket/prefix/"

  ARGV.options do |opts|
    opts.on("--input_image_uri=val") { |val| input_image_uri = val }
    opts.on("--output_uri=val") { |val| output_uri = val }
    opts.parse!
  end


  sample_async_batch_annotate_images input_image_uri, output_uri
end
