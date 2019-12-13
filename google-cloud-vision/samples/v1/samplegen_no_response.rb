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

# DO NOT EDIT! This is a generated sample ("Request",  "samplegen_no_response")

# sample-metadata
#   title: Delete Product Set (returns Empty)
#   description: Delete Product Set (returns Empty)
#   bundle exec ruby samples/v1/samplegen_no_response.rb

# Delete Product Set (returns Empty)
def sample_delete_product_set
  # [START samplegen_no_response]
  # Import client library
  require "google/cloud/vision"

  # Instantiate a client
  product_search_client = Google::Cloud::Vision::ProductSearch.new version: :v1

  # The full name of the product set to delete
  formatted_name = product_search_client.class.product_set_path("[PROJECT]", "[LOCATION]", "[PRODUCT_SET]")

  product_search_client.delete_product_set(formatted_name)
  puts "Deleted product set."
  # [END samplegen_no_response]
end

# Code below processes command-line arguments to execute this code sample.

require "optparse"

if $PROGRAM_NAME == __FILE__
  sample_delete_product_set
end
