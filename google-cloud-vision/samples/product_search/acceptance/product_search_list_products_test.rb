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

describe "List products", :product_search do
  it "lists products" do
    snippet_filepath = get_snippet_filepath __FILE__
    2.times { create_temp_product }

    output = `ruby #{snippet_filepath} #{@project_id} #{@location}`

    output_products = output.split("\n").select { |line| line.include? "projects/" }
    _(output_products.length).must_be :>=, 2
  end
end
