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

describe "#update_vod_config", :stitcher_snippet do
  it "updates a VOD config" do
    sample = SampleLoader.load "update_vod_config.rb"

    refute_nil vod_config
    @vod_config_created = true

    out, _err = capture_io do
      sample.run project_id: project_id, location: location_id,
                 vod_config_id: vod_config_id, source_uri: updated_vod_uri
    end

    vod_config_id_regex = Regexp.escape vod_config_id
    assert_match %r{Updated VOD config: projects/\S+/locations/#{location_id}/vodConfigs/#{vod_config_id_regex}}, out
    assert_match %r{Updated source URI: #{updated_vod_uri}}, out
  end
end
