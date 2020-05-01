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


require_relative "helper"
require_relative "../speech_samples.rb"

describe "Google Cloud Speech API samples" do
  parallelize_me!
  before do
    # Path to RAW audio file with sample rate of 16000 using LINEAR16 encoding
    @audio_file_path = File.expand_path "../resources/brooklyn_bridge.raw", __dir__

    # Path to WAV audio file with sample rate of 44100 using LINEAR16 encoding with 2 channels
    @multi_file_path = File.expand_path "../resources/multi.wav", __dir__

    # Expected transcript of spoken English recorded in the audio.raw file
    @audio_file_transcript = "how old is the Brooklyn Bridge"
  end

  it "transcribe audio file" do
    out, _err = capture_io do
      speech_sync_recognize audio_file_path: @audio_file_path
    end

    assert_match "Transcription: #{@audio_file_transcript}", out
  end

  it "transcribe audio file with words" do
    out, _err = capture_io do
      speech_sync_recognize_words audio_file_path: @audio_file_path
    end

    assert_match "Transcription: how old is the Brooklyn Bridge", out
    assert_match "Word: how 0.0 0.3", out
    assert_match "Word: old 0.3 0.6", out
    assert_match "Word: is 0.6 0.8", out
    assert_match "Word: the 0.8 0.9", out
    assert_match "Word: Brooklyn 0.9 1.1", out
    assert_match "Word: Bridge 1.1 1.4", out
  end

  it "transcribe audio file from GCS" do
    path = "gs://cloud-samples-data/speech/brooklyn_bridge.raw"

    out, _err = capture_io do
      speech_sync_recognize_gcs storage_path: path
    end

    assert_match "Transcription: #{@audio_file_transcript}", out
  end

  it "async operation to transcribe audio file" do
    out, _err = capture_io do
      speech_async_recognize audio_file_path: @audio_file_path
    end

    assert_match "Operation started", out
    assert_match "Transcription: #{@audio_file_transcript}", out
  end

  it "async operation to transcribe audio file from GCS" do
    path = "gs://cloud-samples-data/speech/brooklyn_bridge.raw"

    out, _err = capture_io do
      speech_async_recognize_gcs storage_path: path
    end

    assert_match "Operation started", out
    assert_match "Transcription: #{@audio_file_transcript}\n", out
  end

  it "async operation to transcribe audio file from GCS with words" do
    path = "gs://cloud-samples-data/speech/brooklyn_bridge.raw"

    out, _err = capture_io do
      speech_async_recognize_gcs_words storage_path: path
    end

    assert_match "Operation started", out
    assert_match "Transcription: how old is the Brooklyn Bridge", out
    assert_match "Word: how 0.0 0.3", out
    assert_match "Word: old 0.3 0.6", out
    assert_match "Word: is 0.6 0.8", out
    assert_match "Word: the 0.8 0.9", out
    assert_match "Word: Brooklyn 0.9 1.1", out
    assert_match "Word: Bridge 1.1 1.4", out
  end

  it "streaming operation to transcribe audio file" do
    out, _err = capture_io do
      speech_streaming_recognize audio_file_path: @audio_file_path
    end

    assert_match "how old is the Brooklyn Bridge", out
  end

  it "transcribe audio file with automatic punctuation" do
    audio_file_path = File.expand_path "../resources/commercial_mono.wav", __dir__

    out, _err = capture_io do
      speech_transcribe_auto_punctuation audio_file_path: audio_file_path
    end
    assert_match "I'm here", out
  end

  it "transcribe audio file with enhanced phone call model" do
    audio_file_path = File.expand_path "../resources/commercial_mono.wav", __dir__
    out, _err = capture_io do
      speech_transcribe_enhanced_model audio_file_path: audio_file_path
    end
    assert_match "Chrome", out
  end

  it "transcribe audio file with enhanced video model" do
    video_file_path = File.expand_path "../resources/Google_Gnome.wav", __dir__
    out, _err = capture_io do
      speech_transcribe_model_selection file_path: video_file_path, model: "video"
    end

    assert_match "the weather outside is sunny", out
  end

  it "transcribe audio file with multichannel" do
    audio_file_path = File.expand_path "../resources/multi.wav", __dir__
    out, _err = capture_io do
      speech_transcribe_multichannel audio_file_path: audio_file_path
    end

    assert_match "how are you doing", out
  end

  it "transcribe audio file with multichannel from GCS" do
    path = "gs://cloud-samples-data/speech/multi.wav"

    out, _err = capture_io do
      speech_transcribe_multichannel_gcs storage_path: path
    end
    assert_match "how are you doing", out
  end
end
