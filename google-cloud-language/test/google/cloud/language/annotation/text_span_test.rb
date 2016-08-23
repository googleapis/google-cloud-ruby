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

describe Google::Cloud::Language::Annotation::TextSpan do
  let(:text_span_hash) do
    {
      content: "Hello world!",
      beginOffset: -1
    }
  end
  let(:text_span_json) { text_span_hash.to_json }
  let(:text_span_grpc) { Google::Cloud::Language::V1beta1::TextSpan.decode_json  text_span_json }
  let(:text_span)      { Google::Cloud::Language::Annotation::TextSpan.from_grpc text_span_grpc }

  it "has attributes" do
    text_span.must_be_kind_of Google::Cloud::Language::Annotation::TextSpan

    text_span.text.must_equal    "Hello world!"
    text_span.content.must_equal "Hello world!"

    text_span.offset.must_equal       -1
    text_span.begin_offset.must_equal -1
  end
end
