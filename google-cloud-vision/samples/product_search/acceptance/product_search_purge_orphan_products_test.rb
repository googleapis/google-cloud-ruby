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

describe "Purge orphan products", :product_search do
  it "purges orphan products" do
    snippet_filepath = get_snippet_filepath __FILE__
    temp_product = create_temp_product
    assert @client.get_product(name: temp_product.name)

    `ruby #{snippet_filepath} #{@project_id} #{@location}`

    # Verify product was deleted
    assert_raises Google::Cloud::NotFoundError do
      @client.get_product name: temp_product.name
    end
  end
end
