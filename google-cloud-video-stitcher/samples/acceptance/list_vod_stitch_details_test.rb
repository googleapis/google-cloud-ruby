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

describe "#list_vod_stitch_details", :stitcher_snippet do
  it "lists the stitch details for a VOD session" do
    sample = SampleLoader.load "list_vod_stitch_details.rb"

    refute_nil vod_session
    @session_id = vod_session.name.split("/").last

    assert_output %r{VOD stitch details:\n#{vod_session.name}/vodStitchDetails/\S+} do
      sample.run project_id: project_id, location: location_id,
                 session_id: @session_id
    end
  end
end
