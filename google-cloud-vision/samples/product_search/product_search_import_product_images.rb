# Copyright 2018 Google, LLC
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

# [START vision_product_search_import_product_images]
require "google/cloud/vision"

def product_search_import_product_sets project_id = "your-project-id",
                                       location   = "us-west1"

  client = Google::Cloud::Vision.product_search

  # A resource that represents Google Cloud Platform location.
  location_path = client.location_path project: project_id, location: location

  # Set the input configuration along with Google Cloud Storage URI
  input_config = {
    gcs_source: {
      csv_file_uri: "gs://cloud-samples-data/vision/product_search/product_sets.csv"
    }
  }

  # Import the product sets from the input URI.
  operation = client.import_product_sets parent:       location_path,
                                         input_config: input_config
  puts "Processing operation name: #{operation.name}"
  operation.wait_until_done! # Waits for the operation to complete

  puts "Processing done."

  result = operation.response
  result.statuses.each_with_index do |status, index|
    puts "Status of processing line #{index} of the csv: #{status.code}"

    # Check the status of reference image
    # `0` is the code for OK in google.rpc.Code.
    if status.code.zero?
      reference_image = result.reference_images[index]
      puts reference_image.uri
    else
      puts "Status code not OK: #{status.message}"
    end
  end
end
# [END vision_product_search_import_product_images]

product_search_import_product_sets(*ARGV) if $PROGRAM_NAME == __FILE__
