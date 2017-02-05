# Copyright 2016 Google Inc. All rights reserved.
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

require "helper"

describe Google::Cloud::Speech::Audio, :recognize, :mock_speech do
  let(:results_json) { "{\"results\":[{\"alternatives\":[{\"transcript\":\"how old is the Brooklyn Bridge\",\"confidence\":0.98267895}]}]}" }
  let(:results_grpc) { Google::Cloud::Speech::V1::RecognizeResponse.decode_json results_json }
  let(:results) { results_grpc.results.map { |result_grpc| Google::Cloud::Speech::Result.from_grpc result_grpc } }
  let(:filepath) { "acceptance/data/audio.raw" }
  let(:audio_grpc) { Google::Cloud::Speech::V1::RecognitionAudio.new(content: File.read(filepath, mode: "rb")) }
  let(:audio) { Google::Cloud::Speech::Audio.from_source filepath, speech }

  it "recognizes audio" do
    config_grpc = Google::Cloud::Speech::V1::RecognitionConfig.new(encoding: :LINEAR16, sample_rate_hertz: 16000, language_code: "en")

    mock = Minitest::Mock.new
    mock.expect :recognize, results_grpc, [config_grpc, audio_grpc, options: default_options]

    audio.encoding = :raw
    audio.sample_rate = 16000
    audio.language = "en"

    speech.service.mocked_service = mock
    results = audio.recognize
    mock.verify

    results.count.must_equal 1
    results.first.transcript.must_equal "how old is the Brooklyn Bridge"
    results.first.confidence.must_be_close_to 0.98267895
    results.first.alternatives.must_be :empty?
  end

  it "recognizes audio with language (Symbol)" do
    config_grpc = Google::Cloud::Speech::V1::RecognitionConfig.new(encoding: :LINEAR16, sample_rate_hertz: 16000, language_code: "en")

    mock = Minitest::Mock.new
    mock.expect :recognize, results_grpc, [config_grpc, audio_grpc, options: default_options]

    audio.encoding = :raw
    audio.sample_rate = 16000
    audio.language = :en

    speech.service.mocked_service = mock
    results = audio.recognize
    mock.verify

    results.count.must_equal 1
    results.first.transcript.must_equal "how old is the Brooklyn Bridge"
    results.first.confidence.must_be_close_to 0.98267895
    results.first.alternatives.must_be :empty?
  end
end
