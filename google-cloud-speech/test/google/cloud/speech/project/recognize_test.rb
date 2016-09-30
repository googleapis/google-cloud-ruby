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

describe Google::Cloud::Speech::Project, :recognize, :mock_speech do
  let(:results_json) { "{\"results\":[{\"alternatives\":[{\"transcript\":\"how old is the Brooklyn Bridge\",\"confidence\":0.98267895}]}]}" }
  let(:results_grpc) { Google::Cloud::Speech::V1beta1::SyncRecognizeResponse.decode_json results_json }
  let(:results) { results_grpc.results.map { |result_grpc| Google::Cloud::Speech::Result.from_grpc result_grpc } }

  it "recognizes audio from local file path" do
    config_grpc = Google::Cloud::Speech::V1beta1::RecognitionConfig.new(encoding: :LINEAR16, sample_rate: 16000)
    audio_grpc = Google::Cloud::Speech::V1beta1::RecognitionAudio.new(content: File.read("acceptance/data/audio.raw", mode: "rb"))

    mock = Minitest::Mock.new
    mock.expect :sync_recognize, results_grpc, [config_grpc, audio_grpc]

    speech.service.mocked_service = mock
    results = speech.recognize "acceptance/data/audio.raw", encoding: :raw, sample_rate: 16000
    mock.verify

    results.count.must_equal 1
    results.first.transcript.must_equal "how old is the Brooklyn Bridge"
    results.first.confidence.must_be_close_to 0.98267895
    results.first.alternatives.must_be :empty?
  end

  it "recognizes audio from local file object" do
    config_grpc = Google::Cloud::Speech::V1beta1::RecognitionConfig.new(encoding: :LINEAR16, sample_rate: 16000)
    audio_grpc = Google::Cloud::Speech::V1beta1::RecognitionAudio.new(content: File.read("acceptance/data/audio.raw", mode: "rb"))

    mock = Minitest::Mock.new
    mock.expect :sync_recognize, results_grpc, [config_grpc, audio_grpc]

    speech.service.mocked_service = mock
    results = speech.recognize File.open("acceptance/data/audio.raw", "rb"), encoding: :raw, sample_rate: 16000
    mock.verify

    results.count.must_equal 1
    results.first.transcript.must_equal "how old is the Brooklyn Bridge"
    results.first.confidence.must_be_close_to 0.98267895
    results.first.alternatives.must_be :empty?
  end

  it "recognizes audio from GCS URL" do
    config_grpc = Google::Cloud::Speech::V1beta1::RecognitionConfig.new(encoding: :LINEAR16, sample_rate: 16000)
    audio_grpc = Google::Cloud::Speech::V1beta1::RecognitionAudio.new(uri: "gs://some_bucket/audio.raw")

    mock = Minitest::Mock.new
    mock.expect :sync_recognize, results_grpc, [config_grpc, audio_grpc]

    speech.service.mocked_service = mock
    results = speech.recognize "gs://some_bucket/audio.raw", encoding: :raw, sample_rate: 16000
    mock.verify

    results.count.must_equal 1
    results.first.transcript.must_equal "how old is the Brooklyn Bridge"
    results.first.confidence.must_be_close_to 0.98267895
    results.first.alternatives.must_be :empty?
  end

  it "recognizes audio from Storage File URL" do
    config_grpc = Google::Cloud::Speech::V1beta1::RecognitionConfig.new(encoding: :LINEAR16, sample_rate: 16000)
    audio_grpc = Google::Cloud::Speech::V1beta1::RecognitionAudio.new(uri: "gs://some_bucket/audio.raw")

    mock = Minitest::Mock.new
    mock.expect :sync_recognize, results_grpc, [config_grpc, audio_grpc]

    speech.service.mocked_service = mock
    gcs_fake = OpenStruct.new to_gs_url: "gs://some_bucket/audio.raw"
    results = speech.recognize gcs_fake, encoding: :raw, sample_rate: 16000
    mock.verify

    results.count.must_equal 1
    results.first.transcript.must_equal "how old is the Brooklyn Bridge"
    results.first.confidence.must_be_close_to 0.98267895
    results.first.alternatives.must_be :empty?
  end
end
