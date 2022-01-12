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

require "test_helper"

class PagedEnumerableInvalidRequestTest < Minitest::Test
  def test_MissingPageTokenRequest
    request = Gapic::Examples::MissingPageTokenRequest.new
    response = Gapic::Examples::GoodPagedResponse.new
    options = Gapic::CallOptions.new

    error = assert_raises ArgumentError do
      Gapic::PagedEnumerable.new(
        Object.new, :method_name, request, response, :fake_operation, options
      )
    end
    exp_msg = "#{request.class} must have a page_token field (String)"
    assert_equal exp_msg, error.message
  end

  def test_MissingPageSizeRequest
    request = Gapic::Examples::MissingPageSizeRequest.new
    response = Gapic::Examples::GoodPagedResponse.new
    options = Gapic::CallOptions.new

    error = assert_raises ArgumentError do
      Gapic::PagedEnumerable.new(
        Object.new, :method_name, request, response, :fake_operation, options
      )
    end
    exp_msg = "#{request.class} must have a page_size field (Integer)"
    assert_equal exp_msg, error.message
  end
end
