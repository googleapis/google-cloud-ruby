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

# [START vision_product_search_list_reference_images]
require "google/cloud/vision"

def product_search_list_reference_images project_id = "your-project-id",
                                         location   = "us-west1",
                                         product_id = "your-product-id"

  client = Google::Cloud::Vision.product_search

  product_path = client.product_path project:  project_id,
                                     location: location,
                                     product:  product_id

  puts "Reference images for product #{product_id}:"
  client.list_reference_images(parent: product_path).each do |reference_image|
    puts "\t#{reference_image.name}"
  end
end
# [END vision_product_search_list_reference_images]

product_search_list_reference_images(*ARGV) if $PROGRAM_NAME == __FILE__
