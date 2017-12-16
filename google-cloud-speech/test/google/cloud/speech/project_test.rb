# Copyright 2016 Google LLC
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

describe Google::Cloud::Speech::Project, :mock_speech do
  let(:filepath) { "acceptance/data/audio.raw" }

  it "knows the project identifier" do
    speech.must_be_kind_of Google::Cloud::Speech::Project
    speech.project.must_equal project
  end

  it "builds an audio from filepath input" do
    audio = speech.audio filepath

    audio.wont_be :nil?
    audio.must_be_kind_of Google::Cloud::Speech::Audio
    audio.must_be :content?
    audio.wont_be :url?
    audio.language.must_be :nil?
  end

  it "builds an audio from filepath and language (String) input" do
    audio = speech.audio filepath, language: "en-US"

    audio.wont_be :nil?
    audio.must_be_kind_of Google::Cloud::Speech::Audio
    audio.must_be :content?
    audio.wont_be :url?
    audio.language.wont_be :nil?
  end

  it "builds an audio from filepath and language (Symbol) input" do
    audio = speech.audio filepath, language: "en-US"

    audio.wont_be :nil?
    audio.must_be_kind_of Google::Cloud::Speech::Audio
    audio.must_be :content?
    audio.wont_be :url?
    audio.language.wont_be :nil?
  end
end
