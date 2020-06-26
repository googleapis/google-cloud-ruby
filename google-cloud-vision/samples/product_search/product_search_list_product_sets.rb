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

# [START vision_product_search_list_product_sets]
require "google/cloud/vision"

def product_search_list_product_sets project_id = "your-project-id",
                                     location   = "us-west1"

  client = Google::Cloud::Vision.product_search

  location_path = client.location_path project: project_id, location: location

  puts "Product Sets in location #{location}:"
  client.list_product_sets(parent: location_path).each do |product_set|
    puts "\t#{product_set.name}"
  end
end
# [END vision_product_search_list_product_sets]

product_search_list_product_sets(*ARGV) if $PROGRAM_NAME == __FILE__
