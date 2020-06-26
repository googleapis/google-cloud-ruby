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

describe "Delete reference image", :product_search do
  it "deletes reference image" do
    snippet_filepath = get_snippet_filepath __FILE__
    product = create_temp_product
    product_id = get_id product
    reference_image = create_temp_reference_image product
    reference_image_id = get_id reference_image

    `ruby #{snippet_filepath} #{@project_id} #{@location} #{product_id} #{reference_image_id}`

    assert_raises Google::Cloud::NotFoundError do
      @client.get_reference_image name: reference_image.name
    end
  end
end
