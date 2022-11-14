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

describe "#get_vod_stitch_detail", :stitcher_snippet do
  it "gets a stitch detail for a VOD session" do
    sample = SampleLoader.load "list_vod_stitch_details.rb"

    refute_nil vod_session
    @session_id = vod_session.name.split("/").last

    output = capture_io {
      sample.run project_id: project_id, location: location_id, session_id: @session_id
    }

    @stitch_detail_id = output[0].to_s.split("/").last.strip
    sample = SampleLoader.load "get_vod_stitch_detail.rb"

    out, _err = capture_io do
      sample.run project_id: project_id, location: location_id, session_id: @session_id, stitch_detail_id: @stitch_detail_id
    end

    assert_match %r{VOD stitch detail: projects/\S+/locations/#{location_id}/vodSessions/#{@session_id}/vodStitchDetails/#{@stitch_detail_id}}, out
  end
end
