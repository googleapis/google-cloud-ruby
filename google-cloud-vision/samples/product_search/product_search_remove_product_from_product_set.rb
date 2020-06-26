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

# [START vision_product_search_remove_product_from_product_set]
require "google/cloud/vision"

def product_search_remove_product_from_product_set \
    project_id     = "your-project-id",
    location       = "us-west1",
    product_set_id = "your-product-set-id",
    product_id     = "your-product-id"

  client = Google::Cloud::Vision.product_search

  # Get the full path of the product set.
  product_set_path = client.product_set_path project:     project_id,
                                             location:    location,
                                             product_set: product_set_id

  # Get the full path of the product.
  product_path = client.product_path project:  project_id,
                                     location: location,
                                     product:  product_id

  # Remove the product from the product set.
  client.remove_product_from_product_set name:    product_set_path,
                                         product: product_path

  puts "Product #{product_id} removed from product set #{product_set_id}."
end
# [END vision_product_search_remove_product_from_product_set]

product_search_remove_product_from_product_set(*ARGV) if $PROGRAM_NAME == __FILE__
