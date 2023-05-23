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

describe "#update_slate", :stitcher_snippet do
  it "updates a slate" do
    sample = SampleLoader.load "update_slate.rb"

    refute_nil slate
    @slate_created = true

    out, _err = capture_io do
      sample.run project_id: project_id, location: location_id, slate_id: slate_id, slate_uri: updated_slate_uri
    end

    slate_id_regex = Regexp.escape slate_id
    assert_match %r{Updated slate: projects/\S+/locations/#{location_id}/slates/#{slate_id_regex}}, out
    assert_match %r{Updated uri: #{updated_slate_uri}}, out
  end
end
