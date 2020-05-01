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

require_relative "../speech_samples"
require "rspec"
require "google/cloud/speech"
require "google/cloud/storage"

describe "Google Cloud Speech API samples" do
  before do
    @bucket_name = ENV["GOOGLE_CLOUD_STORAGE_BUCKET"]
    @storage     = Google::Cloud::Storage.new
    @bucket      = @storage.bucket @bucket_name

    @storage.create_bucket @bucket_name unless @storage.bucket @bucket_name

    # Path to RAW audio file with sample rate of 16000 using LINEAR16 encoding
    @audio_file_path = File.expand_path "../resources/audio.raw", __dir__

    # Path to WAV audio file with sample rate of 44100 using LINEAR16 encoding with 2 channels
    @multi_file_path = File.expand_path "../resources/multi.wav", __dir__

    # Expected transcript of spoken English recorded in the audio.raw file
    @audio_file_transcript = "how old is the Brooklyn Bridge"
  end

  # Capture and return STDOUT output by block
  def capture
    real_stdout = $stdout
    $stdout = StringIO.new
    yield
    @captured_output = $stdout.string
  ensure
    $stdout = real_stdout
  end
  attr_reader :captured_output

  example "transcribe audio file" do
    expect {
      speech_sync_recognize audio_file_path: @audio_file_path
    }.to output("Transcription: #{@audio_file_transcript}\n").to_stdout
  end

  example "transcribe audio file with words" do
    capture do
      speech_sync_recognize_words audio_file_path: @audio_file_path
    end

    expect(captured_output).to include "Transcription: how old is the Brooklyn Bridge"
    expect(captured_output).to include "Word: how 0.0 0.3"
    expect(captured_output).to include "Word: old 0.3 0.6"
    expect(captured_output).to include "Word: is 0.6 0.8"
    expect(captured_output).to include "Word: the 0.8 0.9"
    expect(captured_output).to include "Word: Brooklyn 0.9 1.1"
    expect(captured_output).to include "Word: Bridge 1.1 1.4"
  end

  example "transcribe audio file from GCS" do
    file = @bucket.upload_file @audio_file_path, "audio.raw"
    path = "gs://#{file.bucket}/audio.raw"

    expect {
      speech_sync_recognize_gcs storage_path: path
    }.to output("Transcription: #{@audio_file_transcript}\n").to_stdout
  end

  example "async operation to transcribe audio file" do
    expect {
      speech_async_recognize audio_file_path: @audio_file_path
    }.to output("Operation started\nTranscription: #{@audio_file_transcript}\n").to_stdout
  end

  example "async operation to transcribe audio file from GCS" do
    file = @bucket.upload_file @audio_file_path, "audio.raw"
    path = "gs://#{file.bucket}/audio.raw"

    expect {
      speech_async_recognize_gcs storage_path: path
    }.to output("Operation started\nTranscription: #{@audio_file_transcript}\n").to_stdout
  end

  example "async operation to transcribe audio file from GCS with words" do
    file = @bucket.upload_file @audio_file_path, "audio.raw"
    path = "gs://#{file.bucket}/audio.raw"

    capture do
      speech_async_recognize_gcs_words storage_path: path
    end

    expect(captured_output).to include "Operation started"
    expect(captured_output).to include "Transcription: how old is the Brooklyn Bridge"
    expect(captured_output).to include "Word: how 0.0 0.3"
    expect(captured_output).to include "Word: old 0.3 0.6"
    expect(captured_output).to include "Word: is 0.6 0.8"
    expect(captured_output).to include "Word: the 0.8 0.9"
    expect(captured_output).to include "Word: Brooklyn 0.9 1.1"
    expect(captured_output).to include "Word: Bridge 1.1 1.4"
  end

  example "streaming operation to transcribe audio file" do
    expect {
      speech_streaming_recognize audio_file_path: @audio_file_path
    }.to output(
      /how old is the Brooklyn Bridge/
    ).to_stdout
  end

  example "transcribe audio file with automatic punctuation" do
    audio_file_path = File.expand_path "../resources/commercial_mono.wav", __dir__
    expect {
      speech_transcribe_auto_punctuation audio_file_path: audio_file_path
    }.to output(/I'm here\./).to_stdout
  end

  example "transcribe audio file with enhanced phone call model" do
    audio_file_path = File.expand_path "../resources/commercial_mono.wav", __dir__
    expect {
      speech_transcribe_enhanced_model audio_file_path: audio_file_path
    }.to output(/Chrome/).to_stdout
  end

  example "transcribe audio file with enhanced video model" do
    video_file_path = File.expand_path "../resources/Google_Gnome.wav", __dir__
    expect {
      speech_transcribe_model_selection file_path: video_file_path, model: "video"
    }.to output(/the weather outside is sunny/).to_stdout
  end

  example "transcribe audio file with multichannel" do
    audio_file_path = File.expand_path "../resources/multi.wav", __dir__
    expect {
      speech_transcribe_multichannel audio_file_path: audio_file_path
    }.to output(/how are you doing/).to_stdout
  end

  example "transcribe audio file with multichannel from GCS" do
    file = @bucket.upload_file @multi_file_path, "multi.wav"
    path = "gs://#{file.bucket}/multi.wav"

    expect {
      speech_transcribe_multichannel_gcs storage_path: path
    }.to output(/how are you doing/).to_stdout
  end
end
