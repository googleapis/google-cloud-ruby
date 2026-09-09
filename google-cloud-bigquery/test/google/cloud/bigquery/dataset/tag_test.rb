# Copyright 2022 Google LLC
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

describe Google::Cloud::Bigquery::Dataset, :routine, :mock_bigquery do
  let(:tag_key) { "2424242256/environment" }
  let(:tag_value) { "production" }
  let(:tag_hash) do
    {
      "tagKey" => tag_key,
      "tagValue" => tag_value
    }
  end
  let(:tag_gapi) { Google::Apis::BigqueryV2::Dataset::Tag.from_json tag_hash.to_json }
  let(:tag) { Google::Cloud::Bigquery::Dataset::Tag.from_gapi tag_gapi }

  it "knows its attributes" do
    _(tag.tag_key).must_equal tag_key
    _(tag.tag_value).must_equal tag_value
  end
end
