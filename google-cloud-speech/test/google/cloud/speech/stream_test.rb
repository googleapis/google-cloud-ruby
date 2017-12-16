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

describe Google::Cloud::Speech::Stream, :mock_speech do
  it "knows itself" do
    stream = speech.stream encoding: :linear16, language: "en-US", sample_rate: 16000
    stream.must_be_kind_of Google::Cloud::Speech::Stream
    stream.wont_be :started?
    stream.wont_be :stopped?
  end
end
