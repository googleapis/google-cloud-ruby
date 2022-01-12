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

class PagedEnumerableInvalidResponseTest < Minitest::Test
  def test_MissingRepeatedResponse
    request = Gapic::Examples::GoodPagedRequest.new
    response = Gapic::Examples::MissingRepeatedResponse.new
    options = Gapic::CallOptions.new

    error = assert_raises ArgumentError do
      Gapic::PagedEnumerable.new(
        Object.new, :method_name, request, response, :fake_operation, options
      )
    end
    exp_msg = "#{response.class} must have one repeated field"
    assert_equal exp_msg, error.message
  end

  def test_MissingMessageResponse
    request = Gapic::Examples::GoodPagedRequest.new
    response = Gapic::Examples::MissingMessageResponse.new
    options = Gapic::CallOptions.new

    error = assert_raises ArgumentError do
      Gapic::PagedEnumerable.new(
        Object.new, :method_name, request, response, :fake_operation, options
      )
    end
    exp_msg = "#{response.class} must have one repeated field"
    assert_equal exp_msg, error.message
  end

  def test_MissingNextPageTokenResponse
    request = Gapic::Examples::GoodPagedRequest.new
    response = Gapic::Examples::MissingNextPageTokenResponse.new
    options = Gapic::CallOptions.new

    error = assert_raises ArgumentError do
      Gapic::PagedEnumerable.new(
        Object.new, :method_name, request, response, :fake_operation, options
      )
    end
    exp_msg = "#{response.class} must have a next_page_token field (String)"
    assert_equal exp_msg, error.message
  end

  def test_BadMessageOrderResponse
    skip "Looks like fields are already sorted by number, not proto order"

    request = Gapic::Examples::GoodPagedRequest.new
    response = Gapic::Examples::BadMessageOrderResponse.new
    options = Gapic::CallOptions.new

    error = assert_raises ArgumentError do
      Gapic::PagedEnumerable.new(
        Object.new, :method_name, request, response, :fake_operation, options
      )
    end
    exp_msg = "#{response.class} must have one primary repeated field " \
      "by both position and number"
    assert_equal exp_msg, error.message
  end
end
