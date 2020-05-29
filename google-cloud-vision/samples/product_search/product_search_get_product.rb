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

# [START vision_product_search_get_product]
require "google/cloud/vision"

def product_search_get_product project_id = "your-project-id",
                               location   = "us-west1",
                               product_id = "your-product-id"

  client = Google::Cloud::Vision.product_search

  product_path = client.product_path project:  project_id,
                                     location: location,
                                     product:  product_id

  product = client.get_product name: product_path

  puts "Product name: #{product.name}"
  puts "Product display name: #{product.display_name}"
end
# [END vision_product_search_get_product]

product_search_get_product(*ARGV) if $PROGRAM_NAME == __FILE__
