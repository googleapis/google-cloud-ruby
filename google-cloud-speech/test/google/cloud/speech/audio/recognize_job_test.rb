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

describe Google::Cloud::Speech::Audio, :recognize_job, :mock_speech do
  let(:filepath) { "acceptance/data/audio.raw" }
  let(:audio_grpc) { Google::Cloud::Speech::V1beta1::RecognitionAudio.new(content: File.read(filepath, mode: "rb")) }
  let(:audio) { Google::Cloud::Speech::Audio.from_source filepath, speech }
  let(:job_json) { "{\"name\":\"1234567890\",\"metadata\":{\"typeUrl\":\"type.googleapis.com/google.cloud.speech.v1beta1.AsyncRecognizeMetadata\",\"value\":\"CFQSDAi6jKS/BRCwkLafARoMCIeZpL8FEKjRqswC\"}}" }
  let(:job_grpc) { Google::Longrunning::Operation.decode_json job_json }

  it "recognizes audio job" do
    config_grpc = Google::Cloud::Speech::V1beta1::RecognitionConfig.new(encoding: :LINEAR16, sample_rate: 16000, language_code: "en")

    mock = Minitest::Mock.new
    mock.expect :async_recognize, job_grpc, [config_grpc, audio_grpc, options: default_options]

    audio.encoding = :raw
    audio.sample_rate = 16000
    audio.language = "en"

    speech.service.mocked_service = mock
    job = audio.recognize_job
    mock.verify

    job.must_be_kind_of Google::Cloud::Speech::Job
    job.wont_be :done?
  end
end
