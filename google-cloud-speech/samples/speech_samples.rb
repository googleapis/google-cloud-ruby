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

def speech_sync_recognize audio_file_path: nil
  # [START speech_transcribe_sync]
  # audio_file_path = "Path to file on which to perform speech recognition"

  require "google/cloud/speech"

  speech = Google::Cloud::Speech.speech version: :v1

  # [START speech_ruby_migration_sync_response]
  audio_file = File.binread audio_file_path
  config     = { encoding:          :LINEAR16,
                 sample_rate_hertz: 16_000,
                 language_code:     "en-US" }
  audio      = { content: audio_file }

  response = speech.recognize config: config, audio: audio

  results = response.results

  alternatives = results.first.alternatives
  alternatives.each do |alternative|
    puts "Transcription: #{alternative.transcript}"
  end
  # [END speech_ruby_migration_sync_response]
  # [END speech_transcribe_sync]
end

def speech_sync_recognize_words audio_file_path: nil
  # [START speech_sync_recognize_words]
  # audio_file_path = "Path to file on which to perform speech recognition"

  require "google/cloud/speech"

  speech = Google::Cloud::Speech.speech version: :v1

  audio_file = File.binread audio_file_path

  config = { encoding:                 :LINEAR16,
             sample_rate_hertz:        16_000,
             language_code:            "en-US",
             enable_word_time_offsets: true }
  audio  = { content: audio_file }

  response = speech.recognize config: config, audio: audio

  results = response.results

  alternatives = results.first.alternatives
  alternatives.each do |alternative|
    puts "Transcription: #{alternative.transcript}"

    alternative.words.each do |word|
      start_time = word.start_time.seconds + (word.start_time.nanos / 1_000_000_000.0)
      end_time   = word.end_time.seconds + (word.end_time.nanos / 1_000_000_000.0)

      puts "Word: #{word.word} #{start_time} #{end_time}"
    end
  end
  # [END speech_sync_recognize_words]
end

def speech_sync_recognize_gcs storage_path: nil
  # [START speech_transcribe_sync_gcs]
  # storage_path = "Path to file in Cloud Storage, eg. gs://bucket/audio.raw"

  require "google/cloud/speech"

  speech = Google::Cloud::Speech.speech version: :v1

  # [START speech_ruby_migration_config_gcs]
  config = { encoding:          :LINEAR16,
             sample_rate_hertz: 16_000,
             language_code:     "en-US" }
  audio  = { uri: storage_path }

  response = speech.recognize config: config, audio: audio
  # [END speech_ruby_migration_config_gcs]

  results = response.results

  alternatives = results.first.alternatives
  alternatives.each do |alternative|
    puts "Transcription: #{alternative.transcript}"
  end
  # [END speech_transcribe_sync_gcs]
end

def speech_async_recognize audio_file_path: nil
  # [START speech_transcribe_async]
  # audio_file_path = "Path to file on which to perform speech recognition"

  require "google/cloud/speech"

  speech = Google::Cloud::Speech.speech version: :v1

  # [START speech_ruby_migration_async_response]
  # [START speech_ruby_migration_async_request]
  audio_file = File.binread audio_file_path
  config     = { encoding:          :LINEAR16,
                 sample_rate_hertz: 16_000,
                 language_code:     "en-US" }
  audio      = { content: audio_file }

  operation = speech.long_running_recognize config: config, audio: audio

  puts "Operation started"

  operation.wait_until_done!

  raise operation.results.message if operation.error?

  results = operation.response.results
  # [END speech_ruby_migration_async_request]

  alternatives = results.first.alternatives
  alternatives.each do |alternative|
    puts "Transcription: #{alternative.transcript}"
  end
  # [END speech_ruby_migration_async_response]
  # [END speech_transcribe_async]
end

def speech_async_recognize_gcs storage_path: nil
  # [START speech_transcribe_async_gcs]
  # storage_path = "Path to file in Cloud Storage, eg. gs://bucket/audio.raw"

  require "google/cloud/speech"

  speech = Google::Cloud::Speech.speech version: :v1

  config = { encoding:          :LINEAR16,
             sample_rate_hertz: 16_000,
             language_code:     "en-US" }
  audio = { uri: storage_path }

  operation = speech.long_running_recognize config: config, audio: audio

  puts "Operation started"

  operation.wait_until_done!

  raise operation.results.message if operation.error?

  results = operation.response.results

  alternatives = results.first.alternatives
  alternatives.each do |alternative|
    puts "Transcription: #{alternative.transcript}"
  end
  # [END speech_transcribe_async_gcs]
end

def speech_async_recognize_gcs_words storage_path: nil
  # [START speech_transcribe_async_word_time_offsets_gcs]
  # storage_path = "Path to file in Cloud Storage, eg. gs://bucket/audio.raw"

  require "google/cloud/speech"

  speech = Google::Cloud::Speech.speech version: :v1

  config = { encoding:                 :LINEAR16,
             sample_rate_hertz:        16_000,
             language_code:            "en-US",
             enable_word_time_offsets: true }
  audio  = { uri: storage_path }

  operation = speech.long_running_recognize config: config, audio: audio

  puts "Operation started"

  operation.wait_until_done!

  raise operation.results.message if operation.error?

  results = operation.response.results

  results.first.alternatives.each do |alternative|
    puts "Transcription: #{alternative.transcript}"

    alternative.words.each do |word|
      start_time = word.start_time.seconds + (word.start_time.nanos / 1_000_000_000.0)
      end_time   = word.end_time.seconds + (word.end_time.nanos / 1_000_000_000.0)

      puts "Word: #{word.word} #{start_time} #{end_time}"
    end
  end
  # [END speech_transcribe_async_word_time_offsets_gcs]
end

def speech_streaming_recognize audio_file_path: nil
  # [START speech_transcribe_streaming]
  # audio_file_path = "Path to file on which to perform speech recognition"

  require "google/cloud/speech"

  speech = Google::Cloud::Speech.speech version: :v1

  # [START speech_ruby_migration_streaming_response]
  # [START speech_ruby_migration_streaming_request]
  audio_content = File.binread audio_file_path
  bytes_total   = audio_content.size
  bytes_sent    = 0
  chunk_size    = 32_000

  input_stream = Gapic::StreamInput.new
  output_stream = speech.streaming_recognize input_stream

  config = {
    config: {
      encoding:                 :LINEAR16,
      sample_rate_hertz:        16_000,
      language_code:            "en-US",
      enable_word_time_offsets: true
    }
  }
  input_stream.push streaming_config: config

  # Simulated streaming from a microphone
  # Stream bytes...
  while bytes_sent < bytes_total
    input_stream.push audio_content: audio_content[bytes_sent, chunk_size]
    bytes_sent += chunk_size
    sleep 1
  end

  puts "Stopped passing"
  input_stream.close

  results = output_stream
  # [END speech_ruby_migration_streaming_request]

  results.each do |result|
    puts "Transcript: #{result}"
  end
  # [END speech_ruby_migration_streaming_response]
  # [END speech_transcribe_streaming]
end

def speech_transcribe_auto_punctuation audio_file_path: nil
  # [START speech_transcribe_auto_punctuation]
  # audio_file_path = "path/to/audio.wav"

  require "google/cloud/speech"

  speech = Google::Cloud::Speech.speech version: :v1

  config = {
    encoding:                     :LINEAR16,
    sample_rate_hertz:            8000,
    language_code:                "en-US",
    enable_automatic_punctuation: true
  }

  audio_file = File.binread audio_file_path
  audio      = { content: audio_file }

  operation = speech.long_running_recognize config: config, audio: audio

  puts "Operation started"

  operation.wait_until_done!

  raise operation.results.message if operation.error?

  results = operation.response.results

  results.each_with_index do |result, i|
    alternative = result.alternatives.first
    puts "-" * 20
    puts "First alternative of result #{i}"
    puts "Transcript: #{alternative.transcript}"
  end
  # [END speech_transcribe_auto_punctuation]
end

def speech_transcribe_enhanced_model audio_file_path: nil
  # [START speech_transcribe_enhanced_model]
  # audio_file_path = "path/to/audio.wav"

  require "google/cloud/speech"

  speech = Google::Cloud::Speech.speech version: :v1

  config = {
    encoding:          :LINEAR16,
    sample_rate_hertz: 8000,
    language_code:     "en-US",
    use_enhanced:      true,
    model:             "phone_call"
  }

  audio_file = File.binread audio_file_path
  audio      = { content: audio_file }

  operation = speech.long_running_recognize config: config, audio: audio

  puts "Operation started"

  operation.wait_until_done!

  raise operation.results.message if operation.error?

  results = operation.response.results

  results.each_with_index do |result, i|
    alternative = result.alternatives.first
    puts "-" * 20
    puts "First alternative of result #{i}"
    puts "Transcript: #{alternative.transcript}"
  end
  # [END speech_transcribe_enhanced_model]
end

def speech_transcribe_model_selection file_path: nil, model: nil
  # [START speech_transcribe_model_selection]
  # file_path = "path/to/audio.wav"

  require "google/cloud/speech"

  speech = Google::Cloud::Speech.speech version: :v1

  config = {
    encoding:          :LINEAR16,
    sample_rate_hertz: 16_000,
    language_code:     "en-US",
    model:             model
  }

  file  = File.binread file_path
  audio = { content: file }

  operation = speech.long_running_recognize config: config, audio: audio

  puts "Operation started"

  operation.wait_until_done!

  raise operation.results.message if operation.error?

  results = operation.response.results

  results.each_with_index do |result, i|
    alternative = result.alternatives.first
    puts "-" * 20
    puts "First alternative of result #{i}"
    puts "Transcript: #{alternative.transcript}"
  end
  # [END speech_transcribe_model_selection]
end

def speech_transcribe_multichannel audio_file_path: nil
  # [START speech_transcribe_multichannel]
  # audio_file_path = "path/to/audio.wav"

  require "google/cloud/speech"

  speech = Google::Cloud::Speech.speech version: :v1

  config = {
    encoding:                                :LINEAR16,
    sample_rate_hertz:                       44_100,
    language_code:                           "en-US",
    audio_channel_count:                     2,
    enable_separate_recognition_per_channel: true
  }

  audio_file = File.binread audio_file_path
  audio      = { content: audio_file }

  response = speech.recognize config: config, audio: audio

  results = response.results

  results.each_with_index do |result, i|
    alternative = result.alternatives.first
    puts "-" * 20
    puts "First alternative of result #{i}"
    puts "Transcript: #{alternative.transcript}"
    puts "Channel Tag: #{result.channel_tag}"
  end
  # [END speech_transcribe_multichannel]
end

def speech_transcribe_multichannel_gcs storage_path: nil
  # [START speech_transcribe_multichannel_gcs]
  # storage_path = "Path to file in Cloud Storage, eg. gs://bucket/audio.raw"

  require "google/cloud/speech"

  speech = Google::Cloud::Speech.speech version: :v1

  config = {
    encoding:                                :LINEAR16,
    sample_rate_hertz:                       44_100,
    language_code:                           "en-US",
    audio_channel_count:                     2,
    enable_separate_recognition_per_channel: true
  }

  audio = { uri: storage_path }

  response = speech.recognize config: config, audio: audio

  results = response.results

  results.each_with_index do |result, i|
    alternative = result.alternatives.first
    puts "-" * 20
    puts "First alternative of result #{i}"
    puts "Transcript: #{alternative.transcript}"
    puts "Channel Tag: #{result.channel_tag}"
  end
  # [END speech_transcribe_multichannel_gcs]
end

if $PROGRAM_NAME == __FILE__
  command = ARGV.shift

  case command
  when "recognize"
    speech_sync_recognize audio_file_path: ARGV.first
  when "recognize_words"
    speech_sync_recognize_words audio_file_path: ARGV.first
  when "recognize_gcs"
    speech_sync_recognize_gcs storage_path: ARGV.first
  when "async_recognize"
    speech_async_recognize audio_file_path: ARGV.first
  when "async_recognize_gcs"
    speech_async_recognize_gcs storage_path: ARGV.first
  when "async_recognize_gcs_words"
    speech_async_recognize_gcs_words storage_path: ARGV.first
  when "stream_recognize"
    speech_streaming_recognize audio_file_path: ARGV.first
  when "auto_punctuation"
    speech_transcribe_auto_punctuation audio_file_path: ARGV.first
  when "enhanced_model"
    speech_transcribe_enhanced_model audio_file_path: ARGV.first
  when "model_selection"
    speech_transcribe_model_selection file_path: ARGV.first, model: ARGV[1]
  when "multichannel"
    speech_transcribe_multichannel audio_file_path: ARGV.first
  when "multichannel_gcs"
    speech_transcribe_multichannel_gcs storage_path: ARGV.first
  else
    puts <<~USAGE
      Usage: ruby speech_samples.rb <command> [arguments]

      Commands:
        recognize                 <filename> Detects speech in a local audio file.
        recognize_words           <filename> Detects speech in a local audio file with word offsets.
        recognize_gcs             <gcsUri>   Detects speech in an audio file located in a Google Cloud Storage bucket.
        async_recognize           <filename> Creates a job to detect speech in a local audio file, and waits for the job to complete.
        async_recognize_gcs       <gcsUri>   Creates a job to detect speech in an audio file located in a Google Cloud Storage bucket, and waits for the job to complete.
        async_recognize_gcs_words <gcsUri>   Creates a job to detect speech with wordsoffsets in an audio file located in a Google Cloud Storage bucket, and waits for the job to complete.
        stream_recognize          <filename> Detects speech in a local audio file by streaming it to the Speech API.
        auto_punctuation          <filename> Detects speech in a local audio file, including automatic punctuation in the transcript.
        enhanced_model            <filename> Detects speech in a local audio file, using a model enhanced for phone call audio.
        model_selection           <filename> Detects speech in a local file, using a specific model.
        multichannel              <filename> Detects speech in separate channels in a local file.
        multichannel_gcs          <gcsUri>   Detects speech in separate channels in an audio file located in a Google Cloud Storage bucket.
    USAGE
  end
end
