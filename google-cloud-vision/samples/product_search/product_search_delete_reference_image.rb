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

# [START vision_product_search_delete_reference_image]
require "google/cloud/vision"

def product_search_delete_reference_image project_id = "your-project-id",
                                          location   = "us-west1",
                                          product_id = "your-product-id",
                                          image_id   = "your-image-id"

  client = Google::Cloud::Vision.product_search

  reference_image_path = client.reference_image_path project:         project_id,
                                                     location:        location,
                                                     product:         product_id,
                                                     reference_image: image_id

  client.delete_reference_image name: reference_image_path

  puts "Reference image #{image_id} deleted from product #{product_id}."
end
# [END vision_product_search_delete_reference_image]

product_search_delete_reference_image(*ARGV) if $PROGRAM_NAME == __FILE__
