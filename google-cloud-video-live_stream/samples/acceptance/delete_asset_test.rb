# Copyright 2023 Google, Inc
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

describe "#delete_asset", :live_stream_snippet do
  it "deletes the asset" do
    sample = SampleLoader.load "delete_asset.rb"

    refute_nil asset
    client.get_asset name: asset_name

    assert_output(/Deleted asset/) do
      sample.run project_id: project_id, location: location_id, asset_id: asset_id
    end

    assert_raises Google::Cloud::NotFoundError do
      client.get_asset name: asset_name
    end
  end
end
