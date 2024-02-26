# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "minitest/autorun"
require "minitest/spec"

require "google/cloud/speech/v1"

class SpeechSmokeTest < Minitest::Test
  def test_recognize
    speech_client = Google::Cloud::Speech::V1::Speech::Client.new
    config = {
      language_code: "en-US",
      sample_rate_hertz: 44100,
      encoding: :FLAC
    }
    audio = {
      uri: "gs://cloud-samples-data/speech/brooklyn_bridge.flac"
    }
    response = speech_client.recognize config: config, audio: audio
    refute_equal 0, response.results.size
  end
end
