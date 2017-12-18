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

describe Google::Cloud::Speech::Audio, :process, :mock_speech do
  let(:filepath) { "acceptance/data/audio.raw" }
  let(:audio_grpc) { Google::Cloud::Speech::V1::RecognitionAudio.new(content: File.read(filepath, mode: "rb")) }
  let(:audio) { Google::Cloud::Speech::Audio.from_source filepath, speech }
  let(:op_json) { "{\"name\":\"1234567890\",\"metadata\":{\"typeUrl\":\"type.googleapis.com/google.cloud.speech.V1.AsyncRecognizeMetadata\",\"value\":\"CFQSDAi6jKS/BRCwkLafARoMCIeZpL8FEKjRqswC\"}}" }
  let(:op_grpc) { Google::Gax::Operation.new Google::Longrunning::Operation.decode_json(op_json), nil, Google::Cloud::Speech::V1::LongRunningRecognizeResponse, Google::Cloud::Speech::V1::LongRunningRecognizeMetadata }

  it "recognizes audio op" do
    config_grpc = Google::Cloud::Speech::V1::RecognitionConfig.new(encoding: :LINEAR16, language_code: "en-US", sample_rate_hertz: 16000)

    mock = Minitest::Mock.new
    mock.expect :long_running_recognize, op_grpc, [config_grpc, audio_grpc, options: default_options]

    audio.encoding = :linear16
    audio.sample_rate = 16000
    audio.language = "en-US"

    speech.service.mocked_service = mock
    op = audio.process
    mock.verify

    op.must_be_kind_of Google::Cloud::Speech::Operation
    op.id.must_equal "1234567890"
    op.wont_be :done?
  end

  it "recognizes audio op with language (Symbol)" do
    config_grpc = Google::Cloud::Speech::V1::RecognitionConfig.new(encoding: :LINEAR16, language_code: "en", sample_rate_hertz: 16000)

    mock = Minitest::Mock.new
    mock.expect :long_running_recognize, op_grpc, [config_grpc, audio_grpc, options: default_options]

    audio.encoding = :linear16
    audio.sample_rate = 16000
    audio.language = :en

    speech.service.mocked_service = mock
    op = audio.process
    mock.verify

    op.must_be_kind_of Google::Cloud::Speech::Operation
    op.id.must_equal "1234567890"
    op.wont_be :done?
  end

  it "recognizes audio op with words" do
    config_grpc = Google::Cloud::Speech::V1::RecognitionConfig.new(encoding: :LINEAR16, language_code: "en-US", sample_rate_hertz: 16000, enable_word_time_offsets: true)

    mock = Minitest::Mock.new
    mock.expect :long_running_recognize, op_grpc, [config_grpc, audio_grpc, options: default_options]

    audio.encoding = :linear16
    audio.sample_rate = 16000
    audio.language = "en-US"

    speech.service.mocked_service = mock
    op = audio.process words: true
    mock.verify

    op.must_be_kind_of Google::Cloud::Speech::Operation
    op.id.must_equal "1234567890"
    op.wont_be :done?
  end
end
