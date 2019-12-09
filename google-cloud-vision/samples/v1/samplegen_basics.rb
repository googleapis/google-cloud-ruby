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

# DO NOT EDIT! This is a generated sample ("Request",  "samplegen_basics")

# sample-metadata
#   title: This is the sample title
#   description: This is the sample description
#   bundle exec ruby samples/v1/samplegen_basics.rb [--display_name "This is the default value of the display_name request field"]

# This is the sample description
def sample_create_product_set display_name = "This is the default value of the display_name request field"
  # [START samplegen_basics]
  # Import client library
  require "google/cloud/vision"

  # Instantiate a client
  product_search_client = Google::Cloud::Vision::ProductSearch.new version: :v1

  # TODO(developer): Uncomment these variables before running the sample.
  # display_name = "This is the default value of the display_name request field"

  # The project and location in which the product set should be created.
  formatted_parent = product_search_client.class.location_path("[PROJECT]", "[LOCATION]")

  product_set = { display_name: display_name }

  response = product_search_client.create_product_set(formatted_parent, product_set)

  # The API response represents the created product set
  product_set = response
  puts "The full name of the created product set: #{product_set.name}"
  # [END samplegen_basics]
end

# Code below processes command-line arguments to execute this code sample.

require "optparse"

if $PROGRAM_NAME == __FILE__

  display_name = "This is the default value of the display_name request field"

  ARGV.options do |opts|
    opts.on("--display_name=val") { |val| display_name = val }
    opts.parse!
  end

  sample_create_product_set(display_name)
end
