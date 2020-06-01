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

# [START vision_product_search_create_product]
# [START vision_product_search_tutorial_import]
require "google/cloud/vision"
# [END vision_product_search_tutorial_import]

def product_search_create_product project_id = "your-project-id"
  client = Google::Cloud::Vision.product_search

  # A resource that represents Google Cloud Platform location.
  location      = "us-west1" # specify a compute region name
  location_path = client.location_path project: project_id, location: location

  # Create a product with the product specification in the region.
  # Set product display name and product category.
  product = {
    display_name:     "sample-product-1234",
    description:      "Athletic shorts",
    product_category: "apparel",
    product_labels:   [{ key: "color", value: "blue" }]
  }

  # The response is the product with the `name` field populated.
  product = client.create_product parent: location_path, product: product

  # Display the product information.
  puts "Product name: #{product.name}"
end
# [END vision_product_search_create_product]

product_search_create_product(*ARGV) if $PROGRAM_NAME == __FILE__
