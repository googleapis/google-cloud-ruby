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

# DO NOT EDIT! This is a generated sample ("Request",  "samplegen_resource_path")

# sample-metadata
#   title: Create product set (demonstrate resource paths)
#   description: Create product set (demonstrate resource paths)
#   bundle exec ruby samples/v1/samplegen_resource_path.rb [--project "[PROJECT ID]"]

# Create product set (demonstrate resource paths)
def sample_create_product_set project = "[PROJECT ID]"
  # [START samplegen_resource_path]
  # Import client library
  require "google/cloud/vision"

  # Instantiate a client
  product_search_client = Google::Cloud::Vision::ProductSearch.new version: :v1

  # TODO(developer): Uncomment these variables before running the sample.
  # project = "[PROJECT ID]"

  formatted_parent = product_search_client.class.location_path(project, "us-central1")

  display_name = "[DISPLAY NAME]"

  product_set = { display_name: display_name }

  response = product_search_client.create_product_set(formatted_parent, product_set)

  # The API response represents the created product set
  product_set = response
  puts "The full name of the created product set: #{product_set.name}"
  # [END samplegen_resource_path]
end

# Code below processes command-line arguments to execute this code sample.

require "optparse"

if $PROGRAM_NAME == __FILE__

  project = "[PROJECT ID]"

  ARGV.options do |opts|
    opts.on("--project=val") { |val| project = val }
    opts.parse!
  end

  sample_create_product_set(project)
end
