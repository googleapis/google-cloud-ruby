# Copyright 2020 Google, LLC
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

require_relative "helper"

describe "Import product sets and retrieve reference images", :product_search do
  before do
    @product_set_id = "fake_product_set_id_for_testing"
    @temp_product_sets << @product_set_id
  end

  focus
  it "imports product sets and retrieve reference images" do
    snippet_filepath = get_snippet_filepath __FILE__
    product_images = {
      "fake_product_id_for_testing_1" => "shoes_1.jpg",
      "fake_product_id_for_testing_2" => "shoes_2.jpg"
    }

    product_set = nil
    error = nil
    5.times do
      next if product_set
      begin
        output = `ruby #{snippet_filepath} #{@project_id} #{@location}`

        # Verify console output
        product_images.values.each do |image_uri|
          _(output).must_include image_uri
        end

        # Verify project set existence
        product_set_path = @client.product_set_path project: @project_id, location: @location, product_set: @product_set_id
        product_set = @client.get_product_set name: product_set_path
      rescue Google::Cloud::NotFoundError => e
        error = e
        puts "failure"
        sleep rand(10..60)
      end
    end

    if error && !product_set
      raise error
    end

    assert product_set

    # Verify product reference image URIs
    products = @client.list_products_in_product_set name: product_set.name
    products.each do |product|
      product_id = get_id product
      _(product_images).must_include product_id
      reference_image_uri = @client.list_reference_images(parent: product.name).first.uri
      _(reference_image_uri).must_include product_images[product_id]
    end
  end
end
