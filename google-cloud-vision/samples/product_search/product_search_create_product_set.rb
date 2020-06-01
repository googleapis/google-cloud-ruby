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

# [START vision_product_search_create_product_set]
require "google/cloud/vision"

def product_search_create_product_set project_id = "your-project-id"
  client = Google::Cloud::Vision.product_search

  # A resource that represents Google Cloud Platform location.
  location = "us-west1" # specify a compute region name
  location_path = client.location_path project: project_id, location: location

  # Create a product set with the product set specification in the region.
  product_set = {
    display_name: "display-name"
  }

  # The response is the product set with `name` populated.
  product_set = client.create_product_set parent:      location_path,
                                          product_set: product_set

  # Display the product set information.
  puts "Product set name: #{product_set.name}"
end
# [END vision_product_search_create_product_set]

product_search_create_product_set(*ARGV) if $PROGRAM_NAME == __FILE__
