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

require "speech_helper"

describe "Synchonous Recognition", :speech do
  let(:filepath) { "acceptance/data/audio.raw" }

  let(:bucket)   { storage.bucket($speech_prefix) || storage.create_bucket($speech_prefix) }
  let(:gcs_file) { bucket.file("audio.raw") || bucket.create_file(filepath, "audio.raw") }
  let(:gcs_url)  { gcs_file.to_gs_url }

  it "recognizes audio from local file path" do
    results = speech.recognize filepath, encoding: :raw, sample_rate: 16000

    results.count.must_equal 1
    results.first.transcript.must_equal "how old is the Brooklyn Bridge"
    results.first.confidence.must_be_close_to 0.98267895
    results.first.alternatives.must_be :empty?
  end

  it "recognizes audio from local file object" do
    results = speech.recognize File.open(filepath, "rb"), encoding: :raw, sample_rate: 16000

    results.count.must_equal 1
    results.first.transcript.must_equal "how old is the Brooklyn Bridge"
    results.first.confidence.must_be_close_to 0.98267895
    results.first.alternatives.must_be :empty?
  end

  it "recognizes audio from GCS URL" do
    results = speech.recognize gcs_url, encoding: :raw, sample_rate: 16000

    results.count.must_equal 1
    results.first.transcript.must_equal "how old is the Brooklyn Bridge"
    results.first.confidence.must_be_close_to 0.98267895
    results.first.alternatives.must_be :empty?
  end

  it "recognizes audio from Storage File object" do
    results = speech.recognize gcs_file, encoding: :raw, sample_rate: 16000

    results.count.must_equal 1
    results.first.transcript.must_equal "how old is the Brooklyn Bridge"
    results.first.confidence.must_be_close_to 0.98267895
    results.first.alternatives.must_be :empty?
  end

  it "recognizes audio from Audio object" do
    audio = speech.audio gcs_url, encoding: :raw, sample_rate: 16000, language: "en"
    results = speech.recognize audio

    results.count.must_equal 1
    results.first.transcript.must_equal "how old is the Brooklyn Bridge"
    results.first.confidence.must_be_close_to 0.98267895
    results.first.alternatives.must_be :empty?
  end

  it "recognizes audio from Audio object, preserving attributes" do
    audio = speech.audio gcs_url
    results = speech.recognize audio, encoding: :raw, sample_rate: 16000, language: "en"

    results.count.must_equal 1
    results.first.transcript.must_equal "how old is the Brooklyn Bridge"
    results.first.confidence.must_be_close_to 0.98267895
    results.first.alternatives.must_be :empty?
  end

  it "recognizes audio from Audio object, overriding attributes" do
    audio = speech.audio gcs_url, encoding: :flac, sample_rate: 48000, language: "es"
    results = speech.recognize audio, encoding: :raw, sample_rate: 16000, language: "en"

    results.count.must_equal 1
    results.first.transcript.must_equal "how old is the Brooklyn Bridge"
    results.first.confidence.must_be_close_to 0.98267895
    results.first.alternatives.must_be :empty?
  end
end
