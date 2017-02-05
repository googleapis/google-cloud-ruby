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

describe Google::Cloud::Speech::Project, :recognize_job, :mock_speech do
  let(:job_json) { "{\"name\":\"1234567890\",\"metadata\":{\"typeUrl\":\"type.googleapis.com/google.cloud.speech.V1.AsyncRecognizeMetadata\",\"value\":\"CFQSDAi6jKS/BRCwkLafARoMCIeZpL8FEKjRqswC\"}}" }
  let(:job_grpc) { Google::Gax::Operation.new Google::Longrunning::Operation.decode_json(job_json), nil,
                     Google::Cloud::Speech::V1::LongRunningRecognizeResponse,
                     Google::Cloud::Speech::V1::LongRunningRecognizeMetadata }

  it "recognizes audio from local file path" do
    config_grpc = Google::Cloud::Speech::V1::RecognitionConfig.new(encoding: :LINEAR16, language_code: "en-US", sample_rate_hertz: 16000)
    audio_grpc = Google::Cloud::Speech::V1::RecognitionAudio.new(content: File.read("acceptance/data/audio.raw", mode: "rb"))

    mock = Minitest::Mock.new
    mock.expect :long_running_recognize, job_grpc, [config_grpc, audio_grpc, options: default_options]

    speech.service.mocked_service = mock
    job = speech.recognize_job "acceptance/data/audio.raw", encoding: :raw, language: "en-US", sample_rate: 16000
    mock.verify

    job.must_be_kind_of Google::Cloud::Speech::Job
    job.wont_be :done?
  end

  it "recognizes audio from local file object" do
    config_grpc = Google::Cloud::Speech::V1::RecognitionConfig.new(encoding: :LINEAR16, language_code: "en-US", sample_rate_hertz: 16000)
    audio_grpc = Google::Cloud::Speech::V1::RecognitionAudio.new(content: File.read("acceptance/data/audio.raw", mode: "rb"))

    mock = Minitest::Mock.new
    mock.expect :long_running_recognize, job_grpc, [config_grpc, audio_grpc, options: default_options]

    speech.service.mocked_service = mock
    job = speech.recognize_job File.open("acceptance/data/audio.raw", "rb"), encoding: :raw, language: "en-US", sample_rate: 16000
    mock.verify

    job.must_be_kind_of Google::Cloud::Speech::Job
    job.wont_be :done?
  end

  it "recognizes audio from GCS URL" do
    config_grpc = Google::Cloud::Speech::V1::RecognitionConfig.new(encoding: :LINEAR16, language_code: "en-US", sample_rate_hertz: 16000)
    audio_grpc = Google::Cloud::Speech::V1::RecognitionAudio.new(uri: "gs://some_bucket/audio.raw")

    mock = Minitest::Mock.new
    mock.expect :long_running_recognize, job_grpc, [config_grpc, audio_grpc, options: default_options]

    speech.service.mocked_service = mock
    job = speech.recognize_job "gs://some_bucket/audio.raw", encoding: :raw, language: "en-US", sample_rate: 16000
    mock.verify

    job.must_be_kind_of Google::Cloud::Speech::Job
    job.wont_be :done?
  end

  it "recognizes audio from Storage File URL" do
    config_grpc = Google::Cloud::Speech::V1::RecognitionConfig.new(encoding: :LINEAR16, language_code: "en-US", sample_rate_hertz: 16000)
    audio_grpc = Google::Cloud::Speech::V1::RecognitionAudio.new(uri: "gs://some_bucket/audio.raw")

    mock = Minitest::Mock.new
    mock.expect :long_running_recognize, job_grpc, [config_grpc, audio_grpc, options: default_options]

    speech.service.mocked_service = mock
    gcs_fake = OpenStruct.new to_gs_url: "gs://some_bucket/audio.raw"
    job = speech.recognize_job gcs_fake, encoding: :raw, language: "en-US", sample_rate: 16000
    mock.verify

    job.must_be_kind_of Google::Cloud::Speech::Job
    job.wont_be :done?
  end

  it "recognizes audio from Audio object" do
    config_grpc = Google::Cloud::Speech::V1::RecognitionConfig.new(encoding: :LINEAR16, language_code: "en-US", sample_rate_hertz: 16000)
    audio_grpc = Google::Cloud::Speech::V1::RecognitionAudio.new(uri: "gs://some_bucket/audio.raw")

    mock = Minitest::Mock.new
    mock.expect :long_running_recognize, job_grpc, [config_grpc, audio_grpc, options: default_options]

    speech.service.mocked_service = mock
    audio = speech.audio "gs://some_bucket/audio.raw"
    job = speech.recognize_job audio, encoding: :raw, language: "en-US", sample_rate: 16000
    mock.verify

    job.must_be_kind_of Google::Cloud::Speech::Job
    job.wont_be :done?
  end

  it "recognizes audio from Audio object, preserving attributes" do
    config_grpc = Google::Cloud::Speech::V1::RecognitionConfig.new(encoding: :LINEAR16, language_code: "en-US", sample_rate_hertz: 16000)
    audio_grpc = Google::Cloud::Speech::V1::RecognitionAudio.new(uri: "gs://some_bucket/audio.raw")

    mock = Minitest::Mock.new
    mock.expect :long_running_recognize, job_grpc, [config_grpc, audio_grpc, options: default_options]

    speech.service.mocked_service = mock
    audio = speech.audio "gs://some_bucket/audio.raw", encoding: :raw, language: "en-US", sample_rate: 16000
    job = speech.recognize_job audio
    mock.verify

    job.must_be_kind_of Google::Cloud::Speech::Job
    job.wont_be :done?
  end

  it "recognizes audio from Audio object, overriding attributes" do
    config_grpc = Google::Cloud::Speech::V1::RecognitionConfig.new(encoding: :LINEAR16, language_code: "en-US", sample_rate_hertz: 16000)
    audio_grpc = Google::Cloud::Speech::V1::RecognitionAudio.new(uri: "gs://some_bucket/audio.raw")

    mock = Minitest::Mock.new
    mock.expect :long_running_recognize, job_grpc, [config_grpc, audio_grpc, options: default_options]

    speech.service.mocked_service = mock
    audio = speech.audio "gs://some_bucket/audio.raw", encoding: :flac, sample_rate: 48000, language: "en-US"
    job = speech.recognize_job audio, encoding: :raw, language: "en-US", sample_rate: 16000
    mock.verify

    job.must_be_kind_of Google::Cloud::Speech::Job
    job.wont_be :done?
  end
end
