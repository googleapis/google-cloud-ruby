# Copyright 2019 Google LLC
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

# DO NOT EDIT! This is a generated sample ("RequestPagedAll",  "samplegen_paged")

# sample-metadata
#   title: List product sets
#   description: List product sets
#   bundle exec ruby samples/v1/samplegen_paged.rb

# List product sets
def sample_list_product_sets
  # [START samplegen_paged]
  # Import client library
  require "google/cloud/vision"

  # Instantiate a client
  product_search_client = Google::Cloud::Vision::ProductSearch.new version: :v1

  # The project and location where the product sets are contained.
  formatted_parent = product_search_client.class.location_path("[PROJECT]", "[LOCATION]")

  # Iterate over all results.
  product_search_client.list_product_sets(formatted_parent).each do |element|
    # The entity in this iteration represents a product set
    product_set = element
    puts "The full name of this product set: #{product_set.name}"
  end
  # [END samplegen_paged]
end

# Code below processes command-line arguments to execute this code sample.

require "optparse"

if $PROGRAM_NAME == __FILE__
  sample_list_product_sets
end
