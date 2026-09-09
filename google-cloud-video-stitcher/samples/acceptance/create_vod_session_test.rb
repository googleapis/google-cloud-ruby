# Copyright 2022 Google LLC
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

describe "#create_vod_session", :stitcher_snippet do
  it "creates a VOD session" do
    sample = SampleLoader.load "create_vod_session.rb"

    refute_nil vod_config
    @vod_config_created = true

    out, _err = capture_io do
      sample.run project_id: project_id, location: location_id,
                 vod_config_id: vod_config_id
    end

    assert_match %r{VOD session: projects/\S+/locations/#{location_id}/vodSessions/\S+}, out
  end
end
