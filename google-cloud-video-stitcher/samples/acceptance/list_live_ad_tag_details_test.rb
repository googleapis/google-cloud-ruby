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

describe "#list_live_ad_tag_details", :stitcher_snippet do
  it "lists the ad tag details for a live session" do
    sample = SampleLoader.load "list_live_ad_tag_details.rb"

    refute_nil slate
    @slate_created = true

    refute_nil live_config
    @live_config_created = true

    refute_nil live_session
    @session_id = live_session.name.split("/").last

    # Ad tag details
    # To get ad tag details, you need to curl the main manifest and
    # a rendition first. This supplies media player information to the API.
    get_renditions live_session.play_uri

    assert_output %r{Live ad tag details:\n#{live_session.name}/liveAdTagDetails/\S+} do
      sample.run project_id: project_id, location: location_id, session_id: @session_id
    end
  end
end
