# Copyright 2022 Google, Inc
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

describe "#update_input", :live_stream_snippet do
  it "updates the input" do
    sample = SampleLoader.load "update_input.rb"

    refute_nil input

    out, _err = capture_io do
      sample.run project_id: project_id, location: location_id, input_id: input_id
    end

    assert_match(/Updated input: #{input.name}/, out)
    assert_match(/Updated pre-processing config: 5/, out)
  end
end
