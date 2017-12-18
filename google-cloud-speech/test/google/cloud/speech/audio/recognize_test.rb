# Copyright 2016 Google LLC
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

require "helper"

describe Google::Cloud::Speech::Audio, :recognize, :mock_speech do
  let(:results_json) { "{\"results\":[{\"alternatives\":[{\"transcript\":\"how old is the Brooklyn Bridge\",\"confidence\":0.98267895}]}]}" }
  let(:results_grpc) { Google::Cloud::Speech::V1::RecognizeResponse.decode_json results_json }
  let(:results) { results_grpc.results.map { |result_grpc| Google::Cloud::Speech::Result.from_grpc result_grpc } }
  let(:words_results_json) { "{\"results\":[{\"alternatives\":[{\"transcript\":\"how old is the Brooklyn Bridge\",\"confidence\":0.987629,\"words\":[{\"startTime\":{},\"endTime\":{\"nanos\":300000000},\"word\":\"how\"},{\"startTime\":{\"nanos\":300000000},\"endTime\":{\"nanos\":600000000},\"word\":\"old\"},{\"startTime\":{\"nanos\":600000000},\"endTime\":{\"nanos\":800000000},\"word\":\"is\"},{\"startTime\":{\"nanos\":800000000},\"endTime\":{\"nanos\":900000000},\"word\":\"the\"},{\"startTime\":{\"nanos\":900000000},\"endTime\":{\"seconds\":1,\"nanos\":100000000},\"word\":\"Brooklyn\"},{\"startTime\":{\"seconds\":1,\"nanos\":100000000},\"endTime\":{\"seconds\":1,\"nanos\":500000000},\"word\":\"Bridge\"}]}]}]}" }
  let(:words_results_grpc) { Google::Cloud::Speech::V1::RecognizeResponse.decode_json words_results_json }
  let(:filepath) { "acceptance/data/audio.raw" }
  let(:audio_grpc) { Google::Cloud::Speech::V1::RecognitionAudio.new(content: File.read(filepath, mode: "rb")) }
  let(:audio) { Google::Cloud::Speech::Audio.from_source filepath, speech }

  it "recognizes audio" do
    config_grpc = Google::Cloud::Speech::V1::RecognitionConfig.new(encoding: :LINEAR16, language_code: "en-US", sample_rate_hertz: 16000)

    mock = Minitest::Mock.new
    mock.expect :recognize, results_grpc, [config_grpc, audio_grpc, options: default_options]

    audio.encoding = :linear16
    audio.sample_rate = 16000
    audio.language = "en-US"

    speech.service.mocked_service = mock
    results = audio.recognize
    mock.verify

    results.count.must_equal 1
    results.first.transcript.must_equal "how old is the Brooklyn Bridge"
    results.first.confidence.must_be_close_to 0.98267895
    results.first.alternatives.must_be :empty?
  end

  it "recognizes audio with language (Symbol)" do
    config_grpc = Google::Cloud::Speech::V1::RecognitionConfig.new(encoding: :LINEAR16, language_code: "en", sample_rate_hertz: 16000)

    mock = Minitest::Mock.new
    mock.expect :recognize, results_grpc, [config_grpc, audio_grpc, options: default_options]

    audio.encoding = :linear16
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

  it "recognizes audio with word times" do
    config_grpc = Google::Cloud::Speech::V1::RecognitionConfig.new(encoding: :LINEAR16, language_code: "en-US", sample_rate_hertz: 16000, enable_word_time_offsets: true)

    mock = Minitest::Mock.new
    mock.expect :recognize, words_results_grpc, [config_grpc, audio_grpc, options: default_options]

    audio.encoding = :linear16
    audio.sample_rate = 16000
    audio.language = "en-US"

    speech.service.mocked_service = mock
    results = audio.recognize words: true
    mock.verify

    results.count.must_equal 1
    results.first.transcript.must_equal "how old is the Brooklyn Bridge"
    results.first.confidence.must_be_close_to 0.98762899
    results.first.words.wont_be :empty?
    results.first.words.map(&:word).must_equal %w{how old is the Brooklyn Bridge}
    results.first.words.each do |word|
      word.must_be_kind_of Google::Cloud::Speech::Result::Word
      word.word.must_be_kind_of String
      word.start_time.must_be_kind_of Numeric
      word.end_time.must_be_kind_of Numeric
    end
    results.first.alternatives.must_be :empty?
  end
end
