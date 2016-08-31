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
require "tempfile"
require "pathname"

describe Google::Cloud::Speech::Audio, :mock_speech do
  let(:filepath) { "acceptance/data/audio.raw" }

  it "can create from an existing file path" do
    audio = speech.audio filepath, encoding: :raw, sample_rate: 16000

    audio.must_be_kind_of Google::Cloud::Speech::Audio
    audio.must_be :content?
    audio.wont_be :url?

    audio.to_grpc.must_be_kind_of Google::Cloud::Speech::V1beta1::RecognitionAudio
  end

  it "can create from a Pathname object" do
    audio = speech.audio Pathname.new(filepath), encoding: :raw, sample_rate: 16000, language: "en"

    audio.must_be_kind_of Google::Cloud::Speech::Audio
    audio.must_be :content?
    audio.wont_be :url?
    audio.encoding.must_equal :raw
    audio.sample_rate.must_equal 16000
    audio.language.must_equal "en"

    grpc = audio.to_grpc
    grpc.must_be_kind_of Google::Cloud::Speech::V1beta1::RecognitionAudio
    grpc.audio_source.must_equal :content
  end

  it "can create from a File object" do
    audio = speech.audio File.open(filepath, "rb"), encoding: :raw, sample_rate: 16000

    audio.must_be_kind_of Google::Cloud::Speech::Audio
    audio.must_be :content?
    audio.wont_be :url?
    audio.encoding.must_equal :raw
    audio.sample_rate.must_equal 16000
    audio.language.must_be :nil?

    grpc = audio.to_grpc
    grpc.must_be_kind_of Google::Cloud::Speech::V1beta1::RecognitionAudio
    grpc.audio_source.must_equal :content
  end

  it "can create from a StringIO object" do
    audio = speech.audio StringIO.new(File.read(filepath, mode: "rb"))

    audio.must_be_kind_of Google::Cloud::Speech::Audio
    audio.must_be :content?
    audio.wont_be :url?
    audio.encoding.must_be :nil?
    audio.sample_rate.must_be :nil?
    audio.language.must_be :nil?

    grpc = audio.to_grpc
    grpc.must_be_kind_of Google::Cloud::Speech::V1beta1::RecognitionAudio
    grpc.audio_source.must_equal :content
  end

  it "can create from a Tempfile object" do
    audio = nil
    Tempfile.open ["audio", "png"] do |tmpfile|
      tmpfile.binmode
      tmpfile.write File.read(filepath, mode: "rb")

      audio = speech.audio tmpfile, encoding: :raw, sample_rate: 16000

      audio.must_be_kind_of Google::Cloud::Speech::Audio
      audio.must_be :content?
      audio.wont_be :url?
      audio.encoding.must_equal :raw
      audio.sample_rate.must_equal 16000
      audio.language.must_be :nil?

      grpc = audio.to_grpc
      grpc.must_be_kind_of Google::Cloud::Speech::V1beta1::RecognitionAudio
      grpc.audio_source.must_equal :content
    end
  end

  it "can create from a Google Storage URL" do
    audio = speech.audio "gs://test/file.ext", encoding: :raw, sample_rate: 16000

    audio.must_be_kind_of Google::Cloud::Speech::Audio
    audio.wont_be :content?
    audio.must_be :url?
    audio.encoding.must_equal :raw
    audio.sample_rate.must_equal 16000
    audio.language.must_be :nil?

    grpc = audio.to_grpc
    grpc.must_be_kind_of Google::Cloud::Speech::V1beta1::RecognitionAudio
    grpc.audio_source.must_equal :uri
  end

  it "can create from a Storage::File object" do
    gs_img = OpenStruct.new to_gs_url: "gs://test/file.ext"
    audio = speech.audio gs_img, encoding: :raw, sample_rate: 16000

    audio.must_be_kind_of Google::Cloud::Speech::Audio
    audio.wont_be :content?
    audio.must_be :url?
    audio.encoding.must_equal :raw
    audio.sample_rate.must_equal 16000
    audio.language.must_be :nil?

    grpc = audio.to_grpc
    grpc.must_be_kind_of Google::Cloud::Speech::V1beta1::RecognitionAudio
    grpc.audio_source.must_equal :uri
  end

  it "raises when giving an object that is not IO or a Google Storage URL" do
    obj = OpenStruct.new hello: "world"

    expect { speech.audio obj, encoding: :raw, sample_rate: 16000 }.must_raise ArgumentError
  end
end
