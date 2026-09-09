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

describe "#get_asset", :live_stream_snippet do
  it "gets the asset" do
    sample = SampleLoader.load "get_asset.rb"

    refute_nil asset
    @asset_created = true

    assert_output(/Asset: #{asset.name}/) do
      sample.run project_id: project_id, location: location_id, asset_id: asset_id
    end
  end
end
