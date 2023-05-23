# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative "../pagination"
require_relative "helper"


class ComputeDefaultValuesTest < Minitest::Test
  PROJECT = "windows-sql-cloud"

  def test_pagination
    out = capture_io do
      print_images_list project: PROJECT
    end
    assert out.first.lines.count > 2
  end

  def test_pagination_page
    assert_output(/Page index: 2/) do
      print_images_list_by_page project: PROJECT, page_size: 2
    end
  end
end
