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

# [START vision_product_search_get_similar_products_gcs]
require "google/cloud/vision"

def product_search_get_similar_products_gcs \
    project_id       = "your-project-id",
    location         = "us-west1",
    product_set_id   = "your-product-set-id",
    product_category = "apparel",
    gcs_uri          = "gs://cloud-samples-data/vision/product_search/shoes_1.jpg",
    filter           = "(color = red OR color = blue) AND style = kids"

  product_search_client  = Google::Cloud::Vision.product_search
  image_annotator_client = Google::Cloud::Vision.image_annotator

  product_set_path = product_search_client.product_set_path(
    project:     project_id,
    location:    location,
    product_set: product_set_id
  )

  product_set = product_search_client.get_product_set name: product_set_path

  if product_set.index_time.seconds.zero?
    puts "Product set has not been indexed. Please wait and try again."
    return
  end

  product_search_params = {
    product_set:        product_set_path,
    product_categories: [product_category],
    filter:             filter
  }
  image_context = { product_search_params: product_search_params }

  response = image_annotator_client.product_search_detection(
    image:         gcs_uri,
    image_context: image_context
  )

  display_similar_products_gcs response.responses.first.product_search_results
end

def display_similar_products_gcs search_results
  index_time = search_results.index_time
  puts "Product set index time:"
  puts "\tseconds: #{index_time.seconds}"
  puts "\tnanos: #{index_time.nanos}\n"

  puts "Search results:"
  search_results.results.each_with_index do |result, index|
    puts "Result #{index + 1}:"
    product = result.product

    puts "\tScore(Confidence): #{result.score}"
    puts "\tImage name: #{result.image}"

    puts "\tProduct name: #{product.name}"
    puts "\tProduct display name: #{product.display_name}"
    puts "\tProduct description: #{product.description}"
    puts "\tProduct labels: #{product.product_labels}"
  end
end

# [END vision_product_search_get_similar_products_gcs]

product_search_get_similar_products_gcs(*ARGV) if $PROGRAM_NAME == __FILE__
