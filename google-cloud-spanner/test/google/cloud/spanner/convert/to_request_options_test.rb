# Copyright 2020 Google LLC
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

require "helper"
require "bigdecimal"

describe Google::Cloud::Spanner::Convert, :to_request_options, :mock_spanner do
  it "returns nil for nil options value" do
    options = Google::Cloud::Spanner::Convert.to_request_options nil
    _(options).must_be_nil
  end

  it "returns same options if tag field not present" do
    options = Google::Cloud::Spanner::Convert.to_request_options({extra: "123"})
    _(options).must_equal({ extra: "123" })
  end

  it "transform tag key to provided tag type" do
    options = Google::Cloud::Spanner::Convert.to_request_options(
      { tag: "Tag-1" }, tag_type: :request_tag
    )
    _(options).must_equal({ request_tag: "Tag-1"})

    options = Google::Cloud::Spanner::Convert.to_request_options(
      { tag: "Tag-2" }, tag_type: :transaction_tag
    )
    _(options).must_equal({ transaction_tag: "Tag-2"})
  end

  it "transform tag key to provided tag type and merge with options" do
    options = Google::Cloud::Spanner::Convert.to_request_options(
      { extra: "123", transaction_tag: "Tag-1", tag: "Tag-1-1" }, tag_type: :request_tag
    )
    _(options).must_equal({ extra: "123", transaction_tag: "Tag-1", request_tag: "Tag-1-1"})
  end
end
