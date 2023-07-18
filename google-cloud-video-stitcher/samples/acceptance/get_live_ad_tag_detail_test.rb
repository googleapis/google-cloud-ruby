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

describe "#get_live_ad_tag_detail", :stitcher_snippet do
  it "gets an ad tag detail for a live session" do
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

    output = capture_io {
      sample.run project_id: project_id, location: location_id, session_id: @session_id
    }

    @ad_tag_detail_id = output[0].to_s.split("/").last.strip
    sample = SampleLoader.load "get_live_ad_tag_detail.rb"

    out, _err = capture_io do
      sample.run project_id: project_id, location: location_id, session_id: @session_id, ad_tag_detail_id: @ad_tag_detail_id
    end

    assert_match %r{Live ad tag detail: projects/\S+/locations/#{location_id}/liveSessions/#{@session_id}/liveAdTagDetails/#{@ad_tag_detail_id}}, out
  end
end
