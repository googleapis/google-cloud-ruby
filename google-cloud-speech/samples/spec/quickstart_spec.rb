# Copyright 2016 Google, Inc
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

require "rspec"
require "google/cloud/speech"

describe "Speech Quickstart" do
  it "transcribes a sample audio.raw file" do
    speech = Google::Cloud::Speech.new

    expect(Google::Cloud::Speech).to receive(:new)
      .and_return(speech)

    expect {
      load File.expand_path("../quickstart.rb", __dir__)
    }.to output(
      "Transcription: how old is the Brooklyn Bridge\n"
    ).to_stdout
  end
end
