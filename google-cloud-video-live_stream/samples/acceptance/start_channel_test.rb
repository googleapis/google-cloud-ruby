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

describe "#start_channel", :live_stream_snippet do
  it "starts the channel" do
    sample = SampleLoader.load "start_channel.rb"

    refute_nil input
    refute_nil channel
    @input_created = true

    assert_output(/Started channel/) do
      sample.run project_id: project_id, location: location_id, channel_id: channel_id
    end
    @channel_created_started = true
  end
end
