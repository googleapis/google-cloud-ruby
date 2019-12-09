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

# DO NOT EDIT! This is a generated sample ("Request",  "samplegen_no_config")

# sample-metadata
#   title:
#   bundle exec ruby samples/v1/samplegen_no_config.rb

#
def sample_create_product_set
  # Import client library
  require "google/cloud/vision"

  # Instantiate a client
  product_search_client = Google::Cloud::Vision::ProductSearch.new version: :v1

  formatted_parent = product_search_client.class.location_path("[PROJECT]", "[LOCATION]")

  product_set = {}

  response = product_search_client.create_product_set(formatted_parent, product_set)

  puts response.inspect
end

# Code below processes command-line arguments to execute this code sample.

require "optparse"

if $PROGRAM_NAME == __FILE__
  sample_create_product_set
end
