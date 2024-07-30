# Copyright 2024 Google LLC
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

describe "#delete_vod_config", :stitcher_snippet do
  it "deletes a VOD config" do
    sample = SampleLoader.load "delete_vod_config.rb"

    refute_nil vod_config
    @vod_config_created = true

    client.get_vod_config name: vod_config_name

    assert_output(/Deleted VOD config/) do
      sample.run project_id: project_id, location: location_id,
                 vod_config_id: vod_config_id
    end

    assert_raises Google::Cloud::NotFoundError do
      client.get_vod_config name: vod_config_name
    end
  end
end
