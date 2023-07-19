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

describe "#create_live_session", :stitcher_snippet do
  it "creates a live session" do
    sample = SampleLoader.load "create_live_session.rb"

    refute_nil slate
    @slate_created = true

    refute_nil live_config
    @live_config_created = true

    out, _err = capture_io do
      sample.run project_id: project_id, location: location_id,
                 live_config_id: live_config_id
    end

    assert_match %r{Live session: projects/\S+/locations/#{location_id}/liveSessions/\S+}, out
  end
end
